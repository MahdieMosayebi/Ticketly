-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 22, 2026 at 09:57 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ticketly`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CalculateTaxAndUpdate` (IN `travel_id` INT, IN `tax_rate` DECIMAL(5,2))   BEGIN
    DECLARE original_price INT;  -- قیمت اصلی سفر
    DECLARE tax_amount INT;      -- مبلغ مالیات
    DECLARE final_price INT;      -- قیمت نهایی با مالیات
    
    SELECT price INTO original_price 
    FROM travel 
    WHERE idt = travel_id;
    
    SET tax_amount = original_price * (tax_rate / 100);
    SET final_price = original_price + tax_amount;
    
    UPDATE travel 
    SET price = final_price 
    WHERE idt = travel_id;
    
    SELECT 
        travel_id AS شناسه_سفر,
        original_price AS قیمت_قبل_از_مالیات,
        tax_rate AS نرخ_مالیات,
        tax_amount AS مبلغ_مالیات,
        final_price AS قیمت_بعد_از_مالیات,
        'قیمت به‌روز شد' AS وضعیت;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CountReserves` (IN `mid` INT, OUT `total` INT)   BEGIN
    SELECT COUNT(*) INTO total FROM reserve WHERE mosafer_id = mid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeletePassenger` (IN `mid` INT)   BEGIN
    DELETE payment FROM payment 
    JOIN reserve ON payment.reserve_id = reserve.idr 
    WHERE reserve.mosafer_id = mid;
    
    DELETE FROM reserve WHERE reserve.mosafer_id = mid;
    DELETE FROM passenger WHERE passenger.id_mosafer = mid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FindPassenger` (IN `cm` CHAR(10))   BEGIN
    SELECT * FROM passenger WHERE codemeli_mosafer = cm;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CalculateDiscount` (`passenger_id` INT, `months_interval` INT, `discount_rate` DECIMAL(5,2)) RETURNS DECIMAL(5,2) DETERMINISTIC BEGIN
    DECLARE reg_date DATE;
    DECLARE months_diff INT;
    DECLARE discount_percent DECIMAL(5,2);
    SELECT register_date INTO reg_date
    FROM passenger 
    WHERE id_mosafer = passenger_id;
    IF reg_date IS NULL THEN
        RETURN 0;
    END IF;
    SET months_diff = TIMESTAMPDIFF(MONTH, reg_date, CURDATE());
    SET discount_percent = FLOOR(months_diff / months_interval) * discount_rate;
    
    IF discount_percent > 50 THEN
        SET discount_percent = 50;
    END IF;
    RETURN discount_percent;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE `company` (
  `idc` int(11) NOT NULL,
  `namec` varchar(50) DEFAULT NULL,
  `typec` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`idc`, `namec`, `typec`) VALUES
(1, 'ایران ایر', 'هواپیمایی'),
(2, 'ماهان', 'هواپیمایی'),
(3, 'آسمان', 'هواپیمایی'),
(4, 'قشم ایر', 'هواپیمایی'),
(5, 'رجا', 'ریلی'),
(6, 'فدک', 'ریلی'),
(7, 'نورالرضا', 'ریلی'),
(8, 'بن ریل', 'ریلی'),
(9, 'سپهران', 'هواپیمایی'),
(10, 'کاسپین', 'هواپیمایی');

-- --------------------------------------------------------

--
-- Table structure for table `passenger`
--

CREATE TABLE `passenger` (
  `id_mosafer` int(11) NOT NULL,
  `namem` varchar(30) DEFAULT NULL,
  `familym` varchar(50) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `codemeli_mosafer` char(10) DEFAULT NULL,
  `passportnum` char(11) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `register_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

--
-- Dumping data for table `passenger`
--

INSERT INTO `passenger` (`id_mosafer`, `namem`, `familym`, `gender`, `birthdate`, `codemeli_mosafer`, `passportnum`, `email`, `register_date`) VALUES
(1, 'محمد', 'رضایی', 'مرد', '2001-01-08', '1234567890', 'A111111111', NULL, '2026-01-15'),
(2, 'زهرا', 'کاظمی', 'زن', '1999-08-15', '2234567890', 'A222222222', NULL, '2026-02-20'),
(3, 'امیر', 'حسینی', 'مرد', '2000-12-20', '3234567890', 'A333333333', NULL, '2026-01-10'),
(4, 'سارا', 'مرادی', 'زن', '1998-02-11', '4234567890', 'A444444444', NULL, '2026-03-05'),
(5, 'علی', 'اکبری', 'مرد', '2002-07-09', '5234567890', 'A555555555', NULL, '2025-01-15'),
(6, 'نیلوفر', 'عباسی', 'زن', '1997-09-30', '6234567890', 'A666666666', NULL, '2026-05-01'),
(7, 'رضا', 'رحیمی', 'مرد', '1995-01-14', '7234567890', 'A777777777', NULL, '2026-02-12'),
(8, 'مریم', 'قاسمی', 'زن', '2003-03-18', '8234567890', 'A888888888', NULL, '2026-04-20'),
(9, 'حسین', 'کریمی', 'مرد', '1996-11-25', '9234567890', 'A999999999', NULL, '2026-06-01'),
(15, 'سارینا', 'کریمی', 'زن', '2008-03-15', '8888888888', 'Y888888888', 'sarina.karimi@yahoo.com', '2025-04-10');

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `idp` int(11) NOT NULL,
  `amount` int(11) DEFAULT NULL,
  `paydate` datetime DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `paygiri` char(20) DEFAULT NULL,
  `reserve_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`idp`, `amount`, `paydate`, `status`, `paygiri`, `reserve_id`) VALUES
