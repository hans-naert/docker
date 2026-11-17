FROM ubuntu-apache2-php
EXPOSE 80
CMD /usr/sbin/apache2ctl -D FOREGROUND