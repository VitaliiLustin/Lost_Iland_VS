package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	public class QuestWindow extends Window
	{
		public var missions:Array = [];
		
		public var okBttn:Button;
		
		public var quest:Object = { };
		private var titleQuest:TextField;
		private var titleShadow:TextField;
		private var descLabel:TextField;
		
		private var arrowLeft:ImageButton;
		private var arrowRight:ImageButton;
		
		private var prev:int = 0;
		private var next:int = 0;
		private var background:Bitmap;
		private var _startMissionPosY:int = 140;
		
		private var _winContainer:Sprite;
		
		public function QuestWindow(settings:Object = null)
		{
			settings['width'] = 464;
			settings['height'] = 510;
			
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			
			settings["background"] = 'questBacking';  //questsSmallBackingTopPiece   questsMainBacking
			
			settings['hasFader'] = true;
			
			settings['qID'] = settings.qID || 2;
			quest = App.data.quests[settings.qID];
			super(settings);
			
			settings.content = App.user.quests.opened;
			
			for each(var item:* in App.user.quests.opened) {
				if (settings.qID == item.id) {
					break;
				}
				prev = item.id;
			}
			
			for each(item in App.user.quests.opened) {
				if (item.id == 144)
					continue;
				if (next == -1) {
					next = item.id;
					break;
				}
				if (settings.qID == item.id) {
					next = -1;
				}
			}
		}
		
		override public function drawBackground():void 
		{
			if (missions.length == 3)
			{
				bodyContainer.y += 40;
				exit.y += 40;
			}
		}
		
		private var preloader:Preloader = new Preloader();
		override public function drawBody():void 
		{
			exit.x += 13;
			exit.y -= 30;
			
			drawMessage();
			
			okBttn = new Button( {
				width:150,
				height:47,
				fontSize:28,
				hasDotes:false,
				caption:Locale.__e("flash:1382952380242")
			});
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, close);
			
			var character:Bitmap = new Bitmap();
			
			bodyContainer.addChild(preloader);
			preloader.x = -138;
			preloader.y = 184;
			
			this.x += 130;
			if(fader)fader.x -= 130;
			
			Load.loading(Config.getQuestIcon('preview', App.data.personages[quest.character].preview), function(data:*):void { 
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				var addY:int;
				if (missions.length == 3)
				{
					addY = 40;	
				}
				switch(App.data.personages[quest.character].preview) {
					case 'dragon':
						character.x = -(character.width / 4) * 3 - 50/* + 120*/;
						character.y = -90 + addY;
					break;
					case 'druid':
						character.x = -(character.width / 4) * 3 - 20;
						character.y = -80 + addY;
					break;
					case 'engineer':
						character.x = -(character.width / 4) * 3 - 12;
						character.y = -12 + addY;
					break;
					case 'evil':
						character.x = -(character.width / 4) * 3 + 250;
						character.y = -70 + addY;
					break;
					case 'minion':
						character.x = -(character.width / 4) * 3 - 50;
						character.y = -90 + addY;
					break;
					case 'ranger':
						character.x = -(character.width / 4) * 3 - 37;
						character.y = -120 + addY;
					break;
					case 'AI':
						character.x = -(character.width / 4) * 3 - 20;
						character.y = -72 + addY;
					break;
					default:
						character.x = -character.width + 60;
						character.y = 0 + addY;
						break;
				}
				bodyContainer.addChildAt(character,0);
			});
			if (missions.length == 3)
			{
				
			}
			contentChange();
			
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = background.height - okBttn.height - 10;
			
			arrowLeft = new ImageButton(Window.textures.arrow, {scaleX:-1,scaleY:1});
			arrowRight = new ImageButton(Window.textures.arrow, {scaleX:1,scaleY:1});
			
			arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onPrevQuest);
			arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onNextQuest);
			
			if(prev > 0){
				bodyContainer.addChild(arrowLeft);
				arrowLeft.x = okBttn.x - arrowLeft.width - 105;
				arrowLeft.y = okBttn.y - 15;
			}
			
			if(next > 0){
				bodyContainer.addChild(arrowRight);
				arrowRight.x = okBttn.x + okBttn.width + 105;
				arrowRight.y = okBttn.y - 15;
			}
			
			settings.height = okBttn.y + okBttn.height + 16;
			trace();
			//var background:Bitmap = backing(settings.width, settings.height, 50, "itemBacking");
			//layer.addChildAt(background, 0);
			
			
			var separator:Bitmap = Window.backingShort(settings.width - 120, 'divider');
			separator.alpha = 0.8;
			bodyContainer.addChildAt(separator, 0);
			separator.x = 60;
			separator.y = okBttn.y + okBttn.height / 2 - separator.height / 2;
		}
		
		private function onPrevQuest(e:MouseEvent):void {
			close();
			App.user.quests.openWindow(prev);
		}
		
		private function onNextQuest(e:MouseEvent):void {
			close();
			App.user.quests.openWindow(next);
		}
		
		private function drawMessage():void 
		{
			
			var titlePadding:int = 20;
			var descPadding:int = 51;
			
			var descMarginX:int = 10;
			
			_winContainer = new Sprite();
			titleQuestContainer = new Sprite();
			titleQuest = Window.drawText(quest.title, {//quest.title, {
				color:0xFFFFFF,
				borderColor:0xa9784b,
				//borderSize:3,
				fontSize:37,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:260
				//autoSize:"center"				
			});
			titleQuest.wordWrap = true;
			
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.strength = 20;
			myGlow.blurX = 5;
			myGlow.blurY = 5;
			myGlow.color = 0x916234;
			
			titleQuest.wordWrap = true;
			//titleQuest.border = true;
			titleQuest.width;
			
			var descSize:int = 28;
			
			do{
				descLabel = Window.drawText(quest.description, {//quest.description.replace(/\r/g,""), {
					color:0x624512, 
					border:false,
					fontSize:descSize,
					multiline:true,
					textAlign:"center"
				});
					
				descLabel.wordWrap = true;
				descLabel.width = 300;
				descLabel.height = descLabel.textHeight + 40;
					
				descSize -= 1;	
			}
			while (descLabel.height > 140) 
		
			var curHeight:int;
			if (titleQuest.height < 60) {
				curHeight = titleQuest.height + descLabel.height + titlePadding;
			}else
			{
				curHeight = titleQuest.height + descLabel.height + titlePadding - 25;
			}
			
			var marginSpriteY:int = 65;

			bg = Window.backing(380,  curHeight, 80, 'dialogueBacking');
			bg.y = _startMissionPosY + marginSpriteY - bg.height;
			bg.x = -50;
			titleQuest.height = titleQuest.textHeight + 10; 
			titleQuest.y = bg.y - titleQuest.height/2 + 10;
			titleQuest.x = bg.x + bg.width/2 - titleQuest.width/2;
			
			//descLabel.y = (titleQuest.y + titleQuest.height) - descSize/2 + 10;
			//descLabel.y = (titleQuest.y + descLabel.height/2) - 20;
			descLabel.y = titleQuest.y + titleQuest.height - 7;
			if (titleQuest.height >= 70)
			{
				descLabel.y = titleQuest.y + titleQuest.height - 10;
			}
			
			descLabel.x = descMarginX - 22;
			
			//if (descSize >= 26)
			//{
				//descLabel.y = (titleQuest.y + titleQuest.height) - 20;
			//}
			
			_winContainer.addChild(bg);
			titleQuestContainer.addChild(titleQuest);
			_winContainer.addChild(titleQuestContainer);
			_winContainer.addChild(descLabel);
			titleQuestContainer.filters = [myGlow];
			bodyContainer.addChild(_winContainer);
			titleQuest.textWidth
			
			_winContainer.x = 90/*(settings.width - _winContainer.width) / 2 + 25*/;
			_winContainer.y = -marginSpriteY;
			
			var rose:Bitmap = new Bitmap(Window.textures.diamondsTop);
			_winContainer.addChild(rose);
			rose.x = titleQuest.x - 60;
			rose.y = titleQuest.y + titleQuest.height/2 - rose.height/2;
			
			var rose2:Bitmap = new Bitmap(Window.textures.diamondsTop);
			_winContainer.addChild(rose2); rose2.scaleX = -1;
			rose2.x = titleQuest.x + titleQuest.width + 60;
			rose2.y = rose.y;
		}
		
		public function progress(mID:int):void {
			contentChange();
			for each(var item:Mission in missions) {
				if (item.mID == mID) {
					item.progress();
				}
			}
		}
		
		private var bonusList:Sprite;
		override public function contentChange():void {
			
			for each(var item:Mission in missions) {
				bodyContainer.removeChild(item);
				item.dispose();
				item = null;
			}
			missions = [];
			
			var bonusBackgroutnd:Bitmap = backingShort(316, "questRewardBacking");
			bonusBackgroutnd.x = 72;
			bonusBackgroutnd.y = 79;
			bodyContainer.addChild(bonusBackgroutnd);
			//if(bonusList == null){
				bonusList = new BonusList(quest.bonus.materials, false, { 
					hasTitle:false,
					background:'questRewardBacking',
					backingShort:true,
					width: 1909,
					height: 60,
					bgWidth:5000,
					bgX: -3,
					bgY:5,
					titleColor:0x571b00,
					titleBorderColor:0xfffed7,
					bonusTextColor:0x361a0a,
					bonusBorderColor:0xfffed7
					
					} );
			
				bodyContainer.addChild(bonusList);
				bonusList.x = (settings.width - bonusList.width) / 2;
				bonusList.y = 73;
				
				var titleTextCenter:TextField = Window.drawText(Locale.__e('flash:1382952380000'), {
				width:settings.width,
				fontSize:30,
				autoSize:"center",
				color:0x571b00,
				borderColor:0xfffed7,
				borderSize:2
				} );
				titleTextCenter.x = bonusList.x +(bonusList.width / 2 - titleTextCenter.width / 2);
				titleTextCenter.y = (bonusList.y - titleTextCenter.height/2) + 2;

				bodyContainer.addChild(titleTextCenter);
			//}
			
			var itemNum:int = 0;
			for(var mID:* in quest.missions) {
				
				item = new Mission(settings.qID, mID, this);
				
				bodyContainer.addChild(item);
				item.x = (settings.width - item.background.width) / 2;
				item.y = _startMissionPosY + 116 * itemNum;
								
				missions.push(item);
				if (id == mID) {
					item.progress();
				}
				
				itemNum++;
			}
			if (App.user.quests.tutorial) {
				App.user.quests.glowHelp(this);
			}
			
			if ((App.user.quests.data[103] && App.user.quests.data[103].finished == 0) || 			
				(App.user.quests.data[5] && App.user.quests.data[5].finished == 0) ||
				(settings.qID == 36)){
					App.user.quests.glowHelp(this);	
			}
			
			var bgHeight:int = (6 + item.background.height) * itemNum + 204;
			
			if (background)
				layer.removeChild(background);
			
			background = backing(settings.width, bgHeight, 120, settings.background);//bgHeight
			if (missions.length == 3)
			{
				background.y += 40;
			}
			layer.addChildAt(background, 0);
			//background.x = 120;
		}

		private var titleQuestContainer:Sprite;
		private var bg:Bitmap;
		
		
		
		override public function dispose():void {
			if (okBttn)
				okBttn.removeEventListener(MouseEvent.CLICK, close);
			
			if (_winContainer && _winContainer.parent)_winContainer.parent.removeChild(_winContainer);
			_winContainer = null;
			
			super.dispose();
			
			Tutorial.showTip(settings.qID);
		}
		
	}

}
import buttons.Button;
import buttons.MenuButton;
import buttons.MoneyButton;
import buttons.MoneySmallButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.SimpleWindow;


