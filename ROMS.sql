-- MySQL dump 10.13  Distrib 8.0.29, for Linux (x86_64)
--
-- Host: omied.mysql.pythonanywhere-services.com    Database: omied$schema
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Customer`
--

DROP TABLE IF EXISTS `Customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Customer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Customer`
--

LOCK TABLES `Customer` WRITE;
/*!40000 ALTER TABLE `Customer` DISABLE KEYS */;
INSERT INTO `Customer` VALUES (1,'khar','83456839','dkjfbkla'),(2,'syia','1234567890','2094 Bay St'),(3,'syia','1234567890','2094 Bay St'),(4,'syia','1234567890','2094 Bay St'),(5,'khar gaw','9843539','2200 Bay St'),(6,'h1','83475','bay1'),(7,'omied1','394875','kjfa'),(8,'omied1','394875','kjfa'),(9,'kjdsv','4353','jdfdk'),(10,'gaw','3498573','djkghdkfjv'),(11,'Owen','41655678990','Bay St'),(12,'skdjbv','384579','dskjbs'),(13,'skdjbv','384579','dskjbs'),(14,'jkdlvkjd','8943798','dkjfvbskd'),(15,'kjerljkfe','387563984','djkbsvlkj'),(16,'sdbvjjds','438975','djkcbldskj'),(17,'munir','6474223333','123 simcoe road'),(18,'roger','38834574','slhfsduif'),(19,'kfnvkjdf','34865438','ejfbehjdfv'),(20,'James','82364832','efbhbskj'),(21,'john','6477778888','2000 simcoe street'),(22,'johnson','416000444','452 taunton road'),(23,'ksdfbkjs','38454398','384583');
/*!40000 ALTER TABLE `Customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MenuItem`
--

DROP TABLE IF EXISTS `MenuItem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MenuItem` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MenuItem`
--

LOCK TABLES `MenuItem` WRITE;
/*!40000 ALTER TABLE `MenuItem` DISABLE KEYS */;
INSERT INTO `MenuItem` VALUES (1,'Margherita Pizza','Pizza with tomatoes, mozzarella, and basil',8.99,1),(2,'Pepperoni Pizza','Pizza with pepperoni and extra cheese',9.99,1),(3,'Cheeseburger','Burger with a beef patty, cheese, lettuce, and tomato',7.49,0),(4,'Caesar Salad','Fresh romaine lettuce with Caesar dressing and croutons',6.99,1),(7,'Poutine ','French fries, cheese curds topped with a brown gravy',8.79,1),(8,'French Fries','Potatoes fried and lightly salted ',2.99,1),(10,'Saratoga Water','Saratoga Water is a naturally carbonated mineral water from Saratoga Springs, known for its crisp and refreshing taste.',6.99,1),(14,'Hawaiian Pizza','Pizza topped with pineapples',10.00,0),(15,'Hawaiian Pizza','Pizza topped with pineapples',10.99,1);
/*!40000 ALTER TABLE `MenuItem` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `OrderDetail`
--

DROP TABLE IF EXISTS `OrderDetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `OrderDetail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `menu_item_id` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `menu_item_id` (`menu_item_id`),
  CONSTRAINT `OrderDetail_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `Orders` (`id`),
  CONSTRAINT `OrderDetail_ibfk_2` FOREIGN KEY (`menu_item_id`) REFERENCES `MenuItem` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `OrderDetail`
--

LOCK TABLES `OrderDetail` WRITE;
/*!40000 ALTER TABLE `OrderDetail` DISABLE KEYS */;
INSERT INTO `OrderDetail` VALUES (1,1,1,3),(2,1,2,2),(3,1,3,2),(4,1,4,2);
/*!40000 ALTER TABLE `OrderDetail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Orders`
--

DROP TABLE IF EXISTS `Orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `total` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `Orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `Customer` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Orders`
--

LOCK TABLES `Orders` WRITE;
/*!40000 ALTER TABLE `Orders` DISABLE KEYS */;
INSERT INTO `Orders` VALUES (1,1,'2025-04-01 17:26:32',75.91),(2,2,'2025-04-01 17:41:09',17.98),(3,3,'2025-04-01 17:46:54',0.00),(4,4,'2025-04-01 17:49:45',0.00),(5,5,'2025-04-01 17:53:30',26.97),(6,6,'2025-04-01 18:00:26',7.49),(7,7,'2025-04-01 18:07:09',18.98),(8,8,'2025-04-01 18:15:10',0.00),(9,9,'2025-04-01 18:22:25',17.98),(10,10,'2025-04-01 21:06:07',10.87),(11,11,'2025-04-01 22:37:30',18.36),(12,12,'2025-04-01 22:38:09',23.97),(13,13,'2025-04-01 22:51:54',0.00),(14,14,'2025-04-01 23:01:42',7.99),(15,15,'2025-04-01 23:07:51',19.19),(16,16,'2025-04-01 23:19:18',18.06),(17,17,'2025-04-02 23:40:14',0.00),(18,18,'2025-04-02 23:48:42',18.06),(19,19,'2025-04-03 00:06:28',27.09),(20,20,'2025-04-03 15:44:05',59.02),(21,21,'2025-04-03 23:55:38',18.06),(22,22,'2025-04-04 01:05:30',0.00),(23,23,'2025-04-04 01:58:03',20.32);
/*!40000 ALTER TABLE `Orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Payment`
--

DROP TABLE IF EXISTS `Payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Payment` (
  `PaymentID` int NOT NULL AUTO_INCREMENT,
  `OrderID` int NOT NULL,
  `PaymentMethod` varchar(50) DEFAULT NULL,
  `Amount_paid` decimal(10,2) DEFAULT NULL,
  `PaymentLocation` varchar(50) DEFAULT NULL,
  `CardNumber` varchar(20) DEFAULT NULL,
  `CardExpiry` varchar(10) DEFAULT NULL,
  `CardCVV` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`PaymentID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `Payment_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `Orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Payment`
--

LOCK TABLES `Payment` WRITE;
/*!40000 ALTER TABLE `Payment` DISABLE KEYS */;
INSERT INTO `Payment` VALUES (1,9,'credit',17.98,'Online',NULL,NULL,NULL),(2,10,'credit',10.87,'Online',NULL,NULL,NULL),(3,16,'credit',18.06,'Online','4836383489','05/27','078'),(4,17,'credit',0.00,'Online','123456789123','02/28','212'),(5,18,'credit',18.06,'Online','384653784','05/27','078'),(6,19,'credit',27.09,'Online','348568437589','05/27','078'),(7,20,'credit',59.02,'Online','3847658734','05/27','078'),(8,21,'credit',18.06,'Online','1111222233334444','02/26','111'),(9,22,'credit',0.00,'Online','1234123412341234','02/28','888'),(10,23,'credit',20.32,'Online','384598437','07/27','078');
/*!40000 ALTER TABLE `Payment` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-04  2:10:41
