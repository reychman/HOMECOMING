<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

include 'config.php';

// Verificar conexión
if ($conexion->connect_error) {
    die("Conexión fallida: " . $conexion->connect_error);
}

// Consulta para obtener todas las mascotas
$sql = "SELECT M.id, M.nombre, M.especie, M.raza, M.sexo, M.fecha_perdida, M.lugar_perdida, M.estado, M.descripcion, U.nombre AS nombre_dueno, U.email AS email_dueno, U.telefono AS telefono_dueno
        FROM mascotas M
        JOIN usuarios U ON M.usuario_id = U.id";

$result = $conexion->query($sql);
$mascotas = array();

if ($result->num_rows > 0) {
    // Para cada mascota, obtenemos sus fotos
    while($row = $result->fetch_assoc()) {
        // Consulta para obtener las fotos asociadas con la mascota
        $sql_fotos = "SELECT foto FROM fotos_mascotas WHERE mascota_id = " . $row['id'];
        $result_fotos = $conexion->query($sql_fotos);
        $fotos = array();

        // Añadir todas las fotos a un array
        if ($result_fotos->num_rows > 0) {
            while($foto_row = $result_fotos->fetch_assoc()) {
                $fotos[] = $foto_row['foto'];
            }
        }

        // Crear la estructura de datos de la mascota con las fotos
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
            'fotos' => $fotos,  // Array con todas las fotos
            'nombre_dueno' => $row['nombre_dueno'],
            'email_dueno' => $row['email_dueno'],
            'telefono_dueno' => $row['telefono_dueno']
        );
    }
}

// Cerrar conexión
$conexion->close();

// Devolver resultado en formato JSON
echo json_encode($mascotas);
?>
