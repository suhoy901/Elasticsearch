#!/bin/sh

ES_VER="7.5.1"
ES_URL="https://artifacts.elastic.co/downloads/elasticsearch"
ES_RPM="elasticsearch-${ES_VER}-x86_64.rpm"

ES_ETC="/etc/elasticsearch"
ES_MYML="elasticsearch.yml"
ES_ADDYML="ymladd.yml"
ES_JVM="jvm.options"

ES_NODEIP=$(ifconfig | grep inet | grep -vE '127.0.0.1|inet6' | awk '{print $2}')
ES_NODENAME=$(hostname -s)

KB_URL="https://artifacts.elastic.co/downloads/kibana"
KB_RPM="kibana-${ES_VER}-x86_64.rpm"
KB_ETC="/etc/kibana"
KB_MYML="kibana.yml"

SEQ="1st"
ORG_SEQ="org_1st"

#git pull

# ES Package Install
function install_es_packages
{
    wget 2> /dev/null
    if [ $? -ne 1 ]; then
        sudo yum -y install wget
    fi

    ls -alh /usr/local/src/elasticsearch* 2> /dev/null
    if [ $? -ne 0 ]; then
        sudo wget ${ES_URL}/${ES_RPM} -O /usr/local/src/${ES_RPM}
    fi

    rpm -ql elasticsearch > /dev/null
    if [ $? -ne 0 ]; then
        sudo rpm -ivh /usr/local/src/${ES_RPM}
    fi
}

# elasticsearch.yml Configure
function configure_es_yaml
{
    sudo echo "### For ClusterName & Node Name" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    sudo echo "cluster.name: mytuto-es" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    sudo echo "node.name: master-$ES_NODENAME" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    
    sudo echo "### For HEAD" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    sudo echo "http.cors.enabled: true" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    sudo echo "http.cors.allow-origin: \"*\"" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    sudo echo "### For Response by External Request" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    sudo echo "network.host: 0.0.0.0" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null


    sudo echo "### Discovery Settings" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    sudo echo "discovery.seed_hosts: [ \"$ES_NODEIP:9300\",  ]" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null
    sudo echo "cluster.initial_master_nodes: [ \"$ES_NODEIP:9300\",  ]" | sudo tee -a ${ES_ETC}/${ES_MYML} > /dev/null

    # jvm options Configure for Heap Memory
    sudo cp -f ${ES_ETC}/${ES_JVM} ./${ES_JVM}.${ORG_SEQ}
    sudo cp -f ${ES_JVM}.${SEQ} ${ES_ETC}/${ES_JVM}
}

# Start Elasticsearch
function start_es_process
{
    sudo systemctl daemon-reload
    sudo systemctl enable elasticsearch.service
    sudo systemctl restart elasticsearch
}

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


# Kibana Package Install
function install_kb_packages
{
    ls -alh /usr/local/src/kibana* 2> /dev/null
    if [ $? -ne 0 ]; then
        sudo wget ${KB_URL}/${KB_RPM} -O /usr/local/src/${KB_RPM}
    fi

    rpm -ql kibana > /dev/null
    if [ $? -ne 0 ]; then
        sudo rpm -ivh /usr/local/src/${KB_RPM}
    fi
}

# kibana.yml Configure
function configure_kb_yaml
{
    #sudo cp -f ${KB_ETC}/${KB_MYML} ${KB_ETC}/${KB_MYML}.${ORG_SEQ}
    #sudo cp -f ${KB_MYML} ${KB_ETC}/${KB_MYML}
    sudo echo "server.host: \"0.0.0.0\"" | sudo tee -a ${KB_ETC}/${KB_MYML} > /dev/null
    sudo echo elasticsearch.hosts: \"http://localhost:9200\" | sudo tee -a ${KB_ETC}/${KB_MYML} > /dev/null
    sudo echo kibana.index: \".kibana\" | sudo tee -a ${KB_ETC}/${KB_MYML} > /dev/null
}

# Start Kibana
function start_kb_process
{
    sudo systemctl daemon-reload
    sudo systemctl enable kibana.service
    sudo systemctl restart kibana
}

function init_ec2
{
    # remove rpm files
    sudo \rm -rf /usr/local/src/*

    # stop & disable elasticsearch & kibana daemon
    sudo systemctl stop elasticsearch
    sudo systemctl stop kibana

    sudo systemctl disable elasticsearch.service
    sudo systemctl disable kibana.service

    sudo systemctl daemon-reload

    # erase rpm packages
    sudo rpm -e elasticsearch-${ES_VER}-1.x86_64
    sudo rpm -e kibana-${ES_VER}-1.x86_64

    # remove package configs
    sudo rm -rf /etc/elasticsearch
    sudo rm -rf /var/lib/elasticsearch
    sudo rm -rf /var/log/elasticsearch
    sudo rm -rf /etc/kibana
    sudo rm -rf /var/lib/kibana
    sudo rm -rf /var/log/kibana

}

if [ -z $1 ]; then
        echo "##################### Menu ##############"
        echo " $ ./tuto1 [Command]"
        echo "#####################%%%%%%##############"
        echo "1 : elasticsearch packages"
        echo "2 : configure elasticsearch.yml & jvm.options"
        echo "3 : start elasticsearch process"
	echo "4 : install head plugin"
	echo "5 : start head plugin"
        echo "6 : install kibana packages"
        echo "7 : configure kibana.yml"
        echo "8 : start kibana process"
        echo "init : ec2 instance initializing"
        echo "#########################################";
        exit 1;
fi

case "$1" in
        "1" ) install_es_packages;;
        "2" ) configure_es_yaml;;
        "3" ) start_es_process;;
	"4" ) install_head;;
	"5" ) start_head;;
        "6" ) install_kb_packages;;
        "7" ) configure_kb_yaml;;
        "8" ) start_kb_process;;
        "init" ) init_ec2;;
        *) echo "Incorrect Command" ;;
esac
