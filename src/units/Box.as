package units 
{
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.ContextMenu;
	import ui.Hints;
	import wins.EventWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	
	public class Box extends Unit{

		public function Box(object:Object)
		{
			layer = Map.LAYER_SORT;
			if (object.hasOwnProperty('gift'))
				gift = object.gift;
				
			super(object);
			layer = Map.LAYER_SORT;
			
			clickable 			= true;
			touchableInGuest 	= false;
			removable = false;
			
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
			
			tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};
		}
		
		override public function buyAction():void 
		{
			SoundsManager.instance.playSFX('build');
			//TODO снимаем деньги за покупку
			var money:uint = Stock.COINS;
			var count:int = info.coins;
			if (info.real > 0) {
				money = Stock.FANT;
				count = info.real;
			}
			
			var postObject:Object = {
				ctr:this.type,
				act:'buy',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}
			
			if (gift) {
				postObject['gift'] = 1;
			}
			
			if (App.user.stock.take(money, count))
			{
				Hints.buy(this);
				Post.send(postObject, onBuyAction);
				dispatchEvent(new AppEvent(AppEvent.AFTER_BUY));
			}else{
				ShopWindow.currentBuyObject.type = null;
				uninstall();
			}
		}
		
		private function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];			
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		override public function click():Boolean 
		{
			if (!super.click()) return false;
			if (!clickable || id == 0) return false;
			App.tips.hide();
			if (App.user.mode == User.OWNER)
			{
				var price:Object = { };
				price[Stock.FANTASY] = 1;
					
				if (!App.user.stock.checkAll(price))	return false;
				
				showKeyWindow();
			}
			return true;
		}
		
		private function showKeyWindow():void {
			if (info['in'] == ''){
				onOpen();
				return;
			}
			
			new EventWindow({
				target:this,
				sID:info['in'],
				need:info.count,
				description:Locale.__e('flash:1382952379888'),
				bttnCaption:Locale.__e('flash:1382952379890'),
				onWater:onOpen
			}).show();
		}
		
		private var gift:Boolean = false;
		private function onOpen():void {
			
			if (info['in'] != '') {
				if (!App.user.stock.take(info['in'], info.count)) {
					App.user.onStopEvent();
					showKeyWindow();
					return;	
				}
			}else {
				gift = true;
			}
			
			ordered = true;
			storageEvent();
			/*if(App.user.hero.addTarget( {
				target:this,
				callback:storageEvent,
				event:Personage.HARVEST,
				jobPosition:getPosition(),
				shortcut:true
			})) {
				
				ordered = true;
			}*/
		}
		
		override public function set ordered(ordered:Boolean):void {
			super.ordered = ordered;
			alpha = 1;
			var levelData:Object;
			if (ordered){
				levelData = textures.sprites[1];			
				App.ui.flashGlowing(this);
			}else {
				levelData = textures.sprites[0];			
			}	
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		public function storageEvent():void
		{
			if (App.user.mode == User.OWNER) 
			{
				var price:Object = { }
				price[Stock.FANTASY] = 1;
					
				if (!App.user.stock.takeAll(price))	return;
				Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
				
				var postObject:Object = {
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}
				
				/*if (gift) {
					postObject['gift'] = 1;
				}*/
				
				if (App.user.quests.tutorial)
					QuestsRules.quest80 = true;
				
				Post.send(postObject, onStorageEvent);
			}
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			if (data.bonus != null)
				Treasures.packageBonus(data.bonus, new Point(this.x, this.y));
					
			setTimeout(uninstall, 2000);	
		}
		
		private function getPosition():Object
		{
			var Y:int = -1;
			if (coords.z + Y <= 0)
				Y = 0;
			
			return { x:1, y: Y };
		}
	}
}