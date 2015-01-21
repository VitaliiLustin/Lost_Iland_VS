package wins.elements 
{

	import buttons.Button;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Factory;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	import wins.Window;
	import core.Load;
	import com.greensock.*;

		
	public class PurchaseItem extends Sprite
	{ 
		
		public var callback:Function;
		public var background:Bitmap;
		public var title:TextField;
		public var sID:int;
		public var bitmap:Bitmap;
		public var sprite:LayerX;
		public var coinsBttn:MoneyButton;
		public var banksBttn:MoneyButton;
		public var selectBttn:Button;
		public var moneyType:String;
		public var window:*;
		
		private var object:Object;
		private var id:uint;
		private var dY:int = -10;
		
		private var preloader:Preloader = new Preloader();
		public var _state:uint = 1;
		
		private var underIcon:Bitmap;
		private var objIcon:Object;
		
		private var price:int;
		private var drawDesc:Boolean = false;
		public var doGlow:Boolean = false;
		
		private var noTitle:Boolean = false;
		private var noDesc:Boolean = false;
		
		public var bgWidth:int = 152;
		
		public function PurchaseItem(sID:int, callback:Function, window:*, id:uint, doGlow:Boolean = false, noTitle:Boolean = false, noDesc:Boolean = false)
		{
			this.id = id;
			this.sID = sID;
			this.callback = callback;
			this.window = window;
			this.doGlow = doGlow;
			this.noTitle = noTitle;
			this.noDesc = noDesc;
				
			background = Window.backing2(bgWidth, 250, 40, "purchItemBg1", "purchItemBg2");
			addChild(background)
			
			var shine:Bitmap = new Bitmap(Window.textures.productionReadyBacking);
			shine.scaleX = shine.scaleY = 1.7;
			shine.y = 15;
			shine.x = -40;
			addChild(shine);
			
			sprite = new LayerX;
			addChild(sprite);
			
			/*underIcon = new Bitmap(Window.textures.bankRoundBaking);
			sprite.addChild(underIcon);
			underIcon.x = (background.width - underIcon.width) / 2;
			underIcon.y = (background.height - underIcon.height) / 2;*/
			
			bitmap = new Bitmap(null,"auto", true);
			sprite.addChild(bitmap);
			
			sprite.tip = function():Object
			{
				return {
					title:App.data.storage[sID].title,
					text:App.data.storage[sID].description
				};
			}
			
			addChild(preloader);
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height)/ 2 - 8;
			
			object = App.data.storage[sID];
			
			if (object.hasOwnProperty('price')) price = object.price[Stock.FANT];
			else {
				drawDesc = true;
				var needEfir:int = (Stock.efirLimit - App.user.stock.count(Stock.FANTASY));
				if (needEfir > 0) price = Math.ceil(needEfir / 30);
				else price = 0;
				//price = ;
			}
			
			if(!noTitle){
				title = Window.drawText(object.title, {
					multiline:true,
					autoSize:"left",
					textAlign:"center",
					textLeading: -10,
					fontSize:28,
					color:0xfaf9ec,//0xfff7fc,
					borderColor:0x814f31//0x9b1356
				});
				title.y = -title.textHeight - 20;
				title.wordWrap = true;
				title.height = 32;
				title.width = background.width - 4;
						
				title.x = (background.width - title.width) / 2;
				addChild(title);
			}
			
			if (window.settings.listType == "Hut")	drawSelectBttn();
			else if (price == 0)					drawStockFull();
			else 									drawMoneyBttn();
			
			if (App.data.storage[sID].type == "Jam")
			{
				dY = -15
				drawCapacity();
			}
			
			objIcon = App.data.storage[object.out];
			
			if (!drawDesc && !noDesc) {
				if (App.data.storage[sID].view == 'Feed') {
					var efirCount:TextField = Window.drawText('+' + object.count, {
						multiline:true,
						autoSize:"left",
						textAlign:"left",
						fontSize:28,
						color:Window.getTextColor(object.out).color,
						borderColor:Window.getTextColor(object.out).borderColor
					});
					var animalIcon:Bitmap;
					switch (sID) 
					{
						case 281:
							animalIcon = new Bitmap(Window.textures.chickenIco);
							animalIcon.x = background.width - 50;
						break;
						case 282:
							animalIcon = new Bitmap(Window.textures.chickenIco);
							animalIcon.x = background.width - 50;
						break;
						case 283:
							animalIcon = new Bitmap(Window.textures.cowIco);
							animalIcon.x = background.width - 55;
						break;
						case 284:
							animalIcon = new Bitmap(Window.textures.cowIco);
							animalIcon.x = background.width - 55;
						break;
						case 328:
							animalIcon = new Bitmap(Window.textures.sheepIco);
							animalIcon.x = background.width - 65;
						break;case 329:
							animalIcon = new Bitmap(Window.textures.sheepIco);
							animalIcon.x = background.width - 65;
						break;
						case 347:
							animalIcon = new Bitmap(Window.textures.pigIco);
							animalIcon.x = background.width - 65;
						break;
						case 348:
							animalIcon = new Bitmap(Window.textures.pigIco);
							animalIcon.x = background.width - 65;
						break;
						case 370:
							animalIcon = new Bitmap(Window.textures.rabbitIco);
							animalIcon.scaleX = animalIcon.scaleY = 1.2;
							animalIcon.smoothing = true;
							animalIcon.x = background.width - 55;
						break;
						case 371:
							animalIcon = new Bitmap(Window.textures.rabbitIco);
							animalIcon.scaleX = animalIcon.scaleY = 1.2;
							animalIcon.smoothing = true;
							animalIcon.x = background.width - 55;
						break;
						case 405:
							animalIcon = new Bitmap(Window.textures.shepherdIco);
							animalIcon.x = background.width - 65;
						break;
						case 433:
							animalIcon = new Bitmap(Window.textures.snakeIco);
							animalIcon.x = background.width - 65;
						break;
						case 434:
							animalIcon = new Bitmap(Window.textures.snakeIco);
							animalIcon.x = background.width - 65;
						break;
					} 
					if (animalIcon != null) {
						
						animalIcon.scaleX = animalIcon.scaleY = 0.5;
						animalIcon.smoothing = true;
						animalIcon.y = background.height - 125;
						addChild(animalIcon);
					}
					efirCount.wordWrap = true;
					efirCount.height = efirCount.textHeight;
					efirCount.width = efirCount.textWidth + 10;
					addChild(efirCount);
					efirCount.x = (background.width - efirCount.textWidth) / 2 - 3;
					efirCount.y += 8;
					
				}else {
					Load.loading(Config.getIcon(objIcon.type, objIcon.preview), onLoadOut);
				}
			}
			else if (drawDesc) 
				drawDescription();
			else if (noDesc && !noTitle)
				title.y = background.y + 5;
		
			Load.loading(Config.getIcon(object.type, object.preview), onLoad);
			
			
			if (doGlow) glowing();
		}
		
		private function glowing():void {
			customGlowing(background, glowing);
			if (coinsBttn) {
				customGlowing(coinsBttn);
			}
			if (banksBttn) {
				customGlowing(banksBttn);
			}
		}
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});
		}
		
		private function drawStockFull():void 
		{
			var itemDesc:TextField = Window.drawText('Склад полностью заполнен', {
				multiline:true,
				autoSize:"center",
				textAlign:"center",
				fontSize:22,
				color:Window.getTextColor(object.out).color,
				borderColor:Window.getTextColor(object.out).borderColor
			});
			itemDesc.wordWrap = true;
			itemDesc.height = itemDesc.textHeight;
			itemDesc.width = itemDesc.textWidth+60;
					
			itemDesc.x = (background.width - itemDesc.width) / 2;
			itemDesc.y = background.height - itemDesc.height - 5;
			addChild(itemDesc);
		}
		
		private function drawDescription():void 
		{
			var itemDesc:TextField = Window.drawText(object.description, {
				multiline:true,
				autoSize:"center",
				textAlign:"center",
				fontSize:22,
				color:Window.getTextColor(object.out).color,
				borderColor:Window.getTextColor(object.out).borderColor
			});
			itemDesc.wordWrap = true;
			itemDesc.height = itemDesc.textHeight;
			itemDesc.width = itemDesc.textWidth+30;
					
			itemDesc.x = (background.width - itemDesc.width) / 2;
			itemDesc.y = 4;
			addChild(itemDesc);
		}
		
		private function onLoadOut(data:*):void 
		{
			var spEfir:Sprite = new Sprite();
			var iconEfir:Bitmap = new Bitmap(data.bitmapData);
			iconEfir.scaleX = iconEfir.scaleY = 0.4;
			iconEfir.smoothing = true;
			
			
			var efirCount:TextField = Window.drawText('+' + object.count, {
				multiline:true,
				autoSize:"left",
				textAlign:"left",
				fontSize:28,
				color:Window.getTextColor(object.out).color,
				borderColor:Window.getTextColor(object.out).borderColor
			});
			efirCount.wordWrap = true;
			efirCount.height = efirCount.textHeight;
			efirCount.width = efirCount.textWidth+10;
					
			
				
			efirCount.x = iconEfir.x + iconEfir.width + 6;
			spEfir.addChild(iconEfir);
			
			spEfir.addChild(efirCount);
			
			spEfir.x = (background.width - spEfir.width) / 2;
			spEfir.y = 6;
			addChild(spEfir);
		}
		
		public function set state(value:uint):void
		{
			_state = value;
			if (_state){
				if(banksBttn)	banksBttn.state = Button.NORMAL;
				if(coinsBttn)	coinsBttn.state = Button.NORMAL;
			}else{ 
				if(banksBttn)	banksBttn.state = Button.DISABLED;
				if (coinsBttn)	coinsBttn.state = Button.DISABLED;
			}	
		}
		
		private function drawSelectBttn():void
		{
			selectBttn = new Button( {
				width:125,
				height:40,
				fontSize:24,
				bgColor		:[0xfdb29f, 0xed7483],
				borderColor	:[0xffffff, 0xffffff],
				bevelColor  :[0xfeb19f, 0xe87383],
				fontColor	:0xffffff,
				fontBorderColor :0x993a40,
				fontCountColor	:0xFFFFFF,
				fontCountBorder :0x354321,
				fontBorderSize	:3,
				caption:Locale.__e("flash:1382952380066")
			});
			
			addChild(selectBttn);
			selectBttn.x = (this.width - selectBttn.width)/2;
			selectBttn.y = 180;
			
			moneyType = 'coins';
			
			selectBttn.addEventListener(MouseEvent.CLICK, onSelectClick)
		}
		
		private function drawMoneyBttn():void
		{
			if (object.coins > 0)
			{
				coinsBttn = new MoneyButton( {
					countText:String(object.coins),
					width:125,
					height:46,
					caption:Locale.__e("flash:1382952379984"),
					shadow:true,
					fontCountSize:23,
					fontSize:24,
					type:"gold"
				});
				addChild(coinsBttn);
				coinsBttn.x = (this.width - coinsBttn.width)/2;
				coinsBttn.y = 160;
				
				moneyType = 'coins';
				
				coinsBttn.addEventListener(MouseEvent.CLICK, onBuyClick)
			}
			else
			{	
				banksBttn = new MoneyButton( {
					title:Locale.__e('flash:1382952379751') + ':',
					countText:String(price),
					width:132,
					height:44,
					shadow:true,
					fontCountSize:23,
					fontSize:22,
					type:"green",
					radius:18,
					fontBorderColor:0x406903,
					fontCountBorder:0x406903,
					iconScale:0.65,
					fontCountSize:36
				});
				addChild(banksBttn);
				
				//banksBttn.x = (this.width - banksBttn.width)/2;
				banksBttn.x = (152 - banksBttn.width)/2;
				banksBttn.y = 196;
				
				moneyType = 'banknotes';
				
				banksBttn.addEventListener(MouseEvent.CLICK, onBuyClick)
			}
		}
		
		public function dispose():void {
			if(coinsBttn != null){
				coinsBttn.removeEventListener(MouseEvent.CLICK, onBuyClick)
			}
			if(banksBttn != null){
				banksBttn.removeEventListener(MouseEvent.CLICK, onBuyClick)
			}
			if(selectBttn != null){
				selectBttn.removeEventListener(MouseEvent.CLICK, onSelectClick)
			}
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}
		
		public function onSelectClick(e:MouseEvent):void
		{
			if(callback != null) callback(this.sID);
			window.close();
		}
		
		public function onBuyClick(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			var sett:Object = null;
			
			if (App.data.storage[this.sID].out == Techno.TECHNO) {
				sett = { 
					ctr:'techno',
					wID:App.user.worldID,
					x:App.map.heroPosition.x,
					z:App.map.heroPosition.z,
					capacity:1
				};
			}
			
			window.blokItems(false);
			App.user.stock.pack(this.sID, onBuyComplete, function():void {
				window.blokItems(true);
				//window.close();
			}, sett);
			window.close();
		}
		
		private function onBuyComplete(sID:uint, rez:Object = null):void
		{
			if (callback != null) callback(sID);
			if (window.settings.closeAfterBuy)	window.close();
			if (Techno.TECHNO == sID) {
				addChildrens(sID, rez.ids);
			}
			else {
				var currentTarget:Button;
				if (banksBttn) currentTarget = banksBttn;
				if (coinsBttn) currentTarget = coinsBttn;
				
				var X:Number = App.self.mouseX - currentTarget.mouseX + currentTarget.width / 2;
				var Y:Number = App.self.mouseY - currentTarget.mouseY;
				
				Hints.plus(this.sID, 1, new Point(X,Y), true, App.self.tipsContainer);
				
				
				for (var _sid:* in object.price)
					Hints.minus(_sid, object.price[_sid], new Point(X, Y), false, App.self.tipsContainer);
			}
			
			if (sID != Techno.TECHNO){
				flyMaterial();
				window.blokItems(true);
			}
			
			window.removeItems();
			window.createItems();
			window.contentChange();
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
		
		public function onLoad(data:*):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = (background.width - bitmap.width) / 2;
			//bitmap.y = underIcon.y + (underIcon.height - bitmap.height) / 2 - 12;
			bitmap.y = (background.height - bitmap.height) / 2 - 12;
			if (sID == 370 || sID == 371) {
				bitmap.x = (background.width - bitmap.width) / 2 - 10;
			}
		}
			
		private function drawCapacity():void
		{
			var container:Sprite = new Sprite();
			
			var spoonIcon:Bitmap = new Bitmap();
			var _text:String;
			
			var textSettings:Object;
			textSettings = {
					color				: 0x614605,
					fontSize			: 16,
					borderColor 		: 0xf5efd9
				}
				
			if (object.view.indexOf('jam') != -1) {
				spoonIcon = new Bitmap(UserInterface.textures.spoonIcon);
				spoonIcon.scaleX = spoonIcon.scaleY = 0.25;
				switch(id)
				{
					case 0: _text = Locale.__e("flash:1382952380067"); break;
					case 1: _text = Locale.__e("flash:1382952380068"); break;
					case 2: _text = Locale.__e("flash:1382952380069"); break;
				}
			}else {
				spoonIcon = new Bitmap(UserInterface.textures.spoonIconFish);
				spoonIcon.scaleX = spoonIcon.scaleY = 0.35;
				switch(id)
				{
					case 0: _text = Locale.__e("flash:1382952380070"); break;
					case 1: _text = Locale.__e("flash:1382952380071"); break;
					case 2: _text = Locale.__e("flash:1382952380072"); break;
				}
			}
			spoonIcon.smoothing = true;
			
			var text:TextField = Window.drawText(_text + ":", textSettings);
			
			text.width 	= text.textWidth  + 4;
			text.height = text.textHeight;
			
			var countText:TextField = Window.drawText(String(App.data.storage[object.sID].capacity), textSettings);
			
			countText.height = countText.textHeight;
			countText.width = countText.textWidth + 4;
			countText.border = false;
			
			countText.x = text.width + 4;
			
			spoonIcon.x = countText.x + countText.width + 4;
			spoonIcon.y = countText.y + (countText.textHeight - spoonIcon.height)/2;
			
			container.addChild(text);
			container.addChild(countText);
			container.addChild(spoonIcon);
			
			addChild(container);
			container.x = (background.width - container.width) / 2;
			container.y = background.height - container.height - 28;
		}	
		
		private function flyMaterial():void
		{
			var _sID:uint = sID;
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && !App.data.storage[sID].inguest){
				_sID = Stock.FANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Energy' && App.data.storage[sID].inguest == 1){
				_sID = Stock.GUESTFANTASY;
			}
			if (App.data.storage[sID].type == 'Energy' && App.data.storage[sID].view == 'Feed' && !App.data.storage[sID].inguest){
				_sID = App.data.storage[sID].out;
			}
				
			var item:BonusItem = new BonusItem(_sID, 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			item.cashMove(point, App.self.windowContainer);
		}
	}
}	