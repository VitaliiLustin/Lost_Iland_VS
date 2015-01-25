package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class workshop extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/building.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/workshop.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var smokePoints:Array = [
			{dx:0, dy:0}
		];
		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-155,
				dy:-59
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-140,
				dy:-138
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function workshop()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
