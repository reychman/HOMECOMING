<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

$target_dir = "homecoming/assets/imagenes/fotos_mascotas/"; // Asegúrate de que esta ruta sea correcta
$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['foto']['name'])) {
        $target_file = $target_dir . basename($_FILES['foto']['name']);
        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
        $valid_extensions = array("jpg", "jpeg", "png", "gif");

        // Verificar si el archivo es una imagen válida
        $check = getimagesize($_FILES['foto']['tmp_name']);
        if ($check !== false) {
            // Verificar el tamaño del archivo (límite de 5 MB)
            if ($_FILES['foto']['size'] <= 5000000) { // 5000000 bytes = 5MB
                // Permitir solo ciertos formatos de archivo
                if (in_array($imageFileType, $valid_extensions)) {
                    if (move_uploaded_file($_FILES['foto']['tmp_name'], $target_file)) {
                        // El archivo se cargó correctamente
                        require_once('config.php'); // Asegúrate de que este archivo exista y tenga la configuración correcta

                        $file_name = basename($_FILES['foto']['name']);

                        // Inserta el nombre del archivo en la base de datos
                        $sql = "INSERT INTO mascotas (foto) VALUES ('$file_name')";

                        if ($conexion->query($sql) === TRUE) {
                            $response['success'] = true; // Cambiado para coincidir con el código Flutter
                            $response['file_name'] = $file_name; // Incluye el nombre del archivo en la respuesta
                        } else {
                            $response['success'] = false;
                            $response['message'] = "Error: " . $sql . "<br>" . $conexion->error;
                        }

                        $conexion->close();
                    } else {
                        $response['success'] = false;
                        $response['message'] = "Hubo un error al cargar el archivo.";
                    }
                } else {
                    $response['success'] = false;
                    $response['message'] = "Sólo se permiten archivos JPG, JPEG, PNG y GIF.";
                }
            } else {
                $response['success'] = false;
                $response['message'] = "El archivo es demasiado grande.";
            }
        } else {
            $response['success'] = false;
            $response['message'] = "El archivo no es una imagen.";
        }
    } else {
        $response['success'] = false;
        $response['message'] = "Ningún archivo fue subido.";
    }
} else {
    $response['success'] = false;
    $response['message'] = "Solicitud no válida.";
}

echo json_encode($response);
?>
