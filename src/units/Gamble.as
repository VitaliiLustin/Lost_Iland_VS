package units
{
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import ui.Cloud;
	import wins.GambleWindow;
	
	public class Gamble extends Golden
	{
		public var played:uint = 0;
		
		public function Gamble(object:Object)
		{
			played = object.played || 0;
			super(object);
		}
		
		
		
		public override function init():void {
			
			if(formed){
				if (played < App.midnight) {// Значит играли вчера
					tribute = true;
				}else{
					tribute = false;
					App.self.setOnTimer(work);
				}	
			}	
			
			//App.nextMidnight = App.time + 30;
			tip = function():Object {
				if (tribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379911")
					};
				}else{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379912", [TimeConverter.timeToStr(App.nextMidnight - App.time)]),
						timer:true
					};
				}
			}
			
			findCloudPosition();
		}
		
		override public function work():void
		{
			if (App.time > App.nextMidnight)
			{
				App.self.setOffTimer(work);
				tribute = true;
			}
		}
		
		override public function set tribute(value:Boolean):void {
			_tribute = value;
			
			if (_tribute)
			{
				flag = Cloud.HAND;
				findCloudPosition();
			}
			else
			{
				flag = false;
			}
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			super.onAfterBuy(e);
			
			tribute = true;
			
			//var frame:Object = textures.animation.animations[framesType].frames[0]
			findCloudPosition();
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			//var frame:Object = textures.animation.animations[framesType].frames[0]
			findCloudPosition();
		}
		
		override public function click():Boolean {
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			App.tips.hide();
				
			if (App.user.mode == User.OWNER) {
				
				new GambleWindow( {
					target:this,
					onPlay:playEvent
				}).show();
			}
			
			return true;
		}
		
		private var paid:uint = 0;
		private var onPlayed:Function;
		public function playEvent(paid:int, onPlayed:Function):void {
			
			this.onPlayed = onPlayed;
			this.paid = paid;
			
			if (paid == 1) {
				if (!App.user.stock.take(Stock.FANT, info.skip))
					return;
			}
			
			storageEvent();
		}
		
		override public function storageEvent(value:int = 0):void
		{
			if (App.user.mode == User.OWNER) {
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					paid:paid
				}, onStorageEvent);
				
				tribute = false;
			}
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			ordered = false;
			
			if(data.hasOwnProperty('played')){
				this.played = data.played;
			}
			
			if (onPlayed != null) onPlayed(data.bonus);
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
		}
		
		override public function findCloudPosition():void
		{
			switch(info.view) {
				case 'monkey':
						setCloudPosition(0, -130);
					break;
			}
		}
		
		
	}
}