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
    var chr = String.fromCharCode;

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

    /**
     * Expose.
     */
    BinaryParser.Buffer = BinaryParserBuffer;

    

  var MACHINE_ID, ObjectID, checkForHexRegExp, hexTable, i;
  hexTable = (function() {
    var _i, _results;
    _results = [];
    for (i = _i = 0; _i < 256; i = ++_i) {
      _results.push((i <= 15 ? '0' : '') + i.toString(16));
    }
    return _results;
  })();
  MACHINE_ID = parseInt(Math.random() * 0xFFFFFF, 10);
  checkForHexRegExp = /^[0-9a-fA-F]{24}$/;
  ObjectID = function(id, _hex) {
    this._bsontype = 'ObjectID';
    if ((id != null) && id.length !== 12 && id.length !== 24) {
      throw new Error("Argument passed in must be a single String of 12 bytes or a string of 24 hex characters");
    }
    if (id == null) {
      return this.id = this.generate();
    } else if ((id != null) && id.length === 12) {
      return this.id = id;
    } else if (checkForHexRegExp.test(id)) {
      return ObjectID.createFromHexString(id);
    } else {
      throw new Error("Value passed in is not a valid 24 character hex string");
    }
  };
  ObjectID.prototype.generate = function() {
    var index3Bytes, machine3Bytes, pid2Bytes, time4Bytes, unixTime;
    unixTime = parseInt(Date.now() / 1000, 10);
    time4Bytes = BinaryParser.encodeInt(unixTime, 32, true, true);
    machine3Bytes = BinaryParser.encodeInt(MACHINE_ID, 24, false);
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
  ObjectID.prototype.inspect = ObjectID.prototype.toString;
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
  ObjectID.index = parseInt(Math.random() * 0xFFFFFF, 10);
  ObjectID.createFromHexString = function(hexString) {
    var result, _i;
    result = '';
    for (i = _i = 0; _i < 24; i = ++_i) {
      if (i % 2 === 0) {
        result += BinaryParser.fromByte(parseInt(hexString.substr(i, 2), 16));
      }
    }
    return new ObjectID(result, hexString);
  };
  

  
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
  Utils.getTimestamp = function(objectId) {
    return (new ObjectID(objectId)).getTimestamp();
  };
  Utils.getTime = function(objectId) {
    return (new ObjectID(objectId)).getTime();
  };
  
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
  

  
  var Collection;
  Collection = (function() {

    /*
     *  in LocalDB, only use LocalDB to get a collection.
     *  db = new LocalDB('foo')
     *  var collection = db.collection('bar')
     */
    function Collection(collectionName, db) {
      if (collectionName === void 0) {
        throw new Error("collectionName should be specified.");
      }
      this.name = "" + db.name + "_" + collectionName;
      this.ls = db.ls;
      this.deserialize();
    }


    /*
     *  get data and tranfer into object from localStorage/sessionStorage
     */

    Collection.prototype.deserialize = function() {
      return this.data = Utils.parse(this.ls.getItem(this.name));
    };


    /*
     *  save data into localStorage/sessionStorage
     *  when catching error in setItem(), delete the oldest data and try again.
     */

    Collection.prototype.serialize = function() {
      var e, flag;
      try {
        this.ls.setItem(this.name, Utils.stringify(this.data));
      } catch (_error) {
        e = _error;
        flag = true;
        while (flag) {
          try {
            this.data.splice(0, 1);
            this.ls.setItem(this.name, Utils.stringify(this.data));
            flag = false;
          } catch (_error) {}
        }
      }
    };


    /*
     *  delete this collection
     */

    Collection.prototype.drop = function() {
      this.ls.removeItem(this.name);
      return true;
    };


    /*
     *  insert data into collection
     */

    Collection.prototype.insert = function(rowData, options) {
      if (options == null) {
        options = {};
      }
      this.deserialize();
      this.data = Operation.insert(this.data, rowData, options);
      return this.serialize();
    };


    /*
     *  update collection
     */

    Collection.prototype.update = function(actions, options) {
      if (options == null) {
        options = {};
      }
      this.deserialize();
      this.data = Operation.update(this.data, actions, options);
      return this.serialize();
    };


    /*
     *  remove data from collection
     */

    Collection.prototype.remove = function(options) {
      if (options == null) {
        options = {};
      }
      this.deserialize();
      this.data = Operation.remove(this.data, options);
      return this.serialize();
    };


    /*
     * find data from collection
     */

    Collection.prototype.find = function(options) {
      if (options == null) {
        options = {};
      }
      this.deserialize();
      return Operation.find(this.data, options);
    };


    /*
     *  find data and only return one data from collection
     */

    Collection.prototype.findOne = function(options) {
      var data;
      if (options == null) {
        options = {};
      }
      options.limit = 1;
      data = Operation.find(this.data, options)[0];
      if (data != null) {
        return data;
      } else {
        return {};
      }
    };

    return Collection;

  })();
  

  
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
    return !!postMessage;
  };
  Support.websqldatabase = function() {
    return !!openDatabase;
  };
  Support.indexedDB = function() {
    return !!(indexedDB || webkitIndexedDB || mozIndexedDB || OIndexedDB || msIndexedDB);
  };
  Support.applicationcache = function() {
    return !!applicationCache;
  };
  Support.userdata = function() {
    return !!document.documentElement.addBehavior;
  };
  

  
  var Engine, UserData;
  Engine = (function() {
    function Engine(type) {
      this.type = type === 2 ? 2 : 1;
      if (!Support.sessionstorage()) {
        if (type === 1) {
          throw new Error("sessionStorage is not supported!");
        }
        if (Support.userdata()) {
          throw new Error("no browser storage engine is supported in your browser!");
        }
        this.type = 2;
      }
      if (this.type === 2 && Support.localstorage()) {
        this.userdata = new UserData();
      }
      return;
    }

    Engine.prototype.key = function(index) {
      if (this.type === 1) {
        return sessionStorage.key(index);
      } else if (Support.localstorage()) {
        return localStorage.key(index);
      } else {
        return this.userdata.key(index);
      }
    };

    Engine.prototype.size = function() {
      if (this.type === 1) {
        return sessionStorage.length;
      } else if (Support.localstorage()) {
        return localStorage.length;
      } else {
        return this.userdata.size();
      }
    };

    Engine.prototype.setItem = function(key, val) {
      if (this.type === 1) {
        return sessionStorage.setItem(key, val);
      } else if (Support.localstorage()) {
        return localStorage.setItem(key, val);
      } else {
        return this.userdata.setItem(key, val);
      }
    };

    Engine.prototype.getItem = function(key) {
      if (this.type === 1) {
        return sessionStorage.getItem(key);
      } else if (Support.localstorage()) {
        return localStorage.getItem(key);
      } else {
        return this.userdata.getItem(key, val);
      }
    };

    Engine.prototype.removeItem = function(key) {
      if (this.type === 1) {
        return sessionStorage.removeItem(key);
      } else if (Support.localstorage()) {
        return localStorage.removeItem(key);
      } else {
        return this.userdata.removeItem(key, val);
      }
    };

    Engine.prototype.usage = function() {

      /*
       *  check it out: http://stackoverflow.com/questions/4391575/how-to-find-the-size-of-localstorage
       */
      var allStrings, key, val;
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
      return allStrings.length / 512;
    };

    return Engine;

  })();
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
  

  
  var LocalDB, dbPrefix;
  dbPrefix = "ldb_";
  LocalDB = (function() {

    /*
     *  Constructor
     *  var db = new LocalDB('foo')
     *  var db = new LocalDB('foo', {type: 1})
     *  var db = new LocalDB('foo', {type: 2})
     *
     *  Engine will decide to choose the best waty to handle the data automatically.
     *  when type is 1, the data will be alive while browser stay open. e.g. sessionStorage
     *  when type is 2, the data will be alive even after browser is closed. e.g. localStorage
     *  1 by default
     */
    function LocalDB(dbName, options) {
      if (options == null) {
        options = {};
      }
      if (dbName === void 0) {
        throw new Error("dbName should be specified.");
      }
      this.name = dbPrefix + dbName;
      this.ls = new Engine(options.type || 1);
    }

    LocalDB.prototype.options = function() {
      return {
        name: this.name.substr(dbPrefix.length),
        type: this.ls.type
      };
    };


    /*
     *  Get Collection Names
     *  db.collections()    //['foo','foo1','foo2','foo3',....]
     */

    LocalDB.prototype.collections = function() {
      var i, _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = this.ls.size(); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (this.ls.key(i).indexOf("" + this.name + "_") === 0) {
          _results.push(this.ls.key(i).substr(("" + this.name + "_").length));
        }
      }
      return _results;
    };


    /*
     *  Get Collection
     *  var collection = db.collection('bar')
     */

    LocalDB.prototype.collection = function(collectionName) {
      return new Collection(collectionName, this);
    };


    /*
     *  Delete Collection: db.drop(collectionName)
     *  Delete DB: db.drop()
     */

    LocalDB.prototype.drop = function(collectionName) {
      var i, j, keys, _i, _len;
      collectionName = collectionName != null ? "_" + collectionName : "";
      keys = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = this.ls.size(); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (this.ls.key(i).indexOf(this.name + collectionName) === 0) {
            _results.push(this.ls.key(i));
          }
        }
        return _results;
      }).call(this);
      for (_i = 0, _len = keys.length; _i < _len; _i++) {
        j = keys[_i];
        this.ls.removeItem(j);
      }
      return true;
    };

    return LocalDB;

  })();

  /*
   *  Check Browser Compatibility
   *  use LocalDB.isSupport() to check whether the browser support LocalDB or not.
   */
  LocalDB.support = function() {
    return {
      localStorage: typeof localStorage !== "undefined" && localStorage !== null ? true : false,
      sessionStorage: typeof sessionStorage !== "undefined" && sessionStorage !== null ? true : false,
      indexedDB: false
    };
  };

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
  
  return LocalDB
}));