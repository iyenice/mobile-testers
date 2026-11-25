(function(){var T0=Date.now();function L(){try{var a=[].slice.call(arguments);console.log('GEOPROBE +'+((Date.now()-T0)/1000).toFixed(1)+' '+a.join(' '));}catch(e){}}
function ev(s){try{return window.__ev?window.__ev(s):'';}catch(e){return 'err:'+e.message;}}
var g=navigator.geolocation,w0=g.watchPosition,c0=g.getCurrentPosition,x0=g.clearWatch,n={};
g.watchPosition=function(ok,ko,o){var id;id=w0.call(g,function(p){n[id]=(n[id]||0)+1;var b=ev('G.ft+"/"+G.ta'),r=ok.apply(this,arguments),a=ev('G.ft+"/"+G.ta');
  if(n[id]<=8||n[id]%5==0||b===a)L('watch',id,'fix#'+n[id],'ts',p.timestamp,'now-ts',Date.now()-p.timestamp,'lat',p.coords.latitude.toFixed(6),'lon',p.coords.longitude.toFixed(6),'acc',p.coords.accuracy,'spd',p.coords.speed,'hdg',p.coords.heading,'accepted',b!==a);return r;},
  function(e){L('watch',id,'ERR',e&&e.code,e&&e.message);return ko&&ko.apply(this,arguments);},o);L('watchPosition ->',id,JSON.stringify(o));return id;};
g.clearWatch=function(id){L('clearWatch',id,'after',n[id]||0,'fixes',String(new Error().stack||'').split('\n').slice(1,4).join(' | '));return x0.call(g,id);};
g.getCurrentPosition=function(ok,ko,o){L('getCurrentPosition',JSON.stringify(o));return c0.call(g,function(p){L('current fix ts',p.timestamp,'now-ts',Date.now()-p.timestamp,'lat',p.coords.latitude.toFixed(6));return ok.apply(this,arguments);},function(e){L('current ERR',e&&e.code,e&&e.message);return ko&&ko.apply(this,arguments);},o);};
document.addEventListener('visibilitychange',function(){L('visibility',document.visibilityState);});
setInterval(function(){L('state',ev("JSON.stringify({S:!!S,tab:UI.tab,view:UI.view,st:G.status,wid:watchId,age:G.t?Date.now()-G.t:null,ft:G.ft,ta:G.ta,gsRaw:G.gsRaw,acc:G.acc,want:gpsWanted(),armed:A&&A.armed,gs:gpsState(),vis:document.visibilityState})"));},5000);
setTimeout(function(){L('seed',ev("S?'has S':(S=newState('Probe','',0),save(),go('anchor'),'seeded')"));},4000);
window.addEventListener('error',function(e){L('JSERR',e.message,e.filename,e.lineno);});})();
