// Generated by CoffeeScript 1.8.0
define(function(require, exports, module) {
  'use strict';
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
  return module.exports = UserData;
});
