package ui
{
	import buttons.ImagesButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	import wins.WindowEvent;
	import core.Debug;
	
	
	public class QuestPanel extends Sprite
	{
		public static const PROGRESS:uint = 1;
		public static const NEW:uint = 2;
		
		public var questsList:Array = [];
		public var icons:Array = [];
		public var paginator:QuestPaginator;
		public var showNewMode:Boolean = false
		public static var newQuests:Object = {};
		public static var progressQuest:uint = 0;
		public var _parent:LeftPanel;
		
		public function QuestPanel(parent:LeftPanel) {
			_parent = parent;
			paginator = new QuestPaginator(App.user.quests.opened, 4, this);
			addChild(container);
			paginator.drawArrows();
			resize();
			
			
		}
		
		public function clearIconsGlow():void {
			for (var i:int = 0; i < icons.length; i++){
				icons[i].bttn.hideGlowing();
				icons[i].bttn.hidePointing();
			}	
		}
		
		public function refresh():void {
			
			var newQuests:Array = [];
			for each(var item:* in App.user.quests.opened) {
				if (item.fresh) {
					QuestPanel.newQuests[item.id] = App.time + 10;
					newQuests.push(item.id);
				}
			}
			
			if (newQuests.length > 0) {
				focusedOnQuest(newQuests[0]);
				return;
			}
			change();// paginator.startItem, paginator.endItem);
		}
		
		public function focusedOnQuest(qID:uint, type:uint = 0):void
		{
			if (type == PROGRESS) {
				progressQuest = qID;
			}
			
			for (var i:int = 0; i < App.user.quests.opened.length; i++) {
				if (App.user.quests.opened[i].id == qID){
						paginator.focusedOn(i);
					break;
				}
			}
		}
		public var dY:int = 240;//540;
		public var prevY:int = 0;
		private var container:Sprite = new Sprite();
		public function resize():void {
			trace(App.self.stage.stageWidth,App.self.stage.stageHeight);
			
			var delta:uint = 100;
			if (App.self.stage.stageWidth > 935)
				delta = 70;
			
			//this.y = _parent.promoPanel.y + _parent.promoIcons.length * LeftPanel.iconHeight - 5;
			//if (_parent.promoIcons.length == 0) {
				//this.y = 0;
			//}else {
				//this.y = _parent.promoIcons.length * LeftPanel.iconHeight - 5 - 100;
			//}
			
			this.y = -120+20;
			
			var newHeight:uint = App.self.stage.stageHeight - dY - delta + 30 - 10;// - 20;
			paginator.resize(newHeight);
		}
		
		private var countDoChange:int = 0;
		public function change():void {
			
			removeIcons();
			//Debug.log(startID + " - " + endID);
			var itemNum:int = 0;
			var padding:int = 8;
			prevY = 0;
			
			container.y = dY;
			
			for (var i:int = paginator.startItem; i < paginator.endItem; i++) {
				
				var item:Object = App.user.quests.opened[i];
				if (item == null) continue;
				if (App.data.quests[item.id].type == 1) continue;// сообщение
				
				var icon:QuestIcon = new QuestIcon(item);
				
				icons.push(icon);
				
				container.addChildAt(icon, 0);
				icon.x =  46 - icon.bg.width/2;
				
				//if (itemNum == 0) icon.y = icon.bg.height - icon.height;
				/*else*/ icon.y = prevY;// + (icon.bg.height + padding);// - icon.height; 
				
				itemNum ++;
				//prevY = icon.y + icon.bg.height;
				prevY += icon.bg.height + padding;
			}
		}
		
		private function removeIcons():void {
			for each(var icon:QuestIcon in icons) {
				icon.clear();
				//removeChild(icon);
				container.removeChild(icon);
				icon = null;
			}
			
			icons = [];
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

internal class QuestPaginator extends Sprite{
	
	public var startItem:uint = 0;
	public var endItem:uint = 0;
	public var length:uint = 0;
	public var itemsOnPage:uint = 0;
	
	public var _parent:*;
	public var data:Array;
	
	public function QuestPaginator(data:Array, itemsOnPage:uint, _parent:*) {
		
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
			change();
		}
	}
	
	public function down(e:* = null):void {
		startItem ++;
		endItem = startItem + itemsOnPage;
		//if (endItem > App.user.quests.opened.length) 
		//	endItem = App.user.quests.opened.length;
			
		change();
	}
	
	public function change():void {
		
		length = App.user.quests.opened.length
		
		if (startItem == 0){
			arrowUp.visible = false;
		}else{
			arrowUp.visible = true;
		}	
		
		if(startItem + itemsOnPage >= length)
			arrowDown.visible = false;
		else
			arrowDown.visible = true;
		
		_parent.change();
	}
	
	public var arrowUp:ImageButton;
	public var arrowDown:ImageButton;
	
	public function drawArrows():void
	{
		if (arrowUp == null && arrowDown == null)
		{
			arrowUp = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:1, sound:'arrow_bttn'});
			arrowDown = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:-1, sound:'arrow_bttn'});
			
			_parent.addChild(arrowUp);
			arrowUp.x = 28;
			
			_parent.addChild(arrowDown);
			arrowDown.x = 28;
			
			arrowUp.addEventListener(MouseEvent.CLICK, up);
			arrowDown.addEventListener(MouseEvent.CLICK, down);
		}
		
		setArrowsPosition();
	}
	
	public function focusedOn(id:uint):void {
		
		//Debug.log('focusedOn : '+id)
		startItem = id;
		endItem = startItem + itemsOnPage;
		if (endItem > App.user.quests.opened.length) {
			endItem = App.user.quests.opened.length;
			if (endItem - itemsOnPage < 0)
				startItem = 0;
			else
				startItem = endItem - itemsOnPage;
		}
		change();
	}
	
	public function resize(_height:uint):void {
		itemsOnPage = Math.floor(_height / 70)//QuestIcon.HEIGHT);
		startItem = 0;
		endItem = startItem + itemsOnPage;
		setArrowsPosition();
		change();
	}
	
	public function setArrowsPosition():void {
		arrowUp.y 	= _parent.dY - 40;
		arrowDown.y = arrowUp.y + (itemsOnPage + 1) * 70 + 20;
		trace();
	}
}