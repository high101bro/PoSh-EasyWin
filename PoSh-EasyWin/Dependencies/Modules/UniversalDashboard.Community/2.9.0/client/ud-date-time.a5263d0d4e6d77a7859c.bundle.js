(window["webpackJsonp"] = window["webpackJsonp"] || []).push([[1],{

/***/ 430:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return DateTime; });
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(0);
/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var moment__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(433);
/* harmony import */ var moment__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(moment__WEBPACK_IMPORTED_MODULE_1__);
function _typeof(obj) { if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }




var DateTime =
/*#__PURE__*/
function (_React$Component) {
  _inherits(DateTime, _React$Component);

  function DateTime() {
    _classCallCheck(this, DateTime);

    return _possibleConstructorReturn(this, _getPrototypeOf(DateTime).apply(this, arguments));
  }

  _createClass(DateTime, [{
    key: "render",
    value: function render() {
      var y = this.props.value;
      var moment2 = moment__WEBPACK_IMPORTED_MODULE_1___default()(y);

      if (moment2.isValid) {
        return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", null, moment2.format(this.props.dateTimeFormat));
      }

      return react__WEBPACK_IMPORTED_MODULE_0___default.a.createElement("span", null, y);
    }
  }]);

  return DateTime;
}(react__WEBPACK_IMPORTED_MODULE_0___default.a.Component);



/***/ }),

