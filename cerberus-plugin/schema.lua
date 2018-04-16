return {
  no_consumer = true,
  fields = {
    url = { required = true, type = "url" },
    product_company = { required = false, type = "string", default = "productcompany"},
    product_name = { required = false, type = "string", default = "productname"},
    product_version = { required = false, type = "string", default = "product_version"},
    tags = { required = false, type = "array", default = {}},
  }
}
