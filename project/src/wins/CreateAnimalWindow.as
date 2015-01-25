package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.EnergyButton;
	import buttons.ImageButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import ui.UserInterface;
	import units.Animal;
	import units.Unit;
	import wins.elements.Bar;

	public class CreateAnimalWindow extends Window
	{
		public var items:Array = new Array();
		public var friends:Object = { };
		public var handler:Function; 
		private var leftPanel:Bitmap;
		private var rightPanel:Bitmap
		private var animal:Object;
		public var energyBttn:EnergyButton;
		public var createBttn:Button;
		public var anotherBttn:Button;
		public var animalEnergy:Bar;
		public var userEnergy:Bar;
		public var energyBefore:int;
		
		public function CreateAnimalWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 760;
			settings['height'] 			= 620;
			settings['sID'] 			= settings.sID || 0;
			settings['sphere'] 			= settings.sphere || null;
			settings['title'] 			= Locale.__e("flash:1382952380029");
			settings['hasPaginator'] 	= true;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 9;
			settings['content'] 		= App.user.friends.keys;
			
			super(settings);
			
			App.self.addEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
		}
		
		override public function dispose():void {
			App.self.removeEventListener(AppEvent.ON_AFTER_PACK, updateEvent);
			
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i] != null)
				{
				items[i].dispose();
				items[i] = null;
				}
			}
			super.dispose();
		}
		
		public function drawDescription():void {
			
			var selfLabel:TextField = drawText(Locale.__e("flash:1382952380030"), {
				fontSize:22,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0x5a524c,
				borderColor:0xfaf1df
			});
			selfLabel.x = rightPanel.x + (rightPanel.width - selfLabel.width) / 2;
			selfLabel.y = 30;
						
			selfLabel.width = settings.width - 80;
			
			bodyContainer.addChild(selfLabel);
			
			
			var friendsLabel:TextField = drawText(Locale.__e("flash:1382952380031"), {
				fontSize:22,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0x5a524c,
				borderColor:0xfaf1df
			});
			friendsLabel.x = rightPanel.x + (rightPanel.width - friendsLabel.width) / 2;
			friendsLabel.y = 160;
						
			friendsLabel.width = settings.width - 80;
			
			bodyContainer.addChild(friendsLabel);
			
			
			/*var animalLabel:TextField = drawText(App.data.storage[settings.sID].description, {
				fontSize:20,
				textAlign:"center",
				multiline:true,
				color:0x502f06,
				borderColor:0xf8f2e0
			});
			animalLabel.wordWrap = true;
			animalLabel.width = 160;
			animalLabel.height = animalLabel.textHeight+10;
			animalLabel.x = 70;
			animalLabel.y = 310;
			
			bodyContainer.addChild(animalLabel);*/
			
			drawAnimalDescription();
		}
		
		private function drawAnimalDescription():void
		{
			var deltaY:int = 250;//310
			
			var leftFormat:Object = new Object();
				leftFormat.fontSize = 18;
				leftFormat.color = 0x5a524c;
				leftFormat.borderColor = 0xf8f2e0;
				leftFormat.textAlign = 'left';
			
			var rightFormat:Object = new Object()
				rightFormat.fontSize = 21;
				rightFormat.color = 0x502f06;
				rightFormat.borderColor = 0xf8f2e0;
				rightFormat.textAlign = 'left';
			
			var text:String = TimeConverter.timeToCuts(App.data.storage[settings.sID].jobtime);
			var jobTimeLabel_L:TextField = drawText(Locale.__e("flash:1382952380032"), leftFormat);
			var jobTimeLabel_R:TextField = drawText(text,rightFormat);
			
			jobTimeLabel_L.width = jobTimeLabel_L.textWidth + 5;
			jobTimeLabel_L.height = jobTimeLabel_L.textHeight;
			jobTimeLabel_R.height = jobTimeLabel_R.textHeight;
			
			jobTimeLabel_L.x = 130 - jobTimeLabel_L.width / 2;
			jobTimeLabel_R.x = jobTimeLabel_L.x + jobTimeLabel_L.width + 5;
			jobTimeLabel_L.y = jobTimeLabel_R.y = deltaY;
			
			bodyContainer.addChild(jobTimeLabel_L);
			bodyContainer.addChild(jobTimeLabel_R);
			
			text = TimeConverter.timeToCuts(App.data.storage[settings.sID].time);
			var timeLabel_L:TextField = drawText(Locale.__e("flash:1382952380033"), leftFormat);			
			var timeLabel_R:TextField = drawText(text, rightFormat);			
			
			timeLabel_L.width = timeLabel_L.textWidth + 5;
			timeLabel_L.height = timeLabel_L.textHeight;
			timeLabel_R.height = timeLabel_R.textHeight;
			
			timeLabel_L.x = 130 - timeLabel_L.width / 2;
			timeLabel_R.x = timeLabel_L.x + timeLabel_L.width + 5;
			timeLabel_L.y = timeLabel_R.y = deltaY + 25;
			
			bodyContainer.addChild(timeLabel_L);
			bodyContainer.addChild(timeLabel_R);
			
			var out:Object = App.data.storage[App.data.storage[settings.sID].out];
			text = out.title;
			var materialLabel_L:TextField = drawText(Locale.__e("flash:1382952380034"), leftFormat);			
			var materialLabel_R:TextField = drawText(text, rightFormat);			
			materialLabel_R.wordWrap = true;
			
			materialLabel_L.width = materialLabel_L.textWidth + 5;
			materialLabel_L.height = materialLabel_L.textHeight;
			materialLabel_R.height = materialLabel_R.textHeight + 20;
			
			materialLabel_L.x = 130 - materialLabel_L.width / 2;
			materialLabel_R.x = materialLabel_L.x + materialLabel_L.width + 5;
			materialLabel_L.y = materialLabel_R.y = deltaY + 50;
			
			var icon:Bitmap = new Bitmap();
			bodyContainer.addChild(icon);
			
			bodyContainer.addChild(materialLabel_L);
			bodyContainer.addChild(materialLabel_R);
			
			
			Load.loading(Config.getIcon(out.type, out.preview), function(data:Bitmap):void
			{
				icon.bitmapData = data.bitmapData;
				icon.scaleX = icon.scaleY = 0.7;
				icon.smoothing = true;
				icon.x = 150 - icon.width / 2;
				icon.y = deltaY + 105 - icon.height / 2;
			});
			
		}
		
		override public function drawBody():void {
			drawPanels();
			drawButtons();
			drawDescription();
			contentChange();
		}
		
		public function updateEvent(e:AppEvent):void {
			
			userEnergy.have += App.user.stock.count(Stock.FANTASY) - energyBefore;
			userEnergy.counter = String(userEnergy.have);
			energyBefore = App.user.stock.count(Stock.FANTASY);
		}
		
		private var ava:FriendItem;
		public function drawPanels():void {
			
			animal = App.data.storage[settings.sID];
			
			leftPanel = Window.backing(200, settings.height - 120);
			leftPanel.x = 50;
			leftPanel.y = 30;
			bodyContainer.addChild(leftPanel);
			
			rightPanel = Window.backing(settings.width - leftPanel.width - 150, 340);
			rightPanel.x = leftPanel.x + leftPanel.width + 30;
			rightPanel.y = 190;
			bodyContainer.addChild(rightPanel);
			
			var iconBg:Bitmap = Window.backing(180, 180, 10, "itemBacking");
			iconBg.x = 60;
			iconBg.y = 50;
			bodyContainer.addChild(iconBg);
			
			var icon:Bitmap = new Bitmap(null, "auto", true);
			bodyContainer.addChild(icon);
			
			Load.loading(Config.getIcon(animal.type, animal.view), function(data:*):void {
				icon.bitmapData = data.bitmapData;
				icon.x = iconBg.x + (iconBg.width - icon.width) / 2;
				icon.y = iconBg.y + (iconBg.height - icon.height) / 2;
			});
			
			var title:TextField = Window.drawText(App.data.storage[settings.sID].title, {
				fontSize:24,
				color:0x502f06,
				borderColor:0xf8f2e0,
				textAlign:"center",
				multiline:true
			});
			title.wordWrap = true;
			title.width = iconBg.width - 30;
			title.height = title.textHeight;
			bodyContainer.addChild(title);		
			title.x = iconBg.x + 15;
			title.y = iconBg.y - 5;
			
			
			ava = new FriendItem(this, App.user.id, true);
			ava.x = leftPanel.x + leftPanel.width + 120;
			ava.y = 60;
			bodyContainer.addChild(ava);
			
			energyBttn = new EnergyButton( { caption:Locale.__e("flash:1382952380035") } );
			energyBttn.name = "UserEnergyBttn";
			energyBttn.x = ava.x + 124;
			energyBttn.y = ava.y + (100 - energyBttn.height) / 2 + 20;
			bodyContainer.addChild(energyBttn);
			
			energyBttn.addEventListener(MouseEvent.CLICK, onTakeEnergy);
			
			animalEnergy = new Bar(String(settings.sphere.energy) + ' / ' + animal.energy, settings.sphere.energy, animal.energy);	
			animalEnergy.x = iconBg.x + (iconBg.width - animalEnergy.width) / 2 + 22; 
			animalEnergy.y = iconBg.y + iconBg.height - 20;
		
			bodyContainer.addChild(animalEnergy);
			
			var maxEnergy:int = App.data.levels[App.user.level].energy;
			var energy:int = App.user.stock.count(Stock.FANTASY);
			
			//Запоминаем начальное значение энергии
			energyBefore = energy;
			
			//if (energy > maxEnergy) {
			//	energy = maxEnergy;
			//}
			
			userEnergy = new Bar(String(energy), energy, maxEnergy);	
			userEnergy.x = ava.x + 120;
			userEnergy.y = ava.y + (100 - energyBttn.height) / 2 - 16;
		
			bodyContainer.addChild(userEnergy);
		}
		
		private function drawButtons():void {
			createBttn = new Button( {
				caption:Locale.__e("flash:1382952380036"),
				fontSize:26,
				width:160,
				height:40
			});
			
			bodyContainer.addChild(createBttn);
			createBttn.x = 68;
			createBttn.y = 415;
			
			if (animalEnergy.have < animalEnergy.all) {
				createBttn.state = Button.DISABLED;
			}
			
			createBttn.addEventListener(MouseEvent.CLICK, onCreateEvent);
			
			createBttn.tip = function():Object {return {text:Locale.__e("flash:1382952380037")};}
			
			anotherBttn = new Button( {
				caption:				Locale.__e("flash:1382952380038"),
				multiline:				true,
				fontSize:				17,
				height:					40,
				width:					130,
				borderColor:			[0x9f9171,0x9f9171],
				fontColor:				0x4c4404,
				fontBorderColor:		0xefe7d4,
				textLeading:			-6,
				bgColor:				[0xe3d5b5,0xc0b292]
			});
			
			bodyContainer.addChild(anotherBttn);
			anotherBttn.x = 83;
			anotherBttn.y = leftPanel.y + leftPanel.height - 60;
			anotherBttn.addEventListener(MouseEvent.CLICK, onAnotherEvent);
		
		}
		
		
		private function onCreateEvent(e:MouseEvent):void {
			if (createBttn.mode == Button.DISABLED) {
				App.ui.flashGlowing(animalEnergy, 0xd20707);
				return;
			}
			
			//Пытаемся отнять у пользователя энергию
			var canTakeEnergy:int = energyBefore - userEnergy.have;
				
			var ids:Array = [];
			for (var ID:* in friends) {
				if(friends[ID].used){
					ids.push(ID);
				}
			}
			
			if (App.user.stock.check(Stock.FANTASY, canTakeEnergy)) {
				for each(ID in ids) {
					canTakeEnergy += App.data.options['FriendEnergyAnimal'];
				}
				var needEnergy:int = App.data.storage[settings.sID].energy;
				if (canTakeEnergy >= needEnergy) {
					App.user.stock.take(Stock.FANTASY, energyBefore - userEnergy.have);
					for each(ID in ids) {
						App.user.friends.updateOne(ID, 'animal', friends[ID].time);
					}
				}else {
					//TODO показываем окно об ошибке
					close();
				}

			}
			
			createBttn.state = Button.DISABLED;
			close();
			//settings.sphere.remove(function():void {

				//Делаем push в _6e
				//if (App.social == 'FB') {
					//var animalView:String = App.data.storage[settings.sID].view;
					//ExternalApi._6epush([ "_event", { "event": "gain", "item": animalView } ]);
				//}
			
				var unit:* = Unit.add( { sid:settings.sID, x:settings.sphere.coords.x, z:settings.sphere.coords.z } );				

				unit.create( {
					energy:energyBefore - userEnergy.have,
					friends:ids,
					sphere:settings.sphere
				});
				
				settings.sphere.uninstall();
			//});
		}
		
		private function onAnotherEvent(e:MouseEvent):void {
			close();
			settings.sphere.animal = 0;
			settings.sphere.click();
		}
		
		
		private function onTakeEnergy(e:MouseEvent):void {
						
			if (animalEnergy.have >= animalEnergy.all) {
				return;
			}
			
			if (userEnergy.have > 0) {
				
				var energyIcon:Bitmap	= new Bitmap(UserInterface.textures.energyIcon);
				energyIcon.scaleX = energyIcon.scaleY = 0.7;
				energyIcon.x = userEnergy.point.x;
				energyIcon.y = userEnergy.point.y;
				bodyContainer.addChild(energyIcon);
				
				userEnergy.have--;
				userEnergy.counter = String(userEnergy.have);
				
				animalEnergy.have++;
				animalEnergy.counter = (animalEnergy.have) + ' / ' + animalEnergy.all;
				
				if (animalEnergy.have >= animalEnergy.all) {
					animalEnergy.have = animalEnergy.all;
					createBttn.state = Button.NORMAL;
					App.ui.flashGlowing(createBttn);
				}
			
				TweenLite.to(energyIcon, 0.8, { x:animalEnergy.x-2, y:animalEnergy.y-5, onComplete:function():void {
					bodyContainer.removeChild(energyIcon);
					energyIcon = null;
					animalEnergy.glowing();
					
				}});
			}else {
				new PurchaseWindow( {
					content:PurchaseWindow.createContent("Energy", {view:'Energy'}),
					title:Locale.__e("flash:1382952379756"),
					popup:true,
					description:Locale.__e("flash:1382952379757"),
					width:716,
					itemsOnPage:4
				}).show();
			}
			
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowLeft.x = rightPanel.x - paginator.arrowLeft.width / 2;
			paginator.arrowRight.x = rightPanel.x + rightPanel.width - paginator.arrowLeft.width / 2;
			
			paginator.arrowLeft.y = rightPanel.y + rightPanel.height / 2 - 32;
			paginator.arrowRight.y = paginator.arrowLeft.y;
			
			if (settings.content.length == 0) {
				paginator.arrowLeft.visible = false;
				paginator.arrowRight.visible = false;
			}
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var Xs:int = rightPanel.x + 30;
			var Ys:int = rightPanel.y + 10;
			
			var itemNum:int = 0;
			
			if (settings.content.length > 0){
				for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
					
					var item:FriendItem = new FriendItem(this, settings.content[i]);
					
					bodyContainer.addChild(item);
					item.x = Xs;
					item.y = Ys;
									
					items.push(item);
					Xs += item.bg.width + 25;
					
					
					if (itemNum == 2 || itemNum == 5)
					{
						Xs = rightPanel.x + 30;
						Ys += item.bg.height + 10;
					}
					itemNum++;
				}
				
				settings.page = paginator.page;
			}
			//sections[settings.section].page = paginator.page;
			
		}
		
	}

}

