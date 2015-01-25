package wins
{
	import buttons.MenuButton;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class InvitesWindow extends Window
	{		
		public var contentContainer:Sprite = new Sprite();
		public var icons:Array = new Array();
		public var items:Vector.<FriendItem> = new Vector.<FriendItem>();
		public static var history:Object = { section:1, page:0 };
		public var bgDecor:Bitmap;
		
		public function InvitesWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
						
			settings["title"] = Locale.__e("flash:1382952380181");
			
			settings["width"] = 680;
			settings["height"] = 490;
			
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 10;
	
			
			settings['content'] = [];
			
			
			super(settings);
			
		}
		
		public function drawMenu():void {
			
			var menuSettings:Object = {
				1: 	{ order:1,	title:Locale.__e("flash:1382952380189") },
				2: 	{ order:2,	title:Locale.__e("flash:1382952380190") },
				3: 	{ order:3,	title:Locale.__e("flash:1382952380191")},
				4:	{ order:4,	title:Locale.__e("flash:1382952380192")}
			}
			
			var length:int = 0;
			for each(var bttn:Object in menuSettings) {
				length += bttn.title.length;
			}
			
			for (var item:* in menuSettings) {
				var settings:Object = menuSettings[item];
				settings['type'] = item;
				settings['onMouseDown'] = onMenuBttnSelect;
				settings['fontSize'] = 22;
				settings['offset'] = 20;
				icons.push(new MenuButton(settings));
			}
			icons.sortOn("order");
	
			var sprite:Sprite = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < icons.length; i++)
			{
				icons[i].x = offset;
				offset += icons[i].settings.width + 10;
				sprite.addChild(icons[i]);
			}
			bodyContainer.addChild(sprite);
			sprite.x = (this.settings.width - sprite.width) / 2;
			sprite.y = 40;
		}
		
		private function onMenuBttnSelect(e:MouseEvent):void
		{
			e.currentTarget.selected = true;
			history.section = e.currentTarget.type;
			setContentSection(e.currentTarget.type);
		}	
		
		public function setContentSection(section:*, page:Number = -1):Boolean
		{
			for each(var icon:MenuButton in icons) {
				icon.selected = false;
				if (icon.type == section) {
					icon.selected = true;
				}
			}
			
			if (bodyContainer.contains(contentContainer)) {
				bodyContainer.removeChild(contentContainer);
			}
			contentContainer = new Sprite();
			bodyContainer.addChild(contentContainer);
			contentContainer.x = bgDecor.x;
			contentContainer.y = bgDecor.y;
			
			switch(section) {
				case 1: drawRequest(); break;
				case 2: drawInvites(); break;
				case 3: drawNeighbors(); break;
				case 4: drawRandom(); break;
			}
			
			return true;
		}
		
		public function drawRequest():void {
			var content:Array = [];
			for (var fID:String in App.invites.requested) {
				var friend:Object = App.invites.requestedProfiles[fID];
				friend['time'] = App.invites.requested[fID];
				content.push(friend);
			}
			content.sortOn('time', Array.DESCENDING);
			
			tabUpdate(content);
		}
		
		public function drawInvites():void {
			var content:Array = [];
			for (var fID:String in App.invites.invited) {
				var friend:Object = App.invites.invitedProfiles[fID];
				friend['time'] = App.invites.invited[fID];
				content.push(friend);
			}
			content.sortOn('time', Array.DESCENDING);
			
			tabUpdate(content);
		}


		public function drawNeighbors():void {
			var content:Array = [];
			for each(var friend:Object in App.user.friends.data) {
				content.push(friend);
			}
			content.sortOn('uid');
			
			tabUpdate(content);
		}
		
		public function drawRandom():void {
			
			var content:Array = [];
			for each(var friend:Object in App.invites.randomProfiles) {
				if(App.invites.invited[friend.uid] == undefined)
					content.push(friend);
			}
			content.sortOn('uid');
			
			tabUpdate(content);
		}
		
		public function tabUpdate(content:Array):void {
			
			paginator.itemsCount = content.length;
			paginator.update();
						
			var item:FriendItem;
			for each(item in items) {
				item.dispose();
			}
			
			items = new Vector.<FriendItem>();
			
			paginator._buttons[0].visible = true;
			var notice:String;
			
			if (content.length == 0) {
				paginator._buttons[0].visible = false;
				switch(history.section) {
					case 1: notice = Locale.__e('flash:1382952380193'); break;
					case 2: notice = Locale.__e('flash:1382952380194'); break;
					case 3: notice = Locale.__e('flash:1382952380195'); break;
					case 4: notice = Locale.__e('flash:1382952380196'); break;
				}
				var noticeField:TextField = Window.drawText(notice, {
					fontSize:26,
					textAlign:"center",
					autoSize:"left",
					multiple:1,
					color:0xf0e6c1,
					borderColor:0x502f06,
					width:bgDecor.width - 40
				});
				contentContainer.addChild(noticeField);
				noticeField.x = (bgDecor.width - noticeField.width) / 2;
				noticeField.y = (bgDecor.height - noticeField.textHeight) / 2;
			}
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < Math.min(paginator.finishCount,content.length); i++){
				
				item = new FriendItem(content[i], this);
				
				contentContainer.addChild(item);
				item.x = (itemNum % 5) * 110 + 10;
				item.y = (item.height + 19) * int(itemNum / 5) + 20;
				
				items.push(item);
				itemNum++;
			}
			settings.page = paginator.page;
			history.page = settings.page;
		}
		
		override public function drawBody():void {
			bgDecor = Window.backing(settings.width - 120, settings.height - 200, 40, "windowBacking");
			bodyContainer.addChild(bgDecor);
			bgDecor.x = (settings.width - bgDecor.width)/2;
			bgDecor.y = 100;
			
			drawMenu();
			setContentSection(1);
		}
		
		override public function contentChange():void {
			setContentSection(history.section);
		}
		
	}

}

