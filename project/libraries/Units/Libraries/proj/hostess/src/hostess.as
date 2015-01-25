package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class hostess extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/hostess_construction_web.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/hostess_building_web.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-169,
				dy:-74
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-161,
				dy:-155
			}
		];
 
		
		public var animation:Animation = new Animation();
		
		public function hostess()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
