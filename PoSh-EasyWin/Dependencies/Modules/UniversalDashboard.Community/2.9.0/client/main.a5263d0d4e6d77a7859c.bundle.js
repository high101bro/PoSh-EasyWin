/******/ (function(modules) { // webpackBootstrap
/******/ 	// install a JSONP callback for chunk loading
/******/ 	function webpackJsonpCallback(data) {
/******/ 		var chunkIds = data[0];
/******/ 		var moreModules = data[1];
/******/ 		var executeModules = data[2];
/******/
/******/ 		// add "moreModules" to the modules object,
/******/ 		// then flag all "chunkIds" as loaded and fire callback
/******/ 		var moduleId, chunkId, i = 0, resolves = [];
/******/ 		for(;i < chunkIds.length; i++) {
/******/ 			chunkId = chunkIds[i];
/******/ 			if(Object.prototype.hasOwnProperty.call(installedChunks, chunkId) && installedChunks[chunkId]) {
/******/ 				resolves.push(installedChunks[chunkId][0]);
/******/ 			}
/******/ 			installedChunks[chunkId] = 0;
/******/ 		}
/******/ 		for(moduleId in moreModules) {
/******/ 			if(Object.prototype.hasOwnProperty.call(moreModules, moduleId)) {
/******/ 				modules[moduleId] = moreModules[moduleId];
/******/ 			}
/******/ 		}
/******/ 		if(parentJsonpFunction) parentJsonpFunction(data);
/******/
/******/ 		while(resolves.length) {
/******/ 			resolves.shift()();
/******/ 		}
/******/
/******/ 		// add entry modules from loaded chunk to deferred list
/******/ 		deferredModules.push.apply(deferredModules, executeModules || []);
/******/
/******/ 		// run deferred modules when all chunks ready
/******/ 		return checkDeferredModules();
/******/ 	};
/******/ 	function checkDeferredModules() {
/******/ 		var result;
/******/ 		for(var i = 0; i < deferredModules.length; i++) {
/******/ 			var deferredModule = deferredModules[i];
/******/ 			var fulfilled = true;
/******/ 			for(var j = 1; j < deferredModule.length; j++) {
/******/ 				var depId = deferredModule[j];
/******/ 				if(installedChunks[depId] !== 0) fulfilled = false;
/******/ 			}
/******/ 			if(fulfilled) {
/******/ 				deferredModules.splice(i--, 1);
/******/ 				result = __webpack_require__(__webpack_require__.s = deferredModule[0]);
/******/ 			}
/******/ 		}
/******/
/******/ 		return result;
/******/ 	}
/******/
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// object to store loaded and loading chunks
/******/ 	// undefined = chunk not loaded, null = chunk preloaded/prefetched
/******/ 	// Promise = chunk loading, 0 = chunk loaded
/******/ 	var installedChunks = {
/******/ 		0: 0
/******/ 	};
/******/
/******/ 	var deferredModules = [];
/******/
/******/ 	// script path function
/******/ 	function jsonpScriptSrc(chunkId) {
/******/ 		return __webpack_require__.p + "" + ({"1":"ud-date-time","2":"ud-element","3":"ud-html","4":"ud-icon","6":"vendors~ud-date-time","7":"vendors~ud-icon"}[chunkId]||chunkId) + "." + "a5263d0d4e6d77a7859c" + ".bundle.js"
/******/ 	}
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/ 	// This file contains only the entry chunk.
/******/ 	// The chunk loading function for additional chunks
/******/ 	__webpack_require__.e = function requireEnsure(chunkId) {
/******/ 		var promises = [];
/******/
/******/
/******/ 		// JSONP chunk loading for javascript
/******/
/******/ 		var installedChunkData = installedChunks[chunkId];
/******/ 		if(installedChunkData !== 0) { // 0 means "already installed".
/******/
/******/ 			// a Promise means "currently loading".
/******/ 			if(installedChunkData) {
/******/ 				promises.push(installedChunkData[2]);
/******/ 			} else {
/******/ 				// setup Promise in chunk cache
/******/ 				var promise = new Promise(function(resolve, reject) {
/******/ 					installedChunkData = installedChunks[chunkId] = [resolve, reject];
/******/ 				});
/******/ 				promises.push(installedChunkData[2] = promise);
/******/
/******/ 				// start chunk loading
/******/ 				var script = document.createElement('script');
/******/ 				var onScriptComplete;
/******/
/******/ 				script.charset = 'utf-8';
/******/ 				script.timeout = 120;
/******/ 				if (__webpack_require__.nc) {
/******/ 					script.setAttribute("nonce", __webpack_require__.nc);
/******/ 				}
/******/ 				script.src = jsonpScriptSrc(chunkId);
/******/
/******/ 				// create error before stack unwound to get useful stacktrace later
/******/ 				var error = new Error();
/******/ 				onScriptComplete = function (event) {
/******/ 					// avoid mem leaks in IE.
/******/ 					script.onerror = script.onload = null;
/******/ 					clearTimeout(timeout);
/******/ 					var chunk = installedChunks[chunkId];
/******/ 					if(chunk !== 0) {
/******/ 						if(chunk) {
/******/ 							var errorType = event && (event.type === 'load' ? 'missing' : event.type);
/******/ 							var realSrc = event && event.target && event.target.src;
/******/ 							error.message = 'Loading chunk ' + chunkId + ' failed.\n(' + errorType + ': ' + realSrc + ')';
/******/ 							error.name = 'ChunkLoadError';
/******/ 							error.type = errorType;
/******/ 							error.request = realSrc;
/******/ 							chunk[1](error);
/******/ 						}
/******/ 						installedChunks[chunkId] = undefined;
/******/ 					}
/******/ 				};
/******/ 				var timeout = setTimeout(function(){
/******/ 					onScriptComplete({ type: 'timeout', target: script });
/******/ 				}, 120000);
/******/ 				script.onerror = script.onload = onScriptComplete;
/******/ 				document.head.appendChild(script);
/******/ 			}
/******/ 		}
/******/ 		return Promise.all(promises);
/******/ 	};
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// on error function for async loading
/******/ 	__webpack_require__.oe = function(err) { console.error(err); throw err; };
/******/
/******/ 	var jsonpArray = window["webpackJsonp"] = window["webpackJsonp"] || [];
/******/ 	var oldJsonpFunction = jsonpArray.push.bind(jsonpArray);
/******/ 	jsonpArray.push = webpackJsonpCallback;
/******/ 	jsonpArray = jsonpArray.slice();
/******/ 	for(var i = 0; i < jsonpArray.length; i++) webpackJsonpCallback(jsonpArray[i]);
/******/ 	var parentJsonpFunction = oldJsonpFunction;
/******/
/******/
/******/ 	// add entry module to deferred list
/******/ 	deferredModules.push([427,5]);
/******/ 	// run deferred modules when ready
/******/ 	return checkDeferredModules();
/******/ })
/************************************************************************/
/******/ ({

/***/ 160:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(0);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var config__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(18);
/* harmony import */ var _services_fetch_service_jsx__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(40);
/* harmony import */ var pubsub_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(20);
/* harmony import */ var pubsub_js__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(pubsub_js__WEBPACK_IMPORTED_MODULE_3__);
/* harmony import */ var _aspnet_signalr__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(119);
/* harmony import */ var _services_toaster__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(41);
/* harmony import */ var _basics_lazy_element_jsx__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(84);
/* harmony import */ var copy_to_clipboard__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(163);
/* harmony import */ var copy_to_clipboard__WEBPACK_IMPORTED_MODULE_7___default = /*#__PURE__*/__webpack_require__.n(copy_to_clipboard__WEBPACK_IMPORTED_MODULE_7__);
function _slicedToArray(arr, i) { return _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _nonIterableRest(); }

function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance"); }

function _iterableToArrayLimit(arr, i) { if (!(Symbol.iterator in Object(arr) || Object.prototype.toString.call(arr) === "[object Arguments]")) { return; } var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"] != null) _i["return"](); } finally { if (_d) throw _e; } } return _arr; }

function _arrayWithHoles(arr) { if (Array.isArray(arr)) return arr; }









var connection;

function connectWebSocket(sessionId, location, setLoading) {
  if (connection) {
    setLoading(false);
  }

  connection = new _aspnet_signalr__WEBPACK_IMPORTED_MODULE_4__[/* HubConnectionBuilder */ "a"]().withUrl(Object(config__WEBPACK_IMPORTED_MODULE_1__[/* getApiPath */ "a"])() + '/dashboardhub').configureLogging(_aspnet_signalr__WEBPACK_IMPORTED_MODULE_4__[/* LogLevel */ "b"].Information).build();
  connection.on('reload', function (data) {
    window.location.reload(true);
  });
  connection.on('setState', function (componentId, state) {
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish(componentId, {
      type: "setState",
      state: state
    });
  });
  connection.on('showToast', function (model) {
    _services_toaster__WEBPACK_IMPORTED_MODULE_5__[/* default */ "a"].show(model);
  });
  connection.on('showError', function (model) {
    _services_toaster__WEBPACK_IMPORTED_MODULE_5__[/* default */ "a"].error(model);
  });
  connection.on('hideToast', function (id) {
    _services_toaster__WEBPACK_IMPORTED_MODULE_5__[/* default */ "a"].hide(id);
  });
  connection.on('requestState', function (componentId, requestId) {
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish(componentId, {
      type: "requestState",
      requestId: requestId
    });
  });
  connection.on('removeElement', function (componentId, parentId) {
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish(componentId, {
      type: "removeElement",
      componentId: componentId,
      parentId: parentId
    });
  });
  connection.on('clearElement', function (componentId) {
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish(componentId, {
      type: "clearElement",
      componentId: componentId
    });
  });
  connection.on('syncElement', function (componentId) {
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish(componentId, {
      type: "syncElement",
      componentId: componentId
    });
  });
  connection.on('addElement', function (componentId, elements) {
    if (componentId == null) return;
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish(componentId, {
      type: "addElement",
      componentId: componentId,
      elements: elements
    });
  });
  connection.on('showModal', function (props) {
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish("modal.open", props);
  });
  connection.on('closeModal', function () {
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish("modal.close", {});
  });
  connection.on('redirect', function (url, newWindow) {
    if (newWindow) {
      window.open(url);
    } else {
      window.location.href = url;
    }
  });
  connection.on('select', function (ParameterSetName, ID, scrollToElement) {
    if (ParameterSetName == "ToTop") {
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    }

    if (ParameterSetName == "Normal") {
      document.getElementById(ID).focus();

      if (scrollToElement) {
        document.getElementById(ID).scrollIntoView();
      }
    }
  });
  connection.on('invokejavascript', function (jsscript) {
    eval(jsscript);
  });
  connection.on('clipboard', function (Data, toastOnSuccess, toastOnError) {
    var data = Data;

    try {
      var isCopyed = data !== null || data !== '' ? copy_to_clipboard__WEBPACK_IMPORTED_MODULE_7___default()(data) : false;

      if (toastOnSuccess && isCopyed) {
        _services_toaster__WEBPACK_IMPORTED_MODULE_5__[/* default */ "a"].show({
          message: 'Copied to clipboard'
        });
      }
    } catch (err) {
      if (toastOnError) {
        _services_toaster__WEBPACK_IMPORTED_MODULE_5__[/* default */ "a"].show({
          message: 'Unable to copy to clipboard'
        });
      }
    }
  });
  connection.on('write', function (message) {
    pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.publish("write", message);
  });
  connection.on('setConnectionId', function (id) {
    UniversalDashboard.connectionId = id;
    setLoading(false);
  });
  pubsub_js__WEBPACK_IMPORTED_MODULE_3___default.a.subscribe('element-event', function (e, data) {
    if (data.type === "requestStateResponse") {
      connection.invoke("requestStateResponse", data.requestId, data.state);
    }

    if (data.type === "clientEvent") {
      connection.invoke("clientEvent", data.eventId, data.eventName, data.eventData, location).catch(function (e) {
        _services_toaster__WEBPACK_IMPORTED_MODULE_5__[/* default */ "a"].show({
          message: e.message,
          icon: 'fa fa-times-circle',
          iconColor: '#FF0000'
        });
      });
    }

    if (data.type === "unregisterEvent") {
      connection.invoke("unregisterEvent", data.eventId);
    }
  });
  connection.start().then(function (x) {
    window.UniversalDashboard.webSocket = connection;
    connection.invoke("setSessionId", sessionId);
  });
}

function loadStylesheet(url) {
  var styles = document.createElement('link');
  styles.rel = 'stylesheet';
  styles.type = 'text/css';
  styles.media = 'screen';
  styles.href = url;
  document.getElementsByTagName('head')[0].appendChild(styles);
}

function loadJavascript(url, onLoad) {
  var jsElm = document.createElement("script");
  jsElm.onload = onLoad;
  jsElm.type = "application/javascript";
  jsElm.src = url;
  document.body.appendChild(jsElm);
}

function loadData(setDashboard, setLocation, history, location, setLoading) {
  Object(_services_fetch_service_jsx__WEBPACK_IMPORTED_MODULE_2__[/* fetchGet */ "b"])("/api/internal/dashboard", function (json) {
    var dashboard = json.dashboard;
    if (dashboard.stylesheets) dashboard.stylesheets.map(loadStylesheet);
    if (dashboard.scripts) dashboard.scripts.map(loadJavascript);
    connectWebSocket(json.sessionId, location, setLoading);
    UniversalDashboard.design = dashboard.design;
    setDashboard(dashboard);

    if (dashboard.geolocation) {
      getLocation(setLocation);
    }
  }, history);
}

function getLocation(setLocation) {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (position) {
      var name = "location";
      var positionJson = {
        coords: {
          accuracy: position.coords.accuracy,
          altitude: position.coords.altitude,
          altitudeAccuracy: position.coords.altitudeAccuracy,
          heading: position.coords.heading,
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          speed: position.coords.speed
        },
        timestamp: new Date(position.timestamp).toJSON()
      };
      var value = JSON.stringify(positionJson);
      value = btoa(value);
      document.cookie = name + "=" + (value || "") + "; path=/";
      setLocation(value);
    });
  }
}

function Dashboard(_ref) {
  var history = _ref.history;

  var _useState = Object(react__WEBPACK_IMPORTED_MODULE_0__["useState"])(null),
      _useState2 = _slicedToArray(_useState, 2),
      dashboard = _useState2[0],
      setDashboard = _useState2[1];

  var _useState3 = Object(react__WEBPACK_IMPORTED_MODULE_0__["useState"])(false),
      _useState4 = _slicedToArray(_useState3, 2),
      hasError = _useState4[0],
      setHasError = _useState4[1];

  var _useState5 = Object(react__WEBPACK_IMPORTED_MODULE_0__["useState"])(null),
      _useState6 = _slicedToArray(_useState5, 2),
      error = _useState6[0],
      setError = _useState6[1];

  var _useState7 = Object(react__WEBPACK_IMPORTED_MODULE_0__["useState"])(true),
      _useState8 = _slicedToArray(_useState7, 2),
      loading = _useState8[0],
      setLoading = _useState8[1];

  var _useState9 = Object(react__WEBPACK_IMPORTED_MODULE_0__["useState"])(null),
      _useState10 = _slicedToArray(_useState9, 2),
      location = _useState10[0],
      setLocation = _useState10[1];

  Object(react__WEBPACK_IMPORTED_MODULE_0__["useEffect"])(function () {
    if (dashboard) return;

    try {
      loadData(setDashboard, setLocation, history, location, setLoading);
    } catch (err) {
      setError(err);
      setHasError(true);
    }
  });

  if (hasError) {
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(react__WEBPACK_IMPORTED_MODULE_0__["Suspense"], {
      fallback: null
    }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(_basics_lazy_element_jsx__WEBPACK_IMPORTED_MODULE_6__[/* default */ "a"], {
      component: {
        type: 'error',
        message: error.message,
        location: error.stackTrace
      }
    }));
  }

  if (loading) {
    return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", null);
  }

  try {
    var component = UniversalDashboard.renderDashboard({
      dashboard: dashboard,
      history: history
    });
    var pluginComponents = UniversalDashboard.provideDashboardComponents();
    return [component, pluginComponents];
  } catch (err) {
    setError(err);
    setHasError(true);
  }

  return null;
}

/* harmony default export */ __webpack_exports__["a"] = (Dashboard);

/***/ }),

