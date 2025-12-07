#!/bin/bash
#
# AWS Serverless MCP Server - Workshop Setup Script
# =================================================
# This script configures Kiro CLI with the AWS Serverless MCP Server
# for the "Building Event-Driven Serverless Applications" workshop.
#
# Prerequisites:
# - Kiro CLI installed (provided by Workshop Studio)
# - AWS credentials configured (provided by Workshop Studio)
# - Python 3.10+ with uv or pip available
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  AWS Serverless MCP Server - Workshop Setup                    ║"
echo "║  Building Event-Driven Serverless Applications with Kiro      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Step 1: Check prerequisites
echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"

# Check if Kiro config directory exists
KIRO_CONFIG_DIR="$HOME/.kiro/settings"
if [ ! -d "$KIRO_CONFIG_DIR" ]; then
    echo -e "${YELLOW}Creating Kiro config directory...${NC}"
    mkdir -p "$KIRO_CONFIG_DIR"
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured. Please run 'aws configure' or check your Workshop Studio setup.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AWS credentials configured${NC}"

# Get AWS region
AWS_REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
echo -e "${GREEN}✓ AWS Region: ${AWS_REGION}${NC}"

# Check for uv - install if not present (recommended for MCP servers)
if command -v uv &> /dev/null; then
    PYTHON_RUNNER="uvx"
    echo -e "${GREEN}✓ uv package manager found${NC}"
else
    echo -e "${YELLOW}uv not found. Installing uv (recommended for MCP servers)...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    if command -v uv &> /dev/null; then
        PYTHON_RUNNER="uvx"
        echo -e "${GREEN}✓ uv installed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to install uv. Please install manually: https://docs.astral.sh/uv/getting-started/installation/${NC}"
        exit 1
    fi
fi

# Step 2: Setup AWS Serverless MCP Server
echo -e "${YELLOW}[2/5] Setting up AWS Serverless MCP Server...${NC}"
echo -e "${GREEN}✓ Will use uvx to run AWS Serverless MCP Server (no installation needed)${NC}"

# Step 3: Create Kiro MCP configuration
echo -e "${YELLOW}[3/5] Configuring Kiro MCP settings...${NC}"

MCP_CONFIG_FILE="$KIRO_CONFIG_DIR/mcp.json"

# Backup existing config if present
if [ -f "$MCP_CONFIG_FILE" ]; then
    cp "$MCP_CONFIG_FILE" "$MCP_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Backed up existing mcp.json${NC}"
fi

# Create MCP configuration using uvx
cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "aws-serverless": {
      "command": "uvx",
      "args": [
        "awslabs-aws-serverless-mcp-server@latest",
        "--allow-write"
      ],
      "env": {
        "AWS_REGION": "${AWS_REGION}",
        "FASTMCP_LOG_LEVEL": "WARNING"
      },
      "disabled": false,
      "autoApprove": [
        "get_lambda_guidance",
        "get_iac_guidance",
        "get_serverless_templates",
        "get_lambda_event_schemas",
        "esm_guidance",
        "list_registries",
        "search_schema",
        "describe_schema"
      ]
    }
  }
}
EOF

echo -e "${GREEN}✓ Kiro MCP configuration created at: $MCP_CONFIG_FILE${NC}"

# Step 4: Create workshop project directory
echo -e "${YELLOW}[4/5] Creating workshop project directory...${NC}"

WORKSHOP_DIR="$HOME/workshop-esm-lambda"
mkdir -p "$WORKSHOP_DIR"

# Create a README with sample prompts
cat > "$WORKSHOP_DIR/README.md" << 'EOF'
# Workshop: Building Event-Driven Serverless Applications

Welcome to the workshop! Your Kiro CLI is now configured with the AWS Serverless MCP Server.

## 🚀 Quick Start

1. Open Kiro CLI
2. Copy one of the prompts below
3. Watch the AI build your serverless infrastructure!

---

## 📋 Sample Prompts for the Workshop

### Challenge 1: SQS → Lambda Event Processing

**Basic SQS Setup:**
```
Create a Lambda function that processes messages from an SQS queue.
- Queue name: workshop-orders-queue
- Lambda runtime: Python 3.12
- Batch size: 10 messages
- Include a Dead Letter Queue for failed messages
- Deploy to my AWS account
```

**Advanced SQS with DynamoDB:**
```
Build an order processing system:
1. SQS queue named 'workshop-orders' with DLQ
2. Lambda function (Python 3.12) that:
   - Receives order messages with fields: orderId, customerId, amount, timestamp
   - Validates the order data
   - Stores valid orders in DynamoDB table 'workshop-orders-table'
   - Logs invalid orders to CloudWatch
3. Configure ESM with batch size 5 and 30-second visibility timeout
4. Deploy everything to AWS
```

---

