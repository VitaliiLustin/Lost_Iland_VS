package units 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Log;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	
	//new ReferalRewardWindow({pID:81, desc:Locale.__e("flash:1400850022498")}).show();
	 
	public class ReferalRewardWindow extends Window
	{
		
		public var action:Object;
		
		private var items:Array = new Array();
		private var container:Sprite;
		private var takeBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		
		private var bonus:Object = {};
		
		public function ReferalRewardWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 458;
			settings['height'] = 380;
						
			settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['hasExit'] = false;
			
			super(settings);
			
			var blData:Object;
			if (settings.bonus)
				blData = settings.bonus;
			else 
				blData = App.data.blinks[App.blink].bonus;
			
			for(var _sid:* in blData){
				bonus['sid'] = _sid;
				bonus['count'] = blData[_sid];
			}
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 45, 'questBacking');
			layer.addChild(background);
		}
		
		private var background:Bitmap
		public function changePromo(pID:String):void 
		{
			settings.content = initContent(App.data.blinks[App.blink].bonus);
			
			settings['L'] = settings.content.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			drawImage();	
			contentChange();
			drawPrice();
		
			if(fader != null)
				onRefreshPosition();
				
			titleLabel.x = (settings.width - titleLabel.width) / 2;	
			_descriptionLabel.x = settings.width/2 - _descriptionLabel.width/2;
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID:sID, count:data[sID]});
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		override public function drawBody():void 
		{
			this.y += 60;
			fader.y -= 60;
			
			titleLabel.visible = false;
			
			var stars:Bitmap;
			var stars2:Bitmap;
			
			if (stars == null) {
				stars = new Bitmap(Window.textures.magicFog);
				bodyContainer.addChild(stars);
			}
			if (stars2 == null) {
				stars2 = new Bitmap(Window.textures.magicFog);
				stars2.scaleX *= -1;
				bodyContainer.addChild(stars2);
			}
			
			stars.x = (settings.width - stars.width) / 2 + 140;
			stars.y = (settings.height - stars2.height) / 2 + 10;
			
			stars2.x = (settings.width - stars2.width) / 2 + 10;
			stars2.y = (settings.height - stars.height) / 2 + 10;
			
			drawMirrowObjs('storageWoodenDec', 6, settings.width - 6, settings.height - 110);
			drawMirrowObjs('storageWoodenDec', 6, settings.width - 6, 50, false, false, false, 1, -1);
			
			var ribbon:Bitmap = new Bitmap(Window.textures.giftEvent);//Window.backingShort(settings.width + 180, 'questRibbon');//new Bitmap(Window.textures.questRibbon);
			ribbon.y = -230;
			ribbon.x = (settings.width - ribbon.width) / 2;
			bodyContainer.addChild(ribbon);
			
			var text:String = Locale.__e("flash:1406554897349");
			_descriptionLabel = drawText(text, {
				fontSize:36,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x855729
			});
			
			_descriptionLabel.y = ribbon.y + ribbon.height - _descriptionLabel.height - 50;
			
			bodyContainer.addChild(_descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			changePromo(bonus.sid);
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
		}
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 		
			var stageWidth:int = App.self.stage.stageWidth;
			var stageHeight:int = App.self.stage.stageHeight;
			
			layer.x = (stageWidth - settings.width) / 2;
			layer.y = (stageHeight - settings.height) / 2;
			
			fader.width = stageWidth;
			fader.height = stageHeight;
		}
		
		private var promoCount:int = 0;
		private var menuSprite:Sprite
		private var bttns:Array = [];
		private function drawMenu():void 
		{
			menuSprite = new Sprite();
			var X:int = 10;
						
			if (App.data.promo == null) return;
			
			bodyContainer.addChild(menuSprite);
			menuSprite.y = settings.height - 70;
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'smallBacking');
			menuSprite.addChildAt(bg, 0);
			
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}
		
		private var glowing:Bitmap;
		//private var stars:Bitmap;
		//private var stars2:Bitmap;
		//private var stars3:Bitmap;
		//private var stars4:Bitmap;
		//private var stars5:Bitmap;
		//private var stars6:Bitmap;
		private function drawImage():void {
			
			if (glowing == null)
			{
				glowing = new Bitmap(Window.textures.productionReadyBacking2);
				bodyContainer.addChildAt(glowing, 0);
			}
			
			//if (stars == null) {
				//stars = new Bitmap(Window.textures.decorStars);
				//bodyContainer.addChildAt(stars, 1);
			//}
			//if (stars2 == null) {
				//stars2 = new Bitmap(Window.textures.decorStars);
				//bodyContainer.addChildAt(stars2, 2);
			//}
			//if (stars3 == null) {
				//stars3 = new Bitmap(Window.textures.decorStars);
				//bodyContainer.addChildAt(stars3, 3);
				//stars3.scaleX = -1;
			//}
			//if (stars4 == null) {
				//stars4 = new Bitmap(Window.textures.decorStars);
				//bodyContainer.addChildAt(stars4, 4);
				//stars4.scaleX = -1;
			//}
			//
			//if (stars5 == null) {
				//stars5 = new Bitmap(Window.textures.decorStars);
				//bodyContainer.addChildAt(stars5, 5);
			//}
			//if (stars6 == null) {
				//stars6 = new Bitmap(Window.textures.decorStars);
				//bodyContainer.addChildAt(stars6, 6);
				//stars6.scaleX = -1;
			//}
			
			//stars.x = 0;
			//stars.y = 20;
			//stars2.x = 0;
			//stars2.y = stars.y + stars.height - 30;
			//
			//stars3.x = stars.x + stars.width + 120;
			//stars3.y = 20;
			//stars4.x = stars2.x + stars2.width + 120;
			//stars4.y = stars3.y + stars3.height - 30;
			//
			//stars5.x = 0;
			//stars5.y = stars2.y + stars2.height - 30;
			//stars6.x = stars5.x + stars5.width + 120;
			//stars6.y = stars5.y;
			
			glowing.alpha = 0.85;
			//glowing.scaleX = glowing.scaleY = 0.5;
			glowing.smoothing = true;
			glowing.x = (settings.width - glowing.width) / 2;
			glowing.y = -10;
			glowing.smoothing = true;
			
			
			//glowing.width = (settings.width - 100);
			//glowing.x = 50;
			axeX = settings.width / 2;
		}
		
		public override function contentChange():void 
		{
			for each(var _item:ActionItem in items)
			{
				container.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			var Xs:int = 0;
			var Ys:int = 0;
			var X:int = 0;
			
			var itemNum:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			
			container.y += 50;
			container.x = (settings.width - container.width) / 2;
		}
		
		private var cont:Sprite;
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				caption:Locale.__e('flash:1382952379737'),
				fontSize:36,
				width:186,
				height:52
			};
			
			takeBttn = new Button(bttnSettings);
			bodyContainer.addChild(takeBttn);
			
			takeBttn.x = settings.width/2 - takeBttn.width / 2;
			takeBttn.y = settings.height - takeBttn.height - 56;
			
			takeBttn.addEventListener(MouseEvent.CLICK, takeEvent);
			
			if (cont != null)
				bodyContainer.removeChild(cont);
				
			cont = new Sprite();
			
			bodyContainer.addChild(cont);
			cont.x = takeBttn.x + takeBttn.width / 2 - cont.width / 2;
			cont.y = takeBttn.y - 30;
		}
		
		private function takeEvent(e:MouseEvent):void {
			takeBttn.state = Button.DISABLED;
			
			if (settings.bonus) {
				onBlink(0);
			}else{
				Post.send( {
					ctr:	'user',
					act:	'blink',
					uID:	App.user.id,
					blink:	App.blink
				}, onBlink);
			}
		}
		public function onBlink(error:int, data:Object = null, params:Object = null):void {
			if (error) {
				close();
				return;
			}
			
			if (settings.bonus) {
				App.user.stock.addAll(settings.bonus);
				take(settings.bonus, takeBttn);
			}
			else {
				App.user.stock.addAll(App.data.blinks[App.blink].bonus);
				take(App.data.blinks[App.blink].bonus, takeBttn);
			}
			
			close();
		}
		private function take(items:Object, target:*):void {
			for(var i:String in items) {
				var item:BonusItem = new BonusItem(uint(i), items[i]);
				var point:Point = Window.localToGlobal(target);
				item.cashMove(point, App.self.windowContainer);
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:ActionItem in items)
			{
				_item = null;
			}
			
			if (takeBttn) {
				takeBttn.removeEventListener(MouseEvent.CLICK, takeEvent);
				takeBttn.dispose();
				takeBttn = null;
			}
			
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import wins.Window;

internal class ActionItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var window:*;
		
		private var preloader:Preloader = new Preloader();
		
		private var bonus:Boolean = false;
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			this.bonus = bonus;
			
			background = new Bitmap(Window.textures.referalRoundBacking);
			addChild(background);
			
			var sprite:LayerX = new LayerX();
			addChild(sprite);
			
			sprite.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].description
				}
			} 
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			//drawTitle();
			drawDescription();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 10;
			
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
		}
		
		private function addBonusLabel():void 
		{
			removeChild(background);
			background = null;
			background = Window.backing(150, 190, 55, 'shopSpecialBacking');
			addChild(background);
			
			var bonusIcon:Bitmap = new Bitmap(Window.textures.redBow);
			bonusIcon.y = -20;
			bonusIcon.x = -20;
			addChild(bonusIcon);
			
		}
		
		public function onPreviewComplete(data:Bitmap):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height) / 2 - 10;// - 20;
			
			if (bonus)
				bitmap.filters = [new GlowFilter(0xffffff, 1, 40, 40)];
		}
		
		private function drawDescription():void 
		{
			var desc:TextField = Window.drawText("x" + String(count), {
				color:0xffffff,
				borderColor:0x41332b,
				textAlign:"center",
				autoSize:"center",
				fontSize:34,
				textLeading:-6,
				multiline:true
			});
			desc.wordWrap = true;
			desc.width = background.width - 80;
			desc.y = background.height - desc.height - 10;
			desc.x = (background.width - desc.width) / 2;
			addChild(desc);
		}
		
}
