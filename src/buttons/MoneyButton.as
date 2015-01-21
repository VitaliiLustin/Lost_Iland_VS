package buttons 
{
	import adobe.utils.CustomActions;
	import flash.display.Bitmap;
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
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import silin.filters.ColorAdjust;
	import ui.UserInterface;
	
	
	public class MoneyButton extends Button
	{
		public var type:* = "";
		public var countLabel:TextField;
		
		public var countText:int = 99;
		public var fontCountSize:int = 20;
		public var fontCountColor:uint = 0xDCFA9B;
		public var fontCountBorder:uint = 0x38510D;
		public var coinsIcon:Bitmap;
		
		private var countStyle:TextFormat = new TextFormat(); 
		
		public function MoneyButton(settings:Object = null) 
		{
			settings["width"]       = settings.width || 200;
			settings["height"] = settings.height || 44;
			settings['caption'] = settings.caption || "Купить";
			
			settings["bgColor"] = settings.bgColor || [0xa8f84a, 0x74bc17];//[0xa9f84a, 0x73bb16];//[0xf5cf56, 0xf1b733];	  [0x8dd529, 0x6e9e2d];
			settings["borderColor"] = settings.borderColor || [0xffffff, 0xffffff];//[0x9d6249, 0x9d6249];    [0x94F58B, 0x13820B];
			settings["bevelColor"] = settings.bevelColor || [0xc8fa8f, 0x5f9c11];//[0xc5fe78, 0x405c1a]//[0xfff270, 0xca7d00];	
			settings["fontColor"] = settings.fontColor || 0xffffff;				
			settings["fontBorderColor"] = settings.fontBorderColor || 0x4d7d0e;//0x354321;
			
			settings["fontCountColor"]	= settings.fontCountColor || 0xffffff;				//Цвет шрифта	          0xDCFA9B
			settings["fontCountBorder"] = settings.fontCountBorder || 0x4d7d0e;//0x354321;				//Цвет обводки шрифта	
			
			settings['iconScale'] = settings.iconScale || 0.55;
			
			settings["countText"] 		= settings.countText || 50;	
			
			
			settings["fontSize"]  = settings.fontSize || 22;
			settings["fontCountSize"] = settings.fontCountSize || 23;
			settings["fontBorderCountSize"] = 5;
			settings["radius"] = settings.radius || 16;
			
			this.order = settings.order;
			this.type = settings.type;
			super(settings);
		}
		
		public function set countLabelText(count:int):void {
			countText = count;
			countLabel.text = countText + "";
			countLabel.setTextFormat(countStyle);
		//	countLabel.border = true;
		}
		
		public function get countLabelText():int {
			return countText;
		}
		
		override protected function drawTopLayer():void {
			
			textLabel = new TextField();
			textLabel.mouseEnabled = false;
			textLabel.mouseWheelEnabled = false;
			
			textLabel.multiline = true;
			textLabel.antiAliasType = AntiAliasType.ADVANCED;
			textLabel.embedFonts = true;
			textLabel.sharpness = 100;
			textLabel.thickness = 50;
			//textLabel.autoSize = TextFieldAutoSize.LEFT

			textLabel.text = settings.caption;

			var style:TextFormat = new TextFormat(); 
			style.color = settings.fontColor; 
			style.size = settings.fontSize;
			style.font = settings.fontFamily;
			style.align = TextFormatAlign.CENTER;
			style.leading = settings.textLeading;
			textLabel.setTextFormat(style);
			var filter:GlowFilter = new GlowFilter(settings.fontBorderColor,1,settings.fontBorderSize,settings.fontBorderSize,10,1);
			textLabel.filters = [filter];	
			
			textLabel.x = 10;
			
			textLabel.width = textLabel.textWidth + 6;
			textLabel.height = textLabel.textHeight + 6;
			
			var deltaWidth:int = settings.setWidth?40:0;
			
			
			if (textLabel.width > (settings.width - deltaWidth)) {
				if(textLabel.text.indexOf(' ') != -1){
					textLabel.wordWrap = true;
				}
				textLabel.width = settings.width - deltaWidth - 10;
				textLabel.height = textLabel.textHeight + 8;
				while (textLabel.textHeight > bottomLayer.height || textLabel.textWidth > settings.width - deltaWidth - 10) {
					settings.fontSize -= 1;
					if (settings.fontSize  < 18) {
						style.leading = -3;
					}
					style.size = settings.fontSize;
					textLabel.setTextFormat(style);
					textLabel.height = textLabel.textHeight+8;
				}
			}
			//textLabel.border = true;
			
			//textLabel.y = (settings.height - textLabel.textHeight) / 2;
			if (deltaWidth == 0) {
				textLabel.x = (settings.width - textLabel.textWidth) / 2;
			}
			//textLabel.border = true;
			
			//topLayer.addChild(textLabel);
			
			countLabel = new TextField();
			countLabel.mouseEnabled = false;
			countLabel.mouseWheelEnabled = false;
			
			countLabel.antiAliasType = AntiAliasType.ADVANCED;
			countLabel.embedFonts = true;
			countLabel.sharpness = 100;
			countLabel.thickness = 50;

			countLabel.text = settings.countText + "";
			
			//countLabel.border = true;

			countStyle.color = settings.fontCountColor; 
			countStyle.size = settings.fontCountSize*App._fontScale;
			countStyle.font = settings.fontFamily;
			countStyle.align = TextFormatAlign.RIGHT;
			
			countLabel.setTextFormat(countStyle);
			
			var countFilter:GlowFilter = new GlowFilter(settings.fontCountBorder,1,settings.fontBorderCountSize,settings.fontBorderCountSize,10,1);
			countLabel.filters = [countFilter];	
			
			
			if(settings.type == "gold"){
				coinsIcon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
			}else {
				coinsIcon = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
			}
			
			if (settings.iconScale)
			{
				coinsIcon.scaleX = settings.iconScale;
				coinsIcon.scaleY = settings.iconScale;
			}
			
			textLabel.y = (bottomLayer.height - textLabel.height)/2 - 3;
			
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2;
			
			countLabel.y = (bottomLayer.height - countLabel.textHeight)/2;
			countLabel.height = countLabel.textHeight;
			countLabel.width = countLabel.textWidth + 6;
			
			var minX:int = textLabel.textWidth + textLabel.x + 10;
			
			textLabel.x = 0;
			coinsIcon.x = textLabel.x + textLabel.width + 4;
			countLabel.x = coinsIcon.x + coinsIcon.width + 4;
			
			topLayer.addChild(coinsIcon);
			topLayer.addChild(textLabel);
			topLayer.addChild(countLabel);
			
			
			topLayer.x = (settings.width - topLayer.width) / 2;
			if (settings.hasDotes)
				topLayer.x += 10;
			
			addChild(topLayer);
		}
		
		public function updatePos():void
		{
			if (settings.notChangePos) return;
			
			countLabel.y = (bottomLayer.height - countLabel.textHeight) / 2;
			textLabel.y = (bottomLayer.height - textLabel.height) / 2 - 3;
			coinsIcon.y = (bottomLayer.height - coinsIcon.height) / 2;
			
			topLayer.x = (settings.width - topLayer.width) / 2;
			
			if (settings.hasDotes)
				topLayer.x += 10;
		}
		
		//override protected function drawDownBottomLayer():void
		//{
			//super.drawDownBottomLayer();
			//var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.active.fontBorderColor,0.9,2,2,2,1);
			//countLabel.filters = [textFilter, shadowFilter];
		//}
		//
		//override protected function drawBottomLayer():void
		//{
			//super.drawDownBottomLayer();
			//textFilter = new GlowFilter(settings.fontBorderColor, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
			//var shadowFilter:DropShadowFilter = new DropShadowFilter(1,90,settings.fontBorderColor,0.9,2,2,2,1);
			//if(countLabel)countLabel.filters = [textFilter, shadowFilter];
		//}
		
		public function set count(number:String):void {
			countLabel.text = number;
			countLabel.setTextFormat(countStyle);
			countLabel.width = countLabel.textWidth + 6;
			
			updatePos();
		}
		
	}

}