# JS-array.lua

## Table of Contents

-   [Installation](#installation)
-   [Usage](#usage)
-   [API](#api)
-   [Meta Functions](#meta-functions)

A Javascript-like array library for Lua. Built for Lua 5.0.x.

## Installation

Just download the [JS-array.lua](https://github.com/RanggaBS/JS-array.lua/blob/main/js-array.lua) file & put it into your project folder.

## Usage

```lua
-- Require the module
local JSArray = require("js-array")

-- Instantiate a new array
local a = JSArray.new(5, false, "hiya!")
-- local a = JSArray(5, false, "hiya!") -- it's the same, but type hints don't work

-- Prints each element
a:forEach(function(element, index, array)
	print(element, index)
end)

-- Output:
-- 5	1
-- false	2
-- hiya!	3
```

## API

\* **T**: Type of the elements the array contains. (Generic type)

### at()

Takes an integer value and returns the item at that index, allowing for positive and negative integers. Negative integers count back from the last item in the array.

#### Syntax

```lua
at(index)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`index`: **integer** - Index of the array element to be returned. Negative index counts back from the end of the array.

#### Return value

`element`: **T** - The element in the array matching the given index.

#### Example

```lua
local a = JSArray(2, 5, 4)
print(a:at(2)) --> 5
```

### concat()

Merge two or more arrays. This method does not change the existing arrays, but instead returns a new array.

#### Syntax

```lua
concat()
concat(value1)
concat(value1, value2)
concat(value1, value2, --[[ ..., ]] valueN)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`...`: **any** - Arrays and/or values to concatenate into a new array. If parameters are omitted, concat returns a copy of the existing array on which it is called.

#### Return value

`array`: **JSArray** - A new array.

#### Example

```lua
local a = JSArray('a', 'b', 'c')
local b = JSArray('d', 'e', JSArray('f'))
print(a:concat(b))

-- Output:
-- {'a', 'b', 'c', 'd', 'e', {'f'}}
```

### copyWithin()

Shallow copies part of this array to another location in the same array and returns this array without modifying its length.

This methods overwrites the existing values.

#### Syntax

```lua
copyWithin()
copyWithin(targetIndex)
copyWithin(targetIndex, startIndex)
copyWithin(targetIndex, startIndex, endIndex)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`targetIndex` (optional): **integer** - Default is `1`

`startIndex` (optional): **integer** - Inclusive. Default is `1`

`endIndex` (optional): **integer** - Exclusive. Default is the array length.

#### Return value

`array`: **JSArray** - The modified array.

#### Example

```lua
local a = JSArray(1, 2, 3, 4, 5)
print(a:copyWithin(1, 4):join()) --> 4,5,3,4,5

a = JSArray(1, 2, 3, 4, 5)
print(a:copyWithin(1, 4, 5):join()) --> 4,2,3,4,5

a = JSArray(1, 2, 3, 4, 5)
print(a:copyWithin(-2, -3, -1):join()) --> 1,2,3,3,4

a = JSArray(1, 2, 3, 4, 5)
print(a:copyWithin():join()) --> 1,2,3,4,5
```

### entries()

Returns an iterable of key, value pairs for every entry in the array.

#### Syntax

```lua
entries()
```

#### Parameters

None.

#### Return value

`iterator`: **function** - An iterator function returning the `index` & the `value` of the array.

#### Example

```lua
local a = JSArray('a', 'b', 'c')
for i, v in a:entries() do
	print(i, v)
end

-- Output:
-- 1	a
-- 2	b
-- 3	c
```

### every()

Determines whether all the members of an array satisfy the specified test.

#### Syntax

```lua
every(callbackFunction)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array. It should return a truthy value to indicate the element passes the test, and a falsy value otherwise. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

    -   `array`: **JSArray** - The array `every()` was called upon.

-   Return value

    -   `boolean`

#### Return value

`boolean` - `true` if all elements pass the test, otherwise `false`.

#### Example

```lua
function isBigEnough(element, index, array)
	return element >= 7
end

local a = JSArray(9, 8, 2, 9, 8, 6, 4)
local b = JSArray(7, 8, 12, 9, 9, 20, 13)

print(a:every(isBigEnough)) --> false
print(b:every(isBigEnough)) --> true
```

### fill()

Changes all array elements from start to end index to a static value and returns the modified array.

This method overwrites the original array.

#### Syntax

```lua
fill(value)
fill(value, startIndex)
fill(value, startIndex, endIndex)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`value`: **any** - Value to fill array section with.

`startIndex` (optional): **integer** - (inclusive) Index to start filling the array at. If it is negative, it is treated as `length + startIndex + 1` where length is the length of the array.

`endIndex` (optional): **integer** - (exclusive) Index to stop filling the array at. If it is negative, it is treated as length+end.

#### Return value

`array`: **JSArray** - The modified array, filled with `value`.

#### Example

```lua
local a = JSArray.new(1, 2, 3, 4, 5, 6, 7)
print(a:fill(9, 3, -3):join()) --> 1,2,9,9,5,6,7
```

### filter()

Returns the elements of an array that meet the condition specified in a callback function.

This method does not change the original array.

#### Syntax

```lua
filter(predicate)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`predicate`: **function** - A function to execute for each element in the array. It should return a truthy value to keep the element in the resulting array, and a falsy value otherwise. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

    -   `array`: **JSArray** - The array `filter()` was called upon.

-   Return value

    -   `boolean`

#### Return value

`array`: **JSArray** - A new array containing just the elements that pass the test.

#### Example

```lua
function isGreaterThan20(element, index, array)
	return element[2] > 20
end

local a = JSArray(
	{"Cloud", 21},
	{"Tifa", 20},
	{"Aerith", 22},
)

local b = a:map(isGreaterThan20)

b:forEach(function(entry)
	local name = 'name = "'..entry[1]..'"'
	local age = "age = "..tostring(entry[2]])
	print('{'..name..", "..age..'}')
end)

-- Output:
-- {name = "Cloud", age = 21},
-- {name = "Aerith", age = 22},
```

### find()

Returns the value of the first element in the array where `predicate` is `true` and `nil` otherwise.

#### Syntax

```lua
find(predicate)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`predicate`: **function** - A function to execute for each element in the array. It should return a truthy value to indicate a matching element has been found, and a falsy value otherwise. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

    -   `array`: **JSArray** - The array `find()` was called upon.

-   Return value

    -   `boolean`

#### Return value

`element`: **any** - The first element in the array that satisfies the provided testing function. Otherwise, `nil` is returned.

#### Example

```lua
local inventory = JSArray(
	{ name = "apples", quantity = 3 },
	{ name = "bananas", quantity = 5 },
	{ name = "oranges", quantity = 2 }
)

function isBananas(fruit)
	return fruit.name == "bananas"
end

local fruitItem = inventory:find(isBananas)

local name = "name = \""..fruitItem.name.."\""
local quantity = "quantity = "..tostring(fruitItem.quantity)
print('{'..name..", "..quantity..'}')

-- Output:
-- {name = "bananas", quantity = 5}
```

### findIndex()

Returns the index of the first element in the array where predicate is `true` and `-1` otherwise.

#### Syntax

```lua
findIndex(callbackFunction)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array. It should return a truthy value to indicate a matching element has been found, and a falsy value otherwise. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

    -   `array`: **JSArray** - The array `findIndex()` was called upon.

-   Return value

    -   `boolean`

#### Return value

`index`: **integer** - The index of the first element in the array that passes the test. Otherwise, `-1`.

#### Example

```lua
function is5(element)
	return element == 5
end

local a = JSArray(2, 1, 1, 4, 6, 6, 7)
local b = JSArray(7, 2, 7, 5, 4, 1, 7)

print(a:findIndex(is5)) --> -1
print(b:findIndex(is5)) --> 4
```

### findLast()

Iterates the array in reverse order and returns the value of the first element that satisfies the provided testing function. If no elements satisfy the testing function, `nil` is returned.

#### Syntax

```lua
findLast(callbackFunction)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array. It should return a truthy value to indicate a matching element has been found, and a falsy value otherwise. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

    -   `array`: **JSArray** - The array `findLast()` was called upon.

-   Return value

    -   `boolean`

#### Return value

`element`: **T** - The value of the last element that pass the test.
Otherwise it returns `nil`.

#### Example

```lua
local inventory = JSArray(
	{ name = "apples", quantity = 3 },
	{ name = "tomatoes", quantity = 1 },
	{ name = "bananas", quantity = 5 },
	{ name = "oranges", quantity = 2 }
)

function isNotEnough(fruit)
	return fruit.quantity < 2
end

local fruitItem = inventory:findLast(isNotEnough)

local name = "name = \""..fruitItem.name.."\""
local quantity = "quantity = "..tostring(fruitItem.quantity)
print('{'..name..", "..quantity..'}')

-- Output:
-- {name = "tomatoes", quantity = 1}
```

### findLastIndex()

Iterates the array in reverse order and returns the index of the first element that satisfies the provided testing function. If no elements satisfy the testing function, `-1` is returned.

#### Syntax

```lua
findLastIndex(calbackFunction)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array. It should return a truthy value to indicate a matching element has been found, and a falsy value otherwise. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

    -   `array`: **JSArray** - The array `every()` was called upon.

-   Return value

    -   `boolean`

#### Return value

`index`: **integer** - The index of the last element that passes the test.
Otherwise `-1`.

#### Example

```lua
local a = JSArray(157, 161, 104, 61, 176, 146, 192)

function isGreaterThan(number)
	return function(element)
		return element > number
	end
end

print(a:findLastIndex(isGreaterThan(150))) --> 7
print(a:findLastIndex(isGreaterThan(200))) --> -1
```

### flat()

Returns a new array with all sub-array elements concatenated into it recursively up to the specified depth.

#### Syntax

```lua
flat()
flat(depth)
```

#### Parameters

`depth`: **integer** - The depth level specifying how deep a nested array structure should be flattened. Defaults to `1`.

#### Return value

`array`: **JSArray** - The flattened array.

#### Example

```lua
local a = JSArray.new(1, 2, { 3, 4, { 5, 6, { 7, 8 } } })
print(a:flat()) --> {1, 2, 3, 4, {5, 6, {7, 8}}}
print(a:flat(2)) --> {1, 2, 3, 4, 5, 6, {7, 8}}
print(a:flat(math.huge)) --> {1, 2, 3, 4, 5, 6, 7, 8}
```

### flatMap()

Calls a defined callback function on each element of an array. Then, flattens the result into a new array. This is identical to a map followed by flat with depth `1`.

This method does not change the original array.

#### Syntax

```lua
flatMap(callbackFunction)
```

#### Generics

`T` - Type of the elements the array contains.

`U` - Type of the elements of the new array will contain.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array. It should **return an array containing new elements** of the new array, **or a single non-array value** to be added to the new array. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index` (optional): **integer** - The index of the current element being processed in the array.

    -   `array` (optional): **JSArray** - The array `forEach()` was called upon.

-   Return value

    -   `item`: **U | JSArray** - The mapped original element. An array or a non-array.

#### Return value

`array`: **JSArray** - An array with the elements as a result of `callbackFunction` and then flattened.

#### Example

```lua
local a = JSArray.new(1, 2, 3, 4)

local b = a:flatMap(function(x) return { x * 2 } end)
--> `b` is now: {2, 4, 6, 8}

local c = a:flatMap(function(x) return { { x * 2 } } end)
--> `c` is now: {{2}, {4}, {6}, {8}}

local d = JSArray.new(5, 4, -3, 20, 17, -33, -4, 18)

local e = d:flatMap(function(n)
	if n < 0 then
		return {}
	end
	return n % 2 == 0 and { n } or { n - 1, 1 }
end)
--> variable `e` is now: {4, 1, 4, 20, 16, 1, 18}
```

### forEach()

Executes a provided function once for each array element.

#### Syntax

```lua
forEach(callbackFunction)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array.

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index` (optional): **integer** - The index of the current element being processed in the array.

    -   `array` (optional): **JSArray** - The array `forEach()` was called upon.

-   Return value

    -   None, `nil`.

#### Return value

None, `nil`.

#### Example

```lua
JSArray(1, 2, 3):forEach(function(element)
	print(element * element)
end)

-- Output:
-- 1
-- 4
-- 9
```

### from()

Creates an array from an iterable or array-like object.

#### Syntax

```lua
JSArray.from(arrayLike)
JSArray.from(arrayLike, mapFunction)
```

#### Generics

`T` - Type of the elements of the array contains.

`U` - Type of the elements of the new array will contain.

#### Parameters

`arrayLike`: **any** - An iterable or array-like object to convert to an array.

`mapFunction` (optional): **function** - A function to call on every element of the array. If provided, every value to be added to the array is first passed through this function, and `mapFunction`'s return value is added to the array instead. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

-   Return value

    -   `element`: **U** - The new elements of the new array will contain.

#### Return value

`array`: **JSArray** - A new array.

#### Example

```lua
print(JSArray.from("abc"):join()) --> a,b,c
print(JSArray.from(123)) --> {}
print(JSArray.from(false)) --> {}
print(JSArray.from(function() end)) --> {}
print(JSArray.from({ "foo", "bar" }):join()) --> foo,bar
print(JSArray.from({ foo = "bar" })) --> {}
print(JSArray.from("123", function(element)
	return tonumber(element) * 2
end):join()) --> 2,4,6
```

### getLength()

Returns the length of an array. The same as using `table.getn()`, or `#array` in newer version of Lua.

#### Syntax

```lua
getLength()
```

#### Parameters

None.

#### Return value

`length`: **integer** - The length of an array.

#### Example

```lua
print(JSArray('a', 'b'):getLength()) --> 2
```

### includes()

Determines whether an array includes a certain element, returning `true` or `false` as appropriate.

#### Syntax

```lua
includes(searchElement)
includes(searchElement, fromIndex)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`searchElement`: **T** - The value to search for.

`fromIndex` (optional): **integer** - Index at which to start searching. Negatives index is allowed.

#### Return value

`boolean` - `true` if the value is found, otherwise `false`.

#### Example

```lua
local a = JSArray.new(false, 5, nil, "FOO")
print(a:includes(false)) --> true
print(a:includes(false, -3)) --> false
print(a:includes(nil)) --> true
print(a:includes("FOO")) --> true
print(a:includes("FOO", 2)) --> true
print(a:includes(5)) --> true
print(a:includes(5, -2)) --> false
```

### indexOf()

Returns the first index at which a given element can be found in the array, or `-1` if it is not present.

#### Syntax

```lua
indexOf(searchElement)
indexOf(searchElement, fromIndex)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`searchElement`: **any** - Element to locate in the array.

`fromIndex`: **integer** - Index at which to start searching.

#### Return value

`index`: **integer** - The first index of `searchElement` in the array, `-1` if not found.

#### Example

```lua
local a = JSArray('a', 'b', 'b')
print(a:indexOf('a')) --> 1
print(a:indexOf('c')) --> -1
print(a:indexOf('b', 3)) --> 3
print(a:indexOf('a', -1)) --> -1
print(a:indexOf('a', -3)) --> 1
```

### isArray()

Determines whether the passed value is an array or not. Returns `false` if parameters omitted.

#### Syntax

```lua
JSArray.isArray(value)
```

#### Parameters

`value`: **any** - The value to be checked.

#### Return value

`boolean` - `true` if value is an array, otherwhise `false`.

#### Example

```lua
-- All following calls return true
print(JSArray.isArray({ 999 }))
print(JSArray.isArray({ 5, false, "FOOBAR" }))
print(JSArray.isArray(JSArray.new(123, true, "BARFOO")))

-- All following calls return false
print(JSArray.isArray(JSArray.new()))
print(JSArray.isArray({}))
print(JSArray.isArray({ FOO = "BAR" }))
print(JSArray.isArray())
print(JSArray.isArray(nil))
print(JSArray.isArray(27))
print(JSArray.isArray("FOO"))
print(JSArray.isArray(true))
print(JSArray.isArray(false))
```

### isJSArray()

Check if a value is JSArray object.

#### Syntax

```lua
JSArray.isJSArray(value)
```

#### Parameters

`value`: **any** - The value to be checked.

#### Return value

`boolean` - `true` if value is an array, otherwhise `false`.

#### Example

```lua
local a = JSArray.new(1, 2, 3)
local b = { 1, 2, 3 }
print(JSArray.isJSArray(a)) --> true
print(JSArray.isJSArray(b)) --> false
```

### join()

Adds all the elements of an array into a string, separated by the specified separator string.

#### Syntax

```lua
join()
join(separator)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`separator` (optional): **string** - default is `','`

#### Return value

`string` - A string with all array elements joined. If the array length is 0, an empty string is returned.

#### Example

```lua
local a = JSArray(
	'a',
	function()end,
	JSArray(
		'b',
		{'c', 'd'},
		{e = 'f'},
		'g'
	),
	'h'
)
print(a:join()) --> "a,function: XXXXXXXX,b,c,d,table: XXXXXXXX,g,h"
```

### keys()

Returns an iterable of keys in the array.

#### Syntax

```lua
keys()
```

#### Parameters

None.

#### Return value

`iterator`: **function** - An iterator function returning an integer (index) of the array.

#### Example

```lua
local a = JSArray('a', 'b', 'c')
for index in a:keys() do
	print(index)
end

-- Output:
-- 1
-- 2
-- 3
```

### lastIndexOf()

Returns the index of the last occurrence of a specified value in an array, or `-1` if it is not present.

#### Syntax

```lua
lastIndexOf(searchElement)
lastIndexOf(searchElement, fromIndex)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`searchElement`: **T** - The value to locate in the array.

`fromIndex` (optional): **integer** - The array index at which to begin searching backward. If fromIndex is omitted, the search starts at the last index in the array.

#### Return value

`index`: **integer** - The last index of searchElement in the array, `-1` if not found.

#### Example

```lua
local numbers = JSArray(2, 5, 9, 2)
print(numbers:lastIndexOf(2)) -- 4
print(numbers:lastIndexOf(7)) -- -1
print(numbers:lastIndexOf(2, 4)) -- 4
print(numbers:lastIndexOf(2, 2)) -- 1
print(numbers:lastIndexOf(2, -2)) -- 1
print(numbers:lastIndexOf(2, -1)) -- 4

```

### map()

Calls a defined callback function on each element of an array, and returns an array that contains the results.

This method does not change the original array.

#### Syntax

```lua
map(callbackFunction)
```

#### Generics

`T` - Type of the elements the array contains.

`U` - Type of the elements of the new array will contain.

#### Parameters

`callbackFunction`: **function** - A function that accepts up to three arguments. The map method calls the `callbackFunction` function one time for each element in the array. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

    -   `array`: **JSArray** - The array `map()` was called upon.

-   Return value

    -   `element`: **U** - The new elements of the new array will contain.

#### Return value

`array`: **JSArray** - A new array with each element being the result of the callback function.

#### Example

```lua
-- Example 1
local a = JSArray.new(1, 4, 9)
print(a:map(function(num)
	return math.sqrt(num)
end):join()) --> 1,2,3

print("'a' is still " .. a:join())
--> 'a' is still 1,4,9

-- Example 2
local b = JSArray.new(
	-- familiar with these names?
	{ name = "Cloud", age = 21 },
	{ name = "Tifa", age = 20 },
	{ name = "Aerith", age = 22 }
)
local bFormatted = b:map(function(character)
	return { character.name, character.age }
end)
--[[ 'bFormatted' is now:
{
	{ "Cloud", 21 },
	{ "Tifa", 20 },
	{ "Aerith", 2 2}
}
]]
print(bFormatted:join(";"))
--> Cloud,21;Tifa,20;Aerith,22
-- 'b' still remains unchanged
```

### of()

Creates a new array instance from a variable number of arguments, regardless of number or type of the arguments.

#### Syntax

```lua
JSArray.of()
JSArray.of(element1)
JSArray.of(element1, element2)
JSArray.of(element1, element2, --[[ ..., ]] elementN)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`...`: **T** - A set of elements to include in the new array.

#### Return value

`array`: **JSArray** - A new array.

#### Example

```lua
print(JSArray.of({ 99999, FOO = "BAR", true, "asd", 99 }, true, 99, "OYI"))
-- return value: { { 99999, true, "asd", 99, FOO = "BAR" }, true, 99, "OYI" }

print(JSArray.of("asd", 12, true):join())
--> asd,12,true

print(JSArray.of()) --> {}
```

### pop()

Removes the last element from an array and returns it. If the array is empty, `nil` is returned and the array is not modified.

This method changes the original array.

#### Syntax

```lua
pop()
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

None.

#### Return value

`element`: **T** - The removed element from the array.

#### Example

```lua
local a = JSArray('a', 'b', 'c')
print(a:pop()) --> c
-- `a` is now `{'a', 'b'}`
print(a:join()) --> a,b
```

### push()

Appends new elements to the end of an array, and returns the new length of the array.

This method changes the original array.

#### Syntax

```lua
push()
push(element1)
push(element1, element2)
push(element1, element2, --[[ ..., ]] elementN)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`...`: **T** - New elements to add to the array.

#### Return value

`length`: **integer** - The new array length.

#### Example

```lua
local a = JSArray('a', 'b')
print(a:push('c', 'd')) --> 4
-- `a` is now `{'a', 'b', 'c', 'd'}`
print(a:join()) --> a,b,c,d
```

### reduce()

Calls the specified callback function for all the elements in an array. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.

This method does not change the original array.

#### Syntax

```lua
reduce(callbackFunction)
reduce(callbackFunction, initialValue)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array. Its return value becomes the value of the `accumulator` parameter on the next invocation of `callbackFunction`. For the last invocation, the return value becomes the return value of `reduce()`. The function is called with the following arguments:

-   `accumulator`: **T** - The value resulting from the previous call to `callbackFunction`. On the first call, its value is `initialValue` if the latter is specified; otherwise its value is `array[1]`.

-   `currentValue`: **T** - The value of the current element. On the first call, its value is `array[1]` if `initialValue` is specified; otherwise its value is `array[2]`.

-   `currentIndex`: **integer** - The index position of `currentValue` in the array. On the first call, its value is `1` if initialValue is specified, otherwise `2`.

-   `array`: **JSArray** - The array `reduce()` was called upon.

`initialValue` (optional): **T** - If specified, it is used as the initial value to start the accumulation. The first call to the `callbackFunction` function provides this value as an argument instead of an array value.

#### Return value

`value`: **T** - The value that results from running the "reducer" callback function to completion over the entire array.

#### Example

```lua

```

### reduceRight()

Calls the specified callback function for all the elements in an array, in descending order. The return value of the callback function is the accumulated result, and is provided as an argument in the next call to the callback function.

#### Syntax

```lua
reduceRight(callbackFunction)
reduceRight(callbackFunction, initialValue)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array. Its return value becomes the value of the `accumulator` parameter on the next invocation of `callbackFunction`. For the last invocation, the return value becomes the return value of `reduceRight()`. The function is called with the following arguments:

-   `accumulator`: **T** - The value resulting from the previous call to `callbackFunction`. On the first call, its value is `initialValue` if the latter is specified; otherwise its value is the last element of the array.

-   `currentValue`: **T** - The value of the current element. On the first call, its value is the last element if `initialValue` is specified; otherwise its value is the second-to-last element.

-   `currentIndex`: **integer** - The index position of `currentValue` in the array. On the first call, its value is the `array length` if `initialValue` is specified, otherwise `array length - 1`.

-   `array`: **JSArray** - The array `reduceRight()` was called upon.

`initialValue` (optional): **T** - If specified, it is used as the initial value to start the accumulation. The first call to the `callbackFunction` function provides this value as an argument instead of an array value.

#### Return value

`value`: **T** - The value that results from the reduction.

#### Example

```lua

```

### reverse()

Reverses the order of the elements in the array and returns it.

This method overwrites the original array.

To reverse the elements in an array without mutating the original array, use `toReversed()`.

#### Syntax

```lua
reverse()
```

#### Parameters

None.

#### Return value

`array`: **JSArray** - The reference to the original array, now reversed.

#### Example

```lua
local a = JSArray(5, 9, 7, 1)
local b = a:reverse()
print(a:join()) --> 1,7,9,5
print(b:join()) --> 1,7,9,5
b[1] = 999
print(a:join()) --> 999,7,9,5
print(b:join()) --> 999,7,9,5
```

### shift()

Removes the **first** element from an array and returns it.

This method changes the original array.

#### Syntax

```lua
shift()
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

None.

#### Return value

`element`: **T** - The removed element from the array.

#### Example

```lua
local a = JSArray('a', 'b', 'c')
print(a:join()) --> a,b,c
local removed = a:shift()
print(a:join()) --> b,c
print(removed) --> a
```

### slice()

Returns a copy of a section of an array. For both start and end, a negative index can be used to indicate an offset from the end of the array.

#### Syntax

```lua
slice()
slice(startIndex)
slice(startIndex, endIndex)
```

#### Parameters

`startIndex` (optional): **integer** - inclusive

`endIndex` (optional): **integer** - exclusive

#### Return value

`array`: **JSArray** - A new array containing the extracted elements.

#### Example

```lua
local a = JSArray('a', 'b', 'c', 'd', 'e')
print(a:slice(3):join()) --> c,d,e
print(a:slice(3, 5):join()) --> c,d
print(a:slice(2, 6):join()) --> b,c,d,e
print(a:slice(-2):join()) --> d,e
print(a:slice(3, -1):join()) --> c,d
print(a:slice():join()) --> a,b,c,d,e
```

### some()

Determines whether the specified callback function returns `true` for any element of an array.

#### Syntax

```lua
some(callbackFunction)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`callbackFunction`: **function** - A function to execute for each element in the array. It should return a truthy value to indicate the element passes the test, and a falsy value otherwise. The function is called with the following arguments:

-   Parameters

    -   `element`: **T** - The current element being processed in the array.

    -   `index`: **integer** - The index of the current element being processed in the array.

    -   `array`: **JSArray** - The array `some()` was called upon.

-   Return value

    -   `boolean`

#### Return value

`boolean` - `true` if any of the array elements pass the test, otherwise `false`.

#### Example

```lua
function isBiggerThan(num)
	return function(element, index, array)
		return element > num
	end
end

local a = JSArray(1, 12, 4, 17, 12, 10, 8)
print(a:some(isBiggerThan(7))) --> true
print(a:some(isBiggerThan(20))) --> false
```

### sort()

Sorts an array in place & returns the sorted array.

This method overwrites the original array.

#### Syntax

```lua
sort()
sort(compareFunction)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`compareFunction`: **function** - A function that determines the order of the elements. The function is called with the following arguments:

-   Parameters

    -   `a`: **T** - The first element for comparison.

    -   `b`: **T** - The second element for comparison.

-   Return value

    -   `boolean`

#### Return value

`array`: **JSArray** - The array with the items sorted.

#### Example

```lua
local A = JSArray(2, 1, 4, 3, 5, 7, 6)
local B = A:slice()
print(A:sort():join()) --> 1,2,3,4,5,6,7
print(B:sort(function(a, b)
	return a > b
end):join()) --> 7,6,5,4,3,2,1
```

### splice()

Removes elements from an array and, if necessary, inserts new elements in their place, returning the deleted elements.

This method overwrites the original array.

#### Syntax

```lua
splice(start)
splice(start, deleteCount)
splice(start, deleteCount, item1)
splice(start, deleteCount, item1, item2)
splice(start, deleteCount, item1, item2, --[[ ..., ]] itemN)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`start`: **integer** - Index to start changing the array. A negative value counts from the end of the array.

`deleteCount` (optional): **integer** - The number of elements to remove.

`...`: **T** - Elements to insert into the array in place of the deleted elements.

#### Return value

`array`: **JSArray** - An array containing the deleted elements.

#### Example

```lua

```

### toReversed()

Reverses the order of the elements in the array and returns the reversed array.

This method does not change the original array.

#### Syntax

```lua
toReversed()
```

#### Parameters

None.

#### Return value

`array`: **JSArray** - A new array containing the elements in reversed order.

#### Example

```lua
local a = JSArray(1, 2, 3)
local b = a:toReversed()
print(b:join()) --> 3,2,1
print(a:join()) --> 1,2,3
```

### toString()

Returns a string representing the specified array and its elements.

The same as calling `array:join()` or `array:join(',')`.

This method does not change the original array.

#### Syntax

```lua
toString()
```

#### Parameters

None.

#### Return value

`string` - A string representing the elements of the array.

#### Example

```lua
local a = JSArray(5, false, 'a')
print(a:toString()) --> 5,false,a
```

### unshift()

Inserts new elements at the start of an array, and returns the new length of the array.

This method overwrites the original array.

#### Syntax

```lua
unshift()
unshift(value1)
unshift(value1, value2)
unshift(value1, value2, --[[ ..., ]] valueN)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`...`: **T** - The elements to add to the front of the array.

#### Return value

`length`: **integer** - The new length of the array.

#### Example

```lua
local a = JSArray(3, 4, 5)
local length = a:unshift(0, 1, 2)
print(a:join()) --> 0,1,2,3,4,5
print(length) --> 6
```

### valueOf()

Returns the reference to the array itself.

#### Syntax

```lua
valueOf()
```

#### Parameters

None.

#### Return value

`array`: **JSArray** - This array reference itself.

#### Example

```lua
local a = JSArray('a', 'b')
local b = a:valueOf() -- the same as `local b = a`
b[2] = 'c'
print(a:join()) --> a,c
print(b:join()) --> a,c
```

### values()

Returns an iterable of values in the array.

#### Syntax

```lua
values()
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

None.

#### Return value

`iterator`: **function** - An iterator function returning an element in the array.

#### Example

```lua
local a = JSArray.new("a", "b", "c")
for value in a:values() do
	print(value)
end

-- Output:
-- a
-- b
-- c
```

### with()

Change the value of a given index in the array without altering the original array, and return it.

Same as regular syntax `array[index] = value`.

This method does not change the original array.

#### Syntax

```lua
with(index, value)
```

#### Generics

`T` - Type of the elements the array contains.

#### Parameters

`index`: **integer** - Index at which to change the array. Negative index counts back from the end of the array.

`value`: **any** - Any value to be assigned to the given index.

#### Return value

`array`: **JSArray** - A new array with the element at `index` replaced with `value`.

#### Example

```lua
local a = JSArray('a', 'b', 'c')
local b = a:with(2, 'd')
print(b:join()) --> a,d,c
print(a:join()) --> a,b,c
```

## Meta Functions

### \_\_concat()

Allowing to concatenate an array using the concatenation operator (`..`).

#### Example

```lua
local a = JSArray.new(1, 2, 3)
local b = JSArray.new(4, 5, 6)
local c = a .. b --> {1, 2, 3, 4, 5, 6}
local d = 3 .. b --> {3, 4, 5, 6}
local e = d .. "seven" --> {3, 4, 5, 6, "seven"}
print(c:join())
print(d:join())
print(e:join())
```

### \_\_tostring()

Print the representation of the array in a human-readable format.

#### Example

```lua
local a = JSArray.new(
	"BLAH",
	JSArray.new("TESTING...", function() end, -123),
	false,
	999,
	{
		[false] = "dunno",
		"BRUH",
		FOO = "BAR",
		true,
		[{ 5, 1 }] = "this is..",
		[function() end] = "fun",
		function() end,
	}
)
print(a)
-- print(tostring(a)) (it's the same)

--[[
Output:
{
	[1] = "BLAH",
	[2] = {
		[1] = "TESTING...",
		[2] = function: 00XXXXXX,
		[3] = -123,
	},
	[3] = false,
	[4] = 999,
	[5] = {
		[1] = "BRUH",
		[2] = true,
		[3] = function: 00XXXXXX,
		[false] = "dunno",
		["FOO"] = "BAR",
		[function: 00XXXXXX] = "fun",
		[table: 00XXXXXX] = "this is..",
	},
}
]]
```
