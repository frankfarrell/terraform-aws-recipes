# Dynamodb autoscaling

##Variables

1. max_capacity
2. min_capacity
3. target_utilization: default = 0.7
4. table_name 
5. dynamo_autoscale_role_arn 
6. type : Options are READ or WRITE, default is READ

## Use: 
```
module "api_gateway" {
    source = "github.com/frankfarrell/terraform-aws-recipes//dynamodb_autoscaling"
    max_capacity = 100
    min_capacity =5
    target_utilization = 0.7
    table_name = "my-dynamo-table"
    dynamo_autoscale_role_arn = "IAM role arn that is allowed to configure dynamo table capacity" 
    type = "READ"
}
```

## A note on scaling provisioned capacity in DynamoDB
When you initially provision the capacity on your table it determines how mant shards to create for the given capacity. 
This is not fully transparent, but it seems to be 1000 per provisioned capacity unit. When you increase capacity it increases the number of shards, and evenly 
distributes the capacity amongst them. However, when you decresase capacity, the number of shards stay the same, but the capacity is divided equally between them. 
So, you could end up with double the shards, each having half the typical shard capacity as before. 

This can be a problem if your load is not perfectly evenly dsitributed, eg it can lot to hot partitions. 

Rather than scale upwards to the max, it may be a better strategy to cache or throttle writes to keep the shard partitioning integrity in place. 
