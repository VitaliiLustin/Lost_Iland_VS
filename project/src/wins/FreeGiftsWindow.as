package wins 
{
	import buttons.Button;
	import buttons.ChangedButton;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import buttons.MenuButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.BevelFilter;
	import flash.filters.GradientBevelFilter;
	import flash.text.TextField;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldType;
	import flash.ui.Mouse;
	
	public class FreeGiftsWindow extends Window
	{
		public static const FREE:uint = 1;
		public static const TAKE:uint = 2;
		
		public var paginatorDown:Paginator
		
		public var bitmap:Bitmap;
		public var container:Sprite;
		
		public var ListFree:Array = new Array;
		public var ListTake:Array = new Array;
		
		public var listItems:Array = new Array;
		public var takeItems:Array = new Array;
		
		public var items:Array = new Array;
		
		public var freeGiftsBttn:MenuButton;								
		public var takeGiftsBttn:MenuButton;
		public var takeAllBttn:Button;
		
		public var limitLabel:Sprite = new Sprite();
		public var countLimitLabel:TextField = null;
		
		private var mode:uint = FREE;
		
		
		public var capasitySprite:LayerX = new LayerX();
		private var capasitySlider:Sprite = new Sprite();
		private var capasityCounter:TextField;
		public var capasityBar:Bitmap;
		
		/**
		 * Конструктор
		 * @param	settings	настройки
		 */ 
		public function FreeGiftsWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings["title"]			= Locale.__e("flash:1382952380112");
			
			settings["width"]			= 630;
			settings["height"] 			= 630;
			
			//settings["fontSize"] 		= 25;
			settings["multiline"] 		= true;
			settings["textLeading"] 	= -6;
			
			settings["hasPaginator"] 	= false;
			settings["autoClose"] 		= false;
			settings["background"] 		= 'storageBackingMain';
			
			mode = settings.mode || FREE
			
			super(settings);
		}
		
		override public function dispose():void {
			
			super.dispose();
			
			for each(var item:* in items)	item.dispose();
			for each(item in listItems)	item.dispose();
			for each(item in takeItems)	item.dispose();
			for each(item in ListFree)	item.dispose();
			for each(item in ListTake)	item.dispose();
			
			if(items)items.splice(0, items.length);
			if(listItems)listItems.splice(0, listItems.length);
			if(takeItems)takeItems.splice(0, takeItems.length);
			if(ListFree)ListFree.splice(0, ListFree.length);
			if(ListTake)ListTake.splice(0, ListTake.length);
			items = null;
			listItems = null;
			takeItems = null;
			ListFree = null;
			ListTake = null;
			
		}
		
		private var separatorBig:Bitmap;
		override public function drawBody():void {
			
			exit.y -= 12;
			
			drawBackgroundElement();
			createBttns();
			//createTakeBttns()
			
			settings.content = {
				free:createFreeContent(),
				take:App.user.gifts
			};
				
			separatorBig = Window.backingShort(settings.width - 80, 'divider');
			separatorBig.alpha = 0.8;
			//layer.addChild(separatorBig);
			bodyContainer.addChild(separatorBig);
			separatorBig.x = (settings.width - separatorBig.width) / 2;
			separatorBig.y = 60;
				
			createPaginators();
			changeRazdel(mode);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			drawMirrowObjs('diamonds', 22, settings.width - 22, settings.height - 118);
			drawMirrowObjs('diamonds', 22, settings.width - 22, 47, false, false, false, 1, -1);
			
			addSlider();
		}
		
		private function addSlider():void
		{
			capasityBar = new Bitmap(Window.textures.prograssBarBacking);
			
			Window.slider(capasitySlider, 60, 60, "progressBar");
			
			bodyContainer.addChild(capasitySprite);
			
			
			var textSettings:Object = {
				color:0xffffff,
				borderColor:0x7b4003,
				fontSize:32,
				
				textAlign:"center"
			};
			
			//textSettings.fontSize = 24;
			capasityCounter = Window.drawText(Stock.value +'/'+ Stock.limit, textSettings); 
			capasityCounter.width = 120;
			capasityCounter.height = capasityCounter.textHeight;
			capasitySprite.mouseChildren = false;
			capasitySprite.addChild(capasityBar);
			capasitySprite.addChild(capasitySlider);
			capasitySprite.addChild(capasityCounter);
			
			//capasitySlider.x = (capasityBar.width - capasitySlider.width)/2; capasitySlider.y = (capasityBar.height - capasitySlider.height)/2;
			
			var txtTaked:TextField = Window.drawText(Locale.__e('flash:1393580533220'), {
				color:0xffffff,
				borderColor:0x7b4003,
				fontSize:32,
				
				textAlign:"center"
			}
			); 
			capasitySprite.addChild(txtTaked);
			txtTaked.y -= 4;
			
			capasityBar.x = txtTaked.textWidth + 8;
			capasityBar.y  = -8;
			capasitySlider.x = capasityBar.x + 10; 
			capasitySlider.y -= 2;
			
			capasitySprite.x = settings.width / 2 - capasityBar.width / 2 - 48; capasitySprite.y = 64;
			
			capasityCounter.x = capasityBar.x + (capasityBar.width - capasityCounter.width) / 2; 
			capasityCounter.y = capasityBar.height / 2 - capasityCounter.textHeight / 2 - 10;
			
			updateCapasity();
		}
		
		public function updateCapasity():void
		{
			if (!capasityCounter) return;
			
			var maxValue:int = App.user.giftsLimit;//App.data.options['GiftsLimit'];
			var currValue:int = settings.content.take.length;
			
			Window.slider(capasitySlider, currValue,maxValue, "progressBar");
			capasityCounter.text = String(currValue) +'/' +  String(maxValue);
			capasityCounter.x = capasityBar.x + capasityBar.width / 2 - capasityCounter.width / 2; 
		}
		
		private function createFreeContent():Array
		{
			var spisok:Array = []
			for (var sID:* in App.data.storage)
			{
				if (App.data.storage[sID].free == 1)
				{
					spisok.push(sID);
				}
			}
			
			return spisok;
		}
		
		private function createBttns():void
		{
			freeGiftsBttn = new MenuButton( {
											title:				Locale.__e("flash:1382952380137"),
											giftMode:				FREE,
											fontSize:				21,
											height:					42,
											width:					110,
											multiline:				true
										});
											
			bodyContainer.addChild(freeGiftsBttn);
			freeGiftsBttn.textLabel.y -= 3;
			freeGiftsBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			freeGiftsBttn.x = settings.width/2 - freeGiftsBttn.width - 12;
			freeGiftsBttn.y = 9;
			
			takeGiftsBttn = new MenuButton( {
												title:				Locale.__e("flash:1382952379786"),
												giftMode:				TAKE,
												fontSize:				21,
												height:					42,
												width:					110,
												multiline:				true
											});
													
			bodyContainer.addChild(takeGiftsBttn);								
			takeGiftsBttn.addEventListener(MouseEvent.CLICK, bttnClick);
			takeGiftsBttn.x = settings.width/2 + 12;
			takeGiftsBttn.y = 9;
			takeGiftsBttn.textLabel.y -= 3;
			
			takeAllBttn = new Button( {
									caption:				Locale.__e("flash:1382952380115"),
									fontSize:				21,
									height:					34,
									width:					110
								});
								
			//bodyContainer.addChild(takeAllBttn);								
			takeAllBttn.addEventListener(MouseEvent.CLICK, onTakeAllBttn);
			takeAllBttn.x = settings.width - takeAllBttn.width - 35;
			takeAllBttn.y = 56;					
		}
		
		private function onTakeAllBttn(e:MouseEvent):void
		{
			Gifts.grab(refreshRazdel);
		}
		
		private function bttnClick(e:MouseEvent):void
		{
			changeRazdel(e.currentTarget.settings.giftMode);
		}
			
		private function changeRazdel(mode:uint):void
		{
			settings.mode = mode;
			paginator.hide();
			
			paginator.visible = false;
			
			switch(mode)
			{
				case FREE:
					takeGiftsBttn.state = Button.NORMAL;
					freeGiftsBttn.state = Button.ACTIVE;
					
					paginator.onPageCount = 6;
					paginator.show(settings.content.free.length);
					paginator.visible = true;
					
					if (mode == FREE && settings['find'] != undefined) {
						var index:int = settings.content.free.indexOf(settings.find[0]);
						if(index != -1){
							paginator.page = index / paginator.onPageCount;
							paginator.update();
						}
					}
					separatorBig.visible = true;
					capasitySprite.visible = false;
					
					takeAllBttn.visible = false;
				break;
				case TAKE:
					takeGiftsBttn.state = Button.ACTIVE;
					freeGiftsBttn.state = Button.NORMAL;
					
					//for (var i:int = 0; i < settings.content.take.length; i++) {
						//var uid:String = settings.content.take[i].from
						//if (!App.user.friends.data.hasOwnProperty(uid))
						//{
							//settings.content.take.splice(i, 1);
						//}
					//}
					
					paginator.onPageCount = 3;
					paginator.show(settings.content.take.length);
					paginator.visible = true;
					
					if (App.user.gifts.length == 0) takeAllBttn.state = Button.DISABLED;
					takeAllBttn.visible = true;
					
					separatorBig.visible = false;
					capasitySprite.visible = true;
				break;
			}
			
			contentChange();
		}
		
		private function onChangeFree():void
		{
			var Xs:int = 48;
			var Ys:int = bgDecor.y + 14;
			var X:int = Xs;
			
			for each(var _item:* in items)
			{
				_item.dispose();
				bodyContainer.removeChild(_item);
				_item = null;
			}
			items = [];
			
			var itemNumb:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:FreeGiftItem = new FreeGiftItem(settings.content.free[i], this);
				bodyContainer.addChild(item);
				item.x = int(Xs);
				item.y = int(Ys);
				
				items.push(item);
				
				Xs += item.bg.width + 14;
				
				if (itemNumb == 2){
					Xs = X;
					Ys += item.bg.height+14;
				}
				
				itemNumb++;
			}
		}
		
		
		//private var itemWidth:int = 170;
		//private var itemHeight:int = 206;
		
		private function onChangeTake():void
		{
			var Xs:int = 34;
			var Ys:int = bgDecor.y + 12;
			var X:int = Xs;
			
			for each(var _item:* in items)
			{
				_item.dispose();
				bodyContainer.removeChild(_item);
				_item = null;
			}
			items = [];
			
			var itemNumb:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:TakeItem = new TakeItem({
					window:this,
					data:settings.content.take[i] 
					//width:itemWidth,
					//height:itemHeight
				});
				
				bodyContainer.addChild(item);
				item.x = int(Xs);
				item.y = int(Ys);
				
				items.push(item);
				Ys += item.bg.height + 3;
				
				itemNumb++;
			}
			
			updateCapasity();
		}
		
		public override function contentChange():void {
			if (settings.mode == FREE)	onChangeFree();
			else							onChangeTake();
		}
		
		public function createPaginators():void {
			
			paginator = new Paginator(1, 6, 9, {
				hasArrow:true,
				hasButtons:true
			});
		
			paginator.addEventListener(WindowEvent.ON_PAGE_CHANGE, onPageChange);
			
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  -24, 328, { scaleX:-1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 580, 328, { scaleX:1, scaleY:1 } );
			
			bottomContainer.addChildAt(paginator,0)
			paginator.x = int((settings.width - paginator.width)/2) - 35;
			paginator.y = int(settings.height - paginator.height - 7);
			
			
			
			
		}
		
		/*public function refreshRazdel()
		{
			countLimitLabel.text = NumberConverter.convert(Profile.maxCostGifts - Profile.costGifts);
			
			takeItems = createTakeItems();
			paginatorDown.itemsCount = takeItems.length;
			paginatorDown.update();
			onDownChange();
			
			if (takeItems.length == 0)
			{
				takeAllBttn.state = Button.DISABLED
			}
		}*/
		
		private var bgDecor:Bitmap;
		private function drawBackgroundElement():void
		{
			bgDecor = Window.backing(584, 438, 40, "storageBackingSmall");
			bodyContainer.addChild(bgDecor);
			bgDecor.x = (settings.width - bgDecor.width)/2;
			bgDecor.y = 99;
			bgDecor.alpha = 0.7;
		}
		
		public function refreshRazdel():void
		{
			if (settings.mode == FREE) return;
			
			settings.content.take = App.user.gifts;
			paginator.itemsCount = settings.content.take.length;
			paginator.update();
			onChangeTake();
			
			if (settings.content.take.length == 0)
			{
				takeAllBttn.state = Button.DISABLED;
			}
		}	
		
		public function blockItems(block:Boolean = false):void
		{
			if (settings.mode == FREE) return;
			
			var item:TakeItem;
			if (!block) {
				for each(item in items)
					item.takeBttn.state = Button.NORMAL;
			}else{
				for each(item in items)
					item.takeBttn.state = Button.DISABLED;
			}
		}
	}	
}


