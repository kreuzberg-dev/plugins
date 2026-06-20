---
name: tool-calling
description: Use when defining functions/tools for an LLM to call through liter-llm, or requesting structured JSON outputs. Covers tool schemas, tool_calls handling, and response formats.
---

# Tool Calling

Pass a `tools` array of function definitions; the model may respond with
`tool_calls` instead of (or alongside) text. Execute the named function and feed
the result back as a `tool` message.

## Python

```python
import asyncio, os
from liter_llm import LlmClient

tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get the current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {"type": "string", "description": "City name"},
                },
                "required": ["location"],
            },
        },
    }
]

async def main() -> None:
    client = LlmClient(api_key=os.environ["OPENAI_API_KEY"])
    response = await client.chat(
        model="openai/gpt-4o",
        messages=[{"role": "user", "content": "Weather in Berlin?"}],
        tools=tools,
    )
    choice = response.choices[0]
    for call in choice.message.tool_calls or []:
        print(call.function.name, call.function.arguments)  # arguments is a JSON string

asyncio.run(main())
```

## Structured outputs

Request strict JSON with `response_format`:

```python
response = await client.chat(
    model="openai/gpt-4o",
    messages=[{"role": "user", "content": "Extract name and age as JSON."}],
    response_format={"type": "json_object"},
)
```

## Notes

- `function.arguments` is a JSON **string** — parse it before use.
- Append each tool result as a message with `role="tool"` and the matching
  `tool_call_id`, then call `chat` again to let the model continue.
- Tool support and JSON-mode availability vary by provider; check the provider
  reference if a model ignores `tools`.
