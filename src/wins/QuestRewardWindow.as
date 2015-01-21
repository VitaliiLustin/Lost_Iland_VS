package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import strings.Strings;
	import ui.TipsPanel;

	public class QuestRewardWindow extends Window
	{
		public var okBttn:Button;
		
		public var quest:Object = { };
		private var titleQuest:TextField;
		private var descLabel:TextField;
		private var bonusList:RewardList;
		
		
		private var _startMissionPosY:int = 174;
		
		private var _winContainer:Sprite;
		
		private var checkBox:CheckboxButton

		
		public function QuestRewardWindow(settings:Object = null) 
		{
			settings['width'] = 440;
			settings['height'] = 240;
			
			settings['hasTitle'] = false;
			settings['hasButtons'] = false;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;
			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			
			settings['popup'] = true;
			
			settings['qID'] = settings.qID || 2;
			//settings['openSound'] = 'sound_6';
			if (settings.levelRew)
				quest = settings.data;
			else
				quest = App.data.quests[settings.qID];
			super(settings);
			
			//settings.callback(quest.bonus.materials);//вернуть
			
			if(App.user.quests.tutorial){
				App.user.quests.stopTrack();
			}
			
			SoundsManager.instance.playSFX('sound_6');
			TipsPanel.hide();
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close();
		}
		
		private var background:Bitmap;
		override public function drawBackground():void {
			//background = backing(settings.width, settings.height, 80, "questsSmallBackingTopPiece"); // основной бэкграунд
			//layer.addChildAt(background, 0);
			//background.x = - background.width/3 + 25;
			//background.y;
		}
		
		private var preloader:Preloader = new Preloader();
		private var stripe:Bitmap;
		private var upperPart:Bitmap;
				
		override public function drawBody():void 
		{
			
			background = backing(settings.width, settings.height, 80, "dialogueBacking"); // основной бэкграунд
			layer.addChildAt(background, 0);
			background.x = - background.width/3 + 25;
			background.y = 90;
			
			
			upperPart = new Bitmap(Window.textures.questCompleteHeader);
			upperPart.x = -214;
			upperPart.y = background.y - 165;
			layer.addChild(upperPart);
			
			exit.visible = false;
			
			this.x += 120;
			fader.x -= 120;
			this.y -= 40;
			fader.y += 40;
			
			bodyContainer.addChild(preloader);
			preloader.x = -138;
			preloader.y = 184;
			
			drawMessage();
			
			
			okBttn = new Button( {
				borderColor:			[0xfeee7b,0xb27a1a],
				fontColor:				0xffffff,
				fontBorderColor:		0x814f31,
				bgColor:				[0xf5d159, 0xedb130],
				width:162,
				height:50,
				fontSize:32,
				hasDotes:false,
				caption:Locale.__e("flash:1393582068437")
			});
			bodyContainer.addChild(okBttn);
			
			okBttn.addEventListener(MouseEvent.CLICK, onTakeEvent);
			
			
			//var separator:Bitmap = Window.backingShort(200, 'divider', false);
			//separator.alpha = 0.8;
			//bodyContainer.addChild(separator);
			//separator.x = (settings.width/2 - separator.width + 67) - 260;
			//separator.y = 217;
			//
			//var separator2:Bitmap = Window.backingShort(200, 'divider', false);
			//separator2.alpha = 0.8;
			//separator2.scaleX = -1;
			//bodyContainer.addChild(separator2);
			//separator2.x = settings.width/2 - separator.width + 200;
			//separator2.y = 217;
			
			
			var iconContainer:Sprite = new Sprite();
			var character:Bitmap = new Bitmap();
			Load.loading(Config.getQuestIcon('preview', App.data.personages[quest.character].preview), function(data:*):void { 
				bodyContainer.removeChild(preloader);
				
				character.bitmapData = data.bitmapData;
				trace();
				switch(App.data.personages[quest.character].preview) {
					default:
						character.x = -character.width + 60;
						character.y = 0;
						break;
				}
				//iconContainer.addChild(character);
				//bodyContainer.addChildAt(character,0);
			});
			//drawMirrowObjs('diamonds', -24, settings.width + 24, settings.height - 87);
			
			bodyContainer.addChild(iconContainer);
			
			contentChange();
			
			okBttn.x = 23;
			okBttn.y = settings.height - okBttn.height + 100;
			
			if(!settings.levelRew){
				checkBox = new CheckboxButton();
				bodyContainer.addChild(checkBox);
				checkBox.x = okBttn.x + 24;
				checkBox.y = okBttn.y - checkBox.height  - 3;
			}
			
			
			
			//////////////////////////////////////////////////TEXT/////////////////////////////////////////
			var titlePadding:int = -10;
			
			var descMarginX:int = 10;
			
			_winContainer = new Sprite();
			
			titleQuest = Window.drawText(quest.title, {//quest.title, {
				color:0xfffde7,
				borderColor:0x5b2a79,
				borderSize:4,
				fontSize:36,
				multiline:true,
				textAlign:"center"
			});
			titleQuest.wordWrap = true;
			titleQuest.width = 420;
			titleQuest.height = titleQuest.textHeight + 10; 
			
			var descSize:int = 26;
			
			do{
				descLabel = Window.drawText(quest.description, {//quest.description.replace(/\r/g,""), {
					color:0x624512, 
					border:false,
					fontSize:descSize,
					multiline:true,
					textAlign:"center"
				});
					
				descLabel.wordWrap = true;
				descLabel.width = 380;
				descLabel.height = descLabel.textHeight + 10;
					
				descSize -= 1;	
			}
			while (descLabel.height > 104.8) 
				
			var curHeight:int = titleQuest.height + descLabel.height + titlePadding*2;
			if (curHeight > 240) curHeight = 240;
			if (curHeight < 200) curHeight = 200;
			
			var marginSpriteY:int = 65;
		
			titleQuest.y = upperPart.y + (upperPart.height - titleQuest.height)/2  + 40;
			titleQuest.x = upperPart.x + (upperPart.width - titleQuest.width)/2;
			
			descLabel.y = titleQuest.y + titleQuest.height + 25;
			if (descLabel.height >= 100)
			{
				descSize -= 1;
				descLabel.y = titleQuest.y + titleQuest.height + 15;
			}
			//descLabel.y = background.y + 35;
			descLabel.x = background.x + (background.width - descLabel.width)/2;
			
			bodyContainer.addChild(titleQuest);
			//bodyContainer.addChild(descLabel);
			
			bodyContainer.addChild(_winContainer);
			
			_winContainer.x = (settings.width - _winContainer.width) / 2 + 74;
			_winContainer.y = _startMissionPosY - _winContainer.height; //+ background.y
			
			addIcon();
			
		}
		
		private function onTakeEvent(e:MouseEvent):void {
			if (checkBox && checkBox.checked == CheckboxButton.CHECKED) onTellEvent(e);
			bonusList.take();
			close();
		}
		
		private function onTellEvent(e:MouseEvent):void {
			//Пост на стену
		//	var message:String = Locale.__e('flash:1382952380041 прошел flash:1382952379984дание \"%s\" в игре \"flash:1382952379705\". %s', [quest.title, Config.appUrl]);
			
		
			/*var message:String = Strings.__e('QuestRewardWindow_onTellEvent', [quest.title, Config.appUrl]); 
			var back:Sprite = new Sprite();
			var front:Sprite = new Sprite();
			
			var bitmap:Bitmap = new Bitmap();
			bitmap = Load.getCache(Config.getQuestIcon("preview", App.data.personages[quest.character].preview));
			if (bitmap) {
				back.addChild(bitmap);
				bitmap.scaleX = bitmap.scaleY = 0.7;
				bitmap.smoothing = true;
			}
		
			var gameTitle:Bitmap = new Bitmap(Window.textures.logo, "auto", true);
			back.addChild(gameTitle);
			gameTitle.x = 0;
			if (bitmap) {
				gameTitle.y = bitmap.height - 10;
				bitmap.x = (gameTitle.width - bitmap.width) / 2;
			}
			else {
				gameTitle.y = 10;
				bitmap.x = (gameTitle.width - 10) / 2;
			}
			
			//bitmap.x = (gameTitle.width - bitmap.width) / 2;
				
			var bmd:BitmapData;
			if (bitmap)
				bmd = new BitmapData(Math.max(bitmap.width, gameTitle.width), back.height);//, true, 0);
			else 
				bmd = new BitmapData(Math.max(10, gameTitle.width), back.height);//, true, 0);
			bmd.draw(back);
			
			ExternalApi.apiWallPostEvent(ExternalApi.QUEST, new Bitmap(bmd), App.user.id, message, settings.qID);*/
			
			WallPost.makePost(WallPost.QUEST, {quest:quest, qID:settings.qID});
			
			//End Пост на стену
			
			bonusList.take();
			close();
		}
		
		
		private function drawMessage():void {
			
			//var titlePadding:int = -10;
			//
			//var descMarginX:int = 10;
			//
			//_winContainer = new Sprite();
			//
			//titleQuest = Window.drawText(quest.title, {//quest.title, {
				//color:0xfffde7,
				//borderColor:0x5b2a79,
				//borderSize:4,
				//fontSize:36,
				//multiline:true,
				//textAlign:"center"
			//});
			//titleQuest.wordWrap = true;
			//titleQuest.width = 320;
			//titleQuest.height = titleQuest.textHeight + 10; 
			//
			//var descSize:int = 26;
			//
			//do{
				//descLabel = Window.drawText(quest.description, {//quest.description.replace(/\r/g,""), {
					//color:0x624512, 
					//border:false,
					//fontSize:descSize,
					//multiline:true,
					//textAlign:"center"
				//});
					//
				//descLabel.wordWrap = true;
				//descLabel.width = 360;
				//descLabel.height = descLabel.textHeight + 10;
					//
				//descSize -= 1;	
			//}
			//while (descLabel.height > 104.8) 
				//
			//var curHeight:int = titleQuest.height + descLabel.height + titlePadding*2;
			//if (curHeight > 240) curHeight = 240;
			//if (curHeight < 200) curHeight = 200;
			//
			//var marginSpriteY:int = 65;
		//
			//titleQuest.y = -39;
			//titleQuest.x = - titleQuest.width/2 - 10;
			//
			//descLabel.y = 40;
			//descLabel.x = (-descLabel.width)/2 - 20;
			//
			//_winContainer.addChild(titleQuest);
			//_winContainer.addChild(descLabel);
			//
			//bodyContainer.addChild(_winContainer);
			//
			//_winContainer.x = (settings.width - _winContainer.width) / 2 + 74;
			//_winContainer.y = _startMissionPosY - _winContainer.height; //+ background.y
		}
		
		private function addIcon():void
		{
			var persIcon:Bitmap;
			//App.data.personages;
			switch (App.data.personages[quest.character].ID) 
			{
				case 1:
					persIcon = new Bitmap(Window.textures.druidIco);
					persIcon.x = upperPart.x + (upperPart.width - persIcon.width)/2 - 10;
					persIcon.y = upperPart.y- 5;
				break;
				case 2:
					persIcon = new Bitmap(Window.textures.minionIco);
					persIcon.x = upperPart.x + (upperPart.width - persIcon.width)/2 + 5;
					persIcon.y = upperPart.y - 25;
				break;
				case 3:
					persIcon = new Bitmap(Window.textures.dragonIco);
					persIcon.x = upperPart.x + (upperPart.width - persIcon.width)/2 + 2;
					persIcon.y = upperPart.y - 60;
				break;
				case 4:
					persIcon = new Bitmap(Window.textures.engineerIco);
					persIcon.x = upperPart.x + (upperPart.width - persIcon.width)/2 + 15;
					persIcon.y = upperPart.y - 17;
				break;
				case 5:
					persIcon = new Bitmap(Window.textures.rangerIco);
					persIcon.x = upperPart.x + (upperPart.width - persIcon.width)/2 - 17;
					persIcon.y = upperPart.y - 36;
				break;
				case 6:
					persIcon = new Bitmap(Window.textures.evilIco);
					persIcon.x = upperPart.x + (upperPart.width - persIcon.width)/2 - 15;
					persIcon.y = upperPart.y-26;
				break;
				default:
			}
			
			
			bodyContainer.addChild(persIcon);
			
			
			//var bitmap:Bitmap = new Bitmap();
			
		}
		
		override public function contentChange():void {
			
			bonusList = new RewardList(quest.bonus.materials, true, settings.width - 50, Locale.__e("flash:1382952380000"), 0.4);
			bodyContainer.addChild(bonusList);
			bonusList.x = -97 - 15;//(settings.width - bonusList.width) / 2;
			bonusList.y = 100;
			
			var separator:Bitmap = Window.backingShort(180, 'divider', false);
			separator.alpha = 0.8;
			bodyContainer.addChild(separator);
			separator.x = (bonusList.width/2 - separator.width + 67) - 250;
			separator.y = bonusList.y + 30;
			
			var separator2:Bitmap = Window.backingShort(180, 'divider', false);
			separator2.alpha = 0.8;
			separator2.scaleX = -1;
			bodyContainer.addChild(separator2);
			separator2.x = bonusList.width/2 - separator.width + 167;
			separator2.y = bonusList.y + 30;
			
		}
		
		override public function dispose():void {
			okBttn.removeEventListener(MouseEvent.CLICK, close);
			
			super.dispose();
			
			/*if(App.user.quests.tutorial){
				App.user.quests.continueTutorial();
			}*/
		}
		
	}

}
