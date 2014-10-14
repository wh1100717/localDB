# TODO List

---

*   [ ] 支持Promises
*   [ ] 支持域白名单功能，实现跨域共享数据
*   [ ] 存储数据简单加密功能
*   [X] insert的时候提供自增支持 - 不实现，原因在于多客户端同步可能存在问题。而如果直接用objectID，则不存在同步的时候id自增的问题。
*   [ ] 浏览器版本判断
*   [ ] 支持requireJS
*   [ ] 支持component安装
*   [ ] 提供chrome localStorage 增加存储容量的API(调用chrome接口，需要用户确认)
*   [ ] 讨论当容量已满时的行为方案
*   [ ] 支持sort排序