package units 
{
	import api.ExternalApi;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import ui.Cloud;
	import wins.SpeedWindow;
	public class Golden extends Tribute
	{
		public function Golden(object:Object) 
		{
			crafted = object.crafted || 0;
			object['started'] = crafted;
			trace();
			super(object);
			crafting = true;
			totalLevels = level;
			stockable = true;
			flag = false;
			if (formed && textures && crafted > App.time)
				beginAnimation();
			
			findCloudPosition();
				
			if (App.user.mode == User.GUEST) {
				App.self.setOffTimer(work);
				flag = false;
				setFlag(Cloud.TRIBUTE, guestClick );
			}
			//touchableInGuest = false;
			
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
						text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]),
						timer:true
					};
				}
				
				return {
						title:info.title,
						text:Locale.__e("flash:1382952379967")
					};
			}	
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			super.onAfterBuy(e);
			started = App.time;
			App.self.setOnTimer(work);
			crafting = true;
			beginAnimation();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			//instance = 1;
			created = App.time + App.data.storage[sid].time;
			crafted = App.time + App.data.storage[sid].time;
			//App.self.setOnTimer(build);
			//addProgressBar();
			//addEffect(Building.BUILD);
			//checkTechnoNeed();
			
			beginCraft(0, created);
			beginAnimation();
			
			tribute = false;
			hasProduct = false;
			flag = false;
		}
		
		override protected function beginCraft(fID:uint, crafted:uint):void
		{
			//return;
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			App.self.setOnTimer(work);
			//App.self.setOnTimer(production);
			//production();
			
		}
		
		override public function click():Boolean {
			
			//trace(this.mouseX, this.mouseY);
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			//if (!super.click() || this.id == 0) return false;
			
			if (!isReadyToWork()) return true;
			if (isProduct()) return true;
			
			//openProductionWindow();
			return true;
		}
		
		private var guestDone:Boolean = false;
		override public function guestClick():void 
		{
			if (guestDone) return;
			guestDone = true;
			if(App.user.addTarget({
				target:this,
				near:true,
				callback:onGuestClick,
				event:Personage.HARVEST,
				jobPosition:getContactPosition(),
				shortcut:true
			})) {
				ordered = true;
			}else {
				ordered = false;
			}
		}
		
		override public function onGuestClick():void {
			//tribute = false;
			//if (cloud != null)
			//{
				//if(cloud.parent)cloud.parent.removeChild(cloud);
				//cloud = null;
			//}
			//
			//if (_cloud)_cloud.dispose();
			//_cloud = null;
			super.onGuestClick();
		}
		
		override public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
			//flag = "hand";

			finishAnimation();
			//fireTechno(1);
		}
		
		override public function isProduct(value:int = 0):Boolean
		{
			//return;
			if (hasProduct)
			{
				var price:Object = getPrice();
						
				if (!App.user.stock.checkAll(price))	return true;  // было false
				
				// Отправляем персонажа на сбор
				storageEvent();
				
				/*App.user.addTarget( {
					target:this,
					near:true,
					callback:storageEvent,
					event:Personage.HARVEST,
					jobPosition: findJobPosition(),
					shortcut:true
				});*/
				
				ordered = false;
				
				return true; 
			}
			return false;
		}
		
		override public function isReadyToWork():Boolean
		{
			if (crafted > App.time) { 
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:crafted,
					totalTime:App.data.storage[sid].time,
					doBoost:onBoostEvent,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview
				}).show();
				return false;	
				
			}	
			return true;
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
			
			crafted = App.time + App.data.storage[sid].time;
			
			if(data.hasOwnProperty('started')){
				//this.started = data.started;
				App.self.setOnTimer(work);
				beginAnimation();
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			if (params != null) {
				if (params['guest'] != undefined) {
					App.user.friends.giveGuestBonus(App.owner.id);
				}
			}
			tribute = false;
			hasProduct = false;
			flag = false;
		}
		
		override public function work():void
		{
			//var finalTime:Number = started + App.data.storage[sid].time;
			//if (App.time >= finalTime)
			
			if (App.time >= crafted)
			{
				App.self.setOffTimer(work);
				//cloudResource(true, Stock.COINS, storageEvent);
				tribute = true;
				onProductionComplete();
			}
		}
		
		override public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, count)){// || App.user.stock.take(Stock.FANT, count)) {
				
				started = App.time - info.time;
				
				var that:Tribute = this;
				
				onProductionComplete();
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						crafted = data.crafted;
						App.ui.flashGlowing(that);
					}
					
					stopAnimation();
				});	
			}
		}
		
		override public function build():void {
			hasBuilded = true;
			App.self.setOffTimer(build);
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			started = App.time;
			
			created = App.time + App.data.storage[sid].time;
			crafted = App.time + App.data.storage[sid].time;
			
			beginCraft(0, crafted);
			
			//crafting = true;
			initAnimation();
			beginAnimation();
		}
		
		override public function set tribute(value:Boolean):void {
			_tribute = value;
			
			if (_cloud)_cloud.dispose();
				_cloud = null;
			
			if (_tribute)
			{
				cloudResource(true, Stock.EXP, isProduct);
				//App.map.mSort.addChild(_cloud);
				//_cloud.x = this.x;
				//_cloud.y = this.y;
			}
			else
			{
				if (_cloud)_cloud.dispose();
				_cloud = null;
			}
		}
		
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (animationBitmap && animationBitmap.bitmapData && animationBitmap.bitmapData.getPixel(animationBitmap.mouseX, animationBitmap.mouseY) != 0)
				return animationBitmap;
				
			return bitmap;
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
		
		override public function load():void {
			
			var curLevel:int = 1;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		override public function onLoad(data:*):void 
		{
			super.onLoad(data);
			
			initAnimation();
			//if (!hasProduct) beginAnimation();
			beginAnimation();
		}
		
		override public function findCloudPosition():void
		{
			switch(info.view) {
				case 'brazier':
						setCloudPosition(-40, -90);
					break;
				case 'smeltery':
						setCloudPosition(-40, -90);
					break;
				case 'clocktower':
						setCloudPosition(-30, -90);
					break;
				case 'woter_weel':
						setCloudPosition(-40, -70);
					break;
				default:
						setCloudPosition(0, -60);
					break;
			}
		}
	}
}