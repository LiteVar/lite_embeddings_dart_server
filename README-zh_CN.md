# LiteAgent core Dart Server

[English](README.md) · 中文

大模型嵌入工具的HTTP服务

## 功能

- 支持的向量数据库: Chroma
- 支持的类型：纯文本，包括`Markdown`、`TXT`
- [Dart版本List Embeddings](https://github.com/LiteVar/lite_embeddings_dart)的HTTP Server封装
- [Lite Embeddings Dart的EmbeddingsService](https://github.com/LiteVar/lite_embeddings_dart/blob/master/lib/src/service/service.dart)（包括DTO）基础上，增加Controller、Router等，封装成HTTP API

## 使用

### 1. 准备

1. 准备文本文档，可参照 `/example/docs/*.md` 作为样例
2. 文档内具备`分隔符`
    - 如果是`markdown`文档，推荐采用`<!--分隔符-->`作为分隔符，不影响`markdown`渲染后的展示效果
3. 如果需要运行example，在 `example` 文件夹增加 `.env` 文件，并且`.env`文件需要增加如下内容：
     ```properties
     baseUrl = https://xxx.xxx.com         # 大模型接口的BaseURL
     apiKey = sk-xxxxxxxxxxxxxxxxxxxx      # 大模型接口的ApiKey
     ```

### 2. 开发环境运行server
1. `debug`或者`run`模式运行`/bin/server.dart`文件的`main()`

### 3. HTTP API
- [HTTP API](#31-http命令)

#### 3.1 HTTP命令
- 用于控制文档的增删改查，包括：
  - [/version](#get-version)：版本号，用于确认server在运行
  - [/docs/create-by-text](#post-docscreate-by-text)：创建文档，传入完整文本和分隔符，服务自动分割，写入向量数据库
  - [/docs/create](#post-docscreate)：创建文档，传入手工分割并结构化后的数据，写入向量数据库
  - [/docs/delete](#post-docsdelete)：删除文档，传入文档的id
  - [/docs/list](#get-docslist)：罗列出向量数据库所有现存的文档，包括文档的id和文件名
  - [/docs/rename](#post-docsrename)：重命名文档的文件名
  - [/docs/query](#post-docsquery)：检索查询，返回匹配后的片段数组
  - [/docs/batch-query](#post-docsbatch-query)：单一文档批量检索查询，可以一次性输入多个查询语句，返回多个语句分别匹配后的片段数组
  - [/docs/multi-query](#post-docsmulti-query)：多文档单一查询语句，返回匹配后不同文档下的片段数组
  - [/segment/list](#post-segmentlist)：返回文档对应的所有片段
  - [/segment/insert](#post-segmentinsert)：按位置插入新的片段，如果没有位置信息，默认排到最后
  - [/segment/update](#post-segmentupdate)：更新片段
  - [/segment/delete](#post-segmentdelete)：删除片段

##### BaseURL
- `http://127.0.0.1:9537/api`

##### [GET] /version

- 功能：版本号，一般用于确认server在运行
- 请求参数：无
- 返回样例：

  ```json
  {
      "version": "0.1.0"
  }
  ```

##### [POST] /docs/create-by-text

- 功能：创建文档，传入完整文本和分隔符，服务自动分割，写入向量数据库
- 请求参数：
  - 文档相关：文件名、全文、分隔符、元数据、大模型配置
  - 关于元数据：可选，为每个分段都一样的metadata。系统会默认生成带有`vdb`和`embeddings_model`的metadata
  - 请求样例
  ```json
  {
    "docsName": "<文档的名称，例如：摩尔定律使用于一切.md>",
    "text": "<文档的文本全文，带有分隔符>",
    "separator": "<分隔符的文本>",
    "metadata": "<（可选）每个分段的metadata：json map，结构体的值只支持数字、文本、布尔值，不支持对象和数组，每个片段都使用相同的metadata>",
    "llmConfig": {
      "baseUrl": "<大模型API的baseUrl，例如：https://api.openai.com/v1>>",
      "apiKey": "<大模型API的apiKey，例如：sk-xxxxxxxxxx>",
      "model": "<大模型API的嵌入模型名称，例如：text-embedding-ada-002>"
    }
  }
  ```
- 返回：
  - 创建成功的文档信息，包括文档的Id、文件名、token消耗
  - 返回样例
  ```json
  {
    "docsId": "<文档对应的Id>",
    "docsName": "<文档的文件名>",
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /docs/create

- 功能：创建文档，传入手工分割并结构化后的数据，写入向量数据库
- 请求参数：
  - 文档相关：文件名、各个片段及其对应的元数据、大模型配置
  - 关于元数据：可选，系统会默认生成带有`vdb`和`embeddings_model`的metadata
  - 请求样例
  ```json
  {
    "docsName": "<文档的名称，例如：摩尔定律使用于一切.md>",
    "segmentList": [
      { 
        "text": "<片段的原文>",
        "metadata": "<可选，json map，结构体的值只支持数字、文本、布尔值，不支持对象和数组>"
      }
    ],
    "llmConfig": {
      "baseUrl": "<大模型API的baseUrl，例如：https://api.openai.com/v1>>",
      "apiKey": "<大模型API的apiKey，例如：sk-xxxxxxxxxx>",
      "model": "<大模型API的嵌入模型名称，例如：text-embedding-ada-002>"
    }
  }
  ```
- 返回：
  - 创建成功的文档信息，包括文档的Id、文件名、token消耗
  - 返回样例
  ```json
  {
    "docsId": "<文档对应的Id>",
    "docsName": "<文档的文件名>",
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /docs/delete

- 功能：删除文档，传入文档的id
- 请求参数：
  - 文档Id
  - 请求样例
  ```json
  {
    "docsId": "xxxxxxxx"
  }
  ```
- 返回：
  - 删除成功的文档信息，包括文档的Id
  - 返回样例
  ```json
  {
    "docsId": "xxxxxxxx"
  }
  ```

##### [GET] /docs/list

- 功能：罗列出向量数据库所有现存的文档，包括文档的id和文件名
- 请求参数：无
- 返回：
  - 文档信息列表，包括每个文档的Id和文件名
  - 返回样例
  ```json
  [ 
    {
      "docsId": "<文档对应的Id>",
      "docsName": "<文档的文件名>"
    }
  ]
  ```

##### [POST] /docs/rename

- 功能：重命名文档的文件名
- 请求参数：
  - 文档Id，新的文件名
  - 请求样例
  ```json
  {
    "docsId": "<文档对应的Id>",
    "docsName": "<文档的文件名>"
  }
  ```
- 返回：
  - 修改成功的文档信息，包括文档的Id，新的文件名
  - 返回样例
  ```json
  {
    "docsId": "<文档对应的Id>",
    "docsName": "<文档的文件名>"
  }
  ```

##### [POST] /docs/query

- 功能：检索查询，返回匹配后的片段数组
- 请求参数：
  - 文档Id，查询关键文字，返回结果的数量
  - 请求样例
  ```json
  {
    "docsId": "xxxxxxxx",
    "queryText": "<需要匹配的关键文字>",
    "nResults": "<（可选）正整数，默认为2，按距离从小到大，返回匹配片段的数量>",
    "llmConfig": {
      "baseUrl": "<大模型API的baseUrl，例如：https://api.openai.com/v1>>",
      "apiKey": "<大模型API的apiKey，例如：sk-xxxxxxxxxx>",
      "model": "<大模型API的嵌入模型名称，例如：text-embedding-ada-002>"
    }
  }
  ```
- 返回：
  - 文档Id、片段信息的数组、token消耗
  - 返回样例
  ```json
  {
    "docsId": "xxxxxxxx",
    "segmentResultList": [
      {
        "segmentId": "<片段Id>",
        "text": "<片段文字>",
        "metadata": "<json map，片段附带的metadata>",
        "distance": "<0.x的小数，片段匹配向量的距离，越小说明越相近>"
      }
    ],
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /docs/batch-query

- 功能：批量检索查询，可以一次性输入多个查询语句，返回多个语句分别匹配后的片段数组
- 请求参数：
  - 文档Id、查询关键文字的数组、返回结果数量、大模型配置
  - 请求样例
  ```json
  {
    "docsId": "xxxxxxxx",
    "queryTextList": [
      "<查询文字1>",
      "<查询文字2>"
    ],
    "nResults": "<（可选）正整数，默认为2，每一个查询文字都返回的数量，按匹配度从高到低排>",
    "llmConfig": {
      "baseUrl": "<大模型API的baseUrl，例如：https://api.openai.com/v1>>",
      "apiKey": "<大模型API的apiKey，例如：sk-xxxxxxxxxx>",
      "model": "<大模型API的嵌入模型名称，例如：text-embedding-ada-002>"
    }
  }
  ```
- 返回：
  - 检索成功的结果，包括文档ID、片段结果数组组成对象的数组、token消耗
  - 返回样例
  ```json
  [
    {
      "docsId": "xxxxxxxx",
      "segmentResultList": [
        {
          "segmentId": "<片段Id>",
          "text": "<片段文字>",
          "metadata": "<json map，片段附带的metadata>",
          "distance": "<0.x的小数，片段匹配向量的距离，越小说明越相近>"
        }
      ],
      "tokenUsage": {
        "promptToken": "",
        "totalToken": ""
      }
    }
  ]
  ```

##### [POST] /docs/multi-query

- 功能：多文档单一查询语句，返回匹配后不同文档下的片段数组
- 请求参数：
  - 文档Id的数组、查询关键文字、返回结果数量、大模型配置
  - 请求样例
  ```json
  {
    "docsIdList": ["xxxxxxxx", "yyyyyyyy"],
    "queryText": "<查询文字1>",
    "nResults": "<（可选）正整数，默认为2，每一个查询文字都返回的数量，按匹配度从高到低排>",
    "removeDuplicates": "<（可选）布尔值，默认：true，去除返回的片段列表中，文本部分相同的片段>",
    "llmConfig": {
      "baseUrl": "<大模型API的baseUrl，例如：https://api.openai.com/v1>>",
      "apiKey": "<大模型API的apiKey，例如：sk-xxxxxxxxxx>",
      "model": "<大模型API的嵌入模型名称，例如：text-embedding-ada-002>"
    }
  }
  ```
- 返回：
  - 检索成功的结果，片段信息的数组，数组每个对象包括文档ID、片段ID片段文字、metadata、distance、token消耗
  - 返回样例
  ```json
  {
    "segmentResultList": [
      {
        "docsId": "xxxxxxxx",
        "segmentId": "<片段Id>",
        "text": "<片段文字>",
        "metadata": "<json map，片段附带的metadata>",
        "distance": "<0.x的小数，片段匹配向量的距离，越小说明越相近>"
      }
    ],
    "tokenUsage": {
      "promptToken": "",
      "totalToken": ""
    }
  }
  ```

##### [POST] /segment/list

- 功能：返回文档对应的所有片段
- 请求参数：
  - 文档Id
  - 请求样例
  ```json
  {
  "docsId": "xxxxxxxx"
  }
  ```
- 返回：
  - 文档Id、文件名、所有片段的数组
  - 返回样例
  ```json
  {
    "docsId": "xxxxxxxx",
    "docsName": "<文档文件名>",
    "segmentInfoList": [
      {
        "SegmentId": "<片段Id>",
        "text": "<片段文字>",
        "metadata": "<json map，片段附带的metadata>"
      }
    ] 
  }
  ```

##### [POST] /segment/insert

- 功能：按位置插入新的片段，如果没有位置信息，默认排到最后
- 请求参数：
  - 文档Id、新的片段信息、插入位置、大模型配置
  - 关于元数据：可选，系统会默认生成带有`vdb`和`embeddings_model`的metadata
  - 请求样例
  ```json
  {
    "docsId": "xxxxxxxx",
    "segment": {
      "text": "<片段文字>",
      "metadata": "<可选，json map，片段附带的metadata>"
    },
    "index": "（可选）正整数，如果为空，或者大于原长度，则默认添加到末尾",
    "llmConfig": {
      "baseUrl": "<大模型API的baseUrl，例如：https://api.openai.com/v1>>",
      "apiKey": "<大模型API的apiKey，例如：sk-xxxxxxxxxx>",
      "model": "<大模型API的嵌入模型名称，例如：text-embedding-ada-002>"
    }
  }
  ```
- 返回：
  - 插入成功的片段、片段Id、token消耗
  - 返回样例
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

- 功能：更新片段
- 请求参数：
  - 文档Id、新的片段信息、大模型配置
  - 关于元数据，可选，有如下情况：
    - `null`：不更新原有metadata
    - `{}`：清空
    - 有数值：增加或是变更到原有meta中
  - 请求样例
  ```json
  {
    "docsId": "xxxxxxxx",
    "segment": {
      "segmentId": "<片段Id>",
      "text": "<片段文字>",
      "metadata": "<可选，json map，片段附带的metadata>"
    },
    "llmConfig": {
      "baseUrl": "<大模型API的baseUrl，例如：https://api.openai.com/v1>>",
      "apiKey": "<大模型API的apiKey，例如：sk-xxxxxxxxxx>",
      "model": "<大模型API的嵌入模型名称，例如：text-embedding-ada-002>"
    }
  }
  ```
- 返回：
  - 片段Id、token消耗
  - 返回样例
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

- 功能：删除片段
- 请求参数：
  - 需要删除的片段所在的文档Id、片段Id
  - 请求样例
  ```json
  {
    "docsId": "xxxxxxxx",
    "segmentId": "xxxxxxxx"
  }
  ```
- 返回：
  - 删除成功的片段Id
  - 返回样例
  ```json
  {
    "segmentId": "xxxxxxxx"
  }
  ```

## 构建运行
1. 命令行在项目根目录运行如下命令：
    ```shell
    dart compile exe bin/server.dart -o build/lite_embeddings_dart_server
    ```
2. 在build文件夹下，有`lite_embeddings_dart_server`文件
3. 把项目根目录的`config.json`文件复制到`lite_embeddings_dart_server`文件同一目录
4. 命令行运行，例如：
    ```shell
    ./lite_embeddings_dart_server
    ```
5. 命令行会有如下提示，即启动成功：
    ```
    INFO: 2024-06-24 14:48:05.862057: PID 34567: [HTTP] Start Server - http://0.0.0.0:9537/api
    ```
6. 运行启动后，同级目录将会出现`log`文件夹，文件夹中有`embeddings.log`文件，用以记录运行过程的日志