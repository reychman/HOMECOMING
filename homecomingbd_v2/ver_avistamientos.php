<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json; charset=utf-8');

// Desactivar la visualización de errores
error_reporting(0);

include 'config.php';

$response = array(
    'success' => false,
    'message' => '',
    'mascota_ubicacion' => null,
    'avistamientos' => array()
);

if ($conexion->connect_error) {
    $response['message'] = 'Error de conexión: ' . $conexion->connect_error;
    echo json_encode($response);
    exit();
}

// Obtener el ID de la mascota desde la solicitud GET
$id_mascota = isset($_GET['id_mascota']) ? intval($_GET['id_mascota']) : 0;

if ($id_mascota <= 0) {
    $response['message'] = 'ID de mascota no válido';
    echo json_encode($response);
    exit();
}

// Consulta para obtener la ubicación original de la mascota y sus avistamientos
$sql = "SELECT 
            m.id,
            m.latitud AS original_latitud, 
            m.longitud AS original_longitud, 
            a.id_mascota AS avistamiento_mascota_id,
            a.latitud AS avistamiento_latitud, 
            a.longitud AS avistamiento_longitud, 
            a.fecha_avistamiento, 
            a.detalles
        FROM mascotas m
        LEFT JOIN avistamientos a ON m.id = a.id_mascota
        WHERE m.id = ?
        ORDER BY a.fecha_avistamiento DESC";

$stmt = $conexion->prepare($sql);
$stmt->bind_param("i", $id_mascota);

// Capturar cualquier error de preparación
if (!$stmt) {
    $response['message'] = 'Error en la preparación de la consulta: ' . $conexion->error;
    echo json_encode($response);
    exit();
}

$stmt->execute();
$result = $stmt->get_result();

if ($result === false) {
    $response['message'] = 'Error en la ejecución de la consulta: ' . $stmt->error;
    echo json_encode($response);
    exit();
}

if ($result->num_rows > 0) {
    $first_row = true;
    while ($row = $result->fetch_assoc()) {
        // Agregar información de ubicación original de la mascota solo una vez
        if ($first_row) {
            $response['mascota_ubicacion'] = array(
                'id' => $row['id'],
                'latitud' => $row['original_latitud'],
                'longitud' => $row['original_longitud']
            );
            $first_row = false;
        }

        // Agregar avistamientos si existen
        if ($row['avistamiento_latitud'] !== null) {
            $response['avistamientos'][] = array(
                'latitud' => $row['avistamiento_latitud'],
                'longitud' => $row['avistamiento_longitud'],
                'fecha_avistamiento' => $row['fecha_avistamiento'] ?? '',
                'detalles' => $row['detalles'] ?? ''
            );
        }
    }
    
    $response['success'] = true;
} else {
    $response['message'] = 'No se encontraron datos para esta mascota';
}

// Asegurar que no hay salida inesperada antes del json_encode
ob_clean();
echo json_encode($response);

$stmt->close();
$conexion->close();
?>