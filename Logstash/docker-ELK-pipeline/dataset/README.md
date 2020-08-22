# Dataset

> datagenerator
>
> - `DATA_NUM` = 1000
> - `ES_INDEX_NAME` = 'test_data'
> - `ES_URL` = 'elasticsearch:9200'



## Mapping

~~~json
{
    "mapping" : {
        "_doc" : {
            "properties" : {
                "customer_address" : {
                    "type" : "keyword"
                },
                "customer_age" : {
                    "type" : "integer"
                },
                "customer_gender" : {
                    "type" : "keyword"
                },
                "order_id" : {
                    "type" : "integer" 
                },
                "order_주문시간" : {
                    "type" : "date"
                },
                "product_가격" : {
                    "type" : "integer"
                },
                "product_개수" : {
                    "type" : "integer"
                },
                "product_분류" : {
                    "type" : "keyword"
                },
                "결제카드" : {
                    "type" : "keyword"
                },
                "구매사이트" : {
                    "type" : "keyword"
                },
                "평점" : {
                    "type" : "integer"
                },
            }
        }
    }
}
~~~



## 데이터 샘플

~~~json
{
    "order_id": 740,
    "order_주문시간": "2020-07-28T10:08:12",
    "customer_gender": "남성",
    "customer_age": 44,
    "customer_address": "세종특별자치시",
    "product_분류": "니트",
    "product_가격": 19500,
    "product_개수": 2,
    "결제카드": "하나",
    "구매사이트": "쿠팡",
    "평점": 3
}
~~~



## 실행방법

> 1. Python
> 2. Docker

### local run(using python)

~~~shell
$ pip install elasticsearch
$ python generate_dataset.py
~~~



### docker run

~~~shell
$ docker build -f Dockerfile -t test-datagen .
$ docker run --net=docker-elk-pipeline_elk test-datagen
$ docker run --net=docker-elk-pipeline_elk -v="${PWD}/generate_dataset.py:/app/generate_dataset.py" test-datagen
~~~

