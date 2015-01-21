package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -5;
		public var ay:int = -19;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-45, oy:21, x:0, y:0, w:110, h:80},{ox:-45, oy:21, x:110, y:0, w:110, h:80},{ox:-45, oy:22, x:220, y:0, w:110, h:79},{ox:-45, oy:22, x:330, y:0, w:110, h:79},{ox:-45, oy:21, x:440, y:0, w:110, h:80}];
			animations['spring1'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4]};

			frames = [{ox:-26, oy:-13, x:0, y:80, w:35, h:46},{ox:-26, oy:-13, x:35, y:80, w:34, h:45},{ox:-25, oy:-13, x:69, y:80, w:34, h:45},{ox:-26, oy:-13, x:103, y:80, w:36, h:45},{ox:-26, oy:-13, x:139, y:80, w:35, h:45}];
			animations['spring2'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4]};

			
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
