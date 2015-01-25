package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class rock7 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/4.png", mimeType="image/png")]
		private var Stage0:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-41,
				dy:-33
			}
		];
 
		
		
		
		public function rock7()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
