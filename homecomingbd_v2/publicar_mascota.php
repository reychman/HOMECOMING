<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');
include 'config.php';

// Obtener datos del formulario
$nombre = $_POST['nombre'];
$especie = $_POST['especie'];
$raza = $_POST['raza'];
$sexo = $_POST['sexo'];
$fecha_perdida = $_POST['fecha_perdida'];
$lugar_perdida = $_POST['lugar_perdida'];
$descripcion = $_POST['descripcion'];
$foto = $_FILES['foto'];
$latitud = $_POST['latitud']; // Nuevo campo
$longitud = $_POST['longitud']; // Nuevo campo
$usuario_id = $_POST['usuario_id'];

// Procesar la imagen
if (isset($foto)) {
    $foto_nombre = $foto['name'];
    $foto_tmp = $foto['tmp_name'];
    $foto_error = $foto['error'];

    if ($foto_error === UPLOAD_ERR_OK) {
        // Obtener la extensión de la imagen
        $foto_extension = pathinfo($foto_nombre, PATHINFO_EXTENSION);
        
        // Generar el nuevo nombre de archivo basado en el nombre de la mascota, usuario_id, y extensión
        $nuevo_nombre_foto = $nombre . $usuario_id . '.' . $foto_extension;

        // Definir la ruta completa donde se moverá la imagen
        $ruta_foto = '../assets/imagenes/fotos_mascotas/' . $nuevo_nombre_foto;

        // Mover el archivo subido a la ubicación deseada
        if (!move_uploaded_file($foto_tmp, $ruta_foto)) {
            echo json_encode(['success' => false, 'message' => 'Error al mover el archivo de imagen']);
            exit();
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Error al subir la imagen']);
        exit();
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Imagen no proporcionada']);
    exit();
}

// Inserta la mascota en la base de datos con el nuevo nombre de la foto
$sql = "INSERT INTO mascotas (nombre, especie, raza, sexo, fecha_perdida, lugar_perdida, descripcion, foto, latitud, longitud, usuario_id) 
VALUES ('$nombre', '$especie', '$raza', '$sexo', '$fecha_perdida', '$lugar_perdida', '$descripcion', '$nuevo_nombre_foto', '$latitud', '$longitud', '$usuario_id')";

if ($conexion->query($sql) === TRUE) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => $conexion->error]);
}

$conexion->close();
?>
