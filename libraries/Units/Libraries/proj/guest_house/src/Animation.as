package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -63;
		public var ay:int = 3;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-18, oy:-60.5, x:0, y:0, w:33, h:80},{ox:-18, oy:-60.5, x:33, y:0, w:33, h:80},{ox:-18, oy:-59.5, x:66, y:0, w:33, h:79},{ox:-19, oy:-60.5, x:99, y:0, w:34, h:80},{ox:-18, oy:-61.5, x:133, y:0, w:33, h:81},{ox:-18, oy:-62.5, x:0, y:81, w:33, h:82},{ox:-18, oy:-62.5, x:33, y:81, w:33, h:82},{ox:-18, oy:-61.5, x:66, y:81, w:33, h:81},{ox:-18, oy:-60.5, x:99, y:81, w:33, h:80},{ox:-18, oy:-60.5, x:132, y:81, w:33, h:80}];
			animations['hostess_mini'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9]};

			
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
