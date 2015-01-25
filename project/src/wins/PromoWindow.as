package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
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
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Factory;
	import units.Hut;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;

	public class PromoWindow extends Window
	{
		public static const MODE_WITH_TIME:int = 1;
		public static const MODE_WITHOUT_TIME:int = 2;
		
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		
		private var mode:int = MODE_WITH_TIME;
		
		public function PromoWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 728;
			settings['height'] = 375;
						
			settings['title'] = Locale.__e("flash:1382952379793");
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			
			super(settings);
		}
		
		override public function drawExit():void {
		
		}
		
		override public function drawBackground():void 
		{
			
		}
		
		private var background:Bitmap
		public function changePromo(pID:String):void {
			
			App.self.setOffTimer(updateDuration);
			
			action = App.data.actions[pID];
			action.id = pID;
			
			if (action.duration <= 0) {
				settings['height'] = 325;
				mode = MODE_WITHOUT_TIME;
			}
			
			settings.content = initContent(action.items);
			settings.bonus = initContent(action.bonus);
			
			var numItems:int = settings.content.length + (settings.bonus.length - 1);
			
			if (numItems < 4) {
				
				settings.width = numItems * 200 + 200;
				if (settings.content.length == 3) settings.width = 700;
				if (settings.content.length == 1) settings.width = 360;
			}
			if (numItems == 4) settings.width = 850;
			if (numItems == 1) settings.width = 420;
			
			var background:Bitmap = backing(settings.width, settings.height, 45, 'shopMackingMainSmall');
			layer.addChild(background);
			
			exit = new ImageButton(textures.closeBttn);
			headerContainer.addChild(exit);
			exit.x = settings.width - 50;
			exit.y = -20;
			exit.addEventListener(MouseEvent.CLICK, close);
			
			var backing:Bitmap = Window.backing(settings.width - 60, 230, 43, 'shopBackingSmall1');
			bodyContainer.addChild(backing);
			backing.x = (settings.width - backing.width) / 2;
			backing.y = -10;
			//backing.alpha = 0.5;
			
			
			var text:String = Locale.__e("flash:1393581986914");
			_descriptionLabel = drawText(text, {
				fontSize:26,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x6d289a
			});
			
			var ribbonWidth:int = settings.width + 140;
			if(ribbonWidth < _descriptionLabel.textWidth + 150)ribbonWidth = _descriptionLabel.textWidth + 150
			var ribbon:Bitmap = backingShort(ribbonWidth, 'questRibbon');
			ribbon.y = -63;
			ribbon.x = (settings.width - ribbon.width) / 2;
			bodyContainer.addChild(ribbon);
			
			//_descriptionLabel.y = 3;
			_descriptionLabel.y = ribbon.y + (ribbon.height - _descriptionLabel.height)/2 - 15;
			
			bodyContainer.addChild(_descriptionLabel);
			
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = 50;
			container.y = 60;
			
			
			settings['L'] = settings.content.length + settings.bonus.length;
			if (settings['L'] < 2) settings['L'] = 2;
			
			//settings.width = 130 * settings['L'] + 130;
			
			//if(background != null)
				//layer.removeChild(background);
				//
			//background = backing(settings.width, settings.height, 50, "windowActionBacking");
			//layer.addChildAt(background,0);
			
			drawImage();	
			contentChange();
			drawPrice();
			drawTime();
			
			if(mode == MODE_WITH_TIME){
				updateDuration();
				App.self.setOnTimer(updateDuration);
			}
			
			if(fader != null)
				onRefreshPosition();
				
			titleLabel.x = (settings.width - titleLabel.width) / 2;	
			titleLabel.y = ribbon.y + 8;
			_descriptionLabel.x = settings.width/2 - _descriptionLabel.width/2;
			exit.y -= 10;
			
			var X:int = 10;
			for each(var bttn:PromoIcon in bttns) {
				
				if (bttn.pID == pID) 
				{
					bttn.clickable = false;
					bttn.scaleX = bttn.scaleY = 1.2;
					bttn.filters = [];
					bttn.bttn.startRotate(0, 10000, 1);
					bttn.x = X;
					bttn.y = -6;
					X += 84;
				}
				else
				{
					bttn.clickable = true;
					UserInterface.effect(bttn, 0, 0.6);
					bttn.scaleX = bttn.scaleY = 1;
					bttn.y = 0;
					bttn.bttn.stopRotate();
					bttn.x = X;
					X += 70;
				}
			}
			
			if (menuSprite != null){
				menuSprite.x = settings.width / 2 - (promoCount * 70) / 2 - 20;
			}
		}
		
		private function initContent(data:Object):Array
		{
			var result:Array = [];
			for (var sID:* in data) {
				result.push( { sID:sID, count:data[sID], order:action.iorder[sID]} );
			}
			
			result.sortOn('order');
			return result;
		}
		
		private var axeX:int
		private var _descriptionLabel:TextField;
		
		override public function drawBody():void 
		{
			//titleLabel.y -= 50;
			
			
			changePromo(settings['pID']);
			
			if(settings['L'] <= 3)
				axeX = settings.width - 170;
			else
				axeX = settings.width - 190;
				
			_descriptionLabel.x = settings.width / 2 - _descriptionLabel.width / 2;
			
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 15, settings.width / 2 + settings.titleWidth / 2 + 15, -82, true, true);
			drawMirrowObjs('storageWoodenDec', 12, settings.width - 12, settings.height - 127);
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
				var bttn:PromoIcon = new PromoIcon(pID, this);
				menuSprite.addChild(bttn);
				bttns.push(bttn);
				bttn.y = 0;
				bttn.x = X;
				
				if (App.user.promo[pID].hasOwnProperty('new')) 
				{
					if(App.time < App.user.promo[pID]['new'] + 2*3600)
						bttn._new = true;
					
					if(App.time < App.user.promo[pID]['new'] + 5*60)
						bttn.showGlowing();
				}
				X += 70;
			}
			
			bodyContainer.addChild(menuSprite);
			menuSprite.y = settings.height - 70;
			var bg:Bitmap = Window.backing((promoCount * 70) + 40, 70, 10, 'smallBacking');
			menuSprite.addChildAt(bg, 0);
			
			menuSprite.x = (settings.width - menuSprite.width) / 2 - 10;
		}
		
		private var glowing:Bitmap;
		private var stars:Bitmap;
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
			
			//if (glowing == null)
			//{
				//glowing = Window.backingShort(0, 'saleGlowPiece');
				//bodyContainer.addChildAt(glowing, 0);
			//}
			
			//if (stars == null) {
				//stars = Window.backingShort(0, 'decorStars');
				//bodyContainer.addChildAt(stars, 1);
			//}
			
			//stars.smoothing = true;
			//if (stars.width > settings.width - 40) stars.width = settings.width - 40;
			
			//stars.x = 20;
			//stars.y = settings.height - stars.height - 38;
			
			//glowing.alpha = 0.85;
			//glowing.x = axeX - glowing.width/2;
			//glowing.y = settings.height - glowing.height - 38;
			//glowing.smoothing = true;
			
			if (action.image == 'bigPanda') {
			
			}
			
			//glowing.width = (settings.width - 100);
			//glowing.x = 50;
			//axeX = settings.width / 2;
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
			var Ys:int = -40;
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
			
			var plus:Bitmap = new Bitmap(Window.textures.plus);
			plus.x = Xs - 16;
			plus.y = 35;
			Xs += 20;
			
			for (i = 0; i < settings.bonus.length; i++)
			{
				item = new ActionItem(settings.bonus[i], this, true);
				
				container.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.background.width;
			}
			if (settings.bonus.length > 0) {
				container.addChild(plus);
			}
			container.y -= 4;
			container.x = (settings.width - 150 * (settings.content.length + settings.bonus.length)) / 2 - 10;
		}
		
		private var timerContainer:Sprite;
		public function drawTime():void 
		{	
			if (mode != MODE_WITH_TIME) {
				return;
			}
			
			if (timerContainer != null)
				bodyContainer.removeChild(timerContainer);
				
			timerContainer = new Sprite()
			
			var background:Bitmap = Window.backingShort(200, "timeBg");
			timerContainer.addChild(background);
			background.x =  - background.width/2;
			background.y = settings.height - background.height - 80;
			
			//var separator:Bitmap = Window.backingShort(settings.width/2, 'divider', false);
			//separator.alpha = 0.85;
			//separator.x = (background.x - separator.width) - 10;
			//separator.y = background.y + (background.height - separator.height)/2;
			//timerContainer.addChild(separator);
				
			//var separator2:Bitmap = Window.backingShort(settings.width/2, 'divider', false);
			//separator2.alpha = 0.85;
			//separator2.x = background.width + 35;
			//separator2.y = background.y + (background.height - separator2.height)/2;
			//separator2.scaleX = -1;
			//timerContainer.addChild(separator2);
			
			
			descriptionLabel = drawText(Locale.__e('flash:1393581955601'), {
				fontSize:30,
				textAlign:"left",
				color:0xffffff,
				borderColor:0x5a2910
			});
			descriptionLabel.x =  background.x + (background.width - descriptionLabel.textWidth) / 2;
			descriptionLabel.y = background.y - descriptionLabel.textHeight / 2;
			timerContainer.addChild(descriptionLabel);
			
			var time:int = action.duration * 60 * 60 - (App.time - App.user.promo[action.id].started);
			//timerText = Window.drawText(TimeConverter.timeToCuts(time, true, true), {
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xf8d74c,
				letterSpacing:3,
				textAlign:"center",
				fontSize:34,//30,
				borderColor:0x502f06
			});
			timerText.width = 200;
			timerText.y = background.y + 14;
			timerText.x = background.x;
			
			timerContainer.addChild(timerText);
			
			bodyContainer.addChild(timerContainer);
			timerContainer.x = axeX;
		}
		
		private var cont:Sprite;
		public function drawPrice():void {
			
			var bttnSettings:Object = {
				fontSize:36,
				width:186,
				height:52
				//hasDotes:true
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
		
		private function onTechnoComplete(sID:uint, rez:Object = null):void 
		{
			if (Techno.TECHNO == sID) {
				addChildrens(sID, rez.ids);
			}
		}
		
		private function addChildrens(_sid:uint, ids:Object):void 
		{
			var rel:Object = { };
			rel[Factory.TECHNO_FACTORY] = _sid;
			var position:Object = App.map.heroPosition;
			for (var i:* in ids){
				var unit:Unit = Unit.add( { sid:_sid, id:ids[i], x:position.x, z:position.z, rel:rel } );
					(unit as WorkerUnit).born({capacity:1});
			}
		}
		
		private function updateDuration():void {
			if (mode != MODE_WITH_TIME)
				return;
			
			var time:int = action.duration * 3600 - (App.time - App.data.actions[action.id].begin_time);
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0) {
				descriptionLabel.visible = false;
				timerText.visible = false;
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

import buttons.ImagesButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import units.AnimatedUnit;
import units.AUnit;
import units.Techno;

internal class PromoIcon extends LayerX
{
	private var data:Object;
	public var pID:String;
	public var bttn:ImagesButton;
	private var win:*;
	public var clickable:Boolean = true;
	
	public function PromoIcon(pID:String, win:*)
	{
		this.pID = pID;
		this.win = win;
		//var backBitmap:Bitmap = Window.backing(120, 70, 8, 'textSmallBacking');
		
		data = App.data.promo[pID];
		for (var sID:* in data.items) break;
		var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
		
		bttn = new ImagesButton(new BitmapData(100,100,true,0));
		addChild(bttn);
		
		Load.loading(Config.getImage('promo/icons', data.preview), function(data:*):void {
			bttn.bitmapData = data.bitmapData;
		});
		
		Load.loading(url, function(data:Bitmap):void 
		{
			bttn.icon = data.bitmapData;
			bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = 0.5;
			bttn.iconBmp.smoothing = true;
			//bttn.iconBmp.filters = iconSettings.filter;
			bttn.iconBmp.x = 40 - bttn.iconBmp.width / 2;//(bttn.bitmap.width - bttn.iconBmp.width)/2;
			bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
		});
		
		bttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private var title:TextField;
	public function set _new(value:Boolean):void 
	{
		var textSettings:Object = {
			text:Locale.__e("flash:1382952379743"),
			color:0xf0e6c1,
			fontSize:19,
			borderColor:0x773c18,
			scale:0.5,
			textAlign:'center',
			multiline:true
		}
		
		var title:TextField = Window.drawText(textSettings.text, textSettings);
		title.wordWrap = true;
		title.width = 60;
		title.height = title.textHeight + 4;
		
		if (value == true){
			bttn.addChild(title);
			title.x = (bttn.bitmap.width - title.width)/2 - 2;
			title.y = (bttn.bitmap.height - title.height) / 2 + 14;
		}else{
			
		}
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void {
		if (clickable == false) return;
		win.changePromo(pID);
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
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
		
		private var sprite:LayerX;
		
		public function ActionItem(item:Object, window:*, bonus:Boolean = false) {
			
			sID = item.sID;
			count = item.count;
			
			this.window = window;
			this.bonus = bonus;
			
			var backType:String = 'itemBacking';
			//if (!bonus)
			//	backType = 'bonusBacking'
			
		
			background = Window.backing(150, 190, 10, backType);
			addChild(background);
			
			if (bonus)
				addBonusLabel();
			
			sprite = new LayerX();
			addChild(sprite);
			
			bitmap = new Bitmap();
			sprite.addChild(bitmap);
			
			
			drawTitle();
			if (count > 1) {
				drawCount();
			}
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2 - 15;
			
			var type:String = App.data.storage[sID].type;
			var preview:String = App.data.storage[sID].preview;
			
			switch(sID) {
				case Stock.COINS:
					type = "Coins";
					preview = getPreview(Stock.COINS, type);
				break;
				case Stock.FANT:
					type = "Reals";
					preview = getPreview(Stock.FANT);
				break;
			}
			if (App.data.storage[sID].type == "Golden") {
				var aItem:AnimatedUnit = new AnimatedUnit({
				type:	App.data.storage[sID].type,
				view:	App.data.storage[sID].view
				}); 
				aItem.x = (background.width - aItem.width) / 2 - 15;
				sprite.addChild(aItem);
				aItem.scaleX = aItem.scaleY = 0.75;
				aItem.x = (background.width - aItem.width)/ 2 + 40;
				aItem.y = (background.height - aItem.height) / 2 + 80;
				removeChild(preloader);
			}else {
				Load.loading(Config.getIcon(type, preview), onPreviewComplete);
			}

		}
		
		private function getPreview(sid:int, type:String = "Reals"):String
		{
			var preview:String;// = App.data.storage[sID].preview;
			
			var arr:Array = [];
			arr = getIconsItems(type);
			arr.sortOn("order", Array.NUMERIC);
			
			if (arr.length == 0) return preview;
			preview = arr[arr.length-1].preview;
			for (var j:int = arr.length-1; j >= 0; j-- ) {
				if (count >= arr[j].price[sid]) {
					preview = arr[j].preview;
				}
				if (type == "Reals" && arr[j]) {
					
				}
				if (type == "Reals") {
					preview = "crystal_03";
				}else if (type == "Coins") {
					preview = "gold_02";
				}
			}
			return preview;
		}
		
		private function getIconsItems(type:String):Array
		{
			var arr:Array = [];
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sid'] = sID;
				
				if (object.type == type)
				{
					arr.push(object); 
				}
			}
			
			return arr;
		}
		
		private function addBonusLabel():void {
			//background.filters = [new GlowFilter(0xFFFF00, 0.6, 25, 25, 4, 1, true)];
			
			
			removeChild(background);
			background = null;
			background = Window.backing2(150, 190, 25, 'shopSpecialBacking1','shopSpecialBacking2');
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
			//bitmap.scaleX = bitmap.scaleY = 0.8;
			bitmap.smoothing = true;
			bitmap.x = (background.width - bitmap.width)/ 2;
			bitmap.y = (background.height - bitmap.height) / 2;
			
			var description:String = App.data.storage[sID].description;
			if (sID == Techno.TECHNO) {
				description = Locale.__e('flash:1396445082768');
			}
			
			sprite.tip = function():Object {
				return {
					title:App.data.storage[sID].title,
					text:description
				};
			}
			
			if (bonus)
				bitmap.filters = [new GlowFilter(0xffffff, 1, 40, 40)];
		}
		
		public function drawTitle():void {
			title = Window.drawText(String(App.data.storage[sID].title), {
				color:0x773c18,
				borderColor:0xfcf6e4,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				textLeading:-6,
				multiline:true
			});
			title.wordWrap = true;
			title.width = background.width - 10;
			title.y = 10;
			title.x = 5;
			addChild(title);
		}
		
		public function drawCount():void {
			var countText:TextField = Window.drawText('x' + String(count), {
				color:0xffffff,
				borderColor:0x41332b,
				textAlign:"center",
				autoSize:"center",
				fontSize:32,
				textLeading:-6,
				multiline:true
			});
			countText.wordWrap = true;
			countText.width = background.width - 10;
			countText.y = background.height -40;
			countText.x = 5;
			addChild(countText);
		}
}
