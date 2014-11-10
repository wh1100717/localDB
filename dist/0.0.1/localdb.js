(function( global, factory ) {

    if ( typeof module === "object" && typeof module.exports === "object" ) {
        module.exports = global.document ?
            factory( global, true ) :
            function( w ) {
                if ( !w.document ) {
                    throw new Error( "localdb requires a window with a document" );
                }
                return factory( w );
            };
    } else {
        factory( global );
    }

// Pass this if window is not defined yet
}(typeof window !== "undefined" ? window : this, function( window, noGlobal ) {

  // Support: Firefox 18+
  // Can't be in strict mode, several libs including ASP.NET trace
  // the stack via arguments.caller.callee and Firefox dies if
  // you try to trace through "use strict" call chains. (#13335)
  //

  /**
   * Binary Parser.
   * Jonas Raoni Soares Silva
   * http://jsfromhell.com/classes/binary-parser [v1.0]
   */
  'use strict'

  var maxBits = [];
  for (var i = 0; i < 64; i++) {
    maxBits[i] = Math.pow(2, i);
  }

  function BinaryParser(bigEndian, allowExceptions) {
    if (!(this instanceof BinaryParser)) return new BinaryParser(bigEndian, allowExceptions);

    this.bigEndian = bigEndian;
    this.allowExceptions = allowExceptions;
  };

  BinaryParser.warn = function warn(msg) {
    if (this.allowExceptions) {
      throw new Error(msg);
    }

    return 1;
  };

  BinaryParser.decodeInt = function decodeInt(data, bits, signed, forceBigEndian) {
    var b = new this.Buffer(this.bigEndian || forceBigEndian, data),
      x = b.readBits(0, bits),
      max = maxBits[bits]; //max = Math.pow( 2, bits );

    return signed && x >= max / 2 ? x - max : x;
  };

  BinaryParser.encodeInt = function encodeInt(data, bits, signed, forceBigEndian) {
    var max = maxBits[bits];

    if (data >= max || data < -(max / 2)) {
      this.warn("encodeInt::overflow");
      data = 0;
    }

    if (data < 0) {
      data += max;
    }

    for (var r = []; data; r[r.length] = String.fromCharCode(data % 256), data = Math.floor(data / 256));

    for (bits = -(-bits >> 3) - r.length; bits--; r[r.length] = "\0");

    return ((this.bigEndian || forceBigEndian) ? r.reverse() : r).join("");
  };

  BinaryParser.fromByte = function(data) {
    return this.encodeInt(data, 8, false);
  };
  BinaryParser.fromShort = function(data) {
    return this.encodeInt(data, 16, true);
  };

  /**
   * BinaryParser buffer constructor.
   */
  function BinaryParserBuffer(bigEndian, buffer) {
    this.bigEndian = bigEndian || 0;
    this.buffer = [];
    this.setBuffer(buffer);
  };

  BinaryParserBuffer.prototype.setBuffer = function setBuffer(data) {
    var l, i, b;

    if (data) {
      i = l = data.length;
      b = this.buffer = new Array(l);
      for (; i; b[l - i] = data.charCodeAt(--i));
      this.bigEndian && b.reverse();
    }
  };

  BinaryParserBuffer.prototype.hasNeededBits = function hasNeededBits(neededBits) {
    return this.buffer.length >= -(-neededBits >> 3);
  };

  BinaryParserBuffer.prototype.checkBuffer = function checkBuffer(neededBits) {
    if (!this.hasNeededBits(neededBits)) {
      throw new Error("checkBuffer::missing bytes");
    }
  };

  BinaryParserBuffer.prototype.readBits = function readBits(start, length) {
    //shl fix: Henri Torgemane ~1996 (compressed by Jonas Raoni)

    function shl(a, b) {
      for (; b--; a = ((a %= 0x7fffffff + 1) & 0x40000000) == 0x40000000 ? a * 2 : (a - 0x40000000) * 2 + 0x7fffffff + 1);
      return a;
    }

    if (start < 0 || length <= 0) {
      return 0;
    }

    this.checkBuffer(start + length);

    var offsetLeft, offsetRight = start % 8,
      curByte = this.buffer.length - (start >> 3) - 1,
      lastByte = this.buffer.length + (-(start + length) >> 3),
      diff = curByte - lastByte,
      sum = ((this.buffer[curByte] >> offsetRight) & ((1 << (diff ? 8 - offsetRight : length)) - 1)) + (diff && (offsetLeft = (start + length) % 8) ? (this.buffer[lastByte++] & ((1 << offsetLeft) - 1)) << (diff-- << 3) - offsetRight : 0);

    for (; diff; sum += shl(this.buffer[lastByte++], (diff-- << 3) - offsetRight));

    return sum;
  };

  BinaryParser.Buffer = BinaryParserBuffer;

  self.BinaryParser = BinaryParser;

  
  var ObjectID, hexTable, i;
  hexTable = (function() {
    var _i, _results;
    _results = [];
    for (i = _i = 0; _i < 256; i = ++_i) {
      _results.push((i <= 15 ? '0' : '') + i.toString(16));
    }
    return _results;
  })();
  ObjectID = (function() {
    function ObjectID(id, _hex) {
      this._bsontype = 'ObjectID';
      this.MACHINE_ID = parseInt(Math.random() * 0xFFFFFF, 10);
      if ((id != null) && id.length !== 12 && id.length !== 24) {
        throw new Error("Argument passed in must be a single String of 12 bytes or a string of 24 hex characters");
      }
      if (id == null) {
        this.id = this.generate();
      } else if ((id != null) && id.length === 12) {
        this.id = id;
      } else if (/^[0-9a-fA-F]{24}$/.test(id)) {
        return this.createFromHexString(id);
      } else {
        throw new Error("Value passed in is not a valid 24 character hex string");
      }
    }

    ObjectID.prototype.generate = function() {
      var index3Bytes, machine3Bytes, pid2Bytes, time4Bytes, unixTime;
      unixTime = parseInt(Date.now() / 1000, 10);
      time4Bytes = BinaryParser.encodeInt(unixTime, 32, true, true);
      machine3Bytes = BinaryParser.encodeInt(this.MACHINE_ID, 24, false);
      pid2Bytes = BinaryParser.fromShort(typeof process === 'undefined' ? Math.floor(Math.random() * 100000) : process.pid);
      index3Bytes = BinaryParser.encodeInt(this.get_inc(), 24, false, true);
      return time4Bytes + machine3Bytes + pid2Bytes + index3Bytes;
    };

    ObjectID.prototype.toHexString = function() {
      var hexString, _i, _ref;
      hexString = '';
      for (i = _i = 0, _ref = this.id.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        hexString += hexTable[this.id.charCodeAt(i)];
      }
      return hexString;
    };

    ObjectID.prototype.toString = function() {
      return this.toHexString();
    };

    ObjectID.prototype.inspect = function() {
      return this.toHexString();
    };

    ObjectID.prototype.getTime = function() {
      return Math.floor(BinaryParser.decodeInt(this.id.substring(0, 4), 32, true, true)) * 1000;
    };

    ObjectID.prototype.getTimestamp = function() {
      var timestamp;
      timestamp = new Date();
      timestamp.setTime(this.getTime());
      return timestamp;
    };

    ObjectID.prototype.get_inc = function() {
      return ObjectID.index = (ObjectID.index + 1) % 0xFFFFFF;
    };

    ObjectID.prototype.createFromHexString = function(hexString) {
      var result, _i;
      result = '';
      for (i = _i = 0; _i < 24; i = ++_i) {
        if (i % 2 === 0) {
          result += BinaryParser.fromByte(parseInt(hexString.substr(i, 2), 16));
        }
      }
      return new ObjectID(result, hexString);
    };

    return ObjectID;

  })();
  ObjectID.index = parseInt(Math.random() * 0xFFFFFF, 10);
  self.ObjectID = ObjectID;

  
  var Utils, eq, toString, _isType;
  Utils = {};
  toString = Object.prototype.toString;

  /*
   *  isEqual function is implemented by underscore and I just rewrite in my project.
   *  https://github.com/jashkenas/underscore/blob/master/underscore.js
   */
  eq = function(a, b, aStack, bStack) {
    var aCtor, areArrays, bCtor, className, key, keys, length, result, size;
    if (a === b) {
      return a !== 0 || 1 / a === 1 / b;
    }
    if (a === null && b === void 0) {
      return false;
    }
    if (a === void 0 && b === null) {
      return false;
    }
    className = toString.call(a);
    if (className !== toString.call(b)) {
      return false;
    }
    switch (className) {
      case '[object RegExp]':
        return '' + a === '' + b;
      case '[object String]':
        return '' + a === '' + b;
      case '[object Number]':
        if (+a !== +a) {
          return +b !== +b;
        }
        if (+a === 0) {
          return 1 / +a === 1 / b;
        } else {
          return +a === +b;
        }
      case '[object Date]':
        return +a === +b;
      case '[object Boolean]':
        return +a === +b;
    }
    areArrays = className === '[object Array]';
    if (!areArrays) {
      if (typeof a !== 'object' || typeof b !== 'object') {
        return false;
      }
      aCtor = a.constructor;
      bCtor = b.constructor;
      if ((aCtor !== bCtor) && !(Utils.isFunction(aCtor) && aCtor instanceof aCtor && Utils.isFunction(bCtor) && bCtor instanceof bCtor) && ('constructor' in a && 'constructor' in b)) {
        return false;
      }
    }
    length = aStack.length;
    while (length--) {
      if (aStack[length] === a) {
        return bStack[length] === b;
      }
    }
    aStack.push(a);
    bStack.push(b);
    if (areArrays) {
      size = a.length;
      result = size === b.length;
      if (result) {
        while (size--) {
          if (!(result = eq(a[size], b[size], aStack, bStack))) {
            break;
          }
        }
      }
    } else {
      keys = Utils.keys(a);
      size = keys.length;
      result = Utils.keys(b).length === size;
      if (result) {
        while (size--) {
          key = keys[size];
          if (!(result = Utils.has(b, key) && eq(a[key], b[key], aStack, bStack))) {
            break;
          }
        }
      }
    }
    aStack.pop();
    bStack.pop();
    return result;
  };
  _isType = function(type) {
    return function(obj) {
      return toString.call(obj).toLowerCase() === ("[object " + type + "]").toLowerCase();
    };
  };
  Utils.isType = function(ele, type) {
    return _isType(type)(ele);
  };
  Utils.isObject = _isType("object");
  Utils.isString = _isType("string");
  Utils.isNumber = _isType("number");
  Utils.isArray = _isType("array");
  Utils.isFunction = _isType("function");
  Utils.isRegex = _isType("regexp");
  Utils.keys = function(obj) {
    if (!Utils.isObject(obj)) {
      return [];
    }
    if (Object.keys) {
      return Object.keys(obj);
    }
  };
  Utils.has = function(obj, key) {
    return obj !== null && obj !== void 0 && Object.prototype.hasOwnProperty.call(obj, key);
  };
  Utils.isEqual = function(a, b) {
    return eq(a, b, [], []);
  };
  Utils.createObjectId = function() {
    return (new ObjectID()).inspect();
  };
  Utils.stringify = function(arr) {
    if ((arr == null) || !Utils.isArray(arr)) {
      return "[]";
    }
    return JSON.stringify(arr, function(key, value) {
      if (Utils.isRegex(value) || Utils.isFunction(value)) {
        return value.toString();
      }
      return value;
    });
  };
  Utils.parse = function(str) {
    if ((str == null) || !Utils.isString(str)) {
      return [];
    }
    return JSON.parse(str, function(key, value) {
      var v;
      try {
        v = eval(value);
      } catch (_error) {}
      if ((v != null) && Utils.isRegex(v)) {
        return v;
      }
      try {
        v = eval("(" + value + ")");
      } catch (_error) {}
      if ((v != null) && Utils.isFunction(v)) {
        return v;
      }
      return value;
    });
  };
  Utils.parseParas = function(paras) {
    var callback, options;
    options = {};
    callback = null;
    if (paras.length === 1) {
      if (Utils.isObject(paras[0])) {
        options = paras[0];
      } else if (Utils.isFunction(paras[0])) {
        callback = paras[0];
      }
    } else if (paras.length === 2) {
      if (Utils.isObject(paras[0])) {
        options = paras[0];
      }
      if (Utils.isFunction(paras[1])) {
        callback = paras[1];
      }
    }
    return [options, callback];
  };
  Utils.getTimestamp = function(objectId) {
    return (new ObjectID(objectId)).getTimestamp();
  };
  Utils.getTime = function(objectId) {
    return (new ObjectID(objectId)).getTime();
  };
  Utils.toUnicode = function(string) {
    var char, index, len, result, uniChar;
    result = [''];
    index = 1;
    len = string.length;
    while (index <= len) {
      char = string.charCodeAt(index - 1);
      uniChar = "00" + char.toString(16);
      uniChar = uniChar.slice(-4);
      result.push(uniChar);
      index += 1;
    }
    return result.join('\\u');
  };
  Utils.fromUnicode = function(string) {
    var repStr;
    repStr = string.replace(/\\/g, "%");
    return unescape(repStr);
  };
  self.Utils = Utils;
var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };


  
  var Where, arrayCheck, dotCheck, isKeyReserved, keywordCheck, numberCheck, objectCheck, regexCheck, reservedKeys, stringCheck, valueCheck;
  reservedKeys = ['$gt', '$gte', '$lt', '$lte', '$ne', '$in', '$nin', '$and', '$nor', '$or', '$not', '$exists', '$type', '$mod', '$regex', '$all', '$elemMatch', '$size'];
  isKeyReserved = function(key) {
    return __indexOf.call(reservedKeys, key) >= 0;
  };
  Where = function(data, conditions) {

    /*
     *  如果key中包含dot的话，则执行dotCheck
     *  执行valueCheck
     *  如果返回值为true的话，执行keywordCheck
     */
    var condition, key;
    for (key in conditions) {
      condition = conditions[key];
      if (data == null) {
        if (key === "$exists" && condition === false) {
          continue;
        }
        return false;
      }
      if (key.indexOf(".") !== -1) {
        if (dotCheck(data, key, condition)) {
          continue;
        } else {
          return false;
        }
      }
      if (!valueCheck(data, key, condition)) {
        return false;
      }
      if (!keywordCheck(data, key, condition)) {
        return false;
      }
    }
    return true;
  };
  dotCheck = function(data, key, condition) {
    var firstKey;
    firstKey = key.split(".")[0];
    return Where(data[/\d/.test(firstKey) ? Number(firstKey) : firstKey], new function() {
      this[key.substr(key.indexOf('.') + 1)] = condition;
    });
  };
  valueCheck = function(data, key, condition) {

    /*
     *  如果key是关键字，则返回true
     *  如果condition是数字，则执行numberCheck
     *  如果condition是字符串，则执行stringCheck
     *  如果condition是正则表达式，则执行regexCheck
     *  如果condition是数组，则执行arrayCheck
     *  如果condition是对象，则执行objectCheck
     */
    var d;
    if (isKeyReserved(key)) {
      return true;
    }
    d = data[key];
    if (Utils.isNumber(condition) && !numberCheck(d, condition)) {
      return false;
    }
    if (Utils.isString(condition) && !stringCheck(d, condition)) {
      return false;
    }
    if (Utils.isRegex(condition) && !regexCheck(d, condition)) {
      return false;
    }
    if (Utils.isArray(condition) && !arrayCheck(d, condition)) {
      return false;
    }
    if (Utils.isObject(condition) && !objectCheck(d, condition)) {
      return false;
    }
    return true;
  };
  keywordCheck = function(data, key, condition) {
    var c, d, flag, _i, _j, _k, _l, _len, _len1, _len2, _len3;
    switch (key) {
      case "$gt":
        if (data <= condition) {
          return false;
        }
        break;
      case "$gte":
        if (data < condition) {
          return false;
        }
        break;
      case "$lt":
        if (data >= condition) {
          return false;
        }
        break;
      case "$lte":
        if (data > condition) {
          return false;
        }
        break;
      case "$ne":
        if (data === condition) {
          return false;
        }
        break;
      case "$in":
        if (Utils.isArray(data)) {
          flag = true;
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            d = data[_i];
            if (flag) {
              if ((function() {
                var c, _j, _len1;
                for (_j = 0, _len1 = condition.length; _j < _len1; _j++) {
                  c = condition[_j];
                  if (Utils.isRegex(c) && c.test(d) || (Utils.isEqual(c, d))) {
                    return true;
                  }
                }
                return false;
              })()) {
                flag = false;
              }
            }
          }
          if (flag) {
            return false;
          }
        } else {
          if (!(function() {
            var c, _j, _len1;
            for (_j = 0, _len1 = condition.length; _j < _len1; _j++) {
              c = condition[_j];
              if (Utils.isRegex(c) && c.test(data) || (Utils.isEqual(c, data))) {
                return true;
              }
            }
            return false;
          })()) {
            return false;
          }
        }
        break;
      case "$nin":
        if (__indexOf.call(condition, data) >= 0) {
          return false;
        }
        break;
      case "$exists":
        if (condition !== (data != null)) {
          return false;
        }
        break;
      case "$type":
        if (!Utils.isType(data, condition)) {
          return false;
        }
        break;
      case "$mod":
        if (data % condition[0] !== condition[1]) {
          return false;
        }
        break;
      case "$regex":
        if (!(new RegExp(condition)).test(data)) {
          return false;
        }
        break;
      case "$and":
        for (_j = 0, _len1 = condition.length; _j < _len1; _j++) {
          c = condition[_j];
          if (!Where(data, c)) {
            return false;
          }
        }
        break;
      case "$nor":
        for (_k = 0, _len2 = condition.length; _k < _len2; _k++) {
          c = condition[_k];
          if (Where(data, c)) {
            return false;
          }
        }
        break;
      case "$or":
        if (!(function() {
          var _l, _len3;
          for (_l = 0, _len3 = condition.length; _l < _len3; _l++) {
            c = condition[_l];
            if (Where(data, c)) {
              return true;
            }
          }
          return false;
        })()) {
          return false;
        }
        break;
      case "$not":
        if (Where(data, condition)) {
          return false;
        }
        break;
      case "$all":
        if (!Utils.isArray(data)) {
          return false;
        }
        for (_l = 0, _len3 = condition.length; _l < _len3; _l++) {
          c = condition[_l];
          if (!(function() {
            var _len4, _m;
            for (_m = 0, _len4 = data.length; _m < _len4; _m++) {
              d = data[_m];
              if (Utils.isArray(c) ? keywordCheck(d, key, c) : d === c) {
                return true;
              }
            }
          })()) {
            return false;
          }
        }
        break;
      case "$elemMatch":
        if (!Utils.isArray(data)) {
          return false;
        }
        if (!(function() {
          var _len4, _m;
          for (_m = 0, _len4 = data.length; _m < _len4; _m++) {
            d = data[_m];
            if (Where(d, condition)) {
              return true;
            }
          }
        })()) {
          return false;
        }
        break;
      case "$size":
        if (!Utils.isArray(data)) {
          return false;
        }
        if (data.length !== condition) {
          return false;
        }
    }
    return true;
  };
  numberCheck = function(data, cmpData) {

    /* Number Check
     *  cmpData: 1
     *  data: 1 or [1,2,3]
     */
    if (Utils.isNumber(data) && cmpData === data) {
      return true;
    }
    if (Utils.isArray(data) && (__indexOf.call(data, cmpData) >= 0)) {
      return true;
    }
    return false;
  };
  stringCheck = function(data, cmpData) {

    /* String Check
     *  cmpData: "abc"
     *  data: "abc" or ["abc","aaa","bbbb"]
     */
    if (Utils.isString(data) && cmpData === data) {
      return true;
    }
    if (Utils.isArray(data) && (__indexOf.call(data, cmpData) >= 0)) {
      return true;
    }
    return false;
  };
  regexCheck = function(data, cmpData) {

    /* Regex Check
     *  cmpData: /abc/
     *  data: "abcd" or ["abcdf","aaaa","basc","abce"] or /abc/ or [/abc/,/bce/,/hello.*ld/]
     */
    var d, _i, _len;
    if (Utils.isArray(data)) {
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        d = data[_i];
        if (Utils.isRegex(d)) {
          if (Utils.isEqual(d, cmpData)) {
            return true;
          }
        } else {
          if (cmpData.test(d)) {
            return true;
          }
        }
      }
    } else {
      if (Utils.isRegex(data)) {
        if (Utils.isEqual(data, cmpData)) {
          return true;
        }
      } else {
        if (cmpData.test(data)) {
          return true;
        }
      }
    }
    return false;
  };
  arrayCheck = function(data, cmpData) {
    return Utils.isEqual(data, cmpData);
  };
  objectCheck = function(data, conditions) {
    var c, flag, key;
    flag = true;
    for (key in conditions) {
      c = conditions[key];
      if (!(isKeyReserved(key))) {
        continue;
      }
      flag = false;
      if (!Where(data, new function() {
        this[key] = c;
      })) {
        return false;
      }
    }
    if (flag) {
      return Utils.isEqual(data, conditions);
    } else {
      return true;
    }
  };
  self.Where = Where;

  
  var Projection, generateItem;
  Projection = {};
  Projection.generate = function(data, projection) {
    var d, item, result, _i, _len;
    if (JSON.stringify(projection) === "{}") {
      return data;
    }
    result = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      d = data[_i];
      item = generateItem(d, projection);
      if (!Utils.isEqual(item, {})) {
        result.push(item);
      }
    }
    return result;
  };
  generateItem = function(item, projection) {
    var flag, gItem, i, idFlag, key, r, result, v_key, v_value, value, _i, _len;
    result = {};
    idFlag = true;
    for (key in projection) {
      value = projection[key];
      if (key === "_id" && value === -1) {
        idFlag = false;
        continue;
      }
      if (key.indexOf(".$") !== -1) {
        key = key.split(".")[0];
        if (!Utils.isArray(item[key]) || item[key].length === 0) {
          continue;
        }
        result[key] = [item[key][0]];
      } else if (key.indexOf("$elemMatch") === 0) {
        if (!Utils.isArray(item) || item.length === 0) {
          return [];
        }
        r = [];
        for (_i = 0, _len = item.length; _i < _len; _i++) {
          i = item[_i];
          flag = true;
          for (v_key in value) {
            v_value = value[v_key];
            if (Utils.isObject(v_value)) {

            } else {
              if (i[v_key] !== v_value) {
                flag = false;
              }
            }
          }
          if (flag) {
            r.push(i);
            break;
          }
        }
        if (Utils.isEqual(r, [])) {
          return [];
        }
        return r;
      } else if (Utils.isObject(value)) {
        gItem = generateItem(item[key], value);
        if (!Utils.isEqual(gItem, [])) {
          result[key] = gItem;
        }
      } else {
        if (value === 1) {
          result[key] = item[key];
        }
      }
    }
    if (idFlag && !Utils.isEqual(result, {})) {
      result._id = item._id;
    }
    return result;
  };
  self.Projection = Projection;

  
  var Operation, Update;
  Operation = {};
  Operation.insert = function(data, rowData, options) {
    var d, _i, _len;
    if (Utils.isArray(rowData)) {
      for (_i = 0, _len = rowData.length; _i < _len; _i++) {
        d = rowData[_i];
        if (!(Utils.isObject(d))) {
          continue;
        }
        if (d._id == null) {
          d._id = Utils.createObjectId();
        }
        data.push(d);
      }
    } else if (Utils.isObject(rowData)) {
      if (rowData._id == null) {
        rowData._id = Utils.createObjectId();
      }
      data.push(rowData);
    }
    return data;
  };
  Operation.update = function(data, actions, options) {
    var action, multi, upsert, value, where;
    where = options.where || {};
    multi = options.multi != null ? options.multi : true;
    upsert = options.upsert != null ? options.upsert : false;
    for (action in actions) {
      value = actions[action];
      data = Update.generate(data, action, value, where, multi, upsert);
    }
    return data;
  };
  Operation.remove = function(data, options) {
    var d, flag, multi, result, where, _i, _len;
    where = options.where || {};
    multi = options.multi != null ? options.multi : true;
    result = [];
    flag = false;
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      d = data[_i];
      if (flag) {
        result.push(d);
        continue;
      }
      if (Where(d, where)) {
        if (!multi) {
          flag = true;
        }
        continue;
      }
      result.push(d);
    }
    return result;
  };
  Operation.find = function(data, options) {
    var d, limit, projection, result, where, _i, _len;
    where = options.where || {};
    projection = options.projection || {};
    limit = options.limit || -1;
    result = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      d = data[_i];
      if (!(Where(d, where))) {
        continue;
      }
      if (limit === 0) {
        break;
      }
      limit -= 1;
      result.push(d);
    }
    return Projection.generate(result, projection);
  };
  Update = {
    isKeyReserved: function(key) {
      return key === '$inc' || key === '$set' || key === '$mul' || key === '$rename' || key === '$unset' || key === '$max' || key === '$min';
    },
    generate: function(data, action, value, where, multi, upsert) {
      var d, firstKey, flag, k, v, _i, _len;
      if (!Update.isKeyReserved(action)) {
        return data;
      }
      for (k in value) {
        v = value[k];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          d = data[_i];
          if (!(Where(d, where))) {
            continue;
          }
          flag = false;
          while (k.indexOf(".") > 0) {
            firstKey = k.split(".")[0];
            d = d[firstKey];
            if ((d == null) && !upsert) {
              flag = true;
              break;
            }
            if (upsert) {
              d = d || {};
            }
            k = k.substr(k.indexOf(".") + 1);
          }
          if (flag) {
            continue;
          }
          switch (action) {
            case "$inc":
              if ((d[k] != null) || upsert) {
                d[k] += v;
              }
              break;
            case "$set":
              if ((d[k] != null) || upsert) {
                d[k] = v;
              }
              break;
            case "$mul":
              if ((d[k] != null) || upsert) {
                d[k] *= v;
              }
              break;
            case "$rename":
              d[v] = d[k];
              delete d[k];
              break;
            case "$unset":
              delete d[k];
              break;
            case "$min":
              if ((d[k] != null) || upsert) {
                d[k] = Math.min(d[k], v);
              }
              break;
            case "$max":
              if ((d[k] != null) || upsert) {
                d[k] = Math.max(d[k], v);
              }
          }
          if (!multi) {
            break;
          }
        }
      }
      return data;
    }
  };
  self.Operation = Operation;

  /**
   * https://github.com/then/promise [v6.0.1]
   */

  // Use the fastest possible means to execute a task in a future turn
  // of the event loop.

  // linked list of tasks (single, with head node)
  var head = {
    task: void 0,
    next: null
  };
  var tail = head;
  var flushing = false;
  var requestFlush = void 0;
  var isNodeJS = false;

  function flush() {
    /* jshint loopfunc: true */

    while (head.next) {
      head = head.next;
      var task = head.task;
      head.task = void 0;
      var domain = head.domain;

      if (domain) {
        head.domain = void 0;
        domain.enter();
      }

      try {
        task();

      } catch (e) {
        if (isNodeJS) {
          // In node, uncaught exceptions are considered fatal errors.
          // Re-throw them synchronously to interrupt flushing!

          // Ensure continuation if the uncaught exception is suppressed
          // listening "uncaughtException" events (as domains does).
          // Continue in next event to avoid tick recursion.
          if (domain) {
            domain.exit();
          }
          setTimeout(flush, 0);
          if (domain) {
            domain.enter();
          }

          throw e;

        } else {
          // In browsers, uncaught exceptions are not fatal.
          // Re-throw them asynchronously to avoid slow-downs.
          setTimeout(function() {
            throw e;
          }, 0);
        }
      }

      if (domain) {
        domain.exit();
      }
    }

    flushing = false;
  }

  if (typeof process !== "undefined" && process.nextTick) {
    // Node.js before 0.9. Note that some fake-Node environments, like the
    // Mocha test runner, introduce a `process` global without a `nextTick`.
    isNodeJS = true;

    requestFlush = function() {
      process.nextTick(flush);
    };

  } else if (typeof setImmediate === "function") {
    // In IE10, Node.js 0.9+, or https://github.com/NobleJS/setImmediate
    if (typeof window !== "undefined") {
      requestFlush = setImmediate.bind(window, flush);
    } else {
      requestFlush = function() {
        setImmediate(flush);
      };
    }

  } else if (typeof MessageChannel !== "undefined") {
    // modern browsers
    // http://www.nonblocking.io/2011/06/windownexttick.html
    var channel = new MessageChannel();
    channel.port1.onmessage = flush;
    requestFlush = function() {
      channel.port2.postMessage(0);
    };

  } else {
    // old browsers
    requestFlush = function() {
      setTimeout(flush, 0);
    };
  }

  function asap(task) {
    tail = tail.next = {
      task: task,
      domain: isNodeJS && process.domain,
      next: null
    };

    if (!flushing) {
      flushing = true;
      requestFlush();
    }
  };


  function Promise(fn) {
    if (typeof this !== 'object') throw new TypeError('Promises must be constructed via new')
    if (typeof fn !== 'function') throw new TypeError('not a function')
    var state = null
    var value = null
    var deferreds = []
    var self = this

    this.then = function(onFulfilled, onRejected) {
      return new self.constructor(function(resolve, reject) {
        handle(new Handler(onFulfilled, onRejected, resolve, reject))
      })
    }

    function handle(deferred) {
      if (state === null) {
        deferreds.push(deferred)
        return
      }
      asap(function() {
        var cb = state ? deferred.onFulfilled : deferred.onRejected
        if (cb === null) {
          (state ? deferred.resolve : deferred.reject)(value)
          return
        }
        var ret
        try {
          ret = cb(value)
        } catch (e) {
          deferred.reject(e)
          return
        }
        deferred.resolve(ret)
      })
    }

    function resolve(newValue) {
      try { //Promise Resolution Procedure: https://github.com/promises-aplus/promises-spec#the-promise-resolution-procedure
        if (newValue === self) throw new TypeError('A promise cannot be resolved with itself.')
        if (newValue && (typeof newValue === 'object' || typeof newValue === 'function')) {
          var then = newValue.then
          if (typeof then === 'function') {
            doResolve(then.bind(newValue), resolve, reject)
            return
          }
        }
        state = true
        value = newValue
        finale()
      } catch (e) {
        reject(e)
      }
    }

    function reject(newValue) {
      state = false
      value = newValue
      finale()
    }

    function finale() {
      for (var i = 0, len = deferreds.length; i < len; i++)
        handle(deferreds[i])
      deferreds = null
    }

    doResolve(fn, resolve, reject)
  }


  function Handler(onFulfilled, onRejected, resolve, reject) {
    this.onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : null
    this.onRejected = typeof onRejected === 'function' ? onRejected : null
    this.resolve = resolve
    this.reject = reject
  }

  /**
   * Take a potentially misbehaving resolver function and make sure
   * onFulfilled and onRejected are only called once.
   *
   * Makes no guarantees about asynchrony.
   */
  function doResolve(fn, onFulfilled, onRejected) {
    var done = false;
    try {
      fn(function(value) {
        if (done) return
        done = true
        onFulfilled(value)
      }, function(reason) {
        if (done) return
        done = true
        onRejected(reason)
      })
    } catch (ex) {
      if (done) return
      done = true
      onRejected(ex)
    }
  }

  Promise.prototype.done = function(onFulfilled, onRejected) {
    var self = arguments.length ? this.then.apply(this, arguments) : this
    self.then(null, function(err) {
      asap(function() {
        throw err
      })
    })
  }

  /* Static Functions */

  function ValuePromise(value) {
    this.then = function(onFulfilled) {
      if (typeof onFulfilled !== 'function') return this
      return new Promise(function(resolve, reject) {
        asap(function() {
          try {
            resolve(onFulfilled(value))
          } catch (ex) {
            reject(ex);
          }
        })
      })
    }
  }
  ValuePromise.prototype = Promise.prototype

  var TRUE = new ValuePromise(true)
  var FALSE = new ValuePromise(false)
  var NULL = new ValuePromise(null)
  var UNDEFINED = new ValuePromise(undefined)
  var ZERO = new ValuePromise(0)
  var EMPTYSTRING = new ValuePromise('')

  Promise.resolve = function(value) {
    if (value instanceof Promise) return value

    if (value === null) return NULL
    if (value === undefined) return UNDEFINED
    if (value === true) return TRUE
    if (value === false) return FALSE
    if (value === 0) return ZERO
    if (value === '') return EMPTYSTRING

    if (typeof value === 'object' || typeof value === 'function') {
      try {
        var then = value.then
        if (typeof then === 'function') {
          return new Promise(then.bind(value))
        }
      } catch (ex) {
        return new Promise(function(resolve, reject) {
          reject(ex)
        })
      }
    }

    return new ValuePromise(value)
  }

  Promise.all = function(arr) {
    var args = Array.prototype.slice.call(arr)

    return new Promise(function(resolve, reject) {
      if (args.length === 0) return resolve([])
      var remaining = args.length

      function res(i, val) {
        try {
          if (val && (typeof val === 'object' || typeof val === 'function')) {
            var then = val.then
            if (typeof then === 'function') {
              then.call(val, function(val) {
                res(i, val)
              }, reject)
              return
            }
          }
          args[i] = val
          if (--remaining === 0) {
            resolve(args);
          }
        } catch (ex) {
          reject(ex)
        }
      }
      for (var i = 0; i < args.length; i++) {
        res(i, args[i])
      }
    })
  }

  Promise.reject = function(value) {
    return new Promise(function(resolve, reject) {
      reject(value);
    });
  }

  Promise.race = function(values) {
    return new Promise(function(resolve, reject) {
      values.forEach(function(value) {
        Promise.resolve(value).then(resolve, reject);
      })
    });
  }

  /* Prototype Methods */

  Promise.prototype['catch'] = function(onRejected) {
    return this.then(null, onRejected);
  }

  /* Static Functions */

  Promise.denodeify = function(fn, argumentCount) {
    argumentCount = argumentCount || Infinity
    return function() {
      var self = this
      var args = Array.prototype.slice.call(arguments)
      return new Promise(function(resolve, reject) {
        while (args.length && args.length > argumentCount) {
          args.pop()
        }
        args.push(function(err, res) {
          if (err) reject(err)
          else resolve(res)
        })
        fn.apply(self, args)
      })
    }
  }
  Promise.nodeify = function(fn) {
    return function() {
      var args = Array.prototype.slice.call(arguments)
      var callback = typeof args[args.length - 1] === 'function' ? args.pop() : null
      var ctx = this
      try {
        return fn.apply(this, arguments).nodeify(callback, ctx)
      } catch (ex) {
        if (callback === null || typeof callback == 'undefined') {
          return new Promise(function(resolve, reject) {
            reject(ex)
          })
        } else {
          asap(function() {
            callback.call(ctx, ex)
          })
        }
      }
    }
  }

  Promise.prototype.nodeify = function(callback, ctx) {
    if (typeof callback != 'function') return this

    this.then(function(value) {
      asap(function() {
        callback.call(ctx, null, value)
      })
    }, function(err) {
      asap(function() {
        callback.call(ctx, err)
      })
    })
  }

  self.Promise = Promise;
