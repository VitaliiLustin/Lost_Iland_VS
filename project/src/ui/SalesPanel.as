package ui 
{
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.adobe.images.BitString;
	import core.CookieManager;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Character;
	import wins.BankSaleWindow;
	import wins.BanksWindow;
	import wins.BigsaleWindow;
	import wins.EnlargeStorageWindow;
	import wins.PromoWindow;
	import wins.SaleDecorWindow;
	import wins.SaleGoldenWindow;
	import wins.SaleLimitWindow;
	import wins.SalesSetsWindow;
	import wins.SalesSetsWindow2;
	import wins.SalesWindow;
	import wins.ThematicalSaleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class SalesPanel extends Sprite
	{
		public var promoIcons:Array = [];
		public var newPromo:Object = { };
		public var promoPanel:Sprite = new Sprite();
		
		public static var iconHeight:uint = 80;
		
		public var paginator:PromoPaginator;
		
		public function SalesPanel() 
		{
			
			paginator = new PromoPaginator(App.user.promos, 2, this);
			paginator.drawArrows();
			
			addChild(promoPanel);
			
			//if(App.data.promo){
				setTimeout(initPromo, 100);
			//}
		}
		
		public var bankSaleIcons:Array = [];
		private var isBankAdd:Boolean = false;
		public function addBankSaleIcon(btmd:BitmapData):void
		{
			if (bankSaleIcons.length > 0)
				return;
			
			var bttn:ImagesButton = getBankSaleIcon(bttn, btmd);
			bankSaleIcons.push(bttn);
			
			bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
			bttn.x = 35 - bttn.bitmap.width/2;
			
			bttn.startRotate(420);
			
			promoPanel.addChild(bttn);
			
			promoPanel.y = 160;
			
			iconsPosY += iconHeight + 31;
			
			isBankAdd = true;
			
			createPromoPanel(false, true);
			resize();
		}
		
		public function initPromo():void {
			App.user.quests.checkPromo();
		}
		
		private function startGlow(bttn:ImagesButton):void {
			//bttn.showGlowing();
			bttn.showPointing("left", 0, promoPanel.y, App.ui.salesPanel, Locale.__e("flash:1382952379795"), {
				color:0xffd619,
				borderColor:0x7c3d1b,
				autoSize:"left",
				fontSize:24
			}, true);
		}
		
		public var iconDealSpot:*;
		public function createDealSpot(swf:*):void {
			iconDealSpot = swf;
			promoPanel.addChild(iconDealSpot);
			iconDealSpot.x = 120;
			iconDealSpot.y = 0;
		}
		
		public function updateSales():void
		{
			if (App.user.quests.tutorial)
				return;
			
			promoIconId = 0;
			numUpIcons = 0;
			iconsPosY = 0;
			
			if (bankSaleIcons.length > 0) {
				iconsPosY += iconHeight + 31;
				numUpIcons = 1;
			}
			
			clearPromoPanel();
			createPremium();
			createSales();
			createBulks();
			createBigSales();
			
			if (numUpIcons == 1)
				iconsPosY += 20;
			
			if (iconsPosY == 0)
				iconsPosY = 30;
			
			iconsHeight = 0;
		}
		
		private var promoIconId:uint = 0;
		public var iconsPosY:int = 0;
		public var iconsHeight:int = 0;
		private var numUpIcons:int = 0;
		
		private var iconsTopLimit:int = 2;
		
		public function createPromoPanel(isLevelUp:Boolean = false, isPaginatorUpd:Boolean = false):void 
		{
			if (App.user.quests.tutorial) {
				paginator.arrowDown.visible = false;
				paginator.arrowUp.visible = false;
				return;
			}
				
			updateSales();
				
			var iconY:int = 0;
			var limit:int = 3;
			
			promoPanel.y = 146;
			
			var pos:int = iconsPosY + 146;
			paginator.resize(App.self.stage.stageHeight - pos - 212, isLevelUp);
		}
		
		public function doCreate(isLevelUp:Boolean = false):void
		{
			var iconY:int = 0;
			var limit:int = 3;
			App.data
			iconY = iconsPosY;
			
			App.user.promos.sortOn('order', Array.NUMERIC);
			
			for (var i:int = paginator.startItem; i < paginator.endItem; i++)
			{
				if (App.user.promos.length <= i) break;
				if	(App.user.promos[i].buy) {
					limit++;
					continue;
				}
				
				var pID:String = App.user.promos[i].pID;
				var promo:Object = App.data.actions[pID];
				var bttn:ImagesButton = getPromoIcons(bttn, App.user.promos[i], pID);
				promoIcons.push(bttn);
				
				
				
				bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
				bttn.x = 40 - bttn.bitmap.width/2;
				bttn.y = iconY;
				
				promoPanel.addChild(bttn);
				
				iconY += bttn.bitmap.height + 4;
				
				var obj:Object = App.user.promo[pID];
				if (App.user.promo[pID].begin_time + 15 > App.time) {
					startGlow(bttn);
				}
				
				promoIconId++;
				
				iconsHeight += bttn.bitmap.height + 4;
				
				if (isLevelUp && !App.user.promos[i].showed) {
					onPromoOpen(null, bttn);
				}
			}
			
			for (i = 0; i < promoIcons.length; i++)
				promoIcons[i].startRotate(i * 420);
			
			
			if (isBankAdd) {
				isBankAdd = false;
				paginator.resize(App.self.stage.stageHeight - iconY - 112);
			}
			
			paginator.setArrowsPosition();
			
			if (promoIcons.length > 0) {
				promoTime();
				App.self.setOnTimer(promoTime);
			}
			else
			{
				App.self.setOffTimer(promoTime);
			}
		}
		
		public function checkOnGlow(type:String, bttn:ImagesButton, pID:*):void 
		{
			if (ExternalInterface.available) 
			{
				var pID:String = String(pID);
				var cookieName:String = pID + "_" + App.user.id;
				var value:String = CookieManager.read(cookieName);
				
				if (type == 'promo')
				{
					if (newPromo.hasOwnProperty(pID)) {
						if (App.time > newPromo[pID]) 
							return;
						
						Post.addToArchive('startGlow: '+ pID);
						startGlow(bttn);
						CookieManager.store(cookieName, '1');
						return;
					}
					else
					{
						if (value == '1') return;
						newPromo[pID] = App.time + 5;
						Post.addToArchive(pID + ' ' + App.data.promo[pID].title + ' : ' + value);
					}
				}
				else if (type == 'sale')
				{
					Post.addToArchive(pID + '  : ' + value);
					
					if (newPromo.hasOwnProperty(pID)) {
						if (App.time > newPromo[pID]) 
							return;
						
						startGlow(bttn);
						CookieManager.store(cookieName, '1');
						return;
					}
					else
					{
						if (value == '1') return;
						newPromo[pID] = App.time + 5;
					}
				}
				
				if (value != '1') {
					Post.addToArchive('startGlow: '+ pID);
					startGlow(bttn);
					CookieManager.store(cookieName, '1');
				}
			}
		}
	
		private function promoTime():void {
			for (var pID:* in App.user.promo)
			{
				var promo:Object = App.data.actions[pID];
				
				if (promo.begin_time + promo.duration * 3600 < App.time) {
					App.user.updateActions();
					createPromoPanel();
				}
			}
		}
		
		public function onPromoOpen(e:MouseEvent = null, bttn:* = null):void {
			var target:*;
			if (e) {
				target = e.currentTarget;
				target.hideGlowing();
				target.hidePointing();
			}
			else if (bttn) {
				target = bttn;
			}
			
			var pID:String = target.settings.pID;
			
			if (target.settings['sale'] == 'premium'){
				new SaleLimitWindow({pID:pID}).show();
				return;
			}
			
			if (target.settings['sale'] == 'bankSale'){
				//new BankSaleWindow().show();
				new BanksWindow().show();
				return;
			}
			
			if (target.settings['out'] == 365) {
				new EnlargeStorageWindow( { pID:pID } ).show();
				return;
			}
			
			if (target.settings['sale'] == 'promo' && App.data.actions.hasOwnProperty(pID)) {
				if (pID == "32")
					new SaleGoldenWindow( { pID:pID } ).show();
				else	
					new PromoWindow( { pID:pID } ).show();
				
				//new ThematicalSaleWindow({ pID:pID }).show();
				App.user.unprimeAction(pID);
				return;
			}
			
			if (target.settings['sale'] == 'sales' && App.data.sales.hasOwnProperty(pID)) {
				//new SalesWindow({
						//ID:pID,
						//action:App.data.sales[pID],
						//mode:SalesWindow.SALES
					//}).show();
					new SaleDecorWindow({
						ID:pID,
						action:App.data.sales[pID]
					}).show();
				return;
			}
			
			if (target.settings['sale'] == 'bigSale' && App.data.bigsale.hasOwnProperty(pID)){
				new BigsaleWindow( { sID:pID } ).show();
				//new ThematicalSaleWindow({ pID:pID }).show();
				return;
			}
			
			if (App.data.bulks.hasOwnProperty(pID)) {
				
				new SalesWindow( {
					action:App.data.bulks[pID],
					pID:pID,
					mode:SalesWindow.BULKS,
					width:670,
					title:Locale.__e('flash:1385132402486')
				}).show();
				return;
			}
		}
		
		private function checkForOneItem(items:Object):Boolean 
		{
			var num:int = 0;
			for (var it:* in items) {
				num++;
			}
			if (num > 1) 
				return false;
				
			return true;
		}
		
		private function getPromoIcons(bttn:ImagesButton, item:Object, pID:String = ""):ImagesButton {
			
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.5,
				textAlign:'center',
				multiline:true
			}
			
			var iconSettings:Object = {
				scale:0.5
				//filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var bitmap:Bitmap; 
			switch(item.preview) {
				case "SaleBacking1":
					bitmap = new Bitmap(UserInterface.textures.saleBacking1);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x6d2c08;
					iconSettings.scale = 0.55;
				break;
				case "SaleBacking3":
					bitmap = new Bitmap(UserInterface.textures.saleBacking3);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x23534a;
				break;
				case "SaleBacking2":
					bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
				break;
				default:
					bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
			}
			
			for (var key:* in item.items)
				break;
			
			bttn = new ImagesButton(bitmap.bitmapData, null, {out:key, pID:pID, sale:'promo' } );
			
			var _items:Array = [];
			for (var sID:* in item.items) {
				_items.push( { sID:sID, order:item.iorder[sID] } );
			}
			_items.sortOn('order');
			sID = _items[0].sID;
			
			var url:String = Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
			
			switch(sID) {
				case Stock.COINS:
					url = Config.getIcon("Coins", "gold_02");
				break;
				case Stock.FANT:
					url = Config.getIcon("Reals", "crystal_03");
				break;
			}
			
			var title:TextField = Window.drawText(textSettings.text, textSettings);
			title.wordWrap = true;
			title.width = 60;
			title.height = title.textHeight + 4;
			
			//Load.loading(Config.getImageIcon('promo/bg', item.preview), function(data:*):void {
				//bttn.bitmapData = data.bitmapData;
				
				Load.loading(url, function(data:*):void {
					
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY =  iconSettings.scale;
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
					bttn.addChild(title);
					title.x = (bttn.bitmap.width - title.width)/2 - 2;
					title.y = (bttn.bitmap.height - title.height)/2 + 20;
					bttn.initHotspot();
				});
			//});
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = item.duration * 3600 - (App.time - App.user.promo[pID].begin_time);
				if (pID == "32") {
					text = Locale.__e('flash:1409671213710');
				}else if (pID == '75') {
					text = Locale.__e('flash:1409671354895');
				}else if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToStr(time)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToStr(time)]);
				
				return {
					title:Locale.__e(item.title),
					text:text,
					timer:true
				}
			};
			
			return bttn;
		}
		
		private function getPremiumIcon(bttn:ImagesButton, item:Object, pID:String = ""):ImagesButton {
			
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.5,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:1
				//filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var marginTxtY:int = 0;
			var bitmap:Bitmap; 
			switch(item.bg) {
				case "star1":
					bitmap = new Bitmap(new BitmapData(82, 79, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x6d2c08;
					iconSettings.scale = 0.9;
				break;
				case "star2":
					bitmap = new Bitmap(new BitmapData(95, 92, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x23534a;
					marginTxtY = 16;
				break;
				case "round":
					bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
					marginTxtY = 8;
				break;
				default:
					bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
				break
			}
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID, sale:'premium' } );
			
			var url_icon:String = Config.getIcon(App.data.storage[item.sid].type, App.data.storage[item.sid].view);
			var url_bg:String = Config.getImageIcon('promo/bg', item.bg);
			
			textSettings.text = "";// Locale.__e("");
			textSettings.fontSize = 19;
			iconSettings.filter = [];
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			bttn.addChild(text);
			
			text.width = 95;
			text.x = -6;
			text.y = 50 + marginTxtY;
			
			//Load.loading(url_bg, function(data:*):void {
				//bttn.bitmapData = data.bitmapData;
				
				Load.loading(url_icon, function(data:*):void {
					
					bttn.icon = data.bitmapData;
					
					if (bttn.iconBmp.height > bttn.iconBmp.width) {
						bttn.iconBmp.height = bttn.bitmap.height - 6;
						bttn.iconBmp.scaleX = bttn.iconBmp.scaleY;
					}else {
						bttn.iconBmp.width = bttn.bitmap.width - 6;
						bttn.iconBmp.scaleY = bttn.iconBmp.scaleX;
					}
					
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
					
					bttn.initHotspot();
				});
			//});
			
			App.self.setOnTimer(_update);
			function _update():void 
			{
				var time:int = item.duration * 3600 - (App.time - item.time);
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(_update);
					createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = item.duration * 3600 - (App.time - item.time);
				if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				
				return {
					title:Locale.__e(item.title),
					text:text,
					timer:true
				}
			};	
			
			return bttn;
		}
		
		private function getSaleIcon(bttn:ImagesButton, item:Object, pID:String = ""):ImagesButton {
			
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.5,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:1
				//filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var _sid:*;
			var sidArr:Array = [];
			for (_sid in item.items) {
				sidArr.push(_sid);
				//break;
			}
			_sid = sidArr[Math.round(Math.random() * (sidArr.length - 1))];
			
			//for (var _sid2:* in item.items) {
				//if (item.image == App.data.storage[_sid2].view) {
					//_sid = _sid2;
					//break;
				//}
			//}
			
			var url_icon:String = Config.getIcon(App.data.storage[_sid].type, App.data.storage[_sid].view);//Config.getImageIcon('sales/image', item.image);
			var url_bg:String = Config.getImageIcon('sales/bg', item.bg);
			
			var marginTxtY:int = 0;
			var marginTxtX:int = 0;
			var bitmap:Bitmap; 
			switch(item.bg) {
				case "star1":
					bitmap = new Bitmap(new BitmapData(82, 79, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x6d2c08;
					iconSettings.scale = 0.9;
				break;
				case "star2":
					bitmap = new Bitmap(new BitmapData(95, 92, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x23534a;
					marginTxtY = 16;
					marginTxtX = 7;
				break;
				case "round":
					bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
					marginTxtY = 10;
					marginTxtX = 5;
				break;
				default:
					bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
			}
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID, sale:'sales' } );
			
			textSettings.text = "";
			textSettings.fontSize = 19;
			iconSettings.filter = [];
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			//bttn.addChild(text);
			
			text.width = 95;
			text.x = -5 + marginTxtX;
			text.y = 55 + marginTxtY;
			
			Load.loading(url_bg, function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				
				Load.loading(url_icon, function(data:*):void {
					
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
					bttn.addChild(text);
					if (bttn.iconBmp.height + 18 > bttn.bitmap.height) {
						bttn.iconBmp.height = bttn.bitmap.height + 10;
						bttn.iconBmp.scaleX = bttn.iconBmp.scaleY;
					}else if (bttn.iconBmp.width + 18 > bttn.bitmap.width) {
						bttn.iconBmp.width = bttn.bitmap.width + 10;
						bttn.iconBmp.scaleY = bttn.iconBmp.scaleX;
					}
					
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
					
					bttn.initHotspot();
				});
			});
			
			App.self.setOnTimer(_update);
			function _update():void 
			{
				var time:int = item.duration * 3600 - (App.time - item.time);
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(_update);
					createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = item.duration * 3600 - (App.time - item.time);
				if (pID == "32") {
					text = Locale.__e('flash:1409671213710');
				}else if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				
				return {
					title:Locale.__e(item.title),
					text:text,
					timer:true
				}
			};	
			
			return bttn;
		}
		
		private function getBulkIcon(bttn:ImagesButton, item:Object, pID:String = ""):ImagesButton {
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.5,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:1
				//filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var _sid:*;
			
			for (_sid in App.data.bulkset[1].items) {
				break;
			}
			
			var url_icon:String = Config.getIcon(App.data.storage[_sid].type, App.data.storage[_sid].view);
			var url_bg:String = Config.getImageIcon('sales/bg', item.bg);
			
			var marginTxtY:int = 0;
			var marginTxtX:int = 0;
			var bitmap:Bitmap; 
			switch(item.bg) {
				case "star1":
					bitmap = new Bitmap(new BitmapData(82, 79, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x6d2c08;
					iconSettings.scale = 0.9;
				break;
				case "star2":
					bitmap = new Bitmap(new BitmapData(95, 92, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x23534a;
					marginTxtY = 16;
					marginTxtX = 7;
				break;
				case "round":
					bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
				break;
				default:
					bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49;
			}
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID, sale:'sales' } );
			
			var icon:Bitmap = new Bitmap(UserInterface.textures.shopIcon);
			icon.scaleX = icon.scaleY = 0.85;
			icon.smoothing = true;
			bttn.addChild(icon);
			
			icon.x = bttn.bitmap.x + (bttn.bitmap.width - icon.width) / 2;
			icon.y = bttn.bitmap.y + (bttn.bitmap.height - icon.height) / 2 - 5;
			
			textSettings.text = "";
			textSettings.fontSize = 19;
			iconSettings.filter = [];
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			bttn.addChild(text);
			
			text.width = 95;
			text.x = -3 + marginTxtX;
			text.y = 55 + marginTxtY;
			
			Load.loading(url_bg, function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				
				Load.loading(url_icon, function(data:*):void {
					
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
					
					if (bttn.iconBmp.height > bttn.bitmap.height) {
						bttn.iconBmp.height = bttn.bitmap.height - 18;
						bttn.iconBmp.scaleX = bttn.iconBmp.scaleY;
					}else if (bttn.iconBmp.width > bttn.bitmap.width) {
						bttn.iconBmp.width = bttn.bitmap.width - 18;
						bttn.iconBmp.scaleY = bttn.iconBmp.scaleX;
					}
					
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
					
					bttn.initHotspot();
				});
			});
			
			App.self.setOnTimer(_update);
			function _update():void 
			{
				var time:int = item.duration * 3600 - (App.time - item.time);
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(_update);
					createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = item.duration * 3600 - (App.time - item.time);
				if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				
				return {
					title:Locale.__e(item.title),
					text:text,
					timer:true
				}
			};	
			
			return bttn;
		}
		
		private function getBankSaleIcon(bttn:ImagesButton, btmd:BitmapData):ImagesButton
		{
			var textSettings:Object = {
				text:Locale.__e("flash:1382952379793"),
				fontSize:19,
				color:0xffffff,
				borderColor:0x23534a,
				scale:0.5,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:0.5
				//filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			bttn = new ImagesButton(btmd, null, { sale:'bankSale' } );
			
			var url_icon:String = Config.getImage('bankSale', "sale01");
			
			textSettings.text = "";// Locale.__e("");
			textSettings.fontSize = 19;
			iconSettings.filter = [];
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			bttn.addChild(text);
			
			text.width = 95;
			text.x = -2;
			text.y = 60;
			
			Load.loading(url_icon, function(data:*):void {
				
				bttn.icon = data.bitmapData;
				bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
				bttn.iconBmp.smoothing = true;
				bttn.iconBmp.filters = iconSettings.filter;
				bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width) / 2;
				bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height) / 2;
				
				bttn.initHotspot();
			});
			
			App.self.setOnTimer(_update);
			
			var timeToEnd:int = 0;
			if(App.data.money && App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1)
				timeToEnd = App.data.money.date_to;
			else if (App.user.money > App.time)
				timeToEnd = App.user.money;
			
			function _update():void 
			{
				var time:int = timeToEnd - App.time;
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(_update);
					saleLimit = 1;
					for each(var bttnB:ImagesButton in bankSaleIcons) {
						bttnB.hidePointing();
						bttnB.hideGlowing();
						promoPanel.removeChild(bttnB);
					}
					
					bankSaleIcons = [];
					createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
						
				var text:String;
				var time:int = timeToEnd - App.time;
				if (time < 60)
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				else
					text = Locale.__e('flash:1382952379794',[TimeConverter.timeToCuts(time, true, true)]);
				
				return {
					title:Locale.__e("flash:1396606263756"),
					text:text,
					timer:true
				}
			};	
			
			return bttn;
		}
		
		public function clearIconsGlow():void {
			for (var i:int = 0; i < promoIcons.length; i++){
				promoIcons[i].hideGlowing();
				promoIcons[i].hidePointing();
			}	
		}
		
		private function clearPromoPanel():void {
			
			for each(var bttn:ImagesButton in promoIcons) {
				bttn.hidePointing();
				bttn.hideGlowing();
				promoPanel.removeChild(bttn);
			}
			for each(bttn in premiumIcons) {
				bttn.hidePointing();
				bttn.hideGlowing();
				promoPanel.removeChild(bttn);
			}
			for each(bttn in setsIcons) {
				bttn.hidePointing();
				bttn.hideGlowing();
				promoPanel.removeChild(bttn);
			}
			setsIcons = [];
			premiumIcons = [];
			promoIcons = [];
		}
		
		private var premiumIcons:Array = [];
		private var premiumLimit:int = 1;
		private function createPremium():void 
		{	
			if (App.user.premiumPromos.length == 0 || numUpIcons >= iconsTopLimit) 
				return;
				
			var iconY:int = 0;
			var iconX:int = 34;
			
			var countPrimium:int = 0;
			
			if (bankSaleIcons.length > 0) {
				iconY += 96 * bankSaleIcons.length;
			}
			
			for (var i:int = 0; i < App.user.premiumPromos.length; i++ ) {
				if (countPrimium >= premiumLimit)
					break;
					
				if (App.user.stock.count(App.user.premiumPromos[i].sid) > 0) {
					continue;
				}
				
				//if (App.data.storage[App.user.premiumPromos[i].sid].type == "Character" && Character.isCharacter(App.user.premiumPromos[i].sid))
					//continue;
				
				for (var k:int = 0; k < App.user.arrHeroesInRoom.length; k++ ) {
					if (App.user.arrHeroesInRoom[k] == App.user.premiumPromos[i].sid)
						isDeniy = true;
				}
				
				var isDeniy:Boolean = false;
				for (var j:int = 0; j < App.user.characters.length; j++ ) {
					if (App.user.characters[i].sid == App.user.premiumPromos[i].sid)
						isDeniy = true;
				}
				if (isDeniy)
					continue;
				
				if (App.user.premiumPromos[i].hasOwnProperty('social') && !App.user.premiumPromos[i].social.hasOwnProperty(App.social)) 
				continue;
				
				var sale:Object = App.user.premiumPromos[i];
				if (sale.unlock.level > App.user.level)
					continue;
				if (App.time > sale.time + sale.duration * 3600)
					continue;
				
				var bttn:ImagesButton = getPremiumIcon(bttn, sale, App.user.premiumPromos[i].pID);
				premiumIcons.push(bttn);
				
				bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
				//bttn.x = 40 - bttn.bitmap.width/2;
				bttn.x = iconX - bttn.bitmap.width/2;
				
				bttn.y = iconY;
				
				iconY += bttn.bitmap.height + 4;
				
				promoPanel.addChild(bttn);
				
				promoPanel.y = 160;
				if (App.user.premiumPromos[i].time + 15 > App.time) {
					startGlow(bttn);
				}
				
				countPrimium++;
				numUpIcons++;
				
				iconsPosY += iconHeight + 31;
			}
		}
	
		private var openSale:Boolean = false;
		private var saleLimit:int = 1;
		private function createSales():void {
			
			if (App.data.sales == null  || numUpIcons >= iconsTopLimit) 
				return;
				
			var iconY:int = 0;
			var iconX:int = 34;
			
			if (premiumIcons.length > 0) {
				iconY += 96 * premiumIcons.length;
			}
			
			if (bankSaleIcons.length > 0) {
				iconY += 96 * bankSaleIcons.length;
			}
			
			var countSales:int = 0;
			for (var saleID:* in App.data.sales) {
				if (countSales >= saleLimit)
					break;
				
				if (App.data.sales[saleID].hasOwnProperty('social') && !App.data.sales[saleID].social.hasOwnProperty(App.social)) 
				continue;
				
				var sale:Object = App.data.sales[saleID];
				if (sale.unlock.level > App.user.level)
					continue;
				if (App.time > sale.time + sale.duration * 3600)
					continue;
				
				var bttn:ImagesButton = getSaleIcon(bttn, sale, saleID);
				promoIcons.push(bttn);
				
				bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
				
				bttn.y = iconY;
				bttn.x = iconX - bttn.bitmap.width/2;
				
				iconY += bttn.bitmap.height + 4;
				
				promoPanel.addChild(bttn);
				
				promoPanel.y = 160;
				if (App.data.sales[saleID].time + 15 > App.time) {
					startGlow(bttn);
				}
				
				promoIconId++;
				countSales++;
				numUpIcons++;
				
				iconsPosY += iconHeight + 31;
				
				if (!openSale) {
					openSale = true;
				}
			}
		}
		
		private var setsIcons:Array = [];
		private function createBulks():void {
			
			if (numUpIcons >= iconsTopLimit || App.user.level < 5) 
				return;
			
			var iconY:int = 0;
			
			if (premiumIcons.length > 0) {
				iconY += 96 * premiumIcons.length;
			}
			
			if (promoIcons.length > 0) {
				iconY += 96 * promoIcons.length;
			}
			
			if (bankSaleIcons.length > 0) {
				iconY += 96 * bankSaleIcons.length;
			}
			
			for (var bulkID:* in App.data.bulks) {
				var bulk:Object = App.data.bulks[bulkID];
				if (bulk.social.hasOwnProperty(App.social)) /// ВЕРНУТЬ ОБРАТНО, СДЕЛАНО ДЛЯ ТЕСТА
				//if (bulk.social.hasOwnProperty("DM")) 
				{
					if (bulk.time + (bulk.duration * 3600) <= App.time)
						continue;
						
					bulk['bg'] = 'round';
					bulk['image'] = 'sets_icon'; 
					var bttn:ImagesButton = getBulkIcon(bttn, bulk, bulkID);
					setsIcons.push(bttn);
					
					bttn.addEventListener(MouseEvent.CLICK, onBulksOpen);
					bttn.x = 34 - bttn.bitmap.width/2;
					bttn.y = iconY;
					
					promoPanel.addChild(bttn);
					checkOnGlow('sale', bttn, bulkID);
					
					promoIconId++;	
					numUpIcons++;
					
					iconsPosY += iconHeight + 31;
				}
			}
		}
		
		private function onBulksOpen(e:MouseEvent):void {
			e.currentTarget.hideGlowing();
			e.currentTarget.hidePointing();
			
			var pID:String = e.currentTarget.settings.pID;
			
			if (App.data.bulks.hasOwnProperty(pID)) {
				
				
				new SalesSetsWindow2( {
					pID:pID
				}).show();
				return;
			}
		}
		
		private function createBigSales():void
		{
			if (numUpIcons >= iconsTopLimit || App.user.level < 5)
				return;
				
			
			var sales:Array = [];
			var sale:Object;
			for (var sID:* in App.data.bigsale) {
				sale = App.data.bigsale[sID];
				if(sale.social == App.social)
					sales.push({sID:sID, order:sale.order, sale:sale});
			}
			sales.sortOn('order');
			
			//var iconX:int = -8;
			var iconY:int = 0;
			if (premiumIcons.length > 0) {
				iconY += 96 * premiumIcons.length;
			}
			
			if (promoIcons.length > 0) {
				iconY += 96 * promoIcons.length;
			}
			
			if (bankSaleIcons.length > 0) {
				iconY += 96 * bankSaleIcons.length;
			}
			
			if (setsIcons.length > 0) {
				iconY += 96 * setsIcons.length;
			}
			
			for each(sale in sales)
			{
				if (App.time > sale.sale.time && App.time < sale.sale.time + sale.sale.duration * 3600)
				{
					sale.sale['bg'] = 'round';
					var bttn:ImagesButton = getBigSaleIcon(bttn, sale.sale, sale.sID);
					promoIcons.push(bttn);
					
					bttn.addEventListener(MouseEvent.CLICK, onPromoOpen);
					bttn.x = 34 - bttn.bitmap.width/2;
					bttn.y = iconY;
					
					promoPanel.addChild(bttn);
					checkOnGlow('sale', bttn, sale.sID);
					
					promoIconId++;
					numUpIcons++;
					
					iconsPosY += iconHeight + 31;
					break;
				}
			}
		}
		
		private function getBigSaleIcon(bttn:ImagesButton, sale:Object, pID:String = ''):ImagesButton {
			
			var marginTxtY:int = 0;
			var marginTxtX:int = 0;
			var bitmap:Bitmap; 
			
			var textSettings:Object = {
				text:"",
				color:0xffffff,
				fontSize:19,
				borderColor:0x272a49,
				scale:0.55,
				textAlign:'center'
			}
			
			switch(sale.bg) {
				case "star1":
					bitmap = new Bitmap(new BitmapData(82, 79, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x6d2c08;
					iconSettings.scale = 0.9;
				break;
				case "star2":
					bitmap = new Bitmap(new BitmapData(95, 92, true, 0), "auto", true);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x23534a;
					marginTxtY = 16;
					marginTxtX = 7;
				break;
				case "round":
					bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49
					//bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
					//textSettings['color'] = 0xffffff;
					//textSettings['borderColor'] = 0x272a49;
					marginTxtY = 10;
					marginTxtX = 5;
				break;
				default:
					bitmap = new Bitmap(UserInterface.textures.saleBacking2);
					textSettings['color'] = 0xffffff;
					textSettings['borderColor'] = 0x272a49
				//default:
					//bitmap = new Bitmap(new BitmapData(85, 85, true, 0), "auto", true);
					//textSettings['color'] = 0xffffff;
					//textSettings['borderColor'] = 0x272a49;
			}
			
			//var bitmap:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), "auto", true);
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID, sale:'bigSale' } );
			
			
			var material:uint = sale.items[0].sID;
			var type:String = App.data.storage[material].type;
			
			var preview:String = App.data.storage[material].preview;
			
			switch(sale.items[0].sID) {
				case Stock.COINS:
					type = "Coins";
					preview = getPreview(Stock.COINS, sale,  type);
				break;
				case Stock.FANT:
					type = "Reals";
					preview = getPreview(Stock.FANT, sale);
				break;
				case Stock.FANTASY:
					type = "Material";
					//preview = App.data.storage[169].preview;
					//preview = getPreview(Stock.FANTASY, sale);
					//preview = getPreview(169,/*Stock.FANTASY,*/ sale);
				break;
			}
			
			var url_icon:String;
			if (material == 2) {
				url_icon = Config.getIcon(App.data.storage[169].type, App.data.storage[169].preview);
			}else {
				url_icon = Config.getIcon(type, preview);
			}
			var url_bg:String = Config.getImageIcon('sales/bg', sale.bg);
			
			
			var iconSettings:Object = {
				scale:0.55
				//filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			text.width = 95;
			text.x = -10 + marginTxtX;
			text.y = 50 + marginTxtY;
			
			//Load.loading(url_bg, function(data:*):void {
				//bttn.bitmapData = data.bitmapData;
				
				Load.loading(url_icon, function(data:*):void {
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width)/2;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height)/2 - 2;
					
					bttn.addChild(text);
					bttn.initHotspot();
				});
			//});
			
			App.self.setOnTimer(update);
			
			function update():void {
				var time:int = sale.duration * 3600 - (App.time - sale.time);
				text.text = TimeConverter.timeToStr(time);
				if (time < 0) {
					App.self.setOffTimer(update);
					createPromoPanel();
				}
			}
			
			bttn.tip = function():Object {
				return {
					title:Locale.__e('flash:1408612454582')//Locale.__e(sale.title)
				}
			};	
			
			return bttn;
		}
		
		private function getPreview(sid:int, sale:Object, type:String = "Reals"):String
		{
			var preview:String = App.data.storage[sid].preview;
			
			var arr:Array = [];
			arr = getIconsItems(type);
			arr.sortOn("order", Array.NUMERIC);
			
			if (arr.length == 0) return preview;
			preview = arr[arr.length-1].preview;
			for (var j:int = arr.length-1; j >= 0; j-- ) {
				if (sale.items[0].c >= arr[j].price[sid]) {
					preview = arr[j].preview;
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
		
		public function hide():void {
			this.visible = false;
		}
		
		public function show():void {
			this.visible = true;
		}
		
		public function resize():void {
			this.x = App.self.stage.stageWidth - 82;
			
			createPromoPanel();
			
			TipsPanel.resize();
		}
		
	}

}


import buttons.ImageButton;
import core.Debug;
import flash.display.Sprite;
import flash.events.MouseEvent;
import wins.Window;
import wins.WindowEvent;
import ui.UserInterface;
import ui.QuestIcon;
import ui.SalesPanel;

internal class PromoPaginator extends Sprite{
	
	public var startItem:uint = 0;
	public var endItem:uint = 0;
	public var length:uint = 0;
	public var itemsOnPage:uint = 0;
	
	public var _parent:SalesPanel;
	public var data:Array;
	
	public function PromoPaginator(data:Array, itemsOnPage:uint, _parent:SalesPanel) {
		
		this._parent = _parent;
		this.data = data;
		length = data.length;
		startItem = 0;
		this.itemsOnPage = itemsOnPage;
		endItem = startItem + itemsOnPage;
		trace();
	}
	
	public function up(e:* = null):void {
		if (startItem > 0) {
			startItem --;
			endItem = startItem + itemsOnPage;
			
			_parent.updateSales();
			change();
		}
	}
	
	public function down(e:* = null):void {
		startItem ++;
		endItem = startItem + itemsOnPage;
		
		_parent.updateSales();
		change();
	}
	
	public function change(isLevelUp:Boolean = false):void {
		
		length = App.user.promos.length;
		
		if (startItem == 0){
			arrowUp.visible = false;
		}else{
			arrowUp.visible = true;
		}	
		
		if(startItem + itemsOnPage >= length)
			arrowDown.visible = false;
		else
			arrowDown.visible = true;
		
		_parent.doCreate(isLevelUp);
	}
	
	public var arrowUp:ImageButton;
	public var arrowDown:ImageButton;
	
	public function drawArrows():void
	{
		if (arrowUp == null && arrowDown == null)
		{
			arrowUp = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:1, sound:'arrow_bttn'});
			arrowDown = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:-1, sound:'arrow_bttn'});
			
			_parent.promoPanel.addChild(arrowUp);
			arrowUp.x = 22;
			
			_parent.promoPanel.addChild(arrowDown);
			arrowDown.x = 22;
			
			arrowUp.addEventListener(MouseEvent.CLICK, up);
			arrowDown.addEventListener(MouseEvent.CLICK, down);
		}
		
		setArrowsPosition();
	}
	
	public function resize(_height:uint, isLevelUp:Boolean = false):void {
		itemsOnPage = Math.floor(_height / 90);
		startItem = 0;
		endItem = startItem + itemsOnPage;
		setArrowsPosition();
		change(isLevelUp);
	}
	
	public function setArrowsPosition():void {
		
		arrowUp.y 	= _parent.iconsPosY - arrowUp.height - 10;
		arrowDown.y = _parent.iconsPosY + _parent.iconsHeight;//164;
	}
}