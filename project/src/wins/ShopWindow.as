package wins
{
	import buttons.MenuButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import ui.Cursor;
	import wins.elements.SearchShopPanel;
	import wins.elements.ShopItem;
	import wins.elements.ShopMenu;

	/*
	    0 - невидимый
		1 - материалы
		2 - растения
		3 - декор
		4 - здания
		5 - персы
		6 - инструменты
		7 - дополнения
		8 - одежда
		13 - ресурсы
	*/	
	
	public class ShopWindow extends Window
	{
		public static var shop:Object;
		public static var history:Object = {section:100,page:0};
		
		public var sections:Array = new Array();
		public var news:Object = {items:[],page:0};
		public var icons:Array = new Array();
		public var items:Array = [];
		
		private var seachPanel:SearchShopPanel;
		
		private static var _currentBuyObject:Object = { type:null, sid:null };
		
		public function ShopWindow(settings:Object = null)
		{
			initContent();
						
			_currentBuyObject.type = null;
			_currentBuyObject.sid = null;
			
			if (settings == null) {
				settings = new Object();
			}
			settings["section"] = settings.section || history.section; 
			settings["page"] = settings.page || history.page;
			
			settings["find"] = settings.find || null;
			
			settings["title"] = Locale.__e("flash:1382952379765");

			settings["width"] = 806;
			settings["height"] = 615;
			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 8;
			settings["returnCursor"] = false;
			
			history.section		= settings.section;
			history.page		= settings.page;
			
			findTargetPage(settings);
			
			settings.content = shop[history.section].data;
			//settings.content.sortOn('order');
			
			super(settings);
		}
		
		private function findTargetPage(settings:Object):void {
			for (var section:* in shop){
				for (var i:* in shop[section].data) {
					
					var sid:int = shop[section].data[i].sid;
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
		
		private function setBttnPressed(section:int):void
		{
			for (var i:int = 0; i < menu.arrSquence.length; i ++ ) {
			//for (var i:* in menu.arrSquence) {
				if (menu.arrSquence[i] == section) {
					ShopMenu._currBtn = i;
					menu.menuBttns[i].selected = true;
				}else {
					menu.menuBttns[i].selected = false;
				}
			}
		}
		
		private function checkUpdate(updateID:String):Boolean {
			
			var update:Object = App.data.updates[updateID];
			if (!update.hasOwnProperty('social') || !update.social.hasOwnProperty(App.social)) {
				
				for (var sID:* in App.data.updates[updateID].items) {
					if ((update.ext != null && update.ext.hasOwnProperty(App.social)) && (update.stay != null && update.stay[sID] != null))
					{
						
					}
					else
					{
						App.data.storage[sID].visible = 0;
					}
				}
				
				return false;
			}
			
			return true;
		}
		
		public static var currentWorld:* = null;
		public static var lockInThisWorld:Array = [];
		public static var worldShop:Object = null;
		public function initContent ():void 
		{
			if(App.data.storage[App.user.worldID].hasOwnProperty('shop'))
				worldShop = App.data.storage[App.user.worldID].shop;
			
				
			if (currentWorld != App.map.id) {
				currentWorld = App.map.id;
				
				var _itemsData:Object = ShopWindow.worldShop;// [section];
				
				lockInThisWorld = [];
				
				for(var _sect:* in _itemsData){
					for (var __sid:* in _itemsData[_sect]) {
						if (__sid != 's' && _itemsData[_sect][__sid] == 0) {
							lockInThisWorld.push(__sid);
						}
					}
				}
			}
				
			if (shop == null) {
				shop = new Object();
				
				shop[100] = {
					data:[],
					page:0
				};
				
				for (var updateID:* in App.data.updates) 
				{
					// Если этого обновления нет в соц. сети
					if (!App.data.updates[updateID].social || !App.data.updates[updateID].social.hasOwnProperty(App.social)) 
						continue;
					
					var updateObject:Object = {
						id:updateID,
						data:[]
					}
					
					var updatesItems:Array = [];
					var items:Object = App.data.updates[updateID].items;
					for (var _sid:* in items)
					{	
						if (App.data.storage[_sid].visible == 0) continue;
						updatesItems.push( { sid:_sid, order:items[_sid] } );
						//updateObject.data[App.data.updates[updateID].items[_sid]] = App.data.storage[_sid];
					}	
					updatesItems.sortOn('order', Array.NUMERIC);
					for (var i:int = 0; i < updatesItems.length; i++) {
						updateObject.data.push(App.data.storage[updatesItems[i].sid]);
					}
						
					updateObject['order'] = App.data.updates[updateID].order;	
					
					if(App.data.updatelist[App.social].hasOwnProperty(updateID))
						updateObject['order'] = App.data.updatelist[App.social][updateID];
					else
						updateObject['order'] = App.data.updates[updateID].order;
					
					shop[100].data.push(updateObject);
				}
				
				shop[100].data.sortOn('order', Array.NUMERIC);
				shop[100].data.reverse();
				
				
				var _elements:Array = [];
				var decors:Array = [];
				
				for (var j:int = 0; j < shop[100].data.length; j++) {
					var updatesObjectsList:Array = shop[100].data[j].data;
					for (var k:int = 0; k <updatesObjectsList.length ; k++) 
					{
						var _item:Object = updatesObjectsList[k];
						switch(_item.type)
						{
							case 'Golden':		
							case 'Decor':
							case 'Box':
							case 'Fake':
								decors.push(_item.sID);
								break;
						}
					}
				}
				
				
				
				for (var id:String in App.data.storage) {
					var item:Object = App.data.storage[id];
					if (item.type == 'Collection') continue;
					
					//if (App.map.id != 171 && worldShop && worldShop[item.market] != null && !worldShop[item.market][id]) continue;
					if (item.visible == 0) continue;//item.type != 'Resource' && item.type != 'Decor'
					
					if(shop[item.market] == null){
						shop[item.market] = {
							data:new Array(),
							page:0
						};
					}
					item['sid'] = id;
					shop[item.market].data.push(item);
					
					switch(item.type)
					{
						case 'Golden':		
						case 'Decor':
						case 'Box':
						case 'Fake':
							if(decors.indexOf(int(item.sid)) == -1)
								decors.push(int(item.sid));
							break;
					}
				}
				
				for (var market:* in shop) {
					if (market == 100 || market == 3) continue;
					shop[market].data.sortOn('order', Array.NUMERIC);
				}
				
				market = 3;
				
				for (var l:int = 0; l < decors.length; l++) 
				{
					_elements.push(App.data.storage[decors[l]]);
				}

				shop[market].data = [];
				shop[market].data = shop[market].data.concat(_elements);
			}
		}
		
		override public function dispose():void {
			
			for each(var item:* in items) {
				bodyContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			
			for each(var icon:* in icons) {
				//bodyContainer.removeChild(icon);
				icon.dispose();
				icon = null;
			}
			
			super.dispose();
		}
		
		override public function drawBody():void {
			
			drawBacking();
			drawMenu();
			
			exit.y -= 15;
			titleLabel.y -= 2;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -30, true, true);
			drawMirrowObjs('diamonds', 22, settings.width - 21, settings.height - 120 + 6);
			drawMirrowObjs('diamonds', 22, settings.width - 22, 52, false, false, false, 1, -1);
			
			seachPanel = new SearchShopPanel( {
				win:this, 
				callback:showItem,
				stop:onStopFinding,
				hasIcon:false,
				caption:Locale.__e('flash:1405687705056')
			});
			bodyContainer.addChild(seachPanel);
			seachPanel.y = paginator.y + (paginator.height - seachPanel.height) / 2 - 12;
			seachPanel.x = 40;
			seachPanel.visible = false;
			
			setContentSection(settings.section,settings.page);
			contentChange();
		}
		
		private function showSeach(value:Boolean = true):void 
		{
			seachPanel.visible = value;
			if(seachPanel.isFocus)
				seachPanel.searchField.text = "";
			else
				seachPanel.searchField.text = seachPanel.settings.caption;
		}
		
		private function onStopFinding():void 
		{
			setContentSection(settings.section,settings.page);
		}
		
		private function showItem(content:Array):void 
		{
			settings.content = content;
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			contentChange();
		}
		
		private var menu:ShopMenu;
		public function drawMenu():void 
		{
			menu = new ShopMenu(this);
			bodyContainer.addChild(menu);
		}
		
		
		public function setContentSection(section:*, page:Number = -1):Boolean
		{
			setBttnPressed(history.section);
			
			//newIcon.active = false;
			
			//for each(var icon:MenuButton in icons) {
				//icon.selected = false;
				//if (icon.type == section) {
					//icon.selected = true;
				//}
			//}
			
			
			//if (newIcon.type == section) {
			//	newIcon.active = true;
			//}
			
			if (shop.hasOwnProperty(section)) {
				settings.section = section;
				
				settings.content = shop[section].data;
				paginator.page = page == -1 ? shop[section].page : page;
				
				history.section = section;
				history.page = page;
				
				paginator.itemsCount = settings.content.length;
				paginator.update();
				
			}else {
				return false;
			}
			
			if (settings.section == 100) {
				showSeach(false);
				paginator.onPageCount = 3;
			}
			else {
				showSeach();
				paginator.onPageCount = settings.itemsOnPage;
			}
				
			paginator.update();
			contentChange();
			return true;
		}
		
		public function setContentNews(data:Array):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
			}
			
			settings.content = data
			paginator.page = 0;
			
			settings.section = 101;
			paginator.onPageCount = settings.itemsOnPage;
			paginator.itemsCount = settings.content.length;
			paginator.update();
				
			contentChange();
			return true;
		}

		public function drawBacking():void {
			var backing:Bitmap = Window.backing(settings.width-70, 478, 25, 'shopBackingSmall');
			bodyContainer.addChild(backing);
			backing.x = settings.width/2 - backing.width/2;
			backing.y = 49;
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			var X:int = 60;
			var Xs:int = X;
			var Ys:int = 52 + 11;
			
			if (settings.section != 101 && settings.section != 100 && settings.section != 3) 
			settings.content.sortOn('order', Array.NUMERIC);
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
			
				var item:*
				if (settings.section == 100) 
					item = new NewsItem(settings.content[i], this);
				else	
					item = new ShopItem(settings.content[i], this);
				
				bodyContainer.addChildAt(item,1);
				item.x = Xs - 10;
				item.y = Ys/* - 1*/;
				
				items.push(item);
				
				Xs += item.background.width + 6;
				if (itemNum == int(settings.itemsOnPage / 2) - 1)	{
					Xs = X;
					Ys += item.background.height + 15;
				}
				itemNum++;
			}
			
			if (settings.section == 100)
				showBestSellers();
			else
				hideBestSellers();
			
			if (settings.section == 101)
				return;
			
			shop[settings.section].page = paginator.page;
			settings.page = paginator.page;
			history.page = settings.page;
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowLeft.x = -20;
			paginator.arrowLeft.y = y - 18;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 22;
			paginator.arrowRight.y = y - 18;
			
			paginator.y = settings.height - 45;
		}
		
		override public function drawTitle():void {
							
				
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
			titleLabel.y = -10;
			headerContainer.addChild(titleLabel);
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.mouseEnabled = false;
		}
		
		static public function set currentBuyObject(value:Object):void
		{
			_currentBuyObject = value;
		}
		
		static public function get currentBuyObject():Object
		{
			return _currentBuyObject;
		}
		
		public var bestBg:Bitmap = null
		public var bestSellers:BestSellers = null
		public function showBestSellers():void 
		{
			//return;
			if (bestSellers != null) return;
			bestSellers = new BestSellers(this);
			
			bodyContainer.addChild(bestSellers);
			
			bestSellers.y = settings.height - 268;
			bestSellers.x = (settings.width - bestSellers.width) / 2;
			
			paginator.visible = false;
		}
		
		public function hideBestSellers():void {
			if (bestSellers == null) return
			
			bestSellers.dispose();
			bodyContainer.removeChild(bestSellers);
			bestSellers = null;
			paginator.visible = true;
		}
		
		public override function close(e:MouseEvent = null):void {
			super.close();
			if (App.tutorial)
				App.tutorial.hide();
			
		}
	}
}


