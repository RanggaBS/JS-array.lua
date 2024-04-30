-- Javascript-like array library for Lua
-- Author: RanggaBS
-- GitHub: https://github.com/RanggaBS

-- -------------------------------------------------------------------------- --
--                                    Types                                   --
-- -------------------------------------------------------------------------- --

---@alias NotNil number|string|boolean|table|function|thread|userdata

-- -------------------------------------------------------------------------- --
--                                  Utilities                                 --
-- -------------------------------------------------------------------------- --
---Check if a table has any key.
---@param t table
---@return boolean
local function IsTableHasKey(t)
	--[[ for key, _ in pairs(t) do
		if key ~= nil or type(key) ~= "nil" then
			return true
		end
	end
	return false ]]

	for _, __ in pairs(t) do
		return true
	end
	return false
end

-- -------------------------------------------------------------------------- --
--                                   JSArray                                  --
-- -------------------------------------------------------------------------- --

---@class JSArray
---@field private __index JSArray
---@field private new fun(t: table): JSArray
local JSArray = {}

JSArray.__index = JSArray

---Create a new JSArray instance from given table.
---@generic T
---@param t? T[]
---@return JSArray
local function newJSArrayFromTable(t)
	return setmetatable(t or {}, JSArray)
end

---Create a new JSArray instance from passed arguments.
---@generic T
---@param ...? T
---@return JSArray
local function new(...)
	return setmetatable({ unpack(arg) }, JSArray)
end

-- -------------------------------------------------------------------------- --
--                               Static Methods                               --
-- -------------------------------------------------------------------------- --

---Determines whether the passed value is an array or not.
---@param tbl? any
---@return boolean
local function isArray(tbl)
	return type(tbl) == "table" and table.getn(tbl) > 0
end

---Creates an array from an iterable or array-like object.
---@generic T
---@generic U
---@param arrayLike NotNil
---@param mapFunction? fun(element: T, index?: integer): U
---@return JSArray
local function from(arrayLike, mapFunction)
	assert(arrayLike ~= nil, "from(): argument #1 must not be nil")

	local result = {}

	if type(arrayLike) ~= "string" and not isArray(arrayLike) then
		return newJSArrayFromTable(result)
	end

	if type(arrayLike) == "string" then
		for index = 1, string.len(arrayLike) do
			table.insert(result, string.sub(arrayLike, index, index))
		end
	elseif type(arrayLike) == "table" and isArray(arrayLike) then
		for index = 1, table.getn(arrayLike) do
			local value = arrayLike[index]
			if mapFunction then
				value = mapFunction(value, index)
			end
			table.insert(result, value)
		end
	end

	if mapFunction then
		result = newJSArrayFromTable(result):map(function(element, index)
			return mapFunction(element, index)
		end)
	end

	return newJSArrayFromTable(result)
end

---Check if a value is JSArray object
---@param value any
---@return boolean
local function isJSArray(value)
	return getmetatable(value) == JSArray
end

---Creates a new array instance from a variable number of arguments, regardless
---of number or type of the arguments.
---@generic T
---@param ... T A set of elements to include in the new array.
---@return JSArray
local function of(...)
	return newJSArrayFromTable({ unpack(arg) })
end

-- -------------------------------------------------------------------------- --
--                              Metatable Methods                             --
-- -------------------------------------------------------------------------- --

--[[ ---Concatenates an array with given value.\
---Returns an array with value concatenated.\
---Accepted type: boolean|number|string|table
---@param value boolean|number|string|table
---@return JSArray
function JSArray:__concat(value)
	-- Type check
	local valueType = type(value)
	local correctType = {
		["boolean"] = true,
		["number"] = true,
		["string"] = true,
		["table"] = true,
	}
	assert(
		correctType[valueType],
		"__concat: wrong argument type. boolean/number/string/table expected, got"
			.. valueType
	)

	local result = new()

	-- for _, v in ipairs(self) do
	-- 	table.insert(result, v)
	-- end
	self:forEach(function(element)
		result:push(element)
	end)
	-- if isArray(value) then
	-- 	for _, v in
	-- 		ipairs(value --[@as table])
	-- 	do
	-- 		table.insert(result, v)
	-- 	end
	-- else
	-- 	table.insert(result, value)
	-- end
	result = result:concat(value)

	return result
end ]]

