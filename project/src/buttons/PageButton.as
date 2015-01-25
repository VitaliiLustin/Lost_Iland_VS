package buttons 
{
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
	import flash.filters.BitmapFilterQuality;	
	
	
	public class PageButton extends Button
	{
		public static const WIDTH:int = 32;
		public static const HEIGHT:int = 32;
		
		public var page:int = 0;
		
		public function PageButton(settings:Object = null) 
		{
			if (settings == null)
				settings = new Object();
			
			settings["width"] 					= settings.width || PageButton.WIDTH;	
			settings["height"] 					= settings.height || PageButton.HEIGHT;	
			settings["radius"] 					= 15;					//Радиус скругления
			settings["fontSize"]				= 18;					//Размер шрифта
			settings["bevelColor"] 				= [0xbaa48f, 0xb9a491];
			settings["bgColor"] 				= [0xffe092, 0xffb063];
			settings["borderColor"] 			= [0xffefdc, 0xbf7946];
			settings["fontColor"]	 			= 0xffffff;
			settings["fontBorderColor"] 		= 0x904116;
			
			settings['active'] = {
				bgColor:				[0xe3934c,0xe6984d],
				borderColor:			[0xc37a47,0xf9bd77],	//Цвета градиента
				bevelColor:				[0xb9a491,0xbaa48f],	
				fontColor:				0xffffff,				//Цвет шрифта
				fontBorderColor:		0x904116				//Цвет обводки шрифта		
			}
			
			settings["textAlign"]				= "center";	
			settings["caption"]					= settings.caption || "1";
			settings["shadow"]					= true;
			
			super(settings);
		}
	}
}