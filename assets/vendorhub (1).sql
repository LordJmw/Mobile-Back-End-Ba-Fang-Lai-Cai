-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 04 Des 2025 pada 14.37
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vendorhub`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `purchasehistory`
--

CREATE TABLE `purchasehistory` (
  `id` int(11) NOT NULL,
  `customer_id` varchar(50) DEFAULT NULL,
  `purchase_details` text DEFAULT NULL,
  `purchase_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `purchasehistory`
--

INSERT INTO `purchasehistory` (`id`, `customer_id`, `purchase_details`, `purchase_date`) VALUES
(1, '4', '{\"vendor\":\"Dream Events\",\"package\":\"Premium\",\"price\":10000000,\"date\":\"2025-11-27T00:00:00.000\",\"location\":\"jalan asia\",\"notes\":\"-\",\"status\":\"pending\"}', '2025-11-13 13:46:29'),
(4, '6', '{\"vendor\":\"LensArt Studio\",\"package\":\"custom\",\"price\":5000000,\"date\":\"2025-11-25T00:00:00.000\",\"location\":\"kkn\",\"notes\":\"15\",\"status\":\"pending\"}', '2025-11-13 15:06:43'),
(7, '6', '{\"vendor\":\"Wedding Moments\",\"package\":\"Basic\",\"price\":1000000,\"date\":\"2025-11-30T00:00:00.000\",\"location\":\"jalan asia\",\"notes\":\"\",\"status\":\"pending\"}', '2025-11-13 16:23:24'),
(16, 'VLrWSlJIgrMQvdLwA6Kb0B6eVEA2', '{\"vendor\":\"Glam Beauty\",\"package\":\"Basic\",\"price\":800000,\"date\":\"2025-12-23T00:00:00.000\",\"location\":\"asasdasd\",\"notes\":\"aasdasdas\",\"status\":\"pending\"}', '2025-12-03 21:54:08');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `purchasehistory`
--
ALTER TABLE `purchasehistory`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `purchasehistory`
--
ALTER TABLE `purchasehistory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