import adobe.utils.CustomActions;
import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Mouse;
import ui.Cursor;
import ui.Hints;
import units.Anime;
import units.Field;
import units.Sphere;
import units.Unit;
import wins.Window;

internal class NewsItem extends Sprite {
	
	public var item:*;
	public var update:*;
	public var background:Bitmap;
	public var bttn:ImageButton;
	public var preloader:Preloader = new Preloader();
	public var title:TextField;
	public var priceBttn:Button;
	public var openBttn:Button;
	public var window:*;
	private var maska:Shape
	
	public function NewsItem(item:*, window:*) {
			
		this.item = item;
		this.window = window;
		
		update = App.data.updates[item.id];
		
		background = Window.backing(220, 274, 10, "itemBacking");
		addChild(background);
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0, 0, background.width-20, background.height-20, 30, 30);
		maska.graphics.endFill();
		
		maska.x = (background.width - maska.width) / 2;
		maska.y = (background.height - maska.height) / 2;
		
		bttn = new ImageButton(new BitmapData(100,100,true,0));
		addChild(bttn);		
		addChild(maska)
		bttn.mask = maska
		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height)/ 2 - 15;
		
		//Load.loading(Config.getImageIcon('updates/icons', update.preview, 'jpg'), onLoad); 
		Load.loading(Config.getImageIcon('updates/icons', update.preview, 'jpg'), onLoad); 
		drawTitle();
	}	
	
	/*private function scaleTextToFitInTextField( txt : TextField ):void
	{  
		 var f:TextFormat = txt.getTextFormat();
		 f.size = ( txt.width > txt.height ) ? txt.width : txt.height;
		 txt.setTextFormat( f );
	 
		 while ( txt.textWidth > txt.width - 4 || txt.textHeight > txt.height - 6 ) 
		 {    
			  f.size = int( f.size ) - 1;    
			  txt.setTextFormat( f );  
		 }
	}*/
	
	private function autoSize(txt:TextField):void 
	{
	  //You set this according to your TextField's dimensions
		var maxTextWidth:int = 145; 
		var maxTextHeight:int = 30; 

		var f:TextFormat = txt.getTextFormat();

		//decrease font size until the text fits  
		while (txt.textWidth > maxTextWidth || txt.textHeight > maxTextHeight) {
		f.size = int(f.size) - 1;
		txt.setTextFormat(f);
		}
	}
	 
	/*private function scaleTextFieldToFitText( txt : TextField ) : void
	{
		 //the 4s take into account Flash's default padding.
		 //If I omit them, edges of character get cut off.
		 txt.width = txt.textWidth + 4;
		 txt.height = txt.textHeight + 4;
	}*/
	
	private function drawTitle():void {
		
		var title:TextField = Window.drawText(String(update.title), {
			color:0xffcc00,
			borderColor:0x643619,
			/*color:0xfffef6,
			borderColor:0x80552a,*/
			textAlign:"center",
			autoSize:"center",
			fontSize:30,
			textLeading:-6,
			multiline:true
		});
		
		//autoSize(title);
		//scaleTextToFitInTextField(title);
		//scaleTextFieldToFitText(title);
		
		title.wordWrap = true;
		title.width = background.width - 50;
		title.y = 20;
		title.x = 25;
		addChild(title)
	}
	
	private function onLoad(data:Bitmap):void {
		
		removeChild(preloader);
		
		bttn.bitmapData = data.bitmapData
		bttn.x = (background.width - bttn.width) / 2;
		bttn.y = (background.height - bttn.height) / 2;
		
		bttn.addEventListener(MouseEvent.CLICK, onClick)
		
	}
	
	private function onClick(e:MouseEvent):void {
		window.setContentNews(item.data);
	}
	
	public function dispose():void {
		if (bttn != null) bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
}


