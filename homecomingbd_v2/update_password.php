<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

include 'config.php'; // Incluye el archivo de configuración de la base de datos

try {
    // Verificar si se han recibido los datos necesarios
    if (!isset($_POST['id']) || !isset($_POST['new_password'])) {
        echo json_encode(['success' => false, 'message' => 'Datos no proporcionados']);
        exit();
    }

    $id = $_POST['id'];
    $new_password = $_POST['new_password'];

    // Validación básica de entrada
    if (empty($id) || empty($new_password)) {
        echo json_encode(['success' => false, 'message' => 'ID de usuario o contraseña vacíos']);
        exit();
    }

    // Hash de la nueva contraseña usando SHA-1
    $hashed_password = sha1($new_password);

    // Preparar la consulta SQL para actualizar la contraseña
    $sql = "UPDATE usuarios SET contrasena = ?, fecha_modificacion = NOW() WHERE id = ?";

    // Utilizar consultas preparadas para evitar inyecciones SQL
    if ($stmt = $conexion->prepare($sql)) {
        $stmt->bind_param('si', $hashed_password, $id);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Contraseña actualizada correctamente']);
        } else {
            // Agregar más detalles sobre el error específico
            echo json_encode(['success' => false, 'message' => 'Error al ejecutar la consulta: ' . $stmt->error]);
        }

        $stmt->close();
    } else {
        // Agregar más detalles sobre el error específico
        echo json_encode(['success' => false, 'message' => 'Error en la preparación de la consulta: ' . $conexion->error]);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Excepción capturada: ' . $e->getMessage()]);
}

$conexion->close();
?>
