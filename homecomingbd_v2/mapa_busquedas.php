<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');

header('Content-Type: application/json');
include 'config.php';

// Consulta para obtener las mascotas perdidas y la información de los dueños
$sqlMascotas = "SELECT m.id, m.nombre, m.especie, m.raza, m.sexo, m.fecha_perdida, m.lugar_perdida, m.estado, m.descripcion, m.latitud, m.longitud, u.nombre AS nombre_dueno,
                u.email AS email_dueno, u.telefono AS telefono_dueno
                FROM mascotas m
                JOIN usuarios u ON m.usuario_id = u.id
                WHERE m.estado = 'perdido' AND m.estado_registro = 1";
$resultMascotas = $conexion->query($sqlMascotas);

$mascotas = array();

if ($resultMascotas) {
    while ($rowMascota = $resultMascotas->fetch_assoc()) {
        $mascotaId = (int)$rowMascota['id'];
        
        // Asegura que latitud y longitud sean floats
        $rowMascota['latitud'] = (float)$rowMascota['latitud'];
        $rowMascota['longitud'] = (float)$rowMascota['longitud'];
        
        // Consulta para obtener las fotos de la mascota
        $sqlFotos = "SELECT foto FROM fotos_mascotas WHERE mascota_id = $mascotaId";
        $resultFotos = $conexion->query($sqlFotos);
        
        $fotos = array();
        if ($resultFotos) {
            while ($rowFoto = $resultFotos->fetch_assoc()) {
                $fotos[] = $rowFoto['foto']; // Añade la foto al array de fotos
            }
        }
        
        // Añade las fotos al resultado de la mascota
        $rowMascota['fotos'] = $fotos;

        // Añadir la mascota al array
        $mascotas[] = $rowMascota;
    }
    
    // Enviar el resultado en formato JSON
    echo json_encode($mascotas);
} else {
    echo json_encode([]); // Enviar un array vacío si hay un error
}

$conexion->close();
?>
