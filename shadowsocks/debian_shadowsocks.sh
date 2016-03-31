#! /bin/bash
#===============================================================================================
#   System Required:  Debian or Ubuntu (32bit/64bit)
#   Description:  Install Shadowsocks(libev) for Debian or Ubuntu
#   Author: Clang <admin@clangcn.com>
#   Intro:  http://clangcn.com
#===============================================================================================

clear
echo "#############################################################"
echo "# Install Shadowsocks(libev) for Debian or Ubuntu (32bit/64bit)"
echo "# Intro: http://clangcn.com"
echo "#"
echo "# Author: Clang <admin@clangcn.com>"
echo "#"
echo "#############################################################"
echo ""

############################### install function##################################
function install_shadowsocks_clang(){
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

#config setting
echo "#############################################################"
echo "#"
echo "# Please input your shadowsocks server_port and password"
echo "#"
echo "#############################################################"
echo ""
defIP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 { print $1}'`
IP="0.0.0.0"
echo "Please input VPS IP:"
read -p "(You VPS IP:$defIP, Default IP: $IP):" IP
if [ "$IP" = "" ]; then
    IP="0.0.0.0"
fi
serverport="8838"
echo -e "Please input Server Port( \\033[31m\\033[01mDon't the same SSH Port\\033[0m ):"
read -p "(Default Server Port: $serverport):" serverport
if [ "$serverport" = "" ]; then
    serverport="8838"
fi
shadowsockspwd="ilovechina"
read -p "Please input Password:(Default Password: ilovechina):" shadowsockspwd
if [ "$shadowsockspwd" = "" ]; then
    shadowsockspwd="ilovechina"
fi
ssmethod="aes-256-cfb"
echo "Please input Encryption method(aes-256-cfb, bf-cfb, des-cfb, rc4):"
read -p "(Default method: aes-256-cfb):" ssmethod
if [ "$ssmethod" = "" ]; then
    ssmethod="aes-256-cfb"
fi
get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}

echo ""
echo -e "Your Server IP: \033[32m \033[01m${IP}\033[0m"
echo -e "Your Server Port: \033[32m \033[01m${serverport}\033[0m"
echo -e "Your Password: \033[32m \033[01m${shadowsockspwd}\033[0m"
echo -e "Your Encryption Method:\033[32m \033[01m${ssmethod}\033[0m"
echo ""
echo "Press any key to start..."

char=`get_char`
cd $HOME

# install
apt-get update
apt-get install -y --force-yes build-essential autoconf libtool libssl-dev git curl

#download source code
git clone https://github.com/madeye/shadowsocks-libev.git

#compile install
cd shadowsocks-libev
./configure --prefix=/usr
make && make install
mkdir -p /etc/shadowsocks-libev
cp ./debian/shadowsocks-libev.init /etc/init.d/shadowsocks-libev
cp ./debian/shadowsocks-libev.default /etc/default/shadowsocks-libev
chmod +x /etc/init.d/shadowsocks-libev


# Config shadowsocks
cat > /etc/shadowsocks-libev/config.json<<-EOF
{
    "server":"${IP}",
    "server_port":${serverport},
    "local_port":1080,
    "password":"${shadowsockspwd}",
    "timeout":60,
    "method":"${ssmethod}"
}
EOF

#restart
/etc/init.d/shadowsocks-libev restart

#start with boot
update-rc.d shadowsocks-libev defaults

echo "#############################################################"
echo "# Install Shadowsocks(libev) for Debian or Ubuntu (32bit/64bit)"
echo "# Intro: http://clangcn.com"
echo "#"
echo "# Author: Clang <admin@clangcn.com>"
echo "#"
echo "#############################################################"
echo ""
#install successfully
    echo ""
    echo "Congratulations, shadowsocks-libev install completed!"
    echo -e "Your Server IP: \033[32m \033[01m${IP}\033[0m"
    echo -e "Your Server Port: \033[32m \033[01m${serverport}\033[0m"
    echo -e "Your Password: \033[32m \033[01m${shadowsockspwd}\033[0m"
    echo -e "Your Local Port: 1080"
    echo -e "Your Encryption Method:\033[32m \033[01m${ssmethod}\033[0m"
    echo ""
}
############################### uninstall function##################################
function uninstall_shadowsocks_clang(){
#change the dir to shadowsocks-libev
cd $HOME
cd shadowsocks-libev

#stop shadowsocks-libev process
/etc/init.d/shadowsocks-libev stop

#uninstall shadowsocks-libev
make uninstall
make clean
cd ..
rm -rf shadowsocks-libev

# delete config file
rm -rf /etc/shadowsocks-libev

# delete shadowsocks-libev init file
rm -f /etc/init.d/shadowsocks-libev
rm -f /etc/default/shadowsocks-libev

#delete start with boot
update-rc.d -f shadowsocks-libev remove

echo "Shadowsocks-libev uninstall success!"

}

############################### update function##################################
function update_shadowsocks_clang(){
     uninstall_shadowsocks_clang
     install_shadowsocks_clang
	 echo "Shadowsocks-libev update success!"
}
# Initialization
action=$1
[  -z $1 ] && action=install
case "$action" in
install)
    install_shadowsocks_clang
    ;;
uninstall)
    uninstall_shadowsocks_clang
    ;;
update)
    update_shadowsocks_clang
    ;;	
*)
    echo "Arguments error! [${action} ]"
    echo "Usage: `basename $0` {install|uninstall|update}"
    ;;
esac