import adobe.utils.CustomActions;
import buttons.Button;
import buttons.ImageButton;
import com.greensock.plugins.ShortRotationPlugin;
import com.greensock.TweenMax;
import core.AvaLoad;
import core.Load;
import flash.display.Shape;
import ui.UserInterface;
import units.Storehouse;
import wins.FreeGiftsWindow;
import wins.GiftWindow;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import wins.Window;

internal class FreeGiftItem extends Sprite
{
	public var sID:uint;
	private var info:Object;
	private var bitmap:Bitmap;
	public var bg:Bitmap;
	public var giftBttn:Button;
	public var wishBttn:ImageButton;
	public var win:FreeGiftsWindow;
	private var preloader:Preloader = new Preloader();
	
	public function FreeGiftItem(sID:uint, window:FreeGiftsWindow)
	{
		win = window;
		info = App.data.storage[sID];
		this.sID = sID;
		bg = Window.backing(170, 198, 10, "itemBacking");
		addChild(bg);
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2 - 15;
		
		drawBitmap();

		drawTitle();
		drawBttn();
		
		if (window.settings.find != null && window.settings.find.indexOf(int(sID)) != -1) {
			glowing();
		}
	}
	
	private function drawBttn():void
	{
		giftBttn = new Button({
								caption		:Locale.__e("flash:1382952380118"),
								width		:126,
								height		:36,
								fontSize	:24,
								onMouseDown :onGiftBttn,
								hasDotes:false
				});
				
		addChild(giftBttn);
		giftBttn.x = (bg.width - giftBttn.width) / 2;
		giftBttn.y = bg.height - giftBttn.height - 10;
		
		
		wishBttn = new ImageButton(Window.textures.wishlistBttn);
		addChild(wishBttn);
		wishBttn.tip = function():Object { 
					return {
						title:"",
						text:Locale.__e("flash:1382952380013")
					};
				};
		
		wishBttn.x = 0;
		wishBttn.y = 40;
		wishBttn.addEventListener(MouseEvent.CLICK, onWishEvent);
	}
	
