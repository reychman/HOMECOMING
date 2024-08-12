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

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'] ?? '';
    $nombre = $_POST['nombre'] ?? '';
    $primerApellido = $_POST['primerApellido'] ?? '';
    $segundoApellido = $_POST['segundoApellido'] ?? '';
    $telefono = $_POST['telefono'] ?? '';
    $email = $_POST['email'] ?? '';
    $tipo_usuario = isset($_POST['tipo_usuario']) ? $_POST['tipo_usuario'] : null;
}

if (!is_null($tipo_usuario) && !empty($tipo_usuario)) {
    $resultado = actualizarUsuario($conexion, $id, $nombre, $primerApellido, $segundoApellido, $telefono, $email, $tipo_usuario);
} else {
    $resultado = actualizarPerfil($conexion, $id, $nombre, $primerApellido, $segundoApellido, $telefono, $email);
}

echo json_encode($resultado);
?>
