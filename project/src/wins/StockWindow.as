package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Storehouse;
	import wins.elements.SearchMaterialPanel;

	public class StockWindow extends Window
	{
		public static var showUpgBttn:Boolean = true;
		public static const ARTIFACTS:int = 1;
		public static const DEFAULT:int = 00;
		
		public static var mode:int = DEFAULT;
		
		public var sections:Object = new Object();
		public var icons:Array = new Array();
		public var items:Vector.<StockItem> = new Vector.<StockItem>();
		
		public static var history:Object = { section:"all", page:0 };
		
		public var makeBiggerBttn:Button;
		
		public var capasitySprite:LayerX = new LayerX();
		private var capasitySlider:Sprite = new Sprite();
		private var capasityCounter:TextField;
		public var capasityBar:Bitmap;
		
		public function StockWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			
			settings["find"] = settings.find || null;
			
			settings["title"] = settings.title || Locale.__e("flash:1382952379767");
			settings["width"] = 660;
			settings["height"] = 545;
			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 6;
			settings["background"] = 'storageBackingMain';
			mode = settings.mode || DEFAULT;
			
			//settings["hasPaginator"] = false;
			//settings["footerImage"] = 'stock';
			var stocks:Array = Map.findUnits([Storehouse.SILO]);
			settings["target"] = stocks[0];
			
			createContent();
			
			findTargetPage(settings);
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
		}
		
		override public function dispose():void {
			super.dispose();
			
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, refresh);
			
			if (capasitySprite.parent) capasitySprite.parent.removeChild(capasitySprite);
			if (capasitySlider.parent) capasitySlider.parent.removeChild(capasitySlider);
			capasitySprite = null;
			capasitySlider = null;
			capasityCounter = null;
			capasityBar = null;
			
			for each(var item:* in items) {
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				icon.dispose();
				icon = null;
			}
		}
		
		override public function drawBackground():void
		{
			var upperBackground:Bitmap = new Bitmap(Window.textures.storageUpperBacking);
			layer.addChild(upperBackground);
			upperBackground.x = 10;
			upperBackground.y = 0;
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			layer.addChild(background);
			background.x = -10;
			background.y = 40;
			
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
					
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
				
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawExit():void {
				var exit:ImageButton = new ImageButton(textures.closeBttn);
				headerContainer.addChild(exit);
				exit.x = settings.width - 54;
				exit.y = 2;
				exit.addEventListener(MouseEvent.CLICK, close);
			}
		
		private function findTargetPage(settings:Object):void {
			for (var section:* in sections){
				for (var i:* in sections[section].items) {
					
					var sid:int = sections[section].items[i].sid;
					if (settings.find != null && settings.find.indexOf(sid) != -1) {
						
						history.section = section;
						history.page = int(int(i) / settings.itemsOnPage);
						
						settings.section = history.section;
						settings.page = history.page;
						return;
					}
				}
			}
		}
		
		public function createContent():void {
			
			if (sections["all"] != null) return;
			artifacts = [];
			
			sections = {
				"all":{items:new Array(),page:0},
				"harvest":{items:new Array(),page:0},
				"jam":{items:new Array(),page:0},
				"materials":{items:new Array(),page:0},
				"workers":{items:new Array(),page:0},
				"others":{items:new Array(),page:0}
			};
			
			var section:String = "all";
			
			for(var ID:* in App.user.stock.data) {
				var count:int = App.user.stock.data[ID];
				var item:Object = App.data.storage[ID];
				if(item == null)	continue;
				if (count < 1) 		continue;
				
				if (notShow(ID)) continue;
				//Пропускаем деньги
				//if ('gct'.indexOf(item.type) != -1) continue;
				switch(item.type){
					case 'Material':
				
						if (item.mtype == 0) {
							section = "materials";
						}else if (item.mtype == 1) {
							section = "harvest";
						//}else if (item.mtype == 2) {
						//	section = "jam";
						}else if (item.mtype == 3 || item.mtype == 4) {
							//Пропускаем системные
							continue;
						}else{
							section = "others";
						}
						break;
					case 'Jam':
					case 'Clothing':
					case 'Lamp':
					case 'Guide':
							continue;
						break;
					default:
						section = "others";
						break;	
				}
				item["sid"] = ID;
				
				if (item.artifact) {
					artifacts.push(item);
					continue;
				}
				
				sections[section].items.push(item);
				sections["all"].items.push(item);
			}
			
			if (mode == ARTIFACTS) {
				sections["all"].items = artifacts;
			}
		}
		
		private var artifacts:Array = [];
		
		private var separator:Bitmap;
		private var separator2:Bitmap;
		private var seachPanel:SearchMaterialPanel;
		override public function drawBody():void {
			
			drawBacking();
			setContentSection(settings.section,settings.page);
			contentChange();
			
			seachPanel = new SearchMaterialPanel( {
				win:this, 
				callback:showFinded,
				stop:onStopFinding,
				hasIcon:false,
				caption:Locale.__e('flash:1382952380300')
			});
			bodyContainer.addChild(seachPanel);
			seachPanel.y = paginator.y + 23;
			seachPanel.x = 8;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, 5, true, true);
			drawMirrowObjs('storageWoodenDec', -5, settings.width - 10, 79, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -5, settings.width - 10, settings.height - 72);
			
			
			/*separator = Window.backingShort(160, 'separator3');
			separator.alpha = 0.5;
			separator.x = settings.backX;
			separator.y = 84;*/
			
			/*separator2 = Window.backingShort(160, 'separator3');
			separator2.alpha = 0.5;
			separator2.x = settings.backX + settings.backWidth - separator2.width;
			separator2.y = 84;*/
			
			/*bodyContainer.addChild(separator);
			bodyContainer.addChild(separator2);*/
			
			if(settings.target){
				if(settings.target.level < settings.target.totalLevels && showUpgBttn && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					drawBttns();
				}
				if(settings.target.level <= settings.target.totalLevels && showUpgBttn && !settings.target.hasPresent && settings.target.hasBuilded && settings.target.hasUpgraded){
					addSlider();
				}
				else if(settings.target.upgradedTime > 0 && !settings.target.hasUpgraded){
					drawUpgradeInfo();
				}else {
					drawBigSaparator();
				}
			}else {
				drawBigSaparator();
			}
			//addSlider();
		}
		
		private var priceSpeed:int = 0;
		//private var priceBttn:int = 0;
		private var totalTime:int = 0;
		private var finishTime:int = 0;
		private var boostBttn:MoneyButton;
		private var upgTxt:TextField;
		private function drawUpgradeInfo():void 
		{
			if(separator)
				bodyContainer.removeChild(separator);
			if(separator2)
				bodyContainer.removeChild(separator2);
			separator = null;
			separator2 = null;
			
			var time:int = 0;
			if (settings.target.created > 0 && !settings.target.hasBuilded) {
				time = settings.target.created - App.time;
				
				var curLevel:int = settings.target.level + 1;
				if (curLevel >= settings.target.totalLevels) curLevel = settings.target.totalLevels;
				finishTime = settings.target.created;
				totalTime = App.data.storage[settings.target.sid].devel.req[1].t;
			}else if (settings.target.upgradedTime > 0 && !settings.target.hasUpgraded) {
				time = settings.target.upgradedTime - App.time;
				
				finishTime = settings.target.upgradedTime;
				totalTime = App.data.storage[settings.target.sid].devel.req[settings.target.level+1].t;
			}
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				
				textAlign:"left"
			};
			
			upgTxt = Window.drawText(Locale.__e('flash:1402905682294') + " " + TimeConverter.timeToStr(time), textSettings); 
			upgTxt.width = upgTxt.textWidth + 10;
			upgTxt.height = upgTxt.textHeight;
			
			bodyContainer.addChild(upgTxt);
			upgTxt.x = 70;
			upgTxt.y = 44;
			
			
			priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
			
			boostBttn = new MoneyButton({
					caption		:Locale.__e('flash:1382952380104'),
					width		:102,
					height		:63,	
					fontSize	:24,
					countText	:15,
					multiline	:true,
					radius:20,
					iconScale:0.67,
					fontBorderColor:0x4d7d0e,
					fontCountBorder:0x4d7d0e,
					notChangePos:true
			});
			boostBttn.x = upgTxt.x + upgTxt.width + 10;
			boostBttn.y = 32;
			bodyContainer.addChild(boostBttn);
			
			boostBttn.textLabel.y -= 12;
			boostBttn.textLabel.x = 0;
			
			boostBttn.coinsIcon.y += 12;
			boostBttn.coinsIcon.x = 2;
			
			boostBttn.countLabel.y += 12;
			boostBttn.countLabel.x = boostBttn.coinsIcon.x + boostBttn.coinsIcon.width + 6;
			
			var txtWidth:int = boostBttn.textLabel.width;
			if ((boostBttn.coinsIcon.width + 6 + boostBttn.countLabel.width) > txtWidth) {
				txtWidth = boostBttn.coinsIcon.width + 6 + boostBttn.countLabel.width;
				boostBttn.textLabel.x = (txtWidth - boostBttn.textLabel.width) / 2;
			}
			boostBttn.topLayer.x = (boostBttn.settings.width - txtWidth)/2;
			
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
			updateTime();
			App.self.setOnTimer(updateTime);
		}
		
		private function onBoostEvent(e:MouseEvent = null):void
		{
			if (settings.doBoost)
				settings.doBoost(priceBttn);
			else
				settings.target.acselereatEvent(priceBttn);
			close();
		}
		
		private var priceBttn:int;
		private function updateTime():void
		{
			var time:int = 0;
			if (settings.target.created > 0 && !settings.target.hasBuilded) {
				time = settings.target.created - App.time;
			}else if (settings.target.upgradedTime > 0 && !settings.target.hasUpgraded) {
				time = settings.target.upgradedTime - App.time;
			}
			
			if (time < 0) {
				App.self.setOffTimer(updateTime);
				close();
				return;
			}
			
			upgTxt.text = Locale.__e('flash:1402905682294') + " " + TimeConverter.timeToStr(time);
			
			
			priceSpeed = Math.ceil((finishTime - App.time) / App.data.options['SpeedUpPrice']);
			
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
			
		}
		
		private function drawBigSaparator():void
		{
			/*bodyContainer.removeChild(separator);
			bodyContainer.removeChild(separator2);
			separator = null;
			separator2 = null;*/
			
			/*separator = Window.backingShort(580, 'separator3');
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			separator.x = settings.backX;
			separator.y = 84;*/
		}
		
		private function addSlider():void
		{
			capasityBar = new Bitmap(Window.textures.prograssBarBacking);			
			if (mode == StockWindow.ARTIFACTS)
				capasityBar.x = 0;
			
			capasityBar.y = 22;
			Window.slider(capasitySlider, 60, 60, "progressBar");
			
			bodyContainer.addChild(capasitySprite);
			
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				
				textAlign:"center"
			};
			
			//textSettings.fontSize = 24;
			capasityCounter = Window.drawText(Stock.value +'/'+ Stock.limit, textSettings);
			capasityCounter.width = 120;
			capasityCounter.height = capasityCounter.textHeight;
			
			capasitySprite.mouseChildren = false;
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			capasitySprite.addChild(capasityCounter);
			
			//capasitySlider.x = (capasityBar.width - capasitySlider.width)/2; capasitySlider.y = (capasityBar.height - capasitySlider.height)/2;
			capasitySlider.x = capasityBar.x + 10; 
			capasitySlider.y = capasityBar.y + 6;
			
			if (settings.target.level < settings.target.totalLevels)
			{
				capasitySprite.x = settings.width / 2 - capasityBar.width / 2 - 85; 
				capasitySprite.y = 17;
			}else
			{
				capasitySprite.x = settings.width / 2 - capasityBar.width / 2; 
				capasitySprite.y = 17;
			};
			
			
			capasityCounter.x = capasityBar.x + (capasityBar.width / 2 - capasityCounter.width / 2); 
			capasityCounter.y = capasityBar.y - capasityBar.height / 2 + capasityCounter.textHeight / 2 + 8;
			
				
			updateCapasity(Stock.value, Stock.limit);
		}
		
		public function updateCapasity(currValue:int, maxValue:int):void
		{
			if (mode == ARTIFACTS) {
				currValue = Stock._value_mag;
				maxValue = Stock.limit_mag;
			}else {
				currValue = Stock.value;
				maxValue = Stock.limit;
			}
			
			if (capasitySlider) 
			{
				if (currValue < 0)
					currValue = 0;
				
				Window.slider(capasitySlider, currValue, maxValue, "progressBar");
				
				if(capasityCounter){
					capasityCounter.text = currValue +'/' + maxValue;
					capasityCounter.x = capasityBar.x + (capasityBar.width / 2 - capasityCounter.width / 2);
				}
			}
		}
		
		private function drawBttns():void 
		{
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1393580216438", [settings.target.info.devel.req[settings.target.level + 1].c]), //flash:1396609462757
				fontSize:24,
				width:140,
				height:37,
				radius:15,	
				textAlign:"center",
				hasDotes:false
			};
			
			makeBiggerBttn = new Button(bttnSettings);
			bodyContainer.addChild(makeBiggerBttn);
			makeBiggerBttn.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1393580216438", [settings.target.info.devel.req[settings.target.level + 1].c]) //flash:1396609462757
				};
			};
		
			makeBiggerBttn.x = settings.width * 0.5 - makeBiggerBttn.width * 0.5 + 210;
			makeBiggerBttn.y = 43;
			
			if (settings.isStock) {
				makeBiggerBttn.startGlowing();
			}
				
			makeBiggerBttn.addEventListener(MouseEvent.CLICK, onMakeBiggerEvent);
			
			if (mode == StockWindow.ARTIFACTS)
				makeBiggerBttn.visible = false;
				
			if (settings.target.helpTarget == settings.target.sid)
				makeBiggerBttn.showGlowing();
		}
		
		private function onMakeBiggerEvent(e:MouseEvent):void 
		{
			new ConstructWindow( {
				title:settings.target.info.title,
				upgTime:settings.upgTime,
				request:settings.target.info.devel.obj[settings.target.level + 1],
				target:settings.target,
				win:this,
				onUpgrade:onUpgradeAction,
				hasDescription:true
			}).show();
		}
		
		private function onUpgradeAction(obj:Object = null, count:int = 0):void 
		{
			settings.target.upgradeEvent(settings.target.info.devel.obj[settings.target.level + 1], count);
			showUpgBttn = false;
			//App.ui.bottomPanel.bttnMainStock.buttonMode = false;
			//TweenLite.to(App.ui.bottomPanel.bttnMainStock, 1, {alpha:0});
			close();
		}
		
		private function showFinded(content:Array):void
		{
			settings.content = content
			paginator.itemsCount = content.length;
			paginator.update();
			
			contentChange();
		}
		
		private function onStopFinding():void
		{
			setContentSection(history.section,history.page);
		}
		
		public function drawBacking():void {
			
			var backing:Bitmap = Window.backing(580, 400, 40, 'storageBackingSmall');
			bodyContainer.addChild(backing);
			backing.x = (settings.width/2 - backing.width/2) - 10;
			backing.y = 90;
			
			settings['backX'] = backing.x;
			settings['backWidth'] = backing.width;
		}
		
		public function drawMenu():void {
			
			var menuSettings:Object = {
				"all":		{order:1, 	title:" "+Locale.__e("flash:1382952380301")+"  "},
				"harvest":	{order:2, 	title:" "+Locale.__e("flash:1382952380302")+"  "},
				"materials":{order:4, 	title:Locale.__e("flash:1382952380303")},
				"others":	{order:6, 	title:Locale.__e("flash:1382952380304")}
			}
			
			for (var item:* in sections) {
				if (menuSettings[item] == undefined) continue;
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
					
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
	
						
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				//icons[i].y = 30;
				offset += icons[i].settings.width + 10;
				sprite.addChild(icons[i]);
			}
			bodyContainer.addChild(sprite);
			sprite.x = (this.settings.width - sprite.width) / 2;
			sprite.y = 30;
			
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			e.currentTarget.selected = true;
			setContentSection(e.currentTarget.type);
		}
		
		public function setContentSection(section:*,page:int = -1):Boolean {
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			if (sections.hasOwnProperty(section)) {
				settings.section = section;
				settings.content = [];
				
				for (var i:int = 0; i < sections[section].items.length; i++)
				{
					var sID:uint = sections[section].items[i].sid;
					if (App.user.stock.count(sID) > 0)
						settings.content.push(sections[section].items[i]);
				}
				
				paginator.page = page == -1 ? sections[section].page : page;
				paginator.itemsCount = settings.content.length;
				paginator.update();
				
			}else {
				return false;
			}
			
			contentChange();	
			//if(seachPanel) seachPanel.text = "";
			return true
		}
		
		public function refresh(e:AppEvent = null):void
		{
			//setContentSection(settings.section,settings.page);
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				if (App.user.stock.count(settings.content[i].sid) == 0)
				{
					settings.content.splice(i, 1);
				}
			}
			sections = { };
			createContent();
			findTargetPage(settings);
			setContentSection(settings.section,settings.page);
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
			
			updateCapasity(Stock.value, Stock.limit);
		}
		
		override public function contentChange():void {
			
			for each(var _item:StockItem in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			items = new Vector.<StockItem>();
			//var X:int = 74;
			var X:int = 55;
			var Xs:int = X;
			var Ys:int = 105;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:StockItem = new StockItem(settings.content[i], this);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
					
				items.push(item);
				Xs += item.background.width+10;
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height+15;
				}
				itemNum++;
			}
			
			sections[settings.section].page = paginator.page;
			settings.page = paginator.page;
		}
		
		override public function drawArrows():void 
		{
			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:int = (settings.height - paginator.arrowLeft.height) / 2 + 36;
			paginator.arrowLeft.x = -40;
			paginator.arrowLeft.y = y + 5;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 20;
			paginator.arrowRight.y = y + 5;
			
			//paginator.y += 87;
			//paginator.x = int((settings.width - paginator.width)/2/* - 20*/);
			
			if (paginator.pages <= 7) {
				paginator.x = (settings.width - paginator.width) / 2 - 30;
			}else {
				paginator.x = (settings.width - paginator.width) / 2;
			}
			paginator.y = int(settings.height - paginator.height + 32);
		}
		
		private function notShow(sID:int):Boolean 
		{
			switch(sID) {
				case 823:
				case 839:
						return true;
					break;
			}
			
			return false;
		}
	}
}

