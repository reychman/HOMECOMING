<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once('config.php');

// SQL query to fetch users
$sql = "SELECT id, nombre, primerApellido, segundoApellido, telefono, email, tipo_usuario 
        FROM Usuarios
        WHERE estado=1";
$result = $conexion->query($sql);

$users = array();
if ($result->num_rows > 0) {
    // Output data of each row
    while($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
} else {
    echo json_encode(array('message' => 'No users found'));
    exit();
}

// Close the database conexion
$conexion->close();

// Return the JSON response
echo json_encode($users);
?>
