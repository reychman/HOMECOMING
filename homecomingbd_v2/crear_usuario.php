<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization');
header('Content-Type: application/json');

// Incluir configuración de la base de datos
require_once('config.php');

// Verificar la conexión a la base de datos
if ($conexion->connect_error) {
    echo json_encode(array('error' => 'Error de conexión a la base de datos: ' . $conexion->connect_error));
    exit();
}

// Obtener los datos del POST
$nombre = strtoupper($_POST['nombre']);
$primerApellido = strtoupper($_POST['primerApellido']);
$segundoApellido = strtoupper($_POST['segundoApellido']);
$telefono = $_POST['telefono'];
$email = $_POST['email'];
$contrasena = $_POST['contrasena']; // Asegúrate de que la contraseña llegue ya encriptada con SHA-1
$tipo_usuario = $_POST['tipo_usuario'];

// Inicializar variables para los datos del refugio
$nombreRefugio = isset($_POST['nombreRefugio']) ? $_POST['nombreRefugio'] : null;
$emailRefugio = isset($_POST['emailRefugio']) ? $_POST['emailRefugio'] : null;
$ubicacionRefugio = isset($_POST['ubicacionRefugio']) ? $_POST['ubicacionRefugio'] : null;
$telefonoRefugio = isset($_POST['telefonoRefugio']) ? $_POST['telefonoRefugio'] : null;

// Validar que los campos obligatorios no estén vacíos
if (empty($nombre) || empty($primerApellido) || empty($telefono) || empty($email) || empty($contrasena) || empty($tipo_usuario)) {
    echo json_encode(array('error' => 'Todos los campos son obligatorios'));
    exit();
}

// Validaciones adicionales si el tipo de usuario es refugio
if ($tipo_usuario == 'refugio') {
    if (empty($nombreRefugio) || empty($emailRefugio) || empty($ubicacionRefugio) || empty($telefonoRefugio)) {
        echo json_encode(array('error' => 'Todos los campos del refugio son obligatorios'));
        exit();
    }
}

// Validar si el usuario ya existe
$sql = "SELECT id FROM Usuarios WHERE email = ?";
$stmt = $conexion->prepare($sql);

if (!$stmt) {
    echo json_encode(array('error' => 'Error en la preparación de la consulta de verificación: ' . $conexion->error));
    exit();
}

$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    echo json_encode(array('error' => 'El usuario ya existe'));
    $stmt->close();
    exit();
}

// Insertar el nuevo usuario en la base de datos
if ($tipo_usuario == 'propietario') {
    // Si es un propietario, el estado es 1 (activo)
    $sql = "INSERT INTO Usuarios (nombre, primerApellido, segundoApellido, telefono, email, contrasena, tipo_usuario, fecha_creacion, estado) 
            VALUES (?, ?, ?, ?, ?, ?, ?, Now(), 1)";
    $stmt = $conexion->prepare($sql);

    if (!$stmt) {
        echo json_encode(array('error' => 'Error en la preparación de la consulta de inserción: ' . $conexion->error));
        exit();
    }

    $stmt->bind_param("sssssss", $nombre, $primerApellido, $segundoApellido, $telefono, $email, $contrasena, $tipo_usuario);

} else if ($tipo_usuario == 'refugio') {
    // Si es un refugio, el estado es 0 (inactivo)
    $sql = "INSERT INTO Usuarios (nombre, primerApellido, segundoApellido, telefono, email, contrasena, tipo_usuario, nombreRefugio, emailRefugio, ubicacionRefugio, telefonoRefugio, fecha_creacion, estado) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, Now(), 0)";
    $stmt = $conexion->prepare($sql);

    if (!$stmt) {
        echo json_encode(array('error' => 'Error en la preparación de la consulta de inserción: ' . $conexion->error));
        exit();
    }

    $stmt->bind_param("sssssssssss", $nombre, $primerApellido, $segundoApellido, $telefono, $email, $contrasena, $tipo_usuario, $nombreRefugio, $emailRefugio, $ubicacionRefugio, $telefonoRefugio);
}

if ($stmt->execute()) {
    echo json_encode(array('success' => true));
} else {
    echo json_encode(array('error' => 'Error al crear el usuario: ' . $stmt->error));
}

$stmt->close();
$conexion->close();
?>
