package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -92;
		public var ay:int = -122;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:43 + 79, oy:-154.5 + 197, x:0, y:0, w:55, h:59},{ox:42 + 79, oy:-153.5 + 197, x:55, y:0, w:58, h:58},{ox:42 + 79, oy:-152.5 + 197, x:113, y:0, w:60, h:57},{ox:42 + 79, oy:-151.5 + 197, x:173, y:0, w:62, h:56},{ox:42 + 79, oy:-151.5 + 197, x:235, y:0, w:63, h:56},{ox:42 + 79, oy:-150.5 + 197, x:298, y:0, w:65, h:55},{ox:43 + 79, oy:-148.5 + 197, x:0, y:59, w:62, h:53},{ox:44 + 79, oy:-146.5 + 197, x:62, y:59, w:59, h:51},{ox:47 + 79, oy:-144.5 + 197, x:121, y:59, w:54, h:49},{ox:48 + 79, oy:-143.5 + 197, x:175, y:59, w:50, h:48},{ox:53 + 79, oy:-141.5 + 197, x:225, y:59, w:41, h:46},{ox:53 + 79, oy:-141.5 + 197, x:266, y:59, w:38, h:46},{ox:53 + 79, oy:-143.5 + 197, x:0, y:112, w:40, h:48},{ox:48 + 79, oy:-145.5 + 197, x:40, y:112, w:47, h:50},{ox:46 + 79, oy:-148.5 + 197, x:87, y:112, w:51, h:53},{ox:44 + 79, oy:-151.5 + 197, x:138, y:112, w:54, h:56}];
			animations['telescope'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,13,13,13,14,14,14,15,15,15,15,15,15,14,14,14,13,13,13,12,12,12,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0]};

			frames = [{ox:109 + 80, oy:182.5 + 194, x:192, y:112, w:109, h:60},{ox:109 + 80, oy:182.5 + 194, x:301, y:112, w:109, h:60},{ox:109 + 80, oy:182.5 + 194, x:0, y:172, w:109, h:60},{ox:109 + 80, oy:182.5 + 194, x:109, y:172, w:109, h:60},{ox:109 + 80, oy:182.5 + 194, x:218, y:172, w:109, h:59},{ox:109 + 80, oy:182.5 + 194, x:327, y:172, w:109, h:59},{ox:109 + 80, oy:181.5 + 194, x:436, y:172, w:109, h:60}];
			animations['road'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0]};

			frames = [{ox:-27 + 117, oy:-20.5 - 15, x:545, y:172, w:54, h:38},{ox:-27 + 117, oy:-21.5 - 15, x:0, y:232, w:54, h:39},{ox:-27 + 117, oy:-22.5 - 15, x:54, y:232, w:54, h:41},{ox:-29 + 117, oy:-22.5 - 15, x:108, y:232, w:57, h:42},{ox:-30 + 117, oy:-21.5 - 15, x:165, y:232, w:60, h:42},{ox:-31 + 117, oy:-19.5 - 15, x:225, y:232, w:61, h:40},{ox:-30 + 117, oy:-19.5 - 15, x:286, y:232, w:60, h:40},{ox:-27 + 117, oy:-19.5 - 15, x:0, y:274, w:57, h:39},{ox:-27 + 117, oy:-19.5 - 15, x:57, y:274, w:55, h:39},{ox:-27 + 117, oy:-19.5 - 15, x:112, y:274, w:54, h:37}];
			animations['top'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9]};

			
			atlas.dispose();
			atlas = null;
		}
		
		
		public function getFrames(animations:Array, atlas:BitmapData):Array
		{
			const pt:Point = new Point(0, 0);
			var frame:Object;
			var bmd:BitmapData;
			var data:Array = [];
			for (var index:* in animations)
			{
				frame = animations[index];
				bmd = new BitmapData(frame.w, frame.h);
				
				bmd.copyPixels(atlas, new Rectangle(frame.x, frame.y, frame.w, frame.h), pt);
				data.push( { bmd:bmd, ox:frame.ox, oy:frame.oy} );
			}
			return data;
		}
		
		
	}
}
