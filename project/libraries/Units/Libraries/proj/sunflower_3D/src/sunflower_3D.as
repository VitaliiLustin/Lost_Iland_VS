package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class sunflower_3D extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/flower0.png", mimeType="image/png")]
		private var Stage0:Class;
		[Embed(source="sprites/flower1.png", mimeType="image/png")]
		private var Stage1:Class;
		[Embed(source="sprites/flower2.png", mimeType="image/png")]
		private var Stage2:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-42,
				dy:25
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-76,
				dy:-10
			},
			{
				bmp:new Stage2().bitmapData,
				dx:-126,
				dy:-69
			}
		];
 
		
		
		
		public function sunflower_3D()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
