-- Parser.lua

local Parser = {}
Parser.__index = Parser

function Parser.new()
    local self = setmetatable({}, Parser)
    return self
end

function Parser:parse(code)
    local statements = {}
    for line in code:gmatch("[^\r\n]+") do
        local trimmedLine = line:gsub("^%s*(.-)%s*$", "%1")  -- Trim whitespace
        if trimmedLine ~= "" then
            local statement = self:parseLine(trimmedLine)
            if statement then
                table.insert(statements, statement)
            end
        end
    end
    return statements
end

function Parser:parseLine(line)
    -- Variable declaration
    local varPattern = "^(let|const|var)%s+(%w+)%s*=%s*(.+);?$"
    local varType, varName, value = line:match(varPattern)
    if varName then
        return { type = "VariableDeclaration", name = varName, value = value }
    end

    -- Function declaration
    local funcPattern = "^function%s+(%w+)%s*%((.-)%)%s*{"
    local funcName, params = line:match(funcPattern)
    if funcName then
        return { type = "FunctionDeclaration", name = funcName, params = self:splitParams(params), body = {} }
    end

    -- Function call
    local callPattern = "^(%w+)%s*%((.-)%);?$"
    local funcCallName, funcCallArgs = line:match(callPattern)
    if funcCallName then
        return { type = "FunctionCall", name = funcCallName, args = self:splitArgs(funcCallArgs) }
    end

    -- Console.log
    local logPattern = "^console%.log%((.+)%);?$"
    local logValue = line:match(logPattern)
    if logValue then
        return { type = "ConsoleLog", value = logValue }
    end

    -- If statement
    local ifPattern = "^if%((.+)%)%s*{"
    local condition = line:match(ifPattern)
    if condition then
        return { type = "IfStatement", condition = condition, consequent = {} }
    end

    -- For loop
    local forPattern = "^for%s*%((%w+)%s*=%s*(%d+);%s*(%w+)%s*<%s*(%d+);%s*%w+%+%+)%.%s*{"
    local loopVar, start, loopVarName, endValue = line:match(forPattern)
    if loopVar then
        return { type = "ForStatement", init = { var = loopVar, value = start }, condition = loopVarName .. " < " .. endValue, body = {} }
    end

    return nil
end

function Parser:splitParams(paramString)
    local params = {}
    for param in paramString:gmatch("%w+") do
        table.insert(params, param)
    end
    return params
end

function Parser:splitArgs(argString)
    local args = {}
    for arg in argString:gmatch("[^,]+") do
        table.insert(args, arg)
    end
    return args
end

return Parser