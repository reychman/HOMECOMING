<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

require '../../../homecomingbd_v2/config.php';
//require '../../config.php';  // Asegúrate de que este archivo tenga la configuración correcta de conexión a tu base de datos

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $contrasena = $_POST['contrasena'];
    $confirmarContrasena = $_POST['confirmarContrasena'];
    $email = $_POST['email']; // Este campo debe ser enviado desde el formulario

    if ($contrasena === $confirmarContrasena) {
        $contrasenaEncriptada = sha1($contrasena);

        $query = "UPDATE usuarios SET contrasena = '$contrasenaEncriptada', fecha_modificacion=NOW() WHERE email = '$email'";
        if (mysqli_query($conexion, $query)) {
            echo json_encode(['success' => 'Contraseña actualizada exitosamente.']);
        } else {
            echo json_encode(['error' => 'Error al actualizar la contraseña.']);
        }
    } else {
        echo json_encode(['error' => 'Las contraseñas no coinciden.']);
    }
}
?>