internal class BestSellers extends Sprite
{
	public var win:*;
	//public var bg:Bitmap;
	public var items:Array = [];
	public var content:Array = [];
	
	public function BestSellers(win:*) {
		
		
		for each(var sid:* in App.data.bestsellers) {
			
			var item:Object = App.data.storage[sid];
			
			if (item != null && item.visible != 0) {
				if (item.hasOwnProperty('instance') && (World.getBuildingCount(sid) >= getInstanceNum(sid) || App.user.level < item.instance.level[World.getBuildingCount(sid) + 1])) 
					continue;
					
				if ((item.type == 'Resource' || item.type == 'Decor') && App.user.level < item.level)
					continue;
					
				if(checkNotInWorld(sid))
					continue;	
				
					
				item.id = sid;
				item['_order'] = int(Math.random() * 100);
				content.push(item);
			}
		}
		
		content.sortOn('_order');
		
		this.win = win;
		//bg = Window.backing(win.settings.width - 110, 165, 30, "itemBacking");
		//addChild(bg);
		//bg.y -= 10;
		
		drawItems();
		drawTitle();
	}
	
	private function checkNotInWorld(sid:int):Boolean
	{
		var itemsData:Object = ShopWindow.worldShop;// [section];
		var end:Boolean = false;
		
		for(var sect:* in itemsData){
			for (var ind:* in itemsData[sect]) {
				if (sid == ind && itemsData[sect][ind] == 0) {
					end = true;
					break;
				}
			}
		}
		return end;
	}
	
