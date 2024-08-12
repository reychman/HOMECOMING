<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
require 'config.php'; // Asegúrate de que config.php esté en la misma carpeta o ajusta la ruta

session_start();

// Verificar si el usuario está autenticado
$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(["error" => "User ID is required"]);
    exit();
}

// Obtener los datos del usuario desde la base de datos
$sql = "SELECT id, nombre, primerApellido, segundoApellido, telefono, email, tipo_usuario, foto_portada, estado FROM usuarios WHERE id = ?";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user_data = $result->fetch_assoc();
    echo json_encode($user_data);
} else {
    echo json_encode(["error" => "Usuario no encontrado"]);
}

$stmt->close();
$conexion->close();
?>
