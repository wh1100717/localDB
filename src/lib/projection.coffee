'use strict'

Utils = require('./utils')

Projection = {}

Projection.generate = (data, projection) ->
    return data if JSON.stringify(projection) is "{}"
    result = []
    for d in data
        p = {}
        for key, value of projection
            if key.indexOf(".$") isnt -1
                key = key.split(".")[0]
                console.log key
                continue if not Utils.isArray(d[key]) or d[key].length is 0
                p[key] = [d[key][0]]
            else
                #这里不使用deepcopy是否会造成问题？
                p[key] = d[key] if value is 1
        result.push p
    return result

module.exports = Projection