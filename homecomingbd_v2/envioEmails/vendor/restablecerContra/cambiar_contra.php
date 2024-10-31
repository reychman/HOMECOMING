<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

require '../../../config.php';

$response = [];

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $email = $_POST['email'];
        $nuevaContrasena = $_POST['nuevaContrasena'];

        // Verificar si el email existe
        $consulta = $conexion->prepare("SELECT id FROM usuarios WHERE email = ?");
        $consulta->bind_param("s", $email);
        $consulta->execute();
        $consulta->store_result();

        if ($consulta->num_rows > 0) {
            // Encriptar la contraseña con SHA-1
            $hash = sha1($nuevaContrasena);
            
            $updateQuery = $conexion->prepare("UPDATE usuarios SET contrasena = ? WHERE email = ?");
            $updateQuery->bind_param("ss", $hash, $email);
            
            if ($updateQuery->execute()) {
                $response['success'] = true;
                $response['message'] = 'Contraseña actualizada correctamente';
            } else {
                throw new Exception("Error al actualizar la contraseña");
            }
        } else {
            throw new Exception("Correo electrónico no encontrado");
        }
    } else {
        throw new Exception("Método no permitido");
    }
} catch (Exception $e) {
    $response['success'] = false;
    $response['error'] = $e->getMessage();
}

echo json_encode($response);
?>
