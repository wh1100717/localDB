'use strict'

Where = require('./where')
Utils = require('./utils')

Remove = (data, options) ->
    where = options.where or {}
    multi = options.multi or false
    result = []
    flag = false
    for d in data
        if flag
            result.push d
            continue
        if Where(d, where)
            flag = true if multi
            continue
        result.push d
    return result

module.exports = Remove