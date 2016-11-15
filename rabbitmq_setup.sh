##### Adding repository entry #####

wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm -P /opt/software/
rpm -Uvh /opt/software/erlang-solutions-1.0-1.noarch.rpm 

##### Installing Erlang #####

yum -y install erlang

##### Install RabbitMQ server #####

wget --no-cache http://www.convirture.com/repos/definitions/rhel/6.x/convirt.repo -P /etc/yum.repos.d/
yum -y install socat
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.5/rabbitmq-server-3.6.5-1.noarch.rpm -P /opt/software/
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
yum -y install /opt/software/rabbitmq-server-3.6.5-1.noarch.rpm

##### Configure Process #####

chkconfig rabbitmq-server on

##### Start the Server #####

service rabbitmq-server start

##### Create RabbitMQ Configuration Files #####

cd /
echo "config files"
mkdir /etc/rabbitmq
chmod 755 /etc/rabbitmq
touch /etc/rabbitmq/rabbitmq-env.conf
touch /etc/rabbitmq/rabbitmq.config
echo "CONFIG_FILE=/etc/rabbitmq/rabbitmq" >> /etc/rabbitmq/rabbitmq-env.conf
echo "#NODE_IP_ADDRESS=127.0.0.1" >> /etc/rabbitmq/rabbitmq-env.conf
echo "NODENAME=rabbit@rebasvr29" >> /etc/rabbitmq/rabbitmq-env.conf
echo "[{rabbit, [{loopback_users, []}]}]." >> /etc/rabbitmq/rabbitmq.config

##### Open listening port #####

iptables -I INPUT 10 -p tcp -m tcp --dport 15672 -j ACCEPT
/etc/init.d/iptables save

##### Enable RabbitMQ Management GUI #####

rabbitmq-plugins enable rabbitmq_management   

##### Add RabbitMQ user #####

rabbitmqctl add_user lee lee
rabbitmqctl set_user_tags lee administrator
rabbitmqctl set_permissions -p / lee ".*" ".*" ".*"

##### Restart Server

service rabbitmq-server restart