	private function onWishEvent(e:MouseEvent):void
	{
		trace("click_____wish");
		App.wl.show(sID, e);
	}
	
	private function onGiftBttn(e:MouseEvent):void
	{
		win.close();
		
		new GiftWindow( {
			sID:		this.sID,
			iconMode:	GiftWindow.FREE_GIFTS,
			itemsMode:	GiftWindow.FRIENDS
		}).show();
	}

	private function drawBitmap():void
	{
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		Load.loading(Config.getIcon(info.type, info.preview), onPreviewComplete);
		
		sprite.tip = function():Object { 
			return {
				title:info.title,
				text:info.description
			};
		};
	}
		
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.x = (bg.width - bitmap.width)/ 2;
		bitmap.y = (bg.height - bitmap.height)/ 2 - 10;
	}
	
	public function dispose():void
	{
		if (giftBttn) giftBttn.dispose();
	}
	
	private function drawTitle():void
	{
		var title:TextField = Window.drawText(info.title, {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			multiline:true,
			wrap:true,
			width:bg.width - 50
		});
			
		//title.wordWrap = true;
		//title.width = bg.width - 50;
		title.y = 10;
		title.x = (bg.width - title.width)/2;
		addChild(title);
	}
	
	private function glowing():void {
		
		customGlowing(bg, glowing);
		if (win.settings['icon'] != undefined && win.settings.icon == 'wishlist') {
			customGlowing(wishBttn);
		}else{
			if (giftBttn) {
				customGlowing(giftBttn);
			}
		}
	}
	
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null) {
					callback();
				}
			}});	
		}});
	}
}


