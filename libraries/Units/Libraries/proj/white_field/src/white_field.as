package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class white_field extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		[Embed(source="sprites/base.png", mimeType="image/png")]
		private var Stage0:Class;
		[Embed(source="sprites/front_frame.png", mimeType="image/png")]
		private var Stage1:Class;
		
		public var sprites:Array = [
			{
				bmp:new Stage0().bitmapData,
				dx:-125,
				dy: -45
			},
			{
				bmp:new Stage0().bitmapData,
				dx:-125,
				dy: -45
			},
			{
				bmp:new Stage1().bitmapData,
				dx:-119,
				dy: 7
			}
			
		];
 
		
		
		
		public function white_field()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
