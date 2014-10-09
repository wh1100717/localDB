# Getting Start

---

## Installation

#####By Bower

```bash
$ bower install localdb
```

#####By SPM

```bash
$ spm install localdb
```

通过 bower 安装或者直接下载独立库文件的用户，可以直接在html页面中引用该js文件

```html
<!DOCTYPE html>
<html>
<head>
    <script type="text/javascript" src="localdb.js"></script>
</head>
<body>
</body>
<script type="text/javascript">
    var db = new LocalDB()
</script>
</html>
```

LocalDB 支持 [seajs](https://github.com/seajs/seajs) 作为其模块加载器，通过 SPM 安装或者直接下载 seajs 版本的库文件的用户可以利用 seajs 来加载 localDB

```html
<!DOCTYPE html>
<html>
<head>
    <script type="text/javascript" src="http://seajs.org/dist/sea.js"></script>
</head>
<body>
</body>
<script type="text/javascript">
    seajs.use('localdb-seajs.js', function(LocalDB){
        var db = new LocalDB()
    })
</script>
</html>
```

## Usage

##### 创建/获取名为`foo`的db

```javascript
var db = new LocalDB("foo")
```

##### 创建/获取该db中名为`bar`的collection

```javascript
var collection = db.collection("bar")
```

##### 插入数据

```javascript
collection.insert({
    a: 5,
    b: "abc",
    c: /hell.*ld/,
    d: {e: 4, f: "5"},
    g: function(h){return h*3},
    i: [1,2,3]
})
```

目前支持添加的数据格式为数字、字符串、正则表达式、对象、函数和数组。

##### 查询数据

```javascript
collection.find({
    where: {
        a: {$gt: 3, $lt: 10},
        b: "abc"
    },
    projection: {
        a:1,
        b:1
    }
})
```

其中`where`表示查询条件，相当于`select a,b from table where b == "abc"`中的`where`语句。`projection`表示根据查询的条件构造选择数据内容。

##### 更新数据

```javascript
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
```

其表示更新`a`的值为5的数据，设置其`b`的值为`new_string`，设置其`i`的值为`[3,2,1]`

##### 删除数据

```javascript
collection.remove({
    where: {
        a: {$gt: 3, $lt: 10, $ne: 5}
    }
})
```

其表示删除`a`的值大于3、小于10并且不等于5的数据。

更多API和用法请参考[API Reference](apiReference.md)






