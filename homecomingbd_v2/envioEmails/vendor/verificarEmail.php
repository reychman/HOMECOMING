<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

require 'autoload.php';
require '../../config.php';

// Mostrar errores de PHP
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$response = [];

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Obtener el parámetro de la solicitud POST
        if (isset($_POST['email'])) {
            $email = $_POST['email'];

            // Verificar si el email existe en la base de datos
            $consulta = $conexion->prepare("SELECT id, estado FROM usuarios WHERE email = ?");
            if (!$consulta) {
                throw new Exception("Error en la preparación del statement: " . $conexion->error);
            }
            $consulta->bind_param("s", $email);
            $consulta->execute();
            $consulta->store_result();

            if ($consulta->num_rows > 0) {
                $consulta->bind_result($id, $estado);
                $consulta->fetch();

                // Verificar si el estado es 0 (inactivo)
                if ($estado == 0) {
                    // Actualizar el estado a 1 (activo)
                    $actualizar = $conexion->prepare("UPDATE usuarios SET estado = 1 WHERE email = ?");
                    if (!$actualizar) {
                        throw new Exception("Error en la preparación del statement: " . $conexion->error);
                    }
                    $actualizar->bind_param("s", $email);
                    $actualizar->execute();

                    if ($actualizar->affected_rows > 0) {
                        $response['success'] = "La cuenta ha sido activada exitosamente. Puedes iniciar sesión.";
                    } else {
                        $response['error'] = "No se pudo activar la cuenta. Por favor, intenta nuevamente.";
                    }
                } else {
                    $response['info'] = "La cuenta ya está activa o el enlace ha expirado.";
                }
            } else {
                $response['error'] = "Correo electrónico no encontrado.";
            }

            $consulta->close();
            $conexion->close();
        } else {
            throw new Exception("Parámetro de email no encontrado.");
        }
    } else {
        throw new Exception("Método no permitido.");
    }
} catch (Exception $e) {
    $response['error'] = $e->getMessage();
}

echo json_encode($response);
?>