var __slice = [].slice;


  
  var Collection;
  Collection = (function() {

    /*
     *  in LocalDB, only use LocalDB to get a collection.
     *  db = new LocalDB('foo')
     *  var collection = db.collection('bar')
     */
    function Collection(collectionName, engine) {
      this.engine = engine;
      this.name = "" + engine.name + "_" + collectionName;
    }


    /*
     *  get data and tranfer into object from localStorage/sessionStorage
     */

    Collection.prototype.deserialize = function(callback) {
      return this.engine.getItem(this.name, function(data, err) {
        return callback(Utils.parse(data), err);
      });
    };


    /*
     *  save data into localStorage/sessionStorage
     *  when catching error in setItem(), delete the oldest data and try again.
     */

    Collection.prototype.serialize = function(data, callback) {
      return this.engine.setItem(this.name, Utils.stringify(data), callback);
    };


    /*
     *  delete this collection
     */

    Collection.prototype.drop = function(callback) {
      var promiseFn, self;
      self = this;
      promiseFn = function(resolve, reject) {
        return self.engine.removeItem(self.name, function(err) {
          if (callback != null) {
            callback(err);
          }
          if (err != null) {
            return reject(err);
          } else {
            return resolve();
          }
        });
      };
      return new Promise(promiseFn);
    };


    /*
     *  insert data into collection
     */

    Collection.prototype.insert = function() {
      var callback, options, paras, promiseFn, rowData, self, _ref;
      rowData = arguments[0], paras = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = Utils.parseParas(paras), options = _ref[0], callback = _ref[1];
      self = this;
      promiseFn = function(resolve, reject) {
        return self.deserialize(function(data, err) {
          if (err != null) {
            if (callback != null) {
              callback(err);
            }
            return reject(err);
          } else {
            data = Operation.insert(data, rowData, options);
            return self.serialize(data, function(err) {
              if (callback != null) {
                callback(err);
              }
              if (err != null) {
                return reject(err);
              } else {
                return resolve();
              }
            });
          }
        });
      };
      return new Promise(promiseFn);
    };


    /*
     *  update collection
     */

    Collection.prototype.update = function() {
      var actions, callback, options, paras, promiseFn, self, _ref;
      actions = arguments[0], paras = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = Utils.parseParas(paras), options = _ref[0], callback = _ref[1];
      self = this;
      promiseFn = function(resolve, reject) {
        return self.deserialize(function(data, err) {
          if (err) {
            if (callback != null) {
              callback(err);
            }
            return reject(err);
          } else {
            data = Operation.update(data, actions, options);
            return self.serialize(data, function(err) {
              if (callback != null) {
                callback(err);
              }
              if (err != null) {
                return reject(err);
              } else {
                return resolve();
              }
            });
          }
        });
      };
      return new Promise(promiseFn);
    };


    /*
     *  remove data from collection
     */

    Collection.prototype.remove = function() {
      var callback, options, paras, promiseFn, self, _ref;
      paras = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = Utils.parseParas(paras), options = _ref[0], callback = _ref[1];
      self = this;
      promiseFn = function(resolve, reject) {
        return self.deserialize(function(data, err) {
          if (err != null) {
            if (callback != null) {
              callback(err);
            }
            return reject(err);
          } else {
            data = Operation.remove(data, options);
            return self.serialize(data, function(err) {
              if (callback != null) {
                callback(err);
              }
              if (err != null) {
                return reject(err);
              } else {
                return resolve();
              }
            });
          }
        });
      };
      return new Promise(promiseFn);
    };


    /*
     * find data from collection
     */

    Collection.prototype.find = function() {
      var callback, options, paras, promiseFn, self, _ref;
      paras = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = Utils.parseParas(paras), options = _ref[0], callback = _ref[1];
      self = this;
      promiseFn = function(resolve, reject) {
        return self.deserialize(function(data, err) {
          if (err != null) {
            if (callback != null) {
              callback([], err);
            }
            return reject(err);
          } else {
            data = Operation.find(data, options);
            if (callback != null) {
              callback(data, err);
            }
            if (err != null) {
              return reject(err);
            } else {
              return resolve(data);
            }
          }
        });
      };
      return new Promise(promiseFn);
    };


    /*
     *  find data and only return one data from collection
     */

    Collection.prototype.findOne = function() {
      var callback, options, paras, promiseFn, self, _ref;
      paras = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = Utils.parseParas(paras), options = _ref[0], callback = _ref[1];
      options.limit = 1;
      self = this;
      promiseFn = function(resolve, reject) {
        return self.deserialize(function(data, err) {
          if (err != null) {
            if (callback != null) {
              callback(void 0, err);
            }
            return reject(err);
          } else {
            data = Operation.find(data, options);
            if (callback != null) {
              callback(data[0], err);
            }
            if (err != null) {
              return reject(err);
            } else {
              return resolve(data[0]);
            }
          }
        });
      };
      return new Promise(promiseFn);
    };

    return Collection;

  })();
  self.Collection = Collection;

  
  var Support, mod;
  mod = 'lST$*@?';
  Support = {};
  Support.localstorage = function() {
    var e;
    try {
      localStorage.setItem(mod, mod);
      localStorage.removeItem(mod);
      return true;
    } catch (_error) {
      e = _error;
      return false;
    }
  };
  Support.sessionstorage = function() {
    var e;
    try {
      sessionStorage.setItem(mod, mod);
      sessionStorage.removeItem(mod);
      return true;
    } catch (_error) {
      e = _error;
      return false;
    }
  };
  Support.postmessage = function() {
    return typeof postMessage !== "undefined" && postMessage !== null;
  };
  Support.websqldatabase = function() {
    return typeof openDatabase !== "undefined" && openDatabase !== null;
  };
  Support.indexedDB = function() {
    return (typeof indexedDB !== "undefined" && indexedDB !== null) || (typeof webkitIndexedDB !== "undefined" && webkitIndexedDB !== null) || (typeof mozIndexedDB !== "undefined" && mozIndexedDB !== null) || (typeof OIndexedDB !== "undefined" && OIndexedDB !== null) || (typeof msIndexedDB !== "undefined" && msIndexedDB !== null);
  };
  Support.applicationcache = function() {
    return typeof applicationCache !== "undefined" && applicationCache !== null;
  };
  Support.userdata = function() {
    return document.documentElement.addBehavior != null;
  };
  self.Support = Support;

  
  var UserData;
  UserData = (function() {

    /* rewrite with coffee from https://github.com/marcuswestin/store.js
    // Since #userData storage applies only to specific paths, we need to
    // somehow link our data to a specific path.  We choose /favicon.ico
    // as a pretty safe option, since all browsers already make a request to
    // this URL anyway and being a 404 will not hurt us here.  We wrap an
    // iframe pointing to the favicon in an ActiveXObject(htmlfile) object
    // (see: http://msdn.microsoft.com/en-us/library/aa752574(v=VS.85).aspx)
    // since the iframe access rules appear to allow direct access and
    // manipulation of the document element, even for a 404 page.  This
    // document can be used instead of the current document (which would
    // have been limited to the current path) to perform #userData storage.
     */
    function UserData() {
      var e, storageContainer;
      try {
        storageContainer = new ActiveXObject('htmlfile');
        storageContainer.open();
        storageContainer.write('<script>document.w=window</script><iframe src="/favicon.ico"></iframe>');
        storageContainer.close();
        this.storageOwner = storageContainer.w.frames[0].document;
        this.storage = this.storageOwner.createElement('div');
      } catch (_error) {
        e = _error;

        /*
        // somehow ActiveXObject instantiation failed (perhaps some special
        // security settings or otherwse), fall back to per-path storage
         */
        this.storage = document.createElement('div');
        this.storageOwner = document.body;
      }
    }

    UserData.prototype.localStorageName = "localStorage";

    UserData.prototype.forbiddenCharsRegex = new RegExp("[!\"#$%&'()*+,/\\\\:;<=>?@[\\]^`{|}~]", "g");

    UserData.prototype.ieKeyFix = function(key) {
      return key.replace(/^d/, '___$&').replace(this.forbiddenCharsRegex, '___');
    };

    UserData.prototype.setItem = function(key, val) {
      key = this.ieKeyFix(key);
      this.storageOwner.appendChild(this.storage);
      this.storage.addBehavior("#default#userData");
      this.storage.load(this.localStorageName);
      this.storage.setAttribute(key, val);
      this.storage.save(this.localStorageName);
      return true;
    };

    UserData.prototype.getItem = function(key) {
      key = this.ieKeyFix(key);
      this.storageOwner.appendChild(this.storage);
      this.storage.addBehavior("#default#userData");
      this.storage.load(this.localStorageName);
      return this.storage.getAttribute(key);
    };

    UserData.prototype.removeItem = function(key) {
      key = this.ieKeyFix(key);
      this.storageOwner.appendChild(this.storage);
      this.storage.addBehavior("#default#userData");
      this.storage.load(this.localStorageName);
      this.storage.removeAttribute(key);
      return this.storage.save(this.localStorageName);
    };

    UserData.prototype.size = function() {
      return this.storage.XMLDocument.documentElement.attributes.length;
    };

    UserData.prototype.key = function(index) {
      return this.storage.XMLDocument.documentElement.attributes[index];
    };

    return UserData;

  })();
  self.UserData = UserData;
