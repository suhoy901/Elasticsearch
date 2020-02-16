#!/bin/sh

git pull

# ES Nori Plugin Install
function install_nori
{
    sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-nori

}

function restart_es_process
{
    sudo systemctl restart elasticsearch
    sudo touch /etc/elasticsearch/userdict_ko.txt
}

function configure_nori_mappings
{
    curl -s localhost:9200 > /dev/null
    if [ $? -ne 0 ]; then
	echo "Your ES Process is not working yet"
    else
	curl -s -H 'Content-Type: application/json' -XPUT http://localhost:9200/noritest1 -d '
        {
          "settings": {
            "index": {
              "analysis": {
                "tokenizer": {
                  "nori_user_dict": {
                    "type": "nori_tokenizer",
                    "decompound_mode": "mixed",
                    "user_dictionary": "userdict_ko.txt"
                  }
                },
                "analyzer": {
                  "my_analyzer": {
                    "type": "custom",
                    "tokenizer": "nori_user_dict"
                  }
                }
              }
            }
          },
          "mappings": {
            "properties": {
              "norimsg": {
                "type": "text",
                "analyzer": "my_analyzer"
              }
            }
          }
        }'
    fi

}


function get_tokens_by_standard
{

    curl -s localhost:9200 > /dev/null
    if [ $? -ne 0 ]; then
	echo "Your ES Process is not working yet"
    else
##        post="{
##	    \"analyzer\" : \"standard\",
##	    \"text\": \"$1\"
##        }"
##
##	curl -s -H 'Content-Type: application/json' -XPOST http://localhost:9200/_analyze -d "${post}"

	echo "## Standard Analyzer Tokens"
	echo "## text : Winter is Coming!!!"

	curl -s -H 'Content-Type: application/json' -XPOST http://localhost:9200/_analyze?pretty -d '
	{
		"analyzer": "standard",
		"text": "Winter is coming!!!"
	}'
    fi
}

function get_tokens_by_nori
{

    curl -s localhost:9200 > /dev/null
    if [ $? -ne 0 ]; then
	echo "Your ES Process is not working yet"
    else
	echo "## Nori Analyzer Tokens"
	echo "## text : 21세기 세종계획"

	curl -s -H 'Content-Type: application/json' -XPOST http://localhost:9200/noritest1/_analyze?pretty -d '
	{
		"analyzer": "my_analyzer",
		"text": "21세기 세종계획"
	}'
    fi
}


function indexing_by_nori
{

    curl -s localhost:9200 > /dev/null
    if [ $? -ne 0 ]; then
	echo "Your ES Process is not working yet"
    else
	echo "## Nori Analyzer Indexing"
	echo "## norimsg : 21세기 세종계획"

	curl -s -H 'Content-Type: application/json' -XPOST http://localhost:9200/noritest1/_doc -d '
	{
            "norimsg": "21세기 세종계획"
        }'
    fi
}

function searching_by_nori
{

    curl -s localhost:9200 > /dev/null
    if [ $? -ne 0 ]; then
	echo "Your ES Process is not working yet"
    else
	echo "## Nori Analyzer Searching"
	echo "## norimsg : 세종"

	curl -s -H 'Content-Type: application/json' -XPOST http://localhost:9200/noritest1/_search?pretty -d '
	{
            "query": {
	        "match": {
		    "norimsg": "세종"
	        }
	    }
        }'
    fi
}

if [ -z $1 ]; then
        echo "##################### Menu ##############"
        echo " $ ./tuto5 [Command]"
        echo "#####################%%%%%%##############"
        echo "         1 : install nori plugin"
        echo "         2 : restart es process"
        echo "         3 : make a nori mappings"
        echo "         4 : standard analyzer tokens"
        echo "         5 : nori analyzer tokens"
        echo "         6 : nori analyzer indexing"
        echo "         7 : nori analyzer searching"
        echo "#########################################";
        exit 1;
fi

case "$1" in
        "1" ) install_nori;;
        "2" ) restart_es_process;;
        "3" ) configure_nori_mappings;;
        "4" ) get_tokens_by_standard;;
        "5" ) get_tokens_by_nori;;
        "6" ) indexing_by_nori;;
        "7" ) searching_by_nori;;
        *) echo "Incorrect Command" ;;
esac
