<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include 'config.php';

// Obtener los parámetros de fecha de inicio y fecha fin
$start_date = $_GET['start_date'] ?? null;
$end_date = $_GET['end_date'] ?? null;

// Consulta SQL base
$sql = "SELECT 
            (SELECT COUNT(*) FROM mascotas WHERE estado = 'perdido'";

// Agregar filtro de fechas para las mascotas perdidas
if ($start_date && $end_date) {
    $sql .= " AND fecha_perdida BETWEEN '$start_date' AND '$end_date'";
}

$sql .= ") AS mascotas_perdidas,
            (SELECT COUNT(*) FROM mascotas WHERE estado = 'encontrado'";

// Agregar filtro de fechas para las mascotas encontradas
if ($start_date && $end_date) {
    $sql .= " AND fecha_perdida BETWEEN '$start_date' AND '$end_date'";
}

$sql .= ") AS mascotas_encontradas,
            (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'administrador'";

// Agregar filtro de fechas para los usuarios administradores
if ($start_date && $end_date) {
    $sql .= " AND fecha_creacion BETWEEN '$start_date' AND '$end_date'";
}

$sql .= ") AS usuarios_administradores,
            (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'propietario'";

// Agregar filtro de fechas para los usuarios propietarios
if ($start_date && $end_date) {
    $sql .= " AND fecha_creacion BETWEEN '$start_date' AND '$end_date'";
}

$sql .= ") AS usuarios_propietarios,
            (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'refugio'";

// Agregar filtro de fechas para los usuarios refugios
if ($start_date && $end_date) {
    $sql .= " AND fecha_creacion BETWEEN '$start_date' AND '$end_date'";
}

$sql .= ") AS usuarios_refugios
        FROM (SELECT 1) AS dummy";

$result = $conexion->query($sql);

// Verificar si la consulta fue exitosa y enviar la respuesta en formato JSON
if ($result) {
    $row = $result->fetch_assoc();
    echo json_encode([
        'mascotas_perdidas' => (int) $row['mascotas_perdidas'],
        'mascotas_encontradas' => (int) $row['mascotas_encontradas'],
        'usuarios_administradores' => (int) $row['usuarios_administradores'],
        'usuarios_propietarios' => (int) $row['usuarios_propietarios'],
        'usuarios_refugios' => (int) $row['usuarios_refugios']
    ]);
} else {
    echo json_encode([
        'mascotas_perdidas' => 0,
        'mascotas_encontradas' => 0,
        'usuarios_administradores' => 0,
        'usuarios_propietarios' => 0,
        'usuarios_refugios' => 0
    ]);
}

// Cerrar la conexión a la base de datos
$conexion->close();
?>