import wins.Window;
import wins.FreeGiftsWindow;
import wins.StockWindow;
			
internal class TakeItem extends Sprite
{ 
	public var bg:Bitmap;	
	public var data:Object;
	public var win:FreeGiftsWindow;
	
	private var imageCont:Sprite;
	private var bitmap:Bitmap;
	private var title:TextField;
	private var userTitle:TextField;
	private var counter:TextField;
	
	private var regiftBttn:Button;
	public var takeBttn:Button;
	public var closeBttn:ImageButton;
	
	private var avatar:Bitmap
	private var avaCont:Sprite
	
	private var message:Sprite
	private var cutText:String;
	private var fullText:String;
	private var messText:TextField;
	private var messBg:Bitmap;
	
	private var preloader:Preloader = new Preloader();
	private var avaPreloader:Preloader = new Preloader();
	
	private var friend:Object;
	
	public function TakeItem(settings:Object){
		
		this.data = settings.data;
		this.win = settings.window;
		
		bg = Window.backing(560, 136, 20, "itemBacking");
		addChild(bg);
		
		
		imageCont = new Sprite();
		
		
		//var contBg:Bitmap = Window.backing(110, 110, 10, "bonusBacking");
		var contBg:Sprite = new Sprite();
		//searchBg.graphics.lineStyle(2, 0x47424e, 1, true);
		contBg.graphics.beginFill(0xd7cda2, 1);
		contBg.graphics.drawRoundRect(0, 0, 130, 110, 30, 30);
		contBg.graphics.endFill();
		
		
		bitmap = new Bitmap();
		
		imageCont.addChild(contBg);
		imageCont.addChild(bitmap);
		
		addChild(imageCont);
		imageCont.x = (bg.width - imageCont.width) / 2 - 30;
		imageCont.y = (bg.height - imageCont.height) / 2;
		
		drawTitle();
		drawCount();
		//drawBttns();
		
		avaCont = new Sprite();
		avatar = new Bitmap();
		
		avaCont.addChild(avatar);
		addChild(avaCont);
		avaCont.x = 60;
		avaCont.y = 36;
		
		avaPreloader.x = 90;
		avaPreloader.y = 70;
		
		
		
		if (!App.user.friends.data[data.from]) {
			friend = { };
			friend['photo'] = Config.getImage('avatars', 'av_' + int(Math.random() * 2 + 1));
			friend['first_name'] = Locale.__e('flash:1382952380310');
		}else {
			friend = App.user.friends.data[data.from]
		}
		
		drawBttns();
		
		if (friend.hasOwnProperty('first_name')){
			drawAvatar();
		}else {
			addChild(avaPreloader);
			App.self.setOnTimer(checkOnLoad);
		}
		
		if (data.msg.length > 1)	drawMessage();
		
		addChild(preloader);
		preloader.x = imageCont.x + contBg.width / 2;
		preloader.y = imageCont.y + contBg.height / 2;
		
		Load.loading(Config.getIcon(App.data.storage[data.sID].type, App.data.storage[data.sID].preview), onLoad);
	}
	
