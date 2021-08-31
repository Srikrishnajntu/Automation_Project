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
	date=$(date +'%d%m%Y')
	FileType="Tar"
	tarball=$name"-httpd-logs-${timestamp}.tar";
	sudo tar -cvf /tmp/$tarball --exclude="/var/log/apache2/other_vhosts_access.log" /var/log/apache2/*.log
	processID=$!
	wait $processID
	file_Size=$(sudo ls -sh /tmp/$tarball|awk '{print $1}')
	echo $file_Size
	aws s3 \
	cp /tmp/$tarball s3://$s3bucket//$tarball
	if sudo test -f "/var/www/html/inventory.html"
	then
		str_insert="\<tr\>\<td\>httpd-logs&emsp;$date&emsp;$FileType&emsp;$file_Size\</td\>\</tr\>"
		sudo sed -i -e "$ i <p>" -e "$ i $str_insert" -e "$ i </p>" /var/www/html/inventory.html
	else
	
		{
		echo \<p\>
		echo \<tr\>\<td\>"LogType"\&emsp\;"TimeCreated"\&emsp\;"Type"\&emsp\;"Size"\</td\>\</tr\>
		echo \</p\>
		}>> "/var/www/html/inventory.html"
	fi
fi
if ! sudo test -f "/etc/cron.d/automation"
then
	sudo bash -c 'echo "0 0 * * * root /root/Automation_Project/automation.sh" > "/etc/cron.d/automation"'
fi
exit
