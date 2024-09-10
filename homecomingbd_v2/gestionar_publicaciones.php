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
    global $conexion; 

    $usuario_id = isset($_POST['usuario_id']) ? $_POST['usuario_id'] : null;
    error_log("Usuario ID recibido: " . $usuario_id);
    
    if (!$usuario_id) {
        echo json_encode(['error' => 'Falta el usuario_id']);
        exit;
    }

    $sql = "SELECT M.id, M.nombre, M.especie, M.raza, M.sexo, M.fecha_perdida, M.lugar_perdida, 
                    M.estado, M.descripcion, M.foto, M.latitud, M.longitud, 
                    U.nombre AS nombre_dueno, U.email AS email_dueno, U.telefono AS telefono_dueno
            FROM mascotas M
            JOIN usuarios U ON M.usuario_id = U.id
            WHERE M.usuario_id = ? AND M.estado_registro = 1";  
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
                'latitud' => $row['latitud'],  // Incluir latitud
                'longitud' => $row['longitud'], // Incluir longitud
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
    error_log("ID recibido: " . $id);
    error_log("Estado recibido: " . $nuevoEstado);

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

    // Recuperar el id de la publicación
    $id = isset($_POST['id']) ? $_POST['id'] : null;

    // Verificar si el id es nulo
    if (!$id) {
        echo json_encode(['error' => 'Falta el id de la publicación']);
        return;
    }

    // Registrar el id recibido para eliminar
    error_log("Eliminando publicación con ID: " . $id);

    // Preparar la consulta para eliminar la publicación lógicamente
    $sql = "UPDATE mascotas SET estado_registro = 0 WHERE id = ?";
    $stmt = $conexion->prepare($sql);
    
    if ($stmt === false) {
        echo json_encode(['error' => 'Error preparando la consulta']);
        error_log("Error preparando la consulta SQL: " . $conexion->error);
        return;
    }

    // Asignar el parámetro y ejecutar la consulta
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Publicación eliminada']);
    } else {
        echo json_encode(['success' => false, 'error' => 'No se pudo eliminar la publicación']);
        error_log("Error al ejecutar la consulta SQL: " . $stmt->error);
    }
}

function actualizarPublicacion() {
    global $conexion;

    $id = isset($_POST['id']) ? $_POST['id'] : null;  // Recupera el ID de la publicación
    $nombre = isset($_POST['nombre']) ? $_POST['nombre'] : null;
    $especie = isset($_POST['especie']) ? $_POST['especie'] : null;
    $raza = isset($_POST['raza']) ? $_POST['raza'] : null;
    $sexo = isset($_POST['sexo']) ? $_POST['sexo'] : null;
    $fecha_perdida = isset($_POST['fecha_perdida']) ? $_POST['fecha_perdida'] : null;
    $lugar_perdida = isset($_POST['lugar_perdida']) ? $_POST['lugar_perdida'] : null;
    $descripcion = isset($_POST['descripcion']) ? $_POST['descripcion'] : null;
    $latitud = isset($_POST['latitud']) ? $_POST['latitud'] : null;
    $longitud = isset($_POST['longitud']) ? $_POST['longitud'] : null;

    if ($id && $nombre && $especie && $raza && $sexo && $fecha_perdida && $lugar_perdida && $descripcion && $latitud && $longitud) {
        $sql = "UPDATE mascotas SET 
                    nombre = ?, 
                    especie = ?, 
                    raza = ?, 
                    sexo = ?, 
                    fecha_perdida = ?, 
                    lugar_perdida = ?, 
                    descripcion = ?, 
                    latitud = ?, 
                    longitud = ?
                WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("sssssssddi", $nombre, $especie, $raza, $sexo, $fecha_perdida, $lugar_perdida, $descripcion, $latitud, $longitud, $id);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Publicación actualizada']);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo actualizar la publicacion']);
        }
    } else {
        echo json_encode(['error' => 'Faltan datos para actualizar la publicacion']);
    }
}


?>
