---@class JSArray
---@field private new fun(t: table): JSArray
JSArray = {}

JSArray.__index = JSArray

---@generic T
---@param t? T[]
---@return JSArray
function JSArray.new(t)
	return setmetatable(t or {}, JSArray)
end

---@generic T
---@param ...? T
---@return JSArray
local function jsarray(...)
	return setmetatable(table.getn(arg) > 0 and { unpack(arg) } or {}, JSArray)
end
-- -------------------------------------------------------------------------- --
--                                   Methods                                  --
-- -------------------------------------------------------------------------- --

---@generic T
---@param index? number default is `1`
---@return T | nil
function JSArray:at(index)
	assert(type(index) == "number", '`index` must be type of "number"')

	index = index or 1
	if index < 0 then
		index = table.getn(self) - math.abs(index) + 1
	end

	return self[index]
end

---Combines two or more arrays.
---This method returns a new array without modifying any existing arrays.
---@param ... any # Additional arrays and/or items to add to the end of the array.
---@return JSArray
function JSArray:concat(...)
	local result = {}

	-- for each given argument
	for _, element in ipairs(arg) do
		if JSArray.isArray(element) then
			-- stylua: ignore start
			for _, value in ipairs(element --[[@as table]]) do
			-- stylua: ignore end
				table.insert(result, value)
			end
		elseif element ~= nil then
			table.insert(result, element)
		end
	end

	return JSArray.new(result)
end

---@param targetIndex integer
---@param startIndex integer inclusive
---@param endIndex? integer exclusive
---@return JSArray
function JSArray:copyWithin(targetIndex, startIndex, endIndex)
	assert(type(targetIndex) == "number", "`targetIndex` must be type of number")
	assert(type(startIndex) == "number", "`startIndex` must be type of number")
	assert(type(endIndex) == "number", "`endIndex` must be type of number")

	local len = self:getLength()

	if targetIndex > len then
		return self
	end

	startIndex = startIndex or 1
	endIndex = endIndex or len

	-- round down incase given inputs is decimal
	targetIndex = math.floor(targetIndex)
	startIndex = math.floor(startIndex)
	endIndex = math.floor(endIndex)

	if startIndex < 0 then
		startIndex = startIndex < -len and 1 or len - math.abs(startIndex) + 1
	end

	startIndex = math.max(startIndex, 1)
	endIndex = math.min(endIndex, len)

	local copy = {}
	local index = 1
	for i = startIndex, endIndex do
		table.insert(copy, self[i])
		index = index + 1
	end

	len = targetIndex + table.getn(copy) - 1
	len = len > self:getLength() and self:getLength() or len
	index = 1

	for i = targetIndex, len do
		self[i] = copy[index]
		index = index + 1
	end

	return self
end

---Returns an iterable of key, value pairs for every entry in the array.
---@return function iterator
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
---@param callbackFunction fun(element: unknown, index?: integer, array?: JSArray)
---@return boolean
function JSArray:every(callbackFunction)
	assert(
		type(callbackFunction) == "function",
		"`callbackFunction` must be type of function"
	)

	for index, value in ipairs(self) do
		if not callbackFunction(value, index, self) then
			return false
		end
	end
	return true
end

---Changes all elements within a range of indices in an array to a static value.<br/><br/>
---Returns the modified array
---@param value any
---@param start integer inclusive
---@param endIndex integer exclusive
---@return JSArray
function JSArray:fill(value, start, endIndex)
	assert(type(start) == "number", '`start` must be type of "number"')
	assert(type(endIndex) == "number", '`endIndex` must be type of "number"')

	start = math.floor(start)
	endIndex = math.floor(endIndex)

	-- set default value if not given
	local len = self:getLength()
	start = start or 1
	endIndex = endIndex or len + 1

	if start < 0 then
		if start < -len then
			start = 1
		else
			start = len - math.abs(start) + 1
		end
	end

	endIndex = endIndex > len + 1 and len + 1 or endIndex

	for i = start, endIndex do
		if i ~= endIndex then
			self[i] = value
		end
	end

	return self
end

---Returns the elements of an array that meet the condition
---specified in a callback function.
---@param func fun(element: unknown, index?: integer, array?: JSArray): boolean
---@return JSArray
function JSArray:filter(func)
	local result = {}

	self:forEach(function(element, index, array)
		if func(element, index, array) then
			table.insert(result, element)
		end
	end)

	return JSArray.new(result)
end

