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

// Define la URL base para las imágenes
$base_url = "http://localhost/homecoming/assets/imagenes/fotos_mascotas/"; // Ajusta esto a la ruta correcta en tu servidor Laragon

// Consulta para obtener todas las mascotas
$sql = "SELECT M.id, M.nombre, M.especie, M.raza, M.sexo, M.fecha_perdida, M.lugar_perdida, M.estado, M.descripcion, M.fecha_creacion, U.nombre AS nombre_dueno, U.primerApellido AS primer_apellido_dueno, U.segundoApellido AS segundo_apellido_dueno, U.email AS email_dueno, U.telefono AS telefono_dueno
        FROM mascotas M
        JOIN usuarios U ON M.usuario_id = U.id
        WHERE estado_registro=1
        ORDER BY M.fecha_creacion DESC";

$result = $conexion->query($sql);
$mascotas = array();

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $sql_fotos = "SELECT foto FROM fotos_mascotas WHERE mascota_id = " . $row['id'];
        $result_fotos = $conexion->query($sql_fotos);
        $fotos = array();

        if ($result_fotos->num_rows > 0) {
            while($foto_row = $result_fotos->fetch_assoc()) {
                $fotos[] = $base_url . $foto_row['foto']; // Construye la URL completa
            }
        }

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
            'nombre_dueno' => $row['nombre_dueno'],
            'primer_apellido_dueno' => $row['primer_apellido_dueno'],
            'segundo_apellido_dueno' => $row['segundo_apellido_dueno'],
            'email_dueno' => $row['email_dueno'],
            'telefono_dueno' => $row['telefono_dueno']
        );
    }
}

$conexion->close();

echo json_encode($mascotas);
?>