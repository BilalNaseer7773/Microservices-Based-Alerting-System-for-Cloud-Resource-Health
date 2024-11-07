import boto3
import os

# Initialize AWS clients
cloudwatch = boto3.client("cloudwatch")
sns = boto3.client("sns")

# Define SNS topic from environment variables
SNS_TOPIC_ARN = os.getenv("SNS_TOPIC_ARN")

def lambda_handler(event, context):
    # Fetch CPU utilization metrics
    metrics = cloudwatch.get_metric_statistics(
        Namespace="AWS/EC2",
        MetricName="CPUUtilization",
        Dimensions=[{"Name": "InstanceId", "Value": "your-instance-id"}],
        StartTime=event["StartTime"],
        EndTime=event["EndTime"],
        Period=300,
        Statistics=["Average"],
    )

    # Check if CPU exceeds threshold
    for data_point in metrics["Datapoints"]:
        if data_point["Average"] > 80:  # Threshold of 80%
            # Send notification to SNS
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject="High CPU Alert",
                Message=f"CPU utilization is at {data_point['Average']}%"
            )
            return {"statusCode": 200, "body": "Alert sent!"}

    return {"statusCode": 200, "body": "No alerts triggered."}