	private function getInstanceNum(sid:int):int
	{
		var count:int = 0;
		for each(var inst:* in App.data.storage[sid].instance['level']) {
			count++;
		}
		return count;
	}
	
	public function drawItems():void {
		
		var cont:Sprite = new Sprite();
		var X:int = 0;
		
		var _length:int = Math.min(5, content.length);
		for (var i:int = 0; i < _length; i++)
		{
			var item:BestSellerItem = new BestSellerItem(content[i], this);
			cont.addChild(item);
			item.x = X;
			X += item.bg.width + 1;
		}
		
		cont.y = 20;
		addChild(cont);
	}
	
	private function drawTitle():void 
	{
		var title:TextField = Window.drawText(Locale.__e('flash:1382952380296'), {
			color:0xffffff,
			borderColor:0x773c18,
			textAlign:"center",
			autoSize:"center",
			fontSize:32,
			textLeading:-6,
			multiline:true
		});
		
		title.wordWrap = true;
		title.width = win.settings.width - 160;
		title.y = -15;
		title.x = 27;
		addChild(title);
		
		var sep1:Bitmap = Window.backingShort(300, "divider", false);
		var sep2:Bitmap = Window.backingShort(300, "divider", false);
		
		sep1.x = 0;
		sep1.y = title.y + 8;
		sep1.alpha = 0.5;
		
		sep2.x = 700;
		sep2.y = title.y + 8;
		sep2.scaleX = -1;
		sep2.alpha = 0.5;
		
		addChild(sep1);
		addChild(sep2);
	}
	
