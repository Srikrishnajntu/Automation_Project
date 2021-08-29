name="srikrishna"
s3bucket="upgrad-srikrishna"
sudo apt  update -y
if ! dpkg --get-selections | grep apache
then
	sudo apt-get install apache2
fi
if systemctl status apache2| grep "active"
then
	timestamp=$(date +'%d%m%Y-%H%M%S')
	tarball=$name"-httpd-logs-${timestamp}.tar";
	sudo tar -cvf /tmp/$tarball --exclude="/var/log/apache2/other_vhosts_access.log" /var/log/apache2/*.log
	aws s3 \
	cp /tmp/$tarball s3://$s3bucket//$tarball
fi
exit