/***/ 172:
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__.p =  document.getElementsByTagName('base')[0].href;
window.baseUrl =  document.getElementsByTagName('base')[0].href.replace(window.location.origin, "").replace(/\/$/, "");;

/***/ }),

/***/ 18:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return getApiPath; });
/* unused harmony export getWsApiPath */
function getApiPath() {
  return window.baseUrl;
}
function getWsApiPath() {
  var protocol = "ws://";

  if (window.location.protocol.toLowerCase().startsWith("https")) {
    protocol = "wss://";
  }

  return protocol + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
}

/***/ }),

/***/ 40:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return fetchGet; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return fetchPost; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "d", function() { return fetchPostFormData; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return fetchDelete; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "f", function() { return fetchPut; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "e", function() { return fetchPostRaw; });
/* harmony import */ var config__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(18);

var fetchGet = function fetchGet(url, success, history) {
  fetch(Object(config__WEBPACK_IMPORTED_MODULE_0__[/* getApiPath */ "a"])() + url, {
    credentials: 'include',
    headers: {
      'UDConnectionId': UniversalDashboard.connectionId
    }
  }).then(function (response) {
    UniversalDashboard.invokeMiddleware('GET', url, history, response);

    if (response.status === 200) {
      response.text().then(function (text) {
        try {
          return JSON.parse(text);
        } catch (_unused) {
          return text;
        }
      }).then(success);
    } else {
      throw new Error(response.statusText);
    }
  }).catch(function (e) {
    console.log(e);
  });
};
var fetchPost = function fetchPost(url, data, success) {
  if (!success) {
    success = function success() {};
  }

  fetch(Object(config__WEBPACK_IMPORTED_MODULE_0__[/* getApiPath */ "a"])() + url, {
    method: 'post',
    headers: {
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'UDConnectionId': UniversalDashboard.connectionId
    },
    body: JSON.stringify(data),
    credentials: 'include'
  }).then(function (response) {
    if (response.status === 200) {
      var jsonresponse = response.json();

      if (jsonresponse == null) {
        return true;
      } else {
        return jsonresponse;
      }

      ;
    } else {
      throw new Error(response.statusText);
    }
  }).then(success).catch(function (e) {
    console.log(e);
  });
};
var fetchPostFormData = function fetchPostFormData(url, data, success) {
  if (!success) {
    success = function success() {};
  }

  fetch(Object(config__WEBPACK_IMPORTED_MODULE_0__[/* getApiPath */ "a"])() + url, {
    method: 'post',
    headers: {
      'Accept': 'application/json, text/plain, */*',
      'UDConnectionId': UniversalDashboard.connectionId //'Content-Type': 'multipart/form-data'

    },
    body: data,
    credentials: 'include'
  }).then(function (response) {
    if (response.status === 200) {
      return response.json();
    } else {
      throw new Error(response.statusText);
    }
  }).then(success).catch(function (e) {
    console.log(e);
  });
};
var fetchDelete = function fetchDelete(url, data, success) {
  if (!success) {
    success = function success() {};
  }

  fetch(Object(config__WEBPACK_IMPORTED_MODULE_0__[/* getApiPath */ "a"])() + url, {
    method: 'delete',
    headers: {
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'UDConnectionId': UniversalDashboard.connectionId
    },
    body: JSON.stringify(data),
    credentials: 'include'
  }).then(function (response) {
    if (response.status === 200) {
      return response.json();
    } else {
      throw new Error(response.statusText);
    }
  }).then(success).catch(function (e) {
    console.log(e);
  });
};
var fetchPut = function fetchPut(url, data, success) {
  if (!success) {
    success = function success() {};
  }

  fetch(Object(config__WEBPACK_IMPORTED_MODULE_0__[/* getApiPath */ "a"])() + url, {
    method: 'put',
    headers: {
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'UDConnectionId': UniversalDashboard.connectionId
    },
    body: JSON.stringify(data),
    credentials: 'include'
  }).then(function (response) {
    if (response.status === 200) {
      return response.json();
    } else {
      throw new Error(response.statusText);
    }
  }).then(success).catch(function (e) {
    console.log(e);
  });
};
var fetchPostRaw = function fetchPostRaw(url, data, success) {
  if (!success) {
    success = function success() {};
  }

  fetch(Object(config__WEBPACK_IMPORTED_MODULE_0__[/* getApiPath */ "a"])() + url, {
    method: 'post',
    headers: {
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'text/plain',
      'UDConnectionId': UniversalDashboard.connectionId
    },
    body: data,
    credentials: 'include'
  }).then(function (response) {
    if (response.status === 200) {
      return response.text();
    } else {
      throw new Error(response.statusText);
    }
  }).then(success).catch(function (e) {
    console.log(e);
  });
};

/***/ }),

