---
name: embeddings-and-search
description: Use when generating embeddings, calling the 12 web-search providers, or running OCR over documents with the 4 OCR providers through liter-llm. Covers embed, search, and ocr methods plus reranking.
---

# Embeddings and Search

liter-llm exposes embeddings, web search (12 providers), OCR (4 providers), and
reranking through the same `provider/model` routing convention.

## Embeddings

```python
import asyncio, os
from liter_llm import LlmClient

async def main() -> None:
    client = LlmClient(api_key=os.environ["OPENAI_API_KEY"])
    response = await client.embed(
        model="openai/text-embedding-3-small",
        input=["first document", "second document"],
    )
    for item in response.data:
        print(len(item.embedding))

asyncio.run(main())
```

Many embedding models support dimension selection and base64 output; pass
`dimensions` / `encoding_format` where the provider allows it.

## Web search (12 providers)

```python
client = LlmClient(api_key=os.environ["BRAVE_API_KEY"])
response = await client.search(
    model="brave/web-search",
    query="What is the Rust programming language?",
    max_results=5,
)
for result in response.results:
    print(result.title, result.url)
```

## OCR (4 providers)

```python
client = LlmClient(api_key=os.environ["MISTRAL_API_KEY"])
response = await client.ocr(
    model="mistral/mistral-ocr-latest",
    document={"type": "document_url", "url": "https://example.com/invoice.pdf"},
)
for page in response.pages:
    print(page.index, page.markdown[:100])
```

## Reranking

Use `rerank(...)` to score and order candidate documents against a query for
retrieval pipelines — combine it with `embed` for hybrid retrieval. Routing
follows the same `provider/model` convention.

## Notes

- Search and OCR providers each need their own API key (e.g. `BRAVE_API_KEY`,
  `MISTRAL_API_KEY`); read them from env vars.
- See the upstream provider reference for the full list of the 12 search and 4
  OCR backends and their model identifiers.
