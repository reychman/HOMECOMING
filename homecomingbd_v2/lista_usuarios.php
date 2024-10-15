<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once('config.php');

$tipo = isset($_GET['tipo']) ? $_GET['tipo'] : '';

switch ($tipo) {
    case 'propietario':
    case 'administrador':
        $sql = "SELECT id, nombre, primerApellido, segundoApellido, telefono, email, tipo_usuario, estado 
                FROM usuarios 
                WHERE tipo_usuario = ? AND estado = 1";
        $stmt = $conexion->prepare($sql);
        $stmt->bind_param("s", $tipo);
        break;
    case 'refugio':
        $sql = "SELECT id, nombre, primerApellido, segundoApellido, telefono, email, tipo_usuario, 
                        nombreRefugio, emailRefugio, ubicacionRefugio, telefonoRefugio, estado 
                FROM usuarios 
                WHERE tipo_usuario = 'refugio'";
        $stmt = $conexion->prepare($sql);
        break;
    case 'cambiar_estado_refugio':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $id = isset($_POST['id']) ? intval($_POST['id']) : 0;
            $estado = isset($_POST['estado']) ? intval($_POST['estado']) : 0;
            
            if ($id > 0 && ($estado == 1 || $estado == 2)) {
                $sql = "UPDATE usuarios SET estado = ? WHERE id = ? AND tipo_usuario = 'refugio'";
                $stmt = $conexion->prepare($sql);
                $stmt->bind_param("ii", $estado, $id);
                
                if ($stmt->execute()) {
                    echo json_encode(['success' => true, 'message' => 'Estado actualizado correctamente']);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Error al actualizar el estado']);
                }
                $stmt->close();
                $conexion->close();
                exit();
            } else {
                echo json_encode(['success' => false, 'message' => 'Datos inválidos']);
                exit();
            }
        }
        break;
    default:
        echo json_encode(["error" => "Tipo de usuario o acción no válida"]);
        exit();
}

if (isset($stmt) && $stmt) {
    $stmt->execute();
    $result = $stmt->get_result();

    $usuarios = [];
    while ($row = $result->fetch_assoc()) {
        $usuarios[] = $row;
    }

    echo json_encode($usuarios);

    $stmt->close();
}

$conexion->close();
?>