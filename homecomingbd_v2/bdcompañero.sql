CREATE DATABASE  IF NOT EXISTS `homecomingbd_v2` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `homecomingbd_v2`;
-- MySQL dump 10.13  Distrib 8.0.36, for macos14 (arm64)
--
-- Host: localhost    Database: homecomingbd_v2
-- ------------------------------------------------------
-- Server version	8.0.35

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Adopciones`
--

DROP TABLE IF EXISTS `Adopciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Adopciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mascota_id` int NOT NULL,
  `refugio_id` int NOT NULL,
  `fecha_adopcion` date DEFAULT NULL,
  `adoptante_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mascota_id` (`mascota_id`),
  KEY `refugio_id` (`refugio_id`),
  KEY `adoptante_id` (`adoptante_id`),
  CONSTRAINT `adopciones_ibfk_1` FOREIGN KEY (`mascota_id`) REFERENCES `Mascotas` (`id`),
  CONSTRAINT `adopciones_ibfk_2` FOREIGN KEY (`refugio_id`) REFERENCES `Refugios` (`id`),
  CONSTRAINT `adopciones_ibfk_3` FOREIGN KEY (`adoptante_id`) REFERENCES `Usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Adopciones`
--

LOCK TABLES `Adopciones` WRITE;
/*!40000 ALTER TABLE `Adopciones` DISABLE KEYS */;
INSERT INTO `Adopciones` VALUES (1,1,1,'2023-06-30',4),(2,2,2,'2023-07-15',2),(3,4,1,'2023-08-15',1),(4,5,2,'2023-09-30',5);
/*!40000 ALTER TABLE `Adopciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Comentarios`
--

DROP TABLE IF EXISTS `Comentarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Comentarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `reporte_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `comentario` text,
  PRIMARY KEY (`id`),
  KEY `reporte_id` (`reporte_id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `comentarios_ibfk_1` FOREIGN KEY (`reporte_id`) REFERENCES `Reportes_Mascotas_Perdidas` (`id`),
  CONSTRAINT `comentarios_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Comentarios`
--

