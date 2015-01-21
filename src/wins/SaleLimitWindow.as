package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Hut;

	public class SaleLimitWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		
		public static const MODE_TIME:int = 1;
		public static const MODE_COUNT:int = 2;
		private var mode:int;
		
		public function SaleLimitWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 445;
			settings['height'] = 433;
						
			settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			

			super(settings);
			
			if (App.data.actions[settings.pID].rate != "") 
				mode = MODE_COUNT;
			else
				mode = MODE_TIME;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 45, 'questBacking');
			layer.addChild(background);
		}
		
		private var background:Bitmap
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			action = App.data.actions[pID];
			action.id = pID;

			settings.content = initContent(action.items);  // поменять как на серваке будет готово
			
			settings['L'] = settings.content.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			drawImage();	
			contentChange();
			drawPrice();
			drawTime();
			
			App.self.setOnTimer(updateDuration);
			
			if(fader != null)
				onRefreshPosition();
				
			titleLabel.x = (settings.width - titleLabel.width) / 2;	
			//_descriptionLabel.x = settings.width/2 - _descriptionLabel.width/2;
			exit.y -= 20;
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data)
				result.push({sID:sID, count:data[sID], order:action.iorder[sID]});
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		override public function drawBody():void 
		{
			titleLabel.y -= 10;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -50, true, true);
			drawMirrowObjs('storageWoodenDec', 2, settings.width, settings.height - 113);
			drawMirrowObjs('storageWoodenDec', 2, settings.width, 37, false, false, false, 1, -1);
			
			ribbon = backingShort(625, 'questRibbon');
			ribbon.y = -10;
			ribbon.x = (settings.width - ribbon.width) / 2;
			bodyContainer.addChild(ribbon);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			drawMenu();
			changePromo(settings['pID']);
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			
			drawDescription();
			drawTitleText();
			
		}
		
		private function drawTitleText():void {
			var titleCont:Sprite = new Sprite();
			var title:TextField = Window.drawText(String(App.data.storage[action.sid].title), {
				color:0xffffff,
				borderColor:0x8140a7,
				textAlign:"center",
				autoSize:"center",
				fontSize:38
			});
			title.width = title.textWidth + 20;
			title.x = ribbon.x + (ribbon.width - title.width)/2;
			title.y = 0;
			titleCont.addChild(title);
			titleCont.filters = [new GlowFilter(0xa166c4, 1, 4, 4, 2, 1)];
			bodyContainer.addChild(titleCont);
		}
		
		private function drawDescription():void 
		{
			var desc:TextField = Window.drawText(App.data.storage[action.sid].description, {//App.data.storage[sID].title  поменять
				color:0xffffff,
				borderColor:0x76481a,
				textAlign:"center",
				autoSize:"center",
				fontSize:26,
				textLeading: -6,
				wrap:true,
				multiline:true
			});
			desc.wordWrap = true;
			desc.width = settings.width - 80;
			desc.y = 225;
			desc.x = (settings.width - desc.width) / 2;
			bodyContainer.addChild(desc);
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
		private function drawMenu():void {
			
			menuSprite = new Sprite();
			var X:int = 10;
						
			if (App.data.promo == null) return;
			
			for (var pID:* in App.user.promo) {
				
				var promo:Object = App.data.promo[pID];	
				
				if (App.user.promo[pID].status)	continue;
				if (App.time > App.user.promo[pID].started + promo.duration * 3600)	continue
					
				promoCount++;
				var bttn:ActionItem = new ActionItem(pID, this);
				menuSprite.addChild(bttn);
				bttns.push(bttn);
				bttn.y = 0;
				bttn.x = X;
				
				//if (App.user.promo[pID].hasOwnProperty('new')) 
				//{
					//if(App.time < App.user.promo[pID]['new'] + 2*3600)
						//bttn._new = true;
					//
					//if(App.time < App.user.promo[pID]['new'] + 5*60)
						//bttn.showGlowing();
				//}
				X += 70;
			}
			
			bodyContainer.addChild(menuSprite);
			menuSprite.y = settings.height - 70;
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'smallBacking');
			menuSprite.addChildAt(bg, 0);
			
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}
		
		private var stars:Bitmap;
		private var stars2:Bitmap;
		private var starBack:Bitmap;
		
		private function drawImage():void {
			if(action.image != null && action.image != " " && action.image != ""){
				Load.loading(Config.getImage('promo/images', action.image), function(data:Bitmap):void {
					
					var image:Bitmap = new Bitmap(data.bitmapData);
					bodyContainer.addChildAt(image, 0);
					image.x = 20;
					image.y = 185;
					if (action.image == 'bigPanda') {
						image.x = -200;
						image.y = -20;
						//this.x += 100;
					}
				});
			}else{
				axeX = settings.width / 2;
			}
			
			if (stars == null) {
				stars = new Bitmap(Window.textures.magicFog);
				bodyContainer.addChildAt(stars,1);
			}
			if (stars2 == null) {
				stars2 = new Bitmap(Window.textures.magicFog);
				bodyContainer.addChildAt(stars2,2);
			}
			if (starBack == null) {
				starBack = new Bitmap(Window.textures.productionReadyBacking2);
				bodyContainer.addChildAt(starBack,0);
			}
			
			stars.x = (settings.width - stars.width) / 2 + 125;
			stars.y = (settings.height - stars2.height) / 2;
			
			stars2.scaleX *= -1;
			stars2.x = 175;
			stars2.y = (settings.height - stars.height) / 2;
			
			starBack.x = 25;
			starBack.y = settings.height / 2 - starBack.height/ 2 - 70;
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
			//for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var item:ActionItem = new ActionItem(settings.content[i], this);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			
			container.y += 10;
			container.x = (settings.width - item.background.width*settings.content.length) / 2;
		}
		
		private var timerContainer:Sprite;
		public function drawTime():void {
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			var background:Bitmap;
			if (mode == 2) {
				background = Window.backing(145,60,10, "timerBacking");
			}else {
				background = Window.backing(200,60,10, "timerBacking");
			}
			
			timerContainer.addChild(background);
			background.x =  - background.width/2;
			background.y = settings.height - background.height - 80;
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"left",
				color:0xffffff,
				borderColor:0x5a2910
			});
			descriptionLabel.x =  background.x + (background.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = background.y - descriptionLabel.textHeight / 2;
			timerContainer.addChild(descriptionLabel);
			
			
			if (mode == 2) {
				//var allTimePercent:int = App.time/(action.time + action.duration * 60 * 60)*100;
				var spendTime:int = (action.time - App.time)/-3600;
				var allTimePercent:int = ((action.time + action.duration * 60 * 60) / App.time) * 100 - ((action.time + action.duration * 60 * 60) / App.time) * spendTime;
				var rate:int = action.rate;
				var count:int = allTimePercent * rate;
				timerText = Window.drawText(String(count), {
					color:0xffd950,
					letterSpacing:3,
					textAlign:"center",
					fontSize:42,
					borderColor:0x43180a
				});
			}else {
				var time:int = action.duration * 60 * 60 - (App.time - action.time);
				timerText = Window.drawText(TimeConverter.timeToStr(time), {
					color:0xf8d74c,
					letterSpacing:3,
					textAlign:"center",
					fontSize:34,
					borderColor:0x502f06
				});
			}
			
			trace();
			timerText.width = 200;
			timerText.x = background.x + (background.width - timerText.width) / 2;	
			timerText.y = background.y + (background.height - timerText.height) / 2 + 10;
			timerContainer.addChild(timerText);
			
			bodyContainer.addChild(timerContainer);
			timerContainer.x = axeX;
		}
		
		private var cont:Sprite;
		private var ribbon:Bitmap;
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52,
				hasDotes:false
			};
			
			var text:String;
			switch(App.self.flashVars.social) {
				
				case "VK":
				case "DM":
						text = 'flash:1382952379972';
					break;
				case "OK":
						text = '%d ОК';
						//bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						//bttnSettings['fontColor'] = 0x3f2a1a;
						//bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;	
				case "ML":
						text = '[%d мэйлик|%d мэйлика|%d мэйликов]';
						//bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						//bttnSettings['fontColor'] = 0x3f2a1a;
						//bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
				case "PL":
				case "YB":
						text = '%d';	
						//bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						//bttnSettings['fontColor'] = 0x3f2a1a;
						//bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
				case "FB":
						var price:Number = action.price[App.self.flashVars.social];
						price = price * App.network.currency.usd_exchange_inverse;
						price = int(price * 100) / 100;
						text = price + ' ' + App.network.currency.user_currency;	
						
						//bttnSettings['borderColor'] = [0xffca8a, 0xc4690b];
						//bttnSettings['fontColor'] = 0x3f2a1a;
						//bttnSettings['bgColor'] = [0xfcbf1b, 0xe77402];//[0xff8c19, 0xe77402];
					break;
			}
			
			if (priceBttn != null)
				bodyContainer.removeChild(priceBttn);
				
			bttnSettings['caption'] = Locale.__e(text, [action.price[App.self.flashVars.social]])
			//bttnSettings['caption'] = "test";
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			
			priceBttn.x = axeX - priceBttn.width / 2;
			priceBttn.y = settings.height - priceBttn.height / 2 - 50;//135;
			
			priceBttn.addEventListener(MouseEvent.CLICK, buyEvent);
			
			if (cont != null)
				bodyContainer.removeChild(cont);
				
			cont = new Sprite();
			
			bodyContainer.addChild(cont);
			cont.x = priceBttn.x + priceBttn.width / 2 - cont.width / 2;
			cont.y = priceBttn.y - 30;
		}
		
		private function buyEvent(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			//descriptionLabel.visible = false;
			//timerText.visible = false;
			switch(App.social) {
				case 'PL':
					//if(!App.user.stock.check(Stock.FANT, action.price[App.social])){
						//close();
						
						//break;
					//}
				case 'YB':
					if(App.user.stock.take(Stock.FANT, action.price[App.social])){
						Post.send({
							ctr:'Promo',
							act:'buy',
							uID:App.user.id,
							pID:action.id,
							ext:App.social
						},function(error:*, data:*, params:*):void {
							onBuyComplete();
						});
					}else {
						close();
					}
					break;
				default:
					var object:Object;
					if (App.social == 'FB') {
						ExternalApi.apiNormalScreenEvent();
						object = {
							id:		 		action.id,
							type:			'promo',
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback:		onBuyComplete
						};
					}else{
						object = {
							count:			1,
							money:			'promo',
							type:			'item',
							item:			'promo_'+action.id,
							votes:			action.price[App.self.flashVars.social],
							title: 			Locale.__e('flash:1382952379793'),
							description: 	Locale.__e('flash:1382952380239'),
							callback: 		onBuyComplete
						}
					}
					ExternalApi.apiPromoEvent(object);
					break;
			}
		}
		
		private function onBuyComplete(e:* = null):void 
		{
			priceBttn.state = Button.DISABLED;
			App.user.stock.addAll(action.items);
			App.user.stock.addAll(action.bonus);
			
			for each(var item:ActionItem in items) {
				var bonus:BonusItem = new BonusItem(item.sID, item.count);
				var point:Point = Window.localToGlobal(item);
					bonus.cashMove(point, App.self.windowContainer);
			}
			
			App.user.promo[action.id].buy = 1;
			App.user.buyPromo(action.id);
			App.ui.salesPanel.createPromoPanel();
			
			close();
			
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				title:Locale.__e("flash:1382952379735"),
				text:Locale.__e("flash:1382952379990")
			}).show();
		}
		
		private function updateDuration():void {
			if (mode == 2) {
				var spendTime:int = (App.time - action.time)/3600;
				var allTimePercent:int = ((action.time + action.duration * 60 * 60) / App.time) * 100 - ((action.time + action.duration * 60 * 60) / App.time) * spendTime;
				var rate:int = action.rate;
				var count:int = allTimePercent * rate;
				timerText.text = String(count);
				if (count <= 0) {
					descriptionLabel.visible = false;
					timerText.visible = false;
				}
			}else {
				var time:int = action.duration * 60 * 60 - (App.time - action.time);
				timerText.text = TimeConverter.timeToStr(time);
				if (time <= 0) {
					descriptionLabel.visible = false;
					timerText.visible = false;
				}
			}
		}
		
		public override function dispose():void
		{
			for each(var _item:ActionItem in items)
			{
				_item = null;
			}
			
			App.self.setOffTimer(updateDuration);
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import units.AnimatedUnit;
import units.AnimationItem;
import units.Personage;
import wins.Window;

internal class ActionItem extends Sprite {
		
		public var count:uint;
		public var sID:uint;
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var aItem:AnimationItem;
		public var countText:TextField;
		public var window:*;
		
		private var preloader:Preloader = new Preloader();
		
		private var bonus:Boolean = false;
		private var sprite:LayerX;
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			this.bonus = bonus;
			
			background = new Bitmap(Window.textures.referalRoundBacking);
			addChild(background);
			
			sprite = new LayerX();
			addChild(sprite);
			//if (sID != 418) {
				bitmap = new Bitmap();
				sprite.addChild(bitmap);
			/*}else {
				aItem = new AnimationItem();
				sprite.addChild(aItem);
			}*/
			
			
			
			//drawCount();
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 15;
			if (sID != 418) {
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].view), onPreviewComplete);
			}else {
				
				onPreviewComplete(null);
			}
		}
		
		private function addBonusLabel():void {
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
			if (sID == 418) {
				var aItem:AnimatedUnit = new AnimatedUnit({
				type:	App.data.storage[sID].type,
				view:	App.data.storage[sID].view
				}); 
				aItem.x = (background.width - aItem.width) / 2 - 15;
				sprite.addChild(aItem);
				aItem.scaleX = aItem.scaleY = 0.75;
				aItem.x = (background.width - aItem.width)/ 2 + 65;
				aItem.y = (background.height - aItem.height) / 2 + 110;
			}else {
				bitmap.bitmapData = data.bitmapData;
				bitmap.scaleX = bitmap.scaleY = 0.8;
				bitmap.smoothing = true;
				bitmap.x = (background.width - bitmap.width)/ 2;
				bitmap.y = (background.height - bitmap.height) / 2;
			}
			if (bonus)
				bitmap.filters = [new GlowFilter(0xffffff, 1, 40, 40)];
			drawCount();
		}
		
		public function drawCount():void {
			if (count == 1) return;
			countText = Window.drawText("x" + String(count), {
				color:0xffffff,
				borderColor:0x41332b,
				textAlign:"center",
				autoSize:"center",
				fontSize:42,
				textLeading:-6,
				multiline:true
			});
			countText.wordWrap = true;
			countText.width = background.width - 20;
			countText.y = 55;
			countText.x = 80;
			addChild(countText);
		}
		
}
