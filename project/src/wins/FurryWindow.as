package wins 
{
	import adobe.utils.ProductManager;
	import buttons.Button;
	import buttons.IconButton;
	import buttons.ImageButton;
	import buttons.MixedButton2;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.flashdynamix.motion.extras.TextPress;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.UserInterface;
	import units.Animal;
	import units.Cowboy;
	import units.Factory;
	import units.Moneyhouse;
	import units.Resource;
	import units.Techno;
	/**
	 * ...
	 * @author ...
	 */
	public class FurryWindow extends Window
	{
		private var background:Bitmap;
		private var robotIcon:Bitmap;
		private var robotCounter:TextField;
		private var textSettings:Object;
		private var bitmap:Bitmap;
		private var background2:Bitmap;
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private var collectBttn:MixedButton2;
		
		public var plusBttn:ImageButton;
		public var minusBttn:ImageButton;
		public var minusBttn10:ImageButton;
		public var plusBttn10:ImageButton;
		
		public static const FURRY:int = 1;
		public static const RESOURCE:int = 2;
		public static const COLLECTOR:int = 3;
		public static const COWBOW:int = 4;
		public var mode:int = FURRY;
		
		public function FurryWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["width"] = 366;
			settings["height"] = 366;
			settings["title"] = settings.info.title;
			
			settings["fontSize"] = 150;
			settings["hasPaginator"] = false;
			mode = settings["mode"] || FURRY;
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
			if(mode == FURRY || mode == COLLECTOR || mode == COWBOW)
			{
				background = backing(settings.width, settings.height + 45, 20, "storageBackingMain");
				separator = Window.backingShort(160, 'divider', false);
				separator2 = Window.backingShort(160, 'divider', false);
				
				separator.alpha = separator2.alpha =  0.7;
				separator.x = 40;
				separator.y = separator2.y = 260;
				separator2.x = 325;
				separator2.scaleX = -1;
				bodyContainer.addChild(separator);
				bodyContainer.addChild(separator2);
				
				
			}
			if(mode == RESOURCE)
			{
				background = backing(settings.width, settings.height, 20, "storageBackingMain");
				background.x += 50;
			}
			layer.addChildAt(background,0);
		}
		
		override public function drawTitle():void{			
		}
			
		private function drawTitleLabel():void 
		{
			var titleContainer:Sprite = new Sprite();
			var textFilter:GlowFilter = new GlowFilter(0x885827, 1, 4,4, 8, 1);
			var titleText:String;
			if (settings.info.sID == 164) {
				titleText = settings.title;
			}else {
				titleText = settings.info.title;
			}
			var title:TextField = Window.drawText(titleText, {
					color		:0xfeffff,
					borderColor	:0xb88556,
					fontSize	:38,
					multiline	:true,
					wrap		:true,
					textAlign	:"center"
				});
				
				if(mode == FURRY || mode == COLLECTOR || mode == COWBOW)
				{
					title.y = -35;
					title.width = 250;
					title.x = (settings.width - title.width) / 2 - 2;
				}
				
				if(mode == RESOURCE)
				{
					title.y = -5;
					title.x += 50;
					title.width = 450;
					title.x = (settings.width - title.width) / 2 + 50;
				}
				
			titleContainer.addChild(title);
			titleContainer.filters = [textFilter ];
			bodyContainer.addChild(titleContainer);
		}
		
		override public function drawBody():void 
		{
			if(mode == FURRY || mode == COLLECTOR || mode == COWBOW)
			{
				background2 = Window.backing(205, 188, 30, "storageDarkBackingSlim");	
				background2.x = (settings.width/2 - background2.width / 2);
				background2.y = (settings.height/2 - background2.height / 2) - 20;
				layer.addChild(background2);
				drawMirrowObjs('diamonds', 24, settings.width - 24, 58, false, false, false,1,-1 );
				drawMirrowObjs('storageWoodenDec', 5, settings.width - 5, settings.height - 65);
				drawButtons();
				shopBusyFurry();
				drawItems();
				
				drawTitleLabel();
				
				if (mode == COLLECTOR)
					drawHelpButton();
				
				return;
			}
			
			if(mode == RESOURCE)
			{	
				var countContainer:Sprite = new Sprite();
				var capacityContainer:Sprite = new Sprite();
				background2 = Window.backing(175, 170, 30, "storageDarkBackingSlim");
				background2.x = (settings.width/2 - background2.width / 2) + 50;
				background2.y = (settings.height/2 - background2.height / 2) - 30;
				layer.addChild(background2);
				
				var diamond1:Bitmap = new Bitmap(Window.textures.diamonds);
				var diamond2:Bitmap = new Bitmap(Window.textures.diamonds);
				var woodenDec1:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
				var woodenDec2:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
				
				diamond1.y = diamond2.y = 85;
				diamond1.scaleY = diamond2.scaleY = -1;
				diamond2.scaleX = -1;
				diamond1.x = 74;
				diamond2.x = settings.width - 24 + 50;
				
				woodenDec1.y = woodenDec2.y = settings.height - 85;
				woodenDec1.x = 55;
				woodenDec2.scaleX = -1;
				woodenDec2.x = settings.width - 5 + 50;
				
				layer.addChild(diamond1);
				layer.addChild(diamond2);
				layer.addChild(woodenDec1);
				layer.addChild(woodenDec2);
				
				var workerFurry:Bitmap = new Bitmap(Window.textures.errorWork);
				workerFurry.x = - workerFurry.width/3;
				layer.addChild(workerFurry);
				
				drawItems();
				var bg:Shape = new Shape();
				bg.graphics.beginFill(0xbc8e41);
				bg.graphics.drawCircle(0, 0, 18);
				
				var bg2:Shape = new Shape();
				bg2.graphics.beginFill(0xefd099);
				bg2.graphics.drawCircle(0, 0, 15);
				
				var bg3:Shape = new Shape();
				bg3.graphics.beginFill(0xbc8e41);
				bg3.graphics.drawCircle(0, 0, 19);
				
				var bg4:Shape = new Shape();
				bg4.graphics.beginFill(0xefd099);
				bg4.graphics.drawCircle(0, 0, 16);
					
				countContainer.addChild(bg);
				countContainer.addChild(bg2);
				
				capacityContainer.addChild(bg3);
				capacityContainer.addChild(bg4);
				
				itemCount = settings.capacity;
				capacity = 1;
				countCalc = Window.drawText(String(capacity) , {
					color		:0xfeffff,
					borderColor	:0x572c26,
					fontSize	:24,
					textAlign	:"center"
				});
				countCalc.x = -1;
				countCalc.y = -3;
				
				itemCapacityTf = Window.drawText(String(itemCount - capacity) , {
					color		:0xfeffff,
					borderColor	:0x572c26,
					fontSize	:22,
					textAlign	:"center"
				});
				itemCapacityTf.x = -50;
				itemCapacityTf.y = -12;
				
				priceCount = capacity * settings.target.info.require[Stock.FANTASY];
				priceCalc = Window.drawText(String(priceCount) , {
					color		:0xffdb65,
					borderColor	:0x775002,
					fontSize	:34,
					textAlign	:"center"
				});
				priceCalc.x = 15
				priceCalc.y = 65
					
				minusBttn = new ImageButton(UserInterface.textures.coinsMinusBttn);
				minusBttn.x = 0;
				bg.x = minusBttn.x + minusBttn.width + 20;
				bg.y = 10;
				bg2.x = bg.x;
				bg2.y = bg.y;
				
				minusBttn10 = new ImageButton(UserInterface.textures.coinsMinusBttn10);
				minusBttn10.scaleX = 0.9; 
				minusBttn10.x = 100 + 50;
				minusBttn10.y = 194;
				
				plusBttn = new ImageButton(UserInterface.textures.coinsPlusBttn2);
				plusBttn.x = bg.x + 20;
				
				plusBttn10 = new ImageButton(UserInterface.textures.coinsPlusBttn10);
				plusBttn10.scaleX = 0.9; 
				plusBttn10.x = 236 + 50;
				plusBttn10.y = 194;
				
				
				
				var iconBack:Bitmap = new Bitmap(Window.textures.hutNektarBack);
				iconBack.x = (settings.width - iconBack.width) / 2 + 50;
				iconBack.y = (settings.width - iconBack.width) / 2 + 130;
				layer.addChild(iconBack);
				
				var icon:Bitmap = new Bitmap(UserInterface.textures.energyIcon);
				icon.scaleX = icon.scaleY = 0.9;
				icon.smoothing = true;
				icon.x = iconBack.x + 20;
				icon.y = iconBack.y + 3;
				layer.addChild(icon);
				
				minusBttn.state = Button.DISABLED;
				minusBttn10.state = Button.DISABLED;
				plusBttn.addEventListener(MouseEvent.CLICK, onPlusEvent);
				plusBttn10.addEventListener(MouseEvent.CLICK, onPlus10Event);
				minusBttn.addEventListener(MouseEvent.CLICK, onMinusEvent);
				minusBttn10.addEventListener(MouseEvent.CLICK, onMinus10Event);
				
				countContainer.addChild(plusBttn);
				countContainer.addChild(minusBttn);
				layer.addChild(plusBttn10);
				layer.addChild(minusBttn10);
				countContainer.addChild(countCalc);
				countContainer.addChild(priceCalc);
				capacityContainer.addChild(itemCapacityTf);
				
				layer.addChild(countContainer);
				layer.addChild(capacityContainer);
				
				countContainer.x = (background2.width + countContainer.width) / 2 - 10 + 50;
				countContainer.y = background2.y + (background2.height + countContainer.height) / 2 - 20;
				
				capacityContainer.x = background2.x + background2.width;
				capacityContainer.y = background2.y + 10;
				
				
				
				drawButtons();
				drawTitleLabel();
				
				return;
			}
		}
		
		private function drawHelpButton():void
		{
			bttnHelp = new IconButton(Window.textures.helpButton, {caption:''});
			bttnHelp.x = 80;
			bttnHelp.y = 40;
			bodyContainer.addChild(bttnHelp);
			
			bttnHelp.addEventListener(MouseEvent.CLICK, onHelp);
		}
		
		private function onHelp(e:MouseEvent):void 
		{
			new ConciergeHelpWindow({title:Locale.__e('flash:1410429947661')}).show();
		}
		
		private function onMinus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (capacity - 10 <= 0)
			{
				capacity = 1;
			}else
				capacity -= 10;
			
			plusBttn.state = Button.NORMAL;
			plusBttn10.state = Button.NORMAL;
				
			priceCount = int(capacity * settings.target.info.require[Stock.FANTASY]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			if (capacity < 2) {
				minusBttn10.state = Button.DISABLED;
				minusBttn.state = Button.DISABLED;
			}
		}
		
		private function onPlus10Event(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			if (capacity + 10 >= itemCount)
			{
				capacity = itemCount;
			}else
				capacity += 10;
			
			minusBttn.state = Button.NORMAL;
			minusBttn10.state = Button.NORMAL;
			
			priceCount = int(capacity * settings.target.info.require[Stock.FANTASY]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			if (capacity == itemCount) {
				plusBttn.state = Button.DISABLED;
				plusBttn10.state = Button.DISABLED;
			}
		}
		
		
		public var capacity:int = 0;
		private function onMinusEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			capacity --;
			
			priceCount = int(capacity * settings.target.info.require[Stock.FANTASY]);
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity);
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			if (capacity <= 1) {
				minusBttn.state = Button.DISABLED;
				minusBttn10.state = Button.DISABLED;
			}
				
			plusBttn.state = Button.NORMAL
			plusBttn10.state = Button.NORMAL;
		}
		
		private function onPlusEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			capacity ++
			
			priceCount = int(capacity * settings.target.info.require[Stock.FANTASY]);
			
			priceCalc.text = String(priceCount);
			countCalc.text = String(capacity);	
			itemCapacityTf.text = String(itemCount - capacity);
			timeNeed = capacity * settings.target.info.time;  
			collectBttn.count = TimeConverter.timeToCuts(timeNeed, true, true);
			collectBttn.topLayer.x = (collectBttn.bottomLayer.width - collectBttn.topLayer.width) / 2 - 30;
			
			if (capacity == itemCount) {
				plusBttn.state = Button.DISABLED;
				plusBttn10.state = Button.DISABLED;
			}
			
			minusBttn.state = Button.NORMAL;
			minusBttn10.state = Button.NORMAL;
		}
		
		public function drawItems():void
		{	
			bitmap = new Bitmap();
			if (mode == COWBOW) {
				bitmap.bitmapData = settings.target.bitmap.bitmapData;
				bitmap.smoothing = true;
				bitmap.scaleX = bitmap.scaleY = 1;
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = 130 - bitmap.height / 2;
				bodyContainer.addChild(bitmap);
			}
			if (mode == FURRY || mode == COLLECTOR)
			{	
				bitmap.bitmapData = settings.target.bitmap.bitmapData;
				bitmap.smoothing = true;
				if (settings.info.sID == 164) 
				{
					bitmap.scaleX = bitmap.scaleY = 1.2;
				}else {
					bitmap.scaleX = bitmap.scaleY = 0.7;
				}
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = 130 - bitmap.height / 2;
				bodyContainer.addChild(bitmap);
			}
			if (mode == RESOURCE)
			{
				bitmap.bitmapData = settings.target.icon.bitmapData;
				bitmap.smoothing = true;
				
				if (bitmap.height > 140)
					bitmap.scaleX = bitmap.scaleY = 0.8;
				
				bitmap.x = background2.x + (background2.width - bitmap.width) / 2;
				bitmap.y = background2.y + (background2.height - bitmap.height) / 2 - 10;
				
				layer.addChild(bitmap);
			}
		}
		
		private function drawButtons():void 
		{
			if (collectBttn != null)
			{
				bodyContainer.removeChild(collectBttn);
			}
			var timer:Bitmap = new Bitmap(Window.textures.timerBrown, "auto", true);
			
			var bttnTxt:String = Locale.__e("flash:1403870467181");
			
			if (mode == COLLECTOR || mode == COWBOW)
				bttnTxt = "";
			
			collectBttnObj = {
				title			:Locale.__e("flash:1403870467181"),
				width			:240,
				height			:53,	
				fontSize		:26,
				radius			:20,
				countText		:TimeConverter.timeToCuts(timeNeed, true, true),
				multiline		:true,
				hasDotes		:false,
				hasText2		:true,
				fontCountSize	:26,
				fontCountColor	:0xffffff,
				fontCountBorder :0x814f31,
				textAlign		: "left",	
				bgColor			:[0xf5d058, 0xeeb331],
				bevelColor		:[0xfeee7b, 0xbf7e1a],
				fontBorderColor :0x814f31,
				iconScale		:1,
				iconFilter		:0x814f31
			};
			
			var bttnX:int;
			var bttnY:int;
;
			if (mode == FURRY || mode == COLLECTOR || mode == COWBOW)
			{	
				if (mode == COLLECTOR || mode == COWBOW)
					collectBttnObj['title'] = settings.bttnText;
				bttnX = 63;
				bttnY = 300;
			}
			if (mode == RESOURCE)
			{	
				collectBttnObj.title = Locale.__e('flash:1403882956073');
				timeNeed = capacity * settings.target.info.time;  
				collectBttnObj.countText = TimeConverter.timeToCuts(timeNeed, true, true);
				bttnX = 113;
				bttnY = 283;
			}
			
			collectBttn = new MixedButton2(timer, collectBttnObj);
			
			if (mode == RESOURCE)
			{	if (collectBttn.countLabel.textWidth <= 50)
				{
					collectBttn.textLabel.x = 35;
				} else collectBttn.textLabel.x = 10;
				
				collectBttn.textLabel.x = 25;
				collectBttn.coinsIcon.x = collectBttn.textLabel.x + collectBttn.textLabel.textWidth + 10;
				collectBttn.countLabel.x = collectBttn.coinsIcon.x + collectBttn.coinsIcon.width + 3;
				collectBttn.countLabel.y = collectBttn.textLabel.y + 1;
				collectBttn.countLabel.textWidth;
				
				
			}
			collectBttn.addEventListener(MouseEvent.CLICK, onCollect);
			collectBttn.x = bttnX;
			collectBttn.y = bttnY;
			
			bodyContainer.addChild(collectBttn);
		}
		
		private function showMoneyTargets():void
		{
			var possibleSIDs:Array = [];
			for (var id:* in App.data.storage) {
				if (App.data.storage[id].type == "Moneyhouse") {
					possibleSIDs.push(id);
				}
			}
			var hutTargets:Object = { };
			for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Moneyhouse in possibleTargets)
			{
				if (res.busy == 1 || res.hasProduct || res.colector) continue;
				res.state = res.HIGHLIGHTED;
				res.canCollector = true;
				//Moneyhouse.waitForTarget = true;
			}
		}
		
		private function showAnimalTargets():void 
		{
			var possibleSIDs:Array = [];
			for (var id:* in App.data.storage) {
				if (App.data.storage[id].type == "Animal") {
					possibleSIDs.push(id);
				}
			}
			var hutTargets:Object = { };
			for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Animal in possibleTargets)
			{
				if (res.hasProduct || res.cowboy) continue;
				res.state = res.HIGHLIGHTED;
				res.canAddCowboy = true;
			}
		}
		
		private function showResTargets():void
		{
			var possibleSIDs:Array = [];
			for (var id:* in App.data.storage) {
				if (App.data.storage[id].type == "Resource") {
					possibleSIDs.push(id);
				}
			}
			var hutTargets:Object = { };
			for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Resource in possibleTargets)
			{
				if (res.busy == 1 || res.isTarget) continue;
				res.state = res.HIGHLIGHTED;
				Resource.isFurryTarget = true;
			}
			/*setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			}, 100);*/
		}
		
		private function unselectPossibleTargets(e:MouseEvent):void
		{
			if (App.self.moveCounter > 3)
				return;
				
			App.self.removeEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			
			if (mode == COLLECTOR) {
				Moneyhouse.waitForTarget = false;
				//Moneyhouse.collector = null;
			}else if (mode == COWBOW) { 
				Animal.waitForTarget = false;
			}else if (mode == FURRY) {
				Factory.waitForTarget = false;
			}
			
			App.ui.upPanel.hideHelp();
			for each(var res:* in possibleTargets)
			{
				res.state = res.DEFAULT;
				if (res.hasOwnProperty('canAddCowboy'))
					res.canAddCowboy = false;
				if(res.hasOwnProperty('canCollector'))	
					res.canCollector = false;
			}
		}
		
		private function onCollect(e:MouseEvent):void 
		{
			close();
			
			var workers:Array = Techno.freeTechno();
			if (mode != COWBOW && (workers == null || workers.length == 0)){
				App.ui.upPanel.onRobotEvent();
				return;
			}
			
			if (!App.user.stock.take(Stock.FANTASY, priceCount))
				return;
				
			if (mode == FURRY) {
				showResTargets();
				showTargets();
			}else if (mode == COLLECTOR) { 
				showMoneyTargets();
				showTargets();
			}else if (mode == COWBOW) { 
				showAnimalTargets();
				showTargets();
			}else{	
				var worker:Techno = workers[0];
				worker.autoEvent(settings.target, capacity);
			}
		}
		
		
		
		private var possibleTargets:Array = [];
		private var itemCount:int;
		private var countCalc:TextField;
		private var priceCalc:TextField;
		private var priceCount:int;
		private var timeNeed:int;
		private var collectBttnObj:Object;
		private var itemCapacityTf:TextField;
		private var bttnHelp:IconButton;
		
		private function showTargets():void
		{
			var txt:String;
			var widthBg:int = 250;
			
			if (mode == COLLECTOR) {
				Moneyhouse.waitForTarget = true;
				Moneyhouse.collector = settings.target;
				txt = Locale.__e('flash:1409127749657');
				widthBg = 350;
			}else if (mode == COWBOW) {
				Animal.waitForTarget = true;
				Cowboy.cowboy = settings.target;
				//Moneyhouse.collector = settings.target;
				txt = Locale.__e('flash:1409568558009');
			}else if (mode == FURRY) {
				Factory.waitForTarget = true;
				txt = Locale.__e("flash:1403870467181");
			}
			App.ui.upPanel.showHelp(Locale.__e(txt), widthBg);
			setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			}, 100);
		}
		
		private function shopBusyFurry():void
		{
			textSettings = {
				color:0xFFFFFF,
				borderColor:0x4b2e1a,
				fontSize:32,
				textAlign:"center"
			};
			
			var icon:BitmapData;
			var countTxt:String;
			
			if (mode == COWBOW) {
				countTxt = Cowboy.getBusyCowboys() + "/" + App.user.cowboys.length;
				icon = Window.textures.shepherdIco;
			}else {
				countTxt = Techno.getBusyTechno() + "/" + App.user.techno.length
				icon = UserInterface.textures.robotIcon;
			}
			
			robotIcon = new Bitmap(icon);
			robotIcon.x = settings.width/2 - 50;
			robotIcon.y = settings.height/2 + 85;
			if (mode == COWBOW) {
				robotIcon.scaleX = robotIcon.scaleY = 0.85;
				robotIcon.smoothing = true;
				robotIcon.x -= 5;
			}
			robotCounter = Window.drawText("-/-", textSettings);
			robotCounter.text 	=  countTxt;
			
			layer.addChild(robotIcon);
			layer.addChild(robotCounter);
			
			
			
			
			robotCounter.x = robotIcon.x + robotIcon.width - 20;
			robotCounter.y = robotIcon.y + 7;
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			
			exit.x = settings.width - exit.width;
			exit.y = 0;

			if (mode == RESOURCE)
			{	
				exit.x += 50;
			}
		}
		
		//public function clearWindow():void
		//{
			//collectBttn.removeEventListener(MouseEvent.CLICK, onCollect);
			//layer.removeChild(background2);
			//layer.removeChild(robotIcon);
			//layer.removeChild(robotCounter);
			//bodyContainer.removeChild(separator);
			//bodyContainer.removeChild(separator2);
			//bodyContainer.removeChild(bitmap);
			//bodyContainer.removeChild(collectBttn);
		//}
		
		override public function dispose():void
		{
			if(bttnHelp){
				bttnHelp.removeEventListener(MouseEvent.CLICK, onHelp);
				bttnHelp.dispose();
				bttnHelp = null;
			}
			super.dispose();
		}
	}

}