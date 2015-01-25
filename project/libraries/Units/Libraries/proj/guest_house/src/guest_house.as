package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class guest_house extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/hostess_mini_const_web.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/hostess_mini_building_web.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-92,
				dy:-90
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-105,
				dy:-151
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function guest_house()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
