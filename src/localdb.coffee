dbPrefix = "ldb_"

#Utils
_isType = (type) -> (obj) -> {}.toString.call(obj) is "[object #{type.toLowerCase().replace(/\w/, (w) -> w.toUpperCase())}]"
isType = (ele, type) -> _isType(type)(ele)
isObject = _isType("object")
isString = _isType("string")
isArray = _isType("array")
isFunction = _isType("function")
isNumber = _isType("number")

parse = (str) -> if str? and isString(str) then JSON.parse(str) else []

stringify = (obj) -> if obj? and isArray(obj) then JSON.stringify(obj) else "[]"

criteriaCheck = (obj, criteria) ->
    for key, condition of criteria
        (if obj[key]? and obj[key] is condition then continue else return false) if isString(condition) or isNumber(condition)
        flag = true
        switch key
            when "$and" then return false for c in condition when not criteriaCheck(obj, c)
            when "$not" then return false if criteriaCheck(obj, condition)
            when "$nor" then return false for c in condition when criteriaCheck(obj, c)
            when "$or"
                f = false
                for c in condition when criteriaCheck(obj, c)
                    f = true
                    break
                return false if not f
            else flag = false
        continue if flag
        for c_key, c_value of condition
            switch c_key
                when "$gt" then return false if obj[key] <= c_value
                when "$gte" then return false if obj[key] < c_value
                when "$lt" then return false if obj[key] >= c_value
                when "$lte" then return false if obj[key] > c_value
                when "$ne" then return false if obj[key] is c_value
                when "$in" then return false if obj[key] not in c_value
                when "$nin" then return false if obj[key] in c_value
                when "$exist" then return false if c_value isnt obj[key]?
                when "$type" then return false if not isType(obj[key], c_value)
                else return false if not criteriaCheck(obj[key], JSON.parse("{\"#{c_key}\": #{JSON.stringify(c_value)}}"))
    return true
#Utils End

LocalDB = (dbName, engine = localStorage) ->
    @ls = engine
    @name = dbPrefix + dbName
    return

LocalDB.isSupport = -> if localStorage? then true else false

LocalDB.prototype.collections = -> (@ls.key(i) for i in [0...@ls.length] when @ls.key(i).indexOf("#{@name}_") is 0)

LocalDB.prototype.drop = (collectionName) ->
    collectionName = if collectionName? then "_#{collectionName}" else ""
    keys = (@ls.key(i) for i in [0...@ls.length] when @ls.key(i).indexOf(@name + collectionName) is 0)
    @ls.removeItem(j) for j in keys
    return true

LocalDB.prototype.collection = (collectionName) -> new Collection(collectionName, @)

Collection = (collectionName, db) ->
    @name = "#{db.name}_#{collectionName}"
    @ls = db.ls
    @deserialize()
    return

Collection.prototype.deserialize = -> @data = parse(@ls.getItem(@name))

Collection.prototype.serialize = -> @ls.setItem @name, stringify(@data)

Collection.prototype.drop = -> @ls.removeItem(@name)

Collection.prototype.insert = (rowData) ->
    @deserialize()
    @data.push rowData
    @serialize()

Collection.prototype.update = (action, options) ->
    criteria = if options.criteria? then options.criteria else {}
    @deserialize()
    for d in @data when criteriaCheck(d, criteria)
        actions = action.$set
        for key, value of actions
            d[key] = value
    @serialize()

Collection.prototype.remove = (options = {}) ->
    criteria = if options.criteria? then options.criteria else {}
    @data = (d for d in @data when not criteriaCheck(d, criteria))
    @serialize()

Collection.prototype.find = (options = {}) ->
    criteria = if options.criteria? then options.criteria else {}
    projection = if options.projection? then options.projection else {}
    limit = if options.limit? then options.limit else -1
    @deserialize()
    result = []
    for d in @data when criteriaCheck(d, criteria)
        break if limit is 0
        limit = limit - 1
        result.push d
    return result if JSON.stringify(projection) is "{}"
    pResult = []
    for d in result
        p = {}
        for key, value of projection
            p[key] = d[key] if value is 1
        pResult.push p
    return pResult

Collection.prototype.findOne = (options = {}) ->
    options.limit = 1
    @find(options)

module.exports = LocalDB
