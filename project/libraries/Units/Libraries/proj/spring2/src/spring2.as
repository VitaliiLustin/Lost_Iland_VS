package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class spring2 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/2.png", mimeType="image/png")]
		private var Stage0:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-92,
				dy:-59
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function spring2()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
