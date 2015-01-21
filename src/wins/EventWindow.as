package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import wins.elements.OutItem;
	
	public class EventWindow extends Window
	{
		public var item:Object;
		
		public var background:Bitmap;
		public var bitmap:Bitmap;
		public var title:TextField;
		
		private var buyBttn:MoneyButton;
		
		private var sID:uint;
		private var need:uint;
		private var container:Sprite;
		
		private var partList:Array = [];
		private var padding:int = 10;
		public var outItem:OutItem;
		public var eventBttn:Button;
		
		public function EventWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['sID'] = settings.sID || 0;
			
			settings["width"] = 300;
			settings["height"] = 320;
			settings["popup"] = true;
			settings["fontSize"] = 30;
			settings["callback"] = settings["callback"] || null;
			settings["hasPaginator"] = false;
			settings["bttnCaption"] = settings.bttnCaption || Locale.__e("flash:1382952380090");
			
			sID = settings.sID;
			need = settings.need;
			
			settings["title"] = settings.target.info.title;
			
			super(settings);	
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = backing(settings.width, settings.height, 30, "windowBacking");
			//layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		override public function drawBody():void {
			
			if (settings.hasDescription) settings.height += 40;
			titleLabel.y = 2;
			
			drawDescription();
			
			createItems();
			
			var background:Bitmap = backing(settings.width, settings.height, 30, "windowBacking");
			layer.addChild(background);
			
			exit.x = settings.width - exit.width + 12;
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			
			container.x = padding;
			container.y = 6;
			
			eventBttn = new Button({
				caption		:settings.bttnCaption,
				width		:190,
				height		:38,	
				fontSize	:26
			});
			
			bodyContainer.addChild(eventBttn);
			eventBttn.x = (settings.width - eventBttn.width) / 2;
			eventBttn.y = settings.height - eventBttn.height - 10; 
			
			if (App.user.stock.data[sID] >= need)
				eventBttn.visible = true;
			else
				eventBttn.visible = false;
				
			eventBttn.addEventListener(MouseEvent.CLICK, onClick);	
		}
		
		private function onClick(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) 
				return;
			e.currentTarget.state = Button.DISABLED;
			settings.onWater();
			close();
		}
		
		private function drawDescription():void {
			
			var text1:TextField = drawText(Locale.__e(settings.description), {
				fontSize:20,
				color:0x5a524c,
				borderColor:0xfaf1df,
				textAlign:'center',
				multiline:true
			});
			
			text1.width = settings.width;
			bodyContainer.addChild(text1);
			text1.x = 0;
			text1.y = 17;
		}
		
		private function createItems():void
		{
			container = new Sprite();
			
			var inItem:MaterialItem = new MaterialItem({
				sID:sID,
				need:need,
				window:this, 
				type:MaterialItem.IN,
				bitmapDY:-10
			});
				
			inItem.checkStatus();
			inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial);
			
			inItem.x = (settings.width - inItem.background.width) / 2 - 10;
			inItem.y = 60;
			
			container.addChild(inItem);
			bodyContainer.addChild(container);
		}
		
		public function onUpdateOutMaterial(e:WindowEvent):void {
			if (App.user.stock.data[sID] >= need)
				eventBttn.visible = true;
			else
				eventBttn.visible = false;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}		
}
