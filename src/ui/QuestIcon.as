package ui
{
	import buttons.ImagesButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.QuestPanel;
	import wins.Window;

	public class QuestIcon extends Sprite
	{
		private var iconContainer:Sprite;
		public var bttn:ImagesButton;
		private var questData:Object;
		private var item:Object;
		private var qID:uint;
		
		public var bg:Bitmap;
		
		public static var HEIGHT:int;
		
		//private var preloader:Preloader = new Preloader();
		
		public function QuestIcon(item:Object) {
			
			this.item = item;
			this.qID = item.id;
			this.questData = App.data.quests[qID];
			
			for (var ind:* in this.questData.missions) {
				break;
			}
			
			var preview:String 	= questData.missions[ind].preview;
			var target:Object 	= questData.missions[ind].target;
			if (target == null) {
				target = App.data.quests[item.id].missions[ind].map;
			}
			
			for each(var sID:* in target) {
				break;
			}
			iconContainer = new Sprite();
			addChild(iconContainer);
			this.visible = false;
			bg = new Bitmap(Window.textures.questIconBacking);
			iconContainer.addChild(bg);
			
			//addChild(preloader);
			//preloader.x = (bg.width - preloader.width)/ 2;
			//preloader.y = (bg.height - preloader.height)/ 2;
			
			HEIGHT = bg.height;
			
			bttn = getMaterialIcon(bttn, item, sID, preview);
			bttn.addEventListener(MouseEvent.CLICK, onQuestOpen);
			setCoords();
			//var materialIcon:Bitmap = new Bitmap(data.bitmapData);
			//iconContainer.addChild(bttn);
			iconContainer.addChildAt(bttn, 1);
			//bttn.visible = false;
			
			
			if (!App.user.quests.tutorial) {
				if (QuestPanel.progressQuest == qID) {
					if(App.user.quests.data[qID][Quests.questMission] >= App.data.quests[qID].missions[Quests.questMission].need)//потестить
						glowIcon(Locale.__e('flash:1382952379797'), 4000);
					QuestPanel.progressQuest = 0;
				}
				else
				{
					if (QuestPanel.newQuests.hasOwnProperty(qID))
					{
						if (QuestPanel.newQuests[qID] > App.time) {
							
							if (filterQuestGlow(qID))
								glowIcon(Locale.__e('flash:1382952379743'), 0, false);
							else
								glowIcon(Locale.__e('flash:1382952379743'), 6000);
						}
						//else
						delete QuestPanel.newQuests[qID];
					}
				}
			}
			else
			{
				App.ui.flashGlowing(bttn, 0xFFFF00, null, false);
			}
			
			bttn.tip = function():Object 
			{
				var text:String = "";
				var missions:Object = App.data.quests[this.settings.qID].missions;
				
				for (var missID:String in missions)
				{
					var have:int = App.user.quests.data[this.settings.qID][missID];
					var mission:Object = missions[missID];
					var counter:String;
					
					if(mission.func == 'sum'){
						counter = have + '/' + mission.need;
					}else {
						if (have == mission.need) {
							counter = '1/1';
						}else{
							counter = '0/1';
						}
					}
					
					text += '- '+missions[missID].title+' ('+counter+')';
					text += "\n";
				}
					
				return {
					title:Locale.__e(App.data.quests[this.settings.qID].title),
					text:text
				}
			};
			
			//Tutorial.showTip(qID);
		}
		
		private function filterQuestGlow(id:int):Boolean 
		{
			var isNeed:Boolean = false;
			
			for (var qid:* in questsGlowNoStop ) {
				if (id == qid) {
					isNeed = true;
					break;
				}
			}
			
			return isNeed;
		}
		
		private var questsGlowNoStop:Object = {
			142:true,
			13:true,
			39:true,
			15:true,
			17:true,
			65:true
		}
		
		private var timeID:uint;
		private var materialIcon:Bitmap;
		public function glowIcon(text:String, timout:uint, isTimeOut:Boolean = true):void {
			
			clearTimeout(timeID);
			if (text.length > 1)
			{
				bttn.showPointing("right", 0, 15, this, text, {
					color:0xffd619,
					borderColor:0x7c3d1b,
					autoSize:"left",
					fontSize:24
				}, true);
			}
			bttn.showGlowing();
			
			if(isTimeOut)
				timeID = setTimeout(clear, timout);
			SoundsManager.instance.playSFX('sound_5');	
		}
		
		public function clear():void {
			clearTimeout(timeID);
			bttn.hideGlowing();
			bttn.hidePointing();
		}
		
		public function onQuestOpen(e:MouseEvent):void {
			bttn.hideGlowing();
			bttn.hidePointing();
			App.user.quests.openWindow(qID);
		}
		
		private function getMaterialIcon(bttn:ImagesButton, item:*, sID:int, _preview:String = ""):ImagesButton {
				
			var bitmap:Bitmap = new Bitmap(new BitmapData(60,60, true, 0), "auto", true);
			bttn = new ImagesButton(bitmap.bitmapData, null, { qID:item.id } ); 
			
			var url:String;
			if (sID == 0 || sID == 1){
				url = Config.getQuestIcon('missions', _preview);
			}else {
				var preview:String; 
				var material:Object;
				if (_preview != "" && _preview != "1") {
					material = App.data.storage[_preview];
				}else {
					material = App.data.storage[sID];
				}
				
				preview = material.preview;
				if(preview.substr(0,4) == 'land')preview = preview + "_small"
				url = Config.getIcon(material.type, preview);
			}
			
			var that:QuestIcon = this;
			
			Load.loading(Config.getQuestIcon('icons', App.data.personages[item.character].preview), function(data:*):void {
				bttn.bitmapData = data.bitmapData;
				bttn.x = (bg.width - bttn.width) / 2;
				bttn.y = (bg.height - bttn.height) / 2;
				
				setCoords();
				
				that.visible = true;
				bttn.visible = true;
				
				Load.loading(url, function(data:*):void {
					materialIcon = new Bitmap(data.bitmapData);
					iconContainer.addChild(materialIcon);
					
					if (materialIcon.height > 40) {
						materialIcon.height = 40;
						materialIcon.scaleX = materialIcon.scaleY;
					}
					if (materialIcon.width > 50) {
						materialIcon.width = 50;
						materialIcon.scaleY = materialIcon.scaleX;
					}
					//materialIcon.scaleX = materialIcon.scaleY = 0.4;
	
					materialIcon.smoothing = true;
					materialIcon.filters = [new GlowFilter(0xffef7e, 1, 4, 4, 8, 1)];
					
					materialIcon.x = 50;
					materialIcon.y = 34;
					
					setCoords();
				});
			});
			
			return bttn;
		}
		
		private function setCoords():void
		{
			if (!bttn) return;
			
			switch(App.data.personages[item.character].ID) {
						
				case 1: // Люмиос
					bttn.x = -4;
					bttn.y = -4;
					bttn.scaleX = bttn.scaleY = .55;
				break;
				case 2: // Марлоу
					bttn.x = 0;
					bttn.y = -21;
					bttn.scaleX = bttn.scaleY = .6;
				break;
				case 3: // Ксандер
					bttn.x = 5;
					bttn.y = -35;
					bttn.scaleX = bttn.scaleY = .55;
				break;
				case 4: // Бронко
					bttn.x = 5;
					bttn.y = -10;
					bttn.scaleX = bttn.scaleY = .55;
				break;
				case 5: // Хастур
					bttn.x = -8;
					bttn.y = -10;
					bttn.scaleX = bttn.scaleY = .55;
				case 6: // Присцилла
					bttn.x = -10;
					bttn.y = -25;
					bttn.scaleX = bttn.scaleY = .55;
				break;
			}
			bttn.iconBmp.visible = false;
		}
	}
}	