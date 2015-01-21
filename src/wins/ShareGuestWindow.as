package wins 
{
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;

	public class ShareGuestWindow extends Window
	{
		private var items:Array = new Array();
		public var info:Object;
		public var back:Bitmap;
		
		public function ShareGuestWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 46;
			settings['fontBorderColor'] = 0xb6875b;
			settings['shadowBorderColor'] = 0x87582a;
			settings['fontBorderSize'] = 2;
			settings['description'] = getTextFormInfo('text6');
			
			settings['width'] = 640;
			settings['height'] = 330;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			
			settings['content'] = [];
			for (var sID:* in info.kicks) {
				var obj:Object = { sID:sID, count:info.kicks[sID].c };
				if (info.kicks[sID].hasOwnProperty('t')) {
					obj['t'] = info.kicks[sID].t;
				}
				settings['content'].push(obj);
			}
				
			settings['content'].sortOn('sID', Array.NUMERIC);
			super(settings);
		}
		
		private function drawStageInfo():void{
			
			var textSettings:Object = 
			{
				title		:getTextFormInfo('text5') + Locale.__e("flash:1382952380278", [1, info.count]),
				fontSize	:36,
				color		:0x564c45,
				borderColor	:0xf9f2dd
			}
			
			var titleText:Sprite = titleText(textSettings);
				titleText.x = (settings.width - titleText.width) / 2;
				titleText.y = 350;
				bodyContainer.addChild(titleText);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 45, "questBacking");
			layer.addChild(background);
			background.y = 30;
		}
		
		override public function drawBody():void {
			
			drawLabel(settings.target.textures.sprites[3].bmp);
			titleLabel.y += 20;
			titleLabelImage.y += 20;
			
			exit.x += 5;
			exit.y += 14;
			
			var back:Bitmap = Window.backing(590, 210,20, 'dialogueBacking');
			back.x = (settings.width - back.width)/2;
			back.y = 82;
			bodyContainer.addChild(back);
			
			drawItems();
			
			var descriptionLabel:TextField = drawText(Locale.__e(settings.description), {
				fontSize:22,
				autoSize:"left",
				textAlign:"center",
				color:0xffffff,
				borderColor:0x623518,
				textLeading:-9
			});
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = settings.width - 120;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 18;
			
			bodyContainer.addChild(descriptionLabel);	
			
			drawMirrowObjs('storageWoodenDec', 0, settings.width, 66, false, false, false, 1, -1);
		}
		
		private function drawItems():void {
			
			var container:Sprite = new Sprite();
			
			var X:int = 0;
			var Y:int = 0;
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var _item:ShareGuestItem = new ShareGuestItem(settings.content[i], this);
				container.addChild(_item);
				_item.x = X;
				_item.y = Y;
				items.push(_item);
				
				X += _item.bg.width + 22;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2 + 6;
			container.y = 125;
		}
		
		public function blockItems(value:Boolean):void {
			for each(var _item:ShareGuestItem in items) {
				if(value)
					_item.bttn.state = Button.DISABLED;
				else
					_item.bttn.state = Button.NORMAL;
			}
		}
		
		public function getTextFormInfo(value:String):String {
			var text:String = info[value];
			text = text.replace(/\r/, "");
			return Locale.__e(text);
		}
		
	}
}


import buttons.Button;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.elements.PriceLabel;
import wins.Window;

internal class ShareGuestItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	private var kicks:uint;
	private var type:uint;
	
	public function ShareGuestItem(obj:Object, window:*) {
		
		this.type = obj.t;
		this.sID = obj.sID;
		this.kicks = window.info.kicks[sID].c;
		this.item = App.data.storage[sID];
		this.window = window;
		
		bg = new Sprite();
		bg.graphics.beginFill(0xcbd4cf);
		bg.graphics.drawCircle(60, 60, 60);
		bg.graphics.endFill();
		addChild(bg);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();
		drawLabel();
		
		tip = function():Object 
		{
			return {
				title: Locale.__e(item.title),
				text: Locale.__e(item.description)
			}
		}
	}
	
	private var count_txt:TextField; 
	private var count:int; 
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:window.getTextFormInfo("flash:1382952380118"),
			width:110,
			height:36,
			fontSize:26
		}
		
		if(item.real == 0 || type == 1){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
		}
		
		bttn = new Button(bttnSettings);
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height + 30;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (item.real == 0 && App.user.friends.data[App.owner.id]['energy'] <= 0){
			bttn.state = Button.DISABLED;
		}
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		switch(type) {
			case 2:
				if (!App.user.stock.checkAll(item.price)) 
					return;
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) 
					return;
			break;
		}
		
		window.blockItems(true);
		window.settings.kickEvent(sID, onKickEventComplete, type);
	}
	
	private function onKickEventComplete():void {//sID:uint, price:uint
		
		var sID:uint;
		var price:uint;
		if (type == 1) {
			window.close();
			return;
		}
		else if (type == 2)
		{
			sID = Stock.FANT;
			price = item.price[sID];
		}
		else if (type == 3)
		{
			sID = this.sID;
			price = 1;
		}	
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		window.close();
	}	
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		addChildAt(bitmap, 1);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2;
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void {
		
		var title:TextField = Window.drawText(String(item.title), {
			color:0x814f31,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.y = -36;
		title.x = 5;
		addChild(title);
		
	}
	
	public function drawLabel():void {
		
		var bttnSettings:Object = {
			caption:window.getTextFormInfo('text7'),
			width:130,
			height:42,
			fontSize:26
		}
		
		if (item.real || type == 2) {
			
			bttnSettings['bgColor'] = [0xa8f749, 0x74bc17];
			bttnSettings['borderColor'] = [0x5b7385, 0x5b7385];
			bttnSettings['bevelColor'] = [0xcefc97, 0x5f9c11];
			bttnSettings['fontColor'] = 0xffffff;			
			bttnSettings['fontBorderColor'] = 0x4d7d0e;
			bttnSettings['fontCountColor'] = 0xc7f78e;
			bttnSettings['fontCountBorder'] = 0x40680b;		
		}
		
		var price:PriceLabel;
		var text:String = '';
		var hasButton:Boolean = true;
		if (type == 2) { // за кристалы
			price = new PriceLabel(item.price/*, {fontSize:24, fontColor:0x4d7d0e}*/);
			addChild(price);
			price.x = (bg.width - price.width) / 2;
			price.y = bg.height - 2;
		}
		else if (type == 3) { // со склада
			var part1:String = Locale.__e('flash:1409236136005');
			//part1 = part1.substr(0, part1.length - 1);
			text = part1 + ": " + String(App.user.stock.count(sID));
		}
		else if (type == 1) { // за фантазию
			var guests:Object = window.settings.target.guests;
			
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
			
			if (guests.hasOwnProperty(App.user.id) && guests[App.user.id] > 0 && guests[App.user.id] > App.midnight){
				text = Locale.__e("flash:1382952380288");//Один раз в день
				hasButton = false;
			}else{
				price = new PriceLabel({13:1}/*, {fontSize:24, fontColor:0x4d7d0e}*/);
				addChild(price);
				price.x = (bg.width - price.width) / 2;
				price.y = bg.height;
			}
		}
		
		var label:TextField;
		if(text != '')
		{
			label = Window.drawText(text, {
				color:0x793a17,
				borderColor:0xffffff,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				textLeading:-6,
				multiline:true
			});
			
			label.wordWrap = true;
			label.width = bg.width - 10;
			label.height = label.textHeight;
			label.y = bg.height;
			label.x = 5;
			addChild(label);
		}
		
		bttn = new Button(bttnSettings);
		if (!hasButton)
			return;
			
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height + 28;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if(type == 1 && App.user.friends.data[App.owner.id]['energy'] <= 0){
			bttn.state = Button.DISABLED;
		}else if(type == 3) {
			if (App.user.stock.count(sID) <= 0) {
				bttn.state = Button.DISABLED;
			}
		}
	}
}

