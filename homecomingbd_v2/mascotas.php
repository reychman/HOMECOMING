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
$sql = "SELECT id, nombre, especie, raza, sexo, fecha_perdida, lugar_perdida, estado, descripcion, foto FROM mascotas";
$result = $conexion->query($sql);

$mascotas = array();

if ($result->num_rows > 0) {
    // Salida de datos de cada fila
    while($row = $result->fetch_assoc()) {
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
            'foto' => $row['foto']
        );
    }
}

// Cerrar conexión
$conexion->close();

// Devolver resultado en formato JSON
header('Content-Type: application/json');
echo json_encode($mascotas);
?>
