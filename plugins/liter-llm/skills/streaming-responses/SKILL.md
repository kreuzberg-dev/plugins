---
name: streaming-responses
description: Use when streaming tokens incrementally from an LLM via liter-llm over SSE or async iterators. Covers chat_stream, delta handling, and null-content chunks.
---

# Streaming Responses

Use `chat_stream(...)` to receive tokens as they are produced instead of waiting
for the full completion. The proxy streams over SSE; bindings expose async
iterators.

## Python

```python
import asyncio, os
from liter_llm import LlmClient

async def main() -> None:
    client = LlmClient(api_key=os.environ["OPENAI_API_KEY"])
    async for chunk in await client.chat_stream(
        model="openai/gpt-4o",
        messages=[{"role": "user", "content": "Tell me a story"}],
    ):
        if chunk.choices and chunk.choices[0].delta.content:
            print(chunk.choices[0].delta.content, end="", flush=True)
    print()

asyncio.run(main())
```

## TypeScript

```typescript
const chunks = await client.chatStream({
  model: "openai/gpt-4o",
  messages: [{ role: "user", content: "Tell me a story" }],
});
for (const chunk of chunks) {
  process.stdout.write(chunk.choices[0]?.delta?.content ?? "");
}
```

## Notes

- The first and last chunks often carry null content. Always null-check
  `chunk.choices[0].delta.content` (Python) or
  `chunk.choices[0]?.delta?.content` (TypeScript) before using it.
- Tool-call deltas arrive in `delta.tool_calls`; accumulate
  `function.arguments` fragments across chunks before parsing.
- Through the proxy, request streaming with `"stream": true` on
  `/v1/chat/completions`.
