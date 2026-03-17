import openai
from openai import OpenAI
import os

# Initialize the OpenRouter client
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="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"
)

# Stream the response
stream = client.chat.completions.create(
    # model="stepfun/step-3.5-flash:free",
    model="openrouter/hunter-alpha",
    # model="nvidia/nemotron-3-super-120b-a12b:free",
    messages=[
        {
            "role": "user",
            "content": "How many r's are in the word 'strawberry'?"
        }
    ],
    stream=True
)

response = ""
for chunk in stream:
    content = chunk.choices[0].delta.content
    if content:
        response += content
        print(content, end="", flush=True)

# The final usage information is in the last chunk
print(f"\nTotal tokens used: {chunk.usage.total_tokens if chunk.usage else 'N/A'}")
