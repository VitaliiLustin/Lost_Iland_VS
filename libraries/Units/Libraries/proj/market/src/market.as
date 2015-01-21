package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class market extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/market_construction_web.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/market_building_web.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-141,
				dy:-72
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-132,
				dy:-78
			}
		];
 
		
		
		
		public function market()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
