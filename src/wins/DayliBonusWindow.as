package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	public class DayliBonusWindow extends Window
	{
		public var items:Array = new Array();
		private var back:Bitmap;
		private var okBttn:Button;
		public var currentDayItem:DayliItem
		
		public function DayliBonusWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 				= 640;
			settings['height'] 				= 250;
			settings['title'] 				= Locale.__e("flash:1382952380042");
			settings['hasPaginator'] 		= false;
			settings['content'] 			= [];
			settings['fontSize'] 			= 48;
			settings['shadowBorderColor']   = 0x342411;
			settings['fontBorderSize'] 		= 4;
			settings['hasExit'] 			= false;
			settings['faderClickable'] 		= false;
			
			for each(var item:Object in App.data.daylibonus)
			{
				settings.content.push(item);
			}
			
			super(settings);
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: true,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -35;
			bodyContainer.addChild(titleLabel);
			drawMirrowObjs('diamondsTop', titleLabel.x - 5, titleLabel.x + titleLabel.width + 5, titleLabel.y - 20, true, true);
			
			var descLabel:TextField = Window.drawText(Locale.__e("flash:1397115227646"), {
				fontSize	:28,
				color		:0xFFFFFF,
				borderColor	:0x5f2980,
				textAlign	:"center"
			});
			descLabel.width = descLabel.textWidth + 20;
			descLabel.x = titleLabel.x + (titleLabel.width - descLabel.width) / 2;
			descLabel.y = -5;
			bodyContainer.addChild(descLabel);
		}
		
		override public function drawBackground():void {
			back = Window.backing(755, 338, 20, 'questBacking');
			layer.addChild(back);
			back.x = (settings.width - back.width) / 2;
			back.y = -40;
			
			var storageWoodenDec:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
			var storageWoodenDec2:Bitmap = new Bitmap(Window.textures.storageWoodenDec);
			storageWoodenDec.x = back.x + 3;
			storageWoodenDec2.x = back.x + back.width - 3;
			storageWoodenDec.y = storageWoodenDec2.y = 38;
			storageWoodenDec2.scaleX *= -1;
			storageWoodenDec.scaleY *= -1;
			storageWoodenDec2.scaleY *= -1;
			layer.addChild(storageWoodenDec);
			layer.addChild(storageWoodenDec2);
			//drawMirrowObjs('storageWoodenDec', back.x + 3, back.x + back.width - 3, 38, false, false, false,1,-1 );
			drawMirrowObjs('storageWoodenDec', back.x + 3, back.x + back.width - 3, settings.height - 31);
			
			var backRibbon:Bitmap = backingShort(825, 'questRibbon');
			layer.addChild(backRibbon);
			backRibbon.y = back.y + 15;
			backRibbon.x = back.x + (back.width - backRibbon.width) / 2;
			
			titleLabel.y = back.y - titleLabel.height / 2;
			
			//var exit:ImageButton = new ImageButton(textures.closeBttn);
			//layer.addChild(exit);
			//exit.x = back.x + back.width - 47;
			//exit.y = back.y;
			//exit.addEventListener(MouseEvent.CLICK, close);
			
			
		}
		
		override public function drawBody():void {
			Load.loading(Config.getImage('promo/images', 'crystals'), function(data:Bitmap):void {
					var image:Bitmap = new Bitmap(data.bitmapData);
					headerContainer.addChildAt(image, 0);
					image.x = settings.width / 2 - image.width / 2;
					image.y = -80;
			});
			
			drawItems();
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952379737'),
				fontSize:28,
				width:199,
				height:49
			});
			
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = settings.height + 15;
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		private function onOkBttn(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			
			e.currentTarget.state = Button.DISABLED
			take();
		}
		
		private function drawItems():void {
			
			var container:Sprite = new Sprite();
			
			var X:int = 0;
			var Y:int = 10;
			
			for (var i:int = 0; i < 5; i++) {
				var item:DayliItem = new DayliItem(settings.content[i], this);
				
				if (item.itemDay == App.user.day)
				{
					container.addChild(item);
				}else
					container.addChildAt(item,0);
				item.x = X;
				item.y = Y;
				
				X += item.bg.width - 25;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 70;
		}
		
		public function take():void 
		{
			Post.send( {
				ctr:'user',
				act:'day',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				//if (App.social == 'FB') {						
					//ExternalApi._6epush([ "_event", { "event": "gain", "item": "daily_bonus" } ]);
				//}
				
				App.user.stock.addAll(data.bonus);
				
				for (var _sid:* in data.bonus) {
					var item:BonusItem = new BonusItem(_sid, data.bonus[_sid]);
					var point:Point = Window.localToGlobal(currentDayItem);
					point.y += 80;
					item.cashMove(point, App.self.windowContainer);
				}
				
				setTimeout(close, 300);
			});
		}
	}
}	


