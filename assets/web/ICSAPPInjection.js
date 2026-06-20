function _init() {
  var ua = navigator.userAgent;
  var isIOS = ua.indexOf("_iphone") > -1 ||
      ua.indexOf("iPhone") > -1 ||
      ua.indexOf("iPad") > -1;
  var isAndroid = ua.indexOf("_android") > -1 ||
      ua.indexOf("Android") > -1 ||
      ua.indexOf("Adr") > -1;

  function invoke(funcName, args) {
    var payload = args || {};
    if (window.flutter_inappwebview &&
        window.flutter_inappwebview.callHandler) {
      return window.flutter_inappwebview.callHandler("AppBridge", {
        action: funcName,
        payload: payload
      });
    }
    return Promise.reject("flutter_inappwebview unavailable");
  }

  window.ICSJavascriptBridge = {
    isIOS: isIOS,
    isAndroid: isAndroid,
    invoke: invoke
  };
}

_init();
