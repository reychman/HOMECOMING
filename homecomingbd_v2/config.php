<?php
    // Datos de conexión a la base de datos
    $hostname = 'localhost:3309'; // Host donde está alojada la base de datos (generalmente localhost)
    $username = 'root';      // Usuario de la base de datos (por ejemplo, root)
    $password = '';          // Contraseña del usuario de la base de datos
    $database = 'homecoming_v1'; // Nombre de la base de datos a la que te quieres conectar

    // Crear conexión
    $conexion = new mysqli($hostname, $username, $password, $database);

    // Verificar la conexión
    if ($conexion->connect_error) {
        die("Connection failed: " . $conexion->connect_error);
    }
?>