### Challenge 2: Kinesis → Lambda Stream Processing

**Basic Kinesis Setup:**
```
Create a real-time data pipeline:
- Kinesis stream: workshop-events-stream (1 shard)
- Lambda function (Python 3.12) to process stream records
- Starting position: LATEST
- Batch size: 100 records
- Deploy to AWS
```

**Advanced Kinesis with Analytics:**
```
Build a real-time analytics pipeline:
1. Kinesis stream 'workshop-clickstream' with 2 shards
2. Lambda function that:
   - Processes clickstream events (userId, page, action, timestamp)
   - Aggregates events by userId
   - Stores aggregated data in DynamoDB 'workshop-user-activity'
3. Configure ESM with:
   - Batch size: 100
   - Parallelization factor: 2
   - Maximum retry attempts: 3
   - On-failure destination: SQS DLQ
4. Add CloudWatch alarms for iterator age > 1 minute
5. Deploy to AWS
```

---

### Challenge 3: DynamoDB Streams → Lambda

**Change Data Capture:**
```
Set up DynamoDB change data capture:
1. DynamoDB table 'workshop-products' with streams enabled (NEW_AND_OLD_IMAGES)
2. Lambda function that:
   - Captures INSERT, MODIFY, DELETE events
   - Logs changes to CloudWatch with before/after values
   - Sends notifications for price changes > 10%
3. Configure ESM with batch size 10
4. Deploy to AWS
```

---

### Challenge 4: Multi-Service Event Pipeline

**Complete Event-Driven Architecture:**
```
Build a complete order fulfillment system:

1. API Gateway REST endpoint for order submission
2. Lambda function to validate and queue orders
3. SQS queue for order processing with DLQ
4. Processing Lambda that:
   - Reads from SQS
   - Updates inventory in DynamoDB
   - Publishes to SNS for notifications
5. Kinesis stream for real-time order analytics
6. Analytics Lambda that aggregates order metrics

Include proper IAM roles with least privilege.
Add CloudWatch dashboards for monitoring.
Deploy everything to AWS.
```

---

## 🔧 Troubleshooting Prompts

**If Lambda can't connect to Kinesis:**
```
My Lambda function can't read from Kinesis stream 'workshop-events-stream'.
Diagnose the issue and fix it.
```

**If ESM is not triggering:**
```
My Event Source Mapping for SQS queue 'workshop-orders' is not triggering
the Lambda function. Check the configuration and fix any issues.
```

**Optimize ESM performance:**
```
Optimize my Kinesis ESM configuration for:
- Expected throughput: 1000 records/second
- Target latency: < 1 second
- Minimize costs
```

---

## 📊 Useful Commands

**Check your deployed resources:**
```
List all Lambda functions in my account
```

**View CloudWatch logs:**
```
Show me the recent logs for Lambda function 'workshop-order-processor'
```

**Get ESM status:**
```
What's the status of my Event Source Mappings?
```

---

## 🎯 Success Criteria

By the end of this workshop, you should have:
- ✅ At least one SQS → Lambda pipeline deployed
- ✅ At least one Kinesis → Lambda pipeline deployed  
- ✅ Data flowing through your pipelines
- ✅ CloudWatch monitoring configured
- ✅ Understanding of ESM configuration options

---

## 📚 Resources

- [AWS Serverless MCP Server Documentation](https://awslabs.github.io/mcp/)
- [GitHub Repository](https://github.com/awslabs/mcp/tree/main/src/aws-serverless-mcp-server)
- [AWS Lambda ESM Documentation](https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html)

---

Happy Building! 🚀
EOF

echo -e "${GREEN}✓ Workshop directory created at: $WORKSHOP_DIR${NC}"

# Step 5: Verify setup
echo -e "${YELLOW}[5/5] Verifying setup...${NC}"

# Test MCP server can be invoked
echo "Testing MCP server availability..."
if uvx awslabs-aws-serverless-mcp-server@latest --help &> /dev/null; then
    echo -e "${GREEN}✓ AWS Serverless MCP Server is available${NC}"
else
    echo -e "${YELLOW}⚠ Could not verify MCP server (may work when Kiro starts)${NC}"
fi

# Final summary
echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ Setup Complete!                                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Open Kiro CLI (or restart if already open)"
echo "2. Navigate to: $WORKSHOP_DIR"
echo "3. Open README.md for sample prompts"
echo "4. Start with Challenge 1: SQS → Lambda"
echo ""
echo -e "${BLUE}Workshop Directory:${NC} $WORKSHOP_DIR"
echo -e "${BLUE}MCP Config:${NC} $MCP_CONFIG_FILE"
echo -e "${BLUE}AWS Region:${NC} $AWS_REGION"
echo ""
echo -e "${YELLOW}Tip: If Kiro was already open, restart it to load the new MCP configuration.${NC}"
echo ""
