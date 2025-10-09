type OpenApi.Spec {
  components : Maybe(OpenApi.Components),
  paths : Map(String, OpenApi.PathItem),
  info : OpenApi.Info,
  openapi : String
}

type OpenApi.Components {
  schemas : Map(String, OpenApi.Schema),
  responses : Maybe(Map(String, OpenApi.Response))
}

type OpenApi.Schema {
  properties : Maybe(Map(String, OpenApi.Schema)),
  additionalProperties : Maybe(Bool),
  required : Maybe(Array(String)),
  allOf : Maybe(Array(OpenApi.Schema)),
  oneOf : Maybe(Array(OpenApi.Schema)),
  items : Maybe(OpenApi.Schema),
  enum : Maybe(Array(String)),
  format : Maybe(String),
  type : Maybe(String),
  ref : Maybe(String) using "$ref"
}

type OpenApi.PathItem {
  get : Maybe(OpenApi.Operation),
  post : Maybe(OpenApi.Operation),
  put : Maybe(OpenApi.Operation),
  delete : Maybe(OpenApi.Operation)
}

type OpenApi.Operation {
  requestBody : Maybe(OpenApi.RequestBody),
  responses : Map(String, OpenApi.Response),
  parameters : Maybe(Array(OpenApi.Parameter)),
  operationId : Maybe(String),
  summary : Maybe(String)
}

type OpenApi.RequestBody {
  content : Map(String, OpenApi.MediaType),
  required : Maybe(Bool)
}

type OpenApi.Response {
  content : Maybe(Map(String, OpenApi.MediaType)),
  description : String
}

type OpenApi.MediaType {
  schema : Maybe(OpenApi.Schema)
}

type OpenApi.Parameter {
  schema : Maybe(OpenApi.Schema),
  required : Maybe(Bool),
  name : String,
  in : String
}