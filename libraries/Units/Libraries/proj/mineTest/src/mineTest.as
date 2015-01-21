package 
{
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.display.BitmapData;
	
	public class mineTest extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		
		
		public var sprites:Array = [

		];
 
		
		public var animation:Animation = new Animation();
		
		public function mineTest()
		{
			
		}
		
		public function getLevel(level:int = 0):Object
		{
			return sprites[level];
		}
	}
}
