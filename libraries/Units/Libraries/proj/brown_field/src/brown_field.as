package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class brown_field extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/base.png", mimeType="image/png")]
		private var Stage0:Class;
		[Embed(source="sprites/front_frame.png", mimeType="image/png")]
		private var Stage1:Class;
		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-133,
				dy:-43
			},
			{
				bmp:new Stage0().bitmapData,
				dx:-133,
				dy:-43
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-119,
				dy:8
			}
		];

		public function brown_field()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
