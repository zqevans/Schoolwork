/*1368753099,173217045*/

if (self.CavalryLogger) { CavalryLogger.start_js(["LDnuR"]); }

__d("TextExpose",["Arbiter","CSS","DOMEventListener","DOMEvent","$"],function(a,b,c,d,e,f){var g=b('Arbiter'),h=b('CSS'),i=b('DOMEventListener'),j=b('DOMEvent'),k=b('$'),l={toggle:function(m,n){i.add(m,'click',function(o){new j(o).kill();h.toggleClass(k(n),'text_exposed');g.inform('reflow');},false);}};e.exports=l;});