	private function checkOnLoad():void 
	{
		if (friend.hasOwnProperty('first_name'))
		{
			App.self.setOffTimer(checkOnLoad);
			removeChild(avaPreloader);
			drawAvatar();
		}
	}
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.8;
		bitmap.x = 110 / 2 - bitmap.width / 2;
		bitmap.y = 110 / 2 - bitmap.height / 2;
		bitmap.smoothing = true;
	}
	
	private function drawAvatar():void
	{
		var sender:Object = friend;
		
		new AvaLoad(friend.photo, onAvaLoad);
		
		userTitle = Window.drawText(sender.first_name.substr(0, 16), App.self.userNameSettings({
									color:0x6d4b15,
									borderColor:0xfcf6e4,
									fontSize:22
								}));
		addChild(userTitle);
		userTitle.height = userTitle.textHeight;
		userTitle.width = userTitle.textWidth + 4;
		userTitle.x = 90 - userTitle.width / 2;
		userTitle.y = 8;
	}
	
	private function onAvaLoad(data:Bitmap):void
	{
		avatar.bitmapData = data.bitmapData;
		avatar.smoothing = true;
				
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 50, 50, 12, 12);
		shape.graphics.endFill();
		avaCont.mask = shape;
		avaCont.addChild(shape);
		
		var scale:Number = 1.3;
		
		avaCont.width *= scale;
		avaCont.height *= scale;
		
		//removeChild(avaPreloader);
	}
	
	private function drawBttns():void
	{
		regiftBttn = new Button({
			caption:				Locale.__e("flash:1382972712784"),
			multiline:				true,
			fontSize:				22,
			height:					50,
			width:					130,
			mouseDown:				onRegiftClick,
			hasDotes:false
		});
			
		addChild(regiftBttn);	
		regiftBttn.x = bg.width - regiftBttn.width - 50;
		regiftBttn.y = 18;
		regiftBttn.addEventListener(MouseEvent.CLICK, onRegiftClick);
			
		if (friend && !Gifts.canTakeFreeGift(data.from))
			regiftBttn.state = Button.DISABLED;
	
		takeBttn = new Button( {
			caption:Locale.__e("flash:1382952379786"),
			fontSize:22,
			height:40,
			width:130,
			onMouseDown:onTake,
			hasDotes:false
		});
			
		addChild(takeBttn);	
		takeBttn.x = bg.width - takeBttn.width - 50;
		takeBttn.y = 78;
		
		if (data.type == Gifts.SPECIAL || data.from == "1"){
			regiftBttn.visible = false;
			takeBttn.y = bg.height / 2 - takeBttn.height / 2;
		}
		
		closeBttn = new ImageButton(Window.textures.closeBttnSmall, {
				onMouseDown:onClose
			});
		addChild(closeBttn);
		closeBttn.x = bg.width - 36;
		closeBttn.y = bg.y - 5;
		closeBttn.addEventListener(MouseEvent.CLICK, onClose);
	}
	
	private function onClose(e:MouseEvent):void 
	{
		Gifts.remove(data.gID, function():void 
		{
			win.refreshRazdel();
		});
		win.updateCapasity();
	}
	
	private function onRegiftClick(e:MouseEvent):void
	{
		if (regiftBttn.mode == Button.DISABLED) return;
		
		win.close();
		
			//new StockWindow( /*{
				//target:stocks[0]
			//}*/).show();
			
		new GiftWindow( {
			//sID:		this.sID,
			iconMode:	GiftWindow.FREE_GIFTS,
			itemsMode:	GiftWindow.FRIENDS,
			find:data.from
		}).show();
	}
	
	private function drawTitle():void
	{
		title = Window.drawText(App.data.storage[data.sID].title, {
			color:0xfcfad9,
			borderColor:0x764a3e,
			textAlign:"center",
			autoSize:"center",
			fontSize:22,
			multiline:true,
			textLeading: -8
		});
		
		title.wordWrap = true;
		title.width = imageCont.width;
		imageCont.addChild(title);
		title.y = -2;
	}
	
	private function drawCount():void
	{
		counter = Window.drawText("x"+String(data.count), {
			color:0xfcfad9,
			borderColor:0x764a3e,
			fontSize:28
		});
		
		imageCont.addChild(counter);
		counter.x = imageCont.width - counter.textWidth - 10;//70;
		counter.y = 78;
	}
	
	public function dispose():void
	{
		App.self.setOffTimer(checkOnLoad);
	}
	
	private function showCutMessage(e:MouseEvent = null):void
	{
		if (messBg != null && message.contains(messBg)) 		message.removeChild(messBg);
		if (messText != null && message.contains(messText)) 	message.removeChild(messText);
		
		messBg = Window.backing(192, 60, 10, "textSmallBacking");
		message.addChild(messBg);
		
		messText = Window.drawText(cutText,
						{
							autoSize:"left",
							fontSize:17,
							border:false,
							color:0x6d4b15,
							multiline:true
						});
		messText.wordWrap = true;
		messText.width = 172;
		messText.height = 10;
		
		message.addChild(messText);
		messText.x = 10;
		messText.y = 10;
	}
	
	private function showFullMessage(e:MouseEvent = null):void
	{
		if (fullText == null || fullText == "") return;
		
		if (messBg != null && message.contains(messBg)) 		message.removeChild(messBg);
		if (messText != null && message.contains(messText)) 	message.removeChild(messText);
		
		messBg = Window.backing(352, 60, 10, "textSmallBacking");
		message.addChild(messBg);
		
		messText = Window.drawText(fullText,
						{
							autoSize:"left",
							fontSize:17,
							border:false,
							color:0x6d4b15,
							multiline:true
						});
		messText.wordWrap = true;
		messText.width = 332;
		messText.height = 10;
		
		message.addChild(messText);
		messText.x = 14;
		messText.y = 10;
	}
	
	public function drawMessage():void
	{
		message = new Sprite();
		message.addEventListener(MouseEvent.MOUSE_OVER, showFullMessage);
		message.addEventListener(MouseEvent.MOUSE_OUT, showCutMessage);
		message.buttonMode = true;
		message.mouseChildren = false;
		
		addChild(message);
		message.x = 0;
		message.y = 80;
		
		var text:String = data.msg;//"Привет, вот тебе подарочек от меня. Жду в ответ что-нибудь flash:1382952379993 моего списка желаний";
		if (text.length > 55)
		{
			fullText = text;
			cutText = "";
			var wordsArray:Array = text.split(" ");
			
			for (var i:int = 0; i < wordsArray.length; i++)
			{
				var Length:int = cutText.length + wordsArray[i].length;
				if (Length > 55)
				{
					cutText += "...";
					break;
				}
				else
				{
					cutText += " " + wordsArray[i];
				}
			}
		}
		else
		{
			cutText = text; 
			fullText = null;
		}
		
		showCutMessage();
	}
	
	private function onTake(e:MouseEvent):void
	{
		var rew:Object = { };
		rew[data.sID] = data.count;
		if (!App.user.stock.canTake(rew))
			return;
		
		Gifts.take(data.gID, function(block:Boolean):void 
		{
			if (block == true) {
				win.refreshRazdel();
				win.blockItems(block);
			}
			else
			{
				win.blockItems(block);
			}
		});
		//App.user.stock.add(data.sID, data.count);
		win.updateCapasity();
	}
}	