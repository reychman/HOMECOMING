<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');
header("Content-Type: application/json");

require_once('config.php'); 

// Obtener los datos enviados
$nombre = $_POST['nombre'];
$especie = $_POST['especie'];
$raza = $_POST['raza'];
$sexo = $_POST['sexo'];
$fecha_perdida = $_POST['fecha_perdida'];
$lugar_perdida = $_POST['lugar_perdida'];
$descripcion = $_POST['descripcion'];
$foto = $_POST['foto'];
$usuario_id = $_POST['usuario_id'];

// Validar que todos los campos estén presentes
if (empty($nombre) || empty($especie) || empty($raza) || empty($sexo) || empty($fecha_perdida) || empty($lugar_perdida) || empty($descripcion) || empty($foto) || empty($usuario_id)) {
    echo json_encode(['success' => false, 'message' => 'Todos los campos son obligatorios']);
    exit();
}

// Preparar la consulta SQL
$stmt = $conexion->prepare("INSERT INTO mascotas (nombre, especie, raza, sexo, fecha_perdida, lugar_perdida, descripcion, foto, usuario_id, fecha_creacion) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())");
$stmt->bind_param('sssssssss', $nombre, $especie, $raza, $sexo, $fecha_perdida, $lugar_perdida, $descripcion, $foto, $usuario_id);

// Ejecutar la consulta
if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Mascota registrada con éxito']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error al registrar la mascota: ' . $stmt->error]);
}

// Cerrar conexión
$stmt->close();
$conexion->close();
?>
