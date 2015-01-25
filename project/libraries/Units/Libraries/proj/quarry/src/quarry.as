package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class quarry extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/quarry_construction_web.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/quarry_building_web.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-114,
				dy:-39
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-115,
				dy:-100
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function quarry()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
