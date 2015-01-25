package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MixedButton;
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.geom.Point;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.ProductionItem;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class TravelWindow extends Window
	{
		public var items:Array = [];
		public static var history:int = 0;
		public static var maps:Array = [];
		
		public function TravelWindow(settings:Object = null)
		{
			if (settings == null) settings = { };
			
			settings['title'] = Locale.__e("flash:1382952380311");
			settings['width'] = settings.width || 740;
			settings['height'] = settings.height || 420;
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 3;
			//settings['page'] = history;
			settings['hasPaginator'] = false;
			
			//if (maps.length == 0)
				initContent();
			
			super(settings);
		}
		
		override public function drawBackground():void 
		{
				
		}
		
		private var currItem:int = 0;
		private var totalMaps:int;
		private function initContent():void 
		{
			//App.user.worldID
			maps = [];
			var num:int = 0;
			for (var id:String in App.data.storage) {
				var item:Object = App.data.storage[id];
				if (item.type == 'Lands' && id != '332') {
					if (id == String(App.user.worldID)) currItem = num;
					maps.push(id);
					num += 1;
				}
			}
			
			totalMaps = maps.length;
		}
		
		public var subTitle:TextField;
		
		private var leftArrow:ImageButton;
		private var rightArrow:ImageButton;
		override public function drawBody():void 
		{
			exit.y -= 70;
			titleLabel.y += 10;
			
			drawBttns();
			
			contentChange();
			
			leftArrow = new ImageButton(Window.textures.arrow);
			leftArrow.scaleX = -1;
			
			
			rightArrow = new ImageButton(Window.textures.arrow);
			
			
			leftArrow.x = 60;
			rightArrow.x = 700;
			
			leftArrow.y = rightArrow.y = 126;
			
			if (currItem == 0) {
				leftArrow.state = Button.DISABLED;
				leftArrow.alpha = 0.5;
			}else if (currItem == items.length-1) {
				rightArrow.state = Button.DISABLED;
				rightArrow.alpha = 0.5;
			}
			
			leftArrow.addEventListener(MouseEvent.CLICK, onLeft);
			rightArrow.addEventListener(MouseEvent.CLICK, onRight);
			
			bodyContainer.addChild(leftArrow);
			bodyContainer.addChild(rightArrow);
		}
		
		private var travelBttn:Button;
		private var openBttn:Button;
		private function drawBttns():void 
		{
			travelBttn = new Button( {
				height:66,
				width:206,
				caption:Locale.__e('flash:1393584440735'),
				fontSize:34
			});
			bodyContainer.addChild(travelBttn);
			travelBttn.x = 280;
			travelBttn.y = 340;
			travelBttn.visible = false;
			
			openBttn = new Button( {
				height:66,
				width:206,
				caption:Locale.__e('flash:1382952379890'),
				fontSize:34
			});
			bodyContainer.addChild(openBttn);
			openBttn.x = 280;
			openBttn.y = 340;
			openBttn.visible = false;
			
			travelBttn.addEventListener(MouseEvent.CLICK, onTravel);
			openBttn.addEventListener(MouseEvent.CLICK, onOpen);
		}
		
		private function onOpen(e:MouseEvent):void 
		{
			
		}
		
		private function onTravel(e:MouseEvent):void 
		{
			if (focusItem.sID != App.map.id)
				Travel.goTo(focusItem.sID);
			
			close();
		}
		
		private var isRight:Boolean = false;
		private function onRight(e:MouseEvent):void 
		{
			if (rightArrow.mode == Button.DISABLED || doingSlide) return;
			
			leftArrow.state = Button.NORMAL;
			leftArrow.alpha = 1;
			
			isRight = true;
			if (currItem >= items.length) currItem = items.length - 1;
			doSlide();
		}
		
		private function onLeft(e:MouseEvent):void 
		{
			if (leftArrow.mode == Button.DISABLED || doingSlide) return;
			
			rightArrow.state = Button.NORMAL;
			rightArrow.alpha = 1;
			
			isRight = false;
			if (currItem < 0) currItem = 0;
			doSlide();
		}
		
		private function removeSlideStaff():void
		{
			if (leftItem) {
				leftItem.removeEventListener(MouseEvent.CLICK, onLeft);
				leftItem = null;
			}
			if (rightItem) {
				rightItem.removeEventListener(MouseEvent.CLICK, onRight);
				rightItem = null;
			}
			if (focusItem) {
				focusItem.removeEventListener(MouseEvent.CLICK, onTravel);
				focusItem = null;
			}
			if (tween1) {
				tween1.kill();
				tween1 = null;
			}
			if (tween2) {
				tween2.kill();
				tween2 = null;
			}
			if (tween3) {
				tween3.kill();
				tween3 = null;
			}
			if (tween4) {
				tween4.kill();
				tween4 = null;
			}
		}
		
		private var container:Sprite = new Sprite();
		private var doingSlide:Boolean = false;
		
		private var tween1:TweenLite;
		private var tween2:TweenLite;
		private var tween3:TweenLite;
		private var tween4:TweenLite;
		private function doSlide():void
		{
			var item1:TravelItem;
			var item2:TravelItem;
			var item3:TravelItem;
			var item4:TravelItem;
			
			removeSlideStaff();
			
			doingSlide = true;
			
			if (currItem >= 1) {
				item1 = items[currItem - 1];
			}
			item2 = items[currItem];
			if (currItem < items.length-1) {
				item3 = items[currItem + 1];
			}
			
			if (!isRight) {
				if (currItem -2 >= 0) {
					item4 = items[currItem - 2];
				}
				if (item3) tween3 = TweenLite.to(item3, 0.5, { x:item3.x + 60, y:item3.y + 20,  scaleX:0.5, scaleY:0.5, alpha:0, onComplete:function():void { container.removeChild(item3); doingSlide = false } } );
				if (item2) {
					tween2 = TweenLite.to(item2, 0.7, { x:pos3.x, y:pos3.y, scaleX:0.7, scaleY:0.7 } );
					rightItem = item2;
					rightItem.addEventListener(MouseEvent.CLICK, onRight);
				}
				tween1 = TweenLite.to(item1, 0.7, { x:pos2.x, y: pos2.y, scaleX:1, scaleY:1, onComplete:function():void { doingSlide = false }  } );
				if (item4) {
					container.addChild(item4);
					item4.alpha = 0;
					item4.scaleX = item4.scaleY = 0.5;
					item4.x = pos1.x - 20; item4.y = pos1.y + 20;
					tween4 = TweenLite.to(item4, 0.7, { x:pos1.x, y:pos1.y, alpha:1, scaleX:0.7, scaleY:0.7 } );
					leftItem = item4;
					leftItem.addEventListener(MouseEvent.CLICK, onLeft);
				}
				currItem--;
				if (currItem <= 0) {
					leftArrow.state = Button.DISABLED;
					leftArrow.alpha = 0.5;
				}
				
				focusItem = item1;
				focusItem.addEventListener(MouseEvent.CLICK, onTravel);
			}else {
				if (currItem + 2 < items.length) {
					item4 = items[currItem + 2];
				}
				
				leftItem = item2;
				leftItem.addEventListener(MouseEvent.CLICK, onLeft);
				
				if(item1)tween1 = TweenLite.to(item1, 0.5, {x:pos1.x-20, y:pos1.y+20,  scaleX:0.5, scaleY:0.5, alpha:0, onComplete:function():void{container.removeChild(item1)} } );
				tween2 = TweenLite.to(item2, 0.7, {x:pos1.x, y:pos1.y, scaleX:0.7, scaleY:0.7, onComplete:function():void { doingSlide = false } } );
				if(item3)tween3 = TweenLite.to(item3, 0.7, { x:pos2.x, y: pos2.y, scaleX:1, scaleY:1 } );
				if (item4) {
					container.addChild(item4);
					item4.alpha = 0;
					item4.scaleX = item4.scaleY = 0.5;
					item4.x = pos3.x + 60; item4.y = pos1.y + 20;
					tween4 = TweenLite.to(item4, 0.7, { x:pos3.x, y:pos3.y, alpha:1, scaleX:0.7, scaleY:0.7 } );
					rightItem = item4;
					rightItem.addEventListener(MouseEvent.CLICK, onRight);
				}
				
				currItem++;
				if (currItem >= items.length - 1) {
					rightArrow.state = Button.DISABLED;
					rightArrow.alpha = 0.5;
				}
				focusItem = item3;
				focusItem.addEventListener(MouseEvent.CLICK, onTravel);
			}
			updateBttns();
		}
		
		private var homeBttn:MixedButton;
		private function drawHomeBttn():void
		{
			if (App.user.worldID == User.HOME_WORLD)
				return;
				
			homeBttn = new MixedButton(Window.textures.bubble,{caption:Locale.__e("flash:1382952379764"),fontSize:24});
			homeBttn.textLabel.x -= 2;
			bodyContainer.addChild(homeBttn);
			homeBttn.x = (settings.width - homeBttn.width)/2;
			homeBttn.y = settings.height - homeBttn.height - 36;
			homeBttn.addEventListener(MouseEvent.CLICK, onHomeClick);
		}
		
		private function onHomeClick(e:MouseEvent):void
		{
			close();
			if (App.user.worldID != User.HOME_WORLD){
				MapWindow.onDreamEvent(User.HOME_WORLD);
			}
		}
		
		private var leftItem:TravelItem;
		private var rightItem:TravelItem;
		private var focusItem:TravelItem;
		
		private var pos1:Point;
		private var pos2:Point;
		private var pos3:Point;
		
		override public function contentChange():void 
		{	
			bodyContainer.addChild(container);
			container.x = 54;
			container.y = 70;
			
			var itemsX:int = 0;
			var itemsY:int = 0;
			
			var startCount:int = currItem-1;
			var endCount:int = currItem + 1;
			
				
			for (var i:int = 0; i < maps.length; i++ ) {
				var it:TravelItem = new TravelItem(this, maps[i]);
				items.push(it);
			}
			
			if (startCount < 0)
				startCount = 0;
			if (endCount > items.length-1)
				endCount = items.length-1;
			
				
			if (currItem == 0) {
				itemsX += (items[0].bg.width - 66);
			}
				
			for (i = startCount; i <= endCount; i++)
			{
				var item:TravelItem = items[i];
				container.addChild(item);
				
				item.x = itemsX;
				item.y = itemsY;
				
				if (i == currItem) {
					itemsX += item.bg.width + 10;
					item.y -= 46;
					focusItem = item;
					focusItem.addEventListener(MouseEvent.CLICK, onTravel);
				}else {
					if (i == currItem - 1) {
						leftItem = item;
						leftItem.addEventListener(MouseEvent.CLICK, onLeft);
					}else {
						rightItem = item;
						rightItem.addEventListener(MouseEvent.CLICK, onRight);
					}
					item.scaleX = item.scaleY = 0.7;
					itemsX += item.bg.width - 66;
				}
			}
			
			pos1 = new Point(0,0);
			pos2 = new Point(item.bg.width - 66,-46);
			if (currItem == items.length-1) {
				pos3 = new Point(itemsX,0);
			}else {
				pos3 = new Point(itemsX - (item.bg.width - 66),0);
			}
			
			history = settings.page;
			
			updateBttns();
		}
		
		private function updateBttns():void 
		{
			if (focusItem.open) {
				travelBttn.visible = true;
				openBttn.visible = false;
			}else {
				travelBttn.visible = false;
				openBttn.visible = true;
			}
			
			if (focusItem.sID == App.map.id) {
				travelBttn.visible = false;
				openBttn.visible = false;
			}
		}
		
		override public function dispose():void {
			
			removeSlideStaff();
			
			pos1 = null;
			pos2 = null;
			pos3 = null;
			
			for (var i:int = 0; i < items.length; i++ ) {
				items[i].dispose();
				items[i] = null;
			}
			items.splice(0, items.length);
			
			leftArrow.removeEventListener(MouseEvent.CLICK, onLeft);
			rightArrow.removeEventListener(MouseEvent.CLICK, onRight);
			bodyContainer.removeChild(leftArrow);
			bodyContainer.removeChild(rightArrow);
			leftArrow.dispose();
			rightArrow.dispose();
			rightArrow = null;
			leftArrow = null;
			
			travelBttn.removeEventListener(MouseEvent.CLICK, onTravel);
			openBttn.removeEventListener(MouseEvent.CLICK, onOpen);
			travelBttn.dispose();
			openBttn.dispose();
			travelBttn = null;
			openBttn = null;
			
			maps.splice(0, maps.length);
			maps = [];
			
			super.dispose();
		}
	}
}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.setTimeout;
import silin.filters.ColorAdjust;
import ui.UserInterface;
import wins.Window;
import wins.SimpleWindow;
import wins.ShopWindow;
import wins.MapWindow;

