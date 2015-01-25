package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class smithy extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/building.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/Forge.png", mimeType="image/png")]
		private var Stage1:Class;
		
		public var smokePoints:Array = [
			{dx: -41, dy: -256-5 }
		];
		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-143,
				dy:-40
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-114,
				dy:-118
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function smithy()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
