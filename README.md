# JS-array.lua

A Javascript-like array library for Lua. Built for Lua 5.0.x.

## Installation

Just put the [JS-array.lua]() file into your project folder.

## Usage

```lua
-- Require the module
local JSArray = require("js-array")

-- Instantiate a new array
local a = JSArray(5, false, "hiya!")

-- Prints each element
a:forEach(function(element, index, array)
	print(element, index)
end)

-- Output:
-- 5	1
-- false	2
-- hiya!	3
```
