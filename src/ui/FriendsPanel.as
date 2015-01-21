package ui 
{
	/**
	 * ...
	 * @author 
	 */
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.BottomPanel;
	import buttons.ImageButton;
	import wins.ErrorWindow;
	import wins.VisitWindow;
	import wins.Window;
	public class FriendsPanel extends LayerX {
	
		public var friendsItems:Vector.<FriendItem> = new Vector.<FriendItem>();
		private var bottomPanel:BottomPanel;
		private var bg:Bitmap;
		private var friendsCont:Sprite;
		public var opened:Boolean = false;
		private const FREE_FRIEND_CONT:int = 3;
		public var ROW:int = 6;
		
		public var wishList:WishListPopUp = null;
		
		public function FriendsPanel(_parent:*) {
			
			bottomPanel = _parent;
			resize();
			initFriends();
			
			createWishList();
		}
		
		public function createWishList():void
		{
			wishList = new WishListPopUp(this);
			addChild(wishList);
			wishList.x = 52;
			wishList.y = -50;
		}
		
		public function resize():void 
		{
			drawItems();
			showFriends();
		}
		
		private function dispose():void {
			
		}
		
		public var bttnPrev:ImageButton;
		public var bttnPrevSix:ImageButton;
		public var bttnPrevAll:ImageButton;
		public var bttnNext:ImageButton;
		public var bttnNextSix:ImageButton;
		public var bttnNextAll:ImageButton;
		public var exit:ImageButton;
		public var bttnBackPrev:Bitmap;
		public var bttnBackNext:Bitmap;
		
		
		private function drawBttns():void 
		{	
			if (bttnPrev) removeChild(bttnPrev);
			if (bttnPrevAll) removeChild(bttnPrevAll);
			if (bttnNext) removeChild(bttnNext);
			if (bttnNextAll) removeChild(bttnNextAll);
			if (exit) removeChild(exit);
			if (bttnBackNext) removeChild(bttnBackNext);
			if (bttnBackPrev) removeChild(bttnBackPrev);
		
			bttnPrev 		= new ImageButton(UserInterface.textures.friendsBttnOne);
			bttnPrevAll 	= new ImageButton(UserInterface.textures.friendsBttnAll);
			bttnNext 		= new ImageButton(UserInterface.textures.friendsBttnOne, {scaleX:-1});
			bttnNextAll		= new ImageButton(UserInterface.textures.friendsBttnAll, { scaleX: -1 } );
			exit = new ImageButton(UserInterface.textures.closeBttn);
			
			bttnBackPrev = new Bitmap(UserInterface.textures.friendsSearchPanel);
			bttnBackNext = new Bitmap(UserInterface.textures.friendsSearchPanel);
			
			bttnPrev.addEventListener(MouseEvent.CLICK, onPrevEvent);
			bttnPrevAll.addEventListener(MouseEvent.CLICK, onPrevAllEvent);
			bttnNext.addEventListener(MouseEvent.CLICK, onNextEvent);
			bttnNextAll.addEventListener(MouseEvent.CLICK, onNextAllEvent);
			exit.addEventListener(MouseEvent.CLICK, close);
			
			exit.tip = function():Object { 
				return {
					title:Locale.__e('flash:1404381496750'),
					text:Locale.__e("flash:1404381510414")
				};
			};
			
			addChild(bttnBackPrev);
			bttnBackPrev.x = bg.x - 50;
			bttnBackPrev.y = bg.y - 11;

			bttnPrev.x = bttnBackPrev.x + 29;
			bttnPrev.y = bttnBackPrev.y + 20;
			
			bttnPrevAll.x = bttnBackPrev.x + 30;
			bttnPrevAll.y = bttnBackPrev.y + 43;		
			
			
			addChild(bttnBackNext);
			bttnBackNext.x = bg.width + 97;
			bttnBackNext.y = bg.y - 10;
			bttnBackNext.scaleX *= -1;
			
			bttnNext.x = bttnBackNext.x - 45;
			bttnNext.y = bttnBackNext.y + 21;			
			
			bttnNextAll.x = bttnBackNext.x - 49;
			bttnNextAll.y = bttnBackNext.y + 43;					
			
			//exit.x = bttnNextAll.x + bttnNextAll.width/2 - 18;
			//exit.y = -34;
			
			exit.x = bg.x - 30;
			exit.y = bg.y - 37;
			
			addChild(bttnPrev);
			addChild(bttnPrevAll);
			
			addChild(bttnNext);
			addChild(bttnNextAll);
			addChild(exit);
		}
		
		private function onPrevEvent(e:MouseEvent):void {
			showFriends(-1);
		}
		private function onPrevSixEvent(e:MouseEvent):void {
			showFriends(-6);
		}
		private function onPrevAllEvent(e:MouseEvent):void {
			showFriends(-App.user.friends.keys.length);
		}
		private function onNextEvent(e:MouseEvent):void {
			if (App.user.friends.count <= 8) 
				return
			showFriends(+1);
		}
		private function onNextSixEvent(e:MouseEvent):void {
			if (App.user.friends.count <= 8) 
				return
			showFriends(+6);
		}
		private function onNextAllEvent(e:MouseEvent):void {
			if (App.user.friends.count <= 8) 
				return
				
			showFriends(App.user.friends.count - ROW + FREE_FRIEND_CONT);
		}
		
		private function drawItems():void 
		{
			if (bg != null)
				removeChild(bg);
			if (bgDecor != null)
				removeChild(bgDecor);

			bgDecor = BottomPanel.drawPanelBg(App.self.stage.stageWidth - 252, 'panelCornerLittle');

			bg = BottomPanel.drawPanelBg(App.self.stage.stageWidth - 340, 'panelCornerBig');
			
			
			addChild(bgDecor);
			bgDecor.x = bg.x;
			bgDecor.y = 40;
			addChild(bg);
			bg.x = 45;

			if (exit)
				this.setChildIndex(exit, 0);
				
			drawBttns();
			drawSearch();
			
		}
		
		
		public function initFriends():void 
		{
			searchFriends();
		}
		
		private var searchBgPanel:Bitmap;
		
		private function drawSearch():void 
		{	
			if (bttnSearch != null)
				removeChild(bttnSearch);
				
			if (searchBgPanel != null)
				removeChild(searchBgPanel);
				
			bttnSearch =  new ImageButton(UserInterface.textures.searchBttn);
			//bttnSearch.x = bg.x - 30;
			//bttnSearch.y = bg.y - 37;
			
			bttnSearch.x = bttnNextAll.x + bttnNextAll.width/2 - 18;
			bttnSearch.y = -34;
			
			addChild(bttnSearch);
			bttnSearch.addEventListener(MouseEvent.CLICK, onSearchEvent);
			
			searchBgPanel = new Bitmap(UserInterface.textures.searchBackingLongInt);
			searchBgPanel.x = bttnSearch.x - searchBgPanel.width;
			searchBgPanel.y = bttnSearch.y/* + 4*/;
			addChildAt(searchBgPanel, 1);
			searchBgPanel.visible = false;
				
			bttnSearch.tip =  function():Object { return { title:Locale.__e("flash:1382952379771") }; }
			
			searchPanel.x = searchBgPanel.x + 5;
			searchPanel.y =  searchBgPanel.y + 5;
			addChild(searchPanel);
			
			if (searchBg != null)
			{
				searchPanel.removeChild(searchBg);
			}
			
			var searchBg:Shape = new Shape();
			searchBg.graphics.lineStyle(1, 0x47424e, 1, true);
			searchBg.graphics.beginFill(0xf3d8ab,1);
			searchBg.graphics.drawRoundRect(1, 0, 117, 18, 13, 13);
			searchBg.graphics.endFill();
			
			searchPanel.addChild(searchBg);
			
			if (bttnBreak != null)
				searchPanel.removeChild(bttnBreak);
			
			bttnBreak = new ImageButton(UserInterface.textures.stopIcon/*, { scaleX:0.5, scaleY:0.5, shadow:true } */);
			
			
				
			searchPanel.addChild(bttnBreak);
		
			bttnBreak.x = searchBgPanel.width - bttnBreak.width - 11;
			bttnBreak.y = -2;
			bttnBreak.addEventListener(MouseEvent.CLICK, onBreakEvent);
			
			searchField = Window.drawText("",{ 
				color:0x604729,
				borderColor:0xf8f2e0,
				fontSize:16,
				input:true,
				border:false
			});
			
			searchField.width = bttnBreak.x - 2;
			searchField.height = searchField.textHeight + 2;
			searchField.x = 3;
			searchField.y = 0;
			
			searchPanel.addChild(searchField);
			searchPanel.visible = false;
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
			//searchField.addEventListener(TextEvent.TEXT_INPUT, onInputEvent);
		}
		
		private function onFocusEvent(e:FocusEvent):void {
			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
		}
		private function onInputEvent(e:Event):void 
		{
			searchFriends(e.target.text);
		}
		
		private function onSearchEvent(e:MouseEvent):void {
			if (!searchPanel.visible) {
				searchField.text = "";
			}
			searchPanel.visible = !searchPanel.visible;
			/*searchBgBttn.visible = !searchBgBttn.visible;*/
			searchBgPanel.visible = !searchBgPanel.visible;
		}
		
		private function onBreakEvent(e:MouseEvent):void
		{
			searchField.text = "";
			searchFriends();
			searchPanel.visible = false;
			/*searchBgBttn.visible = !searchBgBttn.visible;*/
			searchBgPanel.visible = !searchBgPanel.visible;
		}
		
		private var start:int = 0;
		private var bgDecor:Bitmap;
		public var friends:Array = [];
		public var searchPanel:Sprite = new Sprite();
		public var bttnSearch:ImageButton;
		public var bttnBreak:ImageButton;
		public var searchField:TextField;
		public function searchFriends(query:String = ""):void 
		{
			friends = [];
			var friend:Object;
			query = query.toLowerCase();
			var bot:Object;
			if(query == ""){
				for each(friend in App.user.friends.data){
					if (friend.uid == "1") {
						bot = friend;
					}else{
						friends.push(friend);
					}
				}
			}else {
				for each(friend in App.user.friends.data){
					
					if (
						friend.aka.toLowerCase().indexOf(query) == 0 ||
						friend.first_name.toLowerCase().indexOf(query) == 0 ||
						friend.last_name.toLowerCase().indexOf(query) == 0 ||
						friend.uid.toString().toLowerCase().indexOf(query) == 0
					){
						if (friend.uid == "1") {
							bot = friend;
						}else{
							friends.push(friend);
						}
					}
				}
			}
			start = 0;
			
			friends.sortOn("level", Array.NUMERIC | Array.DESCENDING);
			if(bot){
				friends.unshift(bot);
			}
			
			showFriends();
		}
		
		private function getLimit():int {
			var limit:int = 7;
			
			limit = Math.ceil((App.self.stage.stageWidth - 330 - 40)/70);
			return limit;
		}
		
		public function showFriends(shift:int = 0):void 
		{
			if (friendsCont)
				removeChild(friendsCont);
				
			friendsCont = new Sprite();
			start += shift;
			
			if (start >= friends.length - FREE_FRIEND_CONT)
			start = friends.length - FREE_FRIEND_CONT;
				
			if (start <= 0)
				start = 0;
				
			var childs:int = numChildren;
			
			/*for each(var child:* in friendsItems) {
				removeChild(child);
			}*/
			friendsItems = new Vector.<FriendItem>();
			
			
			var limit:int = getLimit();
			if (App.social == 'YB') {
				limit = 5;
			}
			
			var length:int = friends.length > start + limit ?start + limit :friends.length;
			var item:FriendItem;
			
			var X:int = 45;
			var Y:int = 0;
			
			for (var i:int = start; i < length; i++) {
				item = new FriendItem(this,friends[i]);
				friendsItems.push(item);
				item.x = X;
				item.y = Y;
				friendsCont.addChild(item);
				item.px = item.x;
				X += 68;
				item.addEventListener(MouseEvent.CLICK, onVisitEvent);
			}
			
			for (i = length; i < start + limit; i++) {
				item = new FriendItem(this);
				friendsItems.push(item);
				item.x = X;
				item.y = Y;
				friendsCont.addChild(item);
				item.px = item.x;
				X += 68;
				item.addEventListener(MouseEvent.CLICK, onInviteEvent);
			}
			
			try{
				for (i = friendsItems.length -1 ; i >= 0; i--)
				{
					friendsCont.setChildIndex(friendsItems[i], this.numChildren - 1);
				}
			}catch (e:Error){}
		
			
			friendsCont.x = (bg.width- friendsCont.width)/2;
			friendsCont.y = 8;
			addChild(friendsCont);
		}
		
		private function selectFriendItem(target:* = null):void
		{
			for each(var item:* in friendsItems)
			{
				if (item == target)
				{
					var scale:Number = 1.15;
					item.y = 24;
					item.x = item.px - 4;
					item.width = item.w * scale;
					item.height = item.h * scale;
				}
				else
				{
					item.width = item.w;
					item.height = item.h;
					item.y = 34;
					item.x = item.px
				}
			}
		}
		public function close(e:MouseEvent):void {
			App.ui.bottomPanel.hideFriendsPanel();
		}
		
		public function onVisitEvent(e:MouseEvent):void {
			if (App.user.quests.tutorial)
				return;
		
			Travel.onVisitEvent(e);
		}
		
		public function onInviteEvent(e:MouseEvent):void {
			bottomPanel.onInviteEvent(e);
		}
	}
}

