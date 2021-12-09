local typedefs = require "kong.db.schema.typedefs"

return {
  name = "kong-plugin-template-transformer",
  fields = {
    { consumer = typedefs.no_consumer, },
    {
      config = {
        type = "record",
        fields = {
          { request_template = { type = "string", required = false }, },
          { response_template = { type = "string", required = false }, },
          { hidden_fields = { type = "array", elements = { type = "string" }, required = false}, },
          { ignore_content_types = { type = "array", elements = { type = "string" }, required = false }, },
        }
      }
    }
  },
}
