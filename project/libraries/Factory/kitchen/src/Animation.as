package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 12;
		public var ay:int = -3;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:70, oy:42, x:0, y:0, w:69, h:75},{ox:70, oy:43, x:69, y:0, w:69, h:74},{ox:70, oy:44, x:138, y:0, w:69, h:73},{ox:70, oy:44, x:207, y:0, w:69, h:73},{ox:70, oy:51, x:276, y:0, w:69, h:66},{ox:70, oy:57, x:345, y:0, w:69, h:60},{ox:70, oy:53, x:414, y:0, w:69, h:64},{ox:70, oy:49, x:483, y:0, w:69, h:68},{ox:70, oy:56, x:552, y:0, w:69, h:61},{ox:70, oy:55, x:621, y:0, w:69, h:62},{ox:70, oy:54, x:690, y:0, w:69, h:63},{ox:70, oy:58, x:759, y:0, w:69, h:59},{ox:70, oy:49, x:0, y:75, w:69, h:68},{ox:70, oy:41, x:69, y:75, w:69, h:76},{ox:70, oy:41, x:138, y:75, w:69, h:76},{ox:70, oy:42, x:207, y:75, w:69, h:75}];
			animations['knife'] = {frames:getFrames(frames, atlas), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15]};

			frames = [{ox:24, oy:68, x:276, y:75, w:53, h:35},{ox:24, oy:68, x:329, y:75, w:53, h:35},{ox:24, oy:68, x:382, y:75, w:53, h:35},{ox:24, oy:68, x:435, y:75, w:53, h:35},{ox:24, oy:68, x:488, y:75, w:53, h:35},{ox:24, oy:68, x:541, y:75, w:53, h:35},{ox:24, oy:68, x:594, y:75, w:53, h:35},{ox:24, oy:68, x:647, y:75, w:53, h:35}];
			animations['cooking'] = {frames:getFrames(frames, atlas), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]};

			
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
