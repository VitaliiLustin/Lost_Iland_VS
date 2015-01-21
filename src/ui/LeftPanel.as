package ui 
{
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import core.CookieManager;
	import core.Debug;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import wins.BigsaleWindow;
	import wins.DreamsWindow;
	import wins.PromoWindow;
	import wins.SaleLimitWindow;
	import wins.SalesWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	public class LeftPanel extends Sprite
	{
		
		public var glowedIcons:Object = { };
		public var guestEnergy:Sprite = new Sprite();
		public var questsPanel:QuestPanel;
		//public var promoPanel:Sprite = new Sprite();
		
		public var questIcons:Array = [];
		//public var promoIcons:Array = [];
		//public var newPromo:Object = {};
		
		//public var lastVisible:Array = [];
		
		public var bttnMainDreams:ImagesButton;
		public static var iconHeight:uint = 80;
		
		public function LeftPanel():void
		{
			for each(var character:* in App.data.personages) {
				Load.loading(Config.getQuestIcon('icons', character.preview), function(data:*):void { } );
			}
			var material:Object = App.data.storage[Stock.COINS];
			
			Load.loading(Config.getIcon(material.type, material.preview), function(data:*):void { } );
			addChild(guestEnergy);
			//addChild(promoPanel);
			
			//if(App.data.promo){
				//setTimeout(initPromo, 100);
			//}
			createQuestPanel();
			//setTimeout(createQuestPanel, 200);
			App.self.stage.addEventListener(Event.FULLSCREEN, onFullscreen);
		}
		
		public function createQuestPanel():void {
			
			//return;
			if (questsPanel != null) {
				removeChild(questsPanel);
				questsPanel = null; 
			}
			
			questsPanel = new QuestPanel(this);
			//questsPanel.y = promoPanel.y + promoIcons.length * 90;
			//if (questsPanel.y < 70)	questsPanel.y = 70;
			addChild(questsPanel);
		}
		
		public function initPromo():void {
			//createPromoPanel();
			//promoTime();
			App.user.quests.checkPromo();
		}
		
		private function createDreamsBttn():void
		{
			bttnMainDreams = new ImagesButton(UserInterface.textures.mainBttnBacking, UserInterface.textures.mainBttnCollections, { ix:3 } );
			bttnMainDreams.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379791"),
					text:Locale.__e("flash:1382952379792")
				};
			}
			
			bttnMainDreams.addEventListener(MouseEvent.CLICK, onBttnMainDreams);
			bttnMainDreams.y = App.self.stage.stageHeight - bttnMainDreams.height - 120;
			bttnMainDreams.x = 10;
			
			addChild(bttnMainDreams);
		}
		
		private function onBttnMainDreams(e:MouseEvent):void
		{
			new DreamsWindow().show();
		}
		
		private function onFullscreen(e:Event):void {
			//setTimeout(createQuestPanel, 60);
			if(App.user.mode == User.GUEST){
				setTimeout(update, 60);
			}
		}
		
		public var iconDealSpot:*;
		public function createDealSpot(swf:*):void {
			iconDealSpot = swf;
			//promoPanel.addChild(iconDealSpot);
			iconDealSpot.x = 120;
			iconDealSpot.y = 0;
		}
		
		public function checkOnGlow(type:String, bttn:ImagesButton, pID:*):void 
		{
			if (ExternalInterface.available) 
			{
				var pID:String = String(pID);
				var cookieName:String = pID + "_" + App.user.id;
				var value:String = CookieManager.read(cookieName);
				
				
				if (value != '1') {
					Post.addToArchive('startGlow: '+ pID);
					startGlow(bttn);
					CookieManager.store(cookieName, '1');
				}
			}
		}
		
		private function startGlow(bttn:ImagesButton):void {
			bttn.showGlowing();
			bttn.showPointing("left", 0, 50, App.ui.leftPanel, Locale.__e("flash:1382952379795"), {
				color:0xf3c769,
				borderColor:0x322204,
				autoSize:"left",
				fontSize:24
			}, false);
		}
		
		public function clearIconsGlow():void {
			//for (var i:int = 0; i < promoIcons.length; i++){
				//promoIcons[i].hideGlowing();
				//promoIcons[i].hidePointing();
			//}	
			
			questsPanel.clearIconsGlow();
		}
		
		public function showGuestEnergy():void {
			if (App.owner == null) {
				return;
			}
			
			clearIconsGlow();
			questsPanel.visible = false;
			//promoPanel.visible = false;
			
			var childs:int = guestEnergy.numChildren;
			
			var friend:Object = App.user.friends.uid(App.owner.id);
			
			if (childs > 0 && childs > friend.energy) {
				var icon:*;
				if (App.user.stock.count(Stock.GUESTFANTASY) && friend.energy > 0) {
					icon = guestEnergy.getChildAt(0);
				}else if (App.user.stock.count(Stock.GUESTFANTASY)) {
					icon = guestEnergy.getChildAt(0);
				}else{
					icon = guestEnergy.getChildAt(0);
				}
				
				App.ui.glowing(icon, 0x86e3f2, function():void{ 
					update();
				});
				
			}else {
				update();
			}
		}
		
		public function update():void 
		{
			var friend:Object = App.user.friends.uid(App.owner.id);
			
			while (guestEnergy.numChildren) {
				guestEnergy.removeChildAt(0);
			}
			var material:Object = App.data.storage[Stock.GUESTFANTASY];
			var contEn:LayerX;
			var limit:int = App.user.friends.energyLimit;
			if (limit > 0) {
				var min:int = Math.min(limit, friend.energy);
				for (var i:int = 0; i < min; i++) {
					contEn = new LayerX();
					var bitmap:Bitmap = new Bitmap(UserInterface.textures.guestEnergy);
					bitmap.scaleX = bitmap.scaleY = 0.6;
					bitmap.smoothing = true;
					bitmap.x = 6;
					bitmap.y = (App.self.stage.stageHeight - min * bitmap.height) / 2 + (bitmap.height + 10) * i;
					contEn.addChild(bitmap);
					guestEnergy.addChild(contEn);
					
					contEn.tip = function():Object { 
						return {
							title:Locale.__e('flash:1404378818609'),
							text:Locale.__e("flash:1404378842760")
						};
					};
				}
				if(App.user.stock.count(Stock.GUESTFANTASY)){
					Load.loading(Config.getIcon(material.type, material.preview), function(data:*):void { 
						contEn = new LayerX();
						var bitmap:Bitmap = data;
						bitmap.scaleX = bitmap.scaleY = 0.6;
						bitmap.smoothing = true;
						bitmap.x = 2;
						bitmap.y = (App.self.stage.stageHeight + min*bitmap.height)/2 - bitmap.height * (i+1) - 10 ;
						
						var counter:TextField = Window.drawText('x' + App.user.stock.count(Stock.GUESTFANTASY), {
							fontSize:22,
							autoSize:"left",
							color:0x38342c,
							borderColor:0xecddb9
						});
						
						contEn.addChild(bitmap);
						contEn.addChild(counter);
						guestEnergy.addChild(contEn);
						counter.x = bitmap.x + bitmap.width - 30;
						counter.y = bitmap.y + bitmap.height - counter.height;
						
						contEn.tip = function():Object { 
							return {
								title:Locale.__e('flash:1404378818609'),
								text:Locale.__e("flash:1404378842760")
							};
						};
						
					});
				}
				
			}else{
				if(App.user.stock.count(Stock.GUESTFANTASY)){
					Load.loading(Config.getIcon(material.type, material.preview), function(data:*):void { 
						var bitmap:Bitmap = data;
						bitmap.scaleX = bitmap.scaleY = 0.6;
						bitmap.smoothing = true;
						
						bitmap.x = 2;
						bitmap.y = (App.self.stage.stageHeight - bitmap.height)/2;
						guestEnergy.addChild(bitmap);
						
						var counter:TextField = Window.drawText('x' + App.user.stock.count(Stock.GUESTFANTASY), {
							fontSize:22,
							autoSize:"left",
							color:0x38342c,
							borderColor:0xecddb9
						});
						
						guestEnergy.addChild(counter);
						counter.x = bitmap.x + bitmap.width - 30;
						counter.y = bitmap.y + bitmap.height - counter.height;
					});
				}
				/*
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					text:Locale.__e("flash:1382952379796")
				}).show();
				*/
			}
		}
		
		public function hideGuestEnergy():void {
			while (guestEnergy.numChildren) {
				guestEnergy.removeChildAt(0);
			}
			
			//promoPanel.visible = true;
			questsPanel.visible = true;
		}
		
		public function resize():void {
			if (questsPanel) 
				questsPanel.resize();
		}
		
		/*private function getBigSaleIcon(bttn:ImagesButton, sale:Object, pID:String = ''):ImagesButton {
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), "auto", true);
			bttn = new ImagesButton(bitmap.bitmapData, null, { pID:pID } );
			
			var material:uint = sale.items[0].sID
			var url_icon:String = Config.getIcon(App.data.storage[material].type, App.data.storage[material].preview);
			var url_bg:String = Config.getImage('sales/bg', 'glow');
			
			var textSettings:Object = {
				text:"",
				color:0xf0e6c1,
				fontSize:19,
				borderColor:0x634807,
				scale:0.55,
				textAlign:'center'
			}
			
			var iconSettings:Object = {
				scale:0.55,
				filter:[new GlowFilter(0xf8da0f, 1, 4, 4, 8, 1)]
			}
			
			var text:TextField = Window.drawText(textSettings.text, textSettings);
			text.width = 95;
			text.x = -10;
			text.y = 45;
			
			Load.loading(url_bg, function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				
				Load.loading(url_icon, function(data:*):void {
					bttn.icon = data.bitmapData;
					bttn.iconBmp.scaleX = bttn.iconBmp.scaleY = iconSettings.scale;
					bttn.iconBmp.smoothing = true;
					bttn.iconBmp.filters = iconSettings.filter;
					bttn.iconBmp.x = (bttn.bitmap.width - bttn.iconBmp.width)/2 - 5;
					bttn.iconBmp.y = (bttn.bitmap.height - bttn.iconBmp.height)/2 - 6;
					
					bttn.addChild(text);
					bttn.initHotspot();
				});
			});
			
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
					title:Locale.__e(sale.title)
				}
			};	
			
			return bttn;
		}*/
	}
}

