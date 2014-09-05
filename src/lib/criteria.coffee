Utils = require('./utils')

Criteria = {}

Criteria.check = (obj, criteria) ->
    for key, condition of criteria
        (if obj[key]? and obj[key] is condition then continue else return false) if Utils.isString(condition) or Utils.isNumber(condition)
        (if condition.test(obj[key]) then continue else return false) if Utils.isRegex(condition)
        flag = true
        switch key
            when "$and" then return false for c in condition when not Criteria.check(obj, c)
            when "$not" then return false if Criteria.check(obj, condition)
            when "$nor" then return false for c in condition when Criteria.check(obj, c)
            when "$or"
                f = false
                for c in condition when Criteria.check(obj, c)
                    f = true
                    break
                return false if not f
            else flag = false

        continue if flag
        for c_key, c_value of condition
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

module.exports = Criteria