/***/ 562:
/***/ (function(module, exports, __webpack_require__) {

var map = {
	"./af": 434,
	"./af.js": 434,
	"./ar": 435,
	"./ar-dz": 436,
	"./ar-dz.js": 436,
	"./ar-kw": 437,
	"./ar-kw.js": 437,
	"./ar-ly": 438,
	"./ar-ly.js": 438,
	"./ar-ma": 439,
	"./ar-ma.js": 439,
	"./ar-sa": 440,
	"./ar-sa.js": 440,
	"./ar-tn": 441,
	"./ar-tn.js": 441,
	"./ar.js": 435,
	"./az": 442,
	"./az.js": 442,
	"./be": 443,
	"./be.js": 443,
	"./bg": 444,
	"./bg.js": 444,
	"./bm": 445,
	"./bm.js": 445,
	"./bn": 446,
	"./bn.js": 446,
	"./bo": 447,
	"./bo.js": 447,
	"./br": 448,
	"./br.js": 448,
	"./bs": 449,
	"./bs.js": 449,
	"./ca": 450,
	"./ca.js": 450,
	"./cs": 451,
	"./cs.js": 451,
	"./cv": 452,
	"./cv.js": 452,
	"./cy": 453,
	"./cy.js": 453,
	"./da": 454,
	"./da.js": 454,
	"./de": 455,
	"./de-at": 456,
	"./de-at.js": 456,
	"./de-ch": 457,
	"./de-ch.js": 457,
	"./de.js": 455,
	"./dv": 458,
	"./dv.js": 458,
	"./el": 459,
	"./el.js": 459,
	"./en-SG": 460,
	"./en-SG.js": 460,
	"./en-au": 461,
	"./en-au.js": 461,
	"./en-ca": 462,
	"./en-ca.js": 462,
	"./en-gb": 463,
	"./en-gb.js": 463,
	"./en-ie": 464,
	"./en-ie.js": 464,
	"./en-il": 465,
	"./en-il.js": 465,
	"./en-nz": 466,
	"./en-nz.js": 466,
	"./eo": 467,
	"./eo.js": 467,
	"./es": 468,
	"./es-do": 469,
	"./es-do.js": 469,
	"./es-us": 470,
	"./es-us.js": 470,
	"./es.js": 468,
	"./et": 471,
	"./et.js": 471,
	"./eu": 472,
	"./eu.js": 472,
	"./fa": 473,
	"./fa.js": 473,
	"./fi": 474,
	"./fi.js": 474,
	"./fo": 475,
	"./fo.js": 475,
	"./fr": 476,
	"./fr-ca": 477,
	"./fr-ca.js": 477,
	"./fr-ch": 478,
	"./fr-ch.js": 478,
	"./fr.js": 476,
	"./fy": 479,
	"./fy.js": 479,
	"./ga": 480,
	"./ga.js": 480,
	"./gd": 481,
	"./gd.js": 481,
	"./gl": 482,
	"./gl.js": 482,
	"./gom-latn": 483,
	"./gom-latn.js": 483,
	"./gu": 484,
	"./gu.js": 484,
	"./he": 485,
	"./he.js": 485,
	"./hi": 486,
	"./hi.js": 486,
	"./hr": 487,
	"./hr.js": 487,
	"./hu": 488,
	"./hu.js": 488,
	"./hy-am": 489,
	"./hy-am.js": 489,
	"./id": 490,
	"./id.js": 490,
	"./is": 491,
	"./is.js": 491,
	"./it": 492,
	"./it-ch": 493,
	"./it-ch.js": 493,
	"./it.js": 492,
	"./ja": 494,
	"./ja.js": 494,
	"./jv": 495,
	"./jv.js": 495,
	"./ka": 496,
	"./ka.js": 496,
	"./kk": 497,
	"./kk.js": 497,
	"./km": 498,
	"./km.js": 498,
	"./kn": 499,
	"./kn.js": 499,
	"./ko": 500,
	"./ko.js": 500,
	"./ku": 501,
	"./ku.js": 501,
	"./ky": 502,
	"./ky.js": 502,
	"./lb": 503,
	"./lb.js": 503,
	"./lo": 504,
	"./lo.js": 504,
	"./lt": 505,
	"./lt.js": 505,
	"./lv": 506,
	"./lv.js": 506,
	"./me": 507,
	"./me.js": 507,
	"./mi": 508,
	"./mi.js": 508,
	"./mk": 509,
	"./mk.js": 509,
	"./ml": 510,
	"./ml.js": 510,
	"./mn": 511,
	"./mn.js": 511,
	"./mr": 512,
	"./mr.js": 512,
	"./ms": 513,
	"./ms-my": 514,
	"./ms-my.js": 514,
	"./ms.js": 513,
	"./mt": 515,
	"./mt.js": 515,
	"./my": 516,
	"./my.js": 516,
	"./nb": 517,
	"./nb.js": 517,
	"./ne": 518,
	"./ne.js": 518,
	"./nl": 519,
	"./nl-be": 520,
	"./nl-be.js": 520,
	"./nl.js": 519,
	"./nn": 521,
	"./nn.js": 521,
	"./pa-in": 522,
	"./pa-in.js": 522,
	"./pl": 523,
	"./pl.js": 523,
	"./pt": 524,
	"./pt-br": 525,
	"./pt-br.js": 525,
	"./pt.js": 524,
	"./ro": 526,
	"./ro.js": 526,
	"./ru": 527,
	"./ru.js": 527,
	"./sd": 528,
	"./sd.js": 528,
	"./se": 529,
	"./se.js": 529,
	"./si": 530,
	"./si.js": 530,
	"./sk": 531,
	"./sk.js": 531,
	"./sl": 532,
	"./sl.js": 532,
	"./sq": 533,
	"./sq.js": 533,
	"./sr": 534,
	"./sr-cyrl": 535,
	"./sr-cyrl.js": 535,
	"./sr.js": 534,
	"./ss": 536,
	"./ss.js": 536,
	"./sv": 537,
	"./sv.js": 537,
	"./sw": 538,
	"./sw.js": 538,
	"./ta": 539,
	"./ta.js": 539,
	"./te": 540,
	"./te.js": 540,
	"./tet": 541,
	"./tet.js": 541,
	"./tg": 542,
	"./tg.js": 542,
	"./th": 543,
	"./th.js": 543,
	"./tl-ph": 544,
	"./tl-ph.js": 544,
	"./tlh": 545,
	"./tlh.js": 545,
	"./tr": 546,
	"./tr.js": 546,
	"./tzl": 547,
	"./tzl.js": 547,
	"./tzm": 548,
	"./tzm-latn": 549,
	"./tzm-latn.js": 549,
	"./tzm.js": 548,
	"./ug-cn": 550,
	"./ug-cn.js": 550,
	"./uk": 551,
	"./uk.js": 551,
	"./ur": 552,
	"./ur.js": 552,
	"./uz": 553,
	"./uz-latn": 554,
	"./uz-latn.js": 554,
	"./uz.js": 553,
	"./vi": 555,
	"./vi.js": 555,
	"./x-pseudo": 556,
	"./x-pseudo.js": 556,
	"./yo": 557,
	"./yo.js": 557,
	"./zh-cn": 558,
	"./zh-cn.js": 558,
	"./zh-hk": 559,
	"./zh-hk.js": 559,
	"./zh-tw": 560,
	"./zh-tw.js": 560
};


function webpackContext(req) {
	var id = webpackContextResolve(req);
	return __webpack_require__(id);
}
function webpackContextResolve(req) {
	if(!__webpack_require__.o(map, req)) {
		var e = new Error("Cannot find module '" + req + "'");
		e.code = 'MODULE_NOT_FOUND';
		throw e;
	}
	return map[req];
}
webpackContext.keys = function webpackContextKeys() {
	return Object.keys(map);
};
webpackContext.resolve = webpackContextResolve;
module.exports = webpackContext;
webpackContext.id = 562;

/***/ })

}]);
//# sourceMappingURL=ud-date-time.a5263d0d4e6d77a7859c.bundle.map