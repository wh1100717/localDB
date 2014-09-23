'use strict'

Where = require('./where')
Utils = require('./utils')

Insert = (data, rowData, options) ->
    if Utils.isArray(rowData)
        for d in rowData when Utils.isObject(d)
            d._id = Utils.createObjectId() if not d._id?
            data.push d
    else if Utils.isObject(rowData)
        rowData._id = Utils.createObjectId() if not rowData._id?
        data.push rowData
    return data

module.exports = Insert