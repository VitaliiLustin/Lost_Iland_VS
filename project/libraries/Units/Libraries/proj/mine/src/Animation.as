package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 1;
		public var ay:int = 18;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:23, oy:26, x:0, y:0, w:6, h:8},{ox:22, oy:25, x:6, y:0, w:19, h:30},{ox:22, oy:30, x:25, y:0, w:40, h:41},{ox:38, oy:45, x:65, y:0, w:36, h:39},{ox:23, oy:61, x:101, y:0, w:42, h:41},{ox:2, oy:70, x:143, y:0, w:43, h:42},{ox:-11, oy:75, x:186, y:0, w:40, h:41},{ox:-23, oy:74, x:226, y:0, w:41, h:41},{ox:-29, oy:72, x:267, y:0, w:42, h:42},{ox:-29, oy:72, x:309, y:0, w:42, h:42},{ox:-32, oy:74, x:351, y:0, w:42, h:40},{ox:-36, oy:71, x:393, y:0, w:42, h:43},{ox:-35, oy:71, x:435, y:0, w:41, h:43}];
			animations['mine1'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0,0,0,0,0,0,0,0,0]};

			frames = [{ox:-72, oy:-19, x:0, y:43, w:71, h:69},{ox:-74, oy:-20, x:71, y:43, w:73, h:69},{ox:-74, oy:-21, x:144, y:43, w:72, h:71},{ox:-75, oy:-20, x:216, y:43, w:70, h:69},{ox:-74, oy:-19, x:286, y:43, w:69, h:68},{ox:-73, oy:-18, x:355, y:43, w:68, h:67},{ox:-73, oy:-18, x:423, y:43, w:69, h:67},{ox:-72, oy:-17, x:492, y:43, w:70, h:66},{ox:-72, oy:-16, x:562, y:43, w:70, h:65},{ox:-70, oy:-16, x:632, y:43, w:68, h:65},{ox:-70, oy:-16, x:700, y:43, w:68, h:66},{ox:-70, oy:-17, x:768, y:43, w:69, h:67}];
			animations['mine2'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11]};

			
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
