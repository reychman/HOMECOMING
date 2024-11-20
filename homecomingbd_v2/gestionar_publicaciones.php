<?php
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
    header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
    header('Content-Type: application/json');

    include 'config.php'; // Asumiendo que config.php tiene la conexión a la base de datos

    // Verificar el método HTTP y el parámetro 'accion'
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $accion = isset($_POST['accion']) ? $_POST['accion'] : '';

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
            case 'eliminarFotoMascota':
                eliminarFotoMascota();
                break;
            case 'marcarComoIndebido':
                marcarComoIndebido();
                break;
            case 'obtenerMascotasAdoptadas':
                obtenerMascotasAdoptadas();
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
                    U.nombre AS nombre_dueno, U.email AS email_dueno, U.telefono AS telefono_dueno, M.estado_registro AS estado_registro
            FROM mascotas M
            JOIN usuarios U ON M.usuario_id = U.id
            LEFT JOIN fotos_mascotas F ON M.id = F.mascota_id
            WHERE M.usuario_id = ? AND M.estado_registro = 1 OR M.estado_registro = 2
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
                    'telefono_dueno' => $row['telefono_dueno'],
                    'estado_registro' => $row['estado_registro']
                );
            }
        }

        if (empty($mascotas)) {
            echo json_encode(['error' => 'No se encontraron publicaciones para este usuario']);
        } else {
            echo json_encode($mascotas);
        }
    }

    function obtenerMascotasAdoptadas() {
        global $conexion; 
    
        $usuario_id = isset($_POST['usuario_id']) ? $_POST['usuario_id'] : null;
        error_log("Usuario ID recibido: " . $usuario_id);
        
        if (!$usuario_id) {
            echo json_encode(['error' => 'Falta el usuario_id']);
            exit;
        }
    
        $sql = "SELECT M.id, M.nombre, M.especie, M.raza, M.sexo, 
                    M.fecha_perdida, M.lugar_perdida, 
                    M.estado, M.descripcion, 
                    GROUP_CONCAT(F.foto) AS fotos, 
                    M.latitud, M.longitud, 
                    U.nombre AS nombre_dueno_original, 
                    U.email AS email_dueno_original, 
                    U.telefono AS telefono_dueno_original
                FROM adopciones A
                JOIN mascotas M ON A.mascota_id = M.id
                JOIN usuarios U ON M.usuario_id = U.id
                LEFT JOIN fotos_mascotas F ON M.id = F.mascota_id
                WHERE A.adoptante_id = ? AND A.estado = 'adoptado' OR A.estado = 'interesado'
                GROUP BY M.id";
    
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
                    'fotos' => $fotos, 
                    'latitud' => $row['latitud'],
                    'longitud' => $row['longitud'],
                    'nombre_dueno_original' => $row['nombre_dueno_original'],
                    'email_dueno_original' => $row['email_dueno_original'],
                    'telefono_dueno_original' => $row['telefono_dueno_original']
                );
            }
        }
    
        if (empty($mascotas)) {
            echo json_encode(['error' => 'No se encontraron mascotas adoptadas']);
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
            $fechaActual = ($nuevoEstado == 'encontrado') ? date('Y-m-d H:i:s') : null;
            $sql = "UPDATE mascotas SET estado = ?, fechaEncontrado = ? WHERE id = ?";
            $stmt = $conexion->prepare($sql);
            $stmt->bind_param("ssi", $nuevoEstado, $fechaActual, $id);
    
            if ($stmt->execute()) {
                echo json_encode(['success' => true, 'message' => 'Estado actualizado']);
            } else {
                echo json_encode(['success' => false, 'error' => 'No se pudo actualizar el estado']);
            }
        } else {
            echo json_encode(['error' => 'Faltan datos']);
        }
    }
    

    function actualizarPublicacion() {
        global $conexion;
    
        $id = isset($_POST['id']) ? $_POST['id'] : null;  // Recupera el ID de la Publicacion
        $nombre = isset($_POST['nombre']) ? strtoupper($_POST['nombre']) : null; // Convertir a mayúsculas
        $especie = isset($_POST['especie']) ? strtoupper($_POST['especie']) : null; // Convertir a mayúsculas
        $raza = isset($_POST['raza']) ? strtoupper($_POST['raza']) : null; // Convertir a mayúsculas
        $sexo = isset($_POST['sexo']) ? strtoupper($_POST['sexo']) : null; // Convertir a mayúsculas
        $fecha_perdida = isset($_POST['fecha_perdida']) ? strtoupper($_POST['fecha_perdida']) : null; // Convertir a mayúsculas
        $lugar_perdida = isset($_POST['lugar_perdida']) ? strtoupper($_POST['lugar_perdida']) : null; // Convertir a mayúsculas
        $descripcion = isset($_POST['descripcion']) ? strtoupper($_POST['descripcion']) : null; // Convertir a mayúsculas
        $latitud = isset($_POST['latitud']) ? $_POST['latitud'] : null;
        $longitud = isset($_POST['longitud']) ? $_POST['longitud'] : null;
    
        // Crea la consulta de actualización
        $sql = "UPDATE mascotas SET 
                    nombre = ?, 
                    especie = ?, 
                    raza = ?, 
                    sexo = ?, 
                    descripcion = ?, 
                    latitud = ?, 
                    longitud = ?";
    
        // Agrega los campos opcionales solo si están definidos
        if ($fecha_perdida !== null) {
            $sql .= ", fecha_perdida = ?";
        }
        if ($lugar_perdida !== null) {
            $sql .= ", lugar_perdida = ?";
        }
    
        $sql .= " WHERE id = ?";
    
        $stmt = $conexion->prepare($sql);
        
        // Prepara los parámetros de enlace
        $params = [$nombre, $especie, $raza, $sexo, $descripcion, $latitud, $longitud];
    
        if ($fecha_perdida !== null) {
            $params[] = $fecha_perdida;
        }
        if ($lugar_perdida !== null) {
            $params[] = $lugar_perdida;
        }
        
        // Agrega el ID al final
        $params[] = $id;
    
        // Define el tipo de los parámetros según los que estás usando
        $types = str_repeat('s', count($params) - 1) . 'd'; // Ajusta el tipo según corresponda (s para string, d para double)
    
        $stmt->bind_param($types, ...$params);
    
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Publicacion actualizada']);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo actualizar la publicacion']);
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
    
    
    function eliminarFotoMascota() {
        global $conexion;
        $foto_id = isset($_POST['foto_id']) ? $_POST['foto_id'] : null;
        
        if (!$foto_id) {
            echo json_encode(['success' => false, 'error' => 'ID de la foto no proporcionado']);
            return;
        }
        
        // Consultar la ruta de la foto
        $sql = "SELECT foto FROM fotos_mascotas WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param('i', $foto_id);
        $stmt->execute();
        $stmt->bind_result($foto);
        $stmt->fetch();
        $stmt->close();
        
        if (!$foto) {
            echo json_encode(['success' => false, 'error' => 'No se encontró la foto']);
            return;
        }
        
        $ruta_foto = '../assets/imagenes/fotos_mascotas/' . $foto;
        if (file_exists($ruta_foto)) {
            unlink($ruta_foto);
        }
        
        $sql = "DELETE FROM fotos_mascotas WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param('i', $foto_id);
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Error al eliminar la foto de la base de datos']);
        }
    }
       // Función para eliminar una Publicacion lógicamente
    function eliminarPublicacion() {
        global $conexion;

        // Recuperar el id de la Publicacion
        $id = isset($_POST['id']) ? $_POST['id'] : null;

        // Verificar si el id es nulo
        if (!$id) {
            echo json_encode(['error' => 'Falta el id de la Publicacion']);
            return;
        }

        // Registrar el id recibido para eliminar
        error_log("Eliminando Publicacion con ID: " . $id);

        // Preparar la consulta para eliminar la Publicacion lógicamente
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
            echo json_encode(['success' => true, 'message' => 'Publicacion eliminada']);
        } else {
            echo json_encode(['success' => false, 'error' => 'No se pudo eliminar la Publicacion']);
            error_log("Error al ejecutar la consulta SQL: " . $stmt->error);
        }
    }
    // Función para marcar una Publicacion como indebida
    function marcarComoIndebido() {
        global $conexion;
        
        // Obtener el raw input
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        // Si no hay datos JSON, intentar obtener de POST
        if (json_last_error() !== JSON_ERROR_NONE) {
            $id = isset($_POST['id']) ? $_POST['id'] : null;
        } else {
            $id = isset($data['id']) ? $data['id'] : null;
        }
        
        // Log para debugging
        error_log("ID recibido: " . print_r($id, true));
        error_log("POST data: " . print_r($_POST, true));
        error_log("Raw input: " . $input);
        
        // Verificar si el id es nulo
        if (!$id) {
            echo json_encode(['success' => false, 'error' => 'Falta el id de la Publicacion']);
            return;
        }
    
        // Asegurarse de que el id sea un número
        $id = intval($id);
        
        // Preparar la consulta para actualizar el estado_registro a 2
        $sql = "UPDATE mascotas SET estado_registro = 2 WHERE id = ?";
        $stmt = $conexion->prepare($sql);
        
        if ($stmt === false) {
            error_log("Error preparando la consulta SQL: " . $conexion->error);
            echo json_encode(['success' => false, 'error' => 'Error preparando la consulta']);
            return;
        }
        
        // Asignar el parámetro y ejecutar la consulta
        $stmt->bind_param("i", $id);
        
        if ($stmt->execute()) {
            // Verificar si realmente se actualizó algún registro
            if ($stmt->affected_rows > 0) {
                echo json_encode(['success' => true, 'message' => 'Publicacion marcada como indebida']);
            } else {
                echo json_encode(['success' => false, 'error' => 'No se encontró la Publicacion o ya estaba marcada como indebida']);
            }
        } else {
            error_log("Error al ejecutar la consulta SQL: " . $stmt->error);
            echo json_encode(['success' => false, 'error' => 'No se pudo marcar la Publicacion']);
        }
        
        $stmt->close();
    }

?>
