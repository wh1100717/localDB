Utils = {}

_isType = (type) -> (obj) -> {}.toString.call(obj).toLowerCase() is "[object #{type}]".toLowerCase()
Utils.isType = (ele, type) -> _isType(type)(ele)
Utils.isObject = _isType "object"
Utils.isString = _isType "string"
Utils.isArray = _isType "array"
Utils.isFunction = _isType "function"
Utils.isNumber = _isType "number"
Utils.isRegex = _isType "regexp"

Utils.parse = (str) -> if str? and Utils.isString(str) then JSON.parse(str) else []
Utils.stringify = (obj) -> if obj? and Utils.isArray(obj) then JSON.stringify(obj) else "[]"

module.exports = Utils