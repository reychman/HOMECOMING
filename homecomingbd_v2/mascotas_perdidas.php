<?php
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    include 'config.php';

    // Manejo de errores de conexión

    if ($conexion->connect_error) {
        die("Connection failed: " . $conexion->connect_error);
    }

    $sql = "SELECT * FROM Reportes_Mascotas_Perdidas";
    $result = $conexion->query($sql);

    $lostPets = [];

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $lostPets[] = $row;
        }
    }

    echo json_encode($lostPets);

    $conexion->close();
?>