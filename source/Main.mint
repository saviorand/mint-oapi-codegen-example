component Main {
  fun handleGenerate : Promise(Void) {
    // Load OpenAPI spec (from file, URL, or user input)
    let spec = 
      <<~JSON
      {
        "openapi": "3.0.0",
        "info": { "title": "My API", "version": "1.0.0" },
        "components": {
          "schemas": {
            "User": {
              "type": "object",
              "required": ["id", "name"],
              "properties": {
                "id": { "type": "integer" },
                "name": { "type": "string" },
                "email": { "type": "string" }
              }
            }
          }
        },
        "paths": {
          "/users": {
            "get": {
              "operationId": "getUsers",
              "responses": {
                "200": {
                  "description": "Success",
                  "content": {
                    "application/json": {
                      "schema": {
                        "type": "array",
                        "items": { "$ref": "#/components/schemas/User" }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      JSON
    
    case OpenApi.Generator.generate(spec, "UserApi") {
      Ok(code) =>
        {
          Debug.log("Generated Types:")
          Debug.log(code.types)
          Debug.log("\nGenerated API:")
          Debug.log(code.api)
          
          // Could write this to a file, wip
          next {}
        }
      
      Err(error) =>
        {
          Debug.log("Error: \#{error}")
          next {}
        }
    }
  }
  
  fun render : Html {
    <button onClick={handleGenerate}>
      "Generate Mint Types from OpenAPI"
    </button>
  }
}