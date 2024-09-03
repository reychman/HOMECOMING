<?php
header("Access-Control-Allow-Origin: *"); // Permitir solicitudes de cualquier origen
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Métodos permitidos
header("Access-Control-Allow-Headers: Content-Type"); // Encabezados permitidos
header('Content-Type: application/json');
include 'config.php';

$sql = "SELECT 
            (SELECT COUNT(*) FROM mascotas WHERE estado = 'perdido') AS mascotas_perdidas,
            (SELECT COUNT(*) FROM mascotas WHERE estado = 'encontrado') AS mascotas_encontradas,
            (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'administrador') AS usuarios_administradores,
            (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'propietario') AS usuarios_propietarios,
            (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'refugio') AS usuarios_refugios
        FROM (SELECT 1) AS dummy";

$result = $conexion->query($sql);

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

$conexion->close();
?>