/***/ 41:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(59);
/* harmony import */ var izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var izitoast_dist_css_iziToast_min_css__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(365);
/* harmony import */ var izitoast_dist_css_iziToast_min_css__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(izitoast_dist_css_iziToast_min_css__WEBPACK_IMPORTED_MODULE_1__);


var toaster = {
  show: function show(model) {
    izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0___default.a.show(model);
  },
  hide: function hide(id) {
    var toast = document.querySelector('#' + id);
    izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0___default.a.hide({}, toast);
  },
  info: function info(model) {
    izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0___default.a.info(model);
  },
  success: function success(model) {
    izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0___default.a.success(model);
  },
  warning: function warning(model) {
    izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0___default.a.warning(model);
  },
  error: function error(model) {
    izitoast_dist_js_iziToast_min_js__WEBPACK_IMPORTED_MODULE_0___default.a.error(model);
  }
};
/* harmony default export */ __webpack_exports__["a"] = (toaster);

/***/ }),

/***/ 427:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);

// EXTERNAL MODULE: ./src/app/public-path.js
var public_path = __webpack_require__(172);

// EXTERNAL MODULE: ./node_modules/@babel/polyfill/lib/index.js
var lib = __webpack_require__(173);

// EXTERNAL MODULE: ./node_modules/react/index.js
var react = __webpack_require__(0);
var react_default = /*#__PURE__*/__webpack_require__.n(react);

