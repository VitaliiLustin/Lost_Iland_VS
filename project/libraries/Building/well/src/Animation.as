package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 4;
		public var ay:int = -29;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-33, oy:-15.5, x:0, y:0, w:103, h:77},{ox:-33, oy:-15.5, x:103, y:0, w:102, h:77},{ox:-33, oy:-15.5, x:205, y:0, w:99, h:77},{ox:-33, oy:-15.5, x:304, y:0, w:93, h:77},{ox:-33, oy:-15.5, x:397, y:0, w:85, h:77},{ox:-33, oy:-15.5, x:482, y:0, w:79, h:77},{ox:-33, oy:-15.5, x:561, y:0, w:79, h:77},{ox:-33, oy:-15.5, x:640, y:0, w:80, h:77},{ox:-33, oy:-15.5, x:720, y:0, w:83, h:77},{ox:-33, oy:-15.5, x:803, y:0, w:84, h:77}];
			animations['well1'] = {frames:getFrames(frames, atlas), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0]};

			
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
