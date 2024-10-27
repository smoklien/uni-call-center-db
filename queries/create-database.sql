DROP DATABASE IF EXISTS `callcenter`;
CREATE DATABASE IF NOT EXISTS `callcenter`;
USE `callcenter`;

SET foreign_key_checks = 0;

CREATE TABLE `contact_info` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `number` varchar(15) UNIQUE NOT NULL,
  `email` varchar(100) UNIQUE
);

CREATE TABLE `customer` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `contact_info_id` int UNIQUE NOT NULL,
  
  FOREIGN KEY (`contact_info_id`) REFERENCES `contact_info` (`id`)
);

CREATE TABLE `staff` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `salary` DECIMAL(7, 2) NOT NULL,
  `hire_date` DATE NOT NULL,
  `contact_info_id` INT UNIQUE NOT NULL,
  
  CHECK (`salary` > 0),
  
  FOREIGN KEY (`contact_info_id`) REFERENCES `contact_info` (`id`)
);

CREATE TABLE `supervisor` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `staff_id` int UNIQUE NOT NULL,
  
  FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`)
);

CREATE TABLE `agent` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `staff_id` int UNIQUE NOT NULL,
  `supervisor_id` int NOT NULL,
  
  FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`),
  FOREIGN KEY (`supervisor_id`) REFERENCES `supervisor` (`id`)
);

CREATE TABLE `feedback` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `rating` enum('1','2','3','4','5') NOT NULL,
  `comments` text(1000),
  `customer_id` int NOT NULL,
  `agent_id` int NOT NULL,
  
  FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`),
  FOREIGN KEY (`agent_id`) REFERENCES `agent` (`id`)
);

CREATE TABLE `issue` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `description` varchar(255) NOT NULL
);

CREATE TABLE `service` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `price` decimal(6, 2) NOT NULL,
  
  CHECK (`price` >=0 )
);

CREATE TABLE `call` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `start_at` timestamp NOT NULL,
  `end_at` timestamp NOT NULL DEFAULT current_timestamp,
  `customer_id` int NOT NULL,
  `agent_id` int NOT NULL,
  
  CHECK ((TIMESTAMPDIFF(SECOND, `start_at`, `end_at`) <= 7200)),
  CHECK (`start_at` <= `end_at`),
  
  FOREIGN KEY (`customer_id`) REFERENCES `customer` (`id`),
  FOREIGN KEY (`agent_id`) REFERENCES `agent` (`id`)
);

CREATE TABLE `call_issue` (
  `call_id` int NOT NULL,
  `issue_id` int NOT NULL,
  
  PRIMARY KEY (`call_id`, `issue_id`),
  FOREIGN KEY (`call_id`) REFERENCES `call` (`id`),
  FOREIGN KEY (`issue_id`) REFERENCES `issue` (`id`)
);

CREATE TABLE `call_service` (
  `call_id` int NOT NULL,
  `service_id` int NOT NULL,
  
  PRIMARY KEY (`call_id`, `service_id`),
  FOREIGN KEY (`call_id`) REFERENCES `call` (`id`),
  FOREIGN KEY (`service_id`) REFERENCES `service` (`id`)
);