package ui 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.SimpleButton;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Sine;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.AvaLoad;
	import core.Load;
	import core.Log;
	import core.TimeConverter;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.StageDisplayState;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import units.Factory;
	import units.Personage;
	import units.Techno;
	import wins.BankSaleWindow;
	import wins.BanksWindow;
	import wins.elements.BankMenu;
	import wins.elements.PersonageIcon;
	import wins.elements.ShopMenu;
	import wins.elements.TresureIcon;
	import wins.ErrorWindow;
	import wins.PersonageInfoWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import silin.utils.Color;
	import units.Bear;
	import wins.BankWindow;
	import wins.JamWindow;
	import wins.PurchaseWindow;
	import wins.Window;

	public class UpPanel extends Sprite
	{
		public var avatarPanel:Sprite;
		
		public var coinsPlusBttn:ImageButton;
		public var fantsPlusBttn:ImageButton;
		public var energyPlusBttn:ImageButton;
		public var robotPlusBttn:ImageButton;
		
		public var coinsBar:Bitmap;
		//public var fantsBar:Bitmap;
		//public var bearBar:ImageButton;
		public var robotBar:ImageButton;
		/*public var energyBar:Bitmap;*/
		public var expBar:Bitmap;
		public var expIcon:Bitmap;
		public var capasityBar:Bitmap;
		
		public var coinsSprite:LayerX = new LayerX();
		public var fantSprite:LayerX = new LayerX();
		//public var bearSprite:LayerX = new LayerX();
		public var robotSprite:LayerX = new LayerX();
		public var energySprite:LayerX = new LayerX();
		public var expSprite:LayerX = new LayerX();
		public var capasitySprite:LayerX = new LayerX();
		public var iconsSprite:LayerX = new LayerX();
		
		public var coinsIcon:Bitmap;
		public var fantsIcon:Bitmap;
		//public var bearIcon:Bitmap;
		public var robotIcon:Bitmap;
		public var energyIcon:Bitmap;
		public var capasityIcon:Bitmap;
		
		public var bearPanel:BearsPanel;
		
		private var coinsCounter:TextField;
		private var fantsCounter:TextField;
		//private var bearCounter:TextField;
		private var robotCounter:TextField;
		private var energyCounter:TextField;
		private var expCounter:TextField;
		private var levelCounter:TextField;
		private var capasityCounter:TextField;

		private const enerySliderWidth:int = 81;
		private const expSliderWidth:int = 148;
		
		private var energySlider:Sprite = new Sprite();
		private var expSlider:Sprite = new Sprite();
		private var capasitySlider:Sprite = new Sprite();
		
		//
		public var leftCont:Sprite = new Sprite();
		public var rightCont:Sprite = new Sprite();
		//
		
		private var help:LayerX;
		private var timer:Timer = new Timer(2000, 1);
		
		private var glowBg:Bitmap;
		
		public var personageIcons:Array = [];
		public var tresureIcons:Array = [];
		
		public function hide():void {
			leftCont.visible = false;
			iconsSprite.visible = false;
			rightCont.visible = false;
			this.y = -200;
		}
		public function show2(tween:Boolean = true):void {
			if (tween) {
				TweenLite.to(this, 0.5, { y:0 } );
			}
		}
		
		public function UpPanel() 
		{
			coinsIcon	= new Bitmap(UserInterface.textures.coinsIcon);
			fantsIcon	= new Bitmap(UserInterface.textures.fantsIcon);
			//bearIcon	= new Bitmap(UserInterface.textures.bearIcon);
			robotIcon	= new Bitmap(UserInterface.textures.robotIcon);
			energyIcon	= new Bitmap(UserInterface.textures.energyIcon);
			capasityIcon= new Bitmap(UserInterface.textures.stockIcon);
			
			bearPanel 	= new BearsPanel();
			
			coinsBar	= new Bitmap(UserInterface.textures.coinsBar);
			//fantsBar 	= new Bitmap(UserInterface.textures.fantsBar);
			//bearBar 	= new ImageButton(UserInterface.textures.bearBar);
			robotBar 	= new ImageButton(UserInterface.textures.robotBar);
			//energyBar 	= new Bitmap(UserInterface.textures.energyBar);
			expBar 		= new Bitmap(UserInterface.textures.expBar);
			expIcon 	= new Bitmap(UserInterface.textures.expIcon);
			capasityBar = new Bitmap(Window.textures.prograssBarBacking);
			
			coinsPlusBttn 	= new ImageButton(UserInterface.textures.coinsPlusBttn);
			coinsPlusBttn.name = "coins";
			fantsPlusBttn 	= new ImageButton(UserInterface.textures.fantsPlusBttn);
			fantsPlusBttn.name = "fants";
			
			energyPlusBttn 	= new ImageButton(UserInterface.textures.energyPlusBttn);
			
			robotPlusBttn 	= new ImageButton(UserInterface.textures.robotPlusBttn);
			
			
			coinsPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1382952379813") }; }
			fantsPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1382952379814") }; }
			energyPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1382952379817") }; }
			robotPlusBttn.tip =  function():Object { return { title:Locale.__e("flash:1396336797272") }; }
			
			coinsPlusBttn.addEventListener(MouseEvent.CLICK, onCoinsEvent);//onBankEevent);
			fantsPlusBttn.addEventListener(MouseEvent.CLICK, onRealEvent);//onBankEevent);
			energyPlusBttn.addEventListener(MouseEvent.CLICK, onEnergyEvent);
			robotPlusBttn.addEventListener(MouseEvent.CLICK, onRobotEvent);
			
			//glowBg = new Bitmap(UserInterface.textures.glowBg);
			//addChild(glowBg);
			//glowBg.height = 50;
			//glowBg.y = -20;
			var textSettings:Object;
			
			textSettings = {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:32,
				textAlign:"center"
			};
			
			capasityCounter = Window.drawText(Stock.value +'/'+ Stock.limit, textSettings); 
			capasityCounter.width = 120;
			capasityCounter.height = capasityCounter.textHeight;

			textSettings = {
				color:0xfefdcf,
				borderColor:0x775002,
				fontSize:20,
				textAlign:"center"
			};
			
			coinsCounter = Window.drawText(Numbers.moneyFormat(App.user.stock.count(Stock.COINS)), textSettings);
			coinsCounter.width = 80;
			coinsCounter.height = coinsCounter.textHeight;
			//coinsCounter.border = true;
			
			textSettings = {
				color:0xfefdcf,
				borderColor:0x892d53,
				fontSize:20,
				textAlign:"center"
			};
			
			fantsCounter = Window.drawText(Numbers.moneyFormat(App.user.stock.count(Stock.FANT)), textSettings);
			fantsCounter.width = 60;
			fantsCounter.height = fantsCounter.textHeight;
			//fantsCounter.border = true;

			textSettings = {
				color:0xfefdcf,
				borderColor:0x482e16,
				fontSize:22,
				textAlign:"center"
			};
			
			robotCounter = Window.drawText("-/-", textSettings);//(String(0), textSettings);
			robotCounter.width = 60;
			robotCounter.height = robotCounter.textHeight;
			
			textSettings = {
				color:0xfefdcf,
				borderColor:0x775002,
				fontSize:20,
				textAlign:"center"
			};
			
			textSettings.fontSize = 16;
			energyCounter = Window.drawText(String(App.user.stock.count(Stock.FANTASY)), textSettings);
			energyCounter.width = 82;
			energyCounter.height = energyCounter.textHeight;
			
			textSettings = {
				color:0xfefdcf,
				borderColor:0x5d0368,
				fontSize:18,
				textAlign:"center"
			};
			
			expCounter = Window.drawText(String(App.user.stock.count(Stock.EXP)), textSettings);
			expCounter.width = 148;
			expCounter.height = expCounter.textHeight;
			
			textSettings.color = 0xffffff;
			textSettings.border = true;
			textSettings.fontSize = 26;
			levelCounter = Window.drawText(String(App.user.level), textSettings);
			levelCounter.width = 32;
			levelCounter.height = levelCounter.textHeight;
			
			updateExperience();
			updateEnergy();
			
			resize();
			
			leftCont.addChild(coinsSprite);
			coinsSprite.mouseChildren = false;
			coinsSprite.addChild(coinsBar);
			coinsSprite.addChild(coinsIcon);
			coinsSprite.addChild(coinsCounter);
			
			coinsSprite.tip = function():Object {
				return {
					title:Locale.__e('flash:1382969956057'),
					text:Locale.__e('flash:1382952379825')
				}
			}
			coinsSprite.name = 'coins';
			coinsSprite.addEventListener(MouseEvent.CLICK, onCoinsEvent);
			
			leftCont.addChild(fantSprite);
			fantSprite.mouseChildren = false;
			//fantSprite.addChild(fantsBar);
			fantSprite.addChild(fantsIcon);
			fantSprite.addChild(fantsCounter);
			fantSprite.tip = function():Object {
				return {
					title:Locale.__e('flash:1382952379826'),
					text:Locale.__e('flash:1382952379827')
				}
			}
			fantSprite.name = 'fants';
			fantSprite.addEventListener(MouseEvent.CLICK, onRealEvent);
			
			//addChild(bearSprite);
			//bearSprite.mouseChildren = false;
			//bearSprite.addChild(bearBar);
			//bearSprite.addChild(bearIcon);
			//bearSprite.addChild(bearCounter);
			//bearSprite.tip = function():Object {
				//return {
					//title:Locale.__e('Твои герои'),
					//text:Locale.__e('Они выполнят все, что вы пожелаете')
				//}
			//}
			
			iconsSprite.addChild(robotSprite);
			robotSprite.mouseChildren = false;
			robotSprite.addChild(robotBar);
			robotSprite.addChild(robotIcon);
			robotSprite.addChild(robotCounter);
			robotSprite.tip = function():Object {
				return {
					title:Locale.__e('flash:1382952379828'),
					text:Locale.__e('flash:1382952379829')
				}
			}
			robotSprite.addEventListener(MouseEvent.CLICK, onRobotEvent);
			
			addChild(iconsSprite);
			//addChild(tresureCont);
			
			/*rightCont.addChild(energySprite);*/
			addChild(capasitySprite);
			capasitySprite.visible = false;
			capasityIcon.smoothing = true;
			capasityBar.smoothing = true;
			
			leftCont.addChild(coinsPlusBttn);
			leftCont.addChild(fantsPlusBttn);
			/*rightCont.addChild(energyPlusBttn);*/
			//addChild(robotPlusBttn);
			iconsSprite.addChild(robotPlusBttn);
			
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			capasitySprite.addChild(capasityIcon);
			capasitySprite.addChild(capasityCounter);
			
			capasityIcon.x = capasityBar.x - capasityIcon.width + 10;
			capasityIcon.y = capasityBar.y - 4;
			
			capasitySlider.x = capasityBar.x + 8;
			capasitySlider.y = capasityBar.y + 6;
			
			capasityCounter.x = capasityBar.x + (capasityBar.width - capasityCounter.textWidth) / 2 - capasityIcon.width/2;
			capasityCounter.y = 2;
			capasitySprite.scaleX = capasitySprite.scaleY = 0.9;
			
			trace("!!!!!!!!capasitySprite-= " + capasitySprite.width);
			
			energySprite.mouseChildren = false;
			capasitySprite.mouseChildren = false;
			//energySprite.addChild(energyBar);
			energySprite.addChild(energySlider);
			energySprite.addChild(energyIcon);
			energySprite.addChild(energyCounter);
			
			energySprite.tip = function():Object {
				/*var bonus:int = 0;
				if (App.social == 'PL' && App.data.options['PlingaEnergyPlus'] != undefined) {
					bonus = App.data.options['PlingaEnergyPlus'];
				}
				if (App.social == 'FB' && App.data.options['FBEnergyPlus'] != undefined) {
					bonus = App.data.options['FBEnergyPlus'];
				}*/
				
				/*if (App.user.energy > 0) {
					return {
						title:Locale.__e('flash:1382952379830',[App.user.stock.count(Stock.FANTASY), Stock.efirLimit]),//App.data.levels[App.user.level].energy + bonus
						text:Locale.__e('flash:1382952379831', [TimeConverter.minutesToStr(Stock.energyRestoreSettings - (App.time - App.user.energy))]),
						timer:true
					}
				}else{*/
					return {
						title:Locale.__e('flash:1382952379830',[App.user.stock.count(Stock.FANTASY), Stock.efirLimit]),//App.data.levels[App.user.level].energy + bonus
						text:Locale.__e('flash:1382952379832')
					}
				//}
			};
			energySprite.addEventListener(MouseEvent.CLICK, onEnergyEvent);
			
			expSprite.mouseChildren = false;
			expSprite.tip = function():Object {
				
				var diffExp:int = App.data.levels[App.user.level + 1].experience || 0;
				diffExp -= App.user.stock.count(Stock.EXP);
				diffExp = diffExp > 0?diffExp:0;
				
				return {
					title:Locale.__e('flash:1382952379833'),
					text:Locale.__e('flash:1382952379834', [diffExp, App.user.level+1])
				}
			};
			
			rightCont.addChild(expSprite);
			rightCont.addChild(energySprite);
			rightCont.addChild(energyPlusBttn);
			expSprite.addChild(expBar);
			expSprite.addChild(expSlider);
			expSprite.addChild(expCounter);
			expSprite.addChild(expIcon);
			expSprite.addChild(levelCounter);
			
			addChild(leftCont);
			addChild(rightCont);
			
			//addChild(bearPanel);
			//bearPanel.x = bearSprite.x + bearSprite.width / 2;
			//bearPanel.y = 46;
			//
			//bearSprite.addEventListener(MouseEvent.MOUSE_OVER, onBearBarOver);
			//bearSprite.addEventListener(MouseEvent.MOUSE_OUT, onBearBarOut);
			
			//var posX:int = App.self.stage.stageWidth/2 - 204;
			for (var i:int = 0; i < App.user.aliens.length; i++ ) {
				var persIcon:PersonageIcon = new PersonageIcon(App.user.aliens[i].sid);
				personageIcons.push(persIcon);
				
				if (!persIcon.isBusy) {
					persIcon.visible = false;
				}else {
					updatePersIcons();
				}
				persIcon.addEventListener(MouseEvent.MOUSE_OVER, onPersIconOver);
				persIcon.addEventListener(MouseEvent.MOUSE_OUT, onPersIconOut);
			}
			
			coinsSprite.x = 5;
			coinsSprite.y = 9;
			
			coinsBar.x = -12;
			coinsBar.y = -19;
			
			coinsCounter.x = coinsBar.x + 61;
			coinsCounter.y = coinsBar.y + 25;
			
			/*coinsIcon.x = coinsBar.x + 2;
			coinsIcon.y = coinsBar.y;*/
			
			coinsIcon.x = coinsBar.x + coinsIcon.width/2;
			coinsIcon.y = coinsBar.y +15;
			
			/*coinsPlusBttn.x = 139;
			coinsPlusBttn.y = 15;*/
			coinsPlusBttn.x = 153;
			coinsPlusBttn.y = 13;
			
			
			fantSprite.x = 5;
			fantSprite.y = 52;
			
			//fantsBar.x = 0;
			//fantsBar.y = 0;
			
			/*fantsIcon.x = -4;
			fantsIcon.y = -1;*/
			fantsIcon.x = (coinsBar.x + coinsIcon.width/2) - 2;
			fantsIcon.y = coinsBar.y +15;
			
			fantsCounter.x = /*fantsBar.x + */45;
			fantsCounter.y = /*fantsBar.y + */8;
			
			fantsPlusBttn.x = 120;
			fantsPlusBttn.y = 55;
			
			robotBar.y = -19;
			
			robotIcon.x = robotBar.x + 27;
			robotIcon.y = robotBar.y + 12;
			
			robotCounter.x = robotBar.x + (robotBar.width - robotCounter.width) / 2;//48;
			robotCounter.y = robotBar.y + 23;
			
			
			energySprite.x = 10;//App.self.stage.stageWidth - 175;
			energySprite.y = 55;
			
			//energyBar.x = 0;
			//energyBar.y = 0;
			
			energyIcon.x = /*energyBar.x - */-12;
			energyIcon.y = /*energyBar.y - */-5;
			
			energySlider.x = /*energyBar.x + */22;
			energySlider.y =/* energyBar.y + */5;
			
			energyCounter.x = /*energyBar.x + */32;
			energyCounter.y = 7;
			
			energyPlusBttn.x = /*energyBar.width - energyPlusBttn.width + 6 */136;
			energyPlusBttn.y = 57;
			
			
			//expSprite.x = App.self.stage.stageWidth - 186;
			expSprite.y = 10;
			
			expBar.x = -38;
			expBar.y = -20;
			
			expIcon.x = -21;
			expIcon.y = -5;
			
			expCounter.x = (expBar.x + 106 - (expCounter.width)/2) + 22;
			expCounter.y = 8;
			
			expSlider.x = 14;
			expSlider.y = 7;
			
			levelCounter.x = expIcon.x + 6;
			levelCounter.y = expIcon.y + 9;
			
			
			robotPlusBttn.x = robotSprite.x + 140;
			robotPlusBttn.y = robotSprite.y + 5;
			//
		}
		
		
		public function setTimeToPersIcons(startTime:int, timeToEnd:int, id:int):void
		{
			for (var i:int = 0; i < personageIcons.length; i++ ) {
				var pers:PersonageIcon = personageIcons[i];
				if (pers.isBusy && pers.instanceId == id) {
					pers.updateTime(startTime, timeToEnd);
					pers.startWork();
				}
			}
		}
		
		public function addPersIcon(item:Object):void
		{
			var persIcon:PersonageIcon = new PersonageIcon(item.sid);
			personageIcons.push(persIcon);
			
			if (!persIcon.isBusy) {
				persIcon.visible = false;
			}else {
				updatePersIcons();
			}
			persIcon.addEventListener(MouseEvent.MOUSE_OVER, onPersIconOver);
			persIcon.addEventListener(MouseEvent.MOUSE_OUT, onPersIconOut);
		}
		
		public function consistPersIcon(sid:int):Boolean 
		{
			for (var i:int = 0; i < personageIcons.length; i++ ) {
				if (sid == personageIcons[i].sid)
					return true;
			}
			return false;
		}
		
		public function updatePersIcons():void
		{
			//var posX:int = App.self.stage.stageWidth/2 - 84;
			var posX:int = 0;// robotSprite.x;
			var posY:int = 5;// robotSprite.x;
			//var iconSprite:Sprite = new Sprite();
			var count:int = 0;
			for (var i:int = 0; i < personageIcons.length; i++ ) {
				var pers:PersonageIcon = personageIcons[i];
				if (pers.isBusy) {
					pers.x = posX + 210;
					pers.y = posY - 5;
					posX += pers.bg.width + 8;
					iconsSprite.addChild(pers);
					//iconSprite.addChild(pers);
					pers.visible = true;
					count ++;
				}else {
					if (pers.parent && pers.parent.contains(pers)) pers.parent.removeChild(pers);
					pers.visible = false;
				}
			}
			//if (count > 0)
				//robotSprite.x = posX - 62 * personageIcons.length;
				
				
				
			//.addChild(iconSprite);
			//iconSprite.y = -5;
			//iconSprite.x = robotSprite.x + 230;
			
			iconsSprite.x = App.self.stage.stageWidth / 2 -iconsSprite.width/2;
			iconsSprite.y = 9;
		}
		
		private var prevPers:PersonageIcon;
		private var intervalClose:int;
		private function onPersIconOut(e:MouseEvent):void 
		{
			var pers:PersonageIcon = (e.currentTarget as PersonageIcon);
			
			intervalClose = setInterval(function():void {
				if (pers.isFocused) {
				}
				else {
					App.self.dispatchEvent(new AppEvent(AppEvent.ON_CLOSE_INFO));
					clearInterval(intervalClose);
				}
			}, 1000);
			
			pers.isFocused = false;
			prevPers = null;
		}
		
		private function onPersIconOver(e:MouseEvent):void 
		{
			var pers:PersonageIcon = (e.currentTarget as PersonageIcon);
			prevPers = pers;
			pers.isFocused = true;
			
			if (PersonageInfoWindow.persSid != pers.sid) {
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_CLOSE_INFO));
				setTimeout(function():void { if (!PersonageInfoWindow.isOpen) new PersonageInfoWindow(PersonageInfoWindow.MODE_PERS, { 
					sid:pers.sid, 
					x:pers.x + pers.width / 2 + iconsSprite.x, 
					y:pers.y + pers.height + iconsSprite.y,
					startTime:pers.startTime, 
					endTime:pers.endTime, 
					pers:pers } ).show()} , 200);
			}
			clearInterval(intervalClose);
		}
		
		public function onRealEvent(e:MouseEvent):void
		{
			if (App.user.quests.tutorial)
				return;
			
			BankMenu._currBtn = BankMenu.REALS;
			BanksWindow.history = {section:'Reals',page:0};
			onBankEevent(e);
		}
		
		public function onCoinsEvent(e:MouseEvent = null):void 
		{
			if (App.user.quests.tutorial)
				return;
			
			BankMenu._currBtn = BankMenu.COINS;
			BanksWindow.history = {section:'Coins',page:0};
			onBankEevent(e);
		}
		
		private function updateTimer():void {
			var time:int = timeToActionEnd - App.time;
			if (time <= 0) {
				App.self.setOffTimer(updateTimer);
				moneyLabelCont.visible = false;
				timeToActionEnd = 0;
				return;
			}
			timerText.text = TimeConverter.timeToStr(time);
		}
		
		private function onBearBarOver(e:MouseEvent):void{
			bearPanel.show();
		}
		
		private function onBearBarOut(e:MouseEvent):void {
			bearPanel.hide();
		}
		
		public var avatar:Bitmap;
		public var avatarSprite:Sprite;
		public function showAvatar():void {
			hideAvatar();
			
			var nameLabel:TextField = Window.drawText(Locale.__e("flash:1396867993836", [(App.owner.aka || App.owner.first_name)]), App.self.userNameSettings( { 
				fontSize:22,
				autoSize:"left",
				color:0xffffff,
				borderColor:0x874c26,
				textAlign:"center",
				multiline:true
			}));
			nameLabel.wordWrap = true;
			nameLabel.width = 120;
			nameLabel.x = 77;
			nameLabel.y = 12;
			
			avatarPanel = new Sprite();//Window.shadowBacking(nameLabel.width+70, 50, 20);
			
			var btmp:Bitmap = Window.backingShort(225, 'avaBg');
			avatarPanel.addChild(btmp);
			
			avatarSprite = new Sprite();
			avatar = new Bitmap(null, "auto", true);
			Log.alert(App.owner);
			//Load.loading();
			
			avatarSprite.addChild(avatar);
			avatarPanel.addChild(avatarSprite);
			
			new AvaLoad(App.owner.photo, onAvatarLoad);
			
		//	avatar.y += 5;
		//	avatar.x += 3;
			//avatarSprite.addChild(avatar);
			//avatarPanel.addChild(avatarSprite);
			
		//	avatarSprite.x += 30;
		//	avatarSprite.y += 12;
			
			avatarPanel.x = (App.self.stage.stageWidth - avatarPanel.width) / 2;
			addChild(avatarPanel);
			avatarPanel.addChild(nameLabel);
			avatarSprite.filters = [new GlowFilter(0xf7f2de, 1, 6, 6, 4, 1)];
		}
		
		public function hideAvatar():void {
			if(avatarPanel != null && contains(avatarPanel)){
				removeChild(avatarPanel);
				avatarPanel = null;
				avatar = null;
				avatarSprite = null;
			}
		}
		
		private function onAvatarLoad(data:*):void {
			if(data is Bitmap){
				avatar.bitmapData = data.bitmapData;
				avatar.height = avatar.width = 46;
				avatar.smoothing = true;
			}	
			//avatar.scaleX = avatar.scaleY = 0.7;
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, 46, 47, 20, 20);
			shape.graphics.endFill();
			avatarSprite.mask = shape;
			shape.x = 25;
			shape.y = 13;
			avatarSprite.x = 25;
			avatarSprite.y = 13;
			avatarPanel.addChild(shape);
			
			var star:Bitmap = new Bitmap(UserInterface.textures.expIcon);
			star.scaleX = star.scaleY = 0.6;
			star.smoothing = true;
			star.x = shape.x + shape.width - star.width / 2 - 6;
			star.y = shape.y + shape.height - star.height / 2 - 3;
			avatarPanel.addChild(star);
			
			
			var lvlTxt:TextField =  Window.drawText(String(App.owner.level), {
					color:0xffffff,
					fontSize:16,
					borderColor:0x814f31,
					autoSize:"center",
					textAlign:"center"
				}
			);
			lvlTxt.width = 90;
			lvlTxt.x = star.x +(star.width - lvlTxt.width) / 2;
			lvlTxt.y = star.y +(star.height - lvlTxt.textHeight) / 2;
			avatarPanel.addChild(lvlTxt);
		}
		
		public function resize():void 
		{
			//glowBg.width = App.self.stage.stageWidth;
			
			if (tweenLeft) {
				tweenLeft.kill();
				tweenLeft = null;
			}
			if (tweenMiddle) {
				tweenMiddle.kill();
				tweenMiddle = null;
			}
			if (tweenRight) {
				tweenRight.kill();
				tweenRight = null;
			}
			
			if (avatarPanel != null) {
				avatarPanel.x = (App.self.stage.stageWidth - avatarPanel.width)/2;
				
				
				if (App.self.stage.displayState == StageDisplayState.NORMAL) {
					//avatarPanel.x += 50;
				}
			}
			
			// Coins
			/*coinsSprite.x = 5;
			coinsSprite.y = 9;
			
			coinsBar.x = 0;
			coinsBar.y = 0;
			
			coinsCounter.x = coinsBar.x + 40;
			coinsCounter.y = coinsBar.y + 8;
			
			coinsIcon.x = coinsBar.x + 2;
			coinsIcon.y = coinsBar.y;
			
			coinsPlusBttn.x = 139;
			coinsPlusBttn.y = 15;*/
			
			// Fants
			/*fantSprite.x = 5;
			fantSprite.y = 52;
			
			fantsBar.x = 0;
			fantsBar.y = 0;
			
			fantsIcon.x = -4;
			fantsIcon.y = -1;
			
			fantsCounter.x = fantsBar.x + 40;
			fantsCounter.y = fantsBar.y + 10;
			
			fantsPlusBttn.x = 119;
			fantsPlusBttn.y = 60;*/
			
			iconsSprite.x = App.self.stage.stageWidth / 2 -iconsSprite.width/2;
			iconsSprite.y = 9;
			
			/*robotBar.y = -1;
			
			robotIcon.x = robotBar.x - 6;
			robotIcon.y = robotBar.y - 9;
			
			robotCounter.x = robotBar.x + (robotBar.width - robotCounter.width) / 2;//48;
			robotCounter.y = robotBar.y + 8;*/
			
			//Energy
			/*energySprite.x = App.self.stage.stageWidth - 175;
			energySprite.y = 55;
			
			energyBar.x = 0;
			energyBar.y = 0;
			
			energyIcon.x = energyBar.x - 2;
			energyIcon.y = energyBar.y - 4;
			
			energySlider.x = energyBar.x + 39;
			energySlider.y = energyBar.y + 9;
			
			energyCounter.x = energyBar.x + 42;
			energyCounter.y = 10;
			
			energyPlusBttn.x = App.self.stage.stageWidth - 42;
			energyPlusBttn.y = 59;*/
			
			//robotPlusBttn.x = robotSprite.x + 115;
			//robotPlusBttn.y = robotSprite.y + 5;
			
			//capasity
			capasitySprite.x = (App.self.stage.stageWidth - (capasityBar.width * 0.8 + capasityIcon.width * 0.8 + 2)) / 2 + 50;
			capasitySprite.y = 55;
			capasityBar.x = 0;
			capasityBar.y = 0;
			
			// Exp
			/*expSprite.x = App.self.stage.stageWidth - 186;
			expSprite.y = 10;
			
			expBar.x = 0;
			expBar.y = 0;
			
			expIcon.x = 0;
			expIcon.y = -9;
			
			expCounter.x = expBar.x + 106 - (expCounter.width)/2;
			expCounter.y = 8;
			
			expSlider.x = 40;
			expSlider.y = 9;
			
			levelCounter.x = expIcon.x + 6;
			levelCounter.y = expIcon.y + 9;*/
							
			if (help != null) help.x = (App.self.stage.stageWidth - help.width) / 2;
			
			
			rightCont.x = App.self.stage.stageWidth - 180;//rightCont.width - 5;
			rightCont.y = 0;
			leftCont.y = 0;
		}
		
		
		
		private function onBankEevent(e:MouseEvent):void {
			if (App.user.quests.track) {
				return;
			}
			switch(App.social) {
				case "PL": 
					if (e.target.name == 'coins') {
						ExternalApi.apiBalanceEvent('coins');
					}else if (e.target.name == 'fants') {
						ExternalApi.apiBalanceEvent('reals');
					}
					break;
				default:
					//new BankSaleWindow().show();
					new BanksWindow().show();
					break;
			}
			
		}

		public function onEnergyEvent(e:MouseEvent = null):void {
			
			if (App.user.quests.tutorial)
				return;
			
			new PurchaseWindow( {
				width:716,
				itemsOnPage:4,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'Energy'}),
				title:Locale.__e("flash:1382952379756"),
				description:Locale.__e("flash:1382952379757"),
				popup: true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
				}
			}).show();
			
		}
		
		public function onRobotEvent(e:MouseEvent = null):void {
			
			if (App.user.quests.tutorial)
				return;
			
				new PurchaseWindow( {
					width:716,
					itemsOnPage:4,
					useText:true,
					shortWindow:true,
					closeAfterBuy:true,
					description:Locale.__e('flash:1393599816743'),
					content:PurchaseWindow.createContent("Energy", {inguest:0, view:'furry'}),
					title:App.data.storage[Techno.TECHNO].title,
					//description:Locale.__e("flash:1382952379757"),
					popup: true,
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();
			/*}else {
				//ShopMenu._currBtn = 1;
				new ShopWindow( { find:[Factory.TECHNO_FACTORY], forcedClosing:true, popup: true } ).show();
			}*/
		}
		
		public function show(toogle:Boolean = true):void {
			//bearBar.visible = toogle;
			//bearIcon.visible = toogle;
			//bearCounter.visible = toogle;
			//energyBar.visible = toogle;
			
			expSprite.visible = toogle;
			energyIcon.visible = toogle;
			energySlider.visible = toogle;
			energyCounter.visible = toogle;
			energyPlusBttn.visible = toogle;
			robotPlusBttn.visible = toogle;
			iconsSprite.visible = toogle;
		}
		
		private var canTween:Boolean = true;
		private var isTween:Boolean = false;
		private var timeOff:int;
		private var hideTween:TweenMax;
		public function updateCapasity(_value:int):void 
		{
			if (isTween) return;
			if (!canTween) {
				clearInterval(timeOff);
				
				removeHideTween();
				
				capasityValues(Stock.value, Stock.limit);
				
				timeOff = setInterval(function():void { 
					clearInterval(timeOff);
					
					hideTween = TweenMax.to(capasitySprite, 0.5, { alpha:0, onComplete:function():void {
							capasitySprite.visible = false; canTween = true;
					}});
					}, 2000);
				return;
			}
			
			removeHideTween();
			
			canTween = false;
			isTween = true;
			var value:int = _value;
			var limit:int = Stock.limit;
			
			capasitySprite.visible = true;
			capasitySprite.alpha = 0;
			
			capasityValues(value, limit);
			
			TweenLite.to(capasitySprite, 1, { alpha:1, onComplete:function():void {
				isTween = false;
				capasityValues(Stock.value, limit);
				
				timeOff = setInterval(function():void { 
					clearInterval(timeOff);
					hideTween = TweenMax.to(capasitySprite, 0.5, { alpha:0, onComplete:function():void {
							capasitySprite.visible = false; canTween = true;
					}});
				}, 2000);
			}});
		}
		
		private function capasityValues(value:int, limit:int):void
		{
			capasityCounter.text = value +'/' + limit;
			UserInterface.slider(capasitySlider, value, limit, "progressBar", true);
		}
		
		private function removeHideTween():void
		{
			if (hideTween) {
				hideTween.complete(true);
				hideTween.killVars(capasitySprite);
				hideTween = null;
				capasitySprite.visible = true; capasitySprite.alpha = 1;
			}
		}
		
		public function updateExperience():void {
			var maxExp:int;
			var minExp:int;
			
			if (App.data.levels[App.user.level+1]){
				maxExp = App.data.levels[App.user.level + 1].experience;
			}else {
				maxExp = App.data.levels[App.user.level].experience;
			}
			minExp = App.data.levels[App.user.level].experience;
			var exp:int = App.user.stock.count(Stock.EXP) - minExp;
			if (exp > maxExp) {
				exp = maxExp;
			}
			UserInterface.slider(expSlider, exp, maxExp-minExp, "expSlider");
		}
		
		public function updateEnergy():void {
			var maxEnergy:int = Stock.efirLimit;
			var energy:int = App.user.stock.count(Stock.FANTASY);
			UserInterface.slider(energySlider, energy, maxEnergy, "energySlider");
		}
		
		private var _arrCounts:Array = [App.user.stock.count(Stock.COINS), App.user.stock.count(Stock.FANT), App.user.personages.length,  
										App.user.stock.count(Stock.EXP), App.user.level];//App.user.stock.count(Stock.FANTASY)
		public function update(fields:Array = null):void {
			
			//if (fields != null) {
				//for each(var field:String in fields) {
					//switch (field) {
						//case 'coins': 
							//coinsCounter.text = Numbers.moneyFormat(App.user.stock.count(Stock.COINS));
							//break;
						//case 'fants':
							//fantsCounter.text 	= Numbers.moneyFormat(App.user.stock.count(Stock.FANT));
							//break;
						//case 'bear':
							//bearCounter.text 	= String(Bear.bears.length);
							//break;
						//case 'energy': 
							//energyCounter.text 	= String(App.user.stock.count(Stock.FANTASY));
							//updateEnergy();
							//break;
						//case 'exp':
							//expCounter.text 	= String(App.user.stock.count(Stock.EXP));
							//updateExperience();
							//break;
					//}
				//}
			//}else {
				var twTime:Number = 1.6;
			//	App.ui.upPanel.update
		
				TweenLite.to(_arrCounts, twTime, {endArray: [App.user.stock.count(Stock.COINS), App.user.stock.count(Stock.FANT), App.user.personages.length, 
										App.user.stock.count(Stock.EXP), App.user.level], ease:Sine.easeOut, onUpdate: output } );//App.user.stock.count(Stock.FANTASY), 
				
				//TweenLite.to(mc, 1, {scaleX:1, scaleY:1, ease:Elastic.easeOut});
				coinsCounter.text 	= Numbers.moneyFormat(App.user.stock.count(Stock.COINS));
				//fantsCounter.text 	= Numbers.moneyFormat(App.user.stock.count(Stock.FANT));
				//bearCounter.text 	= String(App.user.personages.length) + "/3";
				energyCounter.text 	= String(App.user.stock.count(Stock.FANTASY));
				expCounter.text 	= String(App.user.stock.count(Stock.EXP));
				//levelCounter.text 	= String(App.user.level);
				App.user.personages.length,
				robotCounter.text 	=  Techno.getBusyTechno() + "/" + App.user.techno.length;//String(Bear.bears.length);
				
				updateExperience();
				updateEnergy();
			//}
		}
		
		private function output():void 
		{
			//if (App.user.stock.count(Stock.COINS) < _arrCounts[0]) {
				//doScaleAnim(coinsIcon);
				
				//coinsCounter.text 	= Numbers.moneyFormat(int(_arrCounts[0]));
			//}
			//if (App.user.stock.count(Stock.FANT) < _arrCounts[1]) {
				//doScaleAnim(fantsIcon);
				
				fantsCounter.text 	= Numbers.moneyFormat(int(_arrCounts[1]));
				//trace("_arrCounts[1]-= " + _arrCounts[1] + "   fantsCounter.text-= " + fantsCounter.text + "   App.user.stock.count(Stock.FANT)-= " + App.user.stock.count(Stock.FANT) );
			//}
			//if (App.user.personages.length < _arrCounts[2]) {
				//doScaleAnim(bearIcon);
				
				//bearCounter.text 	= String(int(_arrCounts[2])) + "/3";
			//}
			//if (App.user.stock.count(Stock.FANTASY) < _arrCounts[3]) {
				//doScaleAnim(energyIcon);
				
				//energyCounter.text 	= String(int(_arrCounts[3]));
			//}
			//if (App.user.stock.count(Stock.EXP) < _arrCounts[4]) {
				//doScaleAnim(expIcon);
				//
				//expCounter.text 	= String(int(_arrCounts[3]));
			//}
			//if (App.user.level < _arrCounts[5]) {
				
				levelCounter.text 	= String(int(_arrCounts[4]));
			//}
			//if (0 < 0) {
				
			//	robotCounter.text 	= String(int(_arrCounts[5])) + "/3";
			//}
		}
		
		private function doScaleAnim(btm:Bitmap):void
		{
			var container:MovieClip = new MovieClip();
			container.x = btm.x; container.y = btm.y;
			container.addChild(btm);
			btm.x = 0, btm.y = 0;
			addChild(container);
			TweenLite.to(container, 0.8, { scaleX:1.4, scaleY:1.4, ease:Elastic.easeOut, onComplete:function():void {
				TweenLite.to(container, 0.8, { scaleX:1, scaleY:1, ease:Elastic.easeOut } );
			}});
		}
		
		public function showHelp(message:String, width:int = 250):void
		{
			//var paddingX:int = 25;
			//var paddingY:int = 17;
			var text:TextField = Window.drawText(message,
			{
				color:0xfbf6d6,
				borderColor:0x5c4126,
				fontSize:38
			});
			
			text.height 	= text.textHeight;
			text.width 		= text.textWidth + 5;
			//text.x = paddingX;
			//text.y = paddingY;
						
			help = new LayerX();
			var backing:Bitmap = Window.backing(width, 60, 10, "searchPanelBackingPiece");
			help.addChild(backing);
			backing.alpha = 0.9;
			
			text.x = (backing.width - text.width) / 2;
			text.y = (backing.height - text.height) / 2;
			
			help.addChild(text);
			addChild(help);
			
			help.x = (App.self.stage.stageWidth - help.width) / 2;
			help.y = 110;
			help.alpha = 0;
			if (help) {
				TweenLite.to(help, 0.7, { alpha:1, onComplete:function():void { if(help) help.startGlowing(); }} );
			}
			
			/*timer.addEventListener(TimerEvent.TIMER, hideHelp);
			timer.start();*/
		}
		
		public function hideHelp(e:TimerEvent = null):void
		{
			timer.reset();
			timer.removeEventListener(TimerEvent.TIMER, hideHelp);
			
			if (help != null)	
			{
				TweenLite.to(help, 1, { alpha:0, onComplete:function():void
				{
					if (help != null && contains(help)) {
						help.hideGlowing();
						removeChild(help);
					}
					help = null;
				}});
			}
		}
		
		private var moneyLabelCont:LayerX = new LayerX();
		private var timerText:TextField;
		
		private var timeToActionEnd:int = 0;
		public function showMoneyLabels():void {
			
			moneyLabelCont.mouseEnabled = false;
			
			var bgLabel:Bitmap = new Bitmap(Window.textures.boost);
			bgLabel.scaleX = bgLabel.scaleY = 0.67;
			bgLabel.smoothing = true;
			
			var labelTitle:TextField = Window.drawText(Locale.__e("flash:1396521604876"), {
				color:0xffc936,
				borderColor:0x773918,
				textAlign:"center",
				autoSize:"center",
				borderSize:3,
				fontSize:19
			});
			labelTitle.width = labelTitle.textWidth + 10;
			
			
			if(App.data.money && App.time >= App.data.money.date_from && App.time < App.data.money.date_to && App.data.money.enabled == 1)
				timeToActionEnd = App.data.money.date_to;
			else if (App.user.money > App.time)
				timeToActionEnd = App.user.money;
			
			timerText = Window.drawText(TimeConverter.timeToStr(timeToActionEnd), {
				letterSpacing:0,
				textAlign:"center",
				fontSize:17,
				color:0xffea90,
				borderColor:0x7b3a1e,
				borderSize:3
			});
			timerText.width = 80;
			
			labelTitle.y = 7;
			bgLabel.x = (timerText.width - bgLabel.width) / 2;
			labelTitle.x = bgLabel.x + (bgLabel.width - labelTitle.width) / 2;
			timerText.y = labelTitle.y + labelTitle.textHeight - 2;
			
			moneyLabelCont.addChild(bgLabel);
			moneyLabelCont.addChild(labelTitle);
			moneyLabelCont.addChild(timerText);
			
			addChild(moneyLabelCont);
			moneyLabelCont.rotation = -18;
			moneyLabelCont.x = 132;
			moneyLabelCont.y = 50;
			
			App.self.setOnTimer(updateTimer);
		}
		
		private var tweenLeft:TweenLite;
		public function showLeft(value:Boolean = true):void
		{
			if (value && !leftCont.visible && !tweenLeft) {
				leftCont.visible = true;
				leftCont.y = -leftCont.height - 20;
				tweenLeft = TweenLite.to(leftCont, 0.6, { y:0, onComplete:function():void { tweenLeft = null; }} );
			}else if (!value && leftCont.visible && !tweenLeft) {
				leftCont.y = 0;
				tweenLeft = TweenLite.to(leftCont, 0.6, { y: -leftCont.height-20, onComplete:function():void { tweenLeft = null, leftCont.visible = false;}} );
			}
		}
		
		private var tweenMiddle:TweenLite;
		public function showMiddle(value:Boolean = true):void
		{
			if (value && !iconsSprite.visible && !tweenMiddle) {
				iconsSprite.visible = true;
				iconsSprite.y = -iconsSprite.height - 9;
				tweenMiddle = TweenLite.to(iconsSprite, 0.6, { y:9, onComplete:function():void { tweenMiddle = null; }} );
			}else if (!value && iconsSprite.visible && !tweenMiddle) {
				iconsSprite.y = 9;
				tweenMiddle = TweenLite.to(iconsSprite, 0.6, { y: -iconsSprite.height-9, onComplete:function():void { tweenMiddle = null, iconsSprite.visible = false;}} );
			}
			
			//if (iconsSprite.visible) 
				//return;
				//
			//this.y = 0;	
				//
			//iconsSprite.visible = true;
			//iconsSprite.y = -iconsSprite.height -9;
			//
			//tweenMiddle = TweenLite.to(iconsSprite, 0.6, {y:9, onComplete:function():void{tweenMiddle = null}});
		}
		
		private var isRightTween:Boolean = false;
		private var tweenRight:TweenLite;
		public function showRight(value:Boolean = true):void
		{
			if (value && !rightCont.visible && !tweenRight) {
				rightCont.visible = true;
				rightCont.y = -rightCont.height - 20;
				tweenRight = TweenLite.to(rightCont, 0.6, {y:0, onComplete:function():void{tweenRight = null}});
			}else if(!value && rightCont.visible && !tweenRight){
				rightCont.y = 0;
				tweenRight = TweenLite.to(rightCont, 0.6, {y:-rightCont.height, onComplete:function():void{tweenRight = null, rightCont.visible = false;}});
			}
		}
	}
}


