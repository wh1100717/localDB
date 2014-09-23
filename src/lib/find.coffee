'use strict'

Where = require('./where')
Utils = require('./utils')
Projection = require('./projection')

Find = (data, options) ->
    where = options.where or {}
    projection = options.projection or {}
    limit = options.limit or -1
    result = []
    for d in data when Where(d, where)
        break if limit is 0
        limit -= 1
        result.push d
    return Projection.generate(result, projection)

module.exports = Find