// EXTERNAL MODULE: ./node_modules/react-dom/index.js
var react_dom = __webpack_require__(115);

// EXTERNAL MODULE: ./node_modules/jquery/dist/jquery.js
var jquery = __webpack_require__(169);

// EXTERNAL MODULE: ./node_modules/whatwg-fetch/fetch.js
var fetch = __webpack_require__(363);

// EXTERNAL MODULE: ./node_modules/promise-polyfill/src/index.js
var src = __webpack_require__(158);

// EXTERNAL MODULE: ./src/app/services/fetch-service.jsx
var fetch_service = __webpack_require__(40);

// EXTERNAL MODULE: ./src/app/services/render-service.jsx
var render_service = __webpack_require__(66);

// EXTERNAL MODULE: ./src/app/basics/lazy-element.jsx
var lazy_element = __webpack_require__(84);

// EXTERNAL MODULE: ./node_modules/pubsub-js/src/pubsub.js
var pubsub = __webpack_require__(20);
var pubsub_default = /*#__PURE__*/__webpack_require__.n(pubsub);

// EXTERNAL MODULE: ./src/app/services/toaster.jsx
var toaster = __webpack_require__(41);

// CONCATENATED MODULE: ./src/app/services/universal-dashboard-service.jsx
function ownKeys(object, enumerableOnly) { var keys = Object.keys(object); if (Object.getOwnPropertySymbols) { var symbols = Object.getOwnPropertySymbols(object); if (enumerableOnly) symbols = symbols.filter(function (sym) { return Object.getOwnPropertyDescriptor(object, sym).enumerable; }); keys.push.apply(keys, symbols); } return keys; }

