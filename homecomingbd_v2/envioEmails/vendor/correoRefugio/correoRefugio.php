<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require '../autoload.php';  // Confirma que la ruta a autoload.php es correcta
require '../../../config.php';

// Mostrar errores de PHP
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];
    $serverIP = $_POST['serverIP'];
    $esAprobado = filter_var($_POST['esAprobado'] ?? 'false', FILTER_VALIDATE_BOOLEAN);
    
    $mail = new PHPMailer(true);
    try {
        // Configuración del servidor
        $mail->isSMTP();
        $mail->Host       = 'smtp.gmail.com';
        $mail->SMTPAuth   = true;
        $mail->Username   = 'apaza.reychman.124@gmail.com';
        $mail->Password   = 'nexx ryea kwvj mmzu';  // Asegúrate de usar credenciales seguras
        $mail->SMTPSecure = 'tls';
        $mail->Port       = 587;
        $mail->CharSet = 'UTF-8';
        // Configuración del correo
        $mail->setFrom('apaza.reychman.124@gmail.com', 'Homecoming');
        $mail->addAddress($email);

        if ($esAprobado) {
            // Correo de aprobación
            $mail->isHTML(true);
            $mail->Subject = '¡Bienvenido a Homecoming! Tu cuenta ha sido aprobada';
            $mail->Body = <<<HTML
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; }
                    .container { padding: 20px; }
                    .header { color: #2e7d32; font-size: 24px; }
                    .content { margin: 20px 0; }
                    .button {
                        background-color: #4CAF50;
                        color: white;
                        padding: 10px 20px;
                        text-decoration: none;
                        border-radius: 5px;
                        display: inline-block;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1 class="header">¡Felicitaciones!</h1>
                    <div class="content">
                        <p>Nos complace informarte que tu cuenta de refugio ha sido aprobada en Homecoming.</p>
                        <p>Ya puedes acceder al sistema y comenzar a gestionar tu refugio.</p>
                        <p>Ingresa con tu correo electrónico y contraseña registrados.</p>
                    </div>
                    <a href="http://localhost:63178/#/iniciar_sesion" class="button">Iniciar sesión</a>
                    <div class="content">
                        <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>
                        <p>¡Bienvenido a la familia Homecoming!</p>
                    </div>
                </div>
            </body>
            </html>
            HTML;
        } else {
            // Correo de rechazo
            $mail->isHTML(true);
            $mail->Subject = 'Actualización sobre tu solicitud de cuenta en Homecoming';
            $mail->Body = <<<HTML
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; }
                    .container { padding: 20px; }
                    .header { color: #d32f2f; font-size: 24px; }
                    .content { margin: 20px 0; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1 class="header">Actualización de solicitud</h1>
                    <div class="content">
                        <p>Gracias por tu interés en formar parte de Homecoming.</p>
                        <p>Lamentamos informarte que tu solicitud de cuenta de refugio no ha sido aprobada en esta ocasión.</p>
                        <p>Esto puede deberse a:</p>
                        <ul>
                            <li>Información incompleta o incorrecta en el registro</li>
                            <li>Falsedad en la solicitud</li>
                            <li>Cuestionamiento de la identidad</li>
                        </ul>
                        <p>Te invitamos a revisar los requisitos y volver a intentarlo.</p>
                        <p>Si tienes alguna pregunta, no dudes en contactarnos para obtener más información.</p>
                    </div>
                </div>
            </body>
            </html>
            HTML;
        }
        $mail->send();
        http_response_code(200);
        echo json_encode(['success' => true, 'message' => 'Correo enviado exitosamente']);
        
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => "Error al enviar el correo: {$mail->ErrorInfo}"]);
    }
} else {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
}