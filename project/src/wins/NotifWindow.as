package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.elements.SearchFriendsPanel;
	/**
	 * ...
	 * @author 
	 */
	public class NotifWindow extends Window
	{
		public var items:Array = [];
		private var seachPanel:SearchFriendsPanel;
		
		public var inviteBttn:Button;
		
		public function NotifWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['popup'] = true;
			
			settings["width"] = 600;
			settings["height"] = 530;
			settings["title"] = Locale.__e("flash:1382952380229");
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 12;
			
			settings.content = [];
			for(var item:* in App.user.friends.keys){
				if(App.user.friends.keys[item].uid != 1){
					settings.content.push(App.user.friends.keys[item]);
				}
			}
			
			var L:uint = settings.content.length;
			for (var i:int = 0; i < L; i++)
			{
				settings.content[i]['order'] = int(Math.random() * L);
			}
			settings.content.sortOn('order');
				
			super(settings);
		}
		
		override public function drawBody():void
		{
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			if (settings.content.length > 0){
				contentChange();
			}else{
				var inviteText:TextField = drawText(Locale.__e('flash:1382952379976'),{
					fontSize:22,
					textAlign:"center",
					color:0xffffff,
					borderColor:0x794a1f,
					textLeading: -3,
					multiline:true
				});
				
				bodyContainer.addChild(inviteText);
				inviteText.wordWrap = true;
				inviteText.width = settings.width - 140;
				inviteText.height = inviteText.textHeight + 10;
				inviteText.x = (settings.width - inviteText.width) / 2;
				inviteText.y = (settings.height - inviteText.height) / 2 - 10;
			}	
			
			seachPanel = new SearchFriendsPanel( {
				win:this,
				callback:refreshContent
			});
			
			bodyContainer.addChild(seachPanel);
			seachPanel.x = 50;
			seachPanel.y = 40;
			
			inviteBttn = new Button( {
				caption:Locale.__e("flash:1382952379977"),
				width:160,
				height:30,
				fontSize:24
			});
			
			bodyContainer.addChild(inviteBttn);
			inviteBttn.x = (settings.width - inviteBttn.width) - 90;
			inviteBttn.y = 42;
			inviteBttn.addEventListener(MouseEvent.CLICK, inviteEvent);
		}
		
		private function refreshContent(friends:Array = null):void
		{
			if (friends.length == App.user.friends.keys.length) friends = null;
			if (friends == null)
			{
				settings.content = [];
				settings.content = settings.content.concat(App.user.friends.keys);
				
				var L:uint = settings.content.length;
				for (var i:int = 0; i < L; i++)
				{
					settings.content[i]['order'] = int(Math.random() * L);
				}
				settings.content.sortOn('order');
			}
			else
			{
				settings.content = friends;
				settings.content.sortOn('level');
			}
			
			paginator.itemsCount = settings.content.length;
			paginator.update();
			
			contentChange();
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = settings.height/2 - paginator.arrowLeft.height
			paginator.arrowLeft.x = 0;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width;
			paginator.arrowRight.y = y;
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			var X:int = 84;
			var Xs:int = 84;
			var Ys:int = 90;
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				
				var item:FriendItem = new FriendItem(this, settings.content[i]);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.bg.width + 10;
				
				
				if (itemNum == 3 || itemNum == 7)
				{
					Xs = X;
					Ys += item.bg.height + 10;
				}
				itemNum++;
			}
			settings.page = paginator.page;
		}
		
		public override function close(e:MouseEvent=null):void 
		{
			if (settings.onClose != null && settings.onClose is Function)
			{
				settings.onClose();
			}
			inviteBttn.removeEventListener(MouseEvent.CLICK, inviteEvent);
			
			super.close();
		}
		
		private function inviteEvent(e:MouseEvent):void {
			ExternalApi.apiInviteEvent();
		}
		
		public function sendNotification():void {
			var text:String = settings.target.getNotification();
		}
	}
}

import api.ExternalApi;
import buttons.Button;
import core.AvaLoad;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.AskWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:*;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var selectBttn:Button;
	private var data:Object;
	
	private var preloader:Preloader = new Preloader();
	
	public function FriendItem(window:*, data:Object)
	{
		this.data = data;
		this.friend = App.user.friends.data[data.uid];
		this.window = window;
		
		bg = Window.backing(100, 100, 10, "bonusBacking");
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		title = Window.drawText(friend.first_name, {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0
		});
		
		addChild(title);		
		title.x = (bg.width - title.textWidth) / 2;
		title.y = -5;
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2;
		//Load.loading(friend.photo, onLoad);
		new AvaLoad(friend.photo, onLoad);
		
		selectBttn = new Button({
			caption		:Locale.__e("flash:1382952380230"),
			fontSize	:18,
			width		:86,
			height		:26,	
			onMouseDown	:onSelectClick
		});
				
		addChild(selectBttn);		
		selectBttn.x = (bg.width - selectBttn.width) / 2;
		selectBttn.y = bg.height - selectBttn.height;
		
	}
	
	private function onSelectClick(e:MouseEvent):void
	{
		var index:int = window.settings.content.indexOf(data);
		if (index != -1) {
			window.settings.content.splice(index, 1);
			window.paginator.itemsCount--;
			window.paginator.update();
			window.contentChange();
			
			window.settings.target.sendInvite(data.uid);
			
			if (window.paginator.itemsCount == 0) {
				window.close();
			}
			
			
		}
	}
		
	private function onLoad(data:*):void {
		removeChild(preloader);
		
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
		selectBttn.dispose();
	}
}