function _objectSpread(target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i] != null ? arguments[i] : {}; if (i % 2) { ownKeys(Object(source), true).forEach(function (key) { _defineProperty(target, key, source[key]); }); } else if (Object.getOwnPropertyDescriptors) { Object.defineProperties(target, Object.getOwnPropertyDescriptors(source)); } else { ownKeys(Object(source)).forEach(function (key) { Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key)); }); } } return target; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }







var UniversalDashboardService = {
  components: [],
  plugins: [],
  registerPlugin: function registerPlugin(plugin) {
    this.plugins.push(plugin);
  },
  register: function register(type, component) {
    var existingComponent = this.components.find(function (x) {
      return x.type === type;
    });
    if (!existingComponent) this.components.push({
      type: type,
      component: component
    });
  },
  renderDashboard: function renderDashboard() {
    return null;
  },
  design: false,
  get: fetch_service["b" /* fetchGet */],
  post: fetch_service["c" /* fetchPost */],
  postFormData: fetch_service["d" /* fetchPostFormData */],
  postRaw: fetch_service["e" /* fetchPostRaw */],
  put: fetch_service["f" /* fetchPut */],
  delete: fetch_service["a" /* fetchDelete */],
  subscribe: pubsub_default.a.subscribe,
  unsubscribe: pubsub_default.a.unsubscribe,
  publish: pubsub_default.a.publishSync,
  toaster: toaster["a" /* default */],
  connectionId: '',
  renderComponent: function renderComponent(component, history, dynamicallyLoaded) {
    var _this = this;

    if (component == null) return react_default.a.createElement(react_default.a.Fragment, null);

    if (component.$$typeof === Symbol.for('react.element')) {
      return component;
    }

    if (Array.isArray(component)) {
      return component.map(function (x) {
        return x.type ? _this.renderComponent(x, history) : x;
      });
    }

    var existingComponent = this.components.find(function (x) {
      return x.type === component.type;
    });

    if (existingComponent != null) {
      return react_default.a.createElement(existingComponent.component, _objectSpread({}, component, {
        key: component.id,
        history: history
      }));
    } else if (component.isPlugin && !dynamicallyLoaded) {
      return react_default.a.createElement(lazy_element["a" /* default */], {
        component: component,
        key: component.id,
        history: history
      });
    }

    return Object(render_service["b" /* internalRenderComponent */])(component, history);
  },
  provideDashboardComponents: function provideDashboardComponents(state) {
    var components = [];
    this.plugins.forEach(function (x) {
      try {
        var pluginComponents = x.provideDashboardComponents(state);

        if (pluginComponents == null) {
          return;
        }

        if (Array.isArray(pluginComponents)) {
          components = components.concat(pluginComponents);
        } else {
          components.push(pluginComponents);
        }
      } catch (_unused) {}
    });
    return components;
  },
  provideRoutes: function provideRoutes() {
    var routes = [];
    this.plugins.forEach(function (x) {
      try {
        routes = routes.concat(x.provideRoutes());
      } catch (_unused2) {}
    });
    return routes;
  },
  invokeMiddleware: function invokeMiddleware(method, url, history, response) {
    this.plugins.forEach(function (x) {
      try {
        x.invokeMiddleware(method, url, history, response);
      } catch (_unused3) {}
    });
  }
};
// EXTERNAL MODULE: ./src/app/ud-dashboard.jsx
var ud_dashboard = __webpack_require__(160);

