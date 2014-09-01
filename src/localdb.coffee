###
 * localDB
 * localDB.emptystack.net
 *
 * Copyright (c) 2014 Eric Wang
 * Licensed under the MIT license.
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
            return false if not obj[key]?
            if isObject(condition)
                for c_key, c_value of condition
                    switch c_key
                        when "$gt" then return false if obj[key] <= c_value
                        when "$gte" then return false if obj[key] < c_value
                        when "$lt" then return false if obj[key] >= c_value
                        when "$lte" then return false if obj[key] > c_value
                        when "$ne" then return false if obj[key] is c_value
                        else return false if not criteriaCheck(obj[key], JSON.parse("{\"#{c_key}\": #{JSON.stringify(c_value)}}"))
            else
                return false if obj[key] isnt condition
        return true
    #Utils End

    localDB = localDB or (dbName, storageType)->
        ls = storageType
        @db = dbPrefix + dbName
        ls.setItem(@db, "_") if not ls.getItem(@db)?
        @length = -> @collections().length
        return

    localDB.isSupport = -> if localStorage? then true else false

    localDB.prototype.serialize = (collectionName, collection) -> ls.setItem "#{@db}_#{collectionName}", stringify(collection)

    localDB.prototype.deserialize = (collectionName, sort = {}) ->
        collection = parse(ls.getItem("#{@db}_#{collectionName}"))


    localDB.prototype.drop = (collectionName)->
        collectionName = if collectionName? then "_#{collectionName}" else ""
        keys = (ls.key(i) for i in [0...ls.length] when ls.key(i).indexOf(@db + collectionName) is 0)
        ls.removeItem(j) for j in keys
        return

    localDB.prototype.collections = -> if @db? then (ls.key(i) for i in [0...ls.length] when ls.key(i).indexOf("#{@db}_") is 0) else []

    localDB.prototype.insert = (collectionName, rowData) ->
        collection = @deserialize(collectionName)
        collection.push rowData
        @serialize(collectionName, collection)
        return @

    localDB.prototype.find = (collectionName, options = {}) ->
        criteria = if options.criteria? then options.criteria else {}
        projection = if options.projection? then options.projection else {}
        limit = if options.limit? then options.limit else -1
        data = []
        for c in @deserialize(collectionName, options.sort) when criteriaCheck(c, criteria)
            break if limit is 0
            limit = limit - 1
            data.push c
        return data if JSON.stringify(projection) is '{}'
        result = []
        for d in data
            r = {}
            for key, value of projection
                r[key] = d[key] if value is 1
            result.push r
        return result

    localDB.prototype.findOne = (collectionName, options = {}) ->
        options.limit = 1
        @find(collectionName, options)

    localDB.prototype.update = (collectionName, options = {}) ->
        action = options.action
        criteria = if options.criteria? then options.criteria else {}
        collection = @deserialize(collectionName)
        for c in collection when criteriaCheck(c, criteria)
            actions = action.$set
            for key, value of actions
                c[key] = value
        @serialize(collectionName, collection)

    localDB.prototype.remove = (collectionName, options = {}) ->
        criteria = if options.criteria? then options.criteria else {}
        @serialize(collectionName, (c for c in @deserialize(collectionName) when not criteriaCheck(c, criteria)))

    module.exports = localDB

    return

