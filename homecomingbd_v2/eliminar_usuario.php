<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
require_once('config.php');

// Verificar si se recibe un ID válido por POST
if (!isset($_POST['id'])) {
  echo json_encode(['error' => 'No se proporcionó un ID de usuario válido']);
  exit;
}

// Obtener el ID del usuario desde POST
$id = intval($_POST['id']); // Convertir a entero para seguridad

// Consulta para actualizar el estado del usuario
$sql = "UPDATE Usuarios SET estado = 0 WHERE id = ?";

// Preparar la consulta
$stmt = $conexion->prepare($sql);

if ($stmt === false) {
  echo json_encode(['error' => 'Error al preparar la consulta']);
  exit;
}

// Enlazar parámetros
$stmt->bind_param('i', $id);

// Ejecutar la consulta
if ($stmt->execute()) {
  echo json_encode(['success' => 'Usuario eliminado correctamente']);
} else {
  echo json_encode(['error' => 'Error al eliminar usuario']);
}

// Cerrar declaración y conexión
$stmt->close();
$conexion->close();
?>
