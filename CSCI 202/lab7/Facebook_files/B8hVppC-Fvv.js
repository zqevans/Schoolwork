/*1362978281,178142497*/

if (self.CavalryLogger) { CavalryLogger.start_js(["oGZW7"]); }

__d("AdwareScaner",["AsyncSignal","URI","createArrayFrom","ge","isEmpty"],function(a,b,c,d,e,f){var g=b('AsyncSignal'),h=b('URI'),i=b('createArrayFrom'),j=b('ge'),k=b('isEmpty'),l={max_scan_count:2,scan_count:0,scan_timeout:10000,scan_depth:2,fb_domains:null,extern_src_res:[],adware_elements:[],selective_scan_elements:[],adwares_found:[],selective_scan_results:[],browser_extensions:[],extensions_found:{},init:function(m,n,o,p,q){setTimeout(l.runScan.bind(l),1000);this.fb_domains=i(m);this.adware_elements=n;this.selective_scan_elements=o;this.max_scan_count=p.max_scan_count||this.max_scan_count;this.scan_timeout=p.scan_timeout||this.scan_timeout;this.scan_depth=p.scan_depth||this.scan_depth;this.browser_extensions=q;},runScan:function(){this.scan_count++;this.checkAdwareElements(this.adware_elements);if(this.fb_domains.length>0)if(!k(this.selective_scan_elements)){this.selectiveDOMScan(this.selective_scan_elements,this.scan_depth);}else this.scanDOM();if(!k(this.browser_extensions))this.lookup_extensions(this.browser_extensions);this.pingBack(this.extern_src_res,this.adwares_found,this.selective_scan_results,this.extensions_found);if(this.scan_count<this.max_scan_count)setTimeout(l.runScan.bind(l),this.scan_timeout*this.scan_count);this.extern_src_res=[];this.adwares_found=[];},lookup_extensions:function(m){for(var n in m){var o=m[n];for(var p=0;p<o.length;p++)this.check_resource(n,o[p],function(q){l.extensions_found[q]=1;},function(q){});}},check_resource:function(m,n,o,p){var q=document.createElement('script');q.onload=function(){o(m);};q.onerror=function(){p(m);};document.body.appendChild(q);q.src=n;},selectiveDOMScan:function(m,n){for(var o in m){var p=m[o];for(var q=0;q<p.length;q++){var r={},s=j(p[q]),t=this.recursiveSelectiveDOMScan(s,0);if(t){r.adware_id=o;r.node_id=p[q];r.extern_src=t.src;r.tag_name=t.tag_name;l.selective_scan_results.push(r);break;}}}},recursiveSelectiveDOMScan:function(m,n){if(n==this.scan_depth||m==null)return null;if(m.src&&this.checkSource(m.src)){return {tag_name:m.tagName,src:m.src};}else for(var o=0;o<m.childNodes.length;o++){var p=m.childNodes[o],q=this.recursiveSelectiveDOMScan(p,n+1);if(q)return q;}return null;},scanDOM:function(){var m=document.documentElement.getElementsByTagName('*');for(var n=0;n<m.length;n++){var o=m[n];if(o.src&&this.checkSource(o.src))this.extern_src_res.push(o.src);}},checkSource:function(m){var n=new h(m);for(var o=0;o<this.fb_domains.length;o++){var p=new RegExp(this.fb_domains[o],'i');if(p.test(n.getDomain()))return false;}return true;},checkAdwareElements:function(m){for(var n in m){var o=m[n];for(var p=0;p<o.length;p++)if(j(o[p])){l.adwares_found.push(n);break;}}},pingBack:function(m,n,o,p){var q={};if(m.length)q.external_src=m;if(n.length)q.adwares_found=n;if(o.length)q.selective_scan_results=o;if(!k(p)){var r=[];for(var s in p)r.push(s);q.browser_extensions=r;}if(!k(q)){var t=JSON.stringify(q),u=new h('/si/ajax/a_crane_wanders').getQualifiedURI().toString();new g(u,{p:t}).send();}}};e.exports=l;});