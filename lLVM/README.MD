# How to Use LPRuntime in Roblox

## Setup

1. **Create a Folder**: In Roblox Studio, create a folder named `LPRuntime`.

2. **Add Scripts**: Inside the `LPRuntime` folder, create the following LuaU scripts:
   - `MainRuntime.luau`
   - `Environment.luau`
   - `Evaluator.luau`
   - `Parser.luau`

## Script Content

### 1. `MainRuntime.lua`

This is the entry point for your script. It initializes the environment, evaluator, and parser, and runs the LuaU-like code.

```lua
local Environment = require(script.Environment)
local Evaluator = require(script.Evaluator)
local Parser = require(script.Parser)

local function main()
    local globalEnv = Environment.new()
    local evaluator = Evaluator.new(globalEnv)
    local parser = Parser.new()

    local code = [[
        let x = 10;
        const y = 5;
        let z = x + y;
        console.log(z);  -- Outputs: 15

        function add(a, b) {
            return a + b;
        }
        console.log(add(5, 3));  -- Outputs: 8

        if (x > y) {
            console.log("x is greater than y");
        }

        for (let i = 0; i < 5; i++) {
            console.log(i);  -- Outputs: 0, 1, 2, 3, 4
        }
    ]]

    local statements = parser:parse(code)
    evaluator:executeBlock(statements)
end

main()