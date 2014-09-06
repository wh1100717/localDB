// Generated by CoffeeScript 1.7.1
'use strict';
var Criteria, Utils, arrayCheck, cmpCheck, logicCheck, numberCheck, regexCheck, stringCheck,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Utils = require('./utils');

numberCheck = function(obj, numberConditon) {
  if (Utils.isNumber(obj) && obj === numberConditon) {
    return true;
  }
  if (Utils.isArray(obj) && (__indexOf.call(obj, numberConditon) >= 0)) {
    return true;
  }
  return false;
};

stringCheck = function(obj, stringCondition) {
  if (Utils.isString(obj) && obj === stringCondition) {
    return true;
  }
  if (Utils.isArray(obj) && (__indexOf.call(obj, stringCondition) >= 0)) {
    return true;
  }
  return false;
};

regexCheck = function(obj, regexCondition) {
  var o, _i, _len;
  if (Utils.isString(obj) && regexCondition.test(obj)) {
    return true;
  }
  if (Utils.isArray(obj)) {
    for (_i = 0, _len = obj.length; _i < _len; _i++) {
      o = obj[_i];
      if (regexCondition.test(o)) {
        return true;
      }
    }
  }
  return false;
};

logicCheck = function(obj, logicKey, logicCondition) {
  var c, _i, _j, _len, _len1;
  switch (logicKey) {
    case "$and":
      for (_i = 0, _len = logicCondition.length; _i < _len; _i++) {
        c = logicCondition[_i];
        if (!Criteria.check(obj, c)) {
          return false;
        }
      }
      break;
    case "$nor":
      for (_j = 0, _len1 = logicCondition.length; _j < _len1; _j++) {
        c = logicCondition[_j];
        if (Criteria.check(obj, c)) {
          return false;
        }
      }
      break;
    case "$not":
      if (Criteria.check(obj, logicCondition)) {
        return false;
      }
      break;
    case "$or":
      if (!(function() {
        var _k, _len2;
        for (_k = 0, _len2 = logicCondition.length; _k < _len2; _k++) {
          c = logicCondition[_k];
          if (Criteria.check(obj, c)) {
            return true;
          }
        }
      })()) {
        return false;
      }
      break;
    default:
      return void 0;
  }
  return true;
};

arrayCheck = function(obj, arrayKey, arrayCondition) {
  var c, _i, _len;
  switch (arrayKey) {
    case "$all":
      if (!Utils.isArray(obj)) {
        return false;
      }
      for (_i = 0, _len = arrayCondition.length; _i < _len; _i++) {
        c = arrayCondition[_i];
        if (!(function() {
          var d, _j, _len1;
          for (_j = 0, _len1 = obj.length; _j < _len1; _j++) {
            d = obj[_j];
            if (Utils.isArray(c) ? arrayCheck(d, arrayKey, c) : d === c) {
              return true;
            }
          }
        })()) {
          return false;
        }
      }
      break;
    default:
      return void 0;
  }
  return true;
};

cmpCheck = function(obj, key, cmpCondition) {
  var c_key, c_value, _ref, _ref1;
  for (c_key in cmpCondition) {
    c_value = cmpCondition[c_key];
    switch (c_key) {
      case "$gt":
        if (obj[key] <= c_value) {
          return false;
        }
        break;
      case "$gte":
        if (obj[key] < c_value) {
          return false;
        }
        break;
      case "$lt":
        if (obj[key] >= c_value) {
          return false;
        }
        break;
      case "$lte":
        if (obj[key] > c_value) {
          return false;
        }
        break;
      case "$ne":
        if (obj[key] === c_value) {
          return false;
        }
        break;
      case "$in":
        if (_ref = obj[key], __indexOf.call(c_value, _ref) < 0) {
          return false;
        }
        break;
      case "$nin":
        if (_ref1 = obj[key], __indexOf.call(c_value, _ref1) >= 0) {
          return false;
        }
        break;
      case "$exist":
        if (c_value !== (obj[key] != null)) {
          return false;
        }
        break;
      case "$type":
        if (!Utils.isType(obj[key], c_value)) {
          return false;
        }
        break;
      case "$mod":
        if (obj[key] % c_value[0] !== c_value[1]) {
          return false;
        }
        break;
      case "$regex":
        if (!(new RegExp(c_value)).test(obj[key])) {
          return false;
        }
        break;
      default:
        if (!Criteria.check(obj[key], JSON.parse("{\"" + c_key + "\": " + (JSON.stringify(c_value)) + "}"))) {
          return false;
        }
    }
  }
  return true;
};

Criteria = {};

Criteria.check = function(obj, criteria) {
  var arrayCheckResult, condition, key, logicCheckResult;
  for (key in criteria) {
    condition = criteria[key];
    if (Utils.isNumber(condition)) {
      if (numberCheck(obj[key], condition)) {
        continue;
      } else {
        return false;
      }
    }
    if (Utils.isString(condition)) {
      if (stringCheck(obj[key], condition)) {
        continue;
      } else {
        return false;
      }
    }
    if (Utils.isRegex(condition)) {
      if (regexCheck(obj[key], condition)) {
        continue;
      } else {
        return false;
      }
    }
    logicCheckResult = logicCheck(obj, key, condition);
    if (logicCheckResult != null) {
      if (logicCheckResult) {
        continue;
      } else {
        return false;
      }
    }
    arrayCheckResult = arrayCheck(obj, key, condition);
    if (arrayCheckResult != null) {
      if (arrayCheckResult) {
        continue;
      } else {
        return false;
      }
    }
    if (cmpCheck(obj, key, condition)) {
      continue;
    } else {
      return false;
    }
  }
  return true;
};

module.exports = Criteria;
