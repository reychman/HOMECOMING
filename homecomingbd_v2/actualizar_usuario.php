<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

require_once('config.php');

function actualizarUsuario($conexion, $id, $nombre, $primerApellido, $segundoApellido, $telefono, $email, $tipo_usuario) {
    if (empty($id) || empty($nombre) || empty($primerApellido) || empty($telefono) || empty($email) || empty($tipo_usuario)) {
        return array('error' => 'Todos los campos son obligatorios');
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return array('error' => 'El formato del email no es válido.');
    }

    $sql = "UPDATE Usuarios SET nombre=?, primerApellido=?, segundoApellido=?, telefono=?, email=?, tipo_usuario=?, fecha_modificacion=NOW() WHERE id=?";
    $stmt = $conexion->prepare($sql);

    if (!$stmt) {
        return array('error' => 'Error en la preparación de la consulta de actualización: ' . $conexion->error);
    }

    $stmt->bind_param("ssssssi", $nombre, $primerApellido, $segundoApellido, $telefono, $email, $tipo_usuario, $id);

    if ($stmt->execute()) {
        return array('success' => 'Usuario actualizado exitosamente');
    } else {
        return array('error' => 'Error al actualizar el usuario: ' . $stmt->error);
    }
}

function actualizarPerfil($conexion, $id, $nombre, $primerApellido, $segundoApellido, $telefono, $email) {
    if (empty($id) || empty($nombre) || empty($primerApellido) || empty($telefono) || empty($email)) {
        return array('error' => 'Todos los campos del perfil son obligatorios');
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return array('error' => 'El formato del email no es válido.');
    }

    $sql = "UPDATE Usuarios SET nombre=?, primerApellido=?, segundoApellido=?, telefono=?, email=?, fecha_modificacion=NOW() WHERE id=?";
    $stmt = $conexion->prepare($sql);

    if (!$stmt) {
        return array('error' => 'Error en la preparación de la consulta de actualización: ' . $conexion->error);
    }

    $stmt->bind_param("sssssi", $nombre, $primerApellido, $segundoApellido, $telefono, $email, $id);

    if ($stmt->execute()) {
        return array('success' => 'Perfil actualizado exitosamente');
    } else {
        return array('error' => 'Error al actualizar el perfil: ' . $stmt->error);
    }
}

function actualizarRefugio($conexion, $id, $nombre_refugio, $email_refugio, $ubicacion_refugio, $telefono_refugio) {
    if (empty($id) || empty($nombre_refugio) || empty($email_refugio) || empty($telefono_refugio) || empty($ubicacion_refugio)) {
        return array('error' => 'Todos los campos son obligatorios');
    }
    if (!filter_var($email_refugio, FILTER_VALIDATE_EMAIL)) {
        return array('error' => 'El formato del email no es válido.');
    }

    $sql = "UPDATE Usuarios SET nombre_refugio=?, email_refugio=?, ubicacion_refugio=?, telefono_refugio=?, fecha_modificacion=NOW() WHERE id=?";
    $stmt = $conexion->prepare($sql);

    if (!$stmt) {
        return array('error' => 'Error en la preparación de la consulta de actualización: ' . $conexion->error);
    }

    $stmt->bind_param("ssssi", $nombre_refugio, $email_refugio, $ubicacion_refugio, $telefono_refugio, $id);

    if ($stmt->execute()) {
        return array('success' => 'Datos de refugio actualizados exitosamente');
    } else {
        return array('error' => 'Error al actualizar los datos del refugio: ' . $stmt->error);
    }
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'] ?? '';
    $nombre = $_POST['nombre'] ?? '';
    $primerApellido = $_POST['primerApellido'] ?? '';
    $segundoApellido = $_POST['segundoApellido'] ?? '';
    $telefono = $_POST['telefono'] ?? '';
    $email = $_POST['email'] ?? '';
    $tipo_usuario = isset($_POST['tipo_usuario']) ? $_POST['tipo_usuario'] : null;

    // Campos de refugio
    $nombre_refugio = $_POST['nombre_refugio'] ?? '';
    $email_refugio = $_POST['email_refugio'] ?? '';
    $ubicacion_refugio = $_POST['ubicacion_refugio'] ?? '';
    $telefono_refugio = $_POST['telefono_refugio'] ?? '';
}

if (!is_null($tipo_usuario) && !empty($tipo_usuario)) {
    if ($tipo_usuario === 'refugio') {
        $resultado = actualizarRefugio($conexion, $id, $nombre_refugio, $email_refugio, $ubicacion_refugio, $telefono_refugio);
    } else {
        $resultado = actualizarUsuario($conexion, $id, $nombre, $primerApellido, $segundoApellido, $telefono, $email, $tipo_usuario);
    }
} else {
    $resultado = actualizarPerfil($conexion, $id, $nombre, $primerApellido, $segundoApellido, $telefono, $email);
}

echo json_encode($resultado);
?>

