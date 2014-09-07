'use strict'

Projection = {}

Projection.generate = (data, projection) ->
    return data if JSON.stringify(projection) is "{}"
    result = []
    for d in result
        p = {}
        for key, value of projection
            #这里不使用deepcopy是否会造成问题？
            p[key] = d[key] if value is 1
        result.push r
    return result

module.exports = Projection