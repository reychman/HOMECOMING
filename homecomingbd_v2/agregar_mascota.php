<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');
header("Content-Type: application/json");

require_once('config.php'); 

// Obtener los datos enviados
$nombre = $_POST['nombre'];
$especie = $_POST['especie'];
$raza = $_POST['raza'];
$sexo = $_POST['sexo'];
$fecha_perdida = $_POST['fecha_perdida'];
$lugar_perdida = $_POST['lugar_perdida'];
$descripcion = $_POST['descripcion'];
$usuario_id = $_POST['usuario_id'];

// Validar que todos los campos estén presentes
if (empty($nombre) || empty($especie) || empty($raza) || empty($sexo) || empty($fecha_perdida) || empty($lugar_perdida) || empty($descripcion) || empty($usuario_id)) {
    echo json_encode(['success' => false, 'message' => 'Todos los campos son obligatorios']);
    exit();
}

// Procesar la imagen
if (isset($_FILES['foto']['name'])) {
    $target_dir = "homecoming/assets/imagenes/fotos_mascotas/"; // Asegúrate de que esta ruta sea correcta

    // Renombrar la imagen usando especie y usuario_id
    $imageFileType = strtolower(pathinfo($_FILES['foto']['name'], PATHINFO_EXTENSION));
    $new_image_name = $especie . $usuario_id . '.' . $imageFileType;
    $target_file = $target_dir . $new_image_name;

    $valid_extensions = array("jpg", "jpeg", "png", "gif");

    // Verificar si el archivo es una imagen válida
    $check = getimagesize($_FILES['foto']['tmp_name']);
    if ($check !== false) {
        // Verificar el tamaño del archivo (límite de 5 MB)
        if ($_FILES['foto']['size'] <= 5000000) { // 5000000 bytes = 5MB
            // Permitir solo ciertos formatos de archivo
            if (in_array($imageFileType, $valid_extensions)) {
                if (move_uploaded_file($_FILES['foto']['tmp_name'], $target_file)) {
                    // El archivo se cargó correctamente, ahora guarda la información en la base de datos
                    $foto = $new_image_name;

                    // Preparar la consulta SQL
                    $stmt = $conexion->prepare("INSERT INTO mascotas (nombre, especie, raza, sexo, fecha_perdida, lugar_perdida, descripcion, foto, usuario_id, fecha_creacion) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())");
                    $stmt->bind_param('sssssssss', $nombre, $especie, $raza, $sexo, $fecha_perdida, $lugar_perdida, $descripcion, $foto, $usuario_id);

                    // Ejecutar la consulta
                    if ($stmt->execute()) {
                        echo json_encode(['success' => true, 'message' => 'Mascota registrada con éxito']);
                    } else {
                        echo json_encode(['success' => false, 'message' => 'Error al registrar la mascota: ' . $stmt->error]);
                    }

                    $stmt->close();
                } else {
                    echo json_encode(['success' => false, 'message' => "Hubo un error al cargar el archivo."]);
                }
            } else {
                echo json_encode(['success' => false, 'message' => "Sólo se permiten archivos JPG, JPEG, PNG y GIF."]);
            }
        } else {
            echo json_encode(['success' => false, 'message' => "El archivo es demasiado grande."]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => "El archivo no es una imagen."]);
    }
} else {
    echo json_encode(['success' => false, 'message' => "Ningún archivo fue subido."]);
}

$conexion->close();
?>
