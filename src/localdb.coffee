###
 * localDB
 * localDB.emptystack.net
 *
 * Copyright (c) 2014 Eric Wang
 * Licensed under the MIT license.
###

###localStorage API
    *   setItem(key, val)
    *   getItem(key)
    *   removeItem(key)
    *   clear()
    *   key(index)
    *   length
###

define (require, exports, module) ->

    'use strict'
    ls = window.localStorage
    dbPrefix = "ldb_"

    #Utils
    _isType = (type) -> (obj) -> {}.toString.call(obj) is "[object #{type.toLowerCase().replace(/\w/, (w) -> w.toUpperCase())}]"
    isType = (ele, type) -> _isType(type)(ele)
    isObject = _isType("object")
    isString = _isType("string")
    isArray = _isType("array")
    isFunction = _isType("function")
    isNumber = _isType("number")

    parse = (str)-> if str? and isString(str) then JSON.parse(str) else []

    stringify = (obj) -> if obj? and isArray(obj) then JSON.stringify(obj) else "[]"

    criteriaCheck = (obj, criteria) ->
        for key, condition of criteria
            for c_key, c_value of condition
                switch c_key
                    when "$gt" then return false if obj[key] <= c_value
                    when "$gte" then return false if obj[key] < c_value
                    when "$lt" then return false if obj[key] >= c_value
                    when "$lte" then return false if obj[key] > c_value
                    when "$ne" then return false if obj[key] is c_value
                    when "$eq" then return false if obj[key] isnt c_value
        return true

    #Utils End

    localDB = localDB or (dbName)->
        @db = dbPrefix+dbName
        ls.setItem(@db, "_") if ls.getItem(@db)?
        @length = -> @collections().length
        return

    localDB.prototype.collections = -> if @db? then (ls.key(i) for i in [0...ls.length] when ls.key(i).indexOf("#{@db}_") is 0) else []

    localDB.prototype.clear = -> ls.removeItem(ls.key(i)) for i in [0...ls.length] when ls.key(i).indexOf("#{@db}_") is 0;@

    localDB.prototype.insert = (collectionName, rowData) ->
        collectionName = "#{@db}_#{collectionName}"
        collection = ls.getItem(collectionName)
        collection = parse collection
        collection.push rowData
        ls.setItem collectionName, stringify(collection)
        return @

    localDB.prototype.find = (collectionName, criteria = {}, limit = -1) ->
        collectionName = "#{@db}_#{collectionName}"
        collection = ls.getItem(collectionName)
        collection = "[]" if not collection?
        collection = parse collection
        data = []
        for c in collection when criteriaCheck(c, criteria)
            break if limit is 0
            limit = limit - 1
            data.push c
        return data

    localDB.prototype.update = (collectionName, action, criteria = {}) ->
        collectionName = "#{@db}_#{collectionName}"
        collection = ls.getItem(collectionName)
        collection = "[]" if not collection?
        collection = parse collection
        for c in collection when criteriaCheck(c, criteria)
            actions = action.$set
            for key, value of actions
                c[key] = value
        ls.setItem collectionName, stringify(collection)

    localDB.prototype.remove = (collectionName, criteria = {}) ->
        collectionName = "#{@db}_#{collectionName}"
        collection = ls.getItem(collectionName)
        collection = "[]" if not collection?
        collection = parse collection
        ls.setItem collectionName, stringify(c for c in collection when not criteriaCheck(c, criteria))

    module.exports = localDB

    return

