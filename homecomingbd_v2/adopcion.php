<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');
header("Content-Type: application/json");

include 'config.php';

// Función principal que maneja todas las solicitudes
function manejarSolicitud($conexion) {
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $action = isset($_POST['action']) ? $_POST['action'] : 'registrar_interes';
        
        switch($action) {
            case 'registrar_interes':
                return registrarInteres($conexion);
            case 'confirmar_adopcion':
                return confirmarAdopcion($conexion);
            case 'rechazar_adopcion':
                return rechazarAdopcion($conexion);
            default:
                return jsonResponse('error', 'Acción no válida');
        }
    } elseif ($_SERVER['REQUEST_METHOD'] == 'GET') {
        return obtenerInteresados($conexion);
    }
    
    return jsonResponse('error', 'Método no permitido');
}

// Función para registrar interés en una mascota
    function registrarInteres($conexion) {
        $mascota_id = $_POST['mascota_id'] ?? null;
        $adoptante_id = $_POST['adoptante_id'] ?? null;
        
        if (!$mascota_id || !$adoptante_id) {
            return jsonResponse('error', 'Faltan datos requeridos');
        }

        // Iniciar transacción para asegurar que ambas operaciones se completen
        $conexion->begin_transaction();

        try {
            // Verificar si ya existe un registro
            $checkSql = "SELECT id, estado FROM adopciones 
                        WHERE mascota_id = ? AND adoptante_id = ?";
            
            $stmt = $conexion->prepare($checkSql);
            $stmt->bind_param("ii", $mascota_id, $adoptante_id);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $registro = $result->fetch_assoc();
                if ($registro['estado'] == 'interesado') {
                    $conexion->rollback();
                    return jsonResponse('error', 'Ya has registrado tu interés en esta mascota');
                }
            }
            
            // Insertar nuevo registro en adopciones
            $sql = "INSERT INTO adopciones (mascota_id, adoptante_id, estado, fecha_adopcion) 
                    VALUES (?, ?, 'interesado', CURRENT_TIMESTAMP)";
            
            $stmt = $conexion->prepare($sql);
            $stmt->bind_param("ii", $mascota_id, $adoptante_id);
            $stmt->execute();

            // Actualizar el estado de la mascota a 'pendiente'
            $updateSql = "UPDATE mascotas SET estado = 'pendiente' WHERE id = ?";
            $updateStmt = $conexion->prepare($updateSql);
            $updateStmt->bind_param("i", $mascota_id);
            $updateStmt->execute();

            // Si todo salió bien, confirmar la transacción
            $conexion->commit();
            return jsonResponse('success', 'Has registrado tu interés en la adopción');

        } catch (Exception $e) {
            // Si algo salió mal, deshacer los cambios
            $conexion->rollback();
            return jsonResponse('error', 'Error al registrar el interés: ' . $e->getMessage());
        }
    }

// Función para obtener lista de interesados en una mascota
function obtenerInteresados($conexion) {
    $mascota_id = isset($_GET['mascota_id']) ? $_GET['mascota_id'] : null;
    
    if (!$mascota_id) {
        return jsonResponse('error', 'ID de mascota no proporcionado');
    }
    
    // Añadimos u.id a la selección
    $sql = "SELECT u.id, u.nombre, u.primerApellido, u.segundoApellido, u.telefono, u.email, a.estado 
            FROM adopciones a 
            JOIN usuarios u ON a.adoptante_id = u.id 
            WHERE a.mascota_id = ? AND a.estado = 'interesado'
            ORDER BY a.fecha_creacion DESC";
    
    if ($stmt = $conexion->prepare($sql)) {
        $stmt->bind_param('i', $mascota_id);
        $stmt->execute();
        $resultado = $stmt->get_result();

        if ($resultado->num_rows > 0) {
            $interesados = [];
            while ($fila = $resultado->fetch_assoc()) {
                $interesados[] = $fila;
            }
            return jsonResponse('success', 'Interesados encontrados', $interesados);
        } else {
            return jsonResponse('error', 'No hay interesados para esta mascota');
        }
    }
    return jsonResponse('error', 'Error en la consulta');
}