LOCK TABLES `Comentarios` WRITE;
/*!40000 ALTER TABLE `Comentarios` DISABLE KEYS */;
INSERT INTO `Comentarios` VALUES (1,1,2,'Espero que Firulais aparezca pronto'),(2,2,2,'Si ven a Michi, por favor avisen a su dueña'),(3,3,4,'Roco es un perro muy asustadizo, espero que lo encuentren'),(4,4,1,'Luna es una gata muy cariñosa, seguro que la encontrarán'),(5,5,5,'Max es un perro muy obediente, espero que lo localicen');
/*!40000 ALTER TABLE `Comentarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Mascotas`
--

DROP TABLE IF EXISTS `Mascotas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Mascotas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `especie` varchar(50) NOT NULL,
  `raza` varchar(50) DEFAULT NULL,
  `edad` int DEFAULT NULL,
  `sexo` enum('macho','hembra') DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `descripcion` text,
  `foto` varchar(100) DEFAULT NULL,
  `propietario_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `propietario_id` (`propietario_id`),
  CONSTRAINT `mascotas_ibfk_1` FOREIGN KEY (`propietario_id`) REFERENCES `Usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Mascotas`
--

LOCK TABLES `Mascotas` WRITE;
/*!40000 ALTER TABLE `Mascotas` DISABLE KEYS */;
INSERT INTO `Mascotas` VALUES (1,'Firulais','perro','Labrador',5,'macho','negro','Perro muy juguetón','firulais.jpg',2),(2,'Michi','gato','Siamés',3,'hembra','blanco y gris','Gato muy cariñoso','michi.jpg',2),(3,'Roco','perro','Bulldog',2,'macho','blanco y marrón','Perro muy protector','roco.jpg',4),(4,'Luna','gato','Persa',1,'hembra','blanco','Gato muy elegante','luna.jpg',1),(5,'Max','perro','Pastor Alemán',4,'macho','negro y marrón','Perro muy inteligente','max.jpg',5);
/*!40000 ALTER TABLE `Mascotas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Notificaciones`
--

DROP TABLE IF EXISTS `Notificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Notificaciones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `mensaje` text,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Notificaciones`
--

LOCK TABLES `Notificaciones` WRITE;
/*!40000 ALTER TABLE `Notificaciones` DISABLE KEYS */;
INSERT INTO `Notificaciones` VALUES (1,2,'Tu mascota Firulais ha sido encontrada'),(2,2,'Michi ha sido adoptada'),(3,4,'Roco ha sido llevado al refugio'),(4,1,'Luna ha sido encontrada'),(5,5,'Max ha sido llevado al refugio');
/*!40000 ALTER TABLE `Notificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Refugios`
--

DROP TABLE IF EXISTS `Refugios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Refugios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `ubicacion` varchar(200) DEFAULT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `usuario_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `refugios_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Refugios`
--

LOCK TABLES `Refugios` WRITE;
/*!40000 ALTER TABLE `Refugios` DISABLE KEYS */;
INSERT INTO `Refugios` VALUES (1,'Refugio de Mascotas','Calle Principal 123','987654321',3),(2,'Hogar de Peluditos','Avenida Central 456','456789123',3);
/*!40000 ALTER TABLE `Refugios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Registro_Actividades`
--

DROP TABLE IF EXISTS `Registro_Actividades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Registro_Actividades` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `accion` text,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `registro_actividades_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `Usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Registro_Actividades`
--

LOCK TABLES `Registro_Actividades` WRITE;
/*!40000 ALTER TABLE `Registro_Actividades` DISABLE KEYS */;
INSERT INTO `Registro_Actividades` VALUES (1,1,'Creó un reporte de mascota perdida'),(2,2,'Actualizó la información de un refugio'),(3,3,'Registró un nuevo refugio'),(4,4,'Adoptó una mascota'),(5,5,'Reportó una mascota perdida');
/*!40000 ALTER TABLE `Registro_Actividades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Reportes_Mascotas_Perdidas`
--

DROP TABLE IF EXISTS `Reportes_Mascotas_Perdidas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Reportes_Mascotas_Perdidas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mascota_id` int NOT NULL,
  `fecha_perdida` date NOT NULL,
  `lugar_perdida` varchar(100) DEFAULT NULL,
  `detalles_adicionales` text,
  PRIMARY KEY (`id`),
  KEY `mascota_id` (`mascota_id`),
  CONSTRAINT `reportes_mascotas_perdidas_ibfk_1` FOREIGN KEY (`mascota_id`) REFERENCES `Mascotas` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Reportes_Mascotas_Perdidas`
--

LOCK TABLES `Reportes_Mascotas_Perdidas` WRITE;
/*!40000 ALTER TABLE `Reportes_Mascotas_Perdidas` DISABLE KEYS */;
INSERT INTO `Reportes_Mascotas_Perdidas` VALUES (1,1,'2023-05-15','Parque Central','Firulais se escapó mientras paseaba con su dueño'),(2,2,'2023-06-01','Calle Principal','Michi salió de casa y no ha regresado'),(3,3,'2023-07-01','Barrio Residencial','Roco se asustó con los fuegos artificiales y huyó'),(4,4,'2023-08-01','Plaza del Centro','Luna salió por la ventana y no la encuentran'),(5,5,'2023-09-01','Bosque Urbano','Max se perdió durante una caminata');
/*!40000 ALTER TABLE `Reportes_Mascotas_Perdidas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Usuarios`
--

DROP TABLE IF EXISTS `Usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `primerApellido` varchar(50) NOT NULL,
  `segundoApellido` varchar(50) NOT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `contrasena` char(40) NOT NULL,
  `tipo_usuario` enum('administrador','propietario','refugio') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Usuarios`
--

LOCK TABLES `Usuarios` WRITE;
/*!40000 ALTER TABLE `Usuarios` DISABLE KEYS */;
INSERT INTO `Usuarios` VALUES (1,'Juan','Pérez','García','123456789','juan.perez@example.com','0f3fde0103dd44077c040215a2fabd09a097aecc','administrador'),(2,'María','López','Rodríguez','987654321','maria.lopez@example.com','c84f35f9f4de4c55d6e68cdf5c1d4ae0f255cd65','propietario'),(3,'Carlos','Martínez','Gómez','456123789','carlos.martinez@example.com','1fb10b98df5e0c7df18c82924fdad0ff97514bab','refugio'),(4,'Ana','González','Fernández','321654987','ana.gonzalez@example.com','8cb2237d0679ca88db6464eac60da96345513964','propietario'),(5,'Luis','Ramírez','Hernández','789123456','luis.ramirez@example.com','0f3fde0103dd44077c040215a2fabd09a097aecc','administrador');
/*!40000 ALTER TABLE `Usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-07-10 22:39:25
