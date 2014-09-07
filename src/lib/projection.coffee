'use strict'

Utils = require('./utils')
Criteria = require('./criteria')


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

        # for key, value of projection
        #     if key.indexOf(".$") isnt -1
        #         key = key.split(".")[0]
        #         console.log key
        #         continue if not Utils.isArray(d[key]) or d[key].length is 0
        #         p[key] = [d[key][0]]
        #     else if key.indexOf("$elemMatch") is 0
        #         continue if not Utils.isArray()
        #     else
        #         #这里不使用deepcopy是否会造成问题？
        #         p[key] = d[key] if value is 1


module.exports = Projection