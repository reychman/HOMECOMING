<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization, X-Requested-With');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Verificar si el método es OPTIONS y detener la ejecución.
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // Responder a la solicitud preflight con un 200 OK
    http_response_code(200);
    exit();
}

require 'config.php'; // Asegúrate de que aquí tienes la configuración de tu base de datos correctamente.

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['accion']) && isset($_POST['id'])) {
        $id = intval($_POST['id']);
        $nombre = isset($_POST['nombre']) ? preg_replace('/\s+/', '', strtolower($_POST['nombre'])) : '';

        switch ($_POST['accion']) {
            case 'subirFotoPerfil':
                if (isset($_FILES['foto_perfil'])) {
                    $resultado = subirFoto($id, $nombre, $_FILES['foto_perfil']);
                    echo json_encode($resultado);
                } else {
                    echo json_encode(array('success' => false, 'error' => 'No se recibió ninguna imagen.'));
                }
                break;

            case 'eliminarFotoPerfil':
                $resultado = eliminarFoto($id);
                echo json_encode($resultado);
                break;

            case 'reemplazarFotoPerfil':
                if (isset($_FILES['foto_perfil'])) {
                    $resultado = reemplazarFoto($id, $nombre, $_FILES['foto_perfil']);
                    echo json_encode($resultado);
                } else {
                    echo json_encode(array('success' => false, 'error' => 'No se recibió ninguna imagen.'));
                }
                break;

            default:
                echo json_encode(array('success' => false, 'error' => 'Acción no válida.'));
                break;
        }
    } else {
        echo json_encode(array('success' => false, 'error' => 'Datos incompletos.'));
    }
} else {
    echo json_encode(array('success' => false, 'error' => 'Método no permitido.'));
}

function subirFoto($id, $nombre, $foto) {
    // Obtener la extensión original de la imagen
    $foto_extension = pathinfo($foto['name'], PATHINFO_EXTENSION);

    // Crear el nuevo nombre de la imagen, manteniendo la extensión original
    $nuevo_nombre_foto = $id . $nombre . '.' . $foto_extension;

    // Ruta donde se guardará la imagen
    $ruta_foto = '../assets/imagenes/fotos_perfil/' . $nuevo_nombre_foto;

    // Subir la imagen al servidor
    if (move_uploaded_file($foto['tmp_name'], $ruta_foto)) {
        // Actualizar la base de datos con el nuevo nombre de la imagen y la fecha de modificación
        global $conexion;
        
        // Verificar si el usuario ya tiene un registro en la base de datos
        $query_verificar = "SELECT COUNT(*) FROM usuarios WHERE id = ?";
        $stmt_verificar = $conexion->prepare($query_verificar);
        $stmt_verificar->bind_param('i', $id);
        $stmt_verificar->execute();
        $stmt_verificar->bind_result($cuenta);
        $stmt_verificar->fetch();
        $stmt_verificar->close();

        $fecha_modificacion = date('Y-m-d H:i:s');

        if ($cuenta > 0) {
            // Si el usuario ya existe, realizar un UPDATE
            $query = "UPDATE usuarios SET foto_portada = ?, fecha_modificacion = NOW() WHERE id = ?";
            $stmt = $conexion->prepare($query);
            $stmt->bind_param('si', $nuevo_nombre_foto, $id);
        } else {
            // Si el usuario no existe, realizar un INSERT
            $query = "INSERT INTO usuarios (id, foto_portada, fecha_modificacion) VALUES (?, ?, NOW())";
            $stmt = $conexion->prepare($query);
            $stmt->bind_param('is', $id, $nuevo_nombre_foto);
        }        

        if ($stmt->execute()) {
            return array('success' => true, 'foto_perfil' => $nuevo_nombre_foto);
        } else {
            return array('success' => false, 'error' => 'Error al actualizar la base de datos.');
        }
    } else {
        return array('success' => false, 'error' => 'Error al subir la imagen.');
    }
}

function reemplazarFoto($id, $nombre, $foto) {
    // Primero eliminamos la foto actual
    $eliminar_resultado = eliminarFoto($id);
    if ($eliminar_resultado['success']) {
        // Después subimos la nueva foto
        return subirFoto($id, $nombre, $foto);
    } else {
        return $eliminar_resultado;
    }
}

function eliminarFoto($id) {
    // Consultar el nombre de la foto actual en la base de datos
    global $conexion;

    // Inicializamos la variable $foto_portada
    $foto_portada = null;

    $query = "SELECT foto_portada FROM usuarios WHERE id = ?";
    $stmt = $conexion->prepare($query);
    $stmt->bind_param('i', $id);
    $stmt->execute();

    // Enlazar el resultado de la consulta a la variable $foto_portada
    $stmt->bind_result($foto_portada);
    $stmt->fetch();
    $stmt->close();

    if ($foto_portada) {
        // Eliminar el archivo físico
        $ruta_foto = '../assets/imagenes/fotos_perfil/' . $foto_portada;
        if (file_exists($ruta_foto)) {
            unlink($ruta_foto);
        }

        // Actualizar la fecha de modificación y eliminar el registro en la base de datos
        $query = "UPDATE usuarios SET foto_portada = NULL, fecha_modificacion = NOW() WHERE id = ?";
        $stmt = $conexion->prepare($query);
        $stmt->bind_param('i', $id);        
        if ($stmt->execute()) {
            return array('success' => true);
        } else {
            return array('success' => false, 'error' => 'Error al eliminar la referencia en la base de datos.');
        }
    } else {
        return array('success' => false, 'error' => 'No se encontró la foto.');
    }
}
?>