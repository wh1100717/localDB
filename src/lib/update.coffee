'use strict'

Where = require('./where')
Utils = require('./utils')

reservedKeys = [
    '$inc', '$set', '$mul', '$rename', '$unset', '$min'
]

isKeyReserved = (key) -> key in reservedKeys

generate = (data, action, value, where, multi, upsert) ->
    return data if not isKeyReserved(action)
    for k, v of value
        for d in data when Where(d, where)
            flag = false
            while k.indexOf(".") > 0
                firstKey = k.split(".")[0]
                d = d[firstKey]
                if not d? and not upsert
                    flag = true
                    break
                d = d or {} if upsert
                k = k.substr(k.indexOf(".") + 1)
            continue if flag
            switch action
                when "$inc" then d[k] += v
                when "$set" then d[k] = v
                when "$mul" then d[k] *= v
                when "$rename"
                    d[v] = d[k]
                    delete d[k]
                when "$unset"
                    delete d[k]
                when "$min" then d[k] = Math.min(d[k], v)
                when "$max" then d[k] = Math.max(d[k], v)
            break if not multi
    return data

Update = (data, actions, options) ->
    where = options.where or {}
    multi = options.multi or false
    upsert = options.upsert or false
    for action, value of actions
        data = generate data, action, value, where, multi, upsert
    return data

module.exports = Update
