<?php
// Importar las clases de PHPMailer en el espacio de nombres global
// Estas deben estar en la parte superior de tu script, no dentro de una función
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

// Cargar el autoloader de Composer
require 'autoload.php';

// Crear una instancia; pasar `true` habilita las excepciones
$mail = new PHPMailer(true);

try {
    // Configuración del servidor 
    $mail->SMTPDebug = 2;                      // Habilitar salida de depuración detallada
    $mail->isSMTP();                                            // Enviar usando SMTP
    $mail->Host       = 'smtp.gmail.com';                     // Establecer el servidor SMTP para enviar a través de
    $mail->SMTPAuth   = true;                                   // Habilitar autenticación SMTP
    $mail->Username   = 'apaza.reychman.124@gmail.com';                     // Nombre de usuario SMTP
    $mail->Password   = 'nexx ryea kwvj mmzu';                               // Contraseña SMTP
    $mail->SMTPSecure = 'tls';            // Habilitar cifrado TLS implícito
    $mail->Port       = 587;                                    // Puerto TCP para conectarse; usar 587 si has establecido `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS`

    // Destinatarios
    $mail->setFrom('apaza.reychman.124@gmail.com', 'Homecoming');               // Establecer remitente
    $mail->addAddress('reychman@gmail.com', 'Reychman Apaza');           // Añadir un destinatario

    // Contenido
    $mail->isHTML(true);                                        // Establecer formato de correo a HTML
    $mail->Subject = 'Restablecer Contraseña';       

    $file = fopen("bodyemail.html","r");             // Asunto del correo
    $str = fread($file, filesize("bodyemail.html"));
    $str=trim($str);
    fclose($file);

    $mail->Body    = $str; // Cuerpo del mensaje en HTML

    $mail->send();
    echo 'Mensaje enviado correctamente';                               // Mensaje enviado
} catch (Exception $e) {
    echo "Mensaje no enviado. Mailer Error: {$mail->ErrorInfo}"; // Mensaje no se pudo enviar. Error de PHPMailer
}
?>