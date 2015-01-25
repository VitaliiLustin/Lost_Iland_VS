package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import ui.Hints;
	import units.Floors;
	import wins.Paginator;
	
	public class TowerWindow extends Window
	{
		private var items:Array = new Array();
		private var info:Object;
		public var back:Bitmap;
		public var hitBttn:Button;
		public var upgradeBttn:Button;
		
		public function TowerWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 46;
			settings['fontBorderColor'] = 0xb5855d;
			settings['shadowBorderColor'] = 0x86572b;
			settings['fontBorderSize'] = 4;
			
			settings['background'] = "storageBackingMain";
			
			settings['width'] = 560;
			settings['height'] = 500;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			
			settings['content'] = [];
			
			for (var _uid:* in settings.target.guests) 
			{
				if (!App.user.friends.data.hasOwnProperty(_uid)) continue;
				settings['content'].push( { uid:_uid, time:settings.target.guests[_uid] } );
			}
			
			if (settings.target.hasOwnProperty('floor'))
				floor = settings.target.floor
			else
				floor = settings.target.level
			
			super(settings);
		}
		
		public var floor:int = 0;
		private var titleTxt:Sprite;
		private var txtS:TextField;
		private function drawStageInfo():void {
			
			var titleS:String = (info.tower[floor + 1] != undefined)
						?getTextFormInfo('text3') + Locale.__e("flash:1382952380278", [settings.target.kicks, info.tower[floor + 1].c])
						:getTextFormInfo('text9');
			
			var textSettings:Object = 
			{
				fontSize	:34,
				color		:0xffffff,
				borderColor	:0x6d3c13,
				textAlign	:"center",
				borderSize:2,
				multiline:true,
				wrap:true
			}
			
			if (info.tower[floor + 1] == undefined) {
				textSettings['fontSize'] = 26;
			}
			
			txtS = Window.drawText(titleS, textSettings);
			txtS.width = 300;
			txtS.height = txtS.textHeight + 5;
			titleTxt = new Sprite();
			titleTxt.addChild(txtS);
			titleTxt.x = 20;
			titleTxt.y = 380;
			bodyContainer.addChild(titleTxt);
		}
		
		public function stageInfoAlign():void {
			var _text:String = (info.tower[floor + 1] != undefined)
						?getTextFormInfo('text3') + Locale.__e("flash:1382952380278", [settings.target.kicks, info.tower[floor + 1].c])
						:getTextFormInfo('text9');
						
			var _title:TextField = drawText(_text, {
				fontSize:36
			});
			if (info.tower[floor + 1] != undefined) {
				titleTxt.x = 20;
			}else {
				txtS.width = 500;
				titleTxt.x = (settings.width - titleTxt.width) / 2;
				titleTxt.y = 360;
			}
		}
		
		override public function drawBody():void 
		{
			drawLabel(settings.target.textures.sprites[3].bmp);
			exit.y -= 8;
			titleLabelImage.y += 20;
			
			drawVisitors();
			drawStageInfo();
			
			if (settings.content.length == 0)
			{
				var descriptionLabel:TextField = drawText(getTextFormInfo('text4'), {
					fontSize:28,
					textAlign:"center",
					color:0xffffff,
					borderColor:0x624512,
					textLeading:-9
				});
				
				descriptionLabel.wordWrap = true;
				descriptionLabel.width = 350;
				descriptionLabel.height = descriptionLabel.textHeight + 10;
				descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
				descriptionLabel.y = 100;
				
				bodyContainer.addChild(descriptionLabel);
			}
			stageInfoAlign();
			drawBttns();
			
			var separator:Bitmap = Window.backingShort(480, 'divider');
			separator.x = back.x + (back.width - separator.width) / 2;
			separator.y = 15;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			//var separator2:Bitmap = Window.backingShort(154, 'separator3');
			//separator2.x = settings.width - separator2.width - 28;
			//separator2.y = 12;
			//separator2.alpha = 0.5;
			//bodyContainer.addChild(separator2);
			
			var underTitle:Bitmap = Window.backingShort(215, "yellowRibbon");
			underTitle.x = (settings.width - underTitle.width) / 2;
			underTitle.y = 3;
			bodyContainer.addChild(underTitle);
			
			var subTitle:TextField = Window.drawText(Locale.__e("flash:1382952380233") + ": " +  settings.target.floor + "/" + settings.target.totalFloors, {
				fontSize:24,
				color:0xFFFFFF,
				autoSize:"left",
				borderColor:0xb56a17
			});
			bodyContainer.addChild(subTitle);
			subTitle.x = settings.width / 2 - subTitle.width / 2;
			subTitle.y = underTitle.y + 5;
			
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 + 5, settings.width / 2 + settings.titleWidth / 2 - 5, -43, true, true);
			drawMirrowObjs('storageWoodenDec', 0, settings.width, settings.height - 116);
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 50, false, false, false, 1, -1);
		}
		
		private var accelerateBttn:MoneyButton
		private function drawBttns():void {
		
			upgradeBttn = new Button({
				caption		:getTextFormInfo('text2'),
				width		:190,
				height		:52,	
				fontSize	:26
			});
			
			hitBttn = new Button({
				caption		:getTextFormInfo('text5'),
				width		:190,
				height		:52,	
				fontSize	:36
			});
			hitBttn.x = (settings.width - hitBttn.width) / 2;
			hitBttn.y = 425;
			
			upgradeBttn.x = (settings.width - upgradeBttn.width) / 2;
			upgradeBttn.y = settings.height - upgradeBttn.height - 50;
			
			bodyContainer.addChild(upgradeBttn);
			bodyContainer.addChild(hitBttn);
			
			var skipPrice:int = 0
			if (info.tower[floor + 1] != null) {
				skipPrice = settings.target.info.skip * (info.tower[floor + 1].c - settings.target.kicks);
			}
			
			accelerateBttn = new MoneyButton({
				caption		:Locale.__e('flash:1382952379751'),
				width		:180,
				height		:47,	
				fontSize	:26,
				fontCountSize : 26,
				radius		:18,
				countText	:skipPrice,
				iconScale	:0.8,
				multiline	:true,
				
				bgColor:[0xa8f749, 0x74bc17],
				borderColor:[0x5b7385, 0x5b7385],
				bevelColor:[0xcefc97, 0x5f9c11],
				fontColor:0xffffff,			
				fontBorderColor:0x4d7d0e,
				
				fontCountColor:0xc7f78e,
				fontCountBorder:0x40680b		
			});
			
			upgradeBttn.addEventListener(MouseEvent.CLICK, kickEvent);
			hitBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			accelerateBttn.addEventListener(MouseEvent.CLICK, buyKickEvent);
			
			bodyContainer.addChild(accelerateBttn);
			accelerateBttn.x = settings.width - accelerateBttn.width - 60;
			accelerateBttn.y = titleTxt.y - 5;
			
			upgradeBttn.visible = false;
			hitBttn.visible = false;
			accelerateBttn.visible = false;
			
			if (floor > 0 || settings.target.kicks >= info.tower[floor+1].c) {
				if (info.tower[floor+1] != undefined && settings.target.kicks < info.tower[floor+1].c){
					hitBttn.visible = true;
					accelerateBttn.visible = true;
				}else if (info.tower[floor + 1] == undefined) {
					upgradeBttn.visible = false;
					hitBttn.visible = true;
				}else{
					upgradeBttn.visible = true;
					titleTxt.x = (settings.width - titleTxt.width) / 2;
					titleTxt.y = 360;
					//titleTxt.y = settings.height - titleTxt.height - 100;
				}
			}else{
				accelerateBttn.visible = true;
			}
			
			switch(info.burst) {
				case Floors.BURST_ONLY_ON_COMPLETE:
					if (info.tower[floor + 1] == null)
						hitBttn.visible = true;
					else
						hitBttn.visible = false;
				break;
				case Floors.BURST_NEVER:
					hitBttn.visible = false;
				break;	
			}
		}
		
		public var skipPrice:int;
		private function buyAllEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.storageEvent(0, onStorageEventComplete);
		}
		
		private function kickEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			settings.upgradeEvent( {} );
			settings.content = [];
			close();
		}
		
		private var price:int;
		private function buyKickEvent(e:MouseEvent):void {
			
			price = (info.tower[floor + 1].c - settings.target.kicks) * info.skip;
			
			if (!App.user.stock.check(Stock.FANT, price))
				return;
			
			if (e.currentTarget.mode == Button.DISABLED) return;
			e.currentTarget.state = Button.DISABLED;
			
			settings.buyKicks({
				callback:onBuyKicks
			});
		}
		
		private function onBuyKicks():void {
			if (titleTxt)
				bodyContainer.removeChild(titleTxt);
				
			drawStageInfo();	
			titleTxt.x = 20;
			
			Hints.minus(Stock.FANT, price, Window.localToGlobal(accelerateBttn), false, this);
			App.user.stock.take(Stock.FANT, price);
			
			titleTxt.y = 360;
			titleTxt.x = (settings.width - titleTxt.width)/2;
			upgradeBttn.visible = true;
			accelerateBttn.visible = false;
			hitBttn.visible = false;
		}
		
		public function onStorageEventComplete(sID:uint, price:uint):void {
			
			if (price == 0 ) {
				close();
				return;
			}
			var X:Number = App.self.mouseX - upgradeBttn.mouseX + upgradeBttn.width / 2;
			var Y:Number = App.self.mouseY - upgradeBttn.mouseY;
			Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
			close();
		}
		
		private function drawVisitors():void {
			
			back = Window.backing(510, 300,20, 'storageBackingSmall');
			back.x = (settings.width - back.width)/2;
			back.y = 60;
			back.alpha = 0.7;

			var text:String = Locale.__e(settings.target.info.text1);
			var label:TextField = drawText(text, {
				fontSize:32,
				autoSize:"center",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x5a3616,
				border:true
			});
			
			label.width = settings.width - 50;
			label.height = label.textHeight;
			label.x = (settings.width - label.width) / 2;
			label.y = back.y - 13;
			
			bodyContainer.addChild(back);
			bodyContainer.addChild(label);	
			
			if (settings['content'].length > 0){
				contentChange();
				drawNotif();
			}else{
				drawNotif();
			}	
		}
		
		public var notifBttn:Button = null;
		
		private function drawNotif():void {
			if (info.tower[floor + 1] == undefined)
				return;
			
			var bttnSettings:Object = {
				caption		:Locale.__e("flash:1382952380197"),
				width		:190,
				height		:54,	
				fontSize	:32
			}
			
			if (settings['content'].length > 0) {
				bttnSettings['width'] = 180;
				bttnSettings['height'] = 44;
				bttnSettings['fontSize'] = 26;
				bttnSettings['caption'] = Locale.__e("flash:1382952379977");
			}
			
			notifBttn = new Button(bttnSettings);
			
			notifBttn.x = back.x + (back.width - notifBttn.width) / 2;
			
			if (settings['content'].length > 0) {
				notifBttn.y = back.y + back.height - 53;
			}
			else
			{
				notifBttn.y = back.y + (back.height - notifBttn.height) / 2 + 80;
			}
			
			bodyContainer.addChild(notifBttn);
			notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
		}
		
		private function onNotifClick(e:MouseEvent):void {
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
					new AskWindow(AskWindow.MODE_NOTIFY, {
						target:settings.target,
						title:Locale.__e('flash:1382952380197'), 
						friendException:settings.friendsData, 
						inviteTxt:Locale.__e("flash:1395846352679"),
						desc:getTextFormInfo('text4')
					} ).show();
					break;
				case 'FB':
				case 'OK':
				case 'ML':	
				case 'PL':	
						ExternalApi.apiInviteEvent();
					break;
			}
		}
		
		override public function drawArrows():void {
				
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = back.y + back.height / 2 - paginator.arrowLeft.height / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2;
			paginator.arrowRight.y = y;
		}
		
		public override function contentChange():void {
			
			for each(var _item:* in items)
			{
				_item.dispose();
				bodyContainer.removeChild(_item);
			}
			
			items = [];
			
			var X:int = 42;
			var Xs:int = X;
			var Y:int = back.y + 30;
			var itemNum:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				if (i >= settings.content.length)
					break;
				var item:FriendItem = new FriendItem(this, settings.content[i], 2);
				items.push(item);
				bodyContainer.addChild(item);
				item.x = X;
				item.y = Y;
				
				X += item.bg.width + 3;
				
				if (itemNum == 4){
					Y += item.bg.height + 3;
					X = Xs;
				}
				
				itemNum++;
			}
		}
		
		override public function dispose():void {
			
			upgradeBttn.removeEventListener(MouseEvent.CLICK, kickEvent);
			hitBttn.removeEventListener(MouseEvent.CLICK, buyAllEvent);
			if (notifBttn != null) notifBttn.addEventListener(MouseEvent.CLICK, onNotifClick);
			
			super.dispose();
		}
		
		public function getTextFormInfo(value:String):String {
			var text:String = settings.target.info[value];
			text = text.replace(/\r/, "");
			return Locale.__e(text);
		}
	}
}