	public function dispose():void {
		for each(var _item:* in items) {
			_item.dispose();
		}
	}
}


import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;
internal class BestSellerItem extends Sprite {
	
	public var bg:Bitmap;
	public var item:Object;
	private var bitmap:Bitmap;
	private var buyBttn:Button;
	private var buyBttnNow:MoneySmallButton;
	private var _parent:*;
	private var preloader:Preloader = new Preloader();
	private var sprite:LayerX;
	//public var paginator:Paginator				= null;	
	
	public function BestSellerItem(item:Object, parent:*) {
		
		this._parent = parent;
		this.item = item;
		bg = Window.backing(136, 154, 15, 'itemBacking');
		addChild(bg);
		
		sprite = new LayerX();
		addChild(sprite);
			
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
			
		sprite.tip = function():Object { 
			
			if (item.type == "Plant")
			{
				return {
					title:item.title,
					text:Locale.__e("flash:1382952380297", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
				};
			}
			else if (item.type == "Decor")
			{
				return {
					title:item.title,
					text:Locale.__e("flash:1382952380076", item.experience)
				}	
			}
			else
			{
				return {
					title:item.title,
					text:item.description
				};
			}
		};
		
		drawTitle();
		drawBttn();
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height)/ 2;
		
		/*Load.loading(Config.getIcon(item.type, item.preview), function(data:Bitmap):void {
			
			removeChild(preloader);
			
			bitmap.bitmapData = data.bitmapData;
			
			bitmap.scaleX = bitmap.scaleY = 0.7;
			bitmap.smoothing = true;
			
			bitmap.x = (bg.width - bitmap.width)/2;
			bitmap.y = (bg.height - bitmap.height)/2 ;
			
		});*/
		
		if (item.type == 'Golden' || item.type == 'Thimbles' || item.type == 'Gamble' || item.type == 'Animal') {
			Load.loading(Config.getSwf(item.type, item.preview), onLoadAnimate);
		}else{
			Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		}
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.7;
		bitmap.smoothing = true;
		
		bitmap.x = (bg.width - bitmap.width)/2;
		bitmap.y = (bg.height - bitmap.height)/2 + 5;
	}
	private function onLoadAnimate(swf:*):void {
		removeChild(preloader);
		
		if (!sprite) sprite = new LayerX();
		if (!contains(sprite)) addChild(sprite);
		
		
		var bitmap:Bitmap = new Bitmap(swf.sprites[swf.sprites.length - 1].bmp, 'auto', true);
		bitmap.x = swf.sprites[swf.sprites.length - 1].dx;
		bitmap.y = swf.sprites[swf.sprites.length - 1].dy;
		sprite.addChild(bitmap);
		
		var framesType:String;
		for (framesType in swf.animation.animations) break;
		var anime:Anime = new Anime(swf, framesType, swf.animation.ax, swf.animation.ay);
		sprite.addChild(anime);
		anime.startAnimation();
		sprite.x = bg.x + bg.width / 2;
		sprite.y = bg.y + bg.height / 2 + 15/* + ((sprite.height > 100) ? ((sprite.height - 100) / 2) : 0)*/;
		sprite.scaleX = sprite.scaleY = 0.6;
	}
	
