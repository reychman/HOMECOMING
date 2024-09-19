<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');
include 'config.php';

// Iniciar la transacción
$conexion->begin_transaction();

try {
    // Obtener datos del formulario
    $nombre = $_POST['nombre'];
    $especie = $_POST['especie'];
    $raza = $_POST['raza'];
    $sexo = $_POST['sexo'];
    $fecha_perdida = $_POST['fecha_perdida'];
    $lugar_perdida = $_POST['lugar_perdida'];
    $descripcion = $_POST['descripcion'];
    $latitud = $_POST['latitud'];
    $longitud = $_POST['longitud'];
    $usuario_id = $_POST['usuario_id'];

    // Insertar mascota en la tabla "mascotas"
    $sql_mascota = "INSERT INTO mascotas (nombre, especie, raza, sexo, fecha_perdida, lugar_perdida, descripcion, latitud, longitud, usuario_id) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt_mascota = $conexion->prepare($sql_mascota);
    $stmt_mascota->bind_param('ssssssssdi', $nombre, $especie, $raza, $sexo, $fecha_perdida, $lugar_perdida, $descripcion, $latitud, $longitud, $usuario_id);

    if (!$stmt_mascota->execute()) {
        throw new Exception("Error al insertar la mascota: " . $stmt_mascota->error);
    }

    // Obtener el ID de la mascota recién insertada
    $mascota_id = $conexion->insert_id;

    // Procesar y guardar las imágenes
    foreach ($_FILES['fotos']['tmp_name'] as $index => $tmpName) {
        $foto_name = $_FILES['fotos']['name'][$index];
        $foto_extension = pathinfo($foto_name, PATHINFO_EXTENSION);

        // Insertar una fila en la tabla fotos_mascotas para obtener el ID
        $sql_foto = "INSERT INTO fotos_mascotas (mascota_id, foto) VALUES (?, '')";
        $stmt_foto = $conexion->prepare($sql_foto);
        $stmt_foto->bind_param('i', $mascota_id);

        if (!$stmt_foto->execute()) {
            throw new Exception("Error al insertar la foto: " . $stmt_foto->error);
        }

        // Obtener el ID de la foto recién insertada
        $foto_id = $conexion->insert_id;

        // Generar el nombre de la imagen usando el ID de la foto, nombre de la mascota, y usuario_id
        $nuevo_nombre_foto = $foto_id . $nombre . $usuario_id . '.' . $foto_extension;
        $ruta_foto = '../assets/imagenes/fotos_mascotas/' . $nuevo_nombre_foto;

        // Mover el archivo subido a la ubicación deseada
        if (!move_uploaded_file($tmpName, $ruta_foto)) {
            throw new Exception("Error al mover el archivo de imagen");
        }

        // Actualizar el nombre de la foto en la base de datos
        $sql_update_foto = "UPDATE fotos_mascotas SET foto = ? WHERE id = ?";
        $stmt_update_foto = $conexion->prepare($sql_update_foto);
        $stmt_update_foto->bind_param('si', $nuevo_nombre_foto, $foto_id);

        if (!$stmt_update_foto->execute()) {
            throw new Exception("Error al actualizar el nombre de la foto: " . $stmt_update_foto->error);
        }
    }

    // Si todo va bien, hacer commit
    $conexion->commit();
    echo json_encode(['success' => true]);

} catch (Exception $e) {
    // Si ocurre un error, hacer rollback
    $conexion->rollback();
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

$conexion->close();
?>