import core.AvaLoad;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import wins.Window;

internal class ShareItem extends LayerX {
	
	public var window:*;
	public var uid:*;
	public var time:uint;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var maska:Shape;
	
	public function ShareItem(obj:Object, window:*) {
		
		this.uid = obj.uid;
		this.time = obj.time;
		this.window = window;
		
		bg = Window.backing(80, 80, 20, 'textSmallBacking');
		addChild(bg);
		
		maska = new Shape();
		maska.graphics.beginFill(0xFFFFFF, 1);
		maska.graphics.drawRoundRect(0,0,50,50,15,15);
		maska.graphics.endFill();
		
		addChild(maska);
		
		new AvaLoad(App.user.friends.data[uid].photo, onLoad);
		
		var count:int = int(Math.random() * 10) + 1;
		
		tip = function():Object {
			return {
				title	:App.user.friends.data[uid].first_name + " " +App.user.friends.data[uid].last_name
			}
		}
	}
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		addChild(bitmap);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
		
		maska.x = bitmap.x;
		maska.y = bitmap.y;
		bitmap.mask = maska;
	}
	
	public function dispose():void {
		
	}
}


import buttons.Button;
import core.AvaLoad;
import core.Load;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.AskWindow;
import wins.Window;
import wins.TowerWindow;

internal class FriendItem extends Sprite
{
	public var bg:Bitmap;
	public var friend:Object;
	public var mode:int;
	
	private var window:TowerWindow;
	
	private var title:TextField;
	private var sprite:Sprite = new Sprite();
	private var avatar:Bitmap = new Bitmap();
	private var data:Object;
	
	private var preloader:Preloader = new Preloader();
	
	private var callBack:Function;
	
	public function FriendItem(window:TowerWindow, data:Object, mode:int, callBack:Function = null)
	{
		this.data = data;
		this.friend = App.user.friends.data[data.uid];
		this.window = window;
		this.mode = mode;
		this.callBack = callBack;
		
		//bg = new Bitmap(Window.textures.avaBg2);
		bg = new Bitmap(Window.textures.friendsBacking);
		addChild(bg);
		//bg.width = 100;
		//bg.height = 100;
		bg.smoothing = true;
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
				txtBttn = Locale.__e("flash:1382952380230");
			break;
			case AskWindow.MODE_PUT_IN_ROOM:
				txtBttn = Locale.__e("flash:1393580021031");
			break;
		}
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
	}
	
	private function onSelectClick(e:MouseEvent):void
	{
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
	}
}