---Returns the value of the first element in the array where predicate is `true`,
---and `nil` otherwise.
---@generic T
---@param func fun(currentValue: T, index?: integer, array?: JSArray)
---@return T | nil
function JSArray:find(func)
	for index, value in ipairs(self) do
		if func(value, index, self) then
			return value
		end
	end
	return nil
end

---Returns the index of the first element in the array where predicate is `true`,
---and `-1` otherwise.
---@param func fun(currentValue: unknown, index?: integer, array?: JSArray)
---@return integer
function JSArray:findIndex(func)
	for index, value in ipairs(self) do
		if func(value, index, self) then
			return index
		end
	end
	return -1
end

---Iterates the array in reverse order and returns the value of the first element
---that satisfies the provided testing function. If no elements satisfy the
---testing function, `nil` is returned.
---@generic T
---@param callbackFunction fun(element: T, index?: integer, array?: JSArray)
---@return T | nil
function JSArray:findLast(callbackFunction)
	for index = self:getLength(), 1, -1 do
		if callbackFunction(self:at(index), index, self) then
			return self:at(index)
		end
	end
	return nil
end

---Iterates the array in reverse order and returns the index of the first element
---that satisfies the provided testing function. If no elements satisfy the
---testing function, `-1` is returned.
---@generic T
---@param callbackFunction fun(element: T, index?: integer, array?: JSArray)
---@return integer
function JSArray:findLastIndex(callbackFunction)
	for index = self:getLength(), 1, -1 do
		if callbackFunction(self:at(index), index, self) then
			return index
		end
	end
	return -1
end

---Returns a new array with all sub-array elements concatenated into it
---recursively up to the specified depth.
---@param depth? integer default: `1`
---@return JSArray
function JSArray:flat(depth)
	depth = depth or 1

	---@param array table
	---@param currentDepth integer
	---@return table
	local function flat2(array, currentDepth)
		local result = {}

		for _, item in ipairs(array) do
			if JSArray.isArray(item) and currentDepth > 0 then
				for __, subitem in ipairs(JSArray.flat(item, currentDepth - 1)) do
					table.insert(result, subitem)
				end
			else
				table.insert(result, item)
			end
		end

		return result
	end

	return flat2(self, depth)
end

---Calls a defined callback function on each element of an array.
---Then, flattens the result into a new array.
---This is identical to a map followed by flat with depth 1.
---@generic T
---@param callbackFunction fun(element: T, index?: integer, array?: JSArray): T
---@return JSArray
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

	local result = JSArray.new(copy(self))

	result = result:map(callbackFunction)

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

---Creates a new, shallow-copied `Array` instance from an
---[interable]() or [array-like]() object
---@param arrayLike any
---@param mapFunction? fun(element: unknown, index?: integer): any
---@return JSArray
function JSArray.from(arrayLike, mapFunction)
	local result = {}

	if type(arrayLike) ~= "string" and not JSArray.isArray(arrayLike) then
		return JSArray.new(result)
	end

	if type(arrayLike) == "string" then
		for index = 1, string.len(arrayLike) do
			table.insert(result, string.sub(arrayLike, index, index))
		end
	elseif JSArray.isArray(arrayLike) then
		for index = 1, table.getn(arrayLike) do
			local value = arrayLike[index]
			if mapFunction then
				value = mapFunction(value, index)
			end
			table.insert(result, value)
		end
	end

	return JSArray.new(result)
end

---Returns the length of the array
---@return integer
function JSArray:getLength()
	return table.getn(self)
end

---Determines whether an array includes a certain element, returning `true` or
---`false` as appropriate.
---@param element? any
---@param start? integer
---@return boolean
function JSArray:includes(element, start)
	if not element then
		return false
	end

	start = start or 1
	for index = start, self:getLength() do
		if self:at(index) == element then
			return true
		end
	end

	return false
end

---Returns the first index at which a given element can be found in the array,
---or `-1` if it is not present.
---@param searchElement? any
---@return integer index `-1` if not found
function JSArray:indexOf(searchElement, fromIndex)
	if not searchElement then
		return -1
	end

	fromIndex = fromIndex or 1
	for index = fromIndex, self:getLength() do
		if self:at(index) == searchElement then
			return index
		end
	end

	return -1
end

---Determines whether the passed value is an array or not.
---@param t? any
---@return boolean
function JSArray.isArray(t)
	return type(t) == "table" and table.getn(t) > 0
end