// EXTERNAL MODULE: ./node_modules/react-router-dom/esm/react-router-dom.js
var react_router_dom = __webpack_require__(116);

// EXTERNAL MODULE: ./node_modules/react-router/esm/react-router.js + 1 modules
var react_router = __webpack_require__(45);

// EXTERNAL MODULE: ./src/app/production.jsx
var production = __webpack_require__(18);

// EXTERNAL MODULE: ./node_modules/react-spinkit/dist/index.js
var dist = __webpack_require__(164);
var dist_default = /*#__PURE__*/__webpack_require__.n(dist);

// CONCATENATED MODULE: ./src/app/App.jsx
function _typeof(obj) { if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }







var App_App =
/*#__PURE__*/
function (_React$Component) {
  _inherits(App, _React$Component);

  function App() {
    var _this;

    _classCallCheck(this, App);

    _this = _possibleConstructorReturn(this, _getPrototypeOf(App).call(this));
    _this.state = {
      loading: true,
      loadingMessage: 'Loading framework...'
    };
    return _this;
  }

  _createClass(App, [{
    key: "loadJavascript",
    value: function loadJavascript(url, onLoad) {
      var jsElm = document.createElement("script");
      jsElm.onload = onLoad;
      jsElm.type = "application/javascript";
      jsElm.src = url;
      document.body.appendChild(jsElm);
    }
  }, {
    key: "componentWillMount",
    value: function componentWillMount() {
      this.loadJavascript(Object(production["a" /* getApiPath */])() + "/api/internal/javascript/framework", function () {
        var styles = document.createElement('link');
        styles.rel = 'stylesheet';
        styles.type = 'text/css';
        styles.media = 'screen';
        styles.href = Object(production["a" /* getApiPath */])() + "/api/internal/dashboard/theme";
        document.getElementsByTagName('head')[0].appendChild(styles);
        this.setState({
          loadingMessage: "Loading plugins..."
        });
        this.loadJavascript(Object(production["a" /* getApiPath */])() + "/api/internal/javascript/plugin", function () {
          this.setState({
            loading: false
          });
        }.bind(this));
      }.bind(this));
    }
  }, {
    key: "render",
    value: function render() {
      var regex = new RegExp('^' + window.baseUrl + '(?!.*(\/login))(?!.*(\/license)).*$');

      if (this.state.loading) {
        return react_default.a.createElement("div", {
          style: {
            backgroundColor: '#FFFFFF'
          },
          className: "v-wrap"
        }, react_default.a.createElement("article", {
          className: "v-box"
        }, react_default.a.createElement(dist_default.a, {
          name: "folding-cube",
          style: {
            width: '150px',
            height: '150px',
            color: '#0689B7'
          }
        })));
      }

      var pluginRoutes = UniversalDashboard.provideRoutes();
      return react_default.a.createElement(react_router_dom["BrowserRouter"], null, react_default.a.createElement("div", {
        className: "ud-dashboard"
      }, pluginRoutes, react_default.a.createElement(react_router["d" /* Route */], {
        path: regex,
        component: ud_dashboard["a" /* default */]
      })));
    }
  }]);

  return App;
}(react_default.a.Component);


// CONCATENATED MODULE: ./src/app/index.jsx










window.react = __webpack_require__(0);
window['reactdom'] = __webpack_require__(115);
window['reactrouterdom'] = __webpack_require__(116); // To add to window

if (!window.Promise) {
  window.Promise = src["a" /* default */];
}

window.UniversalDashboard = UniversalDashboardService;

__webpack_require__(428);

Object(react_dom["render"])(react_default.a.createElement(App_App, null), document.getElementById('app'));

/***/ }),

/***/ 428:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);

// EXTERNAL MODULE: ./node_modules/react/index.js
var react = __webpack_require__(0);
var react_default = /*#__PURE__*/__webpack_require__.n(react);