import core.AvaLoad;
import core.Load;
import core.Log;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.filters.ShaderFilter;
import flash.text.TextField;
import flash.utils.Timer;
import silin.filters.ColorAdjust;
import ui.UserInterface;
import wins.elements.MapIcon;
import wins.GiftItemWindow;
import wins.SimpleWindow;
import wins.Window;

internal class FriendItem extends LayerX {
	
	public var sprite:Sprite = new Sprite();
	public var avatar:Bitmap = new Bitmap(null, "auto", true);
	public var legs:Bitmap = new Bitmap(UserInterface.textures.legs);
	public var friend:Object;
	
	public var w:uint = 0;
	public var h:uint = 0;
	public var px:Number = 0;
	
	public var type:String;
	
	public var friendsBackingBmp:Bitmap;
	public var friendsPanel:*;
	
	public var uid:String;
	
	public function FriendItem(panel:*, friend:Object = null, type:String = 'default'):void {
		this.friend = friend;
		this.type = type;
		this.friendsPanel = panel;
		
		if(friend != null && friend.hasOwnProperty('uid'))
			uid = friend.uid;
		
		friendsBackingBmp = new Bitmap(UserInterface.textures.friendsBacking);
		addChild(friendsBackingBmp);
		
		if(friend != null){
			
			var first_Name:String = friend.first_name || "";
			var name:TextField = Window.drawText(first_Name.substr(0, 15), App.self.userNameSettings( {
				fontSize:18,
				color:0xffffff,
				borderColor:0x884a25,
				autoSize:"center",
				textAlign:"center",
				multiline:true
			}));
			
			addChild(sprite);
			sprite.x = 7;
			sprite.y = 6;
			sprite.addChild(avatar);
			addChild(name);
			name.wordWrap = true;
			name.width = friendsBackingBmp.width + 6;
			name.x = (width - name.width) / 2 - 3;
			name.y = -10;
			//name.border = true;
			
			var star:Bitmap = new Bitmap(Window.textures.star);
			addChild(star);
			star.scaleX = star.scaleY = 0.8; 
			star.smoothing = true;
			star.x = width - star.width + 2;
			star.y = height - star.height - 8;
			
			var level:TextField = Window.drawText(String(friend.level || 0), {
				fontSize:16,
				color:0xFFFFFF,
				borderColor:0x704f1a,
				//border:false,
				autoSize:"left",
				multiline:true
			});
			
			addChild(level);
			level.x = star.x + star.width / 2 - level.width / 2;
			level.y = star.y + 5;
			
			//Log.alert('friend-= ' + friend + "   friend[photo]-= " + friend["photo"] + "   friend.uid -= " + friend.uid);
			
			if(friend["photo"] != undefined){
				//Load.loading(friend.photo, onLoad);
				//Log.alert('_________START____LOAD____FOTO');
				new AvaLoad(friend.photo, onLoad);
			}
			
			addChild(legs);
			legs.visible = false;
			legs.y = star.y + 6;
			legs.x = 3;
			legs.filters = [new GlowFilter(0xd8c5a6, 1, 2, 2, 5, 1)];
			
			if (friend['visited'] != undefined && friend.visited > App.midnight) {
				legs.visible = true;
			}
		}
		else
		{
			friendsBackingBmp.bitmapData = UserInterface.textures.friendsBacking;
			var textLabel:String = Locale.__e('flash:1382952379777');
			if(type == 'manage'){
				textLabel = Locale.__e('flash:1382952379778');
			}
			var text:TextField = Window.drawText(textLabel, {
				fontSize:17,
				color:0xfceecf,
				borderColor:0xbba275,
				textAlign:"center",
				autoSize:"center",
				textLeading:-6,
				multiline:true
			});
			text.wordWrap = true;
			text.width = friendsBackingBmp.width;
			text.height = text.textHeight+2;
			text.x = friendsBackingBmp.x;
			text.y = 24;
			
			var container:Sprite = new Sprite();
			addChild(container);
			container.addChild(text);
			container.filters = [new DropShadowFilter(3, 45, 0, 0.2, 5,5)];
		}
		
		w = this.width;
		h = this.height;
		
		addEventListener(MouseEvent.MOUSE_OVER, onOverEvent);
		addEventListener(MouseEvent.MOUSE_OUT, onOutEvent);
		
		mouseChildren = false;
		
		var that:FriendItem = this;
		tip = function():Object {
			if (type == 'manage') {
				return {
					title: Locale.__e('flash:1382952379779')
				};
			}
			
			return {
				title: that.friend != null ? Locale.__e('flash:1382952379780') : Locale.__e('flash:1382952379781')
			};
		}
	}
	