---Concatenates an array with given value using concatenation operator (two dots, `..`).\
---Returns an array with value concatenated.\
---Accepted type: `number|string|table`
---@param a number|string|table
---@param b number|string|table
---@return JSArray
function JSArray.__concat(a, b)
	-- Type check
	local correctType = {
		["number"] = true,
		["string"] = true,
		["table"] = true,
	}
	local typeA = type(a)
	local typeB = type(b)
	assert(
		correctType[typeA],
		"__concat: bad argument #1 (number/string/table expected, got "
			.. typeA
			.. ")"
	)
	assert(
		correctType[typeB],
		"__concat: bad argument #2 (number/string/table expected, got "
			.. typeB
			.. ")"
	)

	local result = {}

	if typeA == "table" and typeB == "table" then
		-- Insert all item on array A first, then array B
		for _, array in ipairs({ a, b }) do
			for __, item in ipairs(array) do
				table.insert(result, item)
			end
		end

	-- ex: 1 .. {2, 3} --> {1, 2, 3}
	elseif (correctType[typeA] and typeA ~= "table") and typeB == "table" then
		-- Insert A first
		table.insert(result, a)

		-- Then all item from array B
		for _, item in ipairs(b) do
			table.insert(result, item)
		end

	-- ex: {1, 2} .. 3 --> {1, 2, 3}
	elseif typeA == "table" and (correctType[typeB] and typeB ~= "table") then
		-- Insert all item from array A first
		for _, item in ipairs(a) do
			table.insert(result, item)
		end

		-- Then insert B
		table.insert(result, b)
	end

	return newJSArrayFromTable(result)
end

---Get a string that represents the array in a human-readable format.
---@return string # # A string representation of the array
function JSArray:__tostring()
	---@param depth integer
	---@return string
	local function format(t, depth)
		if not IsTableHasKey(t) then
			return "{}"
		end

		local str = ""

		for key, value in pairs(t) do
			if type(value) ~= "nil" then
				local line = ""

				local left = "" -- key
				local right = "" -- value

				-- # Key (left)
				if type(key) == "string" then
					left = '["' .. key .. '"]'
				else
					left = "[" .. tostring(key) .. "]"
				end

				-- # Value (right)
				if type(value) == "string" then
					right = '"' .. value .. '"'
				elseif type(value) == "table" then
					right = format(value, depth + 1) -- recursive
				else
					right = tostring(value)
				end

				-- line (left & right concatenated)
				line = string.rep("\t", depth) .. left .. " = " .. right .. ",\n"

				str = str .. line
			end
		end

		return "{\n" .. str .. string.rep("\t", depth - 1) .. "}"
	end

	return format(self, 1)
end

-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

---@generic T
---@param index? number Default is `1`
---@return T | nil
function JSArray:at(index)
	assert(
		type(index) == "number",
		"at(): bad argument #1 (number expected, got " .. type(index) .. ")"
	)

	index = index or 1
	if index < 0 then
		index = table.getn(self) - math.abs(index) + 1
	end

	return self[index]
end

---Combines two or more arrays.<br>
---This method returns a new array without modifying any existing arrays.
---@param ... any # Additional arrays and/or items to add to the end of the array.
---@return JSArray
function JSArray:concat(...)
	local result = {}

	-- insert current element to a new array
	self:forEach(function(element)
		table.insert(result, element)
	end)

	-- for each given argument
	for _, element in ipairs(arg) do
		-- If the element is an array
		if isArray(element) then
			-- Insert every item in those array to the result array
			-- stylua: ignore start
			for _, value in ipairs(element --[[@as table]]) do
				-- stylua: ignore end
				table.insert(result, value)
			end

		-- If not an array and not nil
		elseif element ~= nil then
			table.insert(result, element)
		end
	end

	return newJSArrayFromTable(result)
end

---Returns the this object after copying a section of the array identified by
---start and end to the same array starting at position target.<br><br>
---This method overwrite the existing values.
---@param targetIndex? integer Default is `1`
---@param startIndex? integer inclusive. Default is `1`
---@param endIndex? integer exclusive. Default is the array length.
---@return JSArray
function JSArray:copyWithin(targetIndex, startIndex, endIndex)
	if not targetIndex then
		return self
	end

	local len = table.getn(self)

	targetIndex = targetIndex or 1
	startIndex = startIndex or 1
	if startIndex < 0 then
		startIndex = len - math.abs(startIndex) + 1
	end
	if endIndex < 0 then
		endIndex = len - math.abs(endIndex) + 1
	end
	endIndex = endIndex and endIndex - 1 or len

	-- copy items
	local copies = {}
	for i = startIndex, endIndex do
		table.insert(copies, self[i])
	end
	-- print("LOG: copies = " .. tostring(newJSArrayFromTable(copies):join()))

	-- replace items
	local index = 1
	for i = targetIndex, table.getn(self) do
		if copies[index] then
			self[i] = copies[index]
			index = index + 1
		end
	end

	return self
