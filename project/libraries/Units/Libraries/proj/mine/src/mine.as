package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class mine extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/mine_construction_web.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/mine_building_web.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-136,
				dy:-128
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-142,
				dy:-139
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function mine()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
