'use strict'

Utils = require('./utils')

numberCheck = (obj, numberConditon) ->
    return true if Utils.isNumber(obj) and obj is numberConditon
    return true if Utils.isArray(obj) and (numberConditon in obj)
    return false

stringCheck = (obj, stringCondition) ->
    return true if Utils.isString(obj) and obj is stringCondition
    return true if Utils.isArray(obj) and (stringCondition in obj)
    return false

regexCheck = (obj, regexCondition) ->
    return true if Utils.isString(obj) and regexCondition.test(obj)
    (return true for o in obj when regexCondition.test(o)) if Utils.isArray(obj)
    return false

logicCheck = (obj, logicKey, logicCondition) ->
    switch logicKey
        when "$and" then return false for c in logicCondition when not Criteria.check(obj, c)
        when "$nor" then return false for c in logicCondition when Criteria.check(obj, c)
        when "$not" then return false if Criteria.check(obj, logicCondition)
        when "$or" then return false if not (-> return true for c in logicCondition when Criteria.check(obj, c))()
        else return undefined
    return true

arrayCheck = (obj, arrayKey, arrayCondition) ->
    switch arrayKey
        when "$all"
            return false if not Utils.isArray(obj)
            return false for c in arrayCondition when not (-> return true for d in obj when if Utils.isArray(c) then arrayCheck(d, arrayKey, c) else d is c)()
        else return undefined
    return true


cmpCheck = (obj, key, cmpCondition) ->
    for c_key, c_value of cmpCondition
        switch c_key
            when "$gt" then return false if obj[key] <= c_value
            when "$gte" then return false if obj[key] < c_value
            when "$lt" then return false if obj[key] >= c_value
            when "$lte" then return false if obj[key] > c_value
            when "$ne" then return false if obj[key] is c_value
            when "$in" then return false if obj[key] not in c_value
            when "$nin" then return false if obj[key] in c_value
            when "$exist" then return false if c_value isnt obj[key]?
            when "$type" then return false if not Utils.isType(obj[key], c_value)
            when "$mod" then return false if obj[key] % c_value[0] isnt c_value[1]
            when "$regex" then return false if not (new RegExp(c_value)).test(obj[key])
            else return false if not Criteria.check(obj[key], JSON.parse("{\"#{c_key}\": #{JSON.stringify(c_value)}}"))
    return true

Criteria = {}

Criteria.check = (obj, criteria) ->
    for key, condition of criteria
        # Number Check
        (if numberCheck(obj[key], condition) then continue else return false) if Utils.isNumber(condition)
        # String Check
        (if stringCheck(obj[key], condition) then continue else return false) if Utils.isString(condition)
        # Regex Check
        (if regexCheck(obj[key], condition) then continue else return false) if Utils.isRegex(condition)
        # Logic Check
        logicCheckResult = logicCheck(obj, key, condition)
        (if logicCheckResult then continue else return false) if logicCheckResult?
        # Array Check
        arrayCheckResult = arrayCheck(obj, key, condition)
        (if arrayCheckResult then continue else return false) if arrayCheckResult?
        # Other Check (Comparison | Element | Evaluation)
        if cmpCheck(obj, key, condition) then continue else return false
    return true

module.exports = Criteria