---Adds all the elements of an array into a string, separated by the specified
---separator string.
---@param separator? string default: '`,`'
---@return string
function JSArray:join(separator)
	separator = separator or ","
	local str = ""

	for index, element in ipairs(self) do
		if JSArray.isArray(element) then
			str = str .. JSArray.new(element):join(separator)
		else
			str = str
				.. tostring(element)
				.. (index < self:getLength() and separator or "")
		end
	end

	return str
end

---Returns an iterable of keys in the array.
---@return JSArray
function JSArray:keys()
	local result = {}

	for index = 1, self:getLength() do
		table.insert(result, index)
	end

	return JSArray.new(result)
end

---Returns the index of the last occurrence of a specified value in an array,
---or `-1` if it is not present.
---@generic T
---@param searchElement? T The value to locate in the array.
---@param fromIndex? integer The array index at which to begin searching
--													 backward. If fromIndex is omitted, the search
--													 starts at the last index in the array.
---@return integer
function JSArray:lastIndexOf(searchElement, fromIndex)
	assert(type(fromIndex) == "number", "`fromIndex` must be type of number")

	if not searchElement or fromIndex == 0 then
		return -1
	end

	fromIndex = (fromIndex and fromIndex < 0)
			and self:getLength() - math.abs(fromIndex) + 1
		or (fromIndex or self:getLength())

	for index = fromIndex, 1, -1 do
		if self:at(index) == searchElement then
			return index
		end
	end

	return -1
end

---Calls a defined callback function on each element of an array, and returns
---an array that contains the results.
---@generic T
---@param func fun(element: T, index?: integer, array?: JSArray): T A function that accepts up to three arguments. The map method calls the callbackfn function one time for each element in the array
---@return JSArray
function JSArray:map(func)
	assert(type(func) == "function", "`func` must be type of function")

	local mappedArray = {}
	local mappedElement

	self:forEach(function(element, index, array)
		mappedElement = func(element, index, array)
		table.insert(mappedArray, mappedElement)
	end)

	return JSArray.new(mappedArray)
end

---Creates a new array instance from a variable number of arguments, regardless
---of number or type of the arguments.
---@generic T
---@param ... T A set of elements to include in the new array
---@return JSArray
function JSArray.of(...)
	return JSArray.new({ unpack(arg) })
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
	return self:getLength()
end

---Removes the last element from an array and returns it.
---If the array is empty, `nil` is returned and the array is not modified.
---@generic T
---@return T | nil # Deleted element
function JSArray:pop()
	local element = self:at(self:getLength())
	table.remove(self, self:getLength())
	return element
end

---Calls the specified callback function for all the elements in an array.
---The return value of the callback function is the accumulated result,
---and is provided as an argument in the next call to the callback function.
---@generic T
---@param callbackFunction fun(accumulator: T, currentValue: T, currentIndex?: integer, array?: JSArray): T
---@param initialValue? T If specified, it is used as the initial value to start the accumulation. The first call to the callbackFunction function provides this value as an argument instead of an array value.
---@return T
function JSArray:reduce(callbackFunction, initialValue)
	assert(
		type(callbackFunction) == "function",
		"`callbackFunction` must be type of function"
	)

	local accumulatedValue = initialValue or self[1]
	local isSkipFirstIteration = initialValue == nil
	local startIndex = isSkipFirstIteration and 2 or 1

	for i = startIndex, table.getn(self) do
		accumulatedValue = callbackFunction(accumulatedValue, self[i], i, self)
	end

	return accumulatedValue
end

---Calls the specified callback function for all the elements in an array,
---in descending order. The return value of the callback function is the
---accumulated result, and is provided as an argument in the next call to
---the callback function.
---@generic T
---@param callbackFunction fun(accumulator: T, currentValue: T, currentIndex?: integer, array?: JSArray): T
---@param initialValue? T If specified, it is used as the initial value to
--												start the accumulation. The first call to the
--												callbackFunction function provides this value
--												as an argument instead of an array value.
---@return T
function JSArray:reduceRight(callbackFunction, initialValue)
	assert(
		type(callbackFunction) == "function",
		"`callbackFunction` must be type of function"
	)

	local accumulatedValue = initialValue or self[table.getn(self)]
	local isSkipFirstIteration = type(initialValue) == "nil"
	local startIndex = table.getn(self) - (isSkipFirstIteration and 1 or 0)

	for i = startIndex, 1, -1 do
		accumulatedValue = callbackFunction(accumulatedValue, self[i], i, self)
	end

	return accumulatedValue
