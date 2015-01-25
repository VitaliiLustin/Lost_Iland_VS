package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class spring0 extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/stage_1.png", mimeType="image/png")]
		private var Stage0:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-98,
				dy:-22
			}
		];
 
		
		
		
		public function spring0()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
