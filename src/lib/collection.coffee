'use strict'

Utils = require('./utils')
Criteria = require('./criteria')

Collection = (collectionName, db) ->
    @name = "#{db.name}_#{collectionName}"
    @ls = db.ls
    @deserialize()
    return

Collection.prototype.deserialize = -> @data = Utils.parse @ls.getItem(@name)

Collection.prototype.serialize = -> @ls.setItem @name, Utils.stringify(@data)

Collection.prototype.drop = -> @ls.removeItem @name

Collection.prototype.insert = (rowData) ->
    @deserialize()
    @data.push rowData
    @serialize()

Collection.prototype.update = (action, options) ->
    criteria = if options.criteria? then options.criteria else {}
    @deserialize()
    for d in @data when Criteria.check(d, criteria)
        actions = action.$set
        for key, value of actions
            d[key] = value
    @serialize()

Collection.prototype.remove = (options = {}) ->
    criteria = if options.criteria? then options.criteria else {}
    @deserialize()
    @data = (d for d in @data when not Criteria.check(d, criteria))
    @serialize()

Collection.prototype.find = (options = {}) ->
    criteria = if options.criteria? then options.criteria else {}
    projection = if options.projection? then options.projection else {}
    limit = if options.limit? then options.limit else -1
    @deserialize()
    result = []
    for d in @data when Criteria.check(d, criteria)
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

module.exports = Collection