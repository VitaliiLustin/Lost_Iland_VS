package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import core.Log;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.BottomPanel;
	import ui.UserInterface;
	import units.Moneyhouse;
	import wins.elements.SearchFriendsPanel;
	/**
	 * ...
	 * @author 
	 */
	public class AskWindow extends Window
	{
		public static const MODE_ASK:int = 1;
		public static const MODE_INVITE:int = 2;
		public static const MODE_PUT_IN_ROOM:int = 3;
		public static const MODE_INVITE_BEST_FRIEND:int = 4;
		public static const MODE_NOTIFY:int = 5;
		public static const MODE_NOTIFY_2:int = 6;
		
		public var items:Array = [];
		private var seachPanel:SearchFriendsPanel;
		
		public var inviteBttn:Button;
		private var bttnAllFriends:Button;
		private var bttnFriendsInGame:Button;
		
		public var blokedStatus:Boolean = true;
		
		public var mode:int;
		
		private var callBack:Function;
		
		public function AskWindow(mode:int, settings:Object = null, callBack:Function = null)
		{
			this.mode = mode;
			this.callBack = callBack;
			
			if (settings == null) {
				settings = new Object();
			}
			settings['popup'] = true;
			settings['background'] = "storageBackingMain";
			settings["width"] = settings.width || 530;
			settings["height"] = settings.height || 552;
			settings['descY'] = settings.descY || 6;
			settings["title"] = settings.title || Locale.__e("flash:1382952379975");
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = settings.itemsOnPage || 8;
			settings['friendException'] = settings.friendException || null;
			settings["sID"] = settings["sID"] || 2;
			settings.content = [];
			
			if (mode == MODE_NOTIFY || mode == MODE_NOTIFY_2) {
				var dataFriends:Object = App.network.otherFriends;
				if (App.social == "ML")
					dataFriends = App.network.friends;
				for(var item2:* in dataFriends){
					settings.content.push(dataFriends[item2]);
				}
				
				for (var j:int = 0; j < settings.content.length; j++)
				{
					settings.content[j]['order'] = int(Math.random() * settings.content.length);
				}
				settings.content.sortOn('order');
				
				if(mode == MODE_NOTIFY && App.social != "ML"){
					for(var item3:* in App.user.friends.keys){
						//if (App.user.friends.keys[item3].uid && App.user.friends.keys[item3].uid != 1) {
							//if(App.social == 'ML' || (settings.content.indexOf(App.user.friends.keys[item3]) == -1 && !settings.content[item3]))
								settings.content.push(App.user.friends.keys[item3]);
						//}
					}
				}
			}else {
				for(var item:* in App.user.friends.keys){
					if(App.user.friends.keys[item].uid && App.user.friends.keys[item].uid != 1){
						settings.content.push(App.user.friends.keys[item]);
					}
				}
				
				var L:uint = settings.content.length;
				for (var i:int = 0; i < L; i++)
				{
					settings.content[i]['order'] = int(Math.random() * L);
				}
				settings.content.sortOn('order');
			}
			
			
			//var L:uint = settings.content.length;
			//for (var i:int = 0; i < L; i++)
			//{
				//settings.content[i]['order'] = int(Math.random() * L);
			//}
			//settings.content.sortOn('order');
			
		
		//	settings.content = [];	
			super(settings);
		}
		override public function drawBackground():void
		{
			background = Window.backing(settings.width, settings.height, 20, "storageBackingMain");
			
			if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				background.y = (settings.height - background.height) / 2 + 70;
				var inviteBack:Bitmap = new Bitmap(Window.textures.inviteFuryBack);
				layer.addChild(inviteBack);
				inviteBack.x = background.x + (background.width - inviteBack.width) / 2;
				inviteBack.y = background.y - 250;
				
				layer.addChild(background);
				var stripe:Bitmap = Window.backingShort(settings.width + 160, 'questRibbon');
				layer.addChild(stripe);
				stripe.x = background.x + (background.width - stripe.width) / 2;
				stripe.y = background.y - 25;
				
				//titleLabel.y = stripe.y + (stripe.height - titleLabel.height) / 2 - 20;
			}else
				layer.addChild(background);
				
			if (mode == MODE_ASK) {
				seachPanel.x -= 100;
				inviteBttn.x -= 100;
				
			}
		}
		
		
		override public function drawTitle():void
		{
			super.drawTitle();
			if (mode == MODE_INVITE_BEST_FRIEND) {
				titleLabel.visible = false;
				var title:TextField = drawText(settings.title,{
					fontSize:settings.fontSize,
					textAlign:"center",
					color:settings.fontColor,
					borderColor:settings.fontBorderColor
				});
				
				bodyContainer.addChild(title);
				title.width = title.textWidth + 20;
				title.x = 110;
				title.y = 25;
			}
		}
		
		private var bgBig:Bitmap;
		private var background:Bitmap;
		override public function drawBody():void
		{
			exit.y -= 12;
			
			bgBig = Window.backing(settings.width - 60, 300, 20, "storageBackingSmall");
			bgBig.x = (settings.width - bgBig.width) / 2;
			bgBig.y = settings.height - bgBig.height - 95;
			bgBig.alpha = 0.9;
			
			bodyContainer.addChild(bgBig);
			
			if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				bgBig.y = settings.height - bgBig.height - 35;
			}
			
			setPaginatorCount();
			paginator.update();
			//paginator.scaleY = 0.9;
			paginator.y += 40;
			paginator.x -= 30;
			
			if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				paginator.y += 65;
			}
			
			
			if (settings.content.length > 0){
				contentChange();
			}else{
				var inviteText:TextField = drawText(Locale.__e('flash:1382952379976'),{
					fontSize:26,
					textAlign:"center",
					color:0xffffff,
					borderColor:0x794a1f,
					textLeading: 8,
					multiline:true
				});
				
				bodyContainer.addChild(inviteText);
				inviteText.wordWrap = true;
				inviteText.width = settings.width - 140;
				inviteText.height = inviteText.textHeight + 10;
				inviteText.x = (settings.width - inviteText.width) / 2;
				inviteText.y = (settings.height - inviteText.height) / 2 - 30;
			}
			
			seachPanel = new SearchFriendsPanel( {
				win:this,
				callback:refreshContent
			});
			
			bodyContainer.addChild(seachPanel);
			seachPanel.x = 54;
			seachPanel.y = settings.height - seachPanel.height - 40 - bgBig.height;
			
			if (mode == MODE_NOTIFY || MODE_NOTIFY_2) {
				seachPanel.x = (settings.width - seachPanel.width) / 2;
				seachPanel.y -= 65;
			}
			
			if (mode == MODE_INVITE) {
				seachPanel.x = (settings.width - seachPanel.width) / 2 - 100;
				seachPanel.y -= 65;
			}
			
			if (mode == MODE_INVITE_BEST_FRIEND) {
				seachPanel.x = 54;
				seachPanel.y = settings.height - seachPanel.height - 40 - bgBig.height;
			}
			
			if (mode != MODE_INVITE_BEST_FRIEND && mode != MODE_NOTIFY && mode != MODE_NOTIFY_2) {
				
				seachPanel.y = settings.height - seachPanel.height - 100 - bgBig.height;
				
				inviteBttn = new Button({
					caption:settings.inviteTxt,
					width:160,
					height:42,
					fontSize:24,
					hasDotes:false
				});
			
			bodyContainer.addChild(inviteBttn);
			inviteBttn.x = (settings.width - inviteBttn.width) /2;
			inviteBttn.y = settings.height - inviteBttn.height - 145 - bgBig.height;
			inviteBttn.addEventListener(MouseEvent.CLICK, inviteEvent);
			}/*else {
				var bestFFIcon:Bitmap = new Bitmap(UserInterface.textures.bFFBttnIco);
				bestFFIcon.scaleX = bestFFIcon.scaleY = 2;
				bestFFIcon.smoothing = true;
				bodyContainer.addChild(bestFFIcon);
				bestFFIcon.x = settings.width - bestFFIcon.width - 80;
				bestFFIcon.y = settings.height - bestFFIcon.height - 100 - bgBig.height;
			}*/
			
			
			
			ExternalApi.onCloseApiWindow = function():void {
				blokedStatus = true;
				blokItems(blokedStatus);
			}
			
			if(mode == MODE_INVITE){
				bttnFriendsInGame = new Button( {
					width:100,		
					fontSize : 20,
					offset : 20,
					icon : false,
					caption:Locale.__e("flash:1382952380138")
				});
				bodyContainer.addChild(bttnFriendsInGame);
				bttnFriendsInGame.x = 280;
				bttnFriendsInGame.y = 156 - bttnFriendsInGame.height;
				bttnFriendsInGame.addEventListener(MouseEvent.CLICK, onFriendsInGame);
				
				bttnAllFriends = new Button( {
					width:100,		
					fontSize : 20,
					offset : 20,
					icon : false,
					caption:Locale.__e("flash:1382952380139")	
				});
				bodyContainer.addChild(bttnAllFriends);
				bttnAllFriends.x = bttnFriendsInGame.x + bttnFriendsInGame.width + 12;
				bttnAllFriends.y = 156 - bttnAllFriends.height;
				bttnAllFriends.addEventListener(MouseEvent.CLICK, onAllFriends);
				
				bttnFriendsInGame.state = Button.ACTIVE;
			}else {
				if (mode != MODE_INVITE_BEST_FRIEND && mode != MODE_NOTIFY && mode != MODE_NOTIFY_2 && mode != MODE_PUT_IN_ROOM) {
					inviteBttn.x = seachPanel.x + seachPanel.width + 24;
					inviteBttn.y = settings.height - inviteBttn.height - 105 - bgBig.height;
				}
			}
			
			drawDesc();
			if (mode != MODE_INVITE_BEST_FRIEND) {
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
				drawMirrowObjs('storageWoodenDec', +5, settings.width - 5, settings.height - 116);
			}else
				drawMirrowObjs('storageWoodenDec', +5, settings.width - 5, settings.height - 50);
			//drawMirrowObjs('storageWoodenDec', -26, settings.width + 26, 55, false, false, false, 1, -1);
			
			
			if (mode == MODE_INVITE_BEST_FRIEND)
				refreshContent(seachPanel.search("", false));
		}
		
		private function onAllFriends(e:MouseEvent):void 
		{
			if (bttnAllFriends.mode == Button.ACTIVE) return;
			
			bttnFriendsInGame.state = Button.NORMAL;
			bttnAllFriends.state = Button.ACTIVE;
			settings['itemsMode'] = 5;
			refreshContent(seachPanel.search("", false));
		}
		
		private function onFriendsInGame(e:MouseEvent):void 
		{
			if (bttnFriendsInGame.mode == Button.ACTIVE) return;
			
			bttnFriendsInGame.state = Button.ACTIVE;
			bttnAllFriends.state = Button.NORMAL;
			settings['itemsMode'] = 3;
			refreshContent(seachPanel.search("", false));
		}
		
		private function drawDesc():void 
		{
			if (settings.desc) {
				var descFriends:TextField = Window.drawText(settings.desc, {
					fontSize:24,
					color:0xffffff,
					autoSize:"center",
					textAlign:"center",
					borderColor:0x7a4b1f,
					multiline:true
				});
				descFriends.wordWrap = true;
				descFriends.width = settings.width - 80;
				bodyContainer.addChild(descFriends);
				descFriends.x = (settings.width - descFriends.width) / 2;
				descFriends.y = settings.descY;
			}
		}
		
		private function refreshContent(friends:Array = null):void
		{
			if (friends.length == App.user.friends.keys.length) friends = null;
			if (friends == null)
			{
				settings.content = [];
				if (mode == MODE_NOTIFY || mode == MODE_NOTIFY_2)
					settings.content = settings.content.concat(App.network.otherFriends);
				else
					settings.content = settings.content.concat(App.user.friends.keys);
				
				var L:uint = settings.content.length;
				for (var i:int = 0; i < L; i++)
				{
					if (i >= settings.content.length) 
						break
					if (checkExceptain(settings.content[i].uid) || !settings.content[i].uid) {
						settings.content.splice(i, 1); 
						i--;
						
						continue;
					}
					settings.content[i]['order'] = int(Math.random() * L);
				}
				settings.content.sortOn('order');
			}
			else
			{
				settings.content = friends;
				settings.content.sortOn('level');
			}
			
			setPaginatorCount();
			paginator.update();
			contentChange();
		}
		
		private function setPaginatorCount():void
		{
			if (mode == MODE_PUT_IN_ROOM) {
				for (var fr:* in App.user.friends.data) {
					if (App.user.friends.data[fr].settle && App.user.friends.data[fr].settle == 1) {
						for (var i:int = 0; i < settings.content.length; i++ ) {
							if (settings.content[i].uid == fr) {
								settings.content.splice(i, 1);
							}
						}
						continue;
					}
				}
			}
			paginator.itemsCount = settings.content.length;
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = settings.height/2 - paginator.arrowLeft.height
			paginator.arrowLeft.x = -44;
			paginator.arrowLeft.y = y + 70;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 44;
			paginator.arrowRight.y = y + 70;
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
				_item.dispose();
			}
			items = [];
			
			var X:int = 58;
			var Xs:int = 58;
			var Ys:int = bgBig.y + 12;
			if (mode == MODE_INVITE_BEST_FRIEND) 
			{
				X = 47;
				Xs = 47;
				Ys = bgBig.y + 20;
			}
			
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				
				//if (checkExceptain(settings.content[i].uid) || !settings.content[i].uid) continue;
				Log.alert("eeeeeeeeeeeeeeeeee___-=  " + settings.content[i].uid);
				var item:FriendItem = new FriendItem(this, settings.content[i], mode, callBack);
				
				bodyContainer.addChild(item);
				item.x = Xs;
				item.y = Ys;
								
				items.push(item);
				Xs += item.bg.width + 14;
				
				if (mode == MODE_INVITE_BEST_FRIEND) 
				{
					if (itemNum == 4 || itemNum == 9)
					{
						Xs = X;
						Ys += item.bg.height + 50;
					}
				}else 
				{
					if (itemNum == 3 || itemNum == 7)
					{
						Xs = X;
						Ys += item.bg.height + 50;
					}
				}
				
				itemNum++;
			}
			settings.page = paginator.page;
		}
		
		private function checkExceptain(uid:Number):Boolean 
		{
			if (settings.friendException) {
				for (var id:* in settings.friendException) {
					if (settings.friendException[id] == uid) {
						return true;
					}
				}
			}
			return false;
		}
		
		public override function close(e:MouseEvent=null):void 
		{
			if (settings.onClose != null && settings.onClose is Function)
			{
				settings.onClose();
			}
			
			super.close();
		}
		
		private function inviteEvent(e:MouseEvent):void {
			
			if (mode == MODE_ASK || mode == MODE_NOTIFY || mode == MODE_NOTIFY_2) {
				ExternalApi.apiInviteEvent();
			}else{
				if(settings.target)
					WallPost.makePost(WallPost.INSTANCE_INVATE_ALL, { sid:settings.target.sid } ); 
			}
		}
		
		public function blokItems(value:Boolean):void
		{
			var item:*;
			if (value)	for each(item in items) item.state = Window.ENABLED;
			else 		for each(item in items) item.state = Window.DISABLED;
		}
		
		override public function dispose():void {
			ExternalApi.onCloseApiWindow = null
			for each(var item:* in items) {
				item.dispose();
			}
			
			if (inviteBttn) {
				inviteBttn.removeEventListener(MouseEvent.CLICK, inviteEvent);
				inviteBttn.dispose();
				inviteBttn = null;
			}
			if (bttnAllFriends){
				bttnAllFriends.removeEventListener(MouseEvent.CLICK, onAllFriends);
				bttnAllFriends.dispose();
				bttnAllFriends = null;
			}
			if (bttnFriendsInGame) {
				bttnFriendsInGame.removeEventListener(MouseEvent.CLICK, onFriendsInGame);
				bttnFriendsInGame.dispose();
				bttnFriendsInGame = null;
			}
			
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Log;
import core.AvaLoad;
import core.Load;
import core.Post;
import core.TimeConverter;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.AskWindow;
import wins.Window;

internal class FriendItem extends Sprite
{
	private var window:AskWindow;
	public var bg:Bitmap;
	public var friend:Object;
	
	private var title:TextField;
	private var infoText:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var selectBttn:Button;
	private var data:Object;
	
	private var preloader:Preloader = new Preloader();
	
	public var mode:int;
	
	private var callBack:Function;
	
	public function FriendItem(window:AskWindow, data:Object, mode:int, callBack:Function = null)
	{
		this.data = data;
		
		
		if (window.mode == AskWindow.MODE_NOTIFY || window.mode == AskWindow.MODE_NOTIFY_2) {
			this.friend = data;
			if (App.user.friends.data[data.uid]) 
				this.friend = App.user.friends.data[data.uid];
		}
		else {
			this.friend = App.user.friends.data[data.uid];
		}
			
			
		
		this.window = window;
		this.mode = mode;
		this.callBack = callBack;
		
		bg = new Bitmap(Window.textures.persIcon);
		addChild(bg);
		addChild(sprite);
		sprite.addChild(avatar);
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2;
		
		if (friend.first_name != null) {
			drawAvatar();
		}else {
			App.self.setOnTimer(checkOnLoad);
		}
		
		var txtBttn:String;
		switch(mode) {
			case AskWindow.MODE_ASK:
				txtBttn = Locale.__e("flash:1382952379978");
			break;
			case AskWindow.MODE_INVITE:
				//txtBttn = Locale.__e("flash:1382952380197");
				txtBttn = Locale.__e("flash:1382952380230");
			break;
			case AskWindow.MODE_PUT_IN_ROOM:
				txtBttn = Locale.__e("flash:1393580021031");
			break;
			case AskWindow.MODE_INVITE_BEST_FRIEND:
				txtBttn = Locale.__e("flash:1382952380230");
			break;
			case AskWindow.MODE_NOTIFY_2:
			case AskWindow.MODE_NOTIFY:
				txtBttn = Locale.__e("flash:1382952380230");
			break;
		}
		selectBttn = new Button({
			caption		:txtBttn,
			fontSize	:20,
			width		:bg.width,
			height		:36,	
			onMouseDown	:onSelectClick
		});
		addChild(selectBttn);		
		selectBttn.x = (bg.width - selectBttn.width) / 2;
		selectBttn.y = bg.height - 4;// - selectBttn.height;
		
		if(!window.blokedStatus)
			selectBttn.state = Button.DISABLED;
	}
	
	private function drawAvatar():void 
	{
		title = Window.drawText(friend.first_name.substr(0,15), App.self.userNameSettings({
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0,
			textAlign:'center'
		}));
		
		addChild(title);
		title.width = bg.width + 10;
		title.x = (bg.width - title.width) / 2;
		title.y = -5;
		
		new AvaLoad(friend.photo, onLoad);
	}
	
	private function checkOnLoad():void {
		if (friend && friend.first_name != null) {
			App.self.setOffTimer(checkOnLoad);
			drawAvatar();
		}
	}
	
	public function set state(value:int):void {
		selectBttn.state = value;
	}
	
	private function onSelectClick(e:MouseEvent):void
	{
		window.blokedStatus = false
		
		switch(mode){
			case AskWindow.MODE_ASK:
				var index:int = window.settings.content.indexOf(data);
				if (index != -1) {
					window.settings.content.splice(index, 1);
					window.paginator.itemsCount--;
					window.paginator.update();
					window.contentChange();
					
					if (window.paginator.itemsCount == 0) {
						window.close();
					}
					
					Gifts.ask(window.settings['sID'], data.uid);
				}
			break;
			case AskWindow.MODE_INVITE:
				if(window.settings.target)
					WallPost.makePost(WallPost.INSTANCE_INVATE, {sid:window.settings.target.sid, uid:data.uid}); 
			break;
			case AskWindow.MODE_PUT_IN_ROOM:
				if (callBack != null) 
					callBack(friend.uid);
				window.close();
			break;
			case AskWindow.MODE_INVITE_BEST_FRIEND:
				if (callBack != null) 
					callBack(friend.uid);
				window.close();
			break;
			case AskWindow.MODE_NOTIFY_2:
			case AskWindow.MODE_NOTIFY:
				if (callBack != null) 
					callBack(friend.uid);
					
				Post.send( {
					ctr:'user',
					act:'setinvite',
					uID:App.user.id,
					fID:friend.uid
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
				});
				window.close();
			break;
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
		callBack = null;
		App.self.setOffTimer(checkOnLoad);
		selectBttn.dispose();
	}
}