end

---Returns an iterable of key, value pairs for every entry in the array.
---@generic T
---@return fun(): integer, T iterator
function JSArray:entries()
	local index = 0
	local length = self:getLength()
	return function()
		index = index + 1
		if index <= length then
			return index, self[index]
		end
	end
end

---Determines whether all the members of an array satisfy the specified test.
---@generic T
---@param callbackFunction fun(element: T, index?: integer, array?: JSArray): boolean
---@return boolean
function JSArray:every(callbackFunction)
	assert(
		type(callbackFunction) == "function",
		-- "`callbackFunction` must be type of function"
		"every(): bad argument #1 (function expected, got "
			.. type(callbackFunction)
	)

	for index, value in ipairs(self) do
		if not callbackFunction(value, index, self) then
			return false
		end
	end
	return true
end

---Changes all array elements from start to end index to a static value and
---returns the modified array.<br><br>
---This method overwrites the original array.
---@param value any Value to fill array section with.
---@param startIndex? integer (inclusive) Index to start filling the array at. If it is negative, it is treated as `length + startIndex + 1` where length is the length of the array.
---@param endIndex? integer (exclusive) Index to stop filling the array at. If it is negative, it is treated as `length + endIndex`.
---@return JSArray
function JSArray:fill(value, startIndex, endIndex)
	--[[ assert(
		type(startIndex) == "number",
		"fill(): bad argument #1 (number expected, got " .. type(startIndex) .. ")"
	)

	assert(
		type(endIndex) == "number",
		"fill(): bad argument #2 (number expected, got " .. type(endIndex) .. ")"
	) ]]

	-- set default value if not given
	local len = self:getLength()
	startIndex = startIndex or 1
	endIndex = endIndex or len + 1

	if startIndex < 0 then
		if startIndex < -len then
			startIndex = 1
		else
			startIndex = len - math.abs(startIndex) + 1
		end
	end

	if endIndex < 0 then
		if endIndex < -len then
			endIndex = 1
		else
			endIndex = len - math.abs(endIndex) + 1
		end
	end

	endIndex = endIndex > len + 1 and len + 1 or endIndex

	for i = startIndex, endIndex do
		if i ~= endIndex then
			self[i] = value
		end
	end

	return self
end

---Returns the elements of an array that meet the condition
---specified in a callback function.
---@generic T
---@param predicate fun(element: T, index?: integer, array?: JSArray): boolean
---@return JSArray # A new array containing just the elements that pass the test.
function JSArray:filter(predicate)
	local result = {}

	self:forEach(function(element, index, array)
		if predicate(element, index, array) then
			table.insert(result, element)
		end
	end)

	return newJSArrayFromTable(result)
end

---Returns the value of the first element in the array where `predicate` is `true`,
---and `nil` otherwise.
---@generic T
---@param predicate fun(currentValue: T, index?: integer, array?: JSArray): boolean
---@return T | nil
function JSArray:find(predicate)
	for index, value in ipairs(self) do
		if predicate(value, index, self) then
			return value
		end
	end
	return nil
end

---Returns the index of the first element in the array where predicate is `true`,
---and `-1` otherwise.
---@param predicate fun(currentValue: unknown, index?: integer, array?: JSArray): boolean
---@return integer
function JSArray:findIndex(predicate)
	for index, value in ipairs(self) do
		if predicate(value, index, self) then
			return index
		end
	end
	return -1
end

---Iterates the array in reverse order and returns the value of the first element
---that satisfies the provided testing function. If no elements satisfy the
---testing function, `nil` is returned.
---@generic T
---@param predicate fun(element: T, index?: integer, array?: JSArray): boolean
---@return T | nil
function JSArray:findLast(predicate)
	for index = table.getn(self), 1, -1 do
		if predicate(self[index], index, self) then
			return self[index]
		end
	end
	return nil