internal class TravelItem extends LayerX {
	
	public var bg:Bitmap;
	public var win:*;
	public var sID:uint;
	private var bitmap:Bitmap;
	private var title:TextField;
	private var bttn:Button;
	private var item:Object;
	private var portal:uint;
	private var lock:Bitmap;
	
	private var bottomLayer:Sprite 		= new Sprite;
	
	public function TravelItem(win:*, sID:uint) {
		
		item = App.data.storage[sID];
		this.win = win;
		this.sID = sID;
		
		addChild(bottomLayer);
		
		addEventListener(MouseEvent.MOUSE_OVER, MouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, MouseOut);
		
		bg = new Bitmap(Window.textures.mapBacking);
		bg.smoothing = true;
		bottomLayer.addChild(bg);
		
		bitmap = new Bitmap();
		bottomLayer.addChild(bitmap);
		
		Load.loading(Config.getIcon(item.type, item.preview), function(data:Bitmap):void {
			bitmap.bitmapData = data.bitmapData;
			bitmap.x = (bg.width - bitmap.width) / 2;//16
			
			if (item.preview == "land0") {
				bitmap.x -= 4;
			}
			
			bitmap.y = bg.height - bitmap.height - 26;//(bg.height - bitmap.height) / 2;
			bitmap.smoothing = true;
		});
		
		//drawTitle();
		drawDesc();
		
		if (sID == App.user.worldID) drawPlaceInfo();
		
		checkStatus();
		if (!_open) {
			lock = new Bitmap();
			Load.loading(Config.getImage('interface', 'lock'), function(data:Bitmap):void {
				lock.bitmapData = data.bitmapData;
				lock.x = (bg.width - lock.width) / 2;
				lock.y = (bg.height - lock.height) / 2 - 16;
				lock.smoothing = true;
				bottomLayer.addChild(lock);
				UserInterface.effect(bitmap, 0, 0.5);
			});
		}	
		
		
		var that:* = this;
		setTimeout(function():void {
			if (App.user.quests.data[81] && App.user.quests.data[81].finished == 0 && sID == User.START_WORLD) {
				that.showGlowing();
				that.showPointing('top', 25, 0, that);
				//Tutorial.watchOn(that, 'top', false, { dy: 0 } );
				//that.addEventListener(MouseEvent.CLICK, _onClick, false, 3000);
			}
		}, 200);
	}
	
