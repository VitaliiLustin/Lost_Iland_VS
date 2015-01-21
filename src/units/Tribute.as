package units 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cloud;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import wins.BankWindow;
	import wins.BuildingConstructWindow;
	import wins.ProductionWindow;
	import wins.SimpleWindow;
	import wins.TributeWindow;
	
	public class Tribute extends Building
	{
		public var started:uint = 0;
		public var _tribute:Boolean = false;
		//private var cloud:Cloud = null;
		
		public function Tribute(object:Object) 
		{
			started = object.started || 0;
			super(object);
			
			touchableInGuest = false;
			//popupBalance.visible = false;
			
			init();
		}
		
		override public function onRemoveFromStage(e:Event):void {
			App.self.setOffTimer(left);
			App.self.setOffTimer(work);
			super.onRemoveFromStage(e);
		}
		
		public function init():void {
			
			if (level == totalLevels){
				touchableInGuest = true;
			}
			
			Load.loading(Config.getIcon('Material', App.data.storage[Stock.COINS].view), onOutLoad);
			//Если мы дома
			if (App.user.mode == User.OWNER) {
				if (started != 0) {
					App.self.setOnTimer(work);
				}
			}else { //если в гостях
				//if (info.view == 'well' && App.user.mode == User.GUEST) {
					
				//}else{
					tribute = true;
				//}
			}
			
			tip = function():Object {
				
				if (tribute){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966")
					};
				}
				
				if (level == totalLevels)
				{
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr((started + info.time) - App.time)]),
						timer:true
					};
				}
				
				return {
						title:info.title,
						text:Locale.__e("flash:1382952379967")
					};
			}	
			
			if (info.view == 'house4' || info.view == 'house5')
				setCloudPosition(30, -4);
			else
				setCloudPosition(0, -20);
		}
		
		override public function click():Boolean {
			//if (info.view == 'well' && App.user.mode == User.GUEST) {
				//return false;
			//}
			
			if (!clickable || id == 0 || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			
			App.tips.hide();
			
			if (level < totalLevels) {
				
				if (App.user.mode == User.OWNER)
				{
					// Открываем окно постройки
					new BuildingConstructWindow({
						title:info.title,
						level:Number(level),
						totalLevels:Number(totalLevels),
						devels:info.devel[level+1],
						bonus:info.bonus,
						target:this,
						upgradeCallback:upgradeEvent
					}).show();
				}
			}
			else
			{
				if (tribute)
				{
					if (App.user.mode == User.OWNER)
					{
						var price:Object = { };
						price[Stock.FANTASY] = 1;
							
						if (!App.user.stock.checkAll(price))	return false;
					}
					
					// Отправляем персонажа на сбор
					if (App.user.hero.addTarget( 
					{
						target:this,
						callback:storageEvent,
						event:Personage.HARVEST,
						jobPosition:getPosition()
					}))
					{
						ordered = true;
					}
					
				}
				else if(App.user.mode == User.OWNER)
				{
					//Открываем окно ускорения работы
					new TributeWindow( {
						title:info.title,
						target:this,
						started:started,
						time:info.time
					}).show();
				}
			}
			
			return true;
		}
		
		private function getPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:int(info.area.w / 2), y: Y };
		}
		
		public function set tribute(value:Boolean):void {
			_tribute = value;
			
			if (_tribute)
			{
				//flag = Cloud.TRIBUTE;
			}
			else
			{
				flag = false;
			}
		}
		
		public function get tribute():Boolean {
			return _tribute;
		}
		
		public function work():void
		{
			if (App.time >= started + info.time)
			{
				App.self.setOffTimer(work);
				tribute = true;
			}
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, info.skip)) {
				
				started = App.time - info.time;
				
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
			if (App.user.mode == User.OWNER) {
				
				var price:Object = { }
				price[Stock.FANTASY] = 1;
					
				if (!App.user.stock.takeAll(price))	return;
				Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			}else {
				if(App.user.friends.takeGuestEnergy(App.owner.id)){
					Post.send({
						ctr:this.type,
						act:'gueststorage',
						uID:App.owner.id,
						id:this.id,
						wID:App.owner.worldID,
						sID:this.sid,
						guest:App.user.id
					}, onStorageEvent, {guest:true});
				}else {
					Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED,  new Point(App.map.scaleX*(x + width / 2) + App.map.x, y*App.map.scaleY + App.map.y));
					App.user.onStopEvent();
					return;					
				}
			}
				
			tribute = false;
		}
		
		public function onHelperStorage(_started:uint):void {
			tribute = false;
			started = _started;
			App.self.setOnTimer(work);
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				if(params && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				return;
			}
			App.time
			//Делаем push в _6e
			//if (App.social == 'FB') {
				//ExternalApi._6epush([ "_event", { "event": "gain" } ]);
			//}
			
			ordered = false;
			
			if(data.hasOwnProperty('started')){
				//this.started = data.started;
				App.self.setOnTimer(work);
				
			//	popupBalance.visible = false;
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			
		}
		
		override public function onUpgradeEvent(error:int, data:Object, params:Object):void {
			
			if (error){
				//Возвращаем как было
				for (var id:* in params) {
					App.user.stock.data[id] = params[id];
				}
				
				this.level--;
				updateLevel();
				return;
			}
			
			hasUpgraded = false;
			upgradedTime = data.upgrade;// + info.devel.req[level].t;
			App.self.setOnTimer(upgraded);
			trace("______________onUpgradeEvent_________upgradedTime-= " + upgradedTime);
			/*if(level == totalLevels){
				new SimpleWindow( {
					title:info.title,
					label:SimpleWindow.BUILDING,
					text:Locale.__e("flash:1382952379896"),
					sID:sid,
					ok:makePost
				}).show();
				
				//Делаем push в _6e
				if (App.social == 'FB') {						
					ExternalApi._6epush([ "_event", { "event": "gain", "item": info.view } ]);
				}
			}else {*/
				//Делаем push в _6e
				//if (App.social == 'FB') {						
					//ExternalApi._6epush([ "_event", { "event": "achievement", "achievement": "building_construction" } ]);
				//}
			//}
			
			//if (data.hasOwnProperty('started')){
				//this.started = data.started;
				//App.self.setOnTimer(work);
			//}	
			
			//for (var sID:* in info.bonus[level])
			//{
				//App.user.stock.add(sID, info.bonus[level][sID]);
			//}
			
		}
		
		override public function set material(toogle:Boolean):void {
			if (countLabel == null) return;
			
			if (toogle) {
				countLabel.text = TimeConverter.timeToStr((started + info.time) - App.time);
				countLabel.x = (icon.width - countLabel.width) / 2;
			}
			//popupBalance.visible = toogle;
		}
		
		public function left():void {
			
			if((started + info.time) - App.time == 0){
				App.self.setOffTimer(left);
				material = false;
			}else {
				material = true;
			}
		}
		
		public function resizePopupBalance():void
		{
			/*var scale:Number = 1;
			switch(SystemPanel.scaleMode)
			{
				case 0:	scale = 1; 		break;
				case 1:	scale = 1.3; 	break;
				case 2:	scale = 1.6; 	break;
				case 3:	scale = 2.1; 	break;
			}
			
			var scaleX:Number = scale;
			var scaleY:Number = scale;
			
			if(rotate) scaleX = -scaleX;
			
			popupBalance.scaleY = scaleY;
			popupBalance.scaleX = scaleX;
			
			popupBalance.x = bitmap.x + (bitmap.width - icon.width * scaleX) / 2;
			if (bitmap.height < 10)
				popupBalance.y = -30 - 40*scaleY;
			else
				popupBalance.y = bitmap.height + bitmap.y - 80 - 40*scaleY;*/
		}
		
		override public function set touch(touch:Boolean):void {
			//if (info.view == 'well' && App.user.mode == User.GUEST) {
			//	return;
			//}
			
			super.touch = touch;	
			//showPopupBalance(touch);
		}
		
		public function showPopupBalance(value:Boolean):void {
			
			/*if (value) {
				if(Cursor.type == 'default' && !_tribute && App.user.mode == User.OWNER && level == totalLevels){
					timeID = setTimeout(function():void{
						material = true;
						popupBalance.alpha = 0;
						resizePopupBalance();
						anim = TweenLite.to(popupBalance, 0.2, { alpha:1 } );
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
		
		override public function remove(_callback:Function = null):void 
		{
			App.self.setOffTimer(work);
			super.remove(_callback);
		}
		
		override public function beginAnimation():void 
		{
			if(textures && textures.animation != null && !animated)
				startAnimation();
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			findCloudPosition();
		}
		
		public function findCloudPosition():void
		{
			switch(info.view) {
				case 'spring':
						//setCloudPosition(0, 30);
					break;
			}
		}	
	}	
}