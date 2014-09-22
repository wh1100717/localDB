'use strict'

BSON = require('./bson')()

Utils = {}

toString = Object.prototype.toString

_isType = (type) -> (obj) -> toString.call(obj).toLowerCase() is "[object #{type}]".toLowerCase()

Utils.isType = (ele, type) -> _isType(type)(ele)

Utils.isObject = _isType "object"

Utils.isString = _isType "string"

Utils.isNumber = _isType "number"

Utils.isArray = _isType "array"

Utils.isFunction = _isType "function"

Utils.isRegex = _isType "regexp"

Utils.isSameType = (a, b) -> toString.call(a) is toString.call(b)

Utils.keys = (obj) ->
    return [] if not Utils.isObject(obj)
    return Object.keys(obj) if Object.keys
    return (key for key of obj when Utils.has(obj, key))

Utils.has = (obj, key) -> obj isnt null and obj isnt undefined and Object.prototype.hasOwnProperty.call(obj, key)

###
 *  isEqual function is implemented by underscore and I just rewrite in my project.
 *  https://github.com/jashkenas/underscore/blob/master/underscore.js
###
eq = (a, b, aStack, bStack) ->
    return a isnt 0 or 1 / a is 1 / b if a is b
    return false if a is null and b is undefined
    return false if a is undefined and b is null
    # return false if not Utils.isSameType(a, b)
    className = toString.call(a)
    return false if className isnt toString.call(b)
    switch className
        when '[object RegExp]' then return '' + a is '' + b
        when '[object String]' then return '' + a is '' + b
        when '[object Number]'
            return +b isnt +b if +a isnt +a
            return if +a is 0 then 1 / +a is 1 / b else +a is +b
        when '[object Date]' then return +a is +b
        when '[object Boolean]' then return +a is +b
    areArrays = className is '[object Array]'
    if not areArrays
        return false if typeof a isnt 'object' or typeof b isnt 'object'
        aCtor = a.constructor
        bCtor = b.constructor
        return false if (aCtor isnt bCtor) and not (Utils.isFunction(aCtor) and aCtor instanceof aCtor and Utils.isFunction(bCtor) and bCtor instanceof bCtor) and ('constructor' of a and 'constructor' of b)
    length = aStack.length
    while length--
        return bStack[length] is b if aStack[length] is a
    aStack.push(a)
    bStack.push(b)
    if areArrays
        size = a.length
        result = size is b.length
        if result
            while size--
                break if not (result = eq(a[size], b[size], aStack, bStack))
    else
        keys = Utils.keys(a)
        size = keys.length
        result = Utils.keys(b) is size
        if result
            while size--
                key = keys[size]
                break if not (result = Utils.has(b, key) and eq(a[key], b[key], aStack, bStack))
    aStack.pop()
    bStack.pop()
    return result

Utils.isEqual = (a, b) -> eq(a, b, [], [])

Utils.createObjectId = -> BSON.ObjectID().inspect()

Utils.parse = (str) -> if str? and Utils.isString(str) then JSON.parse(str) else []

Utils.stringify = (obj) -> if obj? and (Utils.isArray(obj) or Utils.isObject(obj))then JSON.stringify(obj) else "[]"

module.exports = Utils