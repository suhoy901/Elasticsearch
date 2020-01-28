#!/bin/sh

# Elasticsearch Head Plugin Install
function install_head
{
    rpm -ql git > /dev/null
    if [ $? -ne 0 ]; then
        sudo yum -y install git
    fi

    ls -alh /usr/local/elasticsearch-head 2> /dev/null
    if [ $? -ne 0 ]; then
        sudo yum -y install bzip2 epel-release
        sudo yum -y install npm 
        cd /usr/local/
        sudo git clone https://github.com/mobz/elasticsearch-head.git
        cd elasticsearch-head/
        sudo npm install
    fi
    
}

# Start Head Plugin
function start_head
{
    cd /usr/local/elasticsearch-head/
    nohup npm run start &
}

# Elasticsearch HQ Plugin Install
function install_hq
{
    rpm -ql git > /dev/null
    if [ $? -ne 0 ]; then
        sudo yum -y install git
    fi

    ls -alh /usr/local/elasticsearch-HQ 2> /dev/null
    if [ $? -ne 0 ]; then
        sudo yum -y install bzip2 epel-release
        cd /usr/local/
        sudo git clone https://github.com/ElasticHQ/elasticsearch-HQ.git
        cd elasticsearch-HQ/
        sudo yum -y install python34 python34-pip
        sudo pip3.4 install -r requirements.txt
    fi
    
}

# Start Head Plugin
function start_hq
{
    cd /usr/local/elasticsearch-HQ/
    sudo nohup python3.4 application.py & 
}


if [ -z $1 ]; then
        echo "##################### Menu ##############"
        echo " $ ./tuto2 [Command]"
        echo "#####################%%%%%%##############"
        echo "1 : install head plugin" 
        echo "2 : start head plugin"
        echo "3 : install hq plugin" 
        echo "4 : start hq plugin"
        echo "#########################################";
        exit 1;
fi

case "$1" in
        "1" ) install_head;;
        "2" ) start_head;;
        "3" ) install_hq;;
        "4" ) start_hq;;
        *) echo "Incorrect Command" ;;
esac
