# LocalDB -- Browser Storage Framework

---

[![spm package][spm-image]][spm-url] [![Build Status][build-image]][build-url] [![Coverage Status][coverage-image]][coverage-url] [![MIT License][license-image]][license-url]

## 介绍

Github Repo: https://github.com/wh1100717/localDB
API Reference: http://localdb.emptystack.net/

**[LocalDB]** 为开发者提供简单、易用又强大的浏览器端数据存取接口，其被设计用来为 WEB 应用、手机 H5 应用、网页游戏引擎提供浏览器端持久化存储方案，LocalDB包含以下特性：

*   基于 JSON 文档风格的存储方式
*   支持多种数据格式的存储，例如：函数、正则表达式
*   支持基于文档的富查询及排序功能
*   支持 AMD/CMD/Standalone 等多种模块加载方式
*   支持数据存取加密功能
*   智能存储引擎切换
*   支持域白名单功能，实现跨域共享数据，独特的跨域数据共享解决方案
*   独特的域数据模块化解决方案
*   高安全性(可以通过更改proxy来隐藏数据所存储的真实域)
*   支持 [Promise] 或 Callback 异步编程
*   支持 [BSON] objectId

## 整体架构

LocalDB采用模块化开发的方式，通过requirejs对模块进行加载和控制，目前分为如下模块：

*   localdb: 项目的入口模块，负责对LocalDB提供初始化支持，并提供了常用的类方法。主要依赖core/collection，并对core/engine和core/server模块进行初始化。
*   core/collection: 集合操作模块，对外暴露接口，包含drop/insert/update/remove/find/findOne等集合操作，主要依赖core/operation和core/engine模块，主要包含的集合操作如下：
    *   drop:   删除集合。
    *   insert: 向集合中插入数据，支持插入的数据为对象和包含对象的数组(相当于插入多条数据)，对象中包含的数据类型可以为数字、字符串、正则表达式、对象、函数和数组。
    *   update: 更新集合中的数据，目前支持的操作有：`$inc`, `$set`, `$mul`, `$rename`, `$unset`, `$max`, `$min`。
    *   remove: 删除集合中的数据。
    *   find:   查询集合中的数据。
    *   findOne:    查询集合中的数据，但只返回第一条数据。
*   core/operation: 结合操作的数据层具体实现模块，被core/collection模块调用，主要依赖core/where和core/projection模块。
*   core/where: 提供多种选择条件的支持，被core/operation模块调用，主要支持操作如下:
    *   Comparison: `$gt`, `$gte`, `$lt`, `$lte`, `$ne`, `$in`, `$nin`
    *   Logical:    `$and`, `$nor`, `$or`, `$not`
    *   Element:    `$exists`, `$type`
    *   Evaluation: `$mod`, `$regex`
    *   Array:      `$all`, `$elemMatch`, `$size`
*   core/projection： 提供查询数据筛选功能的支持，被core/operation模块调用。
*   core/engine:    引擎模块，对上层暴露统一的API接口，对下层根据是否指定proxy来采取不同的策略进行数据存取服务。主要被core/collection模块调用，在localdb模块中进行初始化。
*   core/proxy:     代理模块，用于在LocalDB指定代理域时进行域间信息交互，与目标域的core/server模块进行交互，被core/engine模块调用。
*   core/server:    服务模块，用于在LocalDB所指定的代理与进行初始化和消息接受并调用core/Storage模块进行底层数据处理。
*   core/storage：  底层数据存储接口，根据不同的配置和浏览器来选择适合的driver来进行数据的存取。理论上来讲对更多存储引擎的支持只需要将存储引擎进行封装并满足storage的调用接口规范即可。
*   core/utils:     该模块主要封装和提供了项目中常用的函数。
*   lib/bson:       该模块主要提供了ObjectId的生成和解析支持。
*   lib/encrypt:    该模块主要提供了数据加密和解密的支持。
*   lib/promise:    该模块主要提供了promise方式封装回调方法的支持。
*   lib/support:    该模块主要提供对浏览器响应存储引擎支持的判断。

## 如何使用

---

### Installation By Bower

```bash
$ bower install localdb
```

### Installation By SPM

```bash
$ spm install localdb
```

