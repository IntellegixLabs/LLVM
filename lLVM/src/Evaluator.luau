-- Evaluator.lua

local Evaluator = {}
Evaluator.__index = Evaluator

function Evaluator.new(environment)
    local self = setmetatable({}, Evaluator)
    self.environment = environment
    return self
end

function Evaluator:eval(value)
    local num = tonumber(value)
    if num then return num end

    -- Variable lookup
    if self.environment:get(value) then
        return self.environment:get(value)
    end

    -- Arithmetic expressions
    local exprPattern = "(.+)%s*([%+%-%*/])%s*(.+)"
    local left, op, right = value:match(exprPattern)
    if left and op and right then
        left = self:eval(left)
        right = self:eval(right)
        if op == "+" then return left + right
        elseif op == "-" then return left - right
        elseif op == "*" then return left * right
        elseif op == "/" then return left / right end
    end

    return value  -- Fallback
end

function Evaluator:executeBlock(statements)
    for _, statement in ipairs(statements) do
        self:execute(statement)
    end
end

function Evaluator:execute(statement)
    -- Handle console.log
    if statement.type == "ConsoleLog" then
        print(self:eval(statement.value))
    elseif statement.type == "VariableDeclaration" then
        self.environment:set(statement.name, self:eval(statement.value))
    elseif statement.type == "FunctionDeclaration" then
        self.environment:set(statement.name, statement)  -- Store function
    elseif statement.type == "FunctionCall" then
        local func = self.environment:get(statement.name)
        if func then
            local args = {}
            for _, arg in ipairs(statement.args) do
                table.insert(args, self:eval(arg))
            end
            self:callFunction(func, args)
        end
    elseif statement.type == "IfStatement" then
        if self:eval(statement.condition) then
            self:executeBlock(statement.consequent)
        end
    elseif statement.type == "ForStatement" then
        local init = statement.init
        self.environment:set(init.var, self:eval(init.value))
        while self:eval(statement.condition) do
            self:executeBlock(statement.body)
            self.environment:set(init.var, self:eval(init.var) + 1)
        end
    elseif statement.type == "ReturnStatement" then
        return self:eval(statement.value)
    end
end

function Evaluator:callFunction(func, args)
    local localEnv = Environment.new(self.environment)
    for i, param in ipairs(func.params) do
        localEnv:set(param, args[i])
    end
    local oldEnv = self.environment
    self.environment = localEnv
    self:executeBlock(func.body)
    self.environment = oldEnv
end

return Evaluator