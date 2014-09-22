'use strict'

Utils = require('./utils')

Projection = {}

Projection.generate = (data, projection) ->
    return data if JSON.stringify(projection) is "{}"
    return (generateItem(d, projection) for d in data)

generateItem = (item, projection) ->
    result = {}
    for key, value of projection
        if key.indexOf(".$") isnt -1
            key = key.split(".")[0]
            continue if not Utils.isArray(item[key]) or item[key].length is 0
            result[key] = [item[key][0]]
        else if key.indexOf("$elemMatch") is 0
            continue if not Utils.isArray(item) or item.length is 0
            r = []
            for i in item
                flag = true
                for v_key, v_value of value
                    if Utils.isObject(v_value)
                        console.log "TODO"
                    else
                        flag = false if i[v_key] isnt v_value
                r.push i if flag
            return r
        else if Utils.isObject(value)
            result[key] = generateItem(item[key], value)
        else
            result[key] = item[key] if value is 1
    return result

module.exports = Projection