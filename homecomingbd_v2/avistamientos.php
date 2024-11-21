<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');


include 'config.php';

if ($conexion->connect_error) {
    echo json_encode(array('error' => 'Error de conexión: ' . $conexion->connect_error));
    exit();
}

// Obtener el ID del usuario actual (asumiendo que tienes un sistema de autenticación)
$usuario_id = $_POST['usuario_id'] ?? null; // Ajusta según el nombre enviado desde Flutter

if (!$usuario_id) {
    echo json_encode(array('status' => 'error', 'message' => 'Usuario no identificado'));
    exit();
}

// Obtener datos del POST
$mascota_id = $_POST['id_mascota'];
$latitud = $_POST['latitud'];
$longitud = $_POST['longitud'];
$detalles = $_POST['detalles'];

// Modificar la consulta SQL para incluir usuario_avistamiento
$sql = "INSERT INTO avistamientos (id_mascota, latitud, longitud, detalles, usuario_avistamiento) 
        VALUES (?, ?, ?, ?, ?)";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("dddsi", $mascota_id, $latitud, $longitud, $detalles, $usuario_id);

if ($stmt->execute()) {
    echo json_encode(array('status' => 'success', 'message' => 'Avistamiento guardado correctamente'));
} else {
    echo json_encode(array('status' => 'error', 'message' => 'Error al guardar el avistamiento: ' . $stmt->error));
}

$stmt->close();
$conexion->close();
?>