module OpenApi.ApiGenerator {
  // Generate HTTP client functions from OpenAPI paths
  fun generateApiModule(
    spec : OpenApi.Spec,
    moduleName : String
  ) : String {
    let functions =
      for path, pathItem of spec.paths {
        generatePathFunctions(path, pathItem)
      }
      |> Array.concat
      |> String.join("\n\n")
    
    <<~MINT
    module \#{moduleName} {
      const BASE_URL = ""
      
      \#{functions}
    }
    MINT
  }
  
  fun generatePathFunctions(
    path : String,
    pathItem : OpenApi.PathItem
  ) : Array(String) {
    [
      Maybe.map(pathItem.get, generateOperation("get", path, _)),
      Maybe.map(pathItem.post, generateOperation("post", path, _)),
      Maybe.map(pathItem.put, generateOperation("put", path, _)),
      Maybe.map(pathItem.delete, generateOperation("delete", path, _))
    ]
    |> Array.compact
  }
  
  fun generateOperation(
    method : String,
    path : String,
    operation : OpenApi.Operation
  ) : String {
    let functionName =
      operation.operationId
      or "\#{method}\#{sanitizePath(path)}"
    
    let parameters =
      operation.parameters
      or []
    
    let paramString =
      for param of parameters {
        let paramType = 
          Maybe.map(param.schema, OpenApi.TypeGenerator.openApiTypeToMint)
          or "String"
        
        "\#{param.name} : \#{paramType}"
      }
      |> String.join(", ")
    
    let Ok(response) =
      Map.values(operation.responses)
      |> Array.first
      or return ""
    
    let responseType =
      response.content
      |> Maybe.andThen(Map.get(_, "application/json"))
      |> Maybe.andThen((mediaType : OpenApi.MediaType) { mediaType.schema })
      |> Maybe.map(OpenApi.TypeGenerator.openApiTypeToMint)
      or "Object"
    
    <<~MINT
    fun \#{functionName}(\#{paramString}) : Promise(Result(Http.ErrorResponse, \#{responseType})) {
      let url = BASE_URL + "\#{path}"
      
      Http.\#{method}(url)
      |> Http.send()
      |> Promise.map(
        (response : Http.Response) {
          case response.body {
            Json(object) =>
              decode object as \#{responseType}
              |> Result.mapError((error : Object.Error) { 
                Http.ErrorResponse.NetworkError 
              })
            
            => Result.Err(Http.ErrorResponse.NetworkError)
          }
        })
    }
    MINT
  }
  
  fun sanitizePath(path : String) : String {
    path
    |> String.replace("/", "_")
    |> String.replace("{", "")
    |> String.replace("}", "")
    |> OpenApi.TypeGenerator.capitalizeFirst
  }
}