import buttons.Button;
import buttons.ImageButton;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import ui.Cursor;
import ui.UserInterface;
import ui.WishList;
import units.Factory;
import units.Field;
import units.Unit;
import units.WorkerUnit;
//import gifts.GiftManager;
//import picture.PictureFiller;
import wins.Window;
import wins.SellItemWindow;
import silin.filters.ColorAdjust;

internal class StockMenuItem extends Sprite {
	
	public var textLabel:TextField;
	public var icon:Bitmap;
	public var type:String;
	public var order:int = 0;
	public var title:String = "";
	public var selected:Boolean = false;
	public var window:*;
	
	public function StockMenuItem(type:String, window:*) {
		
		this.type = type;
		this.window = window;
				
		switch(type) {
			case "all"			: order = 1; title = Locale.__e("flash:1382952380301"); break;
			case "harvest"		: order = 2; title = Locale.__e("flash:1382952380302"); break;
			case "jam"			: order = 3; title = Locale.__e("flash:1382952380201"); break;
			case "materials"	: order = 4; title = Locale.__e("flash:1382952380303"); break;
			case "others"		: order = 6; title = Locale.__e("flash:1382952380304"); break;
		}

		icon.y = - icon.height + 6;
		
		addChild(icon);
				
		textLabel = Window.drawText(title,{
			fontSize:18,
			color:0xf2efe7,
			borderColor:0x464645,
			autoSize:"center"
		});


		addChild(textLabel);
		textLabel.x = (icon.width - textLabel.width) / 2 + 200;

		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
		
	
	private function onClick(e:MouseEvent):void {
		this.active = true;
		window.setContentSection(type);
	}
	
	private function onOver(e:MouseEvent):void{
		if(!selected){
			effect(0.1);
		}
	}
	
	private function onOut(e:MouseEvent):void {
		if(!selected){
			icon.filters = [];
		}
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function set active(selected:Boolean):void {
		var format:TextFormat = new TextFormat();
		
		this.selected = selected;
		if (selected) {
			glow();
			format.size = 18;
			textLabel.setTextFormat(format);
		}else {
			icon.filters = [];
			textLabel.setTextFormat(textLabel.defaultTextFormat);
		}
	}
	
	public function glow():void{
		
		var myGlow:GlowFilter = new GlowFilter();
		myGlow.inner = false;
		//myGlow.color = 0xebdb81;
		myGlow.color = 0xf1d75d;
		myGlow.blurX = 10;
		myGlow.blurY = 10;
		myGlow.strength = 10
		icon.filters = [myGlow];
	}
	
	private function effect(count:int):void {
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.brightness(count);
		icon.filters = [mtrx.filter];
	}
}



import wins.GiftWindow;
import wins.RewardWindow
import wins.SimpleWindow;
import wins.StockDeleteWindow;

internal class StockItem extends Sprite {
	
	public var item:*;
	public var background:Bitmap;
	public var bitmap:Bitmap;
	//public var preloader:Preloader;
	public var title:TextField;
	//public var priceBttn:Button;
	public var placeBttn:Button;
	public var applyBttn:Button;
	public var closeBttn:ImageButton;
	public var wishlistBttn:ImageButton;
	public var giftBttn:ImageButton;
	public var window:*;
	public var sellPrice:TextField;
	public var price:int;
	
	public var plusBttn:Button;
	public var minusBttn:Button;
	
	public var plus10Bttn:Button;
	public var minus10Bttn:Button;
	
	public var countCalc:TextField;
	private var preloader:Preloader = new Preloader();
	
	
	public function StockItem(item:*, window:*):void {
		
		this.item = item;
		this.window = window;
		
		background = Window.backing(170, 170, 10, "itemBacking");
		addChild(background);
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		sprite.tip = function():Object { 
			return {
				title:item.title,
				text:item.description
			};
		};
		
		drawTitle();
		
		addChild(preloader);
		preloader.x = background.width / 2;
		preloader.y = background.height / 2;
		
		drawBttns();
		
		//if (item.ID is String) {
			
		Load.loading(Config.getIcon(item.type, item.preview), onPreviewComplete);
			
		price = item.cost;
			
		placeBttn.visible = false;
		applyBttn.visible = false;
		wishlistBttn.visible = true;
		giftBttn.visible = true;
			
		//if (item.type == "e") {
			//priceBttn.visible = false;
		//}else{	
			//drawSellPrice();
		//}
		
		//wishBttn.visible = true;
		
		if (item.type == "Jam"){
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			//priceBttn.visible = false;
			placeBttn.visible = true;
		}
		
		if (['Building','Farm','Tribute','Decor','Golden','Animal','Resource','Table','Helper','Collector','Bridge','Firework', 'Techno', 'Box', 'Moneyhouse', 'Field', 'Floors', 'Walkgolden', 'Mining', 'Buffer'].indexOf(item.type) != -1){
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			//priceBttn.visible = false;
			placeBttn.visible = true;
			sellSprite.visible = false;
		}
		
		//if ((item.hasOwnProperty('mtype') && item.mtype == 5)) {
			//giftBttn.visible = false;
			//wishlistBttn.visible = false;
		//}
		
		if (item.type == 'Energy')
		{
			giftBttn.visible = false;
			wishlistBttn.visible = false;
			//priceBttn.visible = false;
			applyBttn.visible = true;
			//applyBttn.x = (background.width - applyBttn.width) / 2;
		}
		
		drawCount();
		
		if (window.settings.find != null && window.settings.find.indexOf(int(item.sid)) != -1) {
			glowing();
		}
	}
	
	public function dispose():void {
		
		//removeEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
		//removeEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
		
		//if (plusBttn != null){
			//plusBttn.removeEventListener(MouseEvent.CLICK, onPlusEvent);
			//minusBttn.removeEventListener(MouseEvent.CLICK, onMinusEvent);
			//plus10Bttn.removeEventListener(MouseEvent.CLICK, onPlus10Event);
			//minus10Bttn.removeEventListener(MouseEvent.CLICK, onMinus10Event);
			
		//}
		
		//Connection.MAIN_CONTAINER.removeEnterFrameCallback(bttnsShowCheck)
		
		//priceBttn.removeEventListener(MouseEvent.CLICK, onSellEvent);
		closeBttn.removeEventListener(MouseEvent.CLICK, onSellEvent);
		//if(tweenClose)tweenClose.kill();
		//tweenClose = null;
		
		wishlistBttn.removeEventListener(MouseEvent.CLICK, onWishlistEvent);
		giftBttn.removeEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		placeBttn.removeEventListener(MouseEvent.CLICK, onPlaceEvent);
		applyBttn.removeEventListener(MouseEvent.CLICK, onApplyEvent);
	}
	
	public function drawTitle():void {
		var text:String = "";
		
		title = Window.drawText(item.title, {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			multiline:true
		});
		title.wordWrap = true;
		title.width = background.width - 50;
		title.y = 10;
		title.x = 25;
		addChild(title)
	}
	
	
	public function drawCount():void {
		/*var counterSprite:LayerX = new LayerX();
		counterSprite.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380305")
			};
		};*/
		
		var countOnStock:TextField = Window.drawText('x' + App.user.stock.data[item.sid] || "", {
			color:0xefcfad9,
			borderColor:0x764a3e,  
			fontSize:28,
			autoSize:"left"
		});
		
		var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
		//var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
		
		//counterSprite.addChild(bg);
		/*addChild(counterSprite);
		counterSprite.x = background.width - counterSprite.width - 33;
		counterSprite.y = 122;*/
		
		addChild(countOnStock);
		countOnStock.x = background.width - countOnStock.width - 14;
		countOnStock.y = background.height - countOnStock.height - 23;
	}
	
	
	public var sellSprite:Sprite = new Sprite();
	public function drawSellPrice():void {
		
		if (item.type == 'Energy')
			return;
		
		var label:TextField = Window.drawText(Locale.__e("flash:1382952380306"), {
			color:0x4A401F,
			borderSize:0,
			fontSize:18,
			autoSize:"left"
		});
		sellSprite.addChild(label);
		
		var icon:Bitmap;
				
		icon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
		icon.scaleX = icon.scaleY = 0.7;
		icon.x = label.width;
		icon.y = -2;

		sellSprite.addChild(icon);
				
		sellPrice = Window.drawText(String(price), {
			fontSize:20, 
			autoSize:"left",
			color:0xffdc39,
			borderColor:0x6d4b15
		});
		sellSprite.addChild(sellPrice);
		sellPrice.x = icon.x + icon.width;
		sellPrice.y = 0;
				
		addChild(sellSprite);
		
		sellSprite.x = (background.width - sellSprite.width) / 2;
		sellSprite.y = 136;
	}
	
	public function drawBttns():void {
		
		closeBttn = new ImageButton(UserInterface.textures.storageSell);
		addChild(closeBttn);
		closeBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380277")
			};
		};
		
		closeBttn.x = background.width - closeBttn.width +10;
		closeBttn.y = -5;
		
		//closeBttn.addEventListener(MouseEvent.CLICK, onCloseEvent);
		
		//priceBttn = new Button( {
				//caption:Locale.__e("flash:1382952380277"),
				//fontSize:22,
				//width:90,
				//height:32
			//});
		//addChild(priceBttn);
		//priceBttn.x = 0;
		//priceBttn.y = 0;
		//priceBttn.addEventListener(MouseEvent.CLICK, onSellEvent);
		closeBttn.addEventListener(MouseEvent.CLICK, onSellEvent);
		
		
		placeBttn = new Button( {
			caption:Locale.__e('flash:1382952380210'),
			width:109,
			hasDotes:false,
			height:37,
			fontSize:22
		});
		addChild(placeBttn);
		
		placeBttn.x = (background.width - placeBttn.width)/2;
		placeBttn.y = background.height - placeBttn.height/2 - 5;
		
		placeBttn.addEventListener(MouseEvent.CLICK, onPlaceEvent);
		
		
		applyBttn = new Button( {
			caption:Locale.__e('flash:1382952380210'),
			width:109,
			hasDotes:true,
			height:37,
			fontSize:22
		});
		addChild(applyBttn);
		
		applyBttn.x = (background.width - applyBttn.width)/2;
		applyBttn.y = background.height - applyBttn.height/2 - 5;
		
		applyBttn.addEventListener(MouseEvent.CLICK, onApplyEvent);
		
		wishlistBttn = new ImageButton(Window.textures.wishlistBttn);
		wishlistBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380013")
			};
		};
		//addChild(wishlistBttn);
		//wishlistBttn.x = (background.width - wishlistBttn.width) / 2;
		//wishlistBttn.y = background.height - wishlistBttn.height/2;
		wishlistBttn.addEventListener(MouseEvent.CLICK, onWishlistEvent);
		
		var btnnCont:Sprite = new Sprite();
		btnnCont.addChild(wishlistBttn);
		
		
		giftBttn = new ImageButton(Window.textures.giftBttn, { scaleX:1, scaleY:1 } );
		giftBttn.tip = function():Object { 
			return {
				title:"",
				text:Locale.__e("flash:1382952380012")
			};
		};
		giftBttn.y -= 3;
		giftBttn.addEventListener(MouseEvent.CLICK, onGiftBttnEvent);
		btnnCont.addChild(giftBttn);
		
		
		wishlistBttn.x = giftBttn.x + giftBttn.width + 5;
		addChild(btnnCont);
		btnnCont.x = (background.width - btnnCont.width) / 2;
		btnnCont.y = background.height - btnnCont.height / 2;
	}
	
	private function onGiftBttnEvent(e:MouseEvent):void 
	{
		new GiftWindow( {
			iconMode:GiftWindow.MATERIALS,
			itemsMode:GiftWindow.FRIENDS,
			sID:item.sid
		}).show();
		window.close();
	}
	
	private function onWishlistEvent(e:MouseEvent):void {
		App.wl.show(item.sid, e);
	}
	
	//private var tweenClose:TweenLite;
	//private function onCloseEvent(e:MouseEvent):void 
	//{
		//if(tweenClose)tweenClose.kill();
		//tweenClose = null;
		//var that:StockItem = this;
		//new StockDeleteWindow( {
			//title:Locale.__e("flash:1382952379842"),
			//text:Locale.__e("flash:1382952379968", [item.title]),
			//isImg:true,
			//dialog:true,
			//popup:true,
			//sid:item.sid,
			//confirm:function(count:int):void {
				//App.user.stock.remove(item.sid, count);
				//if(!App.user.stock.data[item.sid])
					//tweenClose = TweenMax.to(that, 0.3, { scaleX:0.2, scaleY:0.2, x:/*(that.x + that.width*0.2) + */window.settings.width / 2, y:App.self.stage.stageHeight, alpha:0, onComplete:function():void { window.refresh(); }} ); //window.refresh();
				//else
					//window.refresh();
					//
				//App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_STOCK));
			//}
		//}).show();
		//App.user.stock.remove(item.sid);
		//window.refresh();
	//}
	
	private function onPlaceEvent(e:MouseEvent):void 
	{
		
		if (!canPlace(item.type) && App.user.worldID != User.HOME_WORLD) {
			new SimpleWindow( {
				label:SimpleWindow.ATTENTION,
				text:Locale.__e('flash:1397124712139', [App.data.storage[item.sid].title]),
				title:"",
				popup:true
			}).show();
			return;
		}
		
		var settings:Object = { sid:item.sid, fromStock:true };
		
		var unit:Unit = Unit.add(settings);
		unit.move = true;
		App.map.moved = unit;
		window.close();
	}
	
	private function canPlace(type:String):Boolean
	{
		var isCan:Boolean = true;
		switch(type) {
			case 'Animal':
			case 'Techno':
			case 'Building':
			case 'Mining':
			case 'Storehouse':
			case 'Factory':	
			case 'Moneyhouse':	
			case 'Trade':	
			case 'Field':
				isCan = false;
			break;
		}
		return isCan;
	}
	
	private function onApplyEvent(e:MouseEvent):void {
		if (item.type == 'Energy') {
			
			App.user.stock.charge(item.ID);
			
			flyMaterial(Stock.FANTASY);
			window.refresh();
			return;
		}
		
		if (item.mtype != null && item.mtype == 5){
			Field.boost = item.ID;
			Cursor.type = 'water';
		}	
		window.close();
	}
	
	private function onSellEvent(e:MouseEvent):void {
		new SellItemWindow( { 
			sID:item.sID, 
			callback:function():void {
				window.refresh();
			}
		}).show();
	}
	
	
	/*
	private function onWishEvent(e:MouseEvent):void
	{
		App.wl.show(item.ID, e);
	}
		
	private function onGiftEvent(e:MouseEvent):void
	{
		new GiftWindow( {
			iconMode:GiftWindow.MATERIALS,
			itemsMode:GiftWindow.FRIENDS,
			sID:item.ID
		}).show();
	}*/
	
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = (background.width - bitmap.width) / 2;
		bitmap.y = (background.height - bitmap.height) / 2;
	}
	
	private function glowing():void {
		customGlowing(background, glowing);
		//customGlowing(priceBttn);
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
	
	private function flyMaterial(sID:uint):void
	{
		var item:BonusItem = new BonusItem(sID, 0);
		
		var point:Point = Window.localToGlobal(bitmap);
		item.cashMove(point, App.self.windowContainer);
	}
}