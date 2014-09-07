/*1368411205,173220389*/

if (self.CavalryLogger) { CavalryLogger.start_js(["Qq3CC"]); }

__d("legacy:DynamicFriendListEducation",["DynamicFriendListEducation"],function(a,b,c,d){a.DynamicFriendListEducation=b('DynamicFriendListEducation');},3);
__d("FriendListMenu",["Event","Arbiter","AsyncRequest","CSS","DOM","HTML","Focus","Input","Keys","MenuDeprecated","Parent"],function(a,b,c,d,e,f){var g=b('Event'),h=b('Arbiter'),i=b('AsyncRequest'),j=b('CSS'),k=b('DOM'),l=b('HTML'),m=b('Focus'),n=b('Input'),o=b('Keys'),p=b('MenuDeprecated'),q=b('Parent'),r={init:function(s){p.register(s,false);var t=k.find(s,'.FriendListCreateTrigger'),u=k.find(s,'.CreateListInputItem'),v=k.find(u,'.createListInput');p.subscribe('select',function(w,x){if(x.item==t){j.addClass(s,'FriendListMenuCreate');m.set(v);}});g.listen(v,'blur',function(w){if(n.isEmpty(v))j.removeClass(s,'FriendListMenuCreate');});g.listen(v,'keydown',function(w){if(g.getKeyCode(w)==o.RETURN&&/[^\s]/.test(v.value))new i().setURI('/ajax/friends/lists/create.php').setData({name:v.value,id:s.id}).setHandler(function(){n.reset(v);j.removeClass(s,'FriendListMenuCreate');}).send();});h.subscribe('friend-list/new',function(w,x){var y=l(x.new_li).getRootNode();k.insertBefore(t,y);if(x.id===s.id){p.focusItem(y);p.inform('select',{menu:q.byClass(y,'uiMenu'),item:y});}else p.toggleItem(y);});},addToAnotherList:function(s,t){g.listen(s,'click',function(event){var u=q.byClass(s,'FlyoutFriendMenu');j.removeClass(u,'addToListsClosed');j.addClass(u,'addToListsOpen');});},goBack:function(s,t){g.listen(s,'click',function(event){var u=q.byClass(s,'FlyoutFriendMenu');j.removeClass(u,'addToListsOpen');j.addClass(u,'addToListsClosed');});}};e.exports=r;});
__d("RestrictedFriendListEducation",["Arbiter","AsyncRequest"],function(a,b,c,d,e,f){var g=b('Arbiter'),h=b('AsyncRequest'),i,j;function k(m,n){if(n.flid==i)if(m=='FriendListHovercard/add'){if(j)return;j=true;new h().setURI('/ajax/friends/lists/restricted_edu.php').setData({target:n.uid,flid:n.flid}).send();}else if(m=='RestrictedListNUX/okay')new h().setURI('/ajax/friends/lists/nux_log.php').setData(n).send();return true;}var l={init:function(m){i=m;g.subscribe(['FriendListHovercard/add','RestrictedListNUX/okay'],k);}};e.exports=l;});
__d("legacy:FriendListRestrictedEducation",["RestrictedFriendListEducation"],function(a,b,c,d){a.RestrictedFriendListEducation=b('RestrictedFriendListEducation');},3);
__d("FriendRequestDoYouKnow",["AsyncRequest","copyProperties","CSS","csx","DOM"],function(a,b,c,d,e,f){var g=b('AsyncRequest'),h=b('copyProperties'),i=b('CSS'),j=b('csx'),k=b('DOM');function l(m,n,o,p,q){this._container=m;this._id=n;this._ref=o;this._failResponse=k.find(this._container,"._9z");this._loadingIndicator=k.find(this._container,"._9-");var r=k.find(this._container,"._9_"),s=k.find(this._container,"._a0"),t=k.find(this._container,"._a1"),u=k.scry(this._container,"._a2");this._bindLink("._a3",q,r,s);this._bindLink("._a4",p,r,t);if(u.length==1)this._bindLink("._a5",'unmark_spam',t,u[0]);}h(l.prototype,{_bindLink:function(m,n,o,p){k.find(this._container,m).onclick=function(){i.hide(o);this._send(n,function(q){var r=q.payload;if(r.success){i.show(p);}else{if(r.err)k.setContent(this._failResponse,r.err);i.show(this._failResponse);}}.bind(this));}.bind(this);},_send:function(m,n){i.show(this._loadingIndicator);new g().setURI('/requests/friends/ajax/').setData({action:m,id:this._id,ref:this._ref}).setTransportErrorHandler(function(){i.hide(this._loadingIndicator);i.show(this._failResponse);}.bind(this)).setHandler(function(o){i.hide(this._loadingIndicator);if(n)n(o);}.bind(this)).send();}});e.exports=l;});
__d("RampUpPendingRequests",["copyProperties","Animation","AsyncRequest","CSS","DOM"],function(a,b,c,d,e,f){var g=b('copyProperties'),h=b('Animation'),i=b('AsyncRequest'),j=b('CSS'),k=b('DOM');function l(m,n,o,p,q){this._id=o;this._ref=p;this._useDeleteInsteadOfHide=q;this._confirmButton=m;this._hideButton=n;this._responseSection=k.find(this._confirmButton,'^.ruResponse');this._userBox=k.find(this._responseSection,'^.ruUserBox');this._hideButton.onclick=this._hide.bind(this);this._confirmButton.onclick=this._confirm.bind(this);}g(l.prototype,{_send:function(m,n){k.remove(k.find(this._responseSection,'.ruResponseButtons'));var o=k.find(this._responseSection,'.ruResponseLoading'),p=k.find(this._userBox,'.followUpQuestion'),q=k.find(this._userBox,'.followUpQuestionConfirm'),r=k.find(this._userBox,'.requestInfoContainer');if(this._useDeleteInsteadOfHide&&m==='reject'){j.hide(r);j.show(p);}else if(m==='confirm'){j.hide(r);j.show(q);}else j.show(o);var s=new i().setURI('/requests/friends/ajax/').setData({action:m,id:this._id,ref:this._ref}).setTransportErrorHandler(function(){k.remove(o);k.remove(p);j.show(k.find(this._responseSection,'.ruTransportErrorMsg'));}.bind(this));if(n)s.setHandler(n);s.send();},_hide:function(){var m=this._useDeleteInsteadOfHide?'reject':'hide';this._send(m,function(n){this._destroy();}.bind(this));},_confirm:function(){this._send('confirm',function(m){var n=m.payload;k.setContent(this._responseSection,n.success?n.button.markup:n.err);}.bind(this));},_destroy:function(){if(this._useDeleteInsteadOfHide)return;new h(this._userBox).to('opacity',0).duration(500).ondone(function(){k.remove(this._userBox);}.bind(this)).go();}});g(l,{hookUp:function(m,n,o,p,q){new l(m,n,o,p,q);}});e.exports=l;});
__d("InnerStickyArea",["Event","ContextualLayer","CSS","DataStore","DOM","LayerHideOnTransition","Locale","Parent","Style","Vector","copyProperties","cx","removeFromArray"],function(a,b,c,d,e,f){var g=b('Event'),h=b('ContextualLayer'),i=b('CSS'),j=b('DataStore'),k=b('DOM'),l=b('LayerHideOnTransition'),m=b('Locale'),n=b('Parent'),o=b('Style'),p=b('Vector'),q=b('copyProperties'),r=b('cx'),s=b('removeFromArray');function t(w){var x=n.byClass(w,'scrollable')||o.getScrollParent(w.parentNode);return x;}function u(w){var x=t(w);this.node=w;this._extracted=false;this._placeholder=k.create('div',{className:"_ptr"});v.getInstance(x).register(this);}q(u.prototype,{update:function(){if(this._extracted){p.getElementDimensions(this._placeholder).setElementWidth(this.node);p.getElementDimensions(this.node).setElementHeight(this._placeholder);}else p.getElementDimensions(this.node).setElementWidth(this.node).setElementHeight(this._placeholder);return this;},setExtracted:function(w){if(w===this._extracted)return this;if(w){this.update();k.replace(this.node,this._placeholder);}else{o.set(this.node,'height',null);o.set(this.node,'width',null);if(this._placeholder.parentNode){k.replace(this._placeholder,this.node);}else k.remove(this.node);}this._extracted=w;return this;},getInlineNode:function(){return this._extracted?this._placeholder:this.node;},isDisplayed:function(){var w=this.getInlineNode();return w.offsetWidth>0&&w.offsetHeight>0;},getStickyContainer:function(){return this._stickyContainer;},updateContainer:function(){var w=t(this.node);v.getInstance(w).register(this);}});function v(w){this.node=w;this._areas=[];this._fixTarget=null;this._fixedArea=null;this._initialized=false;this._layer=new h({permanent:true},k.create('div')).setInsertParent(this.node.parentNode).disableBehavior(l);this._listener=g.listen(w,'scroll',this.update.bind(this));i.addClass(w,"_pts");j.set(w,'StickyContainer',this);}v.getInstance=function(w){var x=j.get(w,'StickyContainer');return x||new v(w);};u.getStickyContainer=function(w){return v.getInstance(t(w));};q(v.prototype,{isDisplayed:function(){return this.node.offsetWidth>0&&this.node.offsetHeight>0;},register:function(w){if(w.getStickyContainer())w.getStickyContainer().unregister(w);w._stickyContainer=this;this._areas.push(w);this.update();return this;},unregister:function(w){s(this._areas,w);this.update();},update:function(){if(!this.isDisplayed())return this;var w=null,x=this,y=this.node.scrollTop,z;for(var aa=0;aa<this._areas.length;aa++){var ba=this._areas[aa],ca=ba.getInlineNode();if(!ba.isDisplayed())continue;if(!k.contains(this.node.parentNode,ca))continue;var da=ca.offsetTop;if(da<=y){if(z===undefined||da>z){w=ba;z=da;}}else if(w){var ea=p.getElementDimensions(w.node).y;if(da-ea<y)x=ba;break;}}if(this._fixedArea===w&&this._fixTarget===x){this._fixedArea&&this._fixedArea.update();}else{if(this._fixedArea&&this._fixedArea!==w)this._unfixArea(this._fixedArea);if(w)this._fixAreaTo(w,x);this._fixedArea=w;this._fixTarget=x;}return this;},destroy:function(){this._listener&&this._listener.remove();this._listener=null;},_fixAreaTo:function(w,x){this._layer.hide();w.setExtracted(true);if(x instanceof v){this._layer.setInsertParent(this.node.parentNode).setAlignment(m.isRTL()?'right':'left').setContext(this.node);}else this._layer.setInsertParent(this.node).setContext(x.node);this._layer.setContent(w.node).show();i.addClass(w.node,"_57kj");},_unfixArea:function(w){this._layer.hide();w.setExtracted(false);i.removeClass(w.node,"_57kj");}});e.exports=u;});