import buttons.Button;
import buttons.ImageButton;
import core.AvaLoad;
import core.Load;
import core.TimeConverter;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.Window;
import wins.InvitesWindow;
import silin.filters.ColorAdjust;

internal class FriendItem extends Sprite
{
	private var window:*;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:LayerX = new LayerX();
	private var avatar:Bitmap = new Bitmap();
	private var inviteBttn:Button;
	private var rejectBttn:ImageButton;
	private var acceptBttn:Button;
	public var waitTime:uint;
	public var leftTime:uint;
	
	public function FriendItem(data:Object, window:*)
	{
		this.friend = data;
		this.window = window;
		
		bg = Window.backing(100, 100, 10, "bonusBacking");
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		title = Window.drawText(friend.first_name, App.self.userNameSettings( {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			width:bg.width - 30
		}));
		
		addChild(title);
		title.x = (bg.width - title.textWidth) / 2 - 10;
		title.y = -5;
		
		//Load.loading(friend.photo, onLoad);
		new AvaLoad(friend.photo, onLoad);
		
		inviteBttn = new Button({
			caption		:Locale.__e("flash:1382952380197"),
			fontSize	:18,
			width		:90,
			height		:26,
			onMouseDown	:onInviteClick
		});
		
		acceptBttn = new Button({
			caption		:Locale.__e("flash:1382952380198"),
			fontSize	:18,
			width		:70,
			height		:26,
			onMouseDown	:onAcceptClick
		});
		
		if(InvitesWindow.history.section == 4){
			title.x = (bg.width - title.textWidth) / 2;
			
			addChild(inviteBttn);
			inviteBttn.x = (bg.width - inviteBttn.width) / 2;
			inviteBttn.y = bg.height - inviteBttn.height + 10;
		}else if (InvitesWindow.history.section == 3) {
			if(friend.uid != '1' && App.network.appFriends != null && App.network.appFriends.indexOf(friend.uid) == -1){
				addRejectBttn();
			}
		}else{
			
			if (InvitesWindow.history.section == 1) {
				addChild(acceptBttn);
				acceptBttn.x = (bg.width - acceptBttn.width) / 2;
				acceptBttn.y = bg.height - 16;
			}
			
			addRejectBttn();
			
			infoText = Window.drawText(TimeConverter.timeToStr(App.time - friend.time), {
				fontSize:16,
				color:0x898989,
				borderColor:0xf8f2e0
			});
			
			addChild(infoText);
			infoText.x = (bg.width - infoText.textWidth) / 2 - 3;
			infoText.y = bg.height - infoText.textHeight - 15;
			
			App.self.setOnTimer(onTimerEvent);
			
			sprite.tip = function():Object {
				return {
					//title: (_hire==0)?Locale.__e("flash:1382952380120"):Locale.__e("flash:1382952380125")
				}
			}
		}
		
	}
	
	
	public function addRejectBttn():void {
		rejectBttn = new ImageButton(Window.textures.closeBttn, { scaleX:0.65, scaleY:0.65 } );
		rejectBttn.x = bg.width - rejectBttn.width / 2 - 10;
		rejectBttn.y = -rejectBttn.height / 2 + 8;
		
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		//mtrx.colorize(0xFF0000,0.6);
		mtrx.brightness(-0.1);
		rejectBttn.bitmap.filters = [mtrx.filter];
		
		
		rejectBttn.addEventListener(MouseEvent.CLICK,onRejectEvent);
		
		addChild(rejectBttn);
	}
	
	private function onRejectEvent(e:MouseEvent):void {
		App.invites.reject(friend.uid, InvitesWindow.history.section, function():void {
			window.contentChange();
		});
	}
	
	private function onTimerEvent():void {
		infoText.text = TimeConverter.timeToStr(App.time - friend.time);
	}
			
	
	private function onInviteClick(e:MouseEvent):void
	{
		App.invites.invite(friend.uid, function():void {
			window.contentChange();
		});
	}
	private function onAcceptClick(e:MouseEvent):void
	{
		App.invites.accept(friend.uid, function():void {
			window.contentChange();
		});
	}
	
	public function set hire(value:uint):void
	{
		
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
		App.self.setOffTimer(onTimerEvent);
		inviteBttn.dispose();
		acceptBttn.dispose();
		if (rejectBttn) {
			rejectBttn.removeEventListener(MouseEvent.CLICK, onRejectEvent);
		}
	}
}