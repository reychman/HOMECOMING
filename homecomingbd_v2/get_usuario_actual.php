<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
require 'config.php';

// Obtener el método de la solicitud
$method = $_SERVER['REQUEST_METHOD'];

// Si es una solicitud OPTIONS, terminar aquí (para manejar preflight CORS)
if ($method === 'OPTIONS') {
    exit(0);
}

// Obtener el ID del usuario
$user_id = null;
if ($method === 'GET') {
    $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
} elseif ($method === 'POST') {
    $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : null;
}

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