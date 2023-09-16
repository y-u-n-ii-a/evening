#!/bin/bash
yum -y update
yum -y install httpd


cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<h1>Okay I'm just trying</h1><br><p>
<font color="magenta">
<b>Version 3.0</b>
</body>
</html>
EOF

sudo service httpd start
chkconfig httpd on