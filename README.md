# aws-serverless-mcp-workshop
aws serverless mcp ieee workshop

#### EventId
```
0e41361e-faf3-43cb-86f8-32a32071bf7d
```

#### Workshop Link
```
https://studio.us-east-1.prod.workshops.aws/events/0e41361e-faf3-43cb-86f8-32a32071bf7d
```

#### Access code
```
c9f4-095b72-2b
```

#### MCP server
```
curl -sSL https://raw.githubusercontent.com/duckinghipster/aws-serverless-mcp-workshop/main/setup_kiro_mcp.sh | bash
```

#### Sample Prompt
```
Create a Kinesis stream named "demo-stream" with 4 shards in us-east-1, then set up an Event Source Mapping to connect it to my existing Lambda function "order-processor" with LATEST starting position and batch size of 100. Deploy everything using SAM, then verify the setup works by putting a test record into the stream and checking CloudWatch logs to confirm the Lambda was invoked.
```

```
Create an SQS queue named "demo-queue" in us-east-1 with a Dead Letter Queue for failed messages, then set up an Event Source Mapping to connect it to my existing Lambda function "order-processor" optimized for processing 1,000 messages per minute (batch size 10, max concurrency as needed). After setup, verify it works by sending a test message to the queue and checking CloudWatch logs to confirm the Lambda was invoked.
```
