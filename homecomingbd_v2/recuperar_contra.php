<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

include 'config.php'; // Asegúrate de incluir tu archivo de conexión a la base de datos

// Mostrar errores de PHP
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $correo = $_POST['email'];

    // Verifica si el correo existe en la base de datos
    $consulta = $conexion->prepare("SELECT id FROM usuarios WHERE email = ?");
    if (!$consulta) {
        echo json_encode(["error" => "Error en la preparación del statement: " . $conexion->error]);
        exit();
    }
    $consulta->bind_param("s", $correo);
    $consulta->execute();
    $consulta->store_result();

    if ($consulta->num_rows > 0) {
        // Genera una nueva contraseña aleatoria
        $nueva_contrasena = bin2hex(random_bytes(4)); // Genera una contraseña de 8 caracteres
        $nueva_contrasena_hash = sha1($nueva_contrasena);

        // Actualiza la contraseña en la base de datos
        $consulta->close();
        $consulta = $conexion->prepare("UPDATE usuarios SET contrasena = ? WHERE email = ?");
        if (!$consulta) {
            echo json_encode(["error" => "Error en la preparación del statement: " . $conexion->error]);
            exit();
        }
        $consulta->bind_param("ss", $nueva_contrasena_hash, $correo);
        if ($consulta->execute()) {
            // Envía el correo electrónico al usuario
            $asunto = "Recuperación de contraseña - Homecoming";
            $mensaje = "Su nueva contraseña es: $nueva_contrasena";
            $encabezados = "From: soporte@tu-dominio.com\r\n";
            $encabezados .= "Reply-To: soporte@tu-dominio.com\r\n";
            $encabezados .= "X-Mailer: PHP/" . phpversion();

            if (mail($correo, $asunto, $mensaje, $encabezados)) {
                echo json_encode(["success" => "Correo enviado"]);
            } else {
                echo json_encode(["error" => "No se pudo enviar el correo"]);
            }
        } else {
            echo json_encode(["error" => "No se pudo actualizar la contraseña: " . $consulta->error]);
        }
    } else {
        echo json_encode(["error" => "Correo no encontrado"]);
    }

    $consulta->close();
    $conexion->close();
} else {
    echo json_encode(["error" => "Método no permitido"]);
}
?>
