package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class farm extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/farm.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/building.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-146,
				dy:-140
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-152,
				dy:-46
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function farm()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
