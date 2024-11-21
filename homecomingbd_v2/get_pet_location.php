<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');


include 'config.php';

// Check connection
if ($conexion->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conexion->connect_error]));
}

// Get mascota_id from GET parameter
$mascota_id = isset($_GET['mascota_id']) ? intval($_GET['mascota_id']) : 0;

if ($mascota_id <= 0) {
    die(json_encode(['error' => 'Invalid mascota_id']));
}

// Prepare SQL to prevent SQL injection
$sql = "SELECT latitud, longitud FROM mascotas WHERE id = ?";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("i", $mascota_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        'latitud' => $row['latitud'], 
        'longitud' => $row['longitud']
    ]);
} else {
    echo json_encode(['error' => 'No location found for this pet']);
}

$stmt->close();
$conexion->close();
?>