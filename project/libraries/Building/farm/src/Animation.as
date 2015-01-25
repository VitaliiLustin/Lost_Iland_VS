package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -36;
		public var ay:int = -29;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:71, oy:32, x:0, y:0, w:47, h:60},{ox:71, oy:32, x:47, y:0, w:46, h:61},{ox:71, oy:32, x:93, y:0, w:45, h:62},{ox:71, oy:32, x:138, y:0, w:44, h:63},{ox:71, oy:33, x:182, y:0, w:45, h:63},{ox:71, oy:33, x:227, y:0, w:46, h:66},{ox:71, oy:33, x:273, y:0, w:47, h:67},{ox:71, oy:33, x:320, y:0, w:47, h:66},{ox:71, oy:32, x:367, y:0, w:47, h:67}];
			animations['anim1'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8]};

			
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
