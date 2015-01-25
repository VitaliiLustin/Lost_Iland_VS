package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class warehouse extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/build.png", mimeType="image/png")]
		private var Stage0:Class;

		[Embed(source="sprites/ready.png", mimeType="image/png")]
		private var Stage1:Class;

		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-115,
				dy:-49
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-126,
				dy:-244
			}/*,
			{
				bmp:new Stage1().bitmapData,
				dx:-126,
				dy:-244
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-126,
				dy:-244
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-126,
				dy:-244
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-126,
				dy:-244
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-126,
				dy:-244
			}*/
		];
 
		
		
		
		public function warehouse()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
