# Host: localhost:3308  (Version 5.5.5-10.4.22-MariaDB)
# Date: 2024-07-23 15:47:11
# Generator: MySQL-Front 6.0  (Build 2.20)


#
# Structure for table "comentarios"
#

DROP TABLE IF EXISTS `comentarios`;
CREATE TABLE `comentarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reporte_id` int(11) DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `comentario` text NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `reporte_id` (`reporte_id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `comentarios_ibfk_1` FOREIGN KEY (`reporte_id`) REFERENCES `reportes_mascotas_perdidas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `comentarios_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

#
# Data for table "comentarios"
#

INSERT INTO `comentarios` VALUES (1,1,2,'Espero que Firulais aparezca pronto','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(2,2,2,'Si ven a Michi, por favor avisen a su dueña','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(3,3,4,'Roco es un perro muy asustadizo, espero que lo encuentren','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(4,4,1,'Luna es una gata muy cariñosa, seguro que la encontrarán','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(5,5,5,'Max es un perro muy obediente, espero que lo localicen','2024-07-11 08:53:34','2024-07-11 08:53:34',1);

#
# Structure for table "usuarios"
#

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `primerApellido` varchar(100) NOT NULL,
  `segundoApellido` varchar(100) DEFAULT NULL,
  `telefono` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `tipo_usuario` enum('administrador','propietario','refugio') NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4;

#
# Data for table "usuarios"
#

INSERT INTO `usuarios` VALUES (1,'Juan','carballo','ugarte','21312312','juan.carballo@example.com','0f3fde0103dd44077c040215a2fabd09a097aecc','administrador','2024-07-11 08:53:34','2024-07-23 15:21:08',1),(2,'Maria','López','Rodríguez','2222222','maria.lopez@example.com','c84f35f9f4de4c55d6e68cdf5c1d4ae0f255cd65','propietario','2024-07-11 08:53:34','2024-07-23 09:56:07',1),(3,'Carlos','Martínez','Gómez','456123789','carlos.martinez@example.com','1fb10b98df5e0c7df18c82924fdad0ff97514bab','refugio','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(4,'Ana','González','Fernández','321654987','ana.gonzalez@example.com','pets','propietario','2024-07-11 08:53:34','2024-07-22 20:16:55',1),(5,'Luis','Ramírez','Hernández','789123456','luis.ramirez@example.com','0f3fde0103dd44077c040215a2fabd09a097aecc','administrador','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(7,'Usuario2','Modificado2','Correctamente2','2222222','modificado2@gmail.com','0f3fde0103dd44077c040215a2fabd09a097aecc','propietario','2024-07-15 16:29:09','2024-07-16 15:55:16',1),(11,'leylacris','apazacar','carballoapaz','12191514','cristo.apaza@example.com','0f3fde0103dd44077c040215a2fabd09a097aecc','administrador','2024-07-15 23:30:21','2024-07-19 10:59:05',1),(12,'rey','Pérez','García','4512145','rey.perez@example.com','hola123','propietario','2024-07-15 23:31:51','2024-07-23 09:13:32',0),(13,'usuario','prueba','segunda','6398995587','reychmasjs@gmail.com','0f3fde0103dd44077c040215a2fabd09a097aecc','propietario','2024-07-16 00:43:14','2024-07-16 17:00:28',0),(19,'claudia','Torres','Apaza','3211564456','clau@gmai.com','568095ee7b98b0afceb32540a1ca5540eaa72666','propietario','2024-07-16 17:03:34','2024-07-16 18:47:25',0),(20,'massiel ','carballo','choque','12345678','ejemplo@gmail.com','0f3fde0103dd44077c040215a2fabd09a097aecc','propietario','2024-07-19 11:00:41','2024-07-23 10:08:05',1),(21,'refugio','refugio','refugio','4545454545454','refugio@gmail.com','ab02528f9cb0420bede260fc13def48cde85a6f2','refugio','2024-07-19 14:32:20','2024-07-22 18:50:25',1),(22,'prueba','modificada','modificada','5444545654','reyhc@gmail.com','0f3fde0103dd44077c040215a2fabd09a097aecc','propietario','2024-07-22 15:13:10','2024-07-22 15:14:46',0);

#
# Structure for table "registro_actividades"
#

DROP TABLE IF EXISTS `registro_actividades`;
CREATE TABLE `registro_actividades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `accion` text NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `registro_actividades_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

#
# Data for table "registro_actividades"
#

INSERT INTO `registro_actividades` VALUES (1,1,'Creó un reporte de mascota perdida','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(2,2,'Actualizó la información de un refugio','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(3,3,'Registró un nuevo refugio','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(4,4,'Adoptó una mascota','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(5,5,'Reportó una mascota perdida','2024-07-11 08:53:34','2024-07-11 08:53:34',1);

#
# Structure for table "refugios"
#

DROP TABLE IF EXISTS `refugios`;
CREATE TABLE `refugios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `ubicacion` varchar(255) DEFAULT NULL,
  `telefono` varchar(100) DEFAULT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `refugios_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

#
# Data for table "refugios"
#

INSERT INTO `refugios` VALUES (1,'Refugio de Mascotas','Calle Principal 123','987654321',3,'2024-07-11 08:53:34','2024-07-11 08:53:34',1),(2,'Hogar de Peluditos','Avenida Central 456','456789123',3,'2024-07-11 08:53:34','2024-07-11 08:53:34',1);

#
# Structure for table "notificaciones"
#

DROP TABLE IF EXISTS `notificaciones`;
CREATE TABLE `notificaciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `mensaje` text NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `leido` enum('si','no') DEFAULT 'no',
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

#
# Data for table "notificaciones"
#

INSERT INTO `notificaciones` VALUES (1,2,'Tu mascota Firulais ha sido encontrada','2024-07-11 08:53:34','no','2024-07-11 08:53:34',1),(2,2,'Michi ha sido adoptada','2024-07-11 08:53:34','no','2024-07-11 08:53:34',1),(3,4,'Roco ha sido llevado al refugio','2024-07-11 08:53:34','no','2024-07-11 08:53:34',1),(4,1,'Luna ha sido encontrada','2024-07-11 08:53:34','no','2024-07-11 08:53:34',1),(5,5,'Max ha sido llevado al refugio','2024-07-11 08:53:34','no','2024-07-11 08:53:34',1);

#
# Structure for table "mascotas"
#

DROP TABLE IF EXISTS `mascotas`;
CREATE TABLE `mascotas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `especie` enum('perro','gato') NOT NULL,
  `raza` varchar(100) DEFAULT NULL,
  `edad` int(11) DEFAULT NULL,
  `sexo` enum('hembra','macho') NOT NULL,
  `color` varchar(100) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `propietario_id` int(11) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `propietario_id` (`propietario_id`),
  CONSTRAINT `mascotas_ibfk_1` FOREIGN KEY (`propietario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

#
# Data for table "mascotas"
#

INSERT INTO `mascotas` VALUES (1,'Firulais','perro','Labrador',5,'macho','negro','Perro muy juguetón','firulais.jpg',2,'2024-07-11 08:53:34','2024-07-11 08:53:34',1),(2,'Michi','gato','Siamés',3,'hembra','blanco y gris','Gato muy cariñoso','michi.jpg',2,'2024-07-11 08:53:34','2024-07-11 08:53:34',1),(3,'Roco','perro','Bulldog',2,'macho','blanco y marrón','Perro muy protector','roco.jpg',4,'2024-07-11 08:53:34','2024-07-11 08:53:34',1),(4,'Luna','gato','Persa',1,'hembra','blanco','Gato muy elegante','luna.jpg',1,'2024-07-11 08:53:34','2024-07-11 08:53:34',1),(5,'Max','perro','Pastor Alemán',4,'macho','negro y marrón','Perro muy inteligente','max.jpg',5,'2024-07-11 08:53:34','2024-07-11 08:53:34',1);

#
# Structure for table "reportes_mascotas_perdidas"
#

DROP TABLE IF EXISTS `reportes_mascotas_perdidas`;
CREATE TABLE `reportes_mascotas_perdidas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mascota_id` int(11) DEFAULT NULL,
  `fecha_perdida` date NOT NULL,
  `lugar_perdida` varchar(255) NOT NULL,
  `detalles_adicionales` text DEFAULT NULL,
  `estado` enum('perdido','encontrado') DEFAULT 'perdido',
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado_registro` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `mascota_id` (`mascota_id`),
  CONSTRAINT `reportes_mascotas_perdidas_ibfk_1` FOREIGN KEY (`mascota_id`) REFERENCES `mascotas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

#
# Data for table "reportes_mascotas_perdidas"
#

INSERT INTO `reportes_mascotas_perdidas` VALUES (1,1,'2023-05-15','Parque Central','Firulais se escapó mientras paseaba con su dueño','perdido','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(2,2,'2023-06-01','Calle Principal','Michi salió de casa y no ha regresado','perdido','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(3,3,'2023-07-01','Barrio Residencial','Roco se asustó con los fuegos artificiales y huyó','perdido','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(4,4,'2023-08-01','Plaza del Centro','Luna salió por la ventana y no la encuentran','perdido','2024-07-11 08:53:34','2024-07-11 08:53:34',1),(5,5,'2023-09-01','Bosque Urbano','Max se perdió durante una caminata','perdido','2024-07-11 08:53:34','2024-07-11 08:53:34',1);

#
# Structure for table "adopciones"
#

DROP TABLE IF EXISTS `adopciones`;
CREATE TABLE `adopciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mascota_id` int(11) DEFAULT NULL,
  `refugio_id` int(11) DEFAULT NULL,
  `fecha_adopcion` date NOT NULL,
  `adoptante_id` int(11) DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_modificacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `mascota_id` (`mascota_id`),
  KEY `refugio_id` (`refugio_id`),
  KEY `adoptante_id` (`adoptante_id`),
  CONSTRAINT `adopciones_ibfk_1` FOREIGN KEY (`mascota_id`) REFERENCES `mascotas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `adopciones_ibfk_2` FOREIGN KEY (`refugio_id`) REFERENCES `refugios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `adopciones_ibfk_3` FOREIGN KEY (`adoptante_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;

#
# Data for table "adopciones"
#

INSERT INTO `adopciones` VALUES (1,1,1,'2023-06-30',4,'2024-07-11 08:53:34','2024-07-11 08:53:34',1),(2,2,2,'2023-07-15',2,'2024-07-11 08:53:34','2024-07-11 08:53:34',1),(3,4,1,'2023-08-15',1,'2024-07-11 08:53:34','2024-07-11 08:53:34',1),(4,5,2,'2023-09-30',5,'2024-07-11 08:53:34','2024-07-11 08:53:34',1);
