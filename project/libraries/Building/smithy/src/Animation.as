package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 1;
		public var ay:int = -6;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:69.5, oy:68, x:0, y:0, w:68, h:41},{ox:69.5, oy:69, x:68, y:0, w:69, h:40},{ox:69.5, oy:72, x:137, y:0, w:70, h:37},{ox:69.5, oy:74, x:207, y:0, w:71, h:35},{ox:69.5, oy:74, x:278, y:0, w:72, h:35},{ox:69.5, oy:74, x:350, y:0, w:72, h:35},{ox:69.5, oy:74, x:422, y:0, w:72, h:35}];
			animations['anim1'] = {frames:getFrames(frames, atlas), chain:[0,0,1,1,2,2,3,3,4,4,5,5,6,6,6,6,5,5,4,4,3,3,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0]};

			frames = [{ox:12.5, oy:53, x:494, y:0, w:41, h:23},{ox:1.5, oy:37, x:535, y:0, w:60, h:39},{ox:-1.5, oy:25, x:595, y:0, w:63, h:50},{ox:3.5, oy:13, x:658, y:0, w:62, h:62},{ox:7.5, oy:-10, x:720, y:0, w:63, h:82},{ox:8.5, oy:-5, x:783, y:0, w:66, h:77},{ox:7.5, oy:-14, x:849, y:0, w:71, h:86},{ox:8.5, oy:-15, x:920, y:0, w:75, h:87},{ox:8.5, oy:-8, x:995, y:0, w:81, h:80},{ox:20.5, oy:-10, x:1076, y:0, w:47, h:24}];
			animations['anim2'] = {frames:getFrames(frames, atlas), chain:[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,0,0,0,0,0,0,0,0]};

			
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