end

---Iterates the array in reverse order and returns the index of the first element
---that satisfies the provided testing function. If no elements satisfy the
---testing function, `-1` is returned.
---@generic T
---@param predicate fun(element: T, index?: integer, array?: JSArray): boolean
---@return integer
function JSArray:findLastIndex(predicate)
	for index = self:getLength(), 1, -1 do
		if predicate(self:at(index), index, self) then
			return index
		end
	end
	return -1
end

---Returns a new array with all sub-array elements concatenated into it
---recursively up to the specified depth.<br><br>
---This method does not change the original array.
---@param depth? integer The depth level specifying how deep a nested array structure should be flattened. Default: `1`
---@return JSArray # The flattened array.
function JSArray:flat(depth)
	depth = depth or 1

	assert(
		type(depth) == "number",
		"flat(): bad argument #1 (number expected, got " .. type(depth) .. ")"
	)

	---@param array table
	---@param currentDepth integer
	---@return table
	local function flat2(array, currentDepth)
		local result = {}

		for _, item in ipairs(array) do
			if isArray(item) and currentDepth > 0 then
				for __, subitem in ipairs(JSArray.flat(item, currentDepth - 1)) do
					table.insert(result, subitem)
				end
			else
				table.insert(result, item)
			end
		end

		return result
	end

	return newJSArrayFromTable(flat2(self, depth))
end

---Calls a defined callback function on each element of an array.
---Then, flattens the result into a new array.
---This is identical to a map followed by flat with depth `1`.<br><br>
---This method does not change the original array.
---@generic T
---@generic U
---@param callbackFunction fun(element: T, index?: integer, array?: JSArray): U
---@return JSArray # An array with the elements as a result of a callback function and then flattened.
function JSArray:flatMap(callbackFunction)
	---Deep copy a table
	---https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
	---@param obj table
	---@param seen? any
	---@return table
	local function copy(obj, seen)
		-- Handle non-tables and previously-seen tables.
		if type(obj) ~= "table" then
			return obj
		end
		if seen and seen[obj] then
			return seen[obj]
		end
		-- New table; mark it as seen and copy recursively.
		local s = seen or {}
		local res = {}
		s[obj] = res
		for k, v in pairs(obj) do
			res[copy(k, s)] = copy(v, s)
		end
		return setmetatable(res, getmetatable(obj))
	end

	local result = newJSArrayFromTable(copy(self))

	result = result:map(callbackFunction)

	-- remove empty table that has no keys
	result = result:filter(function(element)
		if type(element) == "table" and not IsTableHasKey(element) then
			return false
		end
		return true
	end)

	result = result:flat(1)

	return result
end

---Executes a provided function once for each array element.
---@generic T
---@param callbackFunction fun(element: T, index?: integer, array?: JSArray) A function to execute for each element in the array.
function JSArray:forEach(callbackFunction)
	for index, value in ipairs(self) do
		callbackFunction(value, index, self)
	end
end

---Returns the length of the array
---@return integer
function JSArray:getLength()
	return table.getn(self)
end

---Determines whether an array includes a certain element, returning `true` or
---`false` as appropriate.
---@generic T
---@param element T The value to search for.
---@param fromIndex? integer Index at which to start searching.
---@return boolean
function JSArray:includes(element, fromIndex)
	-- if not element then
	-- 	return false
	-- end
	local len = table.getn(self)

	fromIndex = fromIndex or 1
	if fromIndex < 0 then
		fromIndex = len - math.abs(fromIndex) + 1
	end

	for index = fromIndex, len do
		if self[index] == element then
			return true
		end
	end

	return false
end

---Returns the first index at which a given element can be found in the array,
---or `-1` if it is not present.
---@generic T
---@param searchElement? T
---@param fromIndex? integer
---@return integer index `-1` if not found
function JSArray:indexOf(searchElement, fromIndex)
	if not searchElement then
		return -1
	end
	local len = table.getn(self)

	fromIndex = fromIndex or 1
	if fromIndex < 0 then
		fromIndex = len - math.abs(fromIndex) + 1
	end

	for index = fromIndex, len do
		if self[index] == searchElement then
			return index
		end
	end

	return -1
end

