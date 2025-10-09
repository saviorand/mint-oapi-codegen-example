module OpenApi.Generator {
  fun generate(
    specJson : String,
    moduleName : String = "Api"
  ) : Result(String, GeneratedCode) {
    // Parse the spec
    let Ok(spec) =
      OpenApi.Parser.parse(specJson) 
      or return Result.Err("Failed to parse OpenAPI spec")
    
    // Generate types
    let types =
      case spec.components {
        Just(components) =>
          for name, schema of components.schemas {
            let typeName = OpenApi.TypeGenerator.sanitizeTypeName(name)
            OpenApi.TypeGenerator.generateTypeDefinition(typeName, schema)
          }
          |> String.join("\n\n")
        
        => ""
      }
    
    // Generate API client
    let apiModule =
      OpenApi.ApiGenerator.generateApiModule(spec, moduleName)
    
    Result.Ok({
      types: types,
      api: apiModule
    })
  }
}

type GeneratedCode {
  types : String,
  api : String
}