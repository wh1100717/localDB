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

logicCheck = (data, key, condition) ->
    for k, v of condition
        if k is "$not"
            return if Criteria.check(data, (new -> @[key] = v)) then false else true
    switch key
        when "$and" then return false for c in condition when not Criteria.check(data, c)
        when "$nor" then return false for c in condition when Criteria.check(data, c)
        # when "$not" then return false if Criteria.check((new -> @[field] = data), (new -> @[field] = condition))
        when "$or" then return false if not (-> return true for c in condition when Criteria.check(data, c))()
        else return undefined
    return true

arrayCheck = (obj, arrayKey, arrayCondition) ->
    switch arrayKey
        when "$all"
            return false if not Utils.isArray(obj)
            return false for c in arrayCondition when not (-> return true for d in obj when if Utils.isArray(c) then arrayCheck(d, arrayKey, c) else d is c)()
        when "$elemMatch"
            return false if not Utils.isArray(obj)
            return false if not (-> return true for d in obj when Criteria.check(d, arrayCondition))()
        when "$size"
            return false if not Utils.isArray(obj)
            return false if obj.length isnt arrayCondition
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
            when "$in"
                flag = true
                for c_v in c_value
                    if Utils.isRegex(c_v) and c_v.test(obj[key])
                        flag = false
                        break
                    else if obj[key] is c_v
                        flag = false
                        break
                return false if flag
            when "$nin" then return false if obj[key] in c_value
            when "$exists" then return false if c_value isnt obj[key]?
            when "$type" then return false if not Utils.isType(obj[key], c_value)
            when "$mod" then return false if obj[key] % c_value[0] isnt c_value[1]
            when "$regex" then return false if not (new RegExp(c_value)).test(obj[key])
            else return false if not Criteria.check(obj[key], JSON.parse("{\"#{c_key}\": #{JSON.stringify(c_value)}}"))
    return true

Criteria = {}

Criteria.check = (data, criteria) ->
    for key, condition of criteria
        ### Number Check
         *  criteria: {a: 1}
         *  data: [{a: 1, b: 2, c: 3}] or [{a:[1,2,3]}]
        ###
        (if numberCheck(data[key], condition) then continue else return false) if Utils.isNumber(condition) and key isnt "$size"
        ### String Check
         *  criteria: {a: "abc"}
         *  data: [{a: "abc", b: 2, c: 3}] or [{a: ["abc","bcd","edf"], b: 2, c: 3}]
        ###
        (if stringCheck(data[key], condition) then continue else return false) if Utils.isString(condition)
        ### Regex Check
         *  criteria: {a: /abc+/}
         *  data: [{a: "abcabc"}] or [{a: ["abcabc", "aaa", "bbb"]}]
        ###
        (if regexCheck(data[key], condition) then continue else return false) if Utils.isRegex(condition)
        ### Logic Check
         *  $and criteria: {$and: [{a: 1}, {b: 2}]}
         *  data: [{a:1, b:2, c:3}]
         *  $or criteria: {$or: [{a: 1}, {b: 2}]}
         *  data: [{a:1, b:3, c:4}] or [{a:2, b:2, c:3}]
         *  $nor criteria: {$nor: [{a: 1}, {b: 2}]}
         *  data: [{a:2, b:3, c:4}]
         *  TODO $not criteria: {a: {$not: {$gt: 10}}} //a is field
         *  data: [{a:5, b:3, c:4}] 
         *  TO DISCUSS : Should we add feature to support {$not: {a: 10}} kind of criteria?
        ###
        logicCheckResult = logicCheck(data, key, condition)
        (if logicCheckResult then continue else return false) if logicCheckResult?
        ### Array Check
         *  $all criteria: {a: [1,2,3]}
         *  data: [{a: [1,2,3,4,5], b: 1}] or [{a: [[1,2,3],[1,2,4]]}]
        ###
        arrayCheckResult = arrayCheck(data, key, condition)
        (if arrayCheckResult then continue else return false) if arrayCheckResult?
        # Other Check (Comparison | Element | Evaluation)
        if cmpCheck(data, key, condition) then continue else return false
    return true

module.exports = Criteria
