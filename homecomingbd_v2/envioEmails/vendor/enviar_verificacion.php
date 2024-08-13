<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'autoload.php';
require '../../config.php';

// Mostrar errores de PHP
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$response = [];

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $email = $_POST['email'];
        echo $email;
        // Verifica si el email existe en la base de datos
        $consulta = $conexion->prepare("SELECT id FROM usuarios WHERE email = ?");
        if (!$consulta) {
            throw new Exception("Error en la preparación del statement: " . $conexion->error);
        }
        $consulta->bind_param("s", $email);
        $consulta->execute();
        $consulta->store_result();

        if ($consulta->num_rows > 0) {
            // Enviar email con PHPMailer
            $mail = new PHPMailer(true);
            try {
                $mail->isSMTP();
                $mail->Host       = 'smtp.gmail.com';
                $mail->SMTPAuth   = true;
                $mail->Username   = 'apaza.reychman.124@gmail.com';
                $mail->Password   = 'nexx ryea kwvj mmzu';
                $mail->SMTPSecure = 'tls';
                $mail->Port       = 587;

                $mail->setFrom('apaza.reychman.124@gmail.com', 'Homecoming');
                $mail->addAddress($email);

                $mail->isHTML(true);
                $mail->Subject = 'Verificacion Email';

                $file = fopen("bodyVerificacion.html", "r");
                if ($file) {
                    $str = fread($file, filesize("bodyVerificacion.html"));
                    fclose($file);

                    $str = str_replace("{email}", $email, $str);
                    $mail->Body = $str;

                    $mail->send();
                    $response['success'] = "correo enviado";
                } else {
                    throw new Exception("No se pudo abrir el archivo HTML");
                }
            } catch (Exception $e) {
                throw new Exception("No se pudo enviar el correo. Error de PHPMailer: {$mail->ErrorInfo}");
            }
        } else {
            throw new Exception("correo no encontrado");
        }

        $consulta->close();
        $conexion->close();
    } else {
        throw new Exception("Método no permitido");
    }
} catch (Exception $e) {
    $response['error'] = $e->getMessage();
}

echo json_encode($response);
?>