function confirmarAdopcion($conexion) {
    $mascota_id = $_POST['mascota_id'] ?? null;
    $adoptante_id = $_POST['adoptante_id'] ?? null;
    
    if (!$mascota_id || !$adoptante_id) {
        return jsonResponse('error', 'Faltan datos requeridos');
    }
    
    $conexion->begin_transaction();
    
    try {
        // Verificar que exista el registro de adopción y esté en estado 'interesado'
        $sqlGetAdopcion = "SELECT id FROM adopciones 
                          WHERE mascota_id = ? 
                          AND adoptante_id = ? 
                          AND estado = 'interesado'";
        $stmtGetAdopcion = $conexion->prepare($sqlGetAdopcion);
        $stmtGetAdopcion->bind_param("ii", $mascota_id, $adoptante_id);
        $stmtGetAdopcion->execute();
        $result = $stmtGetAdopcion->get_result();
        
        if (!$result->num_rows) {
            $conexion->rollback();
            return jsonResponse('error', 'No se encontró el registro de adopción o ya no está en estado interesado');
        }
        
        $adopcion = $result->fetch_assoc();
        $adopcion_id = $adopcion['id'];
        
        // Actualizar estado de la adopción seleccionada a 'adoptado'
        $sqlUpdate = "UPDATE adopciones 
                     SET estado = 'adoptado', 
                         fecha_adopcion = CURRENT_TIMESTAMP 
                     WHERE id = ?";
        $stmtUpdate = $conexion->prepare($sqlUpdate);
        $stmtUpdate->bind_param("i", $adopcion_id);
        if (!$stmtUpdate->execute()) {
            throw new Exception("Error al actualizar el estado de la adopción");
        }
        
        // Actualizar estado de la mascota a 'adoptado'
        $sqlUpdateMascota = "UPDATE mascotas SET estado = 'adoptado' WHERE id = ?";
        $stmtUpdateMascota = $conexion->prepare($sqlUpdateMascota);
        $stmtUpdateMascota->bind_param("i", $mascota_id);
        if (!$stmtUpdateMascota->execute()) {
            throw new Exception("Error al actualizar el estado de la mascota");
        }
        
        // Rechazar otras solicitudes de adopción para esta mascota
        $sqlRechazar = "UPDATE adopciones 
                       SET estado = 'rechazado' 
                       WHERE mascota_id = ? 
                       AND id != ? 
                       AND estado = 'interesado'";
        $stmtRechazar = $conexion->prepare($sqlRechazar);
        $stmtRechazar->bind_param("ii", $mascota_id, $adopcion_id);
        if (!$stmtRechazar->execute()) {
            throw new Exception("Error al rechazar otras solicitudes");
        }
        
        $conexion->commit();
        return jsonResponse('success', 'Adopción confirmada exitosamente');
        
    } catch (Exception $e) {
        $conexion->rollback();
        return jsonResponse('error', 'Error al confirmar la adopción: ' . $e->getMessage());
    }
}

// Función para rechazar una adopción específica
function rechazarAdopcion($conexion) {
    $adopcion_id = $_POST['adopcion_id'] ?? null;
    
    if (!$adopcion_id) {
        return jsonResponse('error', 'ID de adopción no proporcionado');
    }
    
    $sql = "UPDATE adopciones SET estado = 'rechazado' WHERE id = ?";
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("i", $adopcion_id);
    
    if ($stmt->execute()) {
        return jsonResponse('success', 'Solicitud de adopción rechazada');
    }
    
    return jsonResponse('error', 'Error al rechazar la adopción');
}

// Función auxiliar para respuestas JSON
function jsonResponse($status, $message, $data = null) {
    header('Content-Type: application/json');  // Añade esta línea para asegurar que el contenido es JSON
    
    $response = [
        'status' => $status,
        'message' => $message
    ];
    
    if ($data) {
        $response['data'] = $data;
    }
    
    // Enviar la respuesta JSON
    echo json_encode($response);
    exit; // Asegúrate de salir después de enviar la respuesta
}

// Ejecutar el manejador principal
manejarSolicitud($conexion);

// Cerrar la conexión
$conexion->close();
?>