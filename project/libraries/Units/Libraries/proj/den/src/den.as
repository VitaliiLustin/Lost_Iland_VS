package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class den extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/den1_1.png", mimeType="image/png")]
		private var Stage0:Class;
		[Embed(source="sprites/den.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-89,
				dy:-55
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-93,
				dy:-56
			}
		];
 
		
		
		
		public function den()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