	private function onOverEvent(e:MouseEvent):void {
		for each(var item:FriendItem in friendsPanel.friendsItems) {
			item.friendsBackingBmp.filters = [];
		}
		
		var mtrx:ColorAdjust;
		mtrx = new ColorAdjust();
		mtrx.saturation(1);
		mtrx.brightness(0.1);
		friendsBackingBmp.filters = [mtrx.filter];
		if (avatar != null) avatar.filters = [mtrx.filter];
		
		friendsPanel.wishList.show(this);
			
		//friendsBackingBmp.filters = [new GlowFilter(0x94ef00,1,10,10,2,1)] ;
	}
	
	private function onOutEvent(e:MouseEvent):void {
		for each(var item:FriendItem in friendsPanel.friendsItems) {
			item.friendsBackingBmp.filters = [];
			if(avatar != null) avatar.filters = [];
		}
		
		friendsPanel.wishList.hide();
	}
	
	private function onLoad(data:*):void {
		if(data is Bitmap){
			avatar.bitmapData = data.bitmapData;
			avatar.smoothing = true;
		}	
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 50, 50,20, 20);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
	}	
}

import ui.FriendsPanel;

internal class WishListPopUp extends Sprite
{
	private var showed:Boolean = false;
	private var items:Array = [];
	private var container:Sprite;
	private var overed:Boolean = false;
	private var overTimer:Timer = new Timer(250, 1);
	public var window:FriendsPanel;
	public var callback:Function;
	public var uid:String;

