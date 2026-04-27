import boto3
import json

# Create Bedrock runtime client
client = boto3.client(
    "bedrock-runtime",
    region_name="ap-south-1"   # MUST match your ARN region
)

# 🔥 Replace with your actual inference profile ARN
model_id = "arn:aws:bedrock:ap-south-1:658886689551:application-inference-profile/dupcw1x74unc"

prompt = "CPU usage is 95% on instance i-12345. What is the root cause and fix?"

response = client.invoke_model(
    modelId=model_id,
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 300,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ]
    }),
    contentType="application/json",
    accept="application/json"
)

# Parse response
result = json.loads(response["body"].read())

print(result["content"][0]["text"])
