'use strict'

Criteria = require('./criteria')
Utils = require('./utils')

generate = (data, action, value, criteria) ->
    switch action
        when "$inc"
            for k, v of value
                for d in data when Criteria.check(d, criteria) and Utils.isNumber(d[k])
                    d[k] = d[k] + v
        when "$set"
            for k, v of value
                for d in data when Criteria.check(d, criteria) and d[k]?
                    d[k] = v
        when "$mul"
            for k,v of value
                for d in data when Criteria.check(d, criteria) and Utils.isNumber(d[k])
                    d[k] = d[k] * v
        when "$rename"
            for k,v of value
                for d in data when Criteria.check(d, criteria) and d[k]?
                    d[v] = d[k]
                    delete d[k]
        when "$unset"
            for k of value
                for d in data when Criteria.check(d, criteria) and d[k]?
                    delete d[k]
        when "$min"
            for k, v of value
                for d in data when Criteria.check(d, criteria) and Utils.isNumber(d[k])
                    d[k] = Math.min(d[k], v)
        when "$max"
            for k, v of value
                for d in data when Criteria.check(d, criteria) and Utils.isNumber(d[k])
                    d[k] = Math.max(d[k], v)
        else
            for d in data when Criteria.check(d, criteria) and d[action]?
                d[action] = value
    return data

Update = (data, actions, criteria) ->
    for action, value of actions
        data = generate(data, action, value, criteria)
    return data


module.exports = Update