	private function _onClick(e:MouseEvent):void {
		App.tutorial.hide();
	}
	
	private function MouseOver(e:MouseEvent):void {
		effect(0.1);
	}
	
	private function MouseOut(e:MouseEvent):void {			
		effect(0, 1);
	}
	
	private function drawPlaceInfo():void 
	{
		var circle:Sprite = new Sprite();
        circle.graphics.beginFill(0xFF794B);
        circle.graphics.drawCircle(bg.width/2, bg.height/2 - 8, bg.width/2 - 16);
        circle.graphics.endFill();
        bottomLayer.addChild(circle);

		var square:Sprite = new Sprite();
		bottomLayer.addChild(square);
		square.alpha = 0.5;
		square.graphics.beginFill(0xffffff);
		square.graphics.drawRect(0,0,bg.width,70);
		square.graphics.endFill();
		square.y = bg.height - 90 - square.height;
		square.mask = circle;
		
		var placeTxt:TextField = Window.drawText(Locale.__e('flash:1393584410929'), {
			fontSize:44,
			color:0xffffff,
			borderColor:0x152449,
			multiline:true,
			textAlign:"center"
		});
		bottomLayer.addChild(placeTxt);
		placeTxt.x = (bg.width - placeTxt.textWidth) / 2;
		placeTxt.y = square.y + (square.height - placeTxt.textHeight) / 2;
	}
	
