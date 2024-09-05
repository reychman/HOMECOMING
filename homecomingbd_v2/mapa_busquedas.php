<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');

header('Content-Type: application/json');
include 'config.php';

$sql = "SELECT id, especie, descripcion, latitud, longitud FROM mascotas WHERE estado = 'perdido' AND estado_registro = 1";
$result = $conexion->query($sql);

$mascotas = array();

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $row['id'] = (int)$row['id']; // Asegura que id sea un entero
        $row['latitud'] = (float)$row['latitud']; // Asegura que latitud sea un float
        $row['longitud'] = (float)$row['longitud']; // Asegura que longitud sea un float
        $mascotas[] = $row;
    }
    echo json_encode($mascotas);
} else {
    echo json_encode([]);
}

$conexion->close();
?>
