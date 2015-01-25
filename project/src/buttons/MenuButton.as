package buttons 
{
	import com.adobe.images.BitString;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import silin.filters.ColorAdjust;	
	import wins.Window;
	
	public class MenuButton extends Button
	{
		public var _selected:Boolean = false;
		public var type:* = "";
		public var additionalBitmap:Bitmap
		/**
		 * Конструктор
		 * @param	settings	пользовательские настройки кнопки
		 */
		public function MenuButton(settings:Object = null)
		{
			settings['widthPlus'] = settings.widthPlus || 40;
			settings['width'] = settings.width || String(settings.title).length * 8 + settings.widthPlus//26;
			settings['height'] = settings.height || 42;
			settings['caption'] = settings.title;
			
			settings["bgColor"] = settings.bgColor || [0xffdf96, 0xfdb165];/*settings.bgColor || [0x83caf7, 0x5dabdd];*///[0xf5cf56, 0xf1b733];	
			settings["borderColor"] = settings.borderColor || [0xc2e2f4, 0x3384b2];//[0x9d6249, 0x9d6249];
			settings["bevelColor"] =  settings.bevelColor ||[0xffc289, 0xc27644];	
			settings["fontColor"] = settings.fontColor || 0xffffff;				
			settings["fontBorderColor"] =settings.fontBorderColor || 0xa55c3b;
			
			settings['active'] = settings.active || {
				bgColor:				[0xe09850,0xecae73],
				borderColor:			[0xc27b45,0xffc285],	//Цвета градиента
				bevelColor:				[0xc27b45,0xffc285],	
				fontColor:				0xffffff,				//Цвет шрифта
				fontBorderColor:		0xaa5631				//Цвет обводки шрифта	
			}
			
			this.order = settings.order;
			this.type = settings.type;
			super(settings);
		}
		
		public function set selected(value:Boolean):void {		
			_selected = value;
			if (_selected)
				state = Button.ACTIVE;
			else
				state = Button.NORMAL;
		}
		
		public function glow():void{
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.inner = false;
			myGlow.color = 0xFFFFFF;
			myGlow.blurX = 10;
			myGlow.blurY = 10;
			myGlow.strength = 10;
			myGlow.alpha = 0.5;
			this.filters = [myGlow];
		}
	}
}
