package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class den2 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/den2_1.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/den2_2.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-87,
				dy:-141
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-85,
				dy:-161
			}
		];
 
		
		
		
		public function den2()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
