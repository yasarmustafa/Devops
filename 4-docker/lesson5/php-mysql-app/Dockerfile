FROM php:8.0-apache

# mysqli uzantısını yükle
RUN docker-php-ext-install mysqli

# Geliştirici için ekstra yardımcılar istenirse:
# RUN apt-get update && apt-get install -y vim curl

# Belge klasörünü otomatik tanıması için (gerekirse)
COPY src/ /var/www/html/