(1, 2500000, '2026-05-01 10:10:00', 'موفق', 'P11111', 1),
(2, 850000, '2026-05-02 11:40:00', 'ناموفق', 'P22222', 2),
(3, 3200000, '2026-05-03 09:20:00', 'موفق', 'P33333', 3),
(4, 950000, '2026-05-04 14:30:00', 'موفق', 'P44444', 4),
(5, 4100000, '2026-05-05 16:50:00', 'موفق', 'P55555', 5),
(6, 780000, '2026-05-06 18:10:00', 'ناموفق', 'P66666', 6),
(7, 7200000, '2026-05-07 12:20:00', 'موفق', 'P77777', 7),
(8, 1200000, '2026-05-08 09:00:00', 'موفق', 'P88888', 8),
(9, 3500000, '2026-05-09 19:35:00', 'موفق', 'P99999', 9);

-- --------------------------------------------------------

--
-- Table structure for table `reserve`
--

CREATE TABLE `reserve` (
  `idr` int(11) NOT NULL,
  `date_r` datetime DEFAULT NULL,
  `status_r` varchar(50) DEFAULT NULL,
  `mosafer_id` int(11) DEFAULT NULL,
  `travel_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

--
-- Dumping data for table `reserve`
--

INSERT INTO `reserve` (`idr`, `date_r`, `status_r`, `mosafer_id`, `travel_id`) VALUES
(1, '2026-05-01 10:00:00', 'تایید شده', 1, 1),
(2, '2026-05-02 11:30:00', 'در انتظار', 2, 2),
(3, '2026-05-03 09:15:00', 'لغو شده', 3, 3),
(4, '2026-05-04 14:20:00', 'تایید شده', 4, 4),
(5, '2026-05-05 16:40:00', 'تایید شده', 5, 5),
(6, '2026-05-06 18:00:00', 'در انتظار', 6, 6),
(7, '2026-05-07 12:10:00', 'لغو شده', 7, 7),
(8, '2026-05-08 08:50:00', 'تایید شده', 8, 8),
(9, '2026-05-09 19:25:00', 'تایید شده', 9, 9),
(11, '2026-06-05 09:00:00', 'در انتظار', 1, 2),
(12, '2026-06-05 10:30:00', 'لغو شده', 1, 3);

-- --------------------------------------------------------

--
-- Table structure for table `staffs`
--

CREATE TABLE `staffs` (
  `ids` int(11) NOT NULL,
  `names` varchar(20) DEFAULT NULL,
  `familys` varchar(50) DEFAULT NULL,
  `position` varchar(30) DEFAULT NULL,
  `phones` char(11) DEFAULT NULL,
  `codemelis` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

--
-- Dumping data for table `staffs`
--

INSERT INTO `staffs` (`ids`, `names`, `familys`, `position`, `phones`, `codemelis`) VALUES
(1, 'علی', 'احمدی', 'مدیر', '09134467899', '1111111111'),
(2, 'سارا', 'محمدی', 'کارمند', '09123334455', '2222222222'),
(3, 'رضا', 'کریمی', 'پشتیبان', '09124445566', '3333333333'),
(4, 'نیلوفر', 'حسینی', 'فروشنده', '09125556677', '4444444444'),
(5, 'امیر', 'رحیمی', 'کارمند', '09126667788', '5555555555'),
(6, 'مریم', 'اکبری', 'منشی', '09127778899', '6666666666'),
(7, 'حسین', 'کاظمی', 'مدیر', '09128889900', '7777777777'),
(8, 'زهرا', 'قاسمی', 'پشتیبان', '09129990011', '8888888888'),
(9, 'محمد', 'مرادی', 'فروشنده', '09121112233', '9999999999'),
(10, 'نگار', 'عباسی', 'کارمند', '09122223344', '1010101010');

-- --------------------------------------------------------

--
-- Table structure for table `travel`
--

CREATE TABLE `travel` (
  `idt` int(11) NOT NULL,
  `type` varchar(20) DEFAULT NULL,
  `origin` varchar(50) DEFAULT NULL,
  `destination` varchar(50) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  `duration` time DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `staff_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `vasile_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

--
-- Dumping data for table `travel`
--

INSERT INTO `travel` (`idt`, `type`, `origin`, `destination`, `date`, `time`, `duration`, `capacity`, `price`, `staff_id`, `company_id`, `vasile_id`) VALUES
(1, 'پرواز', 'تهران', 'مشهد', '2026-05-15', '08:30:00', '01:30:00', 120, 2725000, 1, 1, 1),
(2, 'قطار', 'تهران', 'اصفهان', '2026-05-16', '14:00:00', '05:00:00', 200, 850000, 2, 5, 3),
(3, 'پرواز', 'شیراز', 'کیش', '2026-05-18', '19:45:00', '01:00:00', 90, 3584000, 3, 2, 2),
(4, 'قطار', 'تبریز', 'تهران', '2026-05-20', '09:15:00', '08:00:00', 180, 950000, 4, 6, 4),
(5, 'پرواز', 'مشهد', 'کیش', '2026-05-22', '21:00:00', '02:00:00', 75, 4100000, 5, 3, 5),
(6, 'قطار', 'قم', 'یزد', '2026-05-24', '11:30:00', '04:30:00', 140, 780000, 6, 7, 6),
(7, 'پرواز', 'تهران', 'دبی', '2026-05-25', '06:45:00', '02:30:00', 110, 7200000, 7, 4, 7),
(8, 'قطار', 'رشت', 'مشهد', '2026-05-26', '13:00:00', '10:00:00', 250, 1200000, 8, 8, 8),
(9, 'پرواز', 'اصفهان', 'کیش', '2026-05-28', '17:20:00', '01:20:00', 95, 3500000, 9, 9, 9),
(10, 'قطار', 'کرمان', 'تهران', '2026-05-30', '22:00:00', '09:00:00', 300, 1300000, 10, 5, 10);

-- --------------------------------------------------------

--
-- Table structure for table `vasile_naqlie`
--

CREATE TABLE `vasile_naqlie` (
  `idv` int(11) NOT NULL,
  `typev` varchar(20) DEFAULT NULL,
  `register_num` char(20) DEFAULT NULL,
  `capacityv` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

--
-- Dumping data for table `vasile_naqlie`
--

INSERT INTO `vasile_naqlie` (`idv`, `typev`, `register_num`, `capacityv`) VALUES
(1, 'هواپیما', 'IR845', 180),
(2, 'هواپیما', 'IR920', 220),
(3, 'قطار', 'TR220', 350),
(4, 'قطار', 'TR450', 400),
(5, 'هواپیما', 'IR777', 200),
(6, 'قطار', 'TR880', 320),
(7, 'هواپیما', 'IR654', 150),
(8, 'قطار', 'TR990', 280),
(9, 'هواپیما', 'IR333', 170),
(10, 'قطار', 'TR101', 500);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`idc`);

--
-- Indexes for table `passenger`
--
ALTER TABLE `passenger`
  ADD PRIMARY KEY (`id_mosafer`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`idp`),
  ADD KEY `reserve_id` (`reserve_id`);

--
-- Indexes for table `reserve`
--
ALTER TABLE `reserve`
  ADD PRIMARY KEY (`idr`),
  ADD KEY `mosafer_id` (`mosafer_id`),
  ADD KEY `travel_id` (`travel_id`);

--
-- Indexes for table `staffs`
--
ALTER TABLE `staffs`
  ADD PRIMARY KEY (`ids`);

--
-- Indexes for table `travel`
--
ALTER TABLE `travel`
  ADD PRIMARY KEY (`idt`),
  ADD KEY `staff_id` (`staff_id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `vasile_id` (`vasile_id`);

--
-- Indexes for table `vasile_naqlie`
--
ALTER TABLE `vasile_naqlie`
  ADD PRIMARY KEY (`idv`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `company`
--
ALTER TABLE `company`
  MODIFY `idc` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `passenger`
--
ALTER TABLE `passenger`
  MODIFY `id_mosafer` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `idp` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `reserve`
--
ALTER TABLE `reserve`
  MODIFY `idr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `staffs`
--
ALTER TABLE `staffs`
  MODIFY `ids` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `travel`
--
ALTER TABLE `travel`
  MODIFY `idt` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `vasile_naqlie`
--
ALTER TABLE `vasile_naqlie`
  MODIFY `idv` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`reserve_id`) REFERENCES `reserve` (`idr`);

--
-- Constraints for table `reserve`
--
ALTER TABLE `reserve`
  ADD CONSTRAINT `reserve_ibfk_1` FOREIGN KEY (`mosafer_id`) REFERENCES `passenger` (`id_mosafer`),
  ADD CONSTRAINT `reserve_ibfk_2` FOREIGN KEY (`travel_id`) REFERENCES `travel` (`idt`);

--
-- Constraints for table `travel`
--
ALTER TABLE `travel`
  ADD CONSTRAINT `travel_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `staffs` (`ids`),
  ADD CONSTRAINT `travel_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `company` (`idc`),
  ADD CONSTRAINT `travel_ibfk_3` FOREIGN KEY (`vasile_id`) REFERENCES `vasile_naqlie` (`idv`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