import buttons.Button;
import buttons.EnergyButton;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.AvaLoad;
import core.Load;
import core.Log;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.CreateAnimalWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:CreateAnimalWindow;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField
	private var infoText:TextField
	private var sprite:LayerX = new LayerX();
	private var avatar:Bitmap = new Bitmap();
	public var selectBttn:EnergyButton;
	public var _animal:uint = 0;
	
	public var friendEnergy:int = App.data.options['FriendEnergyAnimal'] || 5;
	public var restoreTime:int = App.data.options['TimeEnergyAnimal'] || 7200;
	
	public var used:Boolean = false;
	
	public function FriendItem(window:CreateAnimalWindow, data:Object, self:Boolean = false)
	{
		this.window = window;
		
		if (self) {
			this.friend = App.user;
			bg = Window.backing(100, 100, 10, "textBacking");
		}else {
			this.friend = App.user.friends.data[data.uid];
			bg = Window.backing(100, 100, 10, "bonusBacking");
		}
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		sprite.tip = function():Object
		{
			var text:String;
			
			if (_animal)
				text = Locale.__e("flash:1382952380039")
			else
				text= Locale.__e("flash:1382952380040")
			
			return {
				text:text
			}
		}
		
		title = Window.drawText(!self?(friend.first_name || 'John Doe'):Locale.__e("flash:1382952380041") , {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:"center"
		});
		
		addChild(title);		
		title.width = bg.width;
		title.height = title.textHeight;
		title.x = 0;
		title.y = -5;
		
		
		//Load.loading(friend.photo, onLoad);
		new AvaLoad(friend.photo, onLoad);
		
		selectBttn = new EnergyButton({
			caption		:Locale.__e("+"+friendEnergy),
			width: 76,
			height: 32,
			fontSize:22//,
			//onClick:onSelectClick
		});
		selectBttn.addEventListener(MouseEvent.CLICK, onSelectClick);
		selectBttn.name = "EnergyFriendBttn";
		
		if(!self){
			addChild(selectBttn);		
		}
		selectBttn.x = (bg.width - selectBttn.width) / 2;
		selectBttn.y = bg.height - selectBttn.height + 10;
		
		infoText = Window.drawText("",{
			fontSize:20,
			color:0x898989,//0x502f06,
			borderColor:0xf8f2e0
		});
		
		addChild(infoText);		
		infoText.x = (bg.width - infoText.textWidth) / 2
		infoText.y = bg.height - infoText.textHeight - 5;	
		
		if(!self){
			if (window.friends[friend.uid] == undefined) {
						
				if (!friend.hasOwnProperty("animal")){
					animal = 0;
				}else{
					animal = friend.animal + restoreTime < App.time ? 0 : friend.animal;
				}
			}else {
				animal = window.friends[friend.uid].time;
			}
		}
	}
	
	private function onSelectClick(e:MouseEvent):void
	{
		if (window.animalEnergy.have >= window.animalEnergy.all) {
			return;
		}
		
		animal = App.time;
		window.friends[friend.uid] = {time:_animal, used:true};
		
					
		var energyIcon:Bitmap	= new Bitmap(UserInterface.textures.energyIcon);
		energyIcon.scaleX = energyIcon.scaleY = 0.7;
		var p:Point = new Point(window.bodyContainer.mouseX, window.bodyContainer.mouseY);
		energyIcon.x = p.x;
		energyIcon.y = p.y;
		window.bodyContainer.addChild(energyIcon);
		
		var have:int = window.animalEnergy.have += friendEnergy;
		if (window.animalEnergy.have >= window.animalEnergy.all) {
			window.animalEnergy.have = window.animalEnergy.all;
			window.createBttn.state = Button.NORMAL;
			App.ui.flashGlowing(window.createBttn);
		}
		window.animalEnergy.counter = have + ' / ' + window.animalEnergy.all;
	
		TweenLite.to(energyIcon, 0.8, { x:window.animalEnergy.x-2, y:window.animalEnergy.y-5, onComplete:function():void {
			window.bodyContainer.removeChild(energyIcon);
			energyIcon = null;
			window.animalEnergy.glowing();
		}});
		
		//window.settings.onSelectFriend(friend);
		//window.settings.onClose = null;
		//window.close();
	}
	
	public function set animal(value:uint):void
	{
		_animal = value;
		if (window.friends[friend.uid] != undefined && window.friends[friend.uid]['used'] != undefined) {
			
		}else{
			window.friends[friend.uid] = { time:_animal, used:false };
		}
		
		if (_animal != 0){
			selectBttn.visible = false;
			infoText.visible = true;
			onTimerEvent();
			App.self.setOnTimer(onTimerEvent);
		}
		else
		{
			selectBttn.visible = true;
			infoText.visible = false;
		}
	}
	
	private function onTimerEvent():void {
		infoText.text = TimeConverter.timeToStr(_animal + restoreTime - App.time);
		infoText.x = 20
		infoText.y = bg.height - infoText.textHeight - 5;	
	}
	
	private function onLoad(data:*):void {
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
				
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 50, 50, 12, 12);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		
		var scale:Number = 1.5;
		
		sprite.width *= scale;
		sprite.height *= scale;
		
		sprite.x = (bg.width - sprite.width) / 2;
		sprite.y = (bg.height - sprite.height) / 2;
	}
	
	public function dispose():void
	{
		selectBttn.removeEventListener(MouseEvent.CLICK, onSelectClick);
		App.self.setOffTimer(onTimerEvent);
		selectBttn.dispose();
	}
}

