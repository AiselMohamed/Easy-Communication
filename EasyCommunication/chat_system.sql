-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3307
-- Generation Time: Jun 14, 2024 at 01:37 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `chat_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `chat`
--

CREATE TABLE `chat` (
  `chatid` int(255) NOT NULL,
  `sender_userid` int(255) NOT NULL,
  `reciever_userid` int(255) NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `chat`
--

INSERT INTO `chat` (`chatid`, `sender_userid`, `reciever_userid`, `message`, `timestamp`, `status`) VALUES
(257, 36, 44, 'Hey Khaled? Is it you?', '2024-06-11 10:11:33', 0),
(258, 44, 36, 'Oh Aisel! How are you? It’s been a long time.', '2024-06-11 10:15:17', 0),
(266, 36, 37, 'Hi', '2024-06-11 19:15:00', 1),
(267, 36, 43, 'Hello🥰', '2024-06-11 19:16:15', 1),
(268, 36, 44, '😃😃😃😃', '2024-06-11 19:27:45', 1),
(269, 44, 36, '😄😄😄', '2024-06-11 19:28:16', 1);

-- --------------------------------------------------------

--
-- Table structure for table `chat_login_details`
--

CREATE TABLE `chat_login_details` (
  `id` int(255) NOT NULL,
  `userid` int(255) NOT NULL,
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_typing` enum('no','yes') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `chat_login_details`
--

INSERT INTO `chat_login_details` (`id`, `userid`, `last_activity`, `is_typing`) VALUES
(65, 36, '2024-06-11 10:05:27', 'no'),
(66, 44, '2024-06-11 10:13:21', 'no'),
(67, 44, '2024-06-11 10:14:18', 'no'),
(68, 36, '2024-06-11 10:23:36', 'no'),
(69, 36, '2024-06-11 16:37:05', 'no'),
(70, 36, '2024-06-11 16:37:35', 'no'),
(71, 36, '2024-06-11 16:45:34', 'no'),
(72, 37, '2024-06-11 17:30:54', 'no'),
(73, 36, '2024-06-11 19:11:27', 'no'),
(74, 44, '2024-06-11 19:26:07', 'no'),
(75, 36, '2024-06-11 19:27:13', 'no');

-- --------------------------------------------------------

--
-- Table structure for table `chat_users`
--

CREATE TABLE `chat_users` (
  `userid` int(225) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `current_session` int(11) NOT NULL,
  `online` int(11) NOT NULL,
  `country` varchar(225) NOT NULL,
  `mainlanguage` varchar(225) NOT NULL,
  `email` varchar(225) NOT NULL,
  `img` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `chat_users`
--

INSERT INTO `chat_users` (`userid`, `username`, `password`, `current_session`, `online`, `country`, `mainlanguage`, `email`, `img`) VALUES
(9, 'aisel', 'Aisel123$', 20, 3, 'Egypt', 'arabic', 'aisel20-00264@student.eelu.edu.eg', 'Authentication_Outline.png'),
(36, 'AiselMohamedSalah', 'Aisel123$?', 44, 1, 'United States', 'English ', 'aiselmohamed48@gmail.com', '1501004889890.jpg'),
(37, 'NadaMohamed', 'Nada123$', 0, 0, 'Paris', 'French', 'nadamohamed@gmail.com', 'cat.jpg'),
(38, 'Nada', 'Nada123#?', 0, 0, 'Egypt', 'arabic', 'nada12@gmail.com', 'wallpaperflare.com_wallpaper (1).jpg'),
(39, 'YousefAhmed', 'Yahmed12?', 0, 0, 'Egypt', 'arabic', 'yousefahmed@gmail.com', 'msg838290553-28959.jpg'),
(40, 'Yousef', 'Yousef$12?', 0, 0, 'Canada ', 'English', 'yousef11@gmail.com', 'istockphoto-1304859591-170667a.jpg'),
(41, 'HossamAhmed', 'Hossam123$', 0, 0, 'Egypt', 'arabic', 'hossamahmed@gmail.com', 'wallpaperflare.com_wallpaper (1).jpg'),
(42, 'Hossam', 'Hossam87*', 0, 0, 'China', 'Chinese', 'Hossam45@gmail.com', 'wallpaperflare.com_wallpaper (2).jpg'),
(43, 'Maryam', 'Mariam123%', 0, 0, 'Egypt', 'arabic', 'Maryam12@gmail.com', 'file (1).png'),
(44, 'Khaled', 'Khaled123$', 36, 0, 'UK', 'english', 'Khaled@gmail.com', '426748672_713881120877777_1102701597441956_n.jpg'),
(45, 'Heba', 'Heba123$', 0, 0, 'Egypt', 'arabic', 'heba@gmail.com', 'wallpaperflare.com_wallpaper (4).jpg');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `chat`
--
ALTER TABLE `chat`
  ADD PRIMARY KEY (`chatid`);

--
-- Indexes for table `chat_login_details`
--
ALTER TABLE `chat_login_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `chat_users`
--
ALTER TABLE `chat_users`
  ADD PRIMARY KEY (`userid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `chat`
--
ALTER TABLE `chat`
  MODIFY `chatid` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=270;

--
-- AUTO_INCREMENT for table `chat_login_details`
--
ALTER TABLE `chat_login_details`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `chat_users`
--
ALTER TABLE `chat_users`
  MODIFY `userid` int(225) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