---Adds all the elements of an array into a string, separated by the specified
---separator string.
---@param separator? string A string used to separate one element of the array from the next in the resulting string. If omitted, the array elements are separated with a comma (",").
---@return string
function JSArray:join(separator)
	separator = separator or ","
	--[[ local str = ""

	for index, element in ipairs(self) do
		if isArray(element) then
			str = str .. newJSArrayFromTable(element):join(separator)
		else
			str = str
				.. tostring(element)
				.. (index < table.getn(self) and separator or "")
		end
	end

	return str ]]

	---@param t table
	---@param sep? string
	---@param depth integer
	---@return string
	local function f(t, sep, depth)
		local str = ""

		for index, value in ipairs(t) do
			-- separator
			local s = (index < table.getn(t) and (depth <= 1 and sep or ",") or "")

			if isArray(value) then
				str = str .. f(value, nil, depth + 1) .. s
			else
				str = str .. tostring(value) .. s
			end
		end

		return str
	end

	return f(self, separator, 1)
end

---Returns an iterable of keys in the array.
---@return fun(): integer? index
function JSArray:keys()
	--[[ local result = {}

	for index = 1, table.getn(self) do
		table.insert(result, index)
	end

	return newJSArrayFromTable(result) ]]

	local index = 0
	local length = table.getn(self)
	return function()
		index = index + 1
		if index <= length then
			return index
		end
	end
end

---Returns the index of the last occurrence of a specified value in an array,
---or `-1` if it is not present.
---@generic T
---@param searchElement T The value to locate in the array.
---@param fromIndex? integer The array index at which to begin searching backward. If `fromIndex` is omitted, the search starts at the last index in the array.
---@return integer
function JSArray:lastIndexOf(searchElement, fromIndex)
	local len = table.getn(self)
	fromIndex = fromIndex or len

	assert(type(fromIndex) == "number", "`fromIndex` must be type of number")

	if not searchElement or fromIndex == 0 then
		return -1
	end

	fromIndex = (fromIndex and fromIndex < 0) and len - math.abs(fromIndex) + 1
		or (fromIndex or len)

	for index = fromIndex, 1, -1 do
		if self[index] == searchElement then
			return index
		end
	end

	return -1
end

---Calls a defined callback function on each element of an array, and returns
---an array that contains the results.
---@generic T
---@param callbackFunction fun(element: T, index?: integer, array?: JSArray): T A function that accepts up to three arguments. The map method calls the callbackfn function one time for each element in the array
---@return JSArray
function JSArray:map(callbackFunction)
	assert(
		type(callbackFunction) == "function",
		"map(): bad argument #1 (function expected, got "
			.. type(callbackFunction)
			.. ")"
	)

	local mappedArray = {}
	local mappedElement

	self:forEach(function(element, index, array)
		mappedElement = callbackFunction(element, index, array)
		table.insert(mappedArray, mappedElement)
	end)

	return newJSArrayFromTable(mappedArray)
end

---Removes the last element from an array and returns it.
---If the array is empty, `nil` is returned and the array is not modified.<br><br>
---@generic T
---@return T | nil # Deleted element
function JSArray:pop()
	local len = table.getn(self)
	local element = self[len]
	table.remove(self, len)
	return element
end

---Appends new elements to the end of an array, and returns the new length
---of the array.
---@generic T
---@param ... T New elements to add to the array
---@return integer length
function JSArray:push(...)
	for i = 1, table.getn(arg) do
		table.insert(self, arg[i])
	end
	return table.getn(self)
end

---Calls the specified callback function for all the elements in an array.
---The return value of the callback function is the accumulated result,
---and is provided as an argument in the next call to the callback function.
---@generic T
---@param callbackFunction fun(accumulator: T, currentValue: T, currentIndex?: integer, array?: JSArray): T A function to execute for each element in the array. Its return value becomes the value of the `accumulator` parameter on the next invocation of `callbackFunction`. For the last invocation, the return value becomes the return value of `reduce()`.
---@param initialValue? T If specified, it is used as the initial value to start the accumulation. The first call to the `callbackFunction` function provides this value as an argument instead of an array value.
---@return T
function JSArray:reduce(callbackFunction, initialValue)
	local firstParamType = type(callbackFunction)
	assert(
		firstParamType == "function",
		"reduce(): bad argument #1 (function expected, got "
			.. firstParamType
			.. ")"
	)
	local len = table.getn(self)
	assert(
		len > 0 or initialValue ~= nil,
		"reduce(): Attempt to reduce an empty array with no initial value."
	)

	local accumulatedValue = initialValue or self[1]
	local isSkipFirstIteration = initialValue == nil
	local startIndex = isSkipFirstIteration and 2 or 1

	for i = startIndex, len do
		accumulatedValue = callbackFunction(accumulatedValue, self[i], i, self)
	end

	return accumulatedValue
