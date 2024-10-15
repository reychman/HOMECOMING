<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once('config.php');

$tipo = isset($_GET['tipo']) ? $_GET['tipo'] : '';

switch ($tipo) {
    case 'propietario':
    case 'administrador':
        $sql = "SELECT id, nombre, primerApellido, segundoApellido, telefono, email, tipo_usuario, estado 
                FROM usuarios 
                WHERE tipo_usuario = ? AND estado = 1";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("s", $tipo);
        break;
    case 'refugio':
        $sql = "SELECT id, nombre, primerApellido, segundoApellido, telefono, email, tipo_usuario, 
                        nombreRefugio, emailRefugio, ubicacionRefugio, telefonoRefugio, estado 
                FROM usuarios 
                WHERE tipo_usuario = 'refugio'";
        $stmt = $conexion->prepare($sql);
        break;
    default:
        echo json_encode(["error" => "Tipo de usuario no válido"]);
        exit();
}

$stmt->execute();
$result = $stmt->get_result();

$usuarios = [];
while ($row = $result->fetch_assoc()) {
    $usuarios[] = $row;
}

echo json_encode($usuarios);

$stmt->close();
$conexion->close();
?>