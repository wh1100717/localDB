'use strict'

Where = require('./where')
Utils = require('./utils')

generate = (data, action, value, where) ->
    switch action
        when "$inc"
            for k, v of value
                for d in data when Where(d, where) and Utils.isNumber(d[k])
                    d[k] = d[k] + v
        when "$set"
            for k, v of value
                for d in data when Where(d, where) and d[k]?
                    d[k] = v
        when "$mul"
            for k,v of value
                for d in data when Where(d, where) and Utils.isNumber(d[k])
                    d[k] = d[k] * v
        when "$rename"
            for k,v of value
                for d in data when Where(d, where) and d[k]?
                    d[v] = d[k]
                    delete d[k]
        when "$unset"
            for k of value
                for d in data when Where(d, where) and d[k]?
                    delete d[k]
        when "$min"
            for k, v of value
                for d in data when Where(d, where) and Utils.isNumber(d[k])
                    d[k] = Math.min(d[k], v)
        when "$max"
            for k, v of value
                for d in data when Where(d, where) and Utils.isNumber(d[k])
                    d[k] = Math.max(d[k], v)
        else
            for d in data when Where(d, where) and d[action]?
                d[action] = value
    return data

Update = (data, actions, where) ->
    for action, value of actions
        data = generate(data, action, value, where)
    return data


module.exports = Update
