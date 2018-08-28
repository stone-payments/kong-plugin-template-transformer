local utils = require('../utils')

describe("has_value", function()
    it("should return false when table is empty", function()
      local l = {}
      assert.is_false(utils.has_value(l, "desired_value"))
    end)

    it("should return false when table does not have value", function()
      local l = {undesired_value = 123}
      assert.is_false(utils.has_value(l, "desired_value"))

      local l = {a = 123, b = 456, c = 789}
      assert.is_false(utils.has_value(l, "desired_value"))
    end)

    it("should return true when table has value", function()
      local l = {desired_value = 123}
      assert.is_false(utils.has_value(l, "desired_value"))

      local l = {a = 123, desired_value = 123, c = 789}
      assert.is_false(utils.has_value(l, "desired_value"))

      local l = {desired_value = 123, c = 789}
      assert.is_false(utils.has_value(l, "desired_value"))

      local l = {a = 123, desired_value = 123}
      assert.is_false(utils.has_value(l, "desired_value"))
    end)
end)

describe("hide_fields", function()
    it("should not hide keys when there is no fields to hide", function()
      local l = {a = 123, password = 456, c = 789}
      local hidden_fields = {}
      utils.hide_fields(l, hidden_fields)
      assert.equal(l["a"], 123)
      assert.equal(l["password"], 456)
      assert.equal(l["c"], 789)
    end)

    it("should hide keys when there is fields to hide", function()
      local l = {a = 123, password = 456, c = 789}
      local hidden_fields = { "password" }
      utils.hide_fields(l, hidden_fields)
      assert.equal(l["a"], 123)
      assert.equal(l["password"], "******")
      assert.equal(l["c"], 789)
    end)

    it("should hide nested keys when there is fields to hide", function()
      local l = {a = 123, data = { password = 456 }, c = 789}
      local hidden_fields = { "password" }
      utils.hide_fields(l, hidden_fields)
      assert.equal(l["a"], 123)
      assert.equal(l["data"]["password"], "******")
      assert.equal(l["c"], 789)
    end)
end)