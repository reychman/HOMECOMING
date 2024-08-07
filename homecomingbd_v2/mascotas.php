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
$sql = "SELECT M.id, M.nombre, M.especie, M.raza, M.sexo, M.fecha_perdida, M.lugar_perdida, M.estado, M.descripcion, M.foto, U.nombre AS nombre_dueno, U.email AS email_dueno, U.telefono AS telefono_dueno
        FROM mascotas M
        JOIN usuarios  U ON M.usuario_id = U.id";
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
            'foto' => $row['foto'],
            'nombre_dueno' => $row['nombre_dueno'],
            'email_dueno' => $row['email_dueno'],
            'telefono_dueno' => $row['telefono_dueno']
        );
    }
}

// Cerrar conexión
$conexion->close();

// Devolver resultado en formato JSON
header('Content-Type: application/json');
echo json_encode($mascotas);
?>
