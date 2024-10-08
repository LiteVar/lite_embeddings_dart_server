# Lite Embeddings Dart Server

English · [中文](README-zh_CN.md)

LLM Embedding tool HTTP service

## Feature

- Support Vector Database: Chroma
- Support file type: pure text, include `Markdown`, `TXT`
- HTTP API Wrapper of [Dart List Embeddings](https://github.com/LiteVar/lite_embeddings_dart)
- Base on [Lite Embeddings Dart的EmbeddingsService](https://github.com/LiteVar/lite_embeddings_dart/blob/master/lib/src/service/service.dart)(DTO included), add Controller、Router, wrapper to HTTP/WS API.

## Usage

### 1. Prepare

1. Docs file, according to `/example/docs/*.md`
2. `Separator` in the file
    - If `markdown` file, recommend to use `<!--SEPARATOR-->` as separator, for NOT show it in `markdown` after rendering
3. Add `.env` file in the `example` folder, and add below content in the `.env` file: 
     ```properties
     baseUrl = https://xxx.xxx.com         # LLM API BaseURL
     apiKey = sk-xxxxxxxxxxxxxxxxxxxx      # LLM API ApiKey
     ```

### 2. Develop run server
1. `debug` or `run` mode run `/bin/server.dart` file `main()`

### 3. HTTP API
- [HTTP API](#31-http-API)

#### 3.1 HTTP API
- Docs API, include: 
  - [/version](#get-version): get version number, to confirm server running
  - [/docs/create-by-text](#post-docscreate-by-text): Create docs embeddings, post whole text and separator, service will split and write to vector database
  - [/docs/create](#post-docscreate): Create docs embeddings, post the split docs, service will write to vector database
  - [/docs/delete](#post-docsdelete): Delete docs, post docsId
  - [/docs/list](#get-docslist): List all docs, return docsId and docsName Array
  - [/docs/rename](#post-docsrename): Rename docsName
  - [/docs/query](#post-docsquery): Text query, return N segment array with distance sort
  - [/docs/batch-query](#post-docsbatch-query): Text array query, query multi text at once, return N segment array in array
  - [/docs/multi-query](#post-docsmulti-query): Docs array query, query multi docs with one text, return N segment with docsId array
  - [/segment/list](#post-segmentlist): List all segments in the docs
  - [/segment/insert](#post-segmentinsert): Insert segment by index. If not index, new segment will be inserted at last
  - [/segment/update](#post-segmentupdate): Update segment
  - [/segment/delete](#post-segmentdelete): Delete segment

##### BaseURL
- `http://127.0.0.1:9537/api`

##### [GET] /version

- Feature: get version number, to confirm server running
- Request params: null
- Response body sample: 

  ```json
  {
      "version": "0.1.0"
  }
  ```

##### [POST] /docs/create-by-text

- Feature: Create docs embeddings, post whole text and separator, service will split and write to vector database
- Request params: 
  - Docs info: docsName, text, separator, metadata, LLM Config
  - About metadata: Optional, same metadata for each segment. Default metadata include `vdb` and `embeddings_model`.
  - Sample
  ```json
  {
    "docsName": "<Docs name, e.g. Moore's Law for Everything.md>",
    "text": "<Docs full text, with separetor>",
    "separator": "<Separator text>",
    "metadata": "<Optional, in each segment, json map, value only int, float, string, bool, NOT support object and array. Each segment with same metadata>",
    "llmConfig": {
      "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
      "apiKey": "<LLM API apiKey, e.g. sk-xxxxxxxxxx>",
      "model": "<LLM API embeddings model name, e.g. text-embedding-ada-002>"
    }
  }
  ```
- Response body: 
  - Create successful docs info: docsId, docsName, Token Usage
  - Response body sample
  ```json
  {
    "docsId": "<Docs Id>",
    "docsName": "<Docs Name>",
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /docs/create

- Feature: Create docs embeddings, post the split docs, service will write to vector database
- Request params: 
  - Docs info: docsName, segment and metadata array, LLM Config
  - About metadata: Optional, default metadata include `vdb` and `embeddings_model`.
  - Sample
  ```json
  {
    "docsName": "<Docs name, e.g. Moore's Law for Everything.md>",
    "segmentList": [
      { 
        "text": "<Segment text>",
        "metadata": "<Optional, json map, value only int, float, string, bool, NOT support object and array>"
      }
    ],
    "llmConfig": {
      "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
      "apiKey": "<LLM API apiKey, e.g. sk-xxxxxxxxxx>",
      "model": "<LLM API embeddings model name, e.g. text-embedding-ada-002>"
    }
  }
  ```
- Response body: 
  - Create successful docs info: docsId, docsName, Token Usage
  - Response body sample
  ```json
  {
    "docsId": "<Docs Id>",
    "docsName": "<Docs Name>",
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /docs/delete

- Feature: Delete docs, post docsId
- Request params: 
  - DocsId
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx"
  }
  ```
- Response body: 
  - Docs be deleted info: docsId
  - Response body sample
  ```json
  {
    "docsId": "xxxxxxxx"
  }
  ```

##### [GET] /docs/list

- Feature: List all docs, return docsId and docsName Array
- Request params: null
- Response body: 
  - Docs info list: docsId and docsName
  - Response body sample
  ```json
  [ 
    {
      "docsId": "<Docs Id>",
      "docsName": "<Docs Name>"
    }
  ]
  ```

##### [POST] /docs/rename

- Feature: Rename docsName
- Request params: 
  - docsId, new docsName
  - Sample
  ```json
  {
    "docsId": "<Docs Id>",
    "docsName": "<Docs Name>"
  }
  ```
- Response body: 
  - Docs be modified info: docsId and docsName
  - Response body sample
  ```json
  {
    "docsId": "<Docs Id>",
    "docsName": "<Docs Name>"
  }
  ```

##### [POST] /docs/query

- Feature: Text query, return N segment array with distance sort
- Request params: 
  - docsId, queryText, return query result count, LLM Config
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "queryText": "<query text string>",
    "nResults": "<UInt, return query result by sort number>",
    "llmConfig": {
      "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
      "apiKey": "<LLM API apiKey, e.g. sk-xxxxxxxxxx>",
      "model": "<LLM API embeddings model name, e.g. text-embedding-ada-002>"
    }
  }
  ```
- Response body: 
  - docsId, segmentResultList, Token Usage
  - Response body sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "segmentResultList": [
      {
        "segmentId": "<Segment Id>",
        "text": "<Segment text>",
        "metadata": "<json map, segment with>",
        "distance": "<0.x float, segment match distance, smaller means closer>"
      }
    ],
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /docs/batch-query

- Feature: Text array query, query multi text at once, return N segment array in array
- Request params: 
  - docsId, queryText array, return query result count, LLM Config
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "queryTextList": [
      "<Query Text 1>",
      "<Query Text 2>"
    ],
    "nResults": "<UInt, return query result by sort number>",
    "llmConfig": {
      "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
      "apiKey": "<LLM API apiKey, e.g. sk-xxxxxxxxxx>",
      "model": "<LLM API embeddings model name, e.g. text-embedding-ada-002>"
    }
  }
  ```
- Response body: 
  - Query result: docsId, segmentResultList array, Token Usage
  - Response body sample
  ```json
  [
    {
      "docsId": "xxxxxxxx",
      "segmentResultList": [
        {
          "segmentId": "<Segment Id>",
          "text": "<Segment text>",
          "metadata": "<json map, segment with>",
          "distance": "<0.x float, segment match distance, smaller means closer>"
        }
      ],
      "tokenUsage": {
        "promptToken": "",
        "totalToken": ""
      }
    }
  ]
  ```

- `/docs/multi-query`: 

##### [POST] /docs/multi-query

- Feature: Docs array query, query multi docs with one text, return N segment with docsId array
- Request params:
  - docsId array, queryText, return query result count
  - Sample
  ```json
  {
    "docsIdList": ["xxxxxxxx", "yyyyyyyy"],
    "queryText": "<Query Text 1>",
    "nResults": "<UInt, return query result by sort number>",
    "removeDuplicates": "<(Optional)boolean, default:true, return segments will be removed if same text>",
    "llmConfig": {
      "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
      "apiKey": "<LLM API apiKey, e.g. sk-xxxxxxxxxx>",
      "model": "<LLM API embeddings model name, e.g. text-embedding-ada-002>"
    }
  }
  ```
- Response body:
  - Query result: segment info array, include docsId, segmentId, segment text, metadata, distance
  - Response body sample
  ```json
  {
    "segmentResultList": [
      {
        "docsId": "xxxxxxxx",
        "segmentId": "<Segment Id>",
        "text": "<Segment text>",
        "metadata": "<json map, segment with>",
        "distance": "<0.x float, segment match distance, smaller means closer>"
      }
    ],
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /segment/list

- Feature: List all segments in the docs
- Request params: 
  - docsId
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx"
  }
  ```
- Response body: 
  - docsId, docsName, segment info list
  - Response body sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "docsName": "<Docs Name>",
    "segmentInfoList": [
      {
        "SegmentId": "<Segment Id>",
        "text": "<Segment text>",
        "metadata": "<json map, segment with>"
      }
    ] 
  }
  ```

##### [POST] /segment/insert

- Feature: Insert segment by index. If not index, new segment will be inserted at last
- Request params: 
  - docsId, new segment, index, LLM Config
  - About metadata: Optional, default metadata include `vdb` and `embeddings_model`.
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "segment": {
      "text": "<Segment text>",
      "metadata": "<Optional, json map, segment with>"
    },
    "index": "(Optional) UInt, if null or large than length, be inserted at last",
    "llmConfig": {
      "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
      "apiKey": "<LLM API apiKey, e.g. sk-xxxxxxxxxx>",
      "model": "<LLM API embeddings model name, e.g. text-embedding-ada-002>"
    }
  }
  ```
- Response body: 
  - new Segment ID, Token Usage
  - Response body sample
  ```json
  {
    "segmentId": "xxxxxxxx",
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /segment/update

- Feature: Update segment
- Request params: 
  - docsId, segment, LLM Config
  - About metadata, optional:
    - `null`: NOT update current metadata
    - `{}`: clear metadata, but remain default metadata include `vdb` and `embeddings_model`
    - values: add or update current metadata
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "segment": {
      "segmentId": "Segment Id",
      "text": "<Segment text>",
      "metadata": "<Optional, json map, segment with>"
    },
    "llmConfig": {
      "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
      "apiKey": "<LLM API apiKey, e.g. sk-xxxxxxxxxx>",
      "model": "<LLM API embeddings model name, e.g. text-embedding-ada-002>"
    }
  }
  ```
- Response body: 
  - Segment Id, Token Usage
  - Response body sample
  ```json
  {
    "segmentId": "xxxxxxxx",
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /segment/delete

- Feature: Delete segment
- Request params: 
  - Segment be deleted docsId and segmentId
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "segmentId": "xxxxxxxx"
  }
  ```
- Response body: 
    - Segment Id
    - Response body sample
  ```json
  {
    "segmentId": "xxxxxxxx"
  }
  ```

## Build and Run
1. Build in shell script:
    ```shell
    dart compile exe bin/server.dart -o build/lite_embeddings_dart_server
    ```
2. Then the `lite_embeddings_dart_server` file will be in `build` folder
3. Copy `config.json` file to `lite_embeddings_dart_server` same folder
4. Run in shell script:
    ```shell
    ./lite_embeddings_dart_server
    ```
5. Terminal will show:
    ```
    INFO: 2024-06-24 14:48:05.862057: PID 34567: [HTTP] Start Server - http://0.0.0.0:9537/api
    ```
6. After server running, will create `log` folder and `embeddings.log` file in the folder, to record server running logs.