end

---Calls the specified callback function for all the elements in an array,
---in descending order. The return value of the callback function is the
---accumulated result, and is provided as an argument in the next call to
---the callback function.
---@generic T
---@param callbackFunction fun(accumulator: T, currentValue: T, currentIndex?: integer, array?: JSArray): T A function to execute for each element in the array. Its return value becomes the value of the `accumulator` parameter on the next invocation of `callbackFunction`. For the last invocation, the return value becomes the return value of `reduceRight()`.
---@param initialValue? T If specified, it is used as the initial value to start the accumulation. The first call to the `callbackFunction` function provides this value as an argument instead of an array value.
---@return T
function JSArray:reduceRight(callbackFunction, initialValue)
	local firstParamType = type(callbackFunction)
	assert(
		firstParamType == "function",
		"reduce(): bad argument #1 (function expected, got "
			.. firstParamType
			.. ")"
	)
	local len = table.getn(self)
	assert(
		len > 0 or initialValue ~= nil,
		"reduce(): Attempt to reduce an empty array with no initial value."
	)

	local accumulatedValue = initialValue or self[len]
	local isSkipFirstIteration = type(initialValue) == "nil"
	local startIndex = len - (isSkipFirstIteration and 1 or 0)

	for i = startIndex, 1, -1 do
		accumulatedValue = callbackFunction(accumulatedValue, self[i], i, self)
	end

	return accumulatedValue
end

---Reverses the order of the elements in the array and returns it.<br><br>
---This method overwrites the original array.
---@return JSArray
function JSArray:reverse()
	-- self = self:toReversed()
	-- return self

	local reversedArray = self:toReversed()
	for index, value in ipairs(reversedArray) do
		self[index] = value
	end
	return self
end

---Removes the **first** element from an array and returns it.<br><br>
---This method changes the original array.
---@generic T
---@return T element
function JSArray:shift()
	--[[ local element = self[1]
	table.remove(self, 1)
	return element ]]
	return table.remove(self, 1)
end

---Returns a copy of a section of an array. For both start and end, a negative
---index can be used to indicate an offset from the end of the array.
---@param startIndex? integer inclusive
---@param endIndex? integer exclusive
---@return JSArray
function JSArray:slice(startIndex, endIndex)
	local len = self:getLength()
	startIndex = startIndex or 1
	endIndex = endIndex or len + 1

	local firstParamType = type(startIndex)
	assert(
		firstParamType == "number",
		"slice(): bad argument # (number expected, got " .. firstParamType .. ")"
	)
	local secondParamType = type(endIndex)
	assert(
		secondParamType == "number",
		"slice(): bad argument # (number expected, got " .. secondParamType .. ")"
	)

	-- round down incase given inputs is decimal
	-- startIndex = math.floor(startIndex)
	-- startIndex = math.floor(endIndex)

	local result = {}

	if startIndex > len then
		return result
	elseif startIndex < 0 then
		startIndex = startIndex < -len and 1 or len - math.abs(startIndex) + 1
	end

	if endIndex < 0 then
		endIndex = endIndex < -len and 1 or len - math.abs(endIndex) + 1
	end

	if endIndex <= startIndex then
		return newJSArrayFromTable(result)
	end

	for i = startIndex, endIndex - 1 do
		table.insert(result, self[i])
	end

	return newJSArrayFromTable(result)
end

---Determines whether the specified callback function returns true for any
---element of an array.
---@param callbackFunction fun(element: unknown, index?: integer, array?: JSArray): boolean A function to execute for each element in the array. It should return a truthy value to indicate the element passes the test, and a falsy value otherwise.
---@return boolean `true` if any of the array elements pass the test, otherwise `false`.
function JSArray:some(callbackFunction)
	for index, value in ipairs(self) do
		if callbackFunction(value, index, self) then
			return true
		end
	end
	return false
end

---Sorts an array in place & returns the sorted array.<br><br>
---This method overwrites the original array.
---@generic T
---@param compareFunction? fun(a: T, b: T): boolean A function that determines the order of the elements.
---@return JSArray
function JSArray:sort(compareFunction)
	table.sort(self, compareFunction)
	return self
