package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class white_field extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/16_building site_2_0.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/base.png", mimeType="image/png")]
		private var Stage1:Class;

		[Embed(source="sprites/front_frame.png", mimeType="image/png")]
		private var Stage2:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-176,
				dy:-145
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-138,
				dy:-38
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-138,
				dy:-38
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-132,
				dy:14
			}
		];
 
		
		
		
		public function white_field()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