import buttons.ImageButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import units.Bear;
import flash.utils.Timer;
import units.Personage;

internal class BearsPanel extends Sprite
{
	private var showed:Boolean = false;
	private var items:Array = [];
	private var container:Sprite;
	private var overed:Boolean = false;
	private var overTimer:Timer = new Timer(250, 1);
	
	public function BearsPanel()
	{
		overTimer.addEventListener(TimerEvent.TIMER, dispose)
	}
	
	public function show():void
	{
		dispose();
		
		items = [];
		container = new Sprite();
		
		var X:int = 0;
		var Y:int = 0;
		Bear.bears.sortOn('id');
		for (var i:int = 1; i <= Bear.bears.length; i++)
		{
			var item:BearItem = new BearItem(Bear.bears[i-1]);
			
			item.addEventListener(MouseEvent.MOUSE_OVER, over);
			item.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			container.addChild(item);
			item.x = X;
			item.y = Y;
			
			X += item.bg.width + 2;
			
			if (i%5 == 0)
			{
				Y += item.bg.height;
				X = 0;
			}
		}
		
		container.x = - container.width / 2;
		addChild(container);
		
		showed = true;
	}
	
	private function over(e:MouseEvent):void
	{
		overed = true;
	}
	private function out(e:MouseEvent):void
	{
		overed = false;
	}
	