通过 [bower] 安装或者直接下载独立库文件的用户，可以直接在html页面中引用该js文件：

```html
<!DOCTYPE html>
<html>
<head>
    <script type="text/javascript" src="dist/0.1.0/localdb.js"></script>
</head>
<body>
</body>
<script type="text/javascript">
    var db = new LocalDB("foo")
</script>
</html>
```

[LocalDB] 支持 [requirejs] 作为其模块加载器，具体用法如下：

```html
<!DOCTYPE html>
<html>
<head>
    <script type="text/javascript" src="emaples/require.js"></script>
</head>
<body>
</body>
<script type="text/javascript">
    require(['dist/0.1.0/localdb'],function(LocalDB){
        var db = new LocalDB("foo")
    }
</script>
</html>
```

[LocalDB] 支持 [seajs] 作为其模块加载器，通过 [SPM] 安装或者直接下载 [seajs] 版本的库文件的用户可以利用 [seajs] 来加载 [localDB]：

```html
<!DOCTYPE html>
<html>
<head>
    <script type="text/javascript" src="exmaples/sea.js"></script>
</head>
<body>
</body>
<script type="text/javascript">
    seajs.use('dist/0.1.0/localdb-seajs.js', function(LocalDB){
        var db = new LocalDB("foo")
    })
</script>
</html>
```

### Getting Started

```javascript
// 创建/获取名为`foo`的db
var db = new LocalDB("foo")
// 创建/获取该db中名为`bar`的collection
var collection = db.collection("bar")
// 插入数据
collection.insert({
    a: 5,
    b: "abc",
    c: /hell.*ld/,
    d: {e: 4, f: "5"},
    g: function(h){return h*3},
    i: [1,2,3]
}).then(function(err){
    // 查询数据
    // 目前支持添加的数据格式为数字、字符串、正则表达式、对象、函数和数组。
    collection.find({
        // `where`表示查询条件，相当于`select a,b from table where b == "abc"`中的`where`语句。
        where: {
            a: {$gt: 3, $lt: 10},
            b: "abc"
        },
        // `projection`表示根据查询的条件构造选择数据内容。
        projection: {
            a:1,
            b:1
        }
    })
}).then(function(data, err){
    // 其表示更新`a`的值为5的数据，设置其`b`的值为`new_string`，设置其`i`的值为`[3,2,1]`
    collection.update({
        $set: {
            b: "new_string",
            i: [3,2,1]
        }
    },{
        where: {
            a: 5
        }
    })
}).then(function(err){
    // 其表示删除`a`的值大于3、小于10并且不等于5的数据。
    collection.remove({
        where: {
            a: {$gt: 3, $lt: 10, $ne: 5}
        }
    })
})
```

## Promise及异步

