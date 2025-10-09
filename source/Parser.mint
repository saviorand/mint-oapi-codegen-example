module OpenApi.Parser {
  fun parse(json : String) : Result(String, OpenApi.Spec) {
    let Ok(object) =
      Json.parse(json) or return Result.Err("Invalid JSON")
    
    let Ok(spec) =
      decode object as OpenApi.Spec 
      or return Result.Err("Invalid OpenAPI spec")
    
    Result.Ok(spec)
  }
}