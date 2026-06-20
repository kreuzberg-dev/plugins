---
name: calling-llms
description: Use when sending chat completions through liter-llm and routing to a specific provider via the `provider/model` prefix. Covers the chat call shape, provider routing, model_hint, message roles, and error categories.
---

# Calling LLMs

Send a chat completion with `client.chat(...)`. The model string is
`provider/model`; the prefix selects the backend.

```python
import asyncio, os
from liter_llm import LlmClient

async def main() -> None:
    client = LlmClient(api_key=os.environ["OPENAI_API_KEY"])
    response = await client.chat(
        model="openai/gpt-4o",
        messages=[
            {"role": "system", "content": "You are concise."},
            {"role": "user", "content": "Name three Rust crates for HTTP."},
        ],
    )
    print(response.choices[0].message.content)

asyncio.run(main())
```

## Provider routing

```python
await client.chat(model="anthropic/claude-sonnet-4-20250514", messages=[...])
await client.chat(model="google/gemini-2.0-flash", messages=[...])
await client.chat(model="groq/llama3-70b", messages=[...])
await client.chat(model="mistral/mistral-large-latest", messages=[...])
await client.chat(model="bedrock/anthropic.claude-v2", messages=[...])
```

Set `model_hint` at construction to drop the prefix on every call:

```python
client = LlmClient(api_key="sk-...", model_hint="openai")
await client.chat(model="gpt-4o", messages=[...])  # routes to OpenAI
```

## Notes

- Keys come from env vars (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, …); never
  hardcode them.
- Without a prefix and without `model_hint`, routing fails.
- Errors share a category: `Authentication`, `RateLimited`, `BadRequest`,
  `ContextWindowExceeded`, `ContentPolicy`, `NotFound`, `Server`,
  `ServiceUnavailable`, `Timeout`, `BudgetExceeded`.
