package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -11;
		public var ay:int = 24;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-94, oy:-40, x:0, y:0, w:135, h:106},{ox:-94, oy:-40, x:135, y:0, w:135, h:108},{ox:-95, oy:-40, x:270, y:0, w:136, h:113},{ox:-95, oy:-40, x:406, y:0, w:136, h:121},{ox:-94, oy:-40, x:0, y:121, w:135, h:129},{ox:-92, oy:-40, x:135, y:121, w:133, h:129},{ox:-92, oy:-40, x:268, y:121, w:127, h:129},{ox:-93, oy:-40, x:395, y:121, w:122, h:129},{ox:-94, oy:-40, x:0, y:250, w:120, h:129},{ox:-94, oy:-40, x:120, y:250, w:118, h:129}];
			animations['quarry'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]};

			
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