internal class Mission extends Sprite {
	
	public var qID:int;
	public var mID:int;
	public var background:Bitmap;
	public var bitmap:Bitmap = new Bitmap();
	
	public var mission:Object = { };
	public var quest:Object = { };
	
	public var counterLabel:TextField;
	public var titleLabel:TextField;
	
	public var skipBttn:MoneyButton;
	public var helpBttn:MenuButton;
	
	private var preloader:Preloader = new Preloader();
	
	private var window:*;
	private var titleDecor:Bitmap;
	
	public function Mission(qID:int, mID:int, window:*) {
		
		this.qID = qID;
		this.mID = mID;
		
		this.window = window;
		
		var bgHeight:int = 110;
		
		//background = Window.backing(390, 110, 50, 'questsSmallBackingTopPiece');//'bonusBacking');
		background = Window.backing2(430, bgHeight, 44, 'questTaskBackingTop', 'questTaskBackingBot');//'bonusBacking');
		background.y = 7;
		addChild(background);
		addChild(bitmap);
		
		quest = App.data.quests[qID];
		mission = App.data.quests[qID].missions[mID];
				
		var sID:*;
		if(mission.target is Object){
			for each(sID in mission.target) {
				break;
			}
		}else if (mission.map is Object) {
			for each(sID in mission.map) {
				break;
			}
		}
		
		if(sID!= null && App.data.storage[sID] != undefined){
			
			var url:String;
			if (sID == 0 || sID == 1) {
				url = Config.getQuestIcon('missions', mission.preview);
			}else {
				var icon:Object
				if (mission.preview != "" && mission.preview != "1") {
					icon = App.data.storage[mission.preview];
				}else{
					icon = App.data.storage[sID];
				}
				url = Config.getIcon(icon.type, icon.preview);
			}	
			
			loadIcon(url);
		}else if (qID == 30) {
			loadIcon(Config.getQuestIcon("icons", "druid"));
		}
		
		function loadIcon(url:String):void 
		{
			addChild(preloader);
			preloader.x = 50;
			preloader.y = 45;
			
			Load.loading(url, function(data:*):void {
				
				removeChild(preloader);
				
				bitmap.bitmapData = data.bitmapData;
				if (bitmap.height > bgHeight-20) {
					
					bitmap.height = bgHeight - 24;
					bitmap.scaleX = bitmap.scaleY;
				}
				bitmap.smoothing = true;
				
				bitmap.x = 60 - (bitmap.width) / 2;
				if (bitmap.x < -8) bitmap.x = -8;
				bitmap.y = (bgHeight - bitmap.height)/2/* - 5*/;
				
				bitmap.filters = [new GlowFilter(0xffffff,0.75, 4,4,7)];
			});
		}
		
		var have:int = App.user.quests.data[qID][mID];
		
		var text:String;
		if(mission.func == 'sum'){
			text = have + '/' + mission.need;
		}else {
			if (have == mission.need) {
				text = '1/1';
			}else {
				text = '0/1';
			}
			//text = have + '/' + mission.need;
		}
		
		counterLabel = Window.drawText(text, {
			fontSize:32,
			color:0xffffff,
			borderColor:0x2D2D2D,
			autoSize:"left"
		});
		
		counterLabel.x = 60 - (counterLabel.width) / 2;
		counterLabel.y = 60;
		addChild(counterLabel);
		
		titleLabel = Window.drawText(mission.title, {
			fontSize:24,
			color:0xffffff,
			borderColor:0x49341e,
			multiline:true,
			borderSize:3,
			textAlign:"center",
			textLeading:-3
		});
		titleLabel.wordWrap = true;
		titleLabel.width = 160;
		titleLabel.height = titleLabel.textHeight+10;
		
		titleLabel.x = 110;
		titleLabel.y = (background.height - titleLabel.height) / 2 + 10;
		addChild(titleLabel);
		
		//titleDecor = new Bitmap(Window.textures.diamondsTop, "auto", true);
		//addChild(titleDecor);
		//titleDecor.x = titleLabel.x - titleDecor.width - 5;
		//titleDecor.y = titleLabel.y - 270;

		if (have >= mission.need) {
			drawFinished();
		}else{
			drawButtons();
		}
		
		/*if (qID == 36) {	
			App.user.quests.startTrack();
			App.user.quests.currentTarget = helpBttn;
		}*/
	}
	