/*   
 *   A   JavaScript   implementation   of   the   Secure   Hash   Algorithm,   SHA-1,   as   defined
 *   in   FIPS   PUB   180-1
 *   Version   2.1-BETA   Copyright   Paul   Johnston   2000   -   2002.
 *   Other   contributors:   Greg   Holt,   Andrew   Kepert,   Ydnar,   Lostinet
 *   Distributed   under   the   BSD   License
 *   See   http://pajhome.org.uk/crypt/md5   for   details.
 */
/*   
 *   Configurable   variables.   You   may   need   to   tweak   these   to   be   compatible   with
 *   the   server-side,   but   the   defaults   work   in   most   cases.
 */

  
  var hexcase = 0; /*   hex   output   format.   0   -   lowercase;   1   -   uppercase                 */
  var b64pad = ""; /*   base-64   pad   character.   "="   for   strict   RFC   compliance       */
  var chrsz = 8; /*   bits   per   input   character.   8   -   ASCII;   16   -   Unicode             */
  var Sha1 = {};
  /*   
   *   These   are   the   functions   you'll   usually   want   to   call
   *   They   take   string   arguments   and   return   either   hex   or   base-64   encoded   strings
   */
  Sha1.hex_sha1 = function(s) {
    return binb2hex(core_sha1(str2binb(s), s.length * chrsz));
  }

  /*   
   *   Calculate   the   SHA-1   of   an   array   of   big-endian   words,   and   a   bit   length
   */
  function core_sha1(x, len) {
    /*   append   padding   */
    x[len >> 5] |= 0x80 << (24 - len % 32);
    x[((len + 64 >> 9) << 4) + 15] = len;

    var w = Array(80);
    var a = 1732584193;
    var b = -271733879;
    var c = -1732584194;
    var d = 271733878;
    var e = -1009589776;

    for (var i = 0; i < x.length; i += 16) {
      var olda = a;
      var oldb = b;
      var oldc = c;
      var oldd = d;
      var olde = e;

      for (var j = 0; j < 80; j++) {
        if (j < 16) w[j] = x[i + j];
        else w[j] = rol(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16], 1);
        var t = safe_add(safe_add(rol(a, 5), sha1_ft(j, b, c, d)), safe_add(safe_add(e, w[j]), sha1_kt(j)));
        e = d;
        d = c;
        c = rol(b, 30);
        b = a;
        a = t;
      }

      a = safe_add(a, olda);
      b = safe_add(b, oldb);
      c = safe_add(c, oldc);
      d = safe_add(d, oldd);
      e = safe_add(e, olde);
    }
    return Array(a, b, c, d, e);

  }

  /*   
   *   Perform   the   appropriate   triplet   combination   function   for   the   current
   *   iteration
   */
  function sha1_ft(t, b, c, d) {
    if (t < 20) return (b & c) | ((~b) & d);
    if (t < 40) return b ^ c ^ d;
    if (t < 60) return (b & c) | (b & d) | (c & d);
    return b ^ c ^ d;
  }

  /*   
   *   Determine   the   appropriate   additive   constant   for   the   current   iteration
   */
  function sha1_kt(t) {
    return (t < 20) ? 1518500249 : (t < 40) ? 1859775393 : (t < 60) ? -1894007588 : -899497514;
  }

  /*   
   *   Add   integers,   wrapping   at   2^32.   This   uses   16-bit   operations   internally
   *   to   work   around   bugs   in   some   JS   interpreters.
   */
  function safe_add(x, y) {
    var lsw = (x & 0xFFFF) + (y & 0xFFFF);
    var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
    return (msw << 16) | (lsw & 0xFFFF);
  }

  /*   
   *   Bitwise   rotate   a   32-bit   number   to   the   left.
   */
  function rol(num, cnt) {
    return (num << cnt) | (num >>> (32 - cnt));
  }

  /*   
   *   Convert   an   8-bit   or   16-bit   string   to   an   array   of   big-endian   words
   *   In   8-bit   function,   characters   >255   have   their   hi-byte   silently   ignored.
   */
  function str2binb(str) {
    var bin = Array();
    var mask = (1 << chrsz) - 1;
    for (var i = 0; i < str.length * chrsz; i += chrsz)
      bin[i >> 5] |= (str.charCodeAt(i / chrsz) & mask) << (24 - i % 32);
    return bin;
  }

  /*   
   *   Convert   an   array   of   big-endian   words   to   a   hex   string.
   */
  function binb2hex(binarray) {
    var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";
    var str = "";
    for (var i = 0; i < binarray.length * 4; i++) {
      str += hex_tab.charAt((binarray[i >> 2] >> ((3 - i % 4) * 8 + 4)) & 0xF) + hex_tab.charAt((binarray[i >> 2] >> ((3 - i % 4) * 8)) & 0xF);
    }
    return str;
  }

  self.Sha1 = Sha1;

  
  var Encrypt;
  Encrypt = {};

  /*
    * 加密
   */
  Encrypt.encode = function(value, key) {
    var comEncodeVal, encodeVal, index, len, mod, resultArr, resultStr, uniKey, uniKeyArr, uniValue, uniValueArr, unicodeKey, unicodeValue, _i, _len;
    if (value === null) {
      return null;
    }
    resultArr = [''];
    key = Sha1.hex_sha1(key);
    unicodeValue = Utils.toUnicode(value);
    unicodeKey = Utils.toUnicode(key);
    uniValueArr = unicodeValue.split('\\u').slice(1);
    uniKeyArr = unicodeKey.split('\\u').slice(1);
    len = uniKeyArr.length;
    for (index = _i = 0, _len = uniValueArr.length; _i < _len; index = ++_i) {
      uniValue = uniValueArr[index];
      mod = index % len;
      uniKey = uniKeyArr[mod];
      encodeVal = parseInt(uniValue, 16) + parseInt(uniKey, 16);
      if (encodeVal > 65536) {
        encodeVal = encodeVal - 65536;
      }
      comEncodeVal = ('00' + encodeVal.toString(16)).slice(-4);
      resultArr.push(comEncodeVal);
    }
    resultStr = resultArr.join('\\u');
    return Utils.fromUnicode(resultStr);
  };

  /*
    * 解密
   */
  Encrypt.decode = function(value, key) {
    var comEncodeVal, encodeVal, index, len, mod, resultArr, resultStr, uniKey, uniKeyArr, uniValue, uniValueArr, unicodeKey, unicodeValue, _i, _len;
    if (value === null) {
      return null;
    }
    resultArr = [''];
    key = Sha1.hex_sha1(key);
    unicodeValue = Utils.toUnicode(value);
    unicodeKey = Utils.toUnicode(key);
    uniValueArr = unicodeValue.split('\\u').slice(1);
    uniKeyArr = unicodeKey.split('\\u').slice(1);
    len = uniKeyArr.length;
    for (index = _i = 0, _len = uniValueArr.length; _i < _len; index = ++_i) {
      uniValue = uniValueArr[index];
      mod = index % len;
      uniKey = uniKeyArr[mod];
      encodeVal = parseInt(uniValue, 16) - parseInt(uniKey, 16);
      if (encodeVal < 0) {
        encodeVal = 65536 + encodeVal;
      }
      comEncodeVal = ('00' + encodeVal.toString(16)).slice(-4);
      resultArr.push(comEncodeVal);
    }
    resultStr = resultArr.join('\\u');
    return Utils.fromUnicode(resultStr);
  };
  self.Encrypt = Encrypt;

  
  var Storage;
  Storage = (function() {
    function Storage(session, encrypt, token) {
      this.session = session;
      this.encrypt = encrypt;
      this.token = token;
      if (this.session) {
        if (!Support.sessionstorage()) {
          throw new Error("sessionStorage is not supported!");
        }
      } else if (!Support.localstorage()) {
        if (!Support.userdata()) {
          throw new Error("no browser storage engine is supported in your browser!");
        }
        this.userdata = new UserData();
      }
    }

    Storage.prototype.key = function(index, callback) {
      var e, key;
      try {
        key = (this.session ? sessionStorage : (this.userdata != null ? this.userdata : localStorage)).key(index);
      } catch (_error) {
        e = _error;
        callback(-1, e);
      }
      callback(key);
    };

    Storage.prototype.size = function(callback) {
      var e, size;
      try {
        if (this.session) {
          size = sessionStorage.length;
        } else if (Support.localstorage()) {
          size = localStorage.length;
        } else {
          size = this.userdata.size();
        }
      } catch (_error) {
        e = _error;
        callback(-1, e);
      }
      callback(size);
    };

    Storage.prototype.setItem = function(key, val, callback) {
      var data, e, flag, ls;
      ls = (this.session ? sessionStorage : (this.userdata != null ? this.userdata : localStorage));
      try {
        if (this.encrypt) {
          val = Encrypt.encode(val, this.token);
        }
        ls.setItem(key, val);
      } catch (_error) {
        e = _error;
        flag = true;
        data = Utils.parse(val);
        while (flag) {
          try {
            data.splice(0, 1);
            ls.setItem(key, Utils.stringify(data));
            flag = false;
          } catch (_error) {}
        }
      }

      /* TODO
       *  目前采用的是删除初始数据来保证在数据存满以后仍然可以继续存下去
       *  在初始化LocalDB的时候需要增加配置参数，根据参数来决定是否自动删除初始数据，还是返回e
       */
      callback();
    };

    Storage.prototype.getItem = function(key, callback) {
      var e, item;
      try {
        item = (this.session ? sessionStorage : (this.userdata != null ? this.userdata : localStorage)).getItem(key);
        if (this.encrypt) {
          item = Encrypt.decode(item, this.token);
        }
      } catch (_error) {
        e = _error;
        callback(null, e);
      }
      callback(item);
    };

    Storage.prototype.removeItem = function(key, callback) {
      var e;
      try {
        (this.session ? sessionStorage : (this.userdata != null ? this.userdata : localStorage)).removeItem(key);
      } catch (_error) {
        e = _error;
        callback(e);
      }
      callback();
    };

    Storage.prototype.usage = function(callback) {

      /*
       *  check it out: http://stackoverflow.com/questions/4391575/how-to-find-the-size-of-localstorage
       */
      var allStrings, e, key, val;
      try {
        allStrings = "";
        if (this.tyep === 1) {
          for (key in sessionStorage) {
            val = sessionStorage[key];
            allStrings += val;
          }
        } else if (Support.localstorage()) {
          for (key in localStorage) {
            val = localStorage[key];
            allStrings += val;
          }
        } else {
          console.log("todo");
        }
      } catch (_error) {
        e = _error;
        callback(-1, e);
      }
      return callback(allStrings.length / 512);
    };

    return Storage;

  })();
  self.Storage = Storage;

  
  var Proxy;
  Proxy = {};
  self.Proxy = Proxy;

  
  var Engine;
  Engine = (function() {
    function Engine(session, encrypt, name, proxy) {
      this.session = session;
      this.encrypt = encrypt;
      this.name = name;
      this.proxy = proxy;
      if (this.proxy != null) {
        this.proxy = new Proxy(this.session, this.encrypt, this.name, this.proxy);
      } else {
        this.storage = new Storage(this.session, this.encrypt, this.name);
      }
      return;
    }

    Engine.prototype.key = function(index, callback) {
      return (this.proxy != null ? this.proxy : this.storage).key(index, callback);
    };

    Engine.prototype.size = function(callback) {
      return (this.proxy != null ? this.proxy : this.storage).size(callback);
    };

    Engine.prototype.setItem = function(key, val, callback) {
      return (this.proxy != null ? this.proxy : this.storage).setItem(key, val, callback);
    };

    Engine.prototype.getItem = function(key, callback) {
      return (this.proxy != null ? this.proxy : this.storage).getItem(key, callback);
    };

    Engine.prototype.removeItem = function(key, callback) {
      return (this.proxy != null ? this.proxy : this.storage).removeItem(key, callback);
    };

    Engine.prototype.usage = function(callback) {
      return (this.proxy != null ? this.proxy : this.storage).usage(callback);
    };

    return Engine;

  })();
  self.Engine = Engine;

  
  var LocalDB, dbPrefix;
  dbPrefix = "ldb_";
  LocalDB = (function() {

    /*
     *  Constructor
     *  var db = new LocalDB('foo')
     *  var db = new LocaoDB('foo', {
            session: true,
            encrypt: true,
            proxy: "http://www.foo.com/getProxy.html"
        })
     *
     *  Engine will decide to choose the best waty to handle the data automatically.
     *  when session is true, the data will be alive while browser stay open. e.g. sessionStorage
     *  when session is false, the data will be alive even after browser is closed. e.g. localStorage
     *  true by default
     *  The data will be stored encrypted if the encrpyt options is true, true by default.
     */
    function LocalDB(dbName, options) {
      if (options == null) {
        options = {};
      }
      if (dbName == null) {
        throw new Error("dbName should be specified.");
      }
      this.name = dbPrefix + dbName;
      this.session = options.session != null ? options.session : true;
      this.encrypt = options.encrypt != null ? options.encrypt : true;
      this.proxy = options.proxy != null ? options.proxy : null;
      this.engine = new Engine(this.session, this.encrypt, this.name, this.proxy);
    }

    LocalDB.prototype.options = function() {
      return {
        name: this.name.substr(dbPrefix.length),
        session: this.session,
        encrypt: this.encrypt,
        proxy: this.proxy
      };
    };


    /*
     *  Get Collection
     *  var collection = db.collection('bar')
     */

    LocalDB.prototype.collection = function(collectionName) {
      if (collectionName == null) {
        throw new Error("collectionName should be specified.");
      }
      return new Collection(collectionName, this.engine);
    };


    /*
     *  Delete Collection: db.drop(collectionName)
     *  Delete DB: db.drop()
     */

    return LocalDB;

  })();

  /*
   *  Check Browser Feature Compatibility
   */
  LocalDB.support = Support;

  /*
   *  Version
   */
  LocalDB.version = '0.0.1'

  /*
   *  Get Timestamp
   *  Convert ObjectId to timestamp
   */
  LocalDB.getTimestamp = function(objectId) {
    return Utils.getTimestamp(objectId);
  };

  /*
   *  Get Time
   *  Convert ObjectId to time
   */
  LocalDB.getTime = function(objectId) {
    return Utils.getTime(objectId);
  };
  self.LocalDB = LocalDB;

  if ( typeof define === "function" && define.amd ) {
    define( "localdb", [], function() {
      return LocalDB;
    });
  }

  if (!noGlobal) {
    window.LocalDB = LocalDB
  }

  return LocalDB
}));