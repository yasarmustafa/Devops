<?php
$mysqli = new mysqli("db", "root", "root123", "mydb");
if ($mysqli->connect_error) {
  echo "MySQL'e bağlanılamadı: " . $mysqli->connect_error;
} else {
  echo "MySQL bağlantısı başarılı!";
}
?>