end

---Removes elements from an array and, if necessary, inserts new elements in
---their place, returning the deleted elements.<br><br>
---This method overwrites the original array.
---@generic T
---@param start integer Index to start changing the array.
---@param deleteCount? integer The number of elements to remove.
---@param ... T Elements to insert into the array in place of the deleted elements.
---@return JSArray # An array containing the deleted elements.
function JSArray:splice(start, deleteCount, ...)
	if start == nil then
		return newJSArrayFromTable({})
	end

	local firstParamType = type(start)
	assert(
		firstParamType == "number",
		"splice(): bad argument #1 (number expected, got " .. firstParamType .. ")"
	)

	deleteCount = deleteCount ~= nil and deleteCount or start - 1
	local secondParamType = type(deleteCount)
	assert(
		secondParamType == "number",
		"splice(): bad argument #2 (number expected, got " .. secondParamType .. ")"
	)

	local len = table.getn(self)

	if start < 0 then
		start = len - math.abs(start) + 1
		if start < -len then
			start = 1
		end
	end

	-- store the deleted elements
	local deletedElements = {}
	for _ = start, start - 1 + deleteCount do
		table.insert(deletedElements, self[start])
		table.remove(self, start)
	end

	--[[ local argLen = table.getn(arg)
	local index = 1
	for i = start, start + argLen do
		table.insert(self, i, arg[index])
		index = index + 1
	end

	for i = start + argLen, start + argLen + deleteCount - 1 do
		table.remove(self, start + argLen)
	end ]]

	-- insert new elements from `start`
	local index = 1
	for i = start, start - 1 + table.getn(arg) do
		table.insert(self, i, arg[index])
		index = index + 1
	end

	return newJSArrayFromTable(deletedElements)
end

---Reverses the order of the elements in the array.<br><br>
---This method **does not change** the original array
---@return JSArray # The reversed array
function JSArray:toReversed()
	local reversedArray = {}

	for index = table.getn(self), 1, -1 do
		table.insert(reversedArray, self[index])
	end

	return newJSArrayFromTable(reversedArray)
end

---Returns a string representing the specified array and its elements.<br><br>
---The same as calling `array:join()` or `array:join(',')`.<br><br>
---This method does not change the original array.
---@return string # A string representing the elements of the array.
function JSArray:toString()
	return self:join()
end

---Inserts new elements at the start of an array, and returns the new length of
---the array.<br><br>
---This method overwrites the original array.
---@generic T
---@param ... T
---@return integer # The new length of the array
function JSArray:unshift(...)
	for index, value in ipairs(arg) do
		table.insert(self, index, value)
	end
	return table.getn(self)
end

---Returns the array itself.
---@return JSArray
function JSArray:valueOf()
	return self
end

---Returns an iterable of values in the array.
---@generic T
---@return fun(): T? value
function JSArray:values()
	local index = 0
	local length = table.getn(self)
	return function()
		index = index + 1
		if index <= length then
			return self[index]
		end
	end
end

---Change the value of a given index in the array without altering the original array, and return it.<br><br>
---Same as regular syntax `array[index] = value`.<br><br>
---This method does not change the original array.
---@generic T
---@param index integer Index at which to change the array. Negative index counts back from the end of the array.
---@param value T Any value to be assigned to the given index.
---@return JSArray # A new array with the element at `index` replaced with `value`.
function JSArray:with(index, value)
	-- index = index or 1

	local firstParamType = type(index)
	assert(
		firstParamType ~= "nil" and firstParamType == "number",
		"with(): bad argument #1 (number expected, got " .. firstParamType .. ")"
	)

	local len = table.getn(self)

	if index < -len or index > len then
		error("with(): invalid index: " .. index)
	end

	if index < 0 then
		index = len - math.abs(index) + 1
	end

	local result = { unpack(self) }
	result[index] = value

	return newJSArrayFromTable(result)
end

-- -------------------------------------------------------------------------- --
--                                   Exports                                  --
-- -------------------------------------------------------------------------- --

local module = {}
module.new = new
module.isArray = isArray
module.from = from
module.of = of
module.isJSArray = isJSArray

-- test
-- ABC = JSArray
-- ABC2 = module

return setmetatable(module, {
	__call = function(_, ...)
		return new(unpack(arg))
	end,
})