	private function drawFinished():void {
		
		var underBg:Bitmap = new Bitmap(Window.textures.questCheckmarkSlot, "auto", true);
		addChild(underBg);
		underBg.x = background.width - underBg.width - 30;
		underBg.y = (background.height - underBg.height) / 2 + 5;
		
		var finished:Bitmap = new Bitmap(Window.textures.checkMark, "auto", true);
		addChild(finished);
		finished.x = background.width - finished.width - 27;
		finished.y = (background.height - finished.height) / 2 + 5;
	}
	
	private function drawButtons():void {
		
		skipBttn = new MoneyButton( {
			title: Locale.__e("flash:1382952379751"),// flash:1382952380253"),
			countText:String(mission.skip),
			width:115,
			height:38,
			borderColor:[0xcefc97, 0x5f9c11],
			fontColor:0xFFFFFF,
			fontBorderColor:0x4d7d0e,
			bevelColor:[0xcefc97,0x5f9c11]
		})
		
		addChild(skipBttn);
		skipBttn.x = background.width - skipBttn.width - /*18*/30;
		skipBttn.y = 20;
		skipBttn.countLabel.width = skipBttn.countLabel.textWidth + 5;
		
		
		if (skipBttn.textLabel.height < 20)
			skipBttn.textLabel.y -= 4;
			
		skipBttn.addEventListener(MouseEvent.CLICK, onSkipEvent);
		
		helpBttn = new MenuButton( { 
			title:Locale.__e('flash:1382952380254'),
			width:115,
			height:38,
			bgColor:[0x82c9f6,0x5dacde],
			borderColor:[0xa0d5f6, 0x3384b2],
			fontColor:0xFFFFFF,
			fontBorderColor:0x435060,
			bevelColor:[0xc2e2f4,0x3384b2],
			fontSize:22,
			radius:12
		});
		
		addChild(helpBttn);
		helpBttn.x = background.width - helpBttn.width - 30;
		helpBttn.y = 62;
		helpBttn.settings['find'] = mission.find;
		
		helpBttn.addEventListener(MouseEvent.CLICK, onHelpEvent);
	}
	
	private function onHelpEvent(e:MouseEvent):void
	{
		//if (qID == 36)	
			//App.user.quests.startTrack();
			
		if (e.currentTarget.settings.find > 0) {
			App.user.quests.helpEvent(qID, mID);
			window.close();
		}else{
			new SimpleWindow( {
				popup:true,
				height:300,
				width:420,
				title:Locale.__e('flash:1382952380254'),
				text:App.data.quests[qID].missions[mID].description
			}).show();
		}
	}
	
	public function onSkipEvent(e:MouseEvent):void {
		
		if (App.user.quests.skipEvent(qID, mID, window.progress)) {
			var pnt:Point = Window.localToGlobal(skipBttn)
			var pntThis:Point = new Point(pnt.x - 130, pnt.y - 10);
			Hints.minus(Stock.FANT, mission.skip, pntThis, false, window);
			skipBttn.removeEventListener(MouseEvent.CLICK, onSkipEvent);
		};
	}
	
	public function progress():void {
		App.ui.flashGlowing(bitmap, 0xFFFF00, null, false);
	}
	
	public function dispose():void {
		if(skipBttn != null){
			skipBttn.removeEventListener(MouseEvent.CLICK, onSkipEvent);
		}
	}
}