	public var _open:Boolean = false;
	private function checkStatus():void 
	{
		if(App.user.worlds.hasOwnProperty(sID))
			open = true;
		else
			open = false;
	}
	
	public function set open(value:Boolean):void {
		_open = value;
	}
	
	public function get open():Boolean {
		return _open;
	}
	
	private function drawDesc():void {
		
		var underTxt:Bitmap = Window.backingShort(210, 'homeBttnShort');
		underTxt.smoothing = true;
		bottomLayer.addChild(underTxt);
		underTxt.x = (bg.width - underTxt.width) / 2;
		underTxt.y = bg.height - underTxt.height - 10;
		
		title = Window.drawText(item.title, {
			fontSize:32,
			color:0xffffff,
			borderColor:0x2b3b64,
			multiline:true,
			textAlign:"center"
		});
		
		title.width = bg.width - 20;
		
		bottomLayer.addChild(title);
		title.x = underTxt.x + (underTxt.width - title.width) / 2;
		title.y = underTxt.y + (underTxt.height - title.textHeight) / 2 - 3;
	}
	
	public function effect(count:Number, saturation:Number = 1):void {
		if (count == 0) {
			bottomLayer.filters = [];
		}else{
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(count);
			bottomLayer.filters = [mtrx.filter];
		}
	}
	
	public function dispose():void
	{
		removeEventListener(MouseEvent.MOUSE_OVER, MouseOver);
		removeEventListener(MouseEvent.MOUSE_OUT, MouseOut);
	}
}