end

---Reverses the order of the elements in the array<br/><br/>
---Returns the reversed array<br/><br/>
---This method overwrite the original array
---@return JSArray
function JSArray:reverse()
	self = self:toReversed()
	return self
end

---Return and remove the first item
---@return unknown
function JSArray:shift()
	local element = self:at(1)
	table.remove(self, 1)
	return element
end

---Returns a copy of a section of an array. For both start and end, a negative
---index can be used to indicate an offset from the end of the array.
---@param startIndex? integer inclusive
---@param endIndex? integer exclusive
---@return JSArray
function JSArray:slice(startIndex, endIndex)
	assert(type(startIndex) == "number", '`startIndex` must be type of "number"')
	assert(type(endIndex) == "number", '`endIndex` must be type of "number"')

	-- round down incase given inputs is decimal
	startIndex = math.floor(startIndex)
	startIndex = math.floor(endIndex)

	local len = self:getLength()
	local result = {}

	startIndex = startIndex or 1
	endIndex = endIndex or len

	if startIndex > len then
		return result
	elseif startIndex < 0 then
		startIndex = startIndex < -len and 1 or len - math.abs(startIndex) + 1
	end

	if endIndex < 0 then
		endIndex = endIndex < -len and 1 or len - math.abs(endIndex) + 1
	end

	if endIndex <= startIndex then
		return JSArray.new(result)
	end

	for i = startIndex, endIndex do
		table.insert(result, self[i])
	end

	return JSArray.new(result)
end

---Determines whether the specified callback function returns true for any
---element of an array.
---@param callbackFunction fun(element: unknown, index?: integer, array?: JSArray)
---@return boolean
function JSArray:some(callbackFunction)
	for index, value in ipairs(self) do
		if callbackFunction(value, index, self) then
			return true
		end
	end
	return false
end

---@generic T
---@param compareFunction? fun(a: T, b: T): boolean
---@return JSArray
function JSArray:sort(compareFunction)
	table.sort(self, compareFunction)
	return self
end

---Removes elements from an array and, if necessary, inserts new elements in
---their place, returning the deleted elements.
---@generic T
---@param start integer index to start changing the array
---@param deleteCount? integer
---@param ... T
---@return JSArray # An array containing deleted elements
function JSArray:splice(start, deleteCount, ...)
	assert(type(start) == "number", "`start` must be type of number")
	assert(type(deleteCount) == "number", "`start` must be type of number")

	local len = table.getn(self)

	if start < 0 then
		start = len - math.abs(start) + 1
		if start < -len then
			start = 1
		end
	end

	local deletedElements = {}

	for i = start, start + deleteCount - 1 do
		table.insert(deletedElements, self[i])
	end

	local argLen = table.getn(arg)
	local index = 1
	for i = start, start + argLen do
		table.insert(self, i, arg[index])
		index = index + 1
	end

	for i = start + argLen, start + argLen + deleteCount - 1 do
		table.remove(self, start + argLen)
	end

	return JSArray.new(deletedElements)
end

---Reverses the order of the elements in the array.<br/><br/>
---This method **does not change** the original array
---@return JSArray # The reversed array
function JSArray:toReversed()
	local reversedArray = {}

	for index = self:getLength(), 1, -1 do
		table.insert(reversedArray, self:at(index))
	end

	return JSArray.new(reversedArray)
end

---@return string # A string representation of an array
function JSArray:toString()
	return self:join()
end

---Add item(s) to the beginning of an array.
---@generic T
---@param ... T[]
---@return integer length the new length of the array
function JSArray:unshift(...)
	for index, value in ipairs(arg) do
		table.insert(self, index, value)
	end
	return self:getLength()
end

---Returns the array itself
---@return JSArray
function JSArray:valueOf()
	return self
end

---Change the element at `index` with `value` <br /><br />
---This method does not change the original array
---@param index integer
---@param value any
---@return JSArray
function JSArray:with(index, value)
	index = index or 1

	if index < 0 then
		index = self:getLength() + index
	elseif index < -self:getLength() or not index then
		index = 1
	elseif index >= self:getLength() then
		return self
	end

	local result = { unpack(self) }
	result[index] = value

	return JSArray.new(result)
end

-- -------------------------------------------------------------------------- --
--                                   Exports                                  --
-- -------------------------------------------------------------------------- --

return jsarray
