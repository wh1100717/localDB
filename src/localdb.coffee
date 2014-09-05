'use strict'

Utils = require('./lib/utils')
Collection = require('./lib/collection')

dbPrefix = "ldb_"

LocalDB = (dbName, engine = localStorage) -> @ls = engine; @name = dbPrefix + dbName;@

LocalDB.isSupport = -> if localStorage? then true else false

LocalDB.prototype.collections = -> (@ls.key(i) for i in [0...@ls.length] when @ls.key(i).indexOf("#{@name}_") is 0)

LocalDB.prototype.collection = (collectionName) -> new Collection(collectionName, @)

LocalDB.prototype.drop = (collectionName) ->
    collectionName = if collectionName? then "_#{collectionName}" else ""
    keys = (@ls.key(i) for i in [0...@ls.length] when @ls.key(i).indexOf(@name + collectionName) is 0)
    @ls.removeItem(j) for j in keys
    return true

module.exports = LocalDB