// EXTERNAL MODULE: ./node_modules/react-split-pane/dist/index.esm.js + 1 modules
var index_esm = __webpack_require__(168);

// CONCATENATED MODULE: ./src/app/ud-splitpane.jsx
function _typeof(obj) { if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }




var ud_splitpane_UDSplitPane =
/*#__PURE__*/
function (_React$Component) {
  _inherits(UDSplitPane, _React$Component);

  function UDSplitPane() {
    _classCallCheck(this, UDSplitPane);

    return _possibleConstructorReturn(this, _getPrototypeOf(UDSplitPane).apply(this, arguments));
  }

  _createClass(UDSplitPane, [{
    key: "render",
    value: function render() {
      var content = this.props.content;

      if (content.length !== 2) {
        return react_default.a.createElement("div", null, "Split pane supports exactly two components.");
      }

      var children = content.map(function (x) {
        return UniversalDashboard.renderComponent(x);
      });
      return [react_default.a.createElement("style", {
        dangerouslySetInnerHTML: {
          __html: "\n            .Resizer {\n                background: #000;\n                opacity: .2;\n                z-index: 1;\n                -moz-box-sizing: border-box;\n                -webkit-box-sizing: border-box;\n                box-sizing: border-box;\n                -moz-background-clip: padding;\n                -webkit-background-clip: padding;\n                background-clip: padding-box;\n            }\n        \n             .Resizer:hover {\n                -webkit-transition: all 2s ease;\n                transition: all 2s ease;\n            }\n        \n             .Resizer.horizontal {\n                height: 11px;\n                margin: -5px 0;\n                border-top: 5px solid rgba(255, 255, 255, 0);\n                border-bottom: 5px solid rgba(255, 255, 255, 0);\n                cursor: row-resize;\n                width: 100%;\n            }\n        \n            .Resizer.horizontal:hover {\n                border-top: 5px solid rgba(0, 0, 0, 0.5);\n                border-bottom: 5px solid rgba(0, 0, 0, 0.5);\n            }\n        \n            .Resizer.vertical {\n                width: 11px;\n                margin: 0 -5px;\n                border-left: 5px solid rgba(255, 255, 255, 0);\n                border-right: 5px solid rgba(255, 255, 255, 0);\n                cursor: col-resize;\n            }\n        \n            .Resizer.vertical:hover {\n                border-left: 5px solid rgba(0, 0, 0, 0.5);\n                border-right: 5px solid rgba(0, 0, 0, 0.5);\n            }\n            .Resizer.disabled {\n              cursor: not-allowed;\n            }\n            .Resizer.disabled:hover {\n              border-color: transparent;\n            }\n            .SplitPane {\n                position: relative !important;\n                ".concat(this.props.split === 'vertical' ? 'height: 100ch !important' : '', ";\n            }\n            ")
        }
      }), react_default.a.createElement(index_esm["a" /* default */], this.props, children)];
    }
  }]);

  return UDSplitPane;
}(react_default.a.Component);


// EXTERNAL MODULE: ./node_modules/react-tooltip/dist/index.js
var dist = __webpack_require__(167);
var dist_default = /*#__PURE__*/__webpack_require__.n(dist);

// CONCATENATED MODULE: ./src/app/ud-tooltip.jsx
function ud_tooltip_typeof(obj) { if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { ud_tooltip_typeof = function _typeof(obj) { return typeof obj; }; } else { ud_tooltip_typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return ud_tooltip_typeof(obj); }

function ud_tooltip_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function ud_tooltip_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function ud_tooltip_createClass(Constructor, protoProps, staticProps) { if (protoProps) ud_tooltip_defineProperties(Constructor.prototype, protoProps); if (staticProps) ud_tooltip_defineProperties(Constructor, staticProps); return Constructor; }

function ud_tooltip_possibleConstructorReturn(self, call) { if (call && (ud_tooltip_typeof(call) === "object" || typeof call === "function")) { return call; } return ud_tooltip_assertThisInitialized(self); }

function ud_tooltip_assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function ud_tooltip_getPrototypeOf(o) { ud_tooltip_getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return ud_tooltip_getPrototypeOf(o); }

function ud_tooltip_inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) ud_tooltip_setPrototypeOf(subClass, superClass); }

function ud_tooltip_setPrototypeOf(o, p) { ud_tooltip_setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return ud_tooltip_setPrototypeOf(o, p); }




var ud_tooltip_UDTooltip =
/*#__PURE__*/
function (_React$Component) {
  ud_tooltip_inherits(UDTooltip, _React$Component);

  function UDTooltip() {
    ud_tooltip_classCallCheck(this, UDTooltip);

    return ud_tooltip_possibleConstructorReturn(this, ud_tooltip_getPrototypeOf(UDTooltip).apply(this, arguments));
  }

  ud_tooltip_createClass(UDTooltip, [{
    key: "render",
    value: function render() {
      var tooltipContent = this.props.tooltipContent;

      if (!Array.isArray(tooltipContent)) {
        tooltipContent = [tooltipContent];
      }

      var content = this.props.content;

      if (!Array.isArray(content)) {
        content = [content];
      }

      content = content.map(function (x) {
        return UniversalDashboard.renderComponent(x);
      });
      tooltipContent = tooltipContent.map(function (x) {
        if (typeof x === 'string' || x instanceof String) {
          return x;
        }

        return UniversalDashboard.renderComponent(x);
      });
      return react_default.a.createElement(react_default.a.Fragment, null, react_default.a.createElement("a", {
        "data-tip": "",
        "data-for": this.props.id,
        className: this.props.className
      }, content), react_default.a.createElement(dist_default.a, {
        id: this.props.id,
        effect: this.props.effect,
        place: this.props.place,
        type: this.props.tooltipType
      }, tooltipContent));
    }
  }]);

  return UDTooltip;
}(react_default.a.Component);