	public function drawTitle():void {
		var title:TextField = Window.drawText(String(item.title), {
			color:0x814f31,
			borderColor:0xfcf6e4,
			textAlign:"center",
			//autoSize:"center",
			fontSize:22,
			textLeading:-8,
			multiline:false,
			wrap:true,
			width:bg.width
		});
		//title.wordWrap = true;
		//title.width = bg.width - 10;
		title.y = 5;// (bg.width - title.width) / 2;
		title.x = (bg.width - title.width)/2;
		addChild(title);
	}
	
	public function drawBttn():void {
		
		var isBuyNow:Boolean = false;
		
		var bttnSettings:Object = {
			caption     :Locale.__e("flash:1382952379751"),
			width		:100,
			height		:38,	
			fontSize	:24,
			scale		:0.8,
			hasDotes    :false
		}
		if (item.cost) {
			bttnSettings['type'] = 'real';
			bttnSettings['countText'] = item.cost;
			bttnSettings["bgColor"] = [0xfffef6, 0x80552a];
			bttnSettings["borderColor"] = [0xffffff, 0xffffff];
			bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
			bttnSettings["fontColor"] = 0xffffff;				
			bttnSettings["fontBorderColor"] = 0x354321;
			bttnSettings['greenDotes'] = false;
			isBuyNow = true;
		}else if (item.price && item.price[Stock.COINS]) {
			//bttnSettings['type'] = 'coins';
			//bttnSettings['countText'] = item.price[Stock.COINS];
		}else if(item.price && item.price[Stock.FANT]){
			bttnSettings['type'] = 'real';
			bttnSettings['countText'] = item.price[Stock.FANT];
			bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
			bttnSettings["borderColor"] = [0xffffff, 0xffffff];
			bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
			bttnSettings["fontColor"] = 0xffffff;				
			bttnSettings["fontBorderColor"] = 0x354321;
			bttnSettings['greenDotes'] = false;
			isBuyNow = true;
		}else if (item.instance) {
			var count:int = World.getBuildingCount(item.sID);
			if (count == 0)
				count = 1;
			if (item.instance.cost && item.instance.cost[count][Stock.FANT]) {
				bttnSettings['type'] = 'real';
				bttnSettings["bgColor"] = [0xa9f84a, 0x73bb16];
				bttnSettings["borderColor"] = [0xffffff, 0xffffff];
				bttnSettings["bevelColor"] = [0xc5fe78, 0x405c1a];
				bttnSettings["fontColor"] = 0xffffff;				
				bttnSettings["fontBorderColor"] = 0x354321;
				bttnSettings['greenDotes'] = false;
				bttnSettings["countText"] = item.instance.cost[count][Stock.FANT];
				isBuyNow = true;
			}
		}
		
		if(!isBuyNow){
			buyBttn = new Button(bttnSettings);
			addChild(buyBttn);
			buyBttn.x = (bg.width - buyBttn.width) / 2;
			buyBttn.y = bg.height - 24;
			
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
		}else {
			buyBttnNow = new MoneySmallButton(bttnSettings);
			addChild(buyBttnNow);
			buyBttnNow.x = (bg.width - buyBttnNow.width) / 2;
			buyBttnNow.y = bg.height - 24;
			buyBttnNow.addEventListener(MouseEvent.CLICK, onBuyNow);
			buyBttnNow.coinsIcon.y -= 4;
		}
	}
	
