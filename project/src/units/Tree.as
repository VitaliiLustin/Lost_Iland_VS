package units 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import strings.Strings;
	import ui.Cloud;
	import ui.Cursor;
	import wins.EventWindow;
	import wins.SimpleWindow;
	import wins.TreeGuestWindow;
	import wins.TreeWindow;
	import wins.Window;
	public class Tree extends Tribute
	{
		public var kicks:uint = 0;
		public var _free:Object;
		public var _paid:Object;
		public var times:uint = 1;
		
		public function Tree(object:Object)
		{
			_free = object.free || { };
			_paid = object.paid || { };
			kicks = object.kicks || 0;
			
			times = !object.times?1:object.times + 1;
			
			super(object);
			
			findCloudPosition();
		}
		
		override public function init():void {
			
			Load.loading(Config.getIcon('Material', App.data.storage[info.out].view), onOutLoad);
			
			if (App.user.mode == User.OWNER) {
				if (started == 0) flag = Cloud.WATER;
				if (started != 0){
					App.self.setOnTimer(work);
				}
			}else {
				
				if (kicks > info.count ||
					(started > 0 && App.time > started + info.time))
				{
					tribute = true;
					flag = false;
					touchableInGuest = false;
					return;
				}
				
				if (kicks > 0) {
					touchableInGuest = true;
					flag = Cloud.WATER;
					return
				}
			}
			
			tip = function():Object {
				
				if (tribute)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379959") + "\n" + Locale.__e('flash:1382952379960', [times, info.capacity]) 
					};
				}
				
				if (started > 0)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379961", [TimeConverter.timeToStr((started + info.time) - App.time)]) + "\n" + Locale.__e('flash:1382952379960', [times, info.capacity]),
						timer:true
					};
				}
				
				return {
						title:info.title,
						text:Locale.__e("flash:1382952379962") + "\n" + Locale.__e('flash:1382952379960', [times, info.capacity])
					};
			}
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			super.onAfterBuy(e);
			flag = Cloud.WATER;
		}
		
		override public function click():Boolean {
			if (!clickable) return false;
			
			if (tribute)
			{
				if (App.user.mode == User.OWNER)
				{
					var price:Object = { };
					price[Stock.FANTASY] = 1;
						
					if (!App.user.stock.checkAll(price))	return false;
					
					// Отправляем персонажа на сбор
					if(App.user.hero.addTarget( {
						target:this,
						callback:storageEvent,
						event:Personage.HARVEST,
						jobPosition:getPosition()
					})){
						ordered = true;
					}
				}
			}
			else
			{
				if (App.user.mode == User.OWNER) {
					
					if (flag == Cloud.WATER) {
						showEventWindow();
					}
					else
					{
						new TreeWindow( {
							target:this,
							started:started,
							time:info.time
						}).show();
					}
				}else{	
					if (kicks > info.count || kicks == 0){
						// Больше стучать нельзя
						
					}else{
						new TreeGuestWindow({
							target:this,
							kickEvent:kickEvent
						}).show();
					}
				}
			}
			
			return true;
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, info.skip)) {
				
				started -= info.time;
				
				var that:Tribute = this;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						started = data.started;
						App.ui.flashGlowing(that);
					}
					
				});	
			}
		}
		
		public override function storageEvent(value:int = 0):void
		{
			super.storageEvent();
			_free = { };
			_paid = { };
			kicks = 0;
			started = 0;
			App.self.setOffTimer(work);
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			
			super.onStorageEvent(error, data, params);
			times = data.times + 1;
			if (data.times == info.capacity)
			{
				App.self.setOffTimer(work);
				uninstall();
			}
			else
			{
				flag = Cloud.WATER;
			}
		}
		
		override public function set tribute(value:Boolean):void {
			_tribute = value;
			
			if (_tribute)
			{
				this.level = 1;
				flag = Cloud.HAND;
			}
			else
			{
				this.level = 0;
				flag = false;
			}
			
			if(textures != null)
				updateLevel();
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: this.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: this.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: this.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: this.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: this.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: this.filters = []; break;
			}
			_state = state;
		}
		
		override public function addAnimation():void
		{
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			animationBitmap = new Bitmap();
			addChildAt(animationBitmap, 0);
			addChildAt(bitmap, 0);
		}
		
		private function getPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:int(info.area.w / 2), y: Y };
		}
		
		
		private function showEventWindow():void {
			new EventWindow( {
				target:this,
				sID:info['in'],
				need:1,
				description:Locale.__e('flash:1382952379963'),
				onWater:onWater
			} ).show();
		}
		
		private function onWater():void 
		{
			/*if (!App.user.stock.check(info['in'], 1)) {
				App.user.onStopEvent();
				showEventWindow();
				return;	
			}*/
			
			if(App.user.hero.addTarget({
				target:this,
				callback:waterEvent,
				event:Personage.SOW,
				jobPosition:getPosition()
			})){
				ordered = true;
			}
		}
		
		public function waterEvent():void {
			
			var that:* = this;
			if (!App.user.stock.take(info['in'], 1)) {
				App.user.onStopEvent();
				showEventWindow();
				return;	
			}
			
			Post.send({
					ctr:this.type,
					act:'water',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
			}, function(error:*, data:*, params:*):void {
					
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				_free = { };
				_paid = { };
				kicks = 1;
				App.ui.flashGlowing(that, 0x00c0ff);
				started = data.started;
				App.self.setOnTimer(work);
				ordered = false;
				flag = false;
			});	
		}
		
		override public function showPopupBalance(value:Boolean):void {
			/*
			if (value) {
				if(Cursor.type == 'default' && !_tribute && App.user.mode == User.OWNER && started > 0){
					timeID = setTimeout(function():void{
						material = true;
						//popupBalance.alpha = 0;
						resizePopupBalance();
						//anim = TweenLite.to(popupBalance, 0.2, { alpha:1 } );
						App.self.setOnTimer(left);
					},400);
				}
			}else {
				clearTimeout(timeID);
				if(anim){
					anim.complete(true);
					anim.kill();
					anim = null;
				}
				material = false;
				App.self.setOffTimer(left);
			}*/
		}
		
		public function kickEvent(mID:uint, callback:Function, boost:int = 0):void {
			
			if(boost == 0){
				if (!App.user.friends.takeGuestEnergy(App.owner.id))
					return;	
				
				_free[App.owner.id] = App.user.id;
			}
			else
			{
				_paid[App.owner.id] = App.user.id;
			}	
			
			var self:* = this;
			var sendObject:Object = {
				ctr:'tree',
				act:'kick',
				uID:App.owner.id,
				wID:App.owner.worldID,
				sID:this.sid,
				id:this.id,
				guest:App.user.id,
				mID:mID
			}
		
			Post.send(sendObject,
			function(error:int, data:Object, params:Object):void {
				
				if (error) {
					
					if (error == 31) {
						uninstall();
						if(boost == 0){
							App.user.friends.addGuestEnergy(App.owner.id);
						}
						
						return;
					}
					
					Errors.show(error, data);
					return;
				}
				
				callback(Stock.FANT, App.data.storage[mID].real);
				
				if (data.hasOwnProperty("energy") && data.energy > 0)
					App.user.friends.updateOne(App.owner.id, "energy", data.energy);
					
				if (data.hasOwnProperty('bonus'))
					Treasures.bonus(data.bonus, new Point(self.x, self.y));
					
				self = null;
				
				if (boost == 0)
				{
					App.user.friends.giveGuestBonus(App.owner.id);
					//guests[App.user.id] = App.time;	
				}
					
				kicks += info.kicks[mID].c;
				if (kicks > info.count) {
					
					level = 1;
					updateLevel();
					flag = false;
					touchableInGuest = false;
				}
			});
		}
		
		public function sendInvite(fID:String):void
		{
			//Пост на стену
			//var message:String = Locale.__e("flash:1382952379964", [Config.appUrl]);
			
			var message:String = Strings.__e('Tree_makePost', [Config.appUrl]);
			
			var scale:Number = 0.8;
			var bitmapData:BitmapData = textures.sprites[1].bmp;
			
			var bmp:Bitmap = new Bitmap(bitmapData);
			bmp.scaleX = bmp.scaleY = scale;
			var bmd:BitmapData = new BitmapData(bmp.width, bmp.height);
			var cont:Sprite = new Sprite();
			cont.addChild(bmp);
			bmp.smoothing = true;
			bmd.draw(cont);
			
			var _bitmap:Bitmap = new Bitmap(Gifts.generateGiftPost(new Bitmap(bmd), -30));
			//App.self.addChild(_bitmap);
			if (_bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, _bitmap, String(fID), message, sid);
			}
			//End Пост на стену
		}
		
		public function sendKickPost(fID:String, bmp:Bitmap):void
		{
			//Пост на стену
			var message:String = Locale.__e("flash:1382952379965", [Config.appUrl]);
			var _bitmap:Bitmap = new Bitmap(Gifts.generateGiftPost(bmp));
			
			//App.self.addChild(_bitmap);
			
			if (_bitmap != null) {
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, _bitmap, String(fID), message, sid);
			}
			//End Пост на стену
		}
	}
}