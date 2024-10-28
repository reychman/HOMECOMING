<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include 'config.php';

$start_date = $_GET['start_date'] ?? null;
$end_date = $_GET['end_date'] ?? null;
$tipo_reporte = $_GET['tipo_reporte'] ?? 'general';

// Validar fechas
if ($start_date && $end_date) {
    $start_date = mysqli_real_escape_string($conexion, $start_date);
    $end_date = mysqli_real_escape_string($conexion, $end_date);
} else {
    echo json_encode(['error' => 'Fechas no proporcionadas']);
    exit;
}

switch ($tipo_reporte) {
    case 'general':
        generarReporteGeneral($conexion, $start_date, $end_date);
        break;
    case 'mascotasPerdidas':
        generarReporteMascotasPerdidas($conexion, $start_date, $end_date);
        break;
    case 'mascotasEncontradas':
        generarReporteMascotasEncontradas($conexion, $start_date, $end_date);
        break;
    case 'adopciones':
        generarReporteAdopciones($conexion, $start_date, $end_date);
        break;
    default:
        echo json_encode(['error' => 'Tipo de reporte no válido']);
}

function generarReporteGeneral($conexion, $start_date, $end_date) {
    $sql = "SELECT 
        (SELECT COUNT(*) FROM mascotas WHERE estado = 'perdido' 
         AND fecha_perdida BETWEEN '$start_date' AND '$end_date') as mascotas_perdidas,
        (SELECT COUNT(*) FROM mascotas WHERE estado = 'encontrado'
         AND fecha_perdida BETWEEN '$start_date' AND '$end_date') as mascotas_encontradas,
        (SELECT COUNT(*) FROM mascotas WHERE estado = 'adopcion'
         AND fecha_creacion BETWEEN '$start_date' AND '$end_date') as mascotas_adopcion,
        (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'administrador'
         AND fecha_creacion BETWEEN '$start_date' AND '$end_date') as usuarios_administradores,
        (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'propietario'
         AND fecha_creacion BETWEEN '$start_date' AND '$end_date') as usuarios_propietarios,
        (SELECT COUNT(*) FROM usuarios WHERE tipo_usuario = 'refugio'
         AND fecha_creacion BETWEEN '$start_date' AND '$end_date') as usuarios_refugios";
    
    $result = $conexion->query($sql);
    
    if ($result) {
        $data = $result->fetch_assoc();
        echo json_encode([
            'success' => true,
            'data' => [
                'mascotas_perdidas' => (int)$data['mascotas_perdidas'],
                'mascotas_encontradas' => (int)$data['mascotas_encontradas'],
                'mascotas_adopcion' => (int)$data['mascotas_adopcion'],
                'usuarios_administradores' => (int)$data['usuarios_administradores'],
                'usuarios_propietarios' => (int)$data['usuarios_propietarios'],
                'usuarios_refugios' => (int)$data['usuarios_refugios']
            ]
        ]);
    } else {
        echo json_encode(['error' => 'Error al generar reporte general']);
    }
}

function generarReporteMascotasPerdidas($conexion, $start_date, $end_date) {
    $sql = "SELECT 
        m.nombre AS nombre_mascota,
        m.especie,
        m.raza,
        m.sexo,
        m.fecha_perdida,
        m.lugar_perdida,
        u.nombre AS nombre_propietario,
        u.primerApellido,
        u.segundoApellido,
        u.telefono,
        u.email
    FROM mascotas m
    JOIN usuarios u ON m.usuario_id = u.id
    WHERE m.estado = 'perdido'
    AND m.fecha_perdida BETWEEN '$start_date' AND '$end_date'
    ORDER BY m.fecha_perdida DESC";

    $result = $conexion->query($sql);
    
    if ($result) {
        $mascotas = array();
        while ($row = $result->fetch_assoc()) {
            $mascotas[] = [
                'nombre' => $row['nombre_mascota'],
                'especie' => $row['especie'],
                'raza' => $row['raza'],
                'sexo' => $row['sexo'],
                'fecha_perdida' => $row['fecha_perdida'],
                'lugar_perdida' => $row['lugar_perdida'],
                'nombre_propietario' => $row['nombre_propietario'],
                'primerApellido' => $row['primerApellido'],
                'segundoApellido' => $row['segundoApellido'],
                'telefono' => $row['telefono'],
                'email' => $row['email']
            ];
        }
        echo json_encode([
            'success' => true,
            'data' => ['mascotas' => $mascotas]
        ]);
    } else {
        echo json_encode(['error' => 'Error al generar reporte de mascotas perdidas']);
    }
}

function generarReporteMascotasEncontradas($conexion, $start_date, $end_date) {
    $sql = "SELECT 
        m.nombre AS nombre_mascota,
        m.especie,
        m.raza,
        m.sexo,
        u.nombre AS nombre_encontrador,
        u.primerApellido,
        u.segundoApellido,
        u.telefono,
        u.email
    FROM mascotas m
    INNER JOIN usuarios u ON m.usuario_id = u.id
    WHERE m.estado = 'encontrado' AND m.fecha_creacion BETWEEN '$start_date' AND '$end_date'
    ORDER BY 1 DESC";

    $result = $conexion->query($sql);
    
    if ($result) {
        $mascotas = array();
        while ($row = $result->fetch_assoc()) {
            $mascotas[] = [
                'nombre' => $row['nombre_mascota'],
                'especie' => $row['especie'],
                'raza' => $row['raza'],
                'sexo' => $row['sexo'],
                'nombre_encontrador' => $row['nombre_encontrador'],
                'primerApellido' => $row['primerApellido'],
                'segundoApellido' => $row['segundoApellido'],
                'telefono' => $row['telefono'],
                'email' => $row['email']
            ];
        }
        echo json_encode([
            'success' => true,
            'data' => ['mascotas' => $mascotas]
        ]);
    } else {
        echo json_encode(['error' => 'Error al generar reporte de mascotas encontradas']);
    }
}

function generarReporteAdopciones($conexion, $start_date, $end_date) {
    $sql = "SELECT 
        m.nombre AS nombre_mascota,
        m.especie,
        m.raza,
        m.sexo,
        m.fecha_creacion AS fecha_publicacion,
        u.nombreRefugio AS nombreRefugio,
        u.emailRefugio AS emailRefugio,
        u.ubicacionRefugio AS ubicacionRefugio,
        u.telefonoRefugio AS telefonoRefugio
    FROM mascotas m
    JOIN usuarios u ON m.usuario_id = u.id
    WHERE m.estado = 'adopcion'
    AND m.fecha_creacion BETWEEN '$start_date' AND '$end_date'
    AND u.tipo_usuario = 'refugio'
    ORDER BY m.fecha_creacion DESC";

    $result = $conexion->query($sql);
    
    if ($result) {
        $adopciones = array();
        while ($row = $result->fetch_assoc()) {
            $adopciones[] = [
                'nombre_mascota' => $row['nombre_mascota'],
                'especie' => $row['especie'],
                'raza' => $row['raza'],
                'sexo' => $row['sexo'],
                'fecha_publicacion' => $row['fecha_publicacion'],
                'nombreRefugio' => $row['nombreRefugio'],
                'emailRefugio' => $row['emailRefugio'],
                'ubicacionRefugio' => $row['ubicacionRefugio'],
                'telefonoRefugio' => $row['telefonoRefugio']
            ];
        }
        echo json_encode([
            'success' => true,
            'data' => ['adopciones' => $adopciones]
        ]);
    } else {
        echo json_encode(['error' => 'Error al generar reporte de adopciones']);
    }
}

// Cerrar la conexión a la base de datos
$conexion->close();
?>