	public function WishListPopUp(window:FriendsPanel)
	{
		this.window = window;
		callback = function():void{
			//window.refreshContent();
			//window.onUpChange();
		}
		overTimer.addEventListener(TimerEvent.TIMER, dispose)
	}
	
	public function show(target:FriendItem):void
	{
		if (!App.user.friends.data || !App.user.friends.data[target.uid].hasOwnProperty("wl")) return;
		
		uid = target.uid;
		var wlist:Object = App.user.friends.data[uid].wl;
		
		dispose();
		items = [];
			
		var X:int = 0;
		var Y:int = 0;
		
		for (var i:* in wlist)
		{
			var item:WishListItem = new WishListItem(wlist[i], this, uid);
			item.x = X;
			item.y = Y;
			item.addEventListener(MouseEvent.MOUSE_OVER, over);
			item.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			items.push(item);
			X += 56;
			addChild(item);
		}
		
		this.x = target.x + (target.width - this.width)/2 + 4;
		//this.y = target.y - 60 + 210;
		
		showed = true;
		window.setChildIndex(this, window.numChildren-1);
	}
	
	private function over(e:MouseEvent):void{
		overed = true;
	}
	
	private function out(e:MouseEvent):void{
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
		
		for each(var _item:* in items)
		{
			_item.dispose();
			_item.removeEventListener(MouseEvent.MOUSE_OVER, over);
			_item.removeEventListener(MouseEvent.MOUSE_OUT, out);
			removeChild(_item);
			_item = null;
		}
		items = [];
		
		showed = false;
	}
	
	public function hide():void
	{
		overTimer.reset();
		overTimer.start();
	}
}

internal class WishList extends Sprite
{
	public var items:Array = [];
	public var icon:*;
	public var uid:String;
	public var callback:Function;

	public function WishList(wlist:Object, icon:*)
	{
		this.icon = icon;
		this.uid = icon.uid;
		var X:int = 0;
		var Y:int = 0;
		callback = function():void{
			icon.win.refreshIcon();
			icon.win.refreshContent();
			//icon.drawWishList();
		}
		
		for (var i:* in wlist)
		{
			var item:WishListItem = new WishListItem(wlist[i], this, uid);
			item.x = X;
			item.y = Y;
			items.push(item);
			X += 56;
			addChild(item);
		}
	}
	
	public function dispose():void
	{
		for each(var item:* in items)
		{
			item.dispose();
			item = null;
		}
	}
}

internal class WishListItem extends Sprite
{
	private var bitmap:Bitmap;
	private var bg:Bitmap;
	private var has:Boolean = false;
	private var preloader:Preloader = new Preloader();
	private var wList:*;
	private var sID:uint;
	private var uid:String;
		
	public function WishListItem(sID:uint, wList:*, uid:String)
	{
		this.wList = wList;
		this.sID = sID;
		this.uid = uid;
		
		if (App.user.stock.count(sID) > 0)
		{
			has = true;
			bg = new Bitmap(Window.textures.cursorsPanelItemBg);
			//bg = Window.backing(64, 64, 8, "textSmallBacking");
			bg.x = -2;
			bg.y = -2;
			this.addEventListener(MouseEvent.CLICK, onClick);
		}	
		else
			bg = new Bitmap(Window.textures.cursorsPanelItemBg);
			//bg = Window.backing(60, 60, 8, "bonusBacking");
		
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		addChild(preloader);
		preloader.scaleX = preloader.scaleY = 0.4;
		preloader.x = 60/2;
		preloader.y = 60/2;
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
	}

	private function onClick(e:MouseEvent):void
	{
		new GiftItemWindow( {
			sID:sID,
			fID:uid,
			callback:function():void {
				wList.callback();
			}
		}).show();
	}
	
	public function dispose():void
	{
		this.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.4;
		bitmap.y = (60 - bitmap.height) / 2 - 5;
		bitmap.x = (60 - bitmap.width) / 2 - 5;
		bitmap.smoothing = true;
	}
}
