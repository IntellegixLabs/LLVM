-- Environment.lua

local Environment = {}
Environment.__index = Environment

function Environment.new(parent)
    local self = setmetatable({}, Environment)
    self.variables = {}
    self.parent = parent  -- Reference to parent environment for nested scopes
    return self
end

function Environment:set(varName, value)
    self.variables[varName] = value
end

function Environment:get(varName)
    if self.variables[varName] ~= nil then
        return self.variables[varName]
    elseif self.parent then
        return self.parent:get(varName)
    end
    error("Variable " .. varName .. " is not defined.")
end

return Environment