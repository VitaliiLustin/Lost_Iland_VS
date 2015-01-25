package buttons 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import silin.filters.ColorAdjust;
	import com.greensock.*
	import wins.Window;
	
	
	public class ContextBttn extends Button
	{
		
		public var bitmapData:BitmapData;
		public var bitmapDataAdded:BitmapData;
		private var back:*;
		public var ID:uint;
		public var iconBitmap:Bitmap
				
		public function ContextBttn(settings:Object = null) 
		{
			//this.bitmapData = bitmapData;
			settings['backAlpha'] = 1;
			settings['fontSize'] = 18;
			
			if (settings == null) {
				settings = new Object();
			}
			
			super(settings);
			ID = settings.ID
		}
		
		
		override protected function MouseOver(e:MouseEvent):void {
			if (mode == Button.NORMAL) {
				back.alpha = 1;
				effect(0.1);
			}
		}
		
		override protected function MouseOut(e:MouseEvent):void {			
			if (mode == Button.NORMAL) {
				back.alpha = settings.backAlpha;
				effect(0,1);
			}
		}
		
		public function setText(txt:String):void
		{
			textLabel.text = txt
			textLabel.setTextFormat(style);
		}
		
		override protected function drawBottomLayer():void{
			
			//back = settings.back;
			back = Window.shadowBacking(settings.width, settings.height, 12);
			bottomLayer.addChild(back);
			back.alpha = settings.backAlpha;
			addChildAt(bottomLayer, 0);
			
			if (settings.icon == null) return;
			
			iconBitmap = new Bitmap(settings.icon);
			iconBitmap.smoothing = true;
			bottomLayer.addChild(iconBitmap)
			
			if (settings.icon_dx == null) settings.icon_dx = 0;
			if (settings.icon_dy == null) settings.icon_dy = 0;
			
			if (settings.icon_sx != null) iconBitmap.scaleX = settings.icon_sx;
			if (settings.icon_sy != null) iconBitmap.scaleY = settings.icon_sy;
			
			iconBitmap.x = 16 - iconBitmap.width / 2 + settings.icon_dx;
			iconBitmap.y = 16 - iconBitmap.height / 2 + settings.icon_dy;
		}	
		
		override protected function drawTopLayer():void {
			
			super.drawTopLayer();
			
			textLabel.height = textLabel.textHeight;
			textLabel.y = 6;
			textLabel.x = 14;
			textLabel.width = bottomLayer.width - textLabel.x - 5
		}
		
		/*override protected function drawBottomLayer(){
			var bitmap = new Bitmap(bitmapData,"auto",true);
						
			bottomLayer.addChild(bitmap);
			bitmap.x = (bottomLayer.width - bitmap.width) / 2;
			bitmap.y = (bottomLayer.height - bitmap.height) / 2;
						
			bitmap.scaleX = settings.scaleX;
			if(settings.scaleX < 0){
				bitmap.x += -bitmap.width * settings.scaleX;
			}
		
			bitmap.scaleY = settings.scaleY;
			if(settings.scaleY < 0){
				bitmap.y += -bitmap.height * settings.scaleY;
			}
			

			if(settings.shadow){
				if(settings.shadowFilter ==null){
					var filter:DropShadowFilter = new DropShadowFilter(0, 90, 0x000000, 1, 5, 5, 0.5);
					bitmap.filters = [filter];
				}else {
					bitmap.filters = [settings.shadowFilter];
				}
			}
			
			if (settings.filters != null) {
				for each(var filter in settings.filters) {
					bottomLayer.filters.push(filter);
				}
			}
			
			addChild(bottomLayer);
		}	
		
		override public function enable() {
			this.filters = [];
			this.mouseChildren = true;
			effect(0,1);
		}	
		
		override public function active() {
			effect(-0.2, 0.2)
		}	
		
		override protected function MouseOver(e:MouseEvent) {
			if(mode == Button.NORMAL){
				effect(0.1);
			}
		}
		
		override protected function MouseOut(e:MouseEvent) {			
			if(mode == Button.NORMAL){
				effect(0,1);
			}
		}
		
		override protected function MouseDown(e:MouseEvent) {			
			if(mode == Button.NORMAL){
				effect(-0.1);
				if(onMouseDown != null){
					onMouseDown(e);
				}					
			}
		}
		
		override protected function MouseUp(e:MouseEvent) {			
			if(mode == Button.NORMAL){
				effect(0.1);
				if(onMouseUp != null){
					onMouseUp(e);
				}
			}
		}*/	
		
		
	}

}