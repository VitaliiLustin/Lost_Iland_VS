package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class windmill extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/building.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/build.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-140,
				dy:-61
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-76,
				dy:-196
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function windmill()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
