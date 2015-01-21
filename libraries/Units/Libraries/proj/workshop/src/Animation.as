package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -25;
		public var ay:int = -61;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:40, oy:120.5, x:0, y:0, w:37, h:21},{ox:32, oy:123.5, x:37, y:0, w:26, h:21},{ox:17, oy:117.5, x:63, y:0, w:37, h:33},{ox:9, oy:120.5, x:100, y:0, w:37, h:35},{ox:6, oy:120.5, x:0, y:35, w:42, h:34},{ox:-2, oy:118.5, x:42, y:35, w:54, h:36},{ox:-4, oy:117.5, x:96, y:35, w:62, h:43},{ox:-6, oy:126.5, x:158, y:35, w:64, h:43},{ox:-4, oy:123.5, x:0, y:78, w:75, h:58},{ox:2, oy:121.5, x:75, y:78, w:73, h:69},{ox:40, oy:120.5, x:148, y:78, w:37, h:21}];
			animations['workshop'] = {frames:getFrames(frames, atlas), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10]};

			
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
