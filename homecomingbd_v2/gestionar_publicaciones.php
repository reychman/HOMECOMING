<?php
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
    header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
    header('Content-Type: application/json');

    include 'config.php'; // Asumiendo que config.php tiene la conexión a la base de datos

    // Verificar el método HTTP y el parámetro 'accion'
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $accion = isset($_POST['accion']) ? $_POST['accion'] : null;

        switch ($accion) {
            case 'obtenerPublicaciones':
                obtenerPublicaciones();
                break;
            case 'actualizarEstado':
                actualizarEstado();
                break;
            case 'eliminarPublicacion':
                eliminarPublicacion();
                break;
            case 'actualizarPublicacion':
                actualizarPublicacion();
                break;
            case 'agregarFotos':
                agregarFotos();
                break;
            case 'eliminarFoto':
                eliminarFoto();
                break;
            case 'reemplazarFoto':
                reemplazarFoto();
                break;
            default:
                echo json_encode(['error' => 'Acción no válida']);
                break;
        }
    } else {
        echo json_encode(['error' => 'Método no permitido']);
    }

    // Función para obtener las publicaciones del usuario
    function obtenerPublicaciones() {
        global $conexion; 

        $usuario_id = isset($_POST['usuario_id']) ? $_POST['usuario_id'] : null;
        error_log("Usuario ID recibido: " . $usuario_id);
        
        if (!$usuario_id) {
            echo json_encode(['error' => 'Falta el usuario_id']);
            exit;
        }

        $sql = "SELECT M.id, M.nombre, M.especie, M.raza, M.sexo, M.fecha_perdida, M.lugar_perdida, 
                    M.estado, M.descripcion, GROUP_CONCAT(F.foto) AS fotos, M.latitud, M.longitud, 
                    U.nombre AS nombre_dueno, U.email AS email_dueno, U.telefono AS telefono_dueno
            FROM mascotas M
            JOIN usuarios U ON M.usuario_id = U.id
            LEFT JOIN fotos_mascotas F ON M.id = F.mascota_id
            WHERE M.usuario_id = ? AND M.estado_registro = 1
            GROUP BY M.id";  // Agrupar por ID de mascota para concatenar las fotos

        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("i", $usuario_id);
        $stmt->execute();
        $result = $stmt->get_result();

        $mascotas = array();

        if ($result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                // Dividimos las fotos en una lista si se han concatenado
                $fotos = !empty($row['fotos']) ? explode(',', $row['fotos']) : [];

                $mascotas[] = array(
                    'id' => (int)$row['id'],
                    'nombre' => $row['nombre'],
                    'especie' => $row['especie'],
                    'raza' => $row['raza'],
                    'sexo' => $row['sexo'],
                    'fecha_perdida' => $row['fecha_perdida'],
                    'lugar_perdida' => $row['lugar_perdida'],
                    'estado' => $row['estado'],
                    'descripcion' => $row['descripcion'],
                    'fotos' => $fotos, // Incluimos la lista de fotos
                    'latitud' => $row['latitud'],
                    'longitud' => $row['longitud'],
                    'nombre_dueno' => $row['nombre_dueno'],
                    'email_dueno' => $row['email_dueno'],
                    'telefono_dueno' => $row['telefono_dueno']
                );
            }
        }

        if (empty($mascotas)) {
            echo json_encode(['error' => 'No se encontraron publicaciones para este usuario']);
        } else {
            echo json_encode($mascotas);
        }
    }


    // Función para actualizar el estado de una mascota (perdido/encontrado)
    function actualizarEstado() {
        global $conexion;

        $id = isset($_POST['id']) ? $_POST['id'] : null;
        $nuevoEstado = isset($_POST['estado']) ? $_POST['estado'] : null;
        error_log("ID recibido: " . $id);
        error_log("Estado recibido: " . $nuevoEstado);

        if ($id && $nuevoEstado) {
            $sql = "UPDATE mascotas SET estado = ? WHERE id = ?";
            $stmt = $conexion->prepare($sql);
            $stmt->bind_param("si", $nuevoEstado, $id);
            if ($stmt->execute()) {
                echo json_encode(['success' => true, 'message' => 'Estado actualizado']);
            } else {
                echo json_encode(['success' => false, 'error' => 'No se pudo actualizar el estado']);
            }
        } else {
            echo json_encode(['error' => 'Faltan datos']);
        }
    }



    // Función para eliminar una publicación lógicamente
    function eliminarPublicacion() {
        global $conexion;

        // Recuperar el id de la publicación
        $id = isset($_POST['id']) ? $_POST['id'] : null;

        // Verificar si el id es nulo
        if (!$id) {
            echo json_encode(['error' => 'Falta el id de la publicación']);
            return;
        }

        // Registrar el id recibido para eliminar
        error_log("Eliminando publicación con ID: " . $id);

        // Preparar la consulta para eliminar la publicación lógicamente
        $sql = "UPDATE mascotas SET estado_registro = 0 WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        
        if ($stmt === false) {
            echo json_encode(['error' => 'Error preparando la consulta']);
            error_log("Error preparando la consulta SQL: " . $conexion->error);
            return;
        }

        // Asignar el parámetro y ejecutar la consulta
        $stmt->bind_param("i", $id);
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Publicación eliminada']);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo eliminar la publicación']);
            error_log("Error al ejecutar la consulta SQL: " . $stmt->error);
        }
    }

    function actualizarPublicacion() {
        global $conexion;

        $id = isset($_POST['id']) ? $_POST['id'] : null;  // Recupera el ID de la publicación
        $nombre = isset($_POST['nombre']) ? $_POST['nombre'] : null;
        $especie = isset($_POST['especie']) ? $_POST['especie'] : null;
        $raza = isset($_POST['raza']) ? $_POST['raza'] : null;
        $sexo = isset($_POST['sexo']) ? $_POST['sexo'] : null;
        $fecha_perdida = isset($_POST['fecha_perdida']) ? $_POST['fecha_perdida'] : null;
        $lugar_perdida = isset($_POST['lugar_perdida']) ? $_POST['lugar_perdida'] : null;
        $descripcion = isset($_POST['descripcion']) ? $_POST['descripcion'] : null;
        $latitud = isset($_POST['latitud']) ? $_POST['latitud'] : null;
        $longitud = isset($_POST['longitud']) ? $_POST['longitud'] : null;

        if ($id && $nombre && $especie && $raza && $sexo && $fecha_perdida && $lugar_perdida && $descripcion && $latitud && $longitud) {
            $sql = "UPDATE mascotas SET 
                        nombre = ?, 
                        especie = ?, 
                        raza = ?, 
                        sexo = ?, 
                        fecha_perdida = ?, 
                        lugar_perdida = ?, 
                        descripcion = ?, 
                        latitud = ?, 
                        longitud = ?
                    WHERE id = ?";
            $stmt = $conexion->prepare($sql);
            $stmt->bind_param("sssssssddi", $nombre, $especie, $raza, $sexo, $fecha_perdida, $lugar_perdida, $descripcion, $latitud, $longitud, $id);

            if ($stmt->execute()) {
                echo json_encode(['success' => true, 'message' => 'Publicación actualizada']);
            } else {
                echo json_encode(['success' => false, 'error' => 'No se pudo actualizar la publicacion']);
            }
        } else {
            echo json_encode(['error' => 'Faltan datos para actualizar la publicacion']);
        }
    }

    function agregarFotos() {
        global $conexion;
    
        $publicacion_id = isset($_POST['publicacion_id']) ? $_POST['publicacion_id'] : null;
        if (!$publicacion_id || empty($_FILES['fotos_mascotas']['name'])) {
            echo json_encode(['error' => 'Faltan datos o no se seleccionaron fotos']);
            return;
        }
    
        // Consulta para obtener el nombre de la mascota y el usuario_id
        $sql = "SELECT m.nombre, m.usuario_id 
                FROM mascotas m 
                WHERE m.id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param('i', $publicacion_id);
        $stmt->execute();
        $stmt->bind_result($nombre_mascota, $usuario_id);
        $stmt->fetch();
        $stmt->close();
    
        if (!$nombre_mascota || !$usuario_id) {
            echo json_encode(['error' => 'No se encontró la mascota o el usuario asociado']);
            return;
        }
    
        $errores = [];
    
        foreach ($_FILES['fotos_mascotas']['tmp_name'] as $index => $tmpName) {
            $foto_name = $_FILES['fotos_mascotas']['name'][$index];
            $foto_extension = pathinfo($foto_name, PATHINFO_EXTENSION);
    
            // Insertar la nueva foto
            $sql_foto = "INSERT INTO fotos_mascotas (mascota_id, foto) VALUES (?, '')";
            $stmt_foto = $conexion->prepare($sql_foto);
            $stmt_foto->bind_param('i', $publicacion_id);
            if (!$stmt_foto->execute()) {
                $errores[] = "Error al insertar la foto en la base de datos";
                continue;
            }
    
            $foto_id = $conexion->insert_id;
    
            // Crear el nuevo nombre de la foto con el formato deseado
            $nuevo_nombre_foto = $foto_id . preg_replace('/[^A-Za-z0-9]/', '', $nombre_mascota) . $usuario_id . '.' . $foto_extension;
            $ruta_foto = '../assets/imagenes/fotos_mascotas/' . $nuevo_nombre_foto;
    
            if (!move_uploaded_file($tmpName, $ruta_foto)) {
                $errores[] = "Error al mover el archivo de imagen";
                continue;
            }
    
            // Actualizar el registro de la foto con el nuevo nombre
            $sql_update_foto = "UPDATE fotos_mascotas SET foto = ? WHERE id = ?";
            $stmt_update_foto = $conexion->prepare($sql_update_foto);
            $stmt_update_foto->bind_param('si', $nuevo_nombre_foto, $foto_id);
            if (!$stmt_update_foto->execute()) {
                $errores[] = "Error al actualizar el nombre de la foto en la base de datos";
            }
        }
    
        if (empty($errores)) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['error' => $errores]);
        }
    }
    
    
    function eliminarFoto() {
        global $conexion;
    
        $foto_id = isset($_POST['foto_id']) ? $_POST['foto_id'] : null;
    
        if (!$foto_id) {
            echo json_encode(['success' => false, 'error' => 'ID de la foto no proporcionado']);
            return;
        }
    
        // Depurar el valor de foto_id
        error_log("Recibiendo foto_id: $foto_id");
    
        // Consultar la ruta de la foto
        $sql = "SELECT foto FROM fotos_mascotas WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param('i', $foto_id);
        $stmt->execute();
        $stmt->bind_result($foto);
        $stmt->fetch();
        $stmt->close();
    
        // Depurar el resultado de la consulta
        if (!$foto) {
            error_log("No se encontró la foto en la base de datos para foto_id: $foto_id");
            echo json_encode(['success' => false, 'error' => 'No se encontró la foto']);
            return;
        } else {
            error_log("Se encontró la foto: $foto");
        }
    
        // Eliminar la foto del servidor
        $ruta_foto = '../assets/imagenes/fotos_mascotas/' . $foto;
        if (file_exists($ruta_foto)) {
            unlink($ruta_foto);  // Eliminar el archivo
            error_log("Archivo eliminado: $ruta_foto");
        } else {
            error_log("No se encontró el archivo en la carpeta local: $ruta_foto");
        }
    
        // Eliminar el registro de la base de datos
        $sql = "DELETE FROM fotos_mascotas WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param('i', $foto_id);
    
        if ($stmt->execute()) {
            echo json_encode(['success' => true]);
        } else {
            error_log("Error al eliminar la foto de la base de datos para foto_id: $foto_id");
            echo json_encode(['success' => false, 'error' => 'Error al eliminar la foto de la base de datos']);
        }
    }
    
    
    // Función para reemplazar una foto de una mascota
    function reemplazarFoto() {
        global $conexion;
    
        $foto_id = isset($_POST['foto_id']) ? $_POST['foto_id'] : null;
    
        if (!$foto_id || !isset($_FILES['nueva_foto'])) {
            echo json_encode(['error' => 'Datos insuficientes']);
            exit;
        }
    
        // Buscar la foto actual en la base de datos
        $sql = "SELECT foto FROM fotos_mascotas WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param('i', $foto_id);
        $stmt->execute();
        $stmt->bind_result($foto_actual);
        $stmt->fetch();
        $stmt->close();
    
        if ($foto_actual) {
            // Eliminar el archivo de la carpeta local
            $ruta_foto_actual = 'assets/imagenes/fotos_mascotas/' . $foto_actual;
            if (file_exists($ruta_foto_actual)) {
                unlink($ruta_foto_actual); // Eliminar el archivo actual
            }
    
            // Guardar la nueva imagen en la carpeta local
            $nueva_foto_nombre = $_FILES['nueva_foto']['name'];
            $nueva_foto_tmp = $_FILES['nueva_foto']['tmp_name'];
            $nueva_ruta_foto = 'assets/imagenes/fotos_mascotas/' . $nueva_foto_nombre;
    
            if (move_uploaded_file($nueva_foto_tmp, $nueva_ruta_foto)) {
                // Actualizar el nombre de la nueva imagen en la base de datos
                $sql = "UPDATE fotos_mascotas SET foto = ? WHERE id = ?";
                $stmt = $conexion->prepare($sql);
                $stmt->bind_param('si', $nueva_foto_nombre, $foto_id);
                $stmt->execute();
    
                echo json_encode(['success' => true, 'message' => 'Foto reemplazada con éxito']);
            } else {
                echo json_encode(['error' => 'Error al subir la nueva imagen']);
            }
        } else {
            echo json_encode(['error' => 'Foto no encontrada']);
        }
    }
?>