	private function onBuyNow(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.state = Button.DISABLED;
		
		ShopWindow.currentBuyObject = { type:item.type, sid:item.sid };
		
		var unit:Unit;
		switch(item.type)
		{
			case "Material":
				App.user.stock.buy(item.sid, 1, onBuyComplete);
				break;
			case "Boost":
			case "Energy":
				App.user.stock.pack(item.sid, onBuyComplete);
				break;
			case "Plant":
				if(Field.exists == false){
					unit = Unit.add( { sid:13 } );
					unit.move = true;
					App.map.moved = unit;
					Cursor.plant = item.sid;
				}
				Field.exists = false;
				break;
			default:
				if (item.sid == 54 && App.user.quests.data["16"] == undefined) {
					new SimpleWindow( {
						text:Locale.__e('flash:1383043022250', [App.data.quests[16].title]),
						label:SimpleWindow.ATTENTION
					}).show();
					break;
				}
				unit = Unit.add( { sid:item.sid, buy:true } );
				
				unit.move = true;
				App.map.moved = unit;
				
				
			break;
		}
		
		if(item.type != "Material"){
				_parent.win.close();
			}
	}
	
	public function onBuyComplete(type:*, price:uint = 0):void {
		var point:Point = new Point(App.self.mouseX - buyBttn.mouseX, App.self.mouseY - buyBttn.mouseY);
		point.x += buyBttn.width / 2;
		Hints.minus(Stock.FANT, item.real, point, false, App.self.tipsContainer);
		buyBttn.state = Button.NORMAL;
		
		flyMaterial();
	}
	
	
	private function onBuy(e:MouseEvent):void {
		_parent.win.close();
		new ShopWindow( { find:[item.sID], forcedClosing:true, popup: true } ).show();
	}
	
	
	public function dispose():void {
		if(buyBttn)buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
		if(buyBttnNow)buyBttn.removeEventListener(MouseEvent.CLICK, onBuyNow);
	}
	
	private function flyMaterial():void
	{
		var item:BonusItem = new BonusItem(item.sid, 0);
		
		var point:Point = Window.localToGlobal(bitmap);
		point.y += bitmap.height / 2;
		item.cashMove(point, App.self.windowContainer);
	}
}