import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import ui.UserInterface;
import wins.DayliBonusWindow;
import wins.Window;
	

internal class DayliItem extends LayerX {
	
	private var item:Object;
	public var bg:Bitmap;
	public var win:DayliBonusWindow;
	private var title:TextField;
	private var sID:uint;
	private var count:uint;
	private var bitmap:Bitmap;
	private var status:int = 0;
	public var itemDay:int;
	private var check:Bitmap = new Bitmap(Window.textures.checkMark);
	
	public function DayliItem(item:Object, win:DayliBonusWindow) {
		
		this.win = win;
		this.item = item;
		itemDay = item.day;
		
		if (item.day == App.user.day) {
			status = 1;
			win.currentDayItem = this;
		}else if (item.day > App.user.day + 1)
			status = 0;
		else if (item.day == App.user.day + 1)
			status = 2;
		else if (item.day < App.user.day)
			status = -1;
			
		if (status == 1) {
			bg = Window.backing(164, 194, 10, 'shopSpecialBacking1');
			bg.y -= 35;
			bg.height += 38;
		}else
		{
			bg = Window.backing(164, 194, 10, 'itemBacking');
		}
		addChild(bg);
		if (item == null) return;
		
		for (var _sID:* in item.bonus) break;
		sID = _sID;
		count = item.bonus[_sID];
		
		drawTitle();
		drawCount();
		drawDay();
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:Bitmap):void {
			
			bitmap.bitmapData = data.bitmapData;//new Bitmap(data.bitmapData);
			//addChild(bitmap);
			
			if(sID == Stock.EXP)
				bitmap.scaleX = bitmap.scaleY = 0.8;
			else
				bitmap.scaleX = bitmap.scaleY = 0.9;
				
			bitmap.smoothing = true;
			
			bitmap.x = (bg.width - bitmap.width) / 2;
			bitmap.y = 90 - bitmap.height / 2;
			
			if (sID == Stock.FANT) return;
			if (status == 0 || status == 2){
				UserInterface.effect(bitmap, 0, 0.8);
			}
		});
		drawMark();
		
		if (status == 0 || status == 2){
			UserInterface.effect(bg, -0.15, 0.65);
		}
		
		if (status == 1) {
			this.showGlowing();
		}
	}
	
	private function drawMark():void 
	{
		if (status == -1)
		{
			addChild(check);
		}
		check.x = 50;
		check.y = 60;
	}
	
	private function drawTitle():void
	{
		title = Window.drawText(App.data.storage[sID].title, {
			color:0x773c18,
			borderColor:0xfaf9eb,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.y = 8;
		title.x = 5;
		addChild(title)
	}
	
	private function drawDay():void
	{
		var textSettings:Object = {
			color:0xfff5e3,
			borderColor:0x855729,
			fontSize:28,
			textAlign:"center",
			autoSize:"center",
			textLeading:-6,
			multiline:true
		}
		
		var text:String = Locale.__e('flash:1382952380043', [item.day]);
		
		if(status == 1){
			text = Locale.__e("flash:1382952380044");
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x603306;
			textSettings['fontSize'] = 32;
		}
			
		if(status == 2){
			text = Locale.__e("flash:1383041362368");
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x603306;
			textSettings['fontSize'] = 28;
		}	
		if(status == 0){
			textSettings['color'] = 0xFFFFFF;
			textSettings['borderColor'] = 0x603306;
			textSettings['fontSize'] = 28;
		}
		
		var title:TextField = Window.drawText(text, textSettings);
		title.wordWrap = true;
		title.width = bg.width;
		title.y = -25;
		title.x = 0;
		addChild(title)
		
		if (status == 1)
			title.y -= 2;
	}
	
	private function drawCount():void
	{
		var countText:TextField = Window.drawText("+" + String(count), {
			color:0xffffff,
			borderColor:0x682f1e,
			textAlign:"center",
			autoSize:"center",
			fontSize:32,
			textLeading:-6,
			multiline:true
		});
		countText.wordWrap = true;
		countText.width = bg.width;
		countText.y = 140;
		countText.x = 0;
		addChild(countText)
		
	}
}

