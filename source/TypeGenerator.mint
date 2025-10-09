module OpenApi.TypeGenerator {
  // Convert OpenAPI type to Mint type
  fun openApiTypeToMint(
    schema : OpenApi.Schema
  ) : String {
    case schema.type {
      Just("string") =>
        case schema.format {
          Just("date-time") => "Time"
          => "String"
        }
      
      Just("integer") | Just("number") => "Number"
      Just("boolean") => "Bool"
      Just("array") =>
        case schema.items {
          Just(items) => "Array(\#{openApiTypeToMint(items)})"
          => "Array(Object)"
        }
      
      Just("object") =>
        case schema.properties {
          Just(props) => generateRecordType(props, schema.required or [])
          => "Object"
        }
      
      => "Object"
    }
  }
  
  // Generate a Mint record type from OpenAPI object schema
  fun generateRecordType(
    properties : Map(String, OpenApi.Schema),
    required : Array(String)
  ) : String {
    let fields =
      for name, schema of properties {
        let mintType = openApiTypeToMint(schema)
        let isRequired = Array.contains(required, name)
        
        if isRequired {
          "  \#{name} : \#{mintType}"
        } else {
          "  \#{name} : Maybe(\#{mintType})"
        }
      }
      |> String.join(",\n")
    
    "{\n\#{fields}\n}"
  }
  
  // Generate a complete type definition
  fun generateTypeDefinition(
    name : String,
    schema : OpenApi.Schema
  ) : String {
    // Handle $ref
    if let Just(ref) = schema.ref {
      let refName = extractRefName(ref)
      return "type \#{name} = \#{refName}"
    }
    
    // Handle oneOf (ADT)
    if let Just(oneOf) = schema.oneOf {
      return generateADT(name, oneOf)
    }
    
    // Handle regular object
    case schema.properties {
      Just(props) =>
        {
          let recordType = generateRecordType(props, schema.required or [])
          "type \#{name} \#{recordType}"
        }
      
      => "type \#{name} = Object"
    }
  }
  
  // Generate ADT for oneOf schemas
  fun generateADT(
    name : String,
    variants : Array(OpenApi.Schema)
  ) : String {
    let variantDefs =
      for variant, index of variants {
        let variantName = "\#{name}\#{index + 1}"
        let variantType = openApiTypeToMint(variant)
        "  \#{variantName}(\#{variantType})"
      }
      |> String.join("\n")
    
    "type \#{name} {\n\#{variantDefs}\n}"
  }
  
  // Extract type name from $ref
  fun extractRefName(ref : String) : String {
    ref
    |> String.split("/")
    |> Array.last
    |> Maybe.withDefault("Unknown")
  }
  
  // Convert schema name to valid Mint type name
  fun sanitizeTypeName(name : String) : String {
    name
    |> String.replace("-", "")
    |> String.replace("_", "")
    // Will need to toFirstUpperCase somehow
    |> capitalizeFirst
  }
  
  // Helper to capitalize first letter
  fun capitalizeFirst(str : String) : String {
    if String.isEmpty(str) {
      str
    } else {
      let first = String.toUpperCase(String.slice(str, 0, 1))
      let rest = String.dropStart(str, 1)
      first + rest
    }
  }
}