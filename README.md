# mint-oapi-codegen-example

This repository demonstrates using code generated with [mint-oapi-codegen](https://github.com/asdf-mint-oapi-codegen) via its asdf plugin.

## About mint-oapi-codegen

A fork of [oapi-codegen](https://github.com/oapi-codegen/oapi-codegen) that generates [Mint language](https://mint-lang.com) client code from OpenAPI 3.0 specifications.

### Overview

`mint-oapi-codegen` converts OpenAPI specifications into idiomatic Mint code, including:
- **Type definitions** for all schemas (records, enums, etc.)
- **HTTP client code** as Mint Providers with async/await Promise-based methods
- **Type-safe API calls** with proper error handling

This tool helps you reduce boilerplate when integrating Mint applications with REST APIs, allowing you to focus on business logic instead of HTTP plumbing.

## Usage

The generated client code in this example can be found in the `source/` directory. To use the asdf plugin for your own projects:

```bash
asdf plugin add mint-oapi-codegen https://github.com/saviorand/asdf-mint-oapi-codegen
asdf install mint-oapi-codegen latest
```

Then generate the code from an OpenAPI specification:
```
mint-oapi-codegen -config cfg.yaml api.yaml
```

The code generated for this example can be found in `source/Client.mint`.