	private function dispose(e:TimerEvent = null):void
	{
		overTimer.reset();
		if (overed)
		{
			overTimer.start();
			return;
		}	
		
		for each(var _item:BearItem in items)
		{
			_item.dispose();
			_item.removeEventListener(MouseEvent.MOUSE_OVER, over);
			_item.removeEventListener(MouseEvent.MOUSE_OUT, out);
			removeChild(_item);
			_item = null;
		}
		
		if (container != null)
		{
			removeChild(container);
			container = null;
		}
		
		showed = false;
	}
	
	public function hide():void
	{
		overTimer.reset();
		overTimer.start();
	}
}

import units.Bear;
import ui.UserInterface;
import wins.Window;
import buttons.ImagesButton;

internal class BearItem extends Sprite
{
	public var bg:ImagesButton;
	private var bear:Bear;
	private var bitmap:Bitmap;
	private var statusBitmap:Bitmap;
	
	public function BearItem(bear:Bear)
	{
		this.bear = bear;
		var bearBmd:BitmapData = new BitmapData(UserInterface.textures.mainBttnBacking.width, UserInterface.textures.mainBttnBacking.height, true, 0);
		
		bg = new ImagesButton(UserInterface.textures.mainBttnBacking, bearBmd);
		bg.addEventListener(MouseEvent.CLICK, onClick);
		
		Load.loading(Config.getImage('interface', bear.info.view), function(data:Bitmap):void {
			bg.icon = data.bitmapData;
		});
			
		bitmap = new Bitmap();
		statusBitmap = new Bitmap();
		
		if (bear.resource != null && bear.status == Bear.HIRED)
		{
			Load.loading(Config.getIcon("Material", App.data.storage[bear.resource.info.out].preview), onLoad);
		}
		
		bearBmd = null;
		if (bear.flag == "noJam")
		{
			if(bear.sid == Personage.BEAR)
				bearBmd = UserInterface.textures.noJam;
			else
				bearBmd = UserInterface.textures.noJamFish;
		}
			
		if (bear.flag == "noPlace")
			bearBmd = UserInterface.textures.noPlace;
		
		statusBitmap.bitmapData = bearBmd;
		statusBitmap.scaleX = statusBitmap.scaleY = 0.8;
		statusBitmap.smoothing = true;
		
		addChild(bg);
		addChild(bitmap);
		addChild(statusBitmap);
		
		statusBitmap.y = 45 - statusBitmap.height/2;
	}
	
	private function onLoad(data:Bitmap):void
	{
		bitmap.bitmapData = data.bitmapData;
		var scale:Number = 26 / data.width;
		bitmap.scaleX = bitmap.scaleY = scale;
		bitmap.smoothing = true;
		bitmap.x = bg.width - bitmap.width - 4;
		bitmap.y = bg.height - bitmap.height -4;
		bitmap.filters = [new GlowFilter(0xe8dfcd,1, 4,4,7)];
	}
	
	private function onClick(e:MouseEvent):void
	{
		App.map.focusedOn(bear, true);
	}
	
	public function dispose():void
	{
		bg.removeEventListener(MouseEvent.CLICK, onClick);
		bear = null;
	}
}