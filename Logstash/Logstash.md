## Logstash

~~~shell
input {
  stdin {
  }
}

output {
  stdout {
  }
}
~~~



## 1. File

~~~
input {
  file {
    path => "/home/yckim/Logstash/data/titanic.csv"
    start_position => "beginning"                 
    sincedb_path => "/dev/null" 
  }
}

output {
  stdout {
  }
}
~~~

~~~
input {
  file {
    path => "/home/yckim/Logstash/data/titanic.csv"
    start_position => "beginning"                 
  }
}

output {
  stdout {
  }
}
~~~

~~~
input {
  file {
    path => "/home/yckim/Logstash/data/titanic.csv"
    start_position => "beginning"                 
    sincedb_path => "/dev/null" 
  }
}

filter {
  csv {
    separator => ","
    autodetect_column_names => true
    convert => {                                                                
      "Pclass" => "integer"                                                        
      "PassengerId" => "integer"                                                        
      "Survived" => "integer"                                                    
      "Fare" => "float"                                                            
      "@timestamp" => "date"
    } 
  }
}

output {
  stdout {
  }
}
~~~





## 2. JDBC

### 2.1 MYSQL

~~~
input {                                                                                   
  jdbc {
  	jdbc_driver_library => "/home/yckim/Logstash/lib/mysql-connector-java-8.0.18.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    jdbc_validate_connection => true
    jdbc_connection_string => "jdbc:mysql://localhost:3306/mydb"
    jdbc_user => "user"
    jdbc_password => "password"
    schedule => "* * * * *"
    statement => "SELECT * FROM titanic limit 10"
 }
}                                                                                              
                           
output {
  stdout {
  }                                                                                       
}
~~~





### 2.2 MYSQL

~~~
input {                                                                                   
  jdbc {                                                                                     jdbc_driver_library => "/home/yckim/Logstash/lib/mysql-connector-java-8.0.18.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    jdbc_validate_connection => true
    jdbc_connection_string => "jdbc:mysql://localhost:3306/mydb"
    jdbc_user => "user"
    jdbc_password => "password"
    schedule => "* * * * *"
    statement => "SELECT * FROM titanic limit 10"  
    statement => "SELECT PassengerId, Survived, Pclass, Name FROM titanic limit 10"
 }
}                                                                                              
                           
output {    
  stdout {
  }
  csv {
    fields => ["passengerid", "survived", "pclass", "name"]           
    path => "/home/yckim/Logstash/data/extracted1.csv"
  }
}
~~~





### 2.3 MYSQL

~~~
input {                                                                                   
  jdbc {
    jdbc_driver_library => "/home/yckim/Logstash/lib/mysql-connector-java-8.0.18.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    jdbc_validate_connection => true
    jdbc_connection_string => "jdbc:mysql://localhost:3306/mydb"
    jdbc_user => "user"
    jdbc_password => "password"
    schedule => "* * * * *"
    statement => "SELECT * FROM titanic limit 10"  
    statement => "SELECT PassengerId, Survived, Pclass, Name FROM titanic limit 10"
 }
}                                                                                              
                           
output {    
  stdout {
  }
  elasticsearch {
    hosts => ["my-elasticsearch-address:9200"]
    index => "titanicextracted"
  }
}
~~~







## 3. Elastic Search

~~~
input {
  elasticsearch {
    hosts => ["my-elasticsearch-address:9200"]
    index => "kibana_sample_data_ecommerce"
    query => '{
      "query" : {
        "match_all" : {}
      }
    }'
    size => 10
  }
}

output {
  stdout {
  }
}
~~~





## 4. Azure Event Hub

~~~
input {
   azure_event_hubs {
      event_hub_connections => ["Endpoint=sb://example1...EntityPath=insights-logs-errors", "Endpoint=sb://example2...EntityPath=insights-metrics-pt1m"]
      threads => 8
      decorate_events => true
      consumer_group => "logstash"
      storage_connection => "DefaultEndpointsProtocol=https;AccountName=example...."
   }
}
~~~

~~~
input {
   azure_event_hubs {
     config_mode => "advanced"
     consumer_group => "logstash"
     storage_connection => "DefaultEndpointsProtocol=https;AccountName=example...."
     event_hubs => [
        {"insights-operational-logs" => {
         event_hub_connection => "Endpoint=sb://example1..."
         storage_container => "insights-operational-logs-1"
        }},
        {"insights-operational-logs" => {
         event_hub_connection => "Endpoint=sb://example2..."
         storage_container => "insights-operational-logs-2"
        }}
     ]
   }
}
~~~

~~~
input {
   azure_event_hubs {
     config_mode => "advanced"
     threads => 8
     decorate_events => true
     storage_connection => "DefaultEndpointsProtocol=https;AccountName=example...."
     event_hubs => [
        {"insights-operational-logs" => {
         event_hub_connection => "Endpoint=sb://example1..."
         initial_position => "beginning"
         consumer_group => "iam_team"
        }},
      	{"insights-metrics-pt1m" => {
         event_hub_connection => "Endpoint=sb://example2..."
         initial_position => "end"
         consumer_group => "db_team"
       }}
     ]
   }
}
~~~





### 4. AWS S3

~~~
input {
	s3 {
        "access_key_id" => "1234"
        "secret_access_key" => "secret"
        "bucket" => "logstash-test"
        "additional_settings" => {
          "force_path_style" => true
          "follow_redirects" => false
        }
    }
}
~~~





## 5. Google cloud storage

~~~
input {
  google_cloud_storage {
    interval => 60
    bucket_id => "batch-jobs-output"
    file_matches => "purchases.*.csv"
    json_key_file => "/home/user/key.json"
    codec => "plain"
  }
}

filter {
  csv {
    columns => ["transaction", "sku", "price"]
    convert => {
      "transaction" => "integer"
      "price" => "float"
    }
  }
}

output {
  google_bigquery {
    project_id => "my-project"
    dataset => "logs"
    csv_schema => "transaction:INTEGER,sku:INTEGER,price:FLOAT"
    json_key_file => "/path/to/key.json"
    error_directory => "/tmp/bigquery-errors"
    ignore_unknown_values => true
  }
}
~~~