// CONCATENATED MODULE: ./src/app/component-registration.js


UniversalDashboard.register("ud-splitpane", ud_splitpane_UDSplitPane);
UniversalDashboard.register("ud-tooltip", ud_tooltip_UDTooltip);

/***/ }),

/***/ 66:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return internalRenderComponent; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return renderComponent; });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(0);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
function _extends() { _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }


var UdHtmlComponent = react__WEBPACK_IMPORTED_MODULE_0___default.a.lazy(function () {
  return __webpack_require__.e(/* import() | ud-html */ 3).then(__webpack_require__.bind(null, 429));
});
var UdDateTimeComponent = react__WEBPACK_IMPORTED_MODULE_0___default.a.lazy(function () {
  return Promise.all(/* import() | ud-date-time */[__webpack_require__.e(6), __webpack_require__.e(1)]).then(__webpack_require__.bind(null, 430));
});
var UdElementComponent = react__WEBPACK_IMPORTED_MODULE_0___default.a.lazy(function () {
  return __webpack_require__.e(/* import() | ud-element */ 2).then(__webpack_require__.bind(null, 431));
});
var UdIcon = react__WEBPACK_IMPORTED_MODULE_0___default.a.lazy(function () {
  return Promise.all(/* import() | ud-icon */[__webpack_require__.e(7), __webpack_require__.e(4)]).then(__webpack_require__.bind(null, 432));
});
function internalRenderComponent(component, history) {
  if (!component) return null;

  switch (component.type) {
    case "icon":
      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(react__WEBPACK_IMPORTED_MODULE_0__["Suspense"], {
        fallback: null
      }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(UdIcon, _extends({}, component, {
        key: component.id
      })));

    case "datetime":
      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(react__WEBPACK_IMPORTED_MODULE_0__["Suspense"], {
        fallback: null
      }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(UdDateTimeComponent, _extends({}, component, {
        key: component.id
      })));

    case "element":
      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(react__WEBPACK_IMPORTED_MODULE_0__["Suspense"], {
        fallback: null
      }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(UdElementComponent, _extends({}, component, {
        key: component.key,
        history: history
      })));

    case "rawHtml":
      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(react__WEBPACK_IMPORTED_MODULE_0__["Suspense"], {
        fallback: null
      }, react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement(UdHtmlComponent, _extends({}, component, {
        key: component.id
      })));
  }

  return null;
}
function renderComponent(component, history, dynamicallyLoaded) {
  return window.UniversalDashboard.renderComponent(component, history, dynamicallyLoaded);
}

/***/ }),

/***/ 84:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return LazyElement; });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(0);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var config__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(18);
/* harmony import */ var _services_render_service_jsx__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(66);
function _typeof(obj) { if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }





var LazyElement =
/*#__PURE__*/
function (_React$Component) {
  _inherits(LazyElement, _React$Component);

  function LazyElement() {
    var _this;

    _classCallCheck(this, LazyElement);

    _this = _possibleConstructorReturn(this, _getPrototypeOf(LazyElement).call(this));
    _this.state = {
      loading: true,
      error: ""
    };
    return _this;
  }

  _createClass(LazyElement, [{
    key: "componentWillMount",
    value: function componentWillMount() {
      var script = document.createElement('script');

      script.onload = function () {
        this.setState({
          loading: false
        });
      }.bind(this);

      script.src = Object(config__WEBPACK_IMPORTED_MODULE_1__[/* getApiPath */ "a"])() + "/" + this.props.component.assetId;
      document.head.appendChild(script);
    }
  }, {
    key: "componentDidCatch",
    value: function componentDidCatch(e) {
      this.setState({
        error: e
      });
    }
  }, {
    key: "render",
    value: function render() {
      if (this.state.loading) {
        return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("div", null);
      }

      if (this.state.error !== "") {
        return Object(_services_render_service_jsx__WEBPACK_IMPORTED_MODULE_2__[/* default */ "a"])({
          type: 'error',
          message: "There was an error rendering component of type ".concat(this.props.component.type, ". ").concat(this.state.error)
        });
      }

      var element = Object(_services_render_service_jsx__WEBPACK_IMPORTED_MODULE_2__[/* default */ "a"])(this.props.component, this.props.history, true);

      if (element == null) {
        return Object(_services_render_service_jsx__WEBPACK_IMPORTED_MODULE_2__[/* default */ "a"])({
          type: 'error',
          message: "Component not registered: ".concat(this.props.component.type)
        });
      }

      return element;
    }
  }]);

  return LazyElement;
}(react__WEBPACK_IMPORTED_MODULE_0___default.a.Component);



/***/ })

/******/ });
//# sourceMappingURL=main.a5263d0d4e6d77a7859c.bundle.map