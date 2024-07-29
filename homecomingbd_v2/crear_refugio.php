<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');

header('Content-Type: application/json');

// Incluir configuración de la base de datos
require_once('config.php');

// Verificar la conexión a la base de datos
if ($conexion->connect_error) {
    echo json_encode(array('error' => 'Error de conexión a la base de datos: ' . $conexion->connect_error));
    exit();
}

// Obtener los datos del POST
$nombre = $_POST['nombre'];
$ubicacion = $_POST['ubicacion'];
$telefono = $_POST['telefono'];
$usuario_id = $_POST['usuario_id'];

// Validar que los campos obligatorios no estén vacíos
if (empty($nombre) || empty($ubicacion) || empty($telefono) || empty($usuario_id)) {
    echo json_encode(array('error' => 'Todos los campos son obligatorios'));
    exit();
}

// Insertar los datos del refugio en la base de datos para su verificación
$sql = "INSERT INTO Refugio (nombre, ubicacion, telefono, usuario_id, fecha_solicitud) VALUES (?, ?, ?, ?, Now())";
$stmt = $conexion->prepare($sql);

if (!$stmt) {
    echo json_encode(array('error' => 'Error en la preparación de la consulta de inserción: ' . $conexion->error));
    exit();
}

$stmt->bind_param("sssi", $nombre, $ubicacion, $telefono, $usuario_id);

if ($stmt->execute()) {
    echo json_encode(array('success' => 'Datos enviados correctamente para su verificación'));
} else {
    echo json_encode(array('error' => 'Error al enviar los datos: ' . $stmt->error));
}

$stmt->close();
$conexion->close();
?>
