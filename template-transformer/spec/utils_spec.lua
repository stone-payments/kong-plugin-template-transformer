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

describe("mask_field", function()
  it("should set mask between 2 initial and 2 end characters", function()
    local value = "1234567890"
    local expected = "12******90"
    result = utils.mask_field(value, 2, 2, "*")
    assert.equal(result, expected)
  end)

  it("should set mask on all characters", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value)
    assert.equal(result, expected)
  end)

  it("should set mask after 2 initial characters", function()
    local value = "1234567890"
    local expected = "12********"
    result = utils.mask_field(value, 2)
    assert.equal(result, expected)
  end)

  it("should set mask between 2 initial and 3 end characters", function()
    local value = "1234567890"
    local expected = "12*****890"
    result = utils.mask_field(value, 2, 3)
    assert.equal(result, expected)
  end)

  it("should set hash character on mask between 2 initial and 3 end characters", function()
    local value = "1234567890"
    local expected = "12#####890"
    result = utils.mask_field(value, 2, 3, "#")
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, 4, 6)
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, 3, 11)
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, 11, 3)
    assert.equal(result, expected)
  end)

  it("should just mask the fifth character", function()
    local value = "1234567890"
    local expected = "1234*67890"
    result = utils.mask_field(value, 4, 5)
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, 10, 0)
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, 0, 10)
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, 13, 0)
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, "2", "0")
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, "2", 0)
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, 2, "0")
    assert.equal(result, expected)
  end)

  it("should set all character mask on value", function()
    local value = "1234567890"
    local expected = "**********"
    result = utils.mask_field(value, 0, 13)
    assert.equal(result, expected)
  end)

  it("should just show the last 3 characters", function()
    local value = "1234567890"
    local expected = "*******890"
    result = utils.mask_field(value, 0, 3)
    assert.equal(result, expected)
  end)

  it("should return a number valeu", function()
    local value = 12345
    local expected = 12345
    result = utils.mask_field(value, 1, 3, "*")
    assert.equal(result, expected)
  end)
end)