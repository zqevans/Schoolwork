/*1364176092,178142515*/

if (self.CavalryLogger) { CavalryLogger.start_js(["vxsWQ"]); }

__d("BirthdayReminder",["Animation","Event","DOM","tx"],function(a,b,c,d,e,f){var g=b('Animation'),h=b('Event'),i=b('DOM'),j=b('tx'),k={registerWallpostHandler:function(l){h.listen(l,'error',function(event,m){i.setContent(l,"There was an error submitting your post.");return false;});},registerCommentHandler:function(l,m){h.listen(l,'error',function(event,n){i.setContent(l,"There was an error submitting your comment.");return false;});h.listen(l,'success',function(event,n){i.replace(l,m);new g(m).duration(1000).checkpoint().to('backgroundColor','#FFFFFF').from('borderColor','#FFE222').to('borderColor','#FFFFFF').go();});}};e.exports=k;});