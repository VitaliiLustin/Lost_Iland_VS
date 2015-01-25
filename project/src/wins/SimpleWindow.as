package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.text.TextFormatAlign;
	import flash.filters.GlowFilter;	
	import ui.Cursor;
	import ui.UserInterface;

	public class SimpleWindow extends Window
	{
		public static const MATERIAL:int = 1;
		public static const ERROR:int = 6;
		public static const COLLECTION:int = 8;
		public static const ATTENTION:int = 9;
		public static const BUILDING:int = 10;
		public static const TREASURE:int = 11;
		public static const CRYSTALS:int = 12;
		
		public var OkBttn:Button;
		public var ConfirmBttn:Button;
		public var CancelBttn:Button;
		
		public var textLabel:TextField = null;
		public var _titleLabel:TextField = null;
		
		private var bitmapLabel:Bitmap = null;
		private var dY:int = 0;
		private var dX:int = 0;
		private var textLabel_dY:int = 0;
		private var titleLabel_dY:int = 0;
		
		public function SimpleWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			//settings['background']      = "";
			settings['hasTitle']		= settings.hasTitle || false;
			settings['title'] 			= settings.title;
			settings["label"] 			= settings.label || null;
			settings['text'] 			= settings.text || '';
			settings['textAlign'] 		= settings.textAlign || 'center';
			settings['autoSize'] 		= settings.autoSize || 'center';
			settings['textSize'] 		= settings.textSize || 24;
			settings['padding'] 		= settings.padding || 20;
			settings['hasButtons']		= settings['hasButtons'] == null ? true : settings['hasButtons'];
			settings['dialog']			= settings['dialog'] || false;
			settings['buttonText']		= settings['buttonText'] || Locale.__e('flash:1382952380298');
			settings['confirmText']		= settings['confirmText'] || Locale.__e('flash:1382952380299');
			settings['cancelText']		= settings['cancelText'] || Locale.__e('flash:1383041104026');
			settings['confirm']			= settings.confirm || null;
			settings['cancel']			= settings.cancel || null;
			settings['ok']				= settings.ok || null;
			settings["width"]			= settings.width || 510;// 380;
			settings["height"] 			= settings.height || 210;// 365;
			settings["hasPaginator"] 	= false;
			settings["hasArrows"]		= false;
			settings["fontSize"]		= 38;
			settings["hasPaper"]	 	= true;
			settings["hasTitle"]		= true;
			settings["hasExit"]			= settings.hasExit || false;
			settings["fontColor"]       = 0xffffff//0xf5cf57;
			settings["hasExit"]         = true;
			settings["bitmap"]	 		= settings.bitmap || null;
		
			if (!settings.hasOwnProperty("closeAfterOk"))
			{
				settings["closeAfterOk"] = true
			}
			
			textLabel_dY = 0;
			
			super(settings);
		}
		override public function drawExit():void {
		}
			
		override public function drawBackground():void {
		}
		
		override public function drawBody():void {				
			if (settings.isImg) {
				var robotIcom:Bitmap = new Bitmap(Window.textures.errorStorage);
				bodyContainer.addChild(robotIcom);
				robotIcom.x = -110;
				robotIcom.y = -90;
			}
			
			drawBttns();
			
			var textFontSize:int;
			if (settings.title != null)
			{
				textFontSize = settings.textSize;
			}else
				textFontSize = settings.textSize + 8;
			textLabel = Window.drawText(settings.text, {
				color:0xffffff,
				borderColor:0x65371b,
				borderSize:4,
				fontSize:textFontSize,
				textAlign:settings.textAlign,
				autoSize:settings.autoSize,
				multiline:true
			});

			textLabel.wordWrap = true;
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			textLabel.width = settings.width - 100;
			textLabel.height = textLabel.textHeight + 4;
			
			var y1:int = titleLabel.y + titleLabel.height;
			var y2:int = bottomContainer.y;
			bodyContainer.addChild(textLabel);
			
			var back:Bitmap = backing2(/*backWidth*/textLabel.textWidth + 50, settings.height, 45, "questsSmallBackingTopPiece", 'questsSmallBackingBottomPiece');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2 -22;
			bodyContainer.addChildAt(back, 0);
			textLabel.x = back.x + (back.width - textLabel.width) / 2;
			textLabel.y = back.y + (back.height - textLabel.height) / 2 - 15;
			
			var exit:ImageButton = new ImageButton(textures.closeBttn);
			bodyContainer.addChild(exit);
			exit.x = back.x + back.width - 40;
			exit.y = back.y - 5;
			exit.addEventListener(MouseEvent.CLICK, close)
			
			
			
			
			if (settings.title != null) {
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, settings.titleHeight/2 + titleLabel.y + 2, true, true, true);
			}
			
			if (settings.hasOwnProperty('timer')) {
				drawTimer();
			}
		}
		
		private var timer:TextField
		private function drawTimer():void 
		{
			textLabel.y -= 20;
			timer = Window.drawText(TimeConverter.timeToStr(settings.timer), {
				color:0xffffff,
				letterSpacing:3,
				textAlign:"center",
				fontSize:35,
				borderColor:0x502f06
			});
			timer.width = settings.width - 60;
			timer.x = 30;
			timer.y = textLabel.y + textLabel.height + 10;
			
			var glowing:Bitmap = new Bitmap(Window.textures.actionGlow);
			glowing.alpha = 0.8;
			
			bodyContainer.addChildAt(glowing,0);
			glowing.x = (settings.width - glowing.width) / 2;
			glowing.y = timer.y + (timer.textHeight - glowing.height) / 2 - 25;
			
			bodyContainer.addChild(timer);
			
			App.self.setOnTimer(update);
		}
		
		private function update():void {
			settings.timer --;
			timer.text = TimeConverter.timeToStr(settings.timer);
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
				width				: settings.width - 80,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -35; //12
			bodyContainer.addChild(titleLabel);
		}
		
		public function drawBttns():void 
		{
			if (settings.hasButtons)
			{
				if(settings.dialog == false){
					OkBttn = new Button( {
						caption:settings.buttonText,
						fontSize:22,
						width:200,
						hasDotes:false,
						height:40
					});
					OkBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);//onOkBttn
				
					bottomContainer.addChild(OkBttn);
					OkBttn.x = settings.width / 2 - OkBttn.width / 2;
					
				}else{
					
					var confirmSettings:Object = {
						caption:settings.confirmText,
						width:140,
						hasDotes:false,
						height:40
					}
					
					var cancelSettings:Object = {
						caption:settings.cancelText,
						width:140,
						hasDotes:false,
						height:40
					}
					
					if (settings.hasOwnProperty('confirmSettings'))
						confirmSettings = settings.confirmSettings;
						
					if (settings.hasOwnProperty('cancelSettings'))
						cancelSettings = settings.cancelSettings;
					
					ConfirmBttn = new Button(confirmSettings);
					ConfirmBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);
					
					CancelBttn = new Button(cancelSettings);
					CancelBttn.addEventListener(MouseEvent.CLICK, onCancelBttn);
					
					ConfirmBttn.x = settings.width / 2 - ConfirmBttn.width/* + 4*/-4;
					CancelBttn.x = settings.width / 2/* - 4*/+4;
					
					bottomContainer.addChild(ConfirmBttn);
					bottomContainer.addChild(CancelBttn);
				}
			}
			
			bottomContainer.y = settings.height - bottomContainer.height - 36;
			bottomContainer.x = 0;
		}
		
		public function onOkBttn(e:MouseEvent):void {
			if (settings.ok is Function) {
				settings.ok();
			}
			if(settings.closeAfterOk)
				close();
		}
		
		public function onConfirmBttn(e:MouseEvent):void {
			if (settings.confirm is Function) {
				settings.confirm();
			}
			close();
		}

		public function onCancelBttn(e:MouseEvent):void {
			if (settings.cancel is Function) {
				settings.cancel();
			}
			close();
		}
		
		override public function dispose():void {
			if(OkBttn != null){
				OkBttn.removeEventListener(MouseEvent.CLICK, onOkBttn);
			}
			if(ConfirmBttn!= null){
				ConfirmBttn.removeEventListener(MouseEvent.CLICK, onConfirmBttn);
			}
			if(CancelBttn != null){
				CancelBttn.removeEventListener(MouseEvent.CLICK, onCancelBttn);
			}
			
			App.self.setOffTimer(update);
			super.dispose();
		}
	}
}