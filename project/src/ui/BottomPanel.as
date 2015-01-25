package ui 
{
	import adobe.utils.CustomActions;
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.MixedButton;
	import buttons.UpgradeButton;
	import com.adobe.images.BitString;
	import com.google.analytics.core.ServerOperationMode;
	import com.sociodox.theminer.manager.SampleAnalyzerImpl;
	import core.Debug;
	import core.Load;
	import core.Log;
	import core.Post;
	import effects.ParticleEffect;
	import effects.Particles;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import mx.core.BitmapAsset;
	import units.Bridge;
	import units.Field;
	import units.Lantern;
	import units.Pigeon;
	import units.Storehouse;
	import units.Trade;
	import units.Unit;
	import wins.AchivementMsgWindow;
	import wins.AchivementPremiumWindow;
	import wins.AchivementsWindow;
	import wins.BestFriendsWindow;
	import wins.BigsaleWindow;
	import wins.CharactersWindow;
	import wins.CollectionWindow;
	import wins.CommunityWindow;
	import wins.DayliBonusWindow;
	import wins.DialogWindow;
	import wins.elements.PostPreloader;
	import wins.elements.TresureIcon;
	import wins.EnlargeStorageWindow;
	import wins.ErrorWindow;
	import wins.FindPersonageWindow;
	import wins.FreeGiftsWindow;
	import wins.FriendsWindow;
	import wins.InstanceInfoWindow;
	import wins.InviteBestFriendWindow;
	import wins.InviteLostFriendsWindow;
	import wins.InviteSocialFriends;
	import wins.InvitesWindow;
	import wins.LevelBragWindow;
	import wins.LevelUpWindow;
	import wins.MoneyHouseWindow;
	import wins.NectarAddChooseWindow;
	import wins.NewsWindow;
	import wins.OfferWindow;
	import wins.PortWindow;
	import wins.SaleDecorWindow;
	import wins.SalesSetsWindow2;
	//import wins.PortWindow;
	import wins.QuestRewardWindow;
	import wins.ReferalRewardWindow;
	import wins.RewardWindow;
	import wins.SaleGoldenWindow;
	import wins.SaleLimitWindow;
	import wins.SalesSetsWindow;
	import wins.SalesWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.ThematicalSaleWindow;
	import wins.TradeWindow;
	import wins.TravelWindow;
	import wins.TresureWindow;
	import wins.VisitWindow;
	import wins.Window;
	import com.greensock.TweenLite;
	import wins.WindowEvent;
	
	public class BottomPanel extends Sprite
	{
		public var bttnPrev:ImageButton,
				bttnPrevSix:ImageButton,
				bttnPrevAll:ImageButton,
				bttnNext:ImageButton,
				bttnNextSix:ImageButton,
				bttnNextAll:ImageButton,
				bttnMainShop:ImagesButton,
				bttnMainStock:ImagesButton,
				bttnMainHome:UpgradeButton,
				bttnStop:ImagesButton,
				bttnStopFriends:ImagesButton,
				bttnCursors:ImagesButton,
				openArrow:Bitmap = new Bitmap(UserInterface.textures.openArrow),
				cursorsPanel:Sprite,
				mainPanel:Sprite,
				iconsPanel:Sprite = new Sprite(),		
				counterTradePanel:Bitmap,
				tradeCounter:TextField,
				counterAchivePanel:Bitmap,
				achiveCounter:TextField,
				counterCollPanel:Bitmap,
				collCounter:TextField,
				tresureIcons:Array = [],
				bttnMainGifts:ImagesButton,
				counterPanel:Bitmap,
				giftCounter:TextField;
				
		private var tradeCounterCont:Sprite,
				achiveCounterCont:Sprite,
				collCounterCont:Sprite,
				giftCounterCont:Sprite;
				
		public function removeTresure(sid:int):void
		{
			var trIcon:TresureIcon;
			for (var i:int = 0; i < tresureIcons.length; i++ ) {
				trIcon = tresureIcons[i];
				if(sid == trIcon.sid){
					trIcon.dispose();
					trIcon = null;
					tresureIcons.splice(i, 1);
					resizeTresureIcons();
					break;
				}
			}
		}
		
		public function resizeTresureIcons():void
		{
			var posX:int = 0;// App.ui.bottomPanel.iconsPanel.x + App.ui.bottomPanel.iconsPanel.width;
			for (var i:int = 0; i < tresureIcons.length; i++ ) {
				
				tresureIcons[i].x = posX;
				tresureIcons[i].y = 0;// App.self.stage.stageHeight - tresureIcons[i].bg.height - 2;
				
				posX += tresureIcons[i].bg.width + 14;
				
			}
		}
		
		private var tresureCont:Sprite = new Sprite();
		public function addTresure(sid:int, roomSid:int):void
		{
			if (App.user.quests.tutorial) 
				tresureCont.visible = false;
			if (!canAddTresureIcon(sid)) return;
			
			var tresureIcon:TresureIcon = new TresureIcon(sid, roomSid);
			tresureIcons.push(tresureIcon);
			tresureCont.addChild(tresureIcon);
			resizeTresureIcons();
			
			tresureCont.x = App.ui.bottomPanel.iconsPanel.x + App.ui.bottomPanel.iconsPanel.width;
			tresureCont.y = App.self.stage.stageHeight - 82;
			
			if(!App.user.quests.isTutorial){
				var winSettings:Object = {
					title				:App.data.storage[roomSid].title,
					text				:Locale.__e('flash:1402926875000'),
					instanceId          :sid,
					closeAfterOk        :true
				};
				if(App.user.worldID == App.data.storage[tresureIcon.sid].land && App.user.mode == User.OWNER && !TresureWindow.isOpen)
					new TresureWindow(winSettings).show();
			}
		}
		
		private function canAddTresureIcon(sid:int):Boolean 
		{
			for (var i:int; i < tresureIcons.length; i++ ) {
				if (tresureIcons[i].sid == sid) {
					return false;
				}
			}
			return true;
		}
		
		
		private var dY:int = 0;
		public function resize():void {
			
			if (tweenIcons) {
				tweenIcons.kill();
				tweenIcons = null;
			}
			if (tweenMain) {
				tweenMain.kill();
				tweenMain = null;
			}
			
			if (isShowMain) {
				mainPanel.y = App.self.stage.stageHeight - 71;
			}else {
				mainPanel.y = App.self.stage.stageHeight - 72 + dY;
			}
			mainPanel.x = App.self.stage.stageWidth - 196;
			
			bttnMainHome.x = App.self.stage.stageWidth - bttnMainHome.width - 4;
			bttnMainHome.y = App.self.stage.stageHeight - 80;
			
			bttnStopFriends.x = App.self.stage.stageWidth - 250;
			bttnStopFriends.y = App.self.stage.stageHeight - 108;
			
			if(iconsPanel){
				iconsPanel.x = -4;
				if(!friendsPanel.opened)
					iconsPanel.y = App.self.stage.stageHeight - 52 +dY;
				else
					iconsPanel.y = App.self.stage.stageHeight + 30 + dY;
			}
			
			if (friendsPanel) {
				friendsPanel.resize();
				friendsPanel.x = 10;
				if(friendsPanel.opened)
					friendsPanel.y = App.self.stage.stageHeight - 72 + dY;
				else
					friendsPanel.y = App.self.stage.stageHeight + 45 + dY;
			}
			
			tresureCont.x = App.ui.bottomPanel.iconsPanel.x + App.ui.bottomPanel.iconsPanel.width;
			tresureCont.y = App.self.stage.stageHeight - 82;
		}
		
		public function hide(tween:Boolean = false):void {
			dY = 100;
			mainPanel.visible = false;
			friendsPanel.visible = false;
			iconsPanel.visible = false;
			resize();
		}
		
		public function show(only:String = ''):void {
			dY = 0;
			mainPanel.visible = true;
			TweenLite.to(mainPanel, 0.5, { y:App.self.stage.stageHeight - 85 + dY } );
			if (only == 'mainPanel') return;
			
			var finY:int;
			if (iconsPanel) {
				if (!friendsPanel.opened) 	finY = App.self.stage.stageHeight - 52 + dY;
				else						finY = App.self.stage.stageHeight + 20 + dY;
			}
			TweenLite.to(iconsPanel, 0.5, { y:finY } );
			
			if (friendsPanel) {
				if(friendsPanel.opened) 	finY = App.self.stage.stageHeight - 72 + dY;
				else						finY = App.self.stage.stageHeight + 20 + dY;
			}
			
			TweenLite.to(friendsPanel, 0.5, { y:finY } );
			friendsPanel.visible = true;
			iconsPanel.visible = true;
		}
		
		private function drawMainPanel():void {
			var _bmp:Bitmap = new Bitmap(UserInterface.textures.panelMain);
			mainPanel = new Sprite();
			_bmp.x = -35;
			_bmp.y = -57-1;
			mainPanel.addChild(_bmp);
			mainPanel.x = App.self.stage.stageWidth + 220;
			mainPanel.y = App.self.stage.stageHeight + 85;
			addChild(mainPanel);
			
			bttnCursors = new ImagesButton(UserInterface.textures.interRoundBttn2, UserInterface.textures.iconCursorMain, {ix:10,iy:8});//UserInterface.textures.cursorsBacking
			bttnCursors.addChildAt(openArrow,1);
			
			bttnCursors.x = -23;
			bttnCursors.y = -36;
			openArrow.x = 30;
			openArrow.y = 5;
			
			bttnCursors.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379760"),
					text:Locale.__e("flash:1382952379761")
				}
			}
			mainPanel.addChild(bttnCursors);
			bttnCursors.addEventListener(MouseEvent.CLICK, onCursorsEvent);
			
			
			bttnStop = new ImagesButton(UserInterface.textures.interRoundBttn3, UserInterface.textures.stopBttnIco, { ix:8, iy:8 } );
				bttnStop.x = -17;
				bttnStop.y = 23;
				bttnStop.addEventListener(MouseEvent.CLICK, onStopEvent);
				bttnStop.tip = function():Object { return { title:Locale.__e("flash:1396963190624"), text:Locale.__e("flash:1382952379763") }; }
				mainPanel.addChild(bttnStop);
			
			bttnStopFriends = new ImagesButton(UserInterface.textures.interRoundBttn3, UserInterface.textures.stopBttnIco, { ix:8, iy:8 } );
				bttnStopFriends.x = App.self.stage.stageWidth - 250;
				bttnStopFriends.y = App.self.stage.stageHeight - 108;
				bttnStopFriends.addEventListener(MouseEvent.CLICK, onStopEvent);
				bttnStopFriends.tip = function():Object { return { title:Locale.__e("flash:1396963190624"), text:Locale.__e("flash:1382952379763") }; }
				bttnStopFriends.visible = false;
				addChild(bttnStopFriends);
			
			
			//Создание панели курсоров
			makeCursorsPanel();
			
			bttnMainShop = new ImagesButton(UserInterface.textures.interRoundBttn1, UserInterface.textures.shopIcon);// , { ix:0, iy:3 } );
			bttnMainStock = new ImagesButton(UserInterface.textures.interBoxBttn1, UserInterface.textures.stockIcon);// , { ix:8, iy:3 } );
			bttnMainHome = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption: Locale.__e("flash:1382952379764"),
				width:236,
				height:55,
				fontBorderColor:0x002932,
				countText:"",
				fontSize:28,
				iconScale:0.95,
				radius:30,
				textAlign:'left',
				autoSize:'left',
				widthButton:230
			});
			bttnMainHome.textLabel.x = (bttnMainHome.width - bttnMainHome.textLabel.width)/2;
			//upgradeBttn.coinsIcon.x += 18;
			//bttnMainHome = new MixedButton(Window.textures.homeBttnBg,{caption:Locale.__e("flash:1382952379764"),fontSize:30, fontColor:0xffffff, fontBorderColor:0x1d1132});
			
			mainPanel.addChild(bttnMainShop);
			bttnMainShop.x = 40;
			bttnMainShop.y = -10;
			bttnMainShop.addEventListener(MouseEvent.CLICK, onShopEvent);
			
			bttnMainShop.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379765"),
					text:Locale.__e("flash:1382952379766")
				};
			}
			
			mainPanel.addChild(bttnMainStock);
			bttnMainStock.x = 132 - 2;
			bttnMainStock.y = 10 -2;
			bttnMainStock.addEventListener(MouseEvent.CLICK, onStockEvent);
			bttnMainStock.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379767"),
					text:Locale.__e("flash:1382952379768")
				};
			}
			
			bttnMainHome.visible = false;
			addChild(bttnMainHome);
			//bttnMainHome.x = -40;
			//bttnMainHome.y = -14;
			bttnMainHome.x = App.self.stage.stageWidth - bttnMainHome.width - 4;
			bttnMainHome.y = App.self.stage.stageHeight - 80;
			bttnMainHome.addEventListener(MouseEvent.CLICK, Travel.goHome);
			
			bttnMainHome.tip = function():Object {
				return {
					title:Locale.__e("flash:1382952379764"),
					text:Locale.__e("flash:1382952379769")
				};
			}
			
			
			//bttnMainGifts = new ImagesButton(UserInterface.textures.interRoundBttn2, UserInterface.textures.giftsIcon,null, 0.8);
			//bttnMainGifts.tip = function():Object {
				//return {
					//title:Locale.__e("flash:1382952379798"),
					//text:Locale.__e("flash:1382952379799")
				//};
			//}
			//bttnMainGifts.x = 133;
			//bttnMainGifts.y = -54;
			//mainPanel.addChild(bttnMainGifts);
			//bttnMainGifts.addEventListener(MouseEvent.CLICK, onMainGifts);
			
			//counterPanel = new Bitmap(UserInterface.textures.simpleCounterGreen);
			
			//var textSettings:Object = {
				//color:0xffffff,
				//borderColor:0x35717d,
				//fontSize:16,
				//textAlign:"center"
			//};
			
			//giftCounter = Window.drawText(String(25), textSettings);
			//giftCounter.width = 60;
			//giftCounter.height = giftCounter.textHeight;
			//giftCounter.x = counterPanel.width / 2 - 31;
			//giftCounter.y = counterPanel.height / 2 - giftCounter.height / 2 - 1;
			//
			//giftCounterCont = new Sprite();
			//giftCounterCont.addChild(counterPanel);
			//giftCounterCont.addChild(giftCounter);
			//giftCounterCont.x = bttnMainGifts.x - 12;
			//giftCounterCont.y = bttnMainGifts.y + 30;
			//mainPanel.addChild(giftCounterCont);
			//giftCounterCont.addEventListener(MouseEvent.CLICK, onMainGifts);

			//giftCounter.text = String(App.user.gifts.length);
			//if (App.user.gifts.length == 0) 
				//giftCounterCont.visible = false;	
			//else 							
				//giftCounterCont.visible = true;	
		}
		
		//private function onMainGifts(e:MouseEvent):void
		//{
			//if (App.user.quests.tutorial)
				//return;
			//
			//if (App.user.gifts.length == 0)
				//new FreeGiftsWindow().show();
			//else		
				//new FreeGiftsWindow( {
					//mode:FreeGiftsWindow.TAKE
				//}).show();
		//}
		
		public static function drawPanelBg(_width:int, textureName:String = 'panelCorner'):Bitmap {
			var bg:Sprite = new Sprite();
			var texture:BitmapData = UserInterface.textures[textureName];
			var leftSide:Bitmap = new Bitmap(texture);
			var rightSide:Bitmap = new Bitmap(texture);
			var midSideBMD:BitmapData = new BitmapData(1, rightSide.height, true, 0);
			midSideBMD.copyPixels(texture, new Rectangle(leftSide.width - 1, 0, 1, leftSide.height), new Point());
			var midSide:Bitmap = new Bitmap(midSideBMD);
			
			var midleWidth:int = _width - leftSide.width * 2;
			
			bg.addChild(leftSide);
			bg.addChild(rightSide);
			bg.addChild(midSide);
			leftSide.x = 0;
			midSide.x = leftSide.x + leftSide.width;
			rightSide.scaleX = -1;
			rightSide.x = midleWidth + leftSide.width + rightSide.width;
			midSide.width = midleWidth;
			
			var resultBMD:BitmapData = new BitmapData(bg.width, bg.height, true, 0);
			resultBMD.draw(bg);
			
			return new Bitmap(resultBMD);
		}
		
		public var bttns:Array = [];
		
		public var icons:Array = [
			{name:'friends', icon:UserInterface.textures.friendsIcon, pos: { /*ix:17, iy:-1,*/ title:Locale.__e('flash:1382952380181'), description:Locale.__e('flash:1396343542646')}, click:onFriendsClick},
			{name:'trade', icon:UserInterface.textures.tradeIcon, pos:{/*ix:10, iy:1,*/ title:Locale.__e('flash:1402386358519'), description:Locale.__e('flash:1396343609431')}, click:onTradeClick},
			{name:'bestFriends', icon:UserInterface.textures.bFFBttnIco, pos:{/*ix:5, iy:4,*/ title:Locale.__e('flash:1406623755604'), description:Locale.__e('flash:1406624169962')}, click:onBestFriendsClick},
			//{name:'map', icon:UserInterface.textures.mapIcon, pos:{/*ix:8, iy:3,*/ title:Locale.__e('flash:1396608235927'), description:Locale.__e('flash:1396343775152')}, click:onTestClick2},
			{name:'collections', icon:UserInterface.textures.collectionsIcon, pos:{/*ix:5, iy:4,*/ title:Locale.__e('flash:1382952379800'), description:Locale.__e('flash:1396343809444')}, click:onCollectionsClick},
			{name:'prix', icon:UserInterface.textures.prixIcon, pos: {/*ix:12, iy:6,*/ title:Locale.__e('flash:1396961879671'), description:Locale.__e('flash:1396343692368') }, click:onPrixClick},
			{name:'magic', icon:UserInterface.textures.magicBttnIco, pos:{/*ix:2, iy:3, */title:App.data.storage[397].title, description:App.data.storage[397].description}, click:onMagicClick}

			];
		
		public function drawIconsPanel():void 
		{
			iconsPanel = new Sprite();
			addChild(iconsPanel);
			
			var _width:int = 0;// = icons.length * 70 + 20;
			
			var X:int = -4;
			var Y:int = -32;
			
			for (var i:int = 0; i < icons.length; i++) 
			{
				var bttnObject:Object = icons[i];
				
				var back:BitmapData = UserInterface.textures.interBoxBttn1;
				var backBack:BitmapData = UserInterface.textures.interBoxBttn1Back;
				var backDecor:BitmapData = UserInterface.textures.woodenDecPiece;
				
				if (bttnObject.name == 'friends') {
					back = UserInterface.textures.interRoundBttn1;
					backBack = UserInterface.textures.interRoundBttn1Back;
				}
					
				var bttnBack:Bitmap = new Bitmap(backBack);
					iconsPanel.addChildAt(bttnBack, 0);
					bttnBack.x = X;
					bttnBack.y = Y;
					
				if (bttnObject.name == 'friends') 
				{
					X += bttnBack.width - 142;
					///*iconsPanel.addChild(bttnBack);
					//mc.parent.addChild(mc)*/
					///*bttnBack.parent.addChild(bttnBack);*/
				}

				
				X += bttnBack.width + 5;
					
				var bttn:ImagesButton = new ImagesButton(back, bttnObject.icon, bttnObject.pos);
					bttn.addEventListener(MouseEvent.CLICK, bttnObject.click);
					bttnObject['bttn'] = bttn;
					iconsPanel.addChild(bttn);

					if (bttnObject.name == 'friends')
					{
						bttn.x = (bttnBack.x + (bttnBack.width - bttn.width)/2) + 4;
						bttn.y = (bttnBack.y + (bttnBack.height - bttn.height)/2) + 14;
						bttns.push(bttn);
					}else 
					{
						bttnBack.y = -15;
						
						bttn.x = bttnBack.x + (bttnBack.width - bttn.width)/2;
						bttn.y = bttnBack.y + (bttnBack.height - bttn.height)/2;
						bttns.push(bttn);
					}
					
					if (bttnObject.name == 'friends') 
					{
						bttn.y -= 20;
					}
					if (bttnObject.name == 'magic') 
					{
						bttn.x += 6;
					}
					
					addTip(bttn);
					
					function addTip(bttn:*):void{
						bttn.tip = function():Object {
							return {
								title:bttn.settings.title,
								text:bttn.settings.description
							}
						}
					}
				
				_width += bttn.bitmap.width;
			}
				
			var roseX:int = X - (bttnBack.width * 2) + 32;
			var roseY:int = 18;
			
			for (var j:int = 0; j < icons.length-2; j++) // тут выбираем количество цветков(в данном случае на 5 иконок 3 цветка)
			{
				var bttnDecor:Bitmap = new Bitmap(backDecor);
				iconsPanel.addChild(bttnDecor);
				bttnDecor.x = roseX;
				bttnDecor.y = roseY;
				roseX -= bttnBack.width + 5;
				
				if (!(j % 2 ==0))
				{
					bttnDecor.scaleX *= -1;
					bttnDecor.x += bttnDecor.width+3;
				}					
			}
			
			_width += 6;
			
			
			/*var bg:Bitmap = drawPanelBg(_width);*/
			var bg:Bitmap = new Bitmap(UserInterface.textures.panelCorner);
			bg.x = (X - bg.width) + 12;
			/*bg.width = icons.length * 70 + 95;*/
			bg.y = 15;
			iconsPanel.addChildAt(bg, 0);
		}
		
		private function onMagicClick(e:MouseEvent):void {
			//var stocks:Array = Map.findUnits([Storehouse.SILO]);
			
			var targets:Array = Map.findUnits([Storehouse.ARCHIVE]);
			if (targets.length > 0) {
				if (targets[0].level ==  targets[0].totalLevels) {
					new StockWindow( {
					title:App.data.storage[Storehouse.ARCHIVE].title,
					mode:StockWindow.ARTIFACTS
					}).show();
				}else {
					App.map.focusedOnCenter(targets[0], true);
				}
			}else {
				new ShopWindow( { find:[Storehouse.ARCHIVE] } ).show();
			}
			
		}
		private function onBestFriendsClick(e:MouseEvent):void {
			new BestFriendsWindow().show();
		}
		
		
		private function onFriendsClick(e:MouseEvent):void {
			if (App.user.quests.tutorial)
				return;
			showFriendsPanel();
			
			for (var s:String in App.data.updatelist[App.social]) {
				var update:Object = {
					nid: s,
					update: App.data.updates[s],
					order: App.data.updatelist[App.social][s]
				}
				break;
			}
			//new NewsWindow({ pID:6 }).show();
			//new EnlargeStorageWindow({ pID:75 }).show();
			//new ThematicalSaleWindow({ pID:1 }).show(); // НЕ ИСПОЛЬЗУЕТСЯ !!! ИСПОЛЬЗУЕМ  BigsaleWindow
			//new BigsaleWindow( { sID:1 } ).show();
			//new PortWindow().show();
			
		}
		
		private function onPrixClick(e:MouseEvent):void {
			if (App.user.quests.tutorial)
				return;
			
			new AchivementsWindow().show();
			App.ui.bottomPanel.bttns[3].hidePointing();
		}
		private function onMapClick(e:MouseEvent):void {
			if (App.user.quests.tutorial)
				return;
			
			App.ui.rightPanel.onMapClick(e);
		}
		private function onCollectionsClick(e:MouseEvent):void {
			
			if (App.user.quests.tutorial)
				return;
			
			new CollectionWindow().show();
		}
		
		private function onTradeClick(e:MouseEvent):void 
		{	
			hidePanels();
			var arr:Array = Map.findUnits([Trade.TRADE_ID]);
			for (var i:int = 0; i < arr.length; i++ ) {
				var trade:Trade = arr[i];
				if (trade.sid == Trade.TRADE_ID && trade.level == trade.totalLevels && trade.hasUpgraded && !trade.hasPresent){
				
				App.map.focusedOn(arr[i]);
				
					new TradeWindow( {
						target:arr[i],
						onSell:arr[i].onSell,
						visMark:arr[i].visMark,
						unVisMark:arr[i].unVisMark
					}).show();
					break;
				}
			}
			
			//new DialogWindow().show();
		}
		
		private function onTestClick2(e:MouseEvent):void {
					
			if (App.user.mode == User.OWNER) {
				new TravelWindow().show();
			}
		}
		
		public function onTakeEvent(bonus:Object):void {
			//App.user.stock.addAll(bonus);
		}
		
		public var friendsPanel:FriendsPanel;
		private function showFriendsPanel():void 
		{
			//removeFriendsInt();
			
			friendsPanel.opened = true;
			friendsPanel.searchFriends();
			friendsPanel.y = App.self.stage.stageHeight + 20;
			friendsPanel.visible = true;
			TweenLite.to(iconsPanel, 0.5, { y:App.self.stage.stageHeight + 30 } );
			TweenLite.to(friendsPanel, 0.5, { y:App.self.stage.stageHeight - 72 } );
			
			tresureCont.visible = false;
		}
		
		public function hideFriendsPanel():void 
		{
			//removeFriendsInt();
			
			friendsPanel.opened = false;
			TweenLite.to(iconsPanel, 0.5, { y:App.self.stage.stageHeight - 52 } );
			TweenLite.to(friendsPanel, 0.5, { y:App.self.stage.stageHeight + 45 } );
			
			tresureCont.visible = true;
		}
			
		
		public var hideFriendsInt:int;
		public function BottomPanel()
		{
			counterTradePanel = new Bitmap(UserInterface.textures.simpleCounterGreen);
			counterAchivePanel = new Bitmap(UserInterface.textures.simpleCounterGreen);
			counterCollPanel = new Bitmap(UserInterface.textures.simpleCounterGreen);
			
			drawMainPanel();
			drawIconsPanel();
			
			friendsPanel = new FriendsPanel(this);
			addChild(friendsPanel);
			friendsPanel.visible = false;
			
			addChild(tresureCont);
			
			var textSettings:Object = {
				color:0xf0e9db,
				borderColor:0x36717d,
				fontSize:16,
				textAlign:"center"
			};
			counterTradePanel.x = -12;
			counterTradePanel.y = -10;
			//trade count
			tradeCounter = Window.drawText(String(25), textSettings);
			tradeCounter.width = 60;
			tradeCounter.height = tradeCounter.textHeight;
			tradeCounter.x = (counterTradePanel.x - counterTradePanel.width / 2) - 1;
			tradeCounter.y = (counterTradePanel.y + counterTradePanel.height/2 - tradeCounter.height / 2) - 1;
			
			tradeCounterCont = new Sprite();
			tradeCounterCont.addChild(counterTradePanel);
			tradeCounterCont.addChild(tradeCounter);
			tradeCounterCont.x = bttns[1].x + 50;
			tradeCounterCont.y = bttns[1].y - 1;
			tradeCounterCont.mouseChildren = tradeCounterCont.mouseEnabled = false;
			
			//achive count
			achiveCounter = Window.drawText(String(25), textSettings);
			achiveCounter.width = 60;
			achiveCounter.height = achiveCounter.textHeight;
			achiveCounter.x = counterAchivePanel.width / 2 - 30;
			achiveCounter.y = counterAchivePanel.height / 2 - achiveCounter.height / 2 - 1;
			
			achiveCounterCont = new Sprite();
			achiveCounterCont.addChild(counterAchivePanel);
			achiveCounterCont.addChild(achiveCounter);
			achiveCounterCont.x = bttns[4].x + 40;
			achiveCounterCont.y = bttns[4].y - 12;
			achiveCounterCont.mouseChildren = achiveCounterCont.mouseEnabled = false;
			
			//collection count
			collCounter = Window.drawText(String(25), textSettings);
			collCounter.width = 60;
			collCounter.height = collCounter.textHeight;
			collCounter.x = counterCollPanel.width / 2 - 30;
			collCounter.y = counterCollPanel.height / 2 - collCounter.height / 2 - 1;
			
			collCounterCont = new Sprite();
			collCounterCont.addChild(counterCollPanel);
			collCounterCont.addChild(collCounter);
			collCounterCont.x = bttns[3].x + 40;
			collCounterCont.y = bttns[3].y - 12;
			collCounterCont.mouseChildren = collCounterCont.mouseEnabled = false;
			
			iconsPanel.addChild(tradeCounterCont);
			iconsPanel.addChild(achiveCounterCont);
			iconsPanel.addChild(collCounterCont);
			
			tradeCounterCont.visible = false;
			updateTradeCounter();
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, updateTradeCounter);
			
			updateAchiveCounter();
			
			showFriendsPanel();
			
			hideFriendsInt = setInterval(changePanel, 3*3600*1000);//*3600);
		}
		
		private function changePanel():void 
		{
			if (App.user.mode == User.GUEST) 
				return;
				
			if (friendsPanel.opened)
				hideFriendsPanel();
			else
				showFriendsPanel();
		}
		
		//public function updateGiftCounter():void
		//{
			//giftCounter.text = String(App.user.gifts.length);
			//if (App.user.gifts.length == 0) 
				//giftCounterCont.visible = false;	
			//else 							
				//giftCounterCont.visible = true;	
		//}
		
		private var arrCollections:Array = [];
		public function updateCollCounter():void 
		{
			var counter:int = 0;
			
			if (arrCollections.length == 0) {
				for (var ind:* in App.data.storage) {
					var item:Object = App.data.storage[ind];
					item['sID'] = ind;
					if (item.type == 'Collection' && item.visible) {
						if (App.user.stock.checkCollection(ind)) {
							counter++;
						}
						arrCollections.push(ind);
					}
				}
			}else {
				for (var i:int = 0; i < arrCollections.length; i++ ) {
					if (App.user.stock.checkCollection(arrCollections[i])) {
						counter++;
					}
				}
			}
			
			if (counter > 0) {
				collCounter.text = String(counter);
				collCounterCont.visible = true;
			}
			else collCounterCont.visible = false;
		}
		
		public function updateAchiveCounter():void
		{
			var counter:int = 0;
			
			for (var ind:* in  App.data.ach) {
				for (var mis:* in  App.data.ach[ind].missions) {
					if (ind != 21 && App.user.ach[ind][mis] < 1000000000 && App.data.ach[ind].missions[mis].need <= App.user.ach[ind][mis]) {
						counter++;
					}
				}
			}
			
			if (counter > 0) {
				achiveCounter.text = String(counter);
				achiveCounterCont.visible = true;
			}
			else achiveCounterCont.visible = false;
		}
		
		public function updateTradeCounter(e:AppEvent = null):void 
		{
			updateCollCounter();
			//updateGiftCounter();
			
			var arrTrades:Array = Map.findUnits([Trade.TRADE_ID]);
			if (arrTrades.length == 0 || arrTrades[0].level < arrTrades[0].totalLevels) {
				tradeCounterCont.visible = false;
				return;
			}
			
			var counter:int = 0;
			for each(var item:* in arrTrades[0].trades) {
				if (App.user.stock.checkAll(item.items) && item.time <= App.time) 
				counter++;
			}
			
			if (counter > 0 && arrTrades.length > 0) {
				tradeCounter.text = String(counter);
				tradeCounterCont.visible = true;
			}
			else tradeCounterCont.visible = false;
		}
		
		
		public function onManageFriends(e:MouseEvent):void {
			if(App.invites.inited){
				new InvitesWindow().show();
			}
		}
			
		private var progressLight:Sprite;
		private var textLable:Sprite;
		
		public function makeCursorsPanel():void {
			
				
			var moveCursor:ImagesButton = new ImagesButton(Window.textures.cursorsPanelItemBg);
			moveCursor.icon = UserInterface.textures.iconCursorMove;
			moveCursor.alpha = 0.85;
			
			var removeCursor:ImagesButton = new ImagesButton(Window.textures.cursorsPanelItemBg);
			removeCursor.icon = UserInterface.textures.iconCursorRemove;
			removeCursor.alpha = 0.85;
			
			var stockCursor:ImagesButton = new ImagesButton(Window.textures.cursorsPanelItemBg);
			stockCursor.icon = UserInterface.textures.iconCursorStock;
			stockCursor.alpha = 0.85;
			
			var rotateCursor:ImagesButton = new ImagesButton(Window.textures.cursorsPanelItemBg);
			rotateCursor.icon = UserInterface.textures.iconCursorRotate;
			rotateCursor.alpha = 0.85;
			
			var bg:Bitmap = Window.backing2(70, 260, 15, "cursorsPanelBg2", "cursorsPanelBg3");

			bg.y = -32;
			bg.alpha = 0.5;
			cursorsPanel = new Sprite();
			cursorsPanel.addChild(bg);
			
			mainPanel.addChild(cursorsPanel);
			cursorsPanel.x = bttnCursors.x - 10;
			cursorsPanel.y = bttnCursors.y - cursorsPanel.height + 28;
			
			cursorsPanel.addChild(stockCursor);
			stockCursor.x = 7;
			stockCursor.y = -26;
			stockCursor.tip =  function():Object { return { title:Locale.__e("flash:1382952379772") }; }
			
			cursorsPanel.addChild(rotateCursor);
			rotateCursor.x = 7;
			rotateCursor.y = 37;
			rotateCursor.tip =  function():Object {return {title:Locale.__e("flash:1382952379773")};}
				
			cursorsPanel.addChild(removeCursor);
			removeCursor.x = 7;
			removeCursor.y = 113 - 13;
			removeCursor.tip =  function():Object {return {title:Locale.__e("flash:1382952379774")};}
			
			cursorsPanel.addChild(moveCursor);
			moveCursor.x = 7;
			moveCursor.y = 180 - 17;
			moveCursor.tip =  function():Object { return { title:Locale.__e("flash:1382952379775") }; }
			
			stockCursor.addEventListener(MouseEvent.CLICK, onStockCursor);
			rotateCursor.addEventListener(MouseEvent.CLICK, onRotateCursor);
			removeCursor.addEventListener(MouseEvent.CLICK, onRemoveCursor);
			moveCursor.addEventListener(MouseEvent.CLICK, onMoveCursor);
			
			cursorsPanel.visible = false;
		}
		
		private function onStopEvent(e:MouseEvent):void {
			App.user.onStopEvent(e);
			if (App.map.moved != null)
				onCursorsEvent(e);
		}
		
		private function onCursorsEvent(e:MouseEvent):void {
			
			if (App.user.quests.tutorial)
				return;
			
			var exit:Boolean = false;
			
			if (App.map.moved != null) {
				App.map.moved.previousPlace();
				Cursor.type = "default";
				//Cursor.init();
				cursorsPanel.visible = false;
				exit = true;
				//return;
			}
			
			if (Cursor.plant) {
				Cursor.plant = false;
				exit = true;
			}
			
			if (ShopWindow.currentBuyObject.type != null) {
				ShopWindow.currentBuyObject.type = null;
				Cursor.type = "default";
				//Cursor.init();
				cursorsPanel.visible = false;
				exit = true;
				//return;	
			}
			
			if (exit) {
				return;
			}
				
			if (Cursor.type != "default") {
				Cursor.type = "default";
				Cursor.toStock = false;
			}else{
				if (cursorsPanel.visible == false && App.user.mode != User.GUEST) {
					cursorsPanel.alpha = 0;
					cursorsPanel.visible = true;
					TweenLite.to(cursorsPanel, 0.2, { alpha:1 } );
					
					App.self.addEventListener(AppEvent.ON_MOUSE_UP, onCursorsPanelHide);
				}else {
					cursorsPanel.visible = false;
				}
			}
		}
		
		private function onCursorsPanelHide(e:AppEvent):void {
			cursorsPanel.visible = false;
		}
		
		private function onStockCursor(e:MouseEvent):void {
			Cursor.type = "stock";
			Cursor.toStock = true;
			cursorsPanel.visible = false;
		}
		
		private function onRotateCursor(e:MouseEvent):void {
			Cursor.type = "rotate";
			cursorsPanel.visible = false;
		}
		
		private function onRemoveCursor(e:MouseEvent):void {
			Cursor.type = "remove";
			cursorsPanel.visible = false;
		}
		
		private function onMoveCursor(e:MouseEvent):void {
			Cursor.type = "move";
			cursorsPanel.visible = false;
		}
		
		
		public function showGuestPanel():void {
			bttnMainShop.visible = false;
			bttnMainStock.visible = false;
			bttnMainHome.visible = true;
			
			showStopBttn();
			
			mainPanel.visible = false;
			
			
			friendsPanel.exit.visible = false;
			
			openArrow.visible = false;
			
			bttnMainHome.hideGlowing();
			
			tresureCont.visible = false;
			
			App.ui.upPanel.show(false);
			//App.ui.rightPanel.mode = User.GUEST;
			App.ui.rightPanel.visible = false;
		}
		
		public function showOwnerPanel():void {
			bttnMainShop.visible = true;
			bttnMainStock.visible = true;
			bttnMainHome.visible = false;
			friendsPanel.exit.visible = true;
			
			showStopBttn(false);
			//tresureCont.visible = true;
			
			mainPanel.visible = true;
			
			openArrow.visible = true;
			
			App.ui.upPanel.hideAvatar();
			
			App.ui.upPanel.show(true);
			//App.ui.rightPanel.mode = User.OWNER;
			App.ui.rightPanel.visible = true;
			hideWorlds();
		}
		
		public var worldsPanel:WorldsPanel
		public function hideWorlds():void 
		{
			if (worldsPanel != null){
				removeChild(worldsPanel);
			}
			worldsPanel = null;
		}
		
		public function showWorlds():void 
		{
			hideWorlds();
			worldsPanel = new WorldsPanel();
			addChild(worldsPanel);
			worldsPanel.y = -35;
			worldsPanel.x = 760;
		}
		
		public function onInviteEvent(e:MouseEvent):void {
			
			ExternalApi.apiInviteEvent();
		}
		
		private function onShopEvent(e:MouseEvent):void {
			if (App.user.quests.tutorial)
				return;
			
			new ShopWindow(Quests.targetSettings).show();
		}
		
		private function onStockEvent(e:MouseEvent):void {
			
			//new InstancePassingWindow( { } ).show();
			//
			//return;
			
			if (App.user.quests.tutorial)
				return;
			
			var stocks:Array = Map.findUnits([Storehouse.SILO]);
			
			new StockWindow( {
				target:stocks[0]
			}).show();
		}
		
		private var isShowMain:Boolean = false;
		private var tweenMain:TweenLite;
		public function showMain(value:Boolean = true):void
		{
			if (value && !mainPanel.visible && !tweenMain) {
				isShowMain = true;
				mainPanel.visible = true;
				mainPanel.y = App.self.stage.stageHeight + 60;
				tweenMain = TweenLite.to(mainPanel, 0.6, { y:App.self.stage.stageHeight - 71, onComplete:function():void { tweenMain = null; }} );
			}else if (!value && iconsPanel.visible && !tweenMain) {
				isShowMain = false;
				mainPanel.y = App.self.stage.stageHeight - 71;
				tweenMain = TweenLite.to(mainPanel, 0.6, { y:App.self.stage.stageHeight +60, onComplete:function():void { tweenMain = null, mainPanel.visible = false;}} );
			}
		}
		
		private var tweenIcons:TweenLite;
		public function showIcons(value:Boolean = true):void
		{
			if (value && !iconsPanel.visible && !tweenIcons) {
				iconsPanel.visible = true;
				iconsPanel.y = App.self.stage.stageHeight - 52 + 100;
				tweenIcons = TweenLite.to(iconsPanel, 0.6, { y:App.self.stage.stageHeight - 52, onComplete:function():void { tweenIcons = null; }} );
			}else if (!value && iconsPanel.visible && !tweenIcons) {
				iconsPanel.y = App.self.stage.stageHeight - 52;
				tweenIcons = TweenLite.to(iconsPanel, 0.6, { y:App.self.stage.stageHeight - 52 + 100, onComplete:function():void { tweenIcons = null, iconsPanel.visible = false;}} );
			}
		}
		
		private var timeToPostShow:int = 500;
		private var postInterval:int;
		private var postPreloader:PostPreloader;
		public function addPostPreloader():void
		{
			clearInterval(postInterval);
			postInterval = setInterval(function():void{
			removePostPreloader();
			postPreloader = new PostPreloader();
			App.self.addChild(postPreloader);
			postPreloader.x = 0;
			postPreloader.y = App.self.stage.stageHeight - postPreloader.height + 8;
			}, timeToPostShow);
		}
		
		public function removePostPreloader(obj:* = null):void
		{
			clearInterval(postInterval);
			if (postPreloader && postPreloader.parent)
				postPreloader.parent.removeChild(postPreloader);
				
			postPreloader = null;
		}
		
		public function hidePanels():void
		{
			trace("прячем панельки");
			hideoutFriendsPanel();
			hideUpPanel();
			
		}
		
		public function showStopBttn(value:Boolean = true):void 
		{
			bttnStopFriends.visible = value;
		}
		
		private function hideUpPanel():void 
		{
			trace("прячем верхнюю панель");
		}
		
		private function hideoutFriendsPanel():void
		{
			trace("прячем панель друзей");
			//friendsPanel.opened = false;
			TweenLite.to(iconsPanel, 0.5, { y:App.self.stage.stageHeight - 52 } );
			TweenLite.to(friendsPanel, 0.5, { y:App.self.stage.stageHeight + 45 } );
			//
			//tresureCont.visible = true;
			//friendsPanel.alpha = 0;
			//iconsPanel.alpha = 0;
		}
	}
}

	


