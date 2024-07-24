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
- Docs CRUD API, include: 
  - `/version`: get version number, to confirm server running
  - `/init`: post the llm config to initial the embeddings service
  - `/docs/create-by-text`: Create docs embeddings, post whole text and separator, service will split and write to vector database
  - `/docs/create`: Create docs embeddings, post the split docs, service will write to vector database
  - `/docs/delete`: Delete docs, post docsId
  - `/docs/list`: List all docs, return docsId and docsName Array
  - `/docs/rename`: Rename docsName
  - `/docs/query`: Text query, return N segment array with distance sort
  - `/docs/batch-query`: Text array query, query multi text at once, return N segment array in array
  - `/docs/multi-query`: Docs array query, query multi docs with one text, return N segment with docsId array
  - `/segment/list`: List all segments in the docs
  - `/segment/insert`: Insert segment by index. If not index, new segment will be inserted at last
  - `/segment/update`: Update segment
  - `/segment/delete`: Delete segment
  - `/dispose`: Dispose vector database connection

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

##### [POST] /init

- Feature: post the llm config to initial the embeddings service
- Request params: 
  - LLM config: baseUrl, apiKey, model
  - Sample: 
  ```json
  {
    "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
    "apiKey": "<LLM API apiKey, e.g. sk-xxxxxxxxxx>",
    "model": "<LLM API embeddings model name, e.g. : text-embedding-ada-002>"
  }
  ```

- Response body: 
  - Echo init info, include vectorDatabase name, baseUrl, embeddingsModel
  - Response body sample
  ```json
    {
      "vectorDatabase": "<Vector Database name, e.g. : chroma>",
      "baseUrl": "<LLM API baseUrl, e.g. https://api.openai.com/v1>>",
      "embeddingsModel": "<LLM API embeddings model name, e.g. : text-embedding-ada-002>"
    }
  ```

##### [POST] /docs/create-by-text

- Feature: Create docs embeddings, post whole text and separator, service will split and write to vector database
- Request params: 
  - Docs info: docsName, text, separator, metadata
  - Sample
  ```json
  {
    "docsName": "<Docs name, e.g. Moore's Law for Everything.md>",
    "text": "<Docs full text, with separetor>",
    "separator": "<Separator text>",
    "metadata": "<json map, value only int, float, string, bool, NOT support object and array. Each segment with same metadata>"
  }
  ```
- Response body: 
  - Create successful docs info: docsId, docsName
  - Response body sample
  ```json
  {
    "docsId": "<Docs Id>",
    "docsName": "<Docs Name>"
  }
  ```

##### [POST] /docs/create

- Feature: Create docs embeddings, post the split docs, service will write to vector database
- Request params: 
  - Docs info: docsName, segment and metadata array 
  - Sample
  ```json
  {
    "docsName": "<Docs name, e.g. Moore's Law for Everything.md>",
    "segmentList": [
      { 
        "text": "<Segment text>",
        "metadata": "<json map, value only int, float, string, bool, NOT support object and array>"
      }
    ]
  }
  ```
- Response body: 
  - Create successful docs info: docsId, docsName
  - Response body sample
  ```json
  {
    "docsId": "<Docs Id>",
    "docsName": "<Docs Name>"
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
  - docsId, queryText, return query result count
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "queryText": "<query text string>",
    "nResults": "<UInt, return query result by sort number>"
  }
  ```
- Response body: 
  - docsId, segmentResultList
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
    ]
  }
  ```

##### [POST] /docs/batch-query

- Feature: Text array query, query multi text at once, return N segment array in array
- Request params: 
  - docsId, queryText array, return query result count
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "queryTextList": [
      "<Query Text 1>",
      "<Query Text 2>"
    ],
    "nResults": "<UInt, return query result by sort number>"
  }
  ```
- Response body: 
  - Query result: docsId and segmentResultList array
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
      ]
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
    "nResults": "<UInt, return query result by sort number>"
  }
  ```
- Response body:
  - Query result: segment info array, include docsId, segmentId, segment text, metadata, distance
  - Response body sample
  ```json
  [
    {
      "docsId": "xxxxxxxx",
      "segmentId": "<Segment Id>",
      "text": "<Segment text>",
      "metadata": "<json map, segment with>",
      "distance": "<0.x float, segment match distance, smaller means closer>"
    }
  ]
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
  - docsId, new segment, index
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "segment": {
      "text": "<Segment text>",
      "metadata": "<json map, segment with>"
    },
    "index": "(Optional) UInt, if null or large than length, be inserted at last"
  }
  ```
- Response body: 
  - new Segment ID
  - Response body sample
  ```json
  {
    "segmentId": "xxxxxxxx"
  }
  ```

##### [POST] /segment/update

- Feature: Update segment
- Request params: 
  - docsId, segment
  - Sample
  ```json
  {
    "docsId": "xxxxxxxx",
    "segment": {
      "segmentId": "Segment Id",
      "text": "<Segment text>",
      "metadata": "<json map, segment with>"
    }
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

##### [POST] /dispose

- Feature: Dispose vector database connection
- Request params: 
- Response body: 
    - Dispose successfully text
    - Response body sample
  ```
  "Dispose successfully."
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