package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 23;
		public var ay:int = 91;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-26.5, oy:-17, x:0, y:0, w:53, h:34}];
			animations['hostess1'] = {frames:getFrames(frames, atlas), chain:[0]};

			/*frames = [{ox:25, oy:36.5, x:53, y:0, w:51, h:53},{ox:25, oy:36.5, x:104, y:0, w:51, h:54},{ox:24, oy:36.5, x:155, y:0, w:52, h:54},{ox:24, oy:36.5, x:207, y:0, w:52, h:54},{ox:25, oy:37.5, x:259, y:0, w:50, h:52},{ox:26, oy:38.5, x:309, y:0, w:49, h:51},{ox:25, oy:37.5, x:358, y:0, w:50, h:52},{ox:24, oy:36.5, x:408, y:0, w:51, h:54},{ox:26, oy:36.5, x:459, y:0, w:49, h:54},{ox:27, oy:35.5, x:508, y:0, w:48, h:54}];
			animations['hostess2'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9]};*/
			
			var dX:int = -40;
			var dY:int = -75;
			
			frames = [{ox: dX +25, oy: dY +36.5, x:53, y:0, w:51, h:53},{ox: dX +25, oy: dY +36.5, x:104, y:0, w:51, h:54},{ox: dX +24, oy: dY +36.5, x:155, y:0, w:52, h:54},{ox: dX +24, oy: dY +36.5, x:207, y:0, w:52, h:54},{ox: dX +25, oy: dY +37.5, x:259, y:0, w:50, h:52},{ox: dX +26, oy: dY +38.5, x:309, y:0, w:49, h:51},{ox: dX +25, oy: dY +37.5, x:358, y:0, w:50, h:52},{ox: dX +24, oy: dY +36.5, x:408, y:0, w:51, h:54},{ox: dX +26, oy: dY +36.5, x:459, y:0, w:49, h:54},{ox: dX +27, oy: dY +35.5, x:508, y:0, w:48, h:54}];
			animations['hostess2'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9]};

			
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
