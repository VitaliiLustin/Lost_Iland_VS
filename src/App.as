package
{
	import api.ExternalApi;
	import api.flashVarsGenerator;
	import api.MailApi;
	import api.VKApi;
	import api.OKApi;
	import api.FBApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import com.google.analytics.API;
	import com.greensock.TweenLite;
	import core.CookieManager;
	import core.Debug;
	import core.Lang;
	import core.Log;
	import core.Log;
	import core.Post;
	import core.SpeedWatchDog;
	import effects.ParticleEffect;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.StageDisplayState;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.AnimalCloud;
	import ui.CloudsMenu;
	import ui.CursorShleif;
	import ui.InstanceCloud;
	import ui.TipsPanel;
	import units.Animal;
	import units.Boss;
	import units.Butterfly;
	import units.Decor;
	import units.Jam;
	import units.Lantern;
	import units.Missionhouse;
	import units.Pigeon;
	import units.ReferalRewardWindow;
	import units.Sphere;
	import units.Techno;
	import units.Walkgolden;
	import units.Whispa;
	import wins._6WBonusWindow;
	import wins.AchivementMsgWindow;
	import wins.BankSaleWindow;
	import wins.BanksWindow;
	import wins.BankWindow;
	import wins.BigsaleWindow;
	import wins.DayliBonusWindow;
	import wins.DialogWindow;
	import wins.DreamsWindow;
	import wins.ErrorWindow;
	import wins.FreeGiftsWindow;
	import wins.InstanceWindow;
	import wins.InvitesWindow;
	import wins.ItemsWindow;
	import wins.LevelUpWindow;
	import wins.NewsWindow;
	import wins.OfferWindow;
	import wins.PresentWindow;
	import wins.RewardWindow;
	import wins.SalesWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import core.IsoConvert;
	import core.Load;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.Security;
	import ui.UserInterface;
	import ui.WishList;
	import ui.Cursor;
	import com.sociodox.theminer.TheMiner;
	import units.Building;
	import units.Unit;
	import ui.Tips;
	import ui.HelpPanel;
	import ui.ContextMenu;
	import flash.text.Font;

	[SWF ( width = "900", height = "700", allowsFullScreen = true, backgroundColor = '#8de8b6') ]//82c1ca
	
	public class App extends Sprite 
	{
		public static var data:Object;
		
		public static var user:User;
		
		public static var owner:Owner;
		public static var map:Map;
		public static var ui:UserInterface;
		public static var wl:WishList = new WishList();
		public static var network:*;
		public static var invites:Invites;
		
		public static var _fontScale:Number = 1;
		
		public static var social:String;
		public static var ref:String = "";
		public static var ref_link:String = "";
		
		public static var blink:String = "";
		public static var oneoff:String = "";
		
		public static var tips:Tips;
		
		public static var time:int = new Date().time / 1000;
		public static var serverTime:int = time;
		public static var midnight:int = 0; 
		public static var nextMidnight:int = 0; 
		
		public var windowContainer:Sprite;
		public var contextContainer:Sprite;
		public var tipsContainer:Sprite;
		public var faderContainer:Sprite = new Sprite();
		
		public var complete:Boolean = false;
		
		public var mapCompleted:Boolean = false;
		public var introCompleted:Boolean = false;
		
		public var deltaX:int 		= 0;
		public var deltaY:int 		= 0;
		public var moveCounter:int 	= 0;
		
		public var flashVars:Object;
		public var frameCallbacks:Vector.<Function> = new Vector.<Function>();
		public var timerCallbacks:Vector.<Function> = new Vector.<Function>();
		
		private var prevTime:Number;
		public var fps:Number;
		
		public var timer:Timer;
		private var _timer:Timer = new Timer(60);
		
		public var preloader:* = null;
		//public var getLoader:Function = null;
		public var changeLoader:Function = null;
		public var hideLoader:Function = null;
				
		public var intro:* = null;
		
		public static var self:App;
		private var old_seconds:uint = 0;
		
		public static var console:Console;
		//public static var lang:String;
		public static var tutorial:Tutorial;
		
		public static var cursorShleif:CursorShleif;
		
		Security.allowDomain("*");
        Security.allowInsecureDomain("*");
		
		[Embed(source="fonts/BRUSH-N.TTF",  fontName = "font",  mimeType = "application/x-font-truetype", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true", embedAsCFF="false")]
		//[Embed(source="fonts/meiryob.ttc",  fontName = "font",  mimeType = "application/x-font-truetype", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true", embedAsCFF="false")]
		private static var font:Class;
		
		public static const VERSION:String = '04.09.2';
		
		public static const ID:* = '159185922';		// 159185922     22606358    100002550903626   5800812  2329711  2322590  9490649  134475609  575960593169  2914315
		public static const SOCIAL:* = 'DM';		// DM, VK, OK, ML, FB, PL
		public static const SERVER:* = 'DM';		// DM, VK, OK, ML, FB, PL
		public static var lang:String = 'ru';		// ru en fr es pl nl jp
		
		public function App():void 
		{
			Font.registerFont(font);
			
			if (self){
				throw new Error("Вы не можете создавать экземпляры класса при помощи конструктора. Для доступа к экземпляру используйте Singleton.instance.")
			}else{
				self = this;
			}
			
			Security.allowDomain("*");
            Security.allowInsecureDomain("*");
			//addChild(new TheMiner());
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Инициализация приложения
		 * @param	e	событие
		 */
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			tips = new Tips();
			
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align 		= StageAlign.TOP_LEFT;
			
			if (stage.loaderInfo.parameters.hasOwnProperty('viewer_id'))
				flashVars = stage.loaderInfo.parameters;
			else if (stage.loaderInfo.parameters.hasOwnProperty('logged_user_id')){
				flashVars = stage.loaderInfo.parameters;
				flashVars['viewer_id'] = flashVars['logged_user_id'];
			}else
				flashVars = flashVarsGenerator.take(App.ID.toString());//(9490649)///(159185922)//174971289//89675457//100004640803161//sb_mbga_jp:132771 // 120635122	//134475609	//22606358		//22606358712619  //22606358712619   //2329711 - andrew  22612   //-235815106			
				
			/*if (flashVars['viewer_id'] == '243667149') {
				flashVars['viewer_id'] = '1';
			}*/
			
			if (flashVars.hasOwnProperty('blink'))
				App.blink = flashVars['blink'];
				
			if (flashVars.hasOwnProperty('oneoff'))
				App.oneoff = flashVars['oneoff'];
				
			this.addEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			this.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			//Грузим окна в кеш
			Console.addLoadProgress('Получаем flashvars')
			for (var param:* in flashVars) {
				Console.addLoadProgress(param + ":		" + flashVars[param]);
			}
			
			if (flashVars.hasOwnProperty('secure'))
				Config.setSecure(flashVars.secure+"//");
			
			if (flashVars.hasOwnProperty('ref'))
				App.ref = flashVars.ref;
			
			if (flashVars.hasOwnProperty('testMode'))
			{
				Config.testMode = flashVars.testMode;
				Config.resServer = flashVars['viewer_id'] % 2;
			}
			
			Config.setServersIP(stage.loaderInfo.parameters);
			Log.alert('Узнали IP');
			Log.alert(flashVars);
			//Асинхронно грузим данные об игре и информацию о пользователе
			//Загрузка данных игры
			
			if (flashVars.hasOwnProperty('font')) {
				Load.loading(flashVars.font, function(data:*):void {
					Font.registerFont(data.fontArial);
				});
			}
			
			windowContainer = new Sprite();
			contextContainer = new Sprite();
			tipsContainer = new Sprite();
			
			addChild(contextContainer);
			addChild(windowContainer);
			addChild(tipsContainer);
			addChild(faderContainer);
			
			lang = 'ru';// ru en fr es pl nl jp			
			if (flashVars.hasOwnProperty('lang'))
				lang = flashVars.lang;
				
			Lang.loadLanguage(lang, function():void {
				Load.loadText(Config.getData(lang), onGameLoad);
			});
			
			console = new Console();
			Tutorial.init();
			
			cursorShleif = new CursorShleif();
		}
				
		private function translateGameData(data:*):void {
			for (var id:* in data) {
				var val:* = data[id];
				if (typeof val == 'object') {
					translateGameData(val);
				}else if(typeof val == 'string'){
					if (val.indexOf(':') != -1) {
						data[id] = Locale.__e(val);
					}
				}
			}
		}
		
		/**
		 * Событие завершения загрузки данных об игре
		 * @param	data	данные игры
		 */
		private function onGameLoad(_data:Object):void {
			
			Console.addLoadProgress('storage загружен');
			data = JSON.parse(_data.data);
			
			translateGameData(data);
			
			//Tutorial.init();
			//Формируем коллекции
			for(var sID:* in data.storage){
				var item:Object = data.storage[sID];
				if(item.type == 'Collection'){
					item['materials'] = [];	
					for(var mID:* in data.storage){
						var material:Object = data.storage[mID];
						if (material.collection == sID) {
							item.materials.push(mID);
						}
					}
				}
			}
			//Деньги берем конкретно для сети
			data.money = data.money[flashVars['social']];
			
			social = flashVars['social'];
			
			if (social == 'YB') 
			{
				_fontScale = 0.7;
				tips.init();
			}
			
			//Проверяем акции
			checkPromo();
			
			//Включаем таймер
			timer = new Timer(1000);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			
			Console.addLoadProgress('соц. сеть: ' + flashVars.social);
			Log.alert('соц. сеть: ' + flashVars.social);
			if (flashVars['social']) {
				connectToNetwork(flashVars.social);
			}
			checkUpdates();
		}
		
		private function connectToNetwork(type:String):void 
		{
			switch(type) 
			{
				case 'YB':
					if (ExternalInterface.available){	
						
						ExternalInterface.addCallback('openPayments', Payments.getHistory);
						
						ExternalInterface.addCallback("openBank", function():void {
							new BanksWindow().show();
						});
						ExternalInterface.addCallback("openGifts", function():void {
							new FreeGiftsWindow().show();
						});
					}
				case 'PL':
					if (ExternalInterface.available){
						ExternalInterface.addCallback("initNetwork", onNetworkComplete);
						ExternalInterface.call("initNetwork");
					}else {
						onNetworkComplete({
							profile:flashVars.profile,
							appFriends:flashVars.appFriends,
							wallServer:flashVars.wallServer,
							otherFriends:flashVars.otherFriends
						});
					}
					break
				case 'VK':
				case 'DM':
					if (ExternalInterface.available)
					{
						ExternalInterface.addCallback("openBank", function():void {
							new BanksWindow().show();
						});
						ExternalInterface.addCallback("openGifts", function():void {
							new FreeGiftsWindow().show();
						});
						
						ExternalInterface.addCallback("initNetwork", //onNetworkComplete);
						
							function(data:Object):void
							{
								new VKApi(App.self.flashVars, data, onNetworkComplete);
							}	
						);
							
						ExternalInterface.call("initNetwork");
					}else {
						
						onNetworkComplete({
							profile:flashVars.profile,
							appFriends:flashVars.appFriends,
							wallServer:flashVars.wallServer,
							otherFriends:flashVars.otherFriends,
							leads:[18]
						});
					}
				break;
				case 'OK': 
					Console.addLoadProgress('OK: logged_user_id = ' + flashVars['logged_user_id']);
					if (flashVars['logged_user_id'] != undefined) {
						network = new OKApi(flashVars);
						if (ExternalInterface.available) {	
							ExternalInterface.addCallback("openBank", function():void {
								new BanksWindow().show();
							});
							ExternalInterface.addCallback("openGifts", function():void {
								new FreeGiftsWindow().show();
							});
							ExternalInterface.addCallback("showInviteBox", function():void {
								network.showInviteBox();
							});
						}
						
					}else {
						onNetworkComplete( {
							profile:flashVars.profile,
							appFriends:flashVars.appFriends,
							wallServer:flashVars.wallServer,
							otherFriends:flashVars.allFriends
						});
					}
				break;
				case 'ML': 
					network = new MailApi(flashVars);
					if (ExternalInterface.available) {	
						ExternalInterface.addCallback("openBank", function():void {
							new BanksWindow().show();
						});
						ExternalInterface.addCallback("openGifts", function():void {
							new FreeGiftsWindow().show();
						});
						ExternalInterface.addCallback("showInviteBox", function():void {
							ExternalApi.apiInviteEvent();
						});
					}
				break;
			case 'FB': 
				if (ExternalInterface.available) {	
					ExternalInterface.addCallback("updateBalance", function():void {
						ExternalApi.tries = 0;
						ExternalApi.updateBalance(true);
					});
						
					ExternalInterface.addCallback("openBank", function():void {
						new BanksWindow().show();
					});
					ExternalInterface.addCallback("openGifts", function():void {
						new FreeGiftsWindow().show();
					});
					ExternalInterface.addCallback("openInbox", function():void {
						new FreeGiftsWindow( {
							mode:FreeGiftsWindow.TAKE
						}).show();
					});
				}
				
				network = new FBApi(flashVars);
				
				if (!ExternalInterface.available){	
					App.network['currency'] = {
						'usd_exchange_inverse': 1,
						'user_currency': 'RUR'
					}
				}	
				
				break;
			}
		}
		
		public function onNetworkComplete(data:Object):void 
		{
			Log.alert("onNetworkComplete:  " + data);
			
			network = data;
			Console.addLoadProgress('onNetworkComplete');
			removeEventListener(AppEvent.ON_NETWORK_COMPLETE, onNetworkComplete);
			Console.addLoadProgress("1");
			
			if (App.data.banlist != null && App.data.banlist[flashVars['viewer_id']] != undefined && App.data.banlist[flashVars['viewer_id']].inban) {
				var ban:Object = App.data.banlist[flashVars['viewer_id']];
				Load.loading(Config.getInterface('windows'), function(data:*):void { 
					Window.textures = data;
					new SimpleWindow( {
						'label':SimpleWindow.ATTENTION,
						'text': Locale.__e('flash:1382952379712', [ban.message])
					}).show();
					
					if(hideLoader != null) hideLoader();
				});
				return;
			}
			
			Console.addLoadProgress("2");
			//Загрузка пользователя
			Console.addLoadProgress('Загрузка пользователя');
			addEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
			user = new User(flashVars['viewer_id']);
			
			//addEventListener(AppEvent.ON_START_TUTORIAL, loadIntro);
		}
		
		private function onMapComplete(e:AppEvent):void {
			this.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			//Вызываем событие окончания загрузки игры, можно раставлять теперь объекты на карте
			Console.addLoadProgress('onMapComplete');
			mapCompleted = true;
			
			checkGameStart();
				
			if(!App.user.quests.tutorial){
				showOffers();
			}else {
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, showOffers);
			}
			
			if (!App.user.quests.isTutorial && App.data.hasOwnProperty('blinks') && App.data.blinks.hasOwnProperty(App.blink)) {
				var bbonus:Object = App.data.blinks[App.blink];
				if (bbonus.start < App.time && bbonus.start + bbonus.duration * 3600 > App.time && !App.user.blinks.hasOwnProperty(App.blink)) {
					new ReferalRewardWindow().show();
				}
			}
			
			if (!App.user.quests.isTutorial && App.oneoff.length > 0)
				user.takeBonus();
			
			//if (App.data.gifts) {
				//Load.loading(Config.getImage('promo/images', 'present'), function(data:*):void {
					//for (var id:String in App.data.gifts) {
						//var gift:Object = App.data.gifts[id];
						//if (App.user.presents && App.user.presents[id] == undefined) {
							//if(gift.duration == 0 || (gift.duration > 0 && gift.time + gift.duration*3600 > App.time )){
								//new PresentWindow( { gift:id } ).show();
							//}
						//}
					//}
				//});
			//}
			
			for each(var item:* in App.user._6wbonus) {
				var bonus:Object = App.data.bonus[item['campaign']] || null;
				if (bonus) {
					new _6WBonusWindow( { bonus:bonus } ).show();
					//if (App.social == 'FB')
						//ExternalApi._6epush([ "_event", { event: "gain", item: "edm_bonus" } ]);
				}
			}
			
			if(App.user.trialpay != null){
				for each(var trialpay:Object in App.user.trialpay){
					Load.loading(Config.getImage('promo/images', 'crystals'), function(data:*):void {
						new SimpleWindow( {
							'label':SimpleWindow.CRYSTALS,
							'title': Locale.__e('flash:1382952379735'),
							'text': Locale.__e('flash:1384418596313', [int(trialpay[3])])
						}).show();
					});
				}
			}
			
			//App.user.addCharacter({sid:206, x:20, z:20});
		}
		
		private function showOffers(e:AppEvent = null):void {	
			showOfferWindow();
			showBigSaleWindow();
			//showDealSpot();
		}
		
		private function showDealSpot():void 
		{
			if(App.social == 'FB' && ExternalInterface.available){
				ExternalInterface.addCallback('setDealSpot', function(url:String):void {
					
					Load.loading(url, function(data:*):void {
						App.ui.leftPanel.createDealSpot(data);
					});
				});
				ExternalInterface.call('getDealSpot');
			}
		}
		
		private function showBigSaleWindow():void {
			var sales:Array = [];
			var sale:Object;
			for (var sID:* in App.data.bigsale) {
				sale = App.data.bigsale[sID];
				if(sale.social == App.social)
					sales.push({sID:sID, order:sale.order, sale:sale});
			}
			sales.sortOn('order');
			for each(sale in sales) {
				if (App.time > sale.sale.time && App.time < sale.sale.time + sale.sale.duration * 3600) {
					BigsaleWindow.startAction(sale.sID, sale.sale);
					break;
				}
			}
		}
		
		private function showOfferWindow():void 
		{
			App.self.removeEventListener(AppEvent.ON_FINISH_TUTORIAL, showOfferWindow);
			if ((App.data.money != null && App.data.money.enabled && App.data.money.date_to > App.time) || (App.user.money > App.time))
			{
				if (App.user.quests.isTutorial)
					return;
					
				//Load.loading(Config.getImageIcon('promo/bg', 'star2'), function(data:*):void {
					new BankSaleWindow().show();
					App.ui.salesPanel.addBankSaleIcon(UserInterface.textures.saleBacking2);
					//new OfferWindow().show();
					//App.ui.upPanel.showMoneyLabels();
				//});
			}
		}
		
		private function initMap():void	{
			//App.ui.visible = false;
			map.visible = true;
			
			user.addPersonag();
			map.center();
			//if (App.user.quests.data[90] && App.user.quests.data[90].finished == 0) {
				
				//App.ui.hideAll();
				/*map.x = -2000//-5000 * 0.5;
				map.y = -900* 0.5;
				map.scaleX = map.scaleY = 0.5;
				setTimeout(function():void {
					map.visible = true;
					setTimeout(function():void {
						App.map.focusedOn(App.user.hero, false, function():void {
							new DialogWindow( { qID:90, mID:1 } ).show();
							App.ui.visible = true;
							//	App.ui.showAll();
						}, true, 1, true, 20);
					}, 2000);
				}, 5000);*/
				
				//map.scaleX = map.scaleY = 0.3;
				//map.center();
				//new DialogWindow( { qID:90, mID:1 } ).show();
				//setTimeout(function():void {
					//App.map.focusedOn(App.user.hero, false, function():void {
						//
					//}, true, 1, true, 20);
				//}, 1000);
			//App.map.focusedOn(App.user.hero, false, function():void {
						//new DialogWindow( { qID:90, mID:1 } ).show();
						//App.ui.visible = true;
						//	App.ui.showAll();
					//}, true, 1, true, 20);
			//}else {
				//map.center();
			//}
			
			dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			
			//if ((App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1) || App.data.money.level == user.level) {
				//new BankSaleWindow().show();
			//}
			
			//Lantern.init();
			
			if(App.user.mode == User.OWNER && App.user.level >= 20){
				var bossInitLotteryNumber:int;
				var bossInitCounter:int;
				bossInitLotteryNumber = Math.round(Math.random() * 10);
				if (bossInitLotteryNumber <= 3 && bossInitCounter < 1) {
					Boss.init();
					bossInitCounter++;
				}
			}
			SoundsManager.instance.loadSounds();
			
			if (!App.user.quests.tutorial) {
				
				if(App.user.bonus == 0 && App.user.level > 3) 
					new DayliBonusWindow().show();
				
				Pigeon.checkNews();	
			}
			
			
			//if (App.user.worldID == User.HOME_WORLD && !App.user.quests.tutorial) {
				//Pigeon.checkNews();	
			//}
			
			App.user.quests.checkFreebie();
			
		}
		
		private function checkGameStart():void
		{
			initMap();
			user.quests.openMessages();
			user.quests.continueTutorial();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			if (hideLoader != null) {
				hideLoader();
				Log.alert('hideLoader')
			}
		}
		
		private function onGameComplete(e:AppEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			stage.addEventListener(Event.MOUSE_LEAVE, mouseLeave);
			stage.addEventListener(Event.FULLSCREEN, onFullscreen);
			stage.addEventListener(MouseEvent.MOUSE_OUT, onOutStage);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			this.removeEventListener(AppEvent.ON_GAME_COMPLETE, onGameLoad);
			
			user.friends.showHelpedFriends();
			
			//App.user.stock.checkSystem();
			//App.self.setOnTimer(App.user.stock.checkEnergy);
			
			checkNews();
			App.user.checkBFF();
			/*new NewsWindow( {
				news:App.data.updates['5257d9bacf2ee']
			}).show();*/
			
			//App.data;
			//showBulks();
		}
		
		private function showBulks():void {
			for (var bulkID:* in data.bulks) {
				var bulk:Object = data.bulks[bulkID];
				if (bulk.social.hasOwnProperty(App.social)) {
					new SalesWindow( {
						action:bulk,
						pID:bulkID,
						mode:SalesWindow.BULKS,
						width:670,
						title:Locale.__e('flash:1385132402486')
					}).show();
					return;
				}
			}
		}
		
		private function onSpeedHack(e:Event):void
		{
		   new SimpleWindow( {
					label:SimpleWindow.ERROR,
					text:Locale.__e("flash:1382952379713")
				}).show();
			App.user.onStopEvent();	
		}
		
		private function mouseLeave(e:Event):void
		{
			cursorOut = true;
			moveCounter = 0;
		}
		
		private function onMouseWheel(e:MouseEvent):void {
			if (App.ui && App.ui.systemPanel && !App.user.quests.tutorial)
				App.ui.systemPanel.onMouseWheel(e);
				
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_WHEEL_MOVE));
		}
		
		private function onFullscreen(e:Event):void {
			setTimeout(function():void { mouseLeave(e) }, 10);
			ExternalApi.gotoScreen();
		}
		
		private function onOutStage(e:MouseEvent):void {
			if (!(e.stageX > 0 && e.stageX < stage.stageWidth && e.stageY > 0 && e.stageY < stage.stageHeight)) {
				mouseLeave(e);
			}
		}
		
		/**
		 * Событие завершения загрузки данных пользователя
		 * @param	e	объект события
		 */
		private function onUserComplete(e:AppEvent):void
		{
			Console.addLoadProgress('onUserComplete');
			
			removeEventListener(AppEvent.ON_USER_COMPLETE, onUserComplete);
				
			/*if (user.quests.isTutorial) {
				User.checkBoxState = CheckboxButton.UNCHECKED;
				if(App.self.changeLoader != null) App.self.changeLoader("hasIntro", 0);	
			}*/
			
			this.addEventListener(AppEvent.ON_UI_LOAD, onUILoad);
				
			Console.addLoadProgress('load Windows');
			Load.loading(Config.getInterface('windows'), function(data:*):void {
				Console.addLoadProgress('onWindowsComplete');
				Window.textures = data;
				ExternalApi.setCloseApiWindowCallback();
				
				Console.addLoadProgress('load UI');
				ui = new UserInterface();
				
				if(App.social == 'YB'){
					invites = new Invites();
					invites.init(null);
					Payments.getHistory(false);
				}
				addChildAt(ui, getChildIndex(windowContainer) - 1 );
				
				/*var shopBttn:Button = new Button( {
					caption:'Магазин',
					width:125,
					height:50
				});
				
				shopBttn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					new ShopWindow( { } ).show();
				});
				addChild(shopBttn);
				shopBttn.x = 10;
				shopBttn.y = 10;*/
				
				if (intro != null && contains(intro)){
					setChildIndex(intro, App.self.numChildren-1);
				}
				
			},  0, false, 
			function(progress:Number):void{
				if(changeLoader != null) changeLoader('wins', progress);
			});
			
			/*if (App.social == 'FB') {
				ExternalApi.showTrialpay();
			}*/
		}
		
		/**
		 * Событие завершения загрузки интерфейса
		 * @param	e	объект события
		 */
		private function onUILoad(e:AppEvent):void
		{
			Console.addLoadProgress('onLoad UI');
			this.removeEventListener(AppEvent.ON_UI_LOAD, onUILoad);
			
			//Загрузка карты
			map = new Map(user.worldID, user.units);
			map.visible = false;
			drawBackground();
			//App.ui.visible = false;
		}
		
		/**
		 * Добавление функции обратного вызова на событие EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public function setOnEnterFrame(callback:Function):void {
			addEventListener(Event.ENTER_FRAME, callback);
		}
		
		/**
		 * Удаление функции обратного вызова с события EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public function setOffEnterFrame(callback:Function):void {
			removeEventListener(Event.ENTER_FRAME, callback);
		}
		
		/**
		 * Событие EnterFrame
		 * @param	e	объект события
		 */
		private function onEnterFrame(e:Event):void {
			getFps(e);
		}
		
		public function setOnTimer(callback:Function):void {
			timerCallbacks.push(callback);
		}

		public function setOffTimer(callback:Function):void {
			var index:int = timerCallbacks.indexOf(callback);
			
			if(index != -1){
				timerCallbacks[index] = null;
			}
		}
		
		private function onTimerEvent(e:TimerEvent):void {
			time += 1;
			
			for (var i:int = 0; i < timerCallbacks.length; i++ ) {
				if(timerCallbacks[i] != null){
					timerCallbacks[i].call();
				}
			}
			for (i = 0; i < timerCallbacks.length; i++ ) {
				if(timerCallbacks[i] == null){
					delete timerCallbacks[i];
				}
			}
		}
		
		/**
		 * Событие перемещения мыши
		 * @param	e	объект события
		 */
		//public var isMapMove:Boolean = false;
		public var cursorOut:Boolean = false;
		private function onMouseMove(e:MouseEvent):void 
		{
			if (ItemsWindow.isOpen)
				return;
			
			moveCounter++;
			if (e.buttonDown == true && moveCounter>2 && !Window.isOpen && !cursorOut && !Animal.isMove && !Walkgolden.isMove && !Techno.isMove) {
				if (App.user.quests.track && !(map.moved != null && map.moved is Sphere) || Missionhouse.windowOpened) {
					
					moveCounter = 0;
					return;
				}
				var dx:int = e.stageX - deltaX;
				var dy:int = e.stageY - deltaY;
				
				deltaX = e.stageX;
				deltaY = e.stageY;
				
				map.redraw(dx, dy);
				tips.relocate();
				HelpPanel.hideAll();
				
			}else{
				var target:* = e.target;
				var _target:* = e.target;
				UserInterface.over = false; 
				//trace(target);
				if (!(target is Unit || target is Map)) 
				{
					while (target.parent != null) {
						if (target.parent is UserInterface || target is HelpPanel || target.parent is HelpPanel || target.parent is ContextMenu || target.parent is CloudsMenu || target.parent is AnimalCloud){
							UserInterface.over = true;
							map.untouches();
							break;
						}
						target = target.parent;
					}
				}
				
				var point:Object = IsoConvert.screenToIso(map.mouseX, map.mouseY, true);
				
				Map.X = point.x>0?point.x:0;
				Map.Z = point.z>0?point.z:0;
				Map.X = Map.X < Map.cells?Map.X:Map.cells - 1;
				Map.Z = Map.Z < Map.rows?Map.Z:Map.rows - 1;
							
				target = e.target;
				
				if(App.map._aStarNodes){
					if (App.map._aStarNodes[Map.X][Map.Z].z != 0 && App.map._aStarNodes[Map.X][Map.Z].open == false)
					{
						Cursor.type = 'locked';	
						if (Window.isOpen || UserInterface.over) 
						{
							//Cursor.type = 'default';
							Cursor.init();
						}
						//return;
					}
					else if (Cursor.type == 'locked')
					{
						Cursor.init();
					}
				}
				
				if(!UserInterface.over && !Window.isOpen){
					map.touches(e);
					if (map.touched && map.touched.length > 0) {
						target = map.touched[0];
					}
				}
				if (!map.moved) {
					if (UserInterface.over || Window.isOpen || Missionhouse.windowOpened) {
						tips.show(_target as DisplayObject);
					}else if (target is Unit && target.touch ) {
						tips.show(target as DisplayObject);
					}else {
						tips.hide();
					}
				}else {
					tips.hide();
				}
			}
		}
		
		/**
		 * Событие нажатия кнопки мыши	
		 * @param	e	объект события
		 */
		private function onMouseDown(e:MouseEvent):void {
			moveCounter = 0;
			
			cursorOut = false;
			deltaX = e.stageX;
			deltaY = e.stageY;
			
			
			dispatchEvent(new AppEvent(AppEvent.ON_MOUSE_DOWN));
			
			for (var i:int = 0; i < map.touched.length; i++ ) {
				if (map.touched[i] is Unit/* || map.touched[i] is Techno*/) {
					map.touched[i].onDown();
					break;
				}
			}
		}
		
		/**
		 * Событие отпускания кнопки мыши
		 * @param	e	объект события
		 */
		private function onMouseUp(e:MouseEvent):void {
			
			cursorOut = false;
			//isMapMove = false;
			
			if (UserInterface.over) {
				//UserInterface.over = false;
				return;
			}
			
			if (Window.isOpen || ItemsWindow.isOpen/* || Cursor.type == 'locked'*/) return;
			
			if (moveCounter < 4) {
				if (map.moved != null) {
					if (!map.moved.canInstall()){
						return;
					}
					
					map.moved.move = false;
					
					if (!map.moved.formed && map.moved.multiple == true && Unit.lastUnit != null) {
						if (App.data.storage[Unit.lastUnit.sid].type == 'Decor') 
						{
							Cursor.loading = true;
							setTimeout(function():void {
								Cursor.loading = false;
								Unit.addMore();
							}, 1000)
						}
						else
						{
							Unit.addMore();
						}
					}else {
						map.moved = null;
					}
					
				}else if (map.touched.length > 0) {
					map.touch();
				}else {
					map.click();
				}
			}
			else
			{
				SoundsManager.instance.soundReplace();
			}
			
			dispatchEvent(new AppEvent(AppEvent.ON_MOUSE_UP));
		}
		
		/**
		 * Событие нажатия кнопки клавиатуры
		 * @param	e	объект события
		 */
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.charCode == 93)
			{
				if(e.ctrlKey){
					App.console.open();
				}
			}
			
			if (e.charCode == 100)
				if(e.ctrlKey)
					App.console.openDebug();
					
					
			if (e.charCode == 27 && App.tutorial)
				App.tutorial.resetStep();
				
			if (e.keyCode == Keyboard.I && e.ctrlKey) {
				new SimpleWindow({
					title:			"System",
					text: 			App.VERSION
				}).show();
			}	
		}
		
		/**
		 * Событие изменения размеров приложения
		 * @param	e	объект события
		 */
		private function onResize(e:Event):void {
			App.ui.resize();
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			if (tutorial != null)
				tutorial.resize();
		}
		
		private function getFps(e:Event):void
        {
			fps = Math.round(1000 / (getTimer() - prevTime));
			fps = fps > 31?31:fps;
			
            prevTime = getTimer();
        }
		
		private function checkPromo():void {
			for (var promoID:* in App.data.promo) {
				var promo:Object = App.data.promo[promoID];
				// Удаляем всех не из этой сети
				if (!promo.hasOwnProperty('price') || !promo.price.hasOwnProperty(App.social)) {
					delete App.data.promo[promoID];
				}
			}
		}
		
		private function checkUpdates():void {
			for (var updateID:* in App.data.updates) {
				var update:Object = App.data.updates[updateID];
				if (!update.hasOwnProperty('social') || !update.social.hasOwnProperty(App.social)) {
					for (var sID:* in App.data.updates[updateID].items) {
						if ((update.ext != null && update.ext.hasOwnProperty(App.social)) && (update.stay != null && update.stay[sID] != null))
						{
							
						}
						else
						{
							if(App.data.storage[sID] != null)
								App.data.storage[sID].visible = 0;
						}
					}
				}		
			}	
		}
		
		public function userNameSettings(textSettings:Object):Object {
			if (App.self.flashVars['font']){
				textSettings['fontFamily'] = 'fontArial';
				textSettings['fontSize'] = 14;
			}
			return textSettings;
		}
		
		public var background:Shape;
		public function drawBackground(colors:Array = null):void {
			if (background != null)
				App.self.removeChild(background);
				
				if (colors == null)
					colors = [0xb8dce2, 0x53a3af];
				
                var alphas:Array = [1, 1];
                var ratios:Array = [0, 0xFF];
                var matrix:Matrix = new Matrix();
                matrix.createGradientBox(stage.stageWidth, stage.stageHeight, (3 * Math.PI / 2), 0, 10);
                var focalPoint:Number = .5;
				
				background = new Shape();
				background.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, SpreadMethod.PAD, InterpolationMethod.RGB, focalPoint);
				background.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight); 
				background.graphics.endFill();
				App.self.addChildAt(background, 0);
				background.width = stage.stageWidth;
				background.height = stage.stageHeight;
    
				
			//background = new Shape();
			//background.graphics.beginFill(color);
			//background.graphics.drawRect(0, 0, 100, 100);
			//background.graphics.endFill();
			//App.self.addChildAt(background, 0);
			//background.width = stage.stageWidth;
			//background.height = stage.stageHeight;
		}
		
		public function checkNews():void {
			
			if (App.user.quests.tutorial)
				return;
			setTimeout(function():void 
			{
				for (var newsID:* in data.news) {
					var news:Object = data.news[newsID];
					if (news.social != App.social) continue;
					if (App.time > news.time + news.duration * 3600) continue;
					
					if (ExternalInterface.available) {
						var cookieName:String = "news_" + newsID;
						var value:String = CookieManager.read(cookieName);
						if (value != "1") {
							
						}else{
							continue;
						}
					}
					
					App.ui.showNews(news, cookieName);
				}
			}, 5000);
			
		}
		
		public static function isSocial(... params):Boolean {
			for (var i:int = 0; i < params.length; i++) {
				if (params[i] == App.social)
					return true;
			}
			
			return false;
		}
	}
}
