<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

require_once('config.php');

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['contrasena']) && (isset($data['nombre']) || isset($data['email']))) {
    $contrasena = $data['contrasena'];
    $nombre = isset($data['nombre']) ? $data['nombre'] : null;
    $email = isset($data['email']) ? $data['email'] : null;

    $sql = "SELECT id, nombre, primerApellido, segundoApellido, telefono, contrasena, email, tipo_usuario, foto_portada FROM usuarios WHERE nombre = ? OR email = ?";
    if ($stmt = $conexion->prepare($sql)) {
        $stmt->bind_param("ss", $nombre, $email);
        $stmt->execute();
        $resultado = $stmt->get_result();

        if ($resultado->num_rows > 0) {
            $usuario = $resultado->fetch_assoc();
            $hashedPassword = $usuario['contrasena'];

            if ($hashedPassword === $contrasena) {
                $response = array(
                    'id' => $usuario['id'],
                    'nombre' => $usuario['nombre'],
                    'primerApellido' => $usuario['primerApellido'] ?? "",
                    'segundoApellido' => $usuario['segundoApellido'] ?? "",
                    'telefono' => $usuario['telefono'] ?? "",
                    'email' => $usuario['email'],
                    'tipo_usuario' => $usuario['tipo_usuario'],
                    'foto_portada' => $usuario['foto_portada'] ?? "",
                );
                echo json_encode($response);
            } else {
                $response = array('error' => 'Contraseña incorrecta');
                echo json_encode($response);
            }
        } else {
            $response = array('error' => 'Nombre de usuario o email no encontrado');
            echo json_encode($response);
        }

        $stmt->close();
    }
} else {
    $response = array('error' => 'Datos incompletos');
    echo json_encode($response);
}

$conexion->close();
?>
