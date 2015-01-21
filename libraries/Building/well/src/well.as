package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class well extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		[Embed(source="sprites/build.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/wel.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-86,
				dy:-92
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-78,
				dy:-138
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function well()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
