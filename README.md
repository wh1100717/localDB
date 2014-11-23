#localDB

---

![LocalDB](./icon.jpg)

[![spm package][spm-image]][spm-url]
[![Build Status][build-image]][build-url]
[![Coverage Status][coverage-image]][coverage-url]
[![MIT License][license-image]][license-url]

**LocalDB** 为开发者提供简单、易用又强大的浏览器端数据存取接口，其被设计用来为 WEB 应用、手机 H5 应用、网页游戏引擎提供浏览器端持久化存储方案。

**Under Development - Still Unstable**

## Feature

*   基于 JSON 风格文档的存储方式
*   支持基于文档的富查询方式
*   支持 seajs 模块化加载
*   支持 requirejs 模块化加载
*   支持域白名单功能，实现跨域共享数据，独特的跨域数据共享解决方案
*   独特的域数据模块化解决方案
*   对浏览器端的数据存储进行加密功能
*   高安全性(因为可以通过更改proxy来隐藏数据所存储的真实域)
*   支持sort排序
*   支持 BSON ObjectId
*   支持存储函数和正则表达式

## Documentation

*   [Getting Start](doc/gettingStart.md)
*   [API Reference](doc/apiReference.md)
*   [Support Feature](doc/supportFeature.md)
*   [TODO List](doc/todoList.md)

## License

[LocalDB](http://localdb.emptystack.net/) is licensed under the [MIT license](http://opensource.org/licenses/MIT).


[spm-image]: http://spmjs.io/badge/localdb
[spm-url]: http://spmjs.io/package/localdb
[build-image]: https://api.travis-ci.org/wh1100717/localDB.svg?branch=master
[build-url]: https://travis-ci.org/wh1100717/localDB
[coverage-image]: https://img.shields.io/coveralls/wh1100717/localDB.svg
[coverage-url]: https://coveralls.io/r/wh1100717/localDB?branch=master
[license-image]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat
[license-url]: LICENSE