import flash.display.Sprite;
import flash.events.MouseEvent;
import wins.elements.MapIcon;
import wins.SimpleWindow;
internal class WorldsPanel extends Sprite
{
		private var _wIDs:Array = [171,696,442,668,834];
		private var worlds:Array = [];
		public function WorldsPanel():void {
			if (App.owner.id == '1') return;
			var userWorlds:Object = App.user.worlds;
			var ownerWorlds:Object = App.owner.worlds;
			
			for each(var wID:* in ownerWorlds) {
				if (wID == App.owner.worldID) continue;
				if (_wIDs.indexOf(wID) == -1) continue;
				
				worlds.push(wID);
			}
			
			var X:int = 0;
			var Y:int = 0;
			
			for (var i:int = 0; i < worlds.length; i++) {
				var icon:MapIcon = new MapIcon(worlds[i], this);
				icon.x = X;
				icon.y = Y;
				icon.scaleX = icon.scaleY = 0.7;
				if (worlds[i] == 668)
					icon.y -= 5;
					
				X -= 57;
				addChild(icon);
				icon.addEventListener(MouseEvent.CLICK, onClickIcon);
				if (!App.user.worlds.hasOwnProperty(worlds[i]))
					icon.open = false;
				//if (userWorlds[worlds[i]] == null)
				//icon.alpha = 0.5;
			}
		}
		
		public function onClickIcon(e:MouseEvent):void
		{
			if (!e.currentTarget.open)
			{
				new SimpleWindow({
						label:SimpleWindow.ATTENTION,
						text:Locale.__e('flash:1396608344836'),
						popup:true
					}).show();
				return;
			}
			
			//Travel.visitOwnerWorld(e.currentTarget.worldID);
		}
		
		
}
