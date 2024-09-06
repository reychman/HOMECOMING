<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

include 'config.php'; // Asumiendo que config.php tiene la conexión a la base de datos

// Verificar el método HTTP y el parámetro 'accion'
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $accion = isset($_POST['accion']) ? $_POST['accion'] : null;

    switch ($accion) {
        case 'obtenerPublicaciones':
            obtenerPublicaciones();
            break;
        case 'actualizarEstado':
            actualizarEstado();
            break;
        case 'eliminarPublicacion':
            eliminarPublicacion();
            break;
        case 'actualizarPublicacion':
            actualizarPublicacion();
            break;
        default:
            echo json_encode(['error' => 'Acción no válida']);
            break;
    }
} else {
    echo json_encode(['error' => 'Método no permitido']);
}

// Función para obtener las publicaciones del usuario
function obtenerPublicaciones() {
    global $conexion; // Uso de la conexión de base de datos desde config.php

    $usuario_id = isset($_POST['usuario_id']) ? $_POST['usuario_id'] : null;
      // Aquí agregas el log para verificar si el usuario_id se está recibiendo
    error_log("Usuario ID recibido: " . $usuario_id);
    
    if (!$usuario_id) {
        echo json_encode(['error' => 'Falta el usuario_id']);
        exit;
    }

    $sql = "SELECT M.id, M.nombre, M.especie, M.raza, M.sexo, M.fecha_perdida, M.lugar_perdida, M.estado, M.descripcion, M.foto, U.nombre AS nombre_dueno, U.email AS email_dueno, U.telefono AS telefono_dueno
            FROM mascotas M
            JOIN usuarios U ON M.usuario_id = U.id
            WHERE M.usuario_id = ? AND M.estado_registro = 1";  // Filtrar por el usuario logueado y solo mascotas activas
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("i", $usuario_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $mascotas = array();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $mascotas[] = array(
                'id' => (int)$row['id'],
                'nombre' => $row['nombre'],
                'especie' => $row['especie'],
                'raza' => $row['raza'],
                'sexo' => $row['sexo'],
                'fecha_perdida' => $row['fecha_perdida'],
                'lugar_perdida' => $row['lugar_perdida'],
                'estado' => $row['estado'],
                'descripcion' => $row['descripcion'],
                'foto' => $row['foto'],
                'nombre_dueno' => $row['nombre_dueno'],
                'email_dueno' => $row['email_dueno'],
                'telefono_dueno' => $row['telefono_dueno']
            );
        }
    }

    // Verifica si se encontraron mascotas
    if (empty($mascotas)) {
        echo json_encode(['error' => 'No se encontraron publicaciones para este usuario']);
    } else {
        echo json_encode($mascotas);
    }
}

// Función para actualizar el estado de una mascota (perdido/encontrado)
function actualizarEstado() {
    global $conexion;

    $id = isset($_POST['id']) ? $_POST['id'] : null;
    $nuevoEstado = isset($_POST['estado']) ? $_POST['estado'] : null;

    if ($id && $nuevoEstado) {
        $sql = "UPDATE mascotas SET estado = ? WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("si", $nuevoEstado, $id);
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Estado actualizado']);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo actualizar el estado']);
        }
    } else {
        echo json_encode(['error' => 'Faltan datos']);
    }
}

// Función para eliminar una publicación lógicamente
function eliminarPublicacion() {
    global $conexion;

    $id = isset($_POST['id']) ? $_POST['id'] : null;

    if ($id) {
        $sql = "UPDATE mascotas SET estado_registro = 0 WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("i", $id);
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Publicación eliminada']);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo eliminar la publicación']);
        }
    } else {
        echo json_encode(['error' => 'Falta el id de la publicación']);
    }
}
function actualizarPublicacion() {
    global $conexion;

    $id = isset($_POST['id']) ? $_POST['id'] : null;
    $nombre = isset($_POST['nombre']) ? $_POST['nombre'] : null;
    $especie = isset($_POST['especie']) ? $_POST['especie'] : null;
    $raza = isset($_POST['raza']) ? $_POST['raza'] : null;
    $sexo = isset($_POST['sexo']) ? $_POST['sexo'] : null;
    $fecha_perdida = isset($_POST['fecha_perdida']) ? $_POST['fecha_perdida'] : null;
    $lugar_perdida = isset($_POST['lugar_perdida']) ? $_POST['lugar_perdida'] : null;
    $descripcion = isset($_POST['descripcion']) ? $_POST['descripcion'] : null;
    $foto = isset($_FILES['foto']) ? $_FILES['foto'] : null;

    if ($id && $nombre && $especie && $raza && $sexo && $fecha_perdida && $lugar_perdida && $descripcion) {
        // Actualizar la publicación en la base de datos
        $sql = "UPDATE mascotas SET 
                    nombre = ?, 
                    especie = ?, 
                    raza = ?, 
                    sexo = ?, 
                    fecha_perdida = ?, 
                    lugar_perdida = ?, 
                    descripcion = ?
                WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("sssssssi", $nombre, $especie, $raza, $sexo, $fecha_perdida, $lugar_perdida, $descripcion, $id);

        if ($stmt->execute()) {
            // Si hay una nueva foto, manejar la subida
            if ($foto) {
                $fotoNombre = $id . '_foto.jpg'; // Puedes personalizar el nombre de la imagen
                move_uploaded_file($_FILES['foto']['tmp_name'], "uploads/$fotoNombre");
                $sqlFoto = "UPDATE mascotas SET foto = ? WHERE id = ?";
                $stmtFoto = $conexion->prepare($sqlFoto);
                $stmtFoto->bind_param("si", $fotoNombre, $id);
                $stmtFoto->execute();
            }

            echo json_encode(['success' => true, 'message' => 'Publicación actualizada']);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo actualizar la publicación']);
        }
    } else {
        echo json_encode(['error' => 'Faltan datos para actualizar la publicación']);
    }
}
?>
