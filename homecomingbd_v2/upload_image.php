<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

// Incluir configuración de la base de datos
require_once('config.php');

// Verificar si se ha subido una imagen
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['foto_portada']) && $_FILES['foto_portada']['error'] == 0) {
    $id = $_POST['id']; // ID del usuario

    // Usa una ruta absoluta para evitar problemas con las rutas relativas
    $target_dir = 'C:/Users/Cristopher/Desktop/Cristopher/proyecto HomeComing/homecoming/assets/imagenes/fotos_portada/';
    
    // Crear el directorio si no existe
    if (!is_dir($target_dir)) {
        mkdir($target_dir, 0777, true);
    }

    $target_file = $target_dir . basename($_FILES["foto_portada"]["name"]);
    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

    // Verificar el tipo de archivo (opcional)
    $allowed_types = ['jpg', 'jpeg', 'png', 'gif'];
    if (!in_array($imageFileType, $allowed_types)) {
        echo json_encode(array('error' => 'Tipo de archivo no permitido.'));
        exit();
    }
    // Mover el archivo subido al directorio
    if (move_uploaded_file($_FILES["foto_portada"]["tmp_name"], $target_file)) {
        // Crear la URL completa de la imagen
        $url_imagen = "http://192.168.100.102/assets/imagenes/fotos_portada/" . basename($_FILES["foto_portada"]["name"]); // Cambia "192.168.1.100" por tu IP o dominio

        // Actualizar la URL de la imagen en la base de datos
        $sql = "UPDATE Usuarios SET foto_portada=? WHERE id=?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("si", $url_imagen, $id);

        if ($stmt->execute()) {
            echo json_encode(array('success' => 'Imagen subida y URL actualizada.', 'foto_portada' => $url_imagen));
        } else {
            echo json_encode(array('error' => 'Error al actualizar la URL en la base de datos.'));
        }

        $stmt->close();
    } else {
        echo json_encode(array('error' => 'Error al mover la imagen. Verifica permisos y ruta.'));
    }
} else {
    echo json_encode(array('error' => 'No se ha subido ninguna imagen.'));
}

$conexion->close();
?>
