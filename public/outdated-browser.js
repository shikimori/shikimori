var outdatedUI = null;
var isBrowserUnsupported = false;
var cookieName = 'outdated-browser';

// https://gist.github.com/DaBs/89ccc2ffd1d435efdacff05248514f38
// var test = 'class ಠ_ಠ extends Array {constructor(j = "a", ...c) {const q = (({u: e}) => {return { [`s${c}`]: Symbol(j) };})({});super(j, q, ...c);}}' +
//           'new Promise((f) => {const a = function* (){return "\u{20BB7}".match(/./u)[0].length === 2 || true;};for (let vre of a()) {' +
//           'const [uw, as, he, re] = [new Set(), new WeakSet(), new Map(), new WeakMap()];break;}f(new Proxy({}, {get: (han, h) => h in han ? han[h] ' +
//           ': "42".repeat(0o10)}));}).then(bi => new ಠ_ಠ(bi.rd));';

// https://caniuse.com/?search=const
// https://caniuse.com/?search=WeakMap
// https://caniuse.com/?search=Symbol
// https://caniuse.com/?search=Arrow%20Function
// https://caniuse.com/?search=Promise
// https://caniuse.com/?search=Proxy
var test = '(() => { return Symbol("a"); })();' +
          'new Set(); new WeakSet(); new Map(); new WeakMap();' +
          'new Promise(() => {});' +
          'new Proxy({}, { get: (a, b) => "z" });';

try {
  eval(test);
} catch (e) {
  isBrowserUnsupported = true;
}

function DOMReady(a,b,c){b=document,c='addEventListener';b[c]?b[c]('DOMContentLoaded',a):window.attachEvent('onload',a)} // eslint-disable-line

DOMReady(function() {
  if (!isBrowserUnsupported) { return; }

  try {
    if (Cookies.get(cookieName)) { return; } // eslint-disable-line no-undef
    Cookies.set(cookieName, 'yes', { expires: 7 }); // eslint-disable-line no-undef
  } catch (_e) {} // eslint-disable-line no-empty

  outdatedUI = document.getElementById('outdated');

  for (var opacity = 1; opacity <= 100; opacity++) {
    setTimeout(makeFadeInFunction(opacity), opacity * 8);
  }

  outdatedUI.innerHTML = getMessage({
    'outOfDate': 'Твой браузер сильно устарел',
    'update': {
      'web': 'К сожалению сайт полноценно работать не сможет. ' +
        'Пожалуйста, либо обнови свой браузер, либо установи другой.'
    },
    'url': 'https://browser-update.org/ru/update-browser.html',
    'callToAction': 'Обновить браузер',
    'close': 'Закрыть'
  });
  startStylesAndEvents();
});

function changeOpacity(opacityValue) {
  outdatedUI.style.opacity = opacityValue / 100;
  outdatedUI.style.filter = 'alpha(opacity=' + opacityValue + ')';
}

function fadeIn(opacityValue) {
  changeOpacity(opacityValue);

  if (opacityValue === 1) {
    outdatedUI.style.display = 'table';
  }
}

function makeFadeInFunction(opacityValue) {
  return function() {
    fadeIn(opacityValue);
  };
}

function startStylesAndEvents() {
  var buttonClose = document.getElementById('buttonCloseUpdateBrowser');
  var buttonUpdate = document.getElementById('buttonUpdateBrowser');

  var COLORS = {
    salmon: '#f25648',
    white: 'white'
  };
  var backgroundColor = COLORS.salmon;
  var textColor = COLORS.white;

  // check settings attributes
  outdatedUI.style.backgroundColor = backgroundColor;
  // way too hard to put !important on IE6
  outdatedUI.style.color = textColor;
  outdatedUI.children[0].children[0].style.color = textColor;
  outdatedUI.children[0].children[1].style.color = textColor;

  // Update button is desktop only
  if (buttonUpdate) {
    buttonUpdate.style.color = textColor;
    if (buttonUpdate.style.borderColor) {
      buttonUpdate.style.borderColor = textColor;
    }

    // Override the update button color to match the background color
    buttonUpdate.onmouseover = function() {
      this.style.color = backgroundColor;
      this.style.backgroundColor = textColor;
    };

    buttonUpdate.onmouseout = function() {
      this.style.color = textColor;
      this.style.backgroundColor = backgroundColor;
    };
  }

  buttonClose.style.color = textColor;

  buttonClose.onmousedown = function() {
    outdatedUI.style.display = 'none';
    return false;
  };
}

function getMessage(messages) {
  var updateMessage = '<p>' +
    messages.update.web +
    (messages.url ? (
      '<a id="buttonUpdateBrowser" rel="nofollow" target="_blank" href="' +
      messages.url +
      '">' +
      messages.callToAction +
      '</a>'
    ) : '') +
    '</p>';

  var browserSupportMessage = messages.outOfDate;

  return (
    '<div class="vertical-center"><h6>' +
    browserSupportMessage +
    '</h6>' +
    updateMessage +
    '<p class="last"><a href="#" id="buttonCloseUpdateBrowser" title="' +
    messages.close +
    '">&times;</a></p></div>'
  );
}

/*! js-cookie v3.0.0-rc.1 | MIT */
!function(e,t){"object"==typeof exports&&"undefined"!=typeof module?module.exports=t():"function"==typeof define&&define.amd?define(t):(e=e||self,function(){var n=e.Cookies,r=e.Cookies=t();r.noConflict=function(){return e.Cookies=n,r}}())}(this,function(){"use strict";function e(e){for(var t=1;t<arguments.length;t++){var n=arguments[t];for(var r in n)e[r]=n[r]}return e}var t={read:function(e){return e.replace(/(%[\dA-F]{2})+/gi,decodeURIComponent)},write:function(e){return encodeURIComponent(e).replace(/%(2[346BF]|3[AC-F]|40|5[BDE]|60|7[BCD])/g,decodeURIComponent)}};return function n(r,o){function i(t,n,i){if("undefined"!=typeof document){"number"==typeof(i=e({},o,i)).expires&&(i.expires=new Date(Date.now()+864e5*i.expires)),i.expires&&(i.expires=i.expires.toUTCString()),t=encodeURIComponent(t).replace(/%(2[346B]|5E|60|7C)/g,decodeURIComponent).replace(/[()]/g,escape),n=r.write(n,t);var c="";for(var u in i)i[u]&&(c+="; "+u,!0!==i[u]&&(c+="="+i[u].split(";")[0]));return document.cookie=t+"="+n+c}}return Object.create({set:i,get:function(e){if("undefined"!=typeof document&&(!arguments.length||e)){for(var n=document.cookie?document.cookie.split("; "):[],o={},i=0;i<n.length;i++){var c=n[i].split("="),u=c.slice(1).join("=");'"'===u[0]&&(u=u.slice(1,-1));try{var f=t.read(c[0]);if(o[f]=r.read(u,f),e===f)break}catch(e){}}return e?o[e]:o}},remove:function(t,n){i(t,"",e({},n,{expires:-1}))},withAttributes:function(t){return n(this.converter,e({},this.attributes,t))},withConverter:function(t){return n(e({},this.converter,t),this.attributes)}},{attributes:{value:Object.freeze(o)},converter:{value:Object.freeze(r)}})}(t,{path:"/"})}); // eslint-disable-line
