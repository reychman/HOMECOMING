<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

require_once('config.php');

$input = json_decode(file_get_contents('php://input'), true);

if (isset($input['nombre']) && isset($input['contrasena'])) {
    $nombre = $input['nombre'];
    $contrasena = $input['contrasena'];

    error_log("Nombre recibido: $nombre");
    error_log("Contraseña recibida: $contrasena");

    $query = "SELECT * FROM usuarios WHERE nombre = ? AND contrasena = ?";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param('ss', $nombre, $contrasena);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        echo json_encode($user);
    } else {
        echo json_encode(['error' => 'Nombre de usuario o contraseña incorrectos.']);
    }
} else {
    echo json_encode(['error' => 'Datos incompletos.']);
}
?>
