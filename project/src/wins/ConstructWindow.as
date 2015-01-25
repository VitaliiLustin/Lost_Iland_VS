package wins 
{
	/**
	 * ...
	 * @author ...
	 */
	import buttons.Button;
	import buttons.HardButton;
	import buttons.MixedButton2;
	import buttons.MoneyButton;
	import buttons.MoneySmallButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setInterval;
	import ui.Hints;
	import ui.UserInterface;
	import units.Factory;
	import units.Mining;
	import units.Storehouse;
	import units.Techno;
	import wins.elements.BankMenu;
	
	public class ConstructWindow extends Window
	{
		public var item:Object;
		
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		public var bitmapBack:Bitmap = new Bitmap(null, "auto", true);
		public var dx:int;
		public var dy:int;
		private var upgBttn:MixedButton2;
		private var skipBttn:MoneyButton;
		
		private var container:Sprite = new Sprite();
		
		private var backLine:Bitmap;
		private var backField:Bitmap;
		
		private var resources:Array = [];
		private var prices:Array = [];
		private var partList:Array = [];
		
		private var smallWindow:Boolean = false;
		
		private var bgHeight:int;
		private var isEnoughMoney:Boolean = false;
		private var buildingBackImage:Bitmap;
		private var skipPrices:Array = [];
		public function ConstructWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			settings["width"] = 556;
			settings["height"] = 490;
			settings["fontSize"] = 44;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			settings['popup'] = true;
			settings['background'] = "storageBackingMain";
			settings['onUpgrade'] = settings.onUpgrade;
			settings['upgTime'] = settings.upgTime || 0;
			settings['bttnTxt'] = settings.bttnTxt || Locale.__e('flash:1393580216438');
			
			settings['notChecks'] = settings.notChecks || false;
			
			if (settings.target is Storehouse || settings.target is Mining/* || settings.target is Storehouse || settings.target is Storehouse*/)
				settings['notChecks'] = true;
			
			if (settings.target.level == 0)
				settings['bttnTxt'] = Locale.__e('flash:1382952379806');
			
			super(settings);	
			for (var sID:* in settings.request) {
				switch(sID) {
					case Stock.FANTASY:
						prices.push({sid:sID, count:settings.request[sID]});
						break;
					case Stock.COINS:
						prices.push({sid:sID, count:settings.request[sID]});
						break;
					case Stock.FANT:
						prices.push({sid:sID, count:settings.request[sID]});
						break;
					case Techno.TECHNO:
						prices.push({sid:sID, count:settings.request[sID]});
						break;
					default:
						resources.push(sID);
						break
				}
			}
			
			/*for each(var price:* in App.data.storage[settings.target.sid].instance.p) 
				skipPrices.push(price);*/
				
			skipPrice = settings.target.info.devel.skip[settings.target.level + 1];
			
			if (resources.length == 0) smallWindow = true;
			
			prices.sortOn('sid', Array.NUMERIC);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.addEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
		}
		
		private function onStockChange(e:AppEvent):void 
		{
			isEnoughMoney = true;
			
			if(!lvlSmaller)
				upgBttn.state = Button.NORMAL;
			
			for (var i:int = 0; i < arrBttns.length; i++ ) {
				var bttn:Button = arrBttns[i];
				if (bttn.order == 1) bttn.removeEventListener(MouseEvent.CLICK, showFantasy);
				else if (bttn.order == 2)bttn.removeEventListener(MouseEvent.CLICK, showBankCoins);
				else if (bttn.order == 3)bttn.removeEventListener(MouseEvent.CLICK, showBankReals);
				else if (bttn.order == 4)bttn.removeEventListener(MouseEvent.CLICK, showTechno);
				bttn.dispose();
				bttn = null;
			}
			arrBttns.splice(0, arrBttns.length);
			
			
			if (needTxt && bodyContainer.contains(needTxt) ) {
				bodyContainer.removeChild(needTxt);
			}
			if (descCont && bodyContainer.contains(descCont) ) {
				bodyContainer.removeChild(descCont);
			}
			descCont = null;
			descCont = new Sprite();
			
			for (i = 0; i < partList.length; i++ ) {
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			if(prices.length > 0)drawDescription();
			if (!smallWindow) {
				createResources();
			}
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 8;
			exit.y = -10;
		}
		
		override public function drawBody():void 
		{
			drawBackImage();
			
			resizeBack();
			
			titleLabel.y = -16;
			titleLabel.x = (settings.width - titleLabel.width)/2;
			if (resources.length == 3) 
			{
				titleLabel.x = 70;
			}
			if (resources.length == 5) 
			{
				titleLabel.x = 170;
			}
			
			this.y += 40;
			fader.y -= 40;
			//smallWindow = true;
			bgHeight = settings.height; 
			if (smallWindow) {
				bgHeight = 200;
				this.y += 100;
				fader.y -= 100;
			}
			
			if (settings.hasState) {
				var underTitle:Bitmap = Window.backingShort(180, "orangeStripPiece");
				underTitle.x = (settings.width - underTitle.width) / 2;
				underTitle.y = 6;
				bodyContainer.addChild(underTitle);
				
				var subTitle:TextField = Window.drawText(Locale.__e("flash:1397573560652") + ": " +  settings.state + "/" + settings.statesTotal, {
					fontSize:24,
					color:0xFFFFFF,
					autoSize:"left",
					borderColor:0xb56a17
				});
				bodyContainer.addChild(subTitle);
				subTitle.x = settings.width / 2 - subTitle.width / 2;
				subTitle.y = underTitle.y + 8;
				
				bgHeight += 30;
				this.y -= 30;
				fader.y += 30;
			}
			
			drawBackgrounds();
			
			var stripe:Bitmap = Window.backingShort(300, "yellowRibbon");
			bodyContainer.addChildAt(stripe, 0);
			
			stripe.x = (settings.width - stripe.width) / 2;
			stripe.y = 20;
			
			
			var level:int = settings.target.level - (settings.target.totalLevels - settings.target.craftLevels);
			var totallevels:int = settings.target.craftLevels - 1;
			var txt:String = Locale.__e("flash:1403881753960");
			
			if (settings.target.type == 'Floors') {
				level = settings.target.level;
				totallevels = settings.target.totalLevels;
			}else if (settings.target.craftLevels == 0) {
				level = settings.target.level;
				totallevels = settings.target.totalLevels;
				txt = Locale.__e("flash:1382952380233");
			}else if (settings.target.level >= settings.target.totalLevels - settings.target.craftLevels + 1) {
				txt = Locale.__e("flash:1382952380233");
				level += 1;
				totallevels = settings.target.totalLevels;
			}else {
				level = settings.target.level + 1;
				totallevels = settings.target.totalLevels - totallevels;// + 1;
			}
			
			var needTxt:TextField = drawText(txt + " " + level + "/" + totallevels, {
				fontSize:24,
				color:0xffffff,
				borderColor:0x5b4814,
				textAlign:"center"
			});
			needTxt.width = needTxt.textWidth + 10;
			bodyContainer.addChild(needTxt);
			needTxt.x = (settings.width - needTxt.width) / 2;
			needTxt.y = stripe.y + 8;
			
			drawBttn();
			
			if(prices.length > 0)drawDescription();
			if (resources.length != 5)
			{
				drawMirrowObjs('diamondsTop', titleLabel.x + 120,titleLabel.x + titleLabel.width - 120, -35, true, true);
			}
			if (resources.length == 5)
			{
				drawMirrowObjs('diamondsTop', titleLabel.x + 60,titleLabel.x + titleLabel.width - 60, -35, true, true);
			}
			//drawMirrowObjs('storageWoodenDec', 85, settings.width - 85, settings.height - 115, true, true);
			
			
			storageWoodenDec1 = new Bitmap(Window.textures.storageWoodenDec);
			storageWoodenDec2 = new Bitmap(Window.textures.storageWoodenDec);
			storageWoodenDec1.y = storageWoodenDec2.y = 310;
			storageWoodenDec1.x = 7;
			storageWoodenDec2.x = settings.width - 7;
			storageWoodenDec2.scaleX = -1;
			bodyContainer.addChild(storageWoodenDec1);
			bodyContainer.addChild(storageWoodenDec2);
			
			
			drawMirrowObjs('diamonds', 24, settings.width - 24, 54, false, false, false,1,-1 );
			if (!smallWindow) {
				backField = Window.backing(settings.width - 80/*610*/, 240, 40, "storageBackingSmall2");  // бэкграунд с ингридиентами для улучшения
				bodyContainer.addChildAt(backField, 0);
				backField.x = (settings.width - backField.width) / 2;
				if (prices.length > 0) {
					backField.y = backLine.y + backLine.height + 10;
					bttnContainer.y = background.height - 75;
					storageWoodenDec1.y = storageWoodenDec2.y = background.height - 110;
				}else {
					background.height = 400;
					backField.y = 80;
					bttnContainer.y = background.height - 75;
					storageWoodenDec1.y = storageWoodenDec2.y = background.height - 110;
					if (settings.hasState)
						backField.y += 30;
				}
				recNeedTxt();
				//drawBttn();
				createResources();
				bodyContainer.addChildAt(container,numChildren - 1);
				container.x = backField.x + (backField.width - container.width)/2;
				container.y = backField.y + 26;
			}			
			
			windowUpdate();
		}
		
		private function drawBackImage():void 
		{
			/*var levelData:Object = settings.target.textures.sprites[settings.target.level + 1];
			
			buildingBackImage = new Bitmap(settings.target.bitmap.bitmapData);
			buildingBackImage.x = (settings.width  - buildingBackImage.width)/2 + 50;
			buildingBackImage.y = -buildingBackImage.height + buildingBackImage.height/3;
			//bodyContainer.addChild(buildingBackImage);
			if (resources.length == 5) 
			{
				buildingBackImage.x = (settings.width  - buildingBackImage.width)/2 + 130;
			}*/
		}
		
		private function windowUpdate():void 
		{
			if (upgBttn.mode == DISABLED)
			{
				//background.height = bgHeight;
				backField.height = 256;
				//bttnContainer.y = bgHeight - 80;
				//storageWoodenDec1.y = storageWoodenDec2.y = bgHeight - 120;
			}else if (backLine != null)	{
				var hgNew:int = bgHeight - 26;
				background.height = hgNew;
				backField.height = 206;
				bttnContainer.y = hgNew - 80;
				storageWoodenDec1.y = storageWoodenDec2.y = hgNew - 120;
			} 
		}
		private function resizeBack():void 
		{
			if (resources.length == 6) 
			{
				settings.width = 940;
				exit.x = -exit.width + settings.width;
			}
			if (resources.length == 5) 
			{
				settings.width = 800;
				exit.x = -exit.width + settings.width;
			}
			if (resources.length == 4) 
			{
				settings.width = 660;
				exit.x = -exit.width + settings.width;
			}
			if (resources.length == 3 && buildingBackImage) 
			{
				buildingBackImage.x = settings.width/2 - buildingBackImage.width/2;
			}
		}
		
		private var lvlSmaller:Boolean = false;
		private function drawBttn():void
		{	
			bttnContainer = new Sprite();
			
			var timer:Bitmap = new Bitmap(Window.textures.timerBrown, "auto", true);
			var timeUpg:int = settings.upgTime;
			if (timeUpg == 0)
				timeUpg = settings.target.info.devel.req[settings.target.level + 1].t;
			
			var count:String = Locale.__e(TimeConverter.timeToCuts(timeUpg, true, true));
			
			var bttnUpgSettings:Object = {
				title			:Locale.__e(settings.bttnTxt),
				width			:230,
				height			:63,	
				fontSize		:26,
				radius			:20,
				countText		:count,
				multiline		:true,
				hasDotes		:false,
				hasText2		:true,
				fontCountSize	:28,
				fontCountColor	:0xffffff,
				fontCountBorder :0x623126,
				textAlign		: "left",	
				bgColor			:[0xf5d058, 0xeeb331],
				bevelColor		:[0xfeee7b, 0xbf7e1a],
				fontBorderColor :0x814f31,
				iconScale		:1,
				iconFilter		:0x814f31
			}
			if (count == "") 
			{
				bttnUpgSettings["width"] = 220;
				bttnUpgSettings["title"] = Locale.__e("flash:1382952379806");
			}
			
			
			if (App.user.level < App.data.storage[settings.target.sid].devel.req[settings.target.level + 1].l) {
				timer = new Bitmap(UserInterface.textures.expIcon);
				bttnUpgSettings["title"] = Locale.__e("flash:1404210887391");
				bttnUpgSettings["countText"] = App.data.storage[settings.target.sid].devel.req[settings.target.level + 1].l;
				lvlSmaller = true;
			}else if (timeUpg == 0) {
				bttnUpgSettings['width'] = 160;
			}
			
			upgBttn = new MixedButton2(timer, bttnUpgSettings);
			upgBttn.coinsIcon.x = upgBttn.textLabel.x + upgBttn.textLabel.textWidth + 14;
			upgBttn.coinsIcon.y -= 2;
			upgBttn.countLabel.x = upgBttn.coinsIcon.x + upgBttn.coinsIcon.width + 5;
			upgBttn.countLabel.y += 9;
			upgBttn.topLayer.x = (upgBttn.settings.width - upgBttn.topLayer.width) / 2 - 10;
			
			if (count == "")
			{
				//upgBttn.textLabel.border = true;
			}
			
			if (lvlSmaller) {
				upgBttn.countLabel.x = upgBttn.coinsIcon.x + (upgBttn.coinsIcon.width - upgBttn.countLabel.width) / 2;
				upgBttn.topLayer.x += 10;
				upgBttn.state = Button.DISABLED;
			}
			
			if (App.user.quests.tutorial) {
				upgBttn.showGlowing();
				upgBttn.showPointing('top', 0, 0, upgBttn);//bttnContainer);
				App.user.quests.currentTarget = upgBttn;
				App.user.quests.lock = false;
			}
			
			bttnContainer.addChild(upgBttn);
			upgBttn.addEventListener(MouseEvent.CLICK, onUpgrade);
			
			drawSkpBttn();
			
			bodyContainer.addChild(bttnContainer);
			bttnContainer.x = (settings.width - bttnContainer.width) / 2
		}
		
		private function drawSkpBttn():void {
			skipBttn = new MoneyButton( {
				caption			:Locale.__e('flash:1393580216438'),
				width			:140,
				height			:48,	
				fontSize		:22,
				textLeading		:-5
			});
			skipBttn.count = String(skipPrice);			
			skipBttn.x = 0;
			skipBttn.y = 7;
			upgBttn.x = skipBttn.width +  20;
			
			skipBttn.addEventListener(MouseEvent.CLICK, onSkip);
			
			var banner:Bitmap = Window.backingShort(skipBttn.width + 20, 'greenBanner', true);
			bttnContainer.addChild(banner);
			banner.x = skipBttn.x - 10;
			banner.y = skipBttn.y - 22;
			
			var bannerText:TextField = Window.drawText(Locale.__e("flash:1404227180894"), {
				fontSize:19,
				color:0xfff9a9,
				borderColor:0x5c4414,
				border:true,
				textAlign:'center',
				multiline:true,
				wrap:true,
				textLeading	: 2,
				width:110
			});
			bannerText.x = banner.x + (banner.width - bannerText.width)/2;
			bannerText.y = banner.y + banner.height - 70;
			
			bttnContainer.addChild(bannerText);
			bttnContainer.addChild(skipBttn);
			
			if (settings.target.helpTarget)
				skipBttn.showGlowing();
		}
		
		private function onSkip(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			close();
			e.currentTarget.state = Button.DISABLED;
			
			settings.onUpgrade(settings.request, skipPrice);
			
			//if(settings.hasState)
				//settings.onUpgrade(settings.request);
			//else
				//settings.onUpgrade(settings.target.info.devel.obj[settings.target.level + 1]);
		}
		
		override public function drawBackground():void 
		{
			
		}
		
		private var iconTarget:Bitmap = new Bitmap();
		private function drawBackgrounds():void
		{
			if (prices.length == 0) bgHeight -= 50;
			
			background = backing(settings.width, bgHeight, 45, "storageBackingMain"); // основной бэкграунд
			layer.addChild(background);
		   
			//var btmd:BitmapData;
			//if (settings.target.sid == 160 || settings.target.sid == 178)
				//btmd = settings.target.textures.sprites[0].bmp;
			//else if (settings.target.textures.sprites[settings.target.level + 1])
				//btmd = settings.target.textures.sprites[settings.target.level + 1].bmp;
			//else 
				//btmd = settings.target.bitmap.bitmapData;
			
			var itm:Object = App.data.storage[settings.target.sid];
			Load.loading(Config.getIcon(itm.type, itm.preview), onPreviewComplete);
			
			//var bitmap:Bitmap = new Bitmap(btmd);
			bodyContainer.addChildAt(iconTarget, 0);
			//if (bitmap.height > 190) bitmap.height = 180;
			//bitmap.scaleX = bitmap.scaleY;
			//bitmap.smoothing = true;
			//bitmap.x = (settings.width - bitmap.width) / 2 + 15;
			//bitmap.y = (27 - bitmap.height) + 35;
			
			if (prices.length > 0){
				backLine = new Bitmap(Window.textures.plate);// узкая полоса с наградой
				bodyContainer.addChild(backLine);
				backLine.x = (settings.width - backLine.width) / 2;
				backLine.y = 80;
			}
			
			if (settings.hasState)
				backLine.y += 30;
		}
		
		private function onPreviewComplete(data:Bitmap):void 
		{
			iconTarget.bitmapData = data.bitmapData;
			iconTarget.smoothing = true;
			iconTarget.x = (settings.width - iconTarget.width) / 2;
			iconTarget.y = (27 - iconTarget.height);
		}
		
		private var needTxt:TextField;
		private var descCont:Sprite = new Sprite();
		private var arrBttns:Array = [];
		private var numResourses:int;
		private var storageWoodenDec1:Bitmap;
		private var storageWoodenDec2:Bitmap;
		private var skipPrice:int;
		private var bttnContainer:Sprite;
		
		//private var background:Bitmap;
		
		private function drawDescription():void 
		{
			var posX:int = 0;
			
			bodyContainer.addChild(descCont);
			
			needTxt = drawText(Locale.__e("flash:1383042563368"), {
				fontSize:28,
				color:0xffffff,
				borderColor:0x5b4814
			});
			bodyContainer.addChild(needTxt);
			needTxt.width = needTxt.textWidth + 5;
			needTxt.height = needTxt.textHeight;
			needTxt.y = backLine.y - needTxt.height + 18;
			needTxt.x = backLine.x + (backLine.width - needTxt.width) / 2;
			
			var contIcon:LayerX = new LayerX();
			
			for (var i:int = 0; i < prices.length; i++ ) {
				var icon:Bitmap;
				var color:int;
				var boderColor:int;
				
				var bttn:Button;
				var bttnSettings:Object = { 
					fontSize:20,
					caption:Locale.__e("flash:1382952379751"),
					height:30,
					width:94,
					radius : 12
				};
				switch(prices[i].sid) {
					case Stock.FANTASY:
						icon = new Bitmap(UserInterface.textures.energyIcon);
						icon.y = 7;
						if (App.user.stock.count(prices[i].sid) < prices[i].count) {
							
							bttnSettings['bgColor'] = [0xa9f84a, 0x73bb16];
							bttnSettings['borderColor'] = [0xffffff, 0xffffff];
							bttnSettings['bevelColor'] = [0xc5fe78, 0x5f9c11];
							bttnSettings['fontColor'] = 0xffffff;				
							bttnSettings['fontBorderColor'] = 0x518410;
							
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showFantasy);
							bttn.order = 1;
						}
						break;
					case Stock.COINS:
						icon = new Bitmap(UserInterface.textures.coinsIcon);
						icon.y = 7;
						if(App.user.stock.count(prices[i].sid) < prices[i].count){
							bttn = new Button( bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showBankCoins);
							bttn.order = 2;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16
						break;
					case Stock.FANT:
						icon = new Bitmap(UserInterface.textures.fantsIcon);
						icon.y = 7;
						if(App.user.stock.count(prices[i].sid) < prices[i].count){
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showBankReals);
							bttn.order = 3;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16
						break;
					case Techno.TECHNO:
						icon = new Bitmap(UserInterface.textures.robotIcon);
						icon.y = 7;
						if((App.user.techno.length - Techno.getBusyTechno()) < prices[i].count){
							bttn = new Button(bttnSettings);
							bttn.addEventListener(MouseEvent.CLICK, showTechno);
							bttn.order = 4;
						}
						color = 0xfff1cf;
						boderColor = 0x482e16;
						
						break;
				}
				if (prices[i].sid == Stock.TECHNO && (App.user.techno.length - Techno.getBusyTechno()) < prices[i].count) {
					color = 0xef7563;
					boderColor = 0x623126;
					isEnoughMoney = false;
					upgBttn.state = Button.DISABLED;
					//intervalPluck = setInterval(function():void { if(contIcon && !contIcon.isPluck)contIcon.pluck(30, 25, 25)}, Math.random()* 5000 + 4000);
				}else if (prices[i].sid != Stock.TECHNO  && App.user.stock.count(prices[i].sid) < prices[i].count) {
					color = 0xef7563;
					boderColor = 0x623126;

					isEnoughMoney = false;
					upgBttn.state = Button.DISABLED;
					//intervalPluck = setInterval(function():void { if(contIcon && !contIcon.isPluck)contIcon.pluck(30, 25, 25)}, Math.random()* 5000 + 4000);
				}else {
					color = Window.getTextColor(prices[i].sid).color;
					boderColor = Window.getTextColor(prices[i].sid).borderColor;
				}
				
				icon.smoothing = true;
				descCont.addChild(icon);
				icon.x = posX;
				
				var counTxt:TextField = drawText(String(prices[i].count), {
					fontSize:30,
					color:color,
					borderColor:boderColor
				});
			
				counTxt.width = counTxt.textWidth + 5;
				counTxt.height = counTxt.textHeight;
				counTxt.x = icon.x + icon.width + 5;
				counTxt.y = 12;
				
				descCont.addChild(counTxt);
				
				if (bttn) {
					bttn.x = icon.x + (icon.width + counTxt.textWidth + 5 - bttn.width) / 2;
					bttn.y = 52;
					descCont.addChild(bttn);
					arrBttns.push(bttn);
					bttn = null;
				}
				
				posX = counTxt.x + counTxt.width + 30;
			}
			bodyContainer.addChild(descCont);
			
			//sprite.x = backLine.x + (backLine.width- sprite.width)/2;
			//sprite.y = backLine.y + 10;
			
			descCont.x = backLine.x + (backLine.width- descCont.width)/2;
			descCont.y = backLine.y + 10;
			
		}
		
		private function showTechno(e:MouseEvent):void
		{
			var arrFactories:Array = Map.findUnits([Factory.TECHNO_FACTORY]);
			if (arrFactories.length > 0) {
				
				App.ui.upPanel.onRobotEvent(e);
			}else {
				App.ui.upPanel.onRobotEvent(e);
				
				//new ShopWindow( { find:[Factory.TECHNO_FACTORY], forcedClosing:true, popup: true } ).show();
			}
		}
		
		private function showBankReals(e:MouseEvent):void 
		{
			BankMenu._currBtn = BankMenu.REALS;
			BanksWindow.history = {section:'Reals',page:0};
			new BanksWindow( { popup:true } ).show();

		}
		
		private function showBankCoins(e:MouseEvent):void 
		{
			BankMenu._currBtn = BankMenu.COINS;
			BanksWindow.history = {section:'Coins',page:0};
			new BanksWindow( { popup:true } ).show();
		}
		
		private function showFantasy(e:MouseEvent):void 
		{
			new PurchaseWindow( {
				popup:true,

				width:716,
				itemsOnPage:4,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}),
				title:Locale.__e("flash:1382952379756"),
				description:Locale.__e("flash:1382952379757"),
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
		}
		
		private function recNeedTxt():void
		{
			var txt:String;
			if (prices.length > 0) 
				txt = Locale.__e("flash:1393580288027") + ":";
			else 
				txt = Locale.__e("flash:1393854850716") + ":";
			
			var needTxt:TextField = drawText(txt, {
				fontSize:28,
				color:0xffffff,
				borderColor:0x5b4814
			});
			bodyContainer.addChild(needTxt);
			needTxt.width = needTxt.textWidth + 5;
			needTxt.height = needTxt.textHeight;
			needTxt.y = backField.y - needTxt.height + 30;
			needTxt.x = backField.x + (backField.width - needTxt.width)/2;
		}
		
		private function createResources():void
		{
			var offsetX:int = 0;
			var offsetY:int = 0;
			var dX:int = 0;
			
			var count:int = 0;
			for each(var sID:* in resources) 
			{
				var inItem:MaterialItem = new MaterialItem({
					sID:sID,
					need:settings.request[sID],
					window:this, 
					type:MaterialItem.IN,
					color:0x5a291c,
					borderColor:0xfaf9ec,
					bitmapDY: -10,
					bgItemY:38,
					bgItemX:20
				}, new Bitmap(Window.textures.bgItem));
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				
				container.addChild(inItem);
				inItem.x = offsetX - 2;
				
				count++;
				
				offsetX += inItem.background.width - 10/* + dX*/;
				inItem.background.visible = false;
			}
			
			inItem.dispatchEvent(new WindowEvent(WindowEvent.ON_CONTENT_UPDATE));
		}
		
		public function onUpdateOutMaterial(e:WindowEvent):void {
			var outState:int = MaterialItem.READY;
			for each(var item:* in partList) {
				if(item.status != MaterialItem.READY){
					outState = item.status;
				}
			}
			
			if (outState == MaterialItem.UNREADY) {
				
				upgBttn.state = Button.DISABLED;
			}
			else if (isEnoughMoney && !lvlSmaller) {
				
				upgBttn.state = Button.NORMAL; 
				windowUpdate();
			}
		}
		
		private function onUpgrade(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED) return;
			close();
			e.currentTarget.state = Button.DISABLED;
			
			if(settings.hasState)
				settings.onUpgrade(settings.request);
			else
				settings.onUpgrade(settings.target.info.devel.obj[settings.target.level + 1]);
			
			if (App.user.quests.tutorial)
				App.tutorial.nextStep(5, 6);
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, onStockChange);
			App.self.removeEventListener(AppEvent.ON_TECHNO_CHANGE, onStockChange);
			
			if (upgBttn) {
				upgBttn.removeEventListener(MouseEvent.CLICK, onUpgrade);
				upgBttn.dispose();
				upgBttn = null;
			}
			
			for (var i:int = 0; i < arrBttns.length; i++ ) {
				var bttn:Button = arrBttns[i];
				if (bttn.order == 1) bttn.removeEventListener(MouseEvent.CLICK, showFantasy);
				else if (bttn.order == 2)bttn.removeEventListener(MouseEvent.CLICK, showBankCoins);
				else if (bttn.order == 3)bttn.removeEventListener(MouseEvent.CLICK, showBankReals);
				else if (bttn.order == 4)bttn.removeEventListener(MouseEvent.CLICK, showTechno);
				bttn.dispose();
				bttn = null;
			}
			arrBttns.splice(0, arrBttns.length);
			
			if (needTxt && bodyContainer.contains(needTxt) ) {
				bodyContainer.removeChild(needTxt);
			}
			
			for (i = 0; i < partList.length; i++ ) {
				var itm:MaterialItem = partList[i];
				if (itm.parent) itm.parent.removeChild(itm);
				itm.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				itm.dispose();
				itm = null;
			}
			partList.splice(0, partList.length);
			
			super.dispose();
		}
		
	}		
}