在 [Getting Started](#getting-started) 章节中可以看到所有的数据操作都是通过以下方式进行的：

```javascript
firstFunc()
    .then(function(){
        secondFunc()
    }).then(function(){
        thirdFunc()
    }).then(function(){
        lastFunc()
    })
```

这种编写异步代码的方式实际上就是Promise，具体使用方式请参考 [官网](https://www.promisejs.org/) 或者文档 [JavaScript Promises: There and back again](http://www.html5rocks.com/zh/tutorials/es6/promises/)。

如果不想使用 Promise 也可以直接使用回调来进行如下改写：

```javascript
firstFunc(function(){
    secondFunc(function(){
        thirdFunc(function(){
            lastFunc();
        });
    });
});
```

LocalDB中大部分API为异步调用方式，之所以使用异步的方式，是因为底层可能会涉及到采用多种不同的存储引擎，不能保证所有的引擎都具有较快的执行速度及对应的同步接口。由于异步回调固有的缺陷，如果有底层接口需要使用异步方式时，需要一直回溯至最上层并改写为异步接口。

**因此对于可能会涉及到异步调用的接口，全部采用异步的方式。**

## 跨域数据存取技术实现

**JavaScript出于安全方面的考虑，不允许跨域调用其他页面的对象。**

目前已有的跨域方式请参考 [JavaScript跨域总结与解决办法](http://www.cnblogs.com/rainman/archive/2011/02/20/1959325.html)、[js中几种实用的跨域方法原理详解](http://www.cnblogs.com/2050/p/3191744.html)

LocalDB通过postMessage实现跨域通信，对其进行了封装，可以通过非常简单的配置来实现跨域数据存储。

假如要将www.tmall.com的数据存储在www.taobao.com的域下，则可以通过以下代码实现。

```javascript
//域tmall.com下，初始化LocalDB，并指定proxy
new LocalDB('foo',{
    proxy: "http://www.taobao.com/getProxy.html"
})
```

Proxy为 http://www.taobao.com/getProxy.html 所对应的html包含如下初始化代码：

```javascript
LocalDB.init({
    allow: "*.tmall.com",
    deny: "omg.tmall.com" //也可以设置拒绝的域名
})
```

## 如何贡献代码

1.  [Fork LocalDB](https://github.com/wh1100717/localDB/fork)
    1.  将Fork后的LocalDB项目clone到本地
    2.  命令行执行 `git branch develop-own` 来创建一个新分支
    3.  执行 `git checkout develop` 切换到新创建的分支
    4.  执行 `git remote add upstream https://github.com/wh1100717/localDB.git` 将主干库添加为远端库
    5.  执行 `git remote update` 来更新主干库上的最新代码
    6.  执行 `git fetch upstream/master` 拉取最新代码到本地
    7.  执行 `git rebase upstream/master` 进行本地代码合并
2.  项目根目录执行 `npm install` 安装项目所需要的库和工具
3.  修改源码或者测试用例
3.  执行 `grunt test` 来测试修改的内容是否能跑通所有测试用例
4.  如果测试通过，则将代码提交到remote
5.  在Github你Fork的项目中有一个pull request按钮，点击提交代码合并

## TODO

*   增加 userData driver 的封装以支持IE6/7存取数据
*   增加 window.name 的封装以支持IE6/7下跨域存取数据
*   增加 LocalDB 初始化时 options.expire 对"browser"的支持，数据可以在可以在同一个域的多个页面之间共享，但随着浏览器关闭而消失。
*   增加 LocalDB 初始化时 options.expire 对"Date()"的支持，数据可以在指定日期内一直存在。
*   sort从core/utils抽离出来形成单独的模块。

## API Reference

具体的API请参考[这里](http://localdb.emptystack.net)

## Get Involved

1.  [Fork LocalDB](https://github.com/wh1100717/localDB/fork)
    1.  将Fork后的LocalDB项目clone到本地
    2.  命令行执行 `git branch develop-own` 来创建一个新分支
    3.  执行 `git checkout develop` 切换到新创建的分支
    4.  执行 `git remote add upstream https://github.com/wh1100717/localDB.git` 将主干库添加为远端库
    5.  执行 `git remote update` 来更新主干库上的最新代码
    6.  执行 `git fetch upstream/master` 拉取最新代码到本地
    7.  执行 `git rebase upstream/master` 进行本地代码合并
2.  项目根目录执行 `npm install` 安装项目所需要的库和工具
3.  修改源码或者测试用例
3.  执行 `grunt test` 来测试修改的内容是否能跑通所有测试用例
4.  如果测试通过，则将代码提交到remote
5.  在Github你Fork的项目中有一个pull request按钮，点击提交代码合并

## Support Feature

###[Query Operators](http://docs.mongodb.org/manual/reference/operator/query/)

#####Comparison

*   [X] [$gt](http://docs.mongodb.org/manual/reference/operator/query/gt/#op._S_gt)<br>
    Matches values that are greater than the value specified in the query.
*   [X] [$gte](http://docs.mongodb.org/manual/reference/operator/query/gte/#op._S_gte)<br>
    Matches values that are greater than or equal to the value specified in the query.
*   [X] [$lt](http://docs.mongodb.org/manual/reference/operator/query/lt/#op._S_lt)<br>
    Matches values that are less than the value specified in the query.
*   [X] [$lte](http://docs.mongodb.org/manual/reference/operator/query/lte/#op._S_lte)<br>
    Matches values that are less than or equal to the value specified in the query.
*   [X] [$ne](http://docs.mongodb.org/manual/reference/operator/query/ne/#op._S_ne)<br>
    Matches all values that are not equal to the value specified in the query.
*   [X] [$in](http://docs.mongodb.org/manual/reference/operator/query/in/#op._S_in)<br>
    Matches any of the values that exist in an array specified in the query.
*   [X] [$nin](http://docs.mongodb.org/manual/reference/operator/query/nin/#op._S_nin)<br>
    Matches values that do not exist in an array specified to the query.    

#####Logical

*   [X] [$or](http://docs.mongodb.org/manual/reference/operator/query/or/#op._S_or)<br>
    Joins query clauses with a logical **OR** returns all documents that match the conditions of either clause.
*   [X] [$and](http://docs.mongodb.org/manual/reference/operator/query/and/#op._S_and)<br>
    Joins query clauses with a logical **AND** returns all documents that match the conditions of both clauses.
*   [X] [$not](http://docs.mongodb.org/manual/reference/operator/query/not/#op._S_not)<br>
    Inverts the effect of a query expression and returns documents that do not match the query expression.
*   [X] [$nor](http://docs.mongodb.org/manual/reference/operator/query/nor/#op._S_nor)<br>
    Joins query clauses with a logical **NOR** returns all documents that fail to match both clauses.

#####Element

*   [X] [$exists](http://docs.mongodb.org/manual/reference/operator/query/exists/#op._S_exists)<br>
    Matches documents that have the specified field.
*   [X] [$type](http://docs.mongodb.org/manual/reference/operator/query/type/#op._S_type)<br>
    Selects documents if a field is of the specified type.

    >Note: <br>
    >It is different from the **$type** API in MongoDB.<br>
    >It is really easy to determine the type of element in javascript.<br>
    >Support type input string: `string` | `object` | `function` | `array` | `number`

#####Evaluation

*   [X] [$mod](http://docs.mongodb.org/manual/reference/operator/query/mod/#op._S_mod)<br>
    Performs a modulo operation on the value of a field and selects documents with a specified result.
*   [X] [$regex](http://docs.mongodb.org/manual/reference/operator/query/regex/#op._S_regex)<br>
    Selects documents where values match a specified regular expression.
*   [ ] [$text](http://docs.mongodb.org/manual/reference/operator/query/text/#op._S_text)<br>
    Performs text search.
*   [ ] [$where](http://docs.mongodb.org/manual/reference/operator/query/where/#op._S_where)<br>
    Matches documents that satisfy a JavaScript expression.

#####Array

*   [X] [$all](http://docs.mongodb.org/manual/reference/operator/query/all/#op._S_all)<br>
    Matches arrays that contain all elements specified in the query.
*   [X] [$elemMatch](http://docs.mongodb.org/manual/reference/operator/query/elemMatch/#op._S_elemMatch)<br>
    Selects documents if element in the array field matches all the specified **$elemMatch** condition.
*   [X] [$size](http://docs.mongodb.org/manual/reference/operator/query/size/#op._S_size)<br>
    Selects documents if the array field is a specified size.

#####Projection Operators

*   [X] [$](http://docs.mongodb.org/manual/reference/operator/projection/positional/#proj._S_)<br>
    Projects the first element in an array that matches the query condition.
*   [X] [$elemMatch](http://docs.mongodb.org/manual/reference/operator/projection/elemMatch/#proj._S_elemMatch)<br>
    Projects only the first element from an array that matches the specified **$elemMatch** condition.
*   [ ] [$meta](http://docs.mongodb.org/manual/reference/operator/projection/meta/#proj._S_meta)<br>
    Projects the document’s score assigned during **$text** operation.
*   [ ] [$slice](http://docs.mongodb.org/manual/reference/operator/projection/slice/#proj._S_slice)<br>
    Limits the number of elements projected from an array. Supports skip and limit slices.

###[Update Operators](http://docs.mongodb.org/manual/reference/operator/update/)

#####Fields

*   [X] [$inc](http://docs.mongodb.org/manual/reference/operator/update/inc/#up._S_inc)<br>
    Increments the value of the field by the specified amount.
*   [X] [$mul](http://docs.mongodb.org/manual/reference/operator/update/mul/#up._S_mul)<br>
    Multiplies the value of the field by the specified amount.
*   [X] [$rename](http://docs.mongodb.org/manual/reference/operator/update/rename/#up._S_rename)<br>
    Renames a field.
*   [ ] [$setOnInsert](http://docs.mongodb.org/manual/reference/operator/update/setOnInsert/#up._S_setOnInsert)<br>
    Sets the value of a field upon document creation during an upsert. Has no effect on update operations that modify existing documents.
*   [X] [$set](http://docs.mongodb.org/manual/reference/operator/update/set/#up._S_set)<br>
    Sets the value of a field in a document.
*   [X] [$unset](http://docs.mongodb.org/manual/reference/operator/update/unset/#up._S_unset)<br>
    Removes the specified field from a document.
*   [X] [$min](http://docs.mongodb.org/manual/reference/operator/update/min/#up._S_min)<br>
    Only updates the field if the specified value is less than the existing field value.
*   [X] [$max](http://docs.mongodb.org/manual/reference/operator/update/max/#up._S_max)<br>
    Only updates the field if the specified value is greater than the existing field value.
*   [ ] [$currentDate](http://docs.mongodb.org/manual/reference/operator/update/currentDate/#up._S_currentDate)<br>
    Sets the value of a field to current date, either as a Date or a Timestamp.

#####Array
*   [ ] [$](http://docs.mongodb.org/manual/reference/operator/update/positional/#up._S_)<br>
    Acts as a placeholder to update the first element that matches the query condition in an update.
*   [ ] [$addToSet](http://docs.mongodb.org/manual/reference/operator/update/addToSet/#up._S_addToSet)<br>
    Adds elements to an array only if they do not already exist in the set.
*   [ ] [$pop](http://docs.mongodb.org/manual/reference/operator/update/pop/#up._S_pop)<br>
    Removes the first or last item of an array.
*   [ ] [$pullAll](http://docs.mongodb.org/manual/reference/operator/update/pullAll/#up._S_pullAll)<br>
    Removes all matching values from an array.
*   [ ] [$pull](http://docs.mongodb.org/manual/reference/operator/update/pull/#up._S_pull)<br>
    Removes all array elements that match a specified query.
*   [ ] [$pushAll](http://docs.mongodb.org/manual/reference/operator/update/pushAll/#up._S_pushAll)<br>
    Deprecated. Adds several items to an array.
*   [ ] [$push](http://docs.mongodb.org/manual/reference/operator/update/push/#up._S_push)<br>
    Adds an item to an array.

#####Modifiers
*   [ ] [$each](http://docs.mongodb.org/manual/reference/operator/update/each/#up._S_each)<br>
    Modifies the **$push** and **$addToSet** operators to append multiple items for array updates.
*   [ ] [$slice](http://docs.mongodb.org/manual/reference/operator/update/slice/#up._S_slice)<br>
    Modifies the **$push** operator to limit the size of updated arrays.
*   [ ] [$sort](http://docs.mongodb.org/manual/reference/operator/update/sort/#up._S_sort)<br>
    Modifies the **$push** operator to reorder documents stored in an array.
*   [ ] [$position](http://docs.mongodb.org/manual/reference/operator/update/position/#up._S_position)<br>
    Modifies the **$push** operator to specify the position in the array to add elements.

#####Bitwise

*   [ ] [$bit](http://docs.mongodb.org/manual/reference/operator/update/bit/#up._S_bit)<br>
    Performs bitwise **AND**, **OR**, and **XOR** updates of integer values.

#####Isolation
       
*   [ ] [$isolated](http://docs.mongodb.org/manual/reference/operator/update/isolated/#up._S_isolated)<br>
    Modifies behavior of multi-updates to increase the isolation of the operation.

[spm-image]: http://spmjs.io/badge/localdb
[spm-url]: http://spmjs.io/package/localdb
[build-image]: https://api.travis-ci.org/wh1100717/localDB.svg?branch=master
[build-url]: https://travis-ci.org/wh1100717/localDB
[coverage-image]: https://img.shields.io/coveralls/wh1100717/localDB.svg
[coverage-url]: https://coveralls.io/r/wh1100717/localDB?branch=master
[license-image]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat
[license-url]: LICENSE

[LocalDB]: https://github.com/wh1100717/localDB
[requirejs]: http://requirejs.org/
[seajs]: http://seajs.org/docs/
[SPM]: http://spmjs.io/
[bower]: http://bower.io/
[Promise]: https://www.promisejs.org/
[BSON]: http://bsonspec.org/



