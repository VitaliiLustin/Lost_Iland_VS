package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -5;
		public var ay:int = -14;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-45, oy:21, x:0, y:0, w:110, h:80},{ox:-45, oy:21, x:110, y:0, w:110, h:80},{ox:-45, oy:22, x:220, y:0, w:110, h:79},{ox:-45, oy:22, x:0, y:80, w:110, h:79},{ox:-45, oy:21, x:110, y:80, w:110, h:80}];
			animations['spring1'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4]};

			frames = [{ox:-31, oy:-83, x:220, y:80, w:39, h:43},{ox:-31, oy:-83, x:0, y:160, w:39, h:43},{ox:-31, oy:-83, x:39, y:160, w:39, h:43},{ox:-31, oy:-83, x:78, y:160, w:39, h:43},{ox:-31, oy:-83, x:0, y:203, w:39, h:44}];
			animations['spring3'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4]};

			frames = [{ox:-48, oy:-44, x:39, y:203, w:65, h:77},{ox:-48, oy:-44, x:104, y:203, w:65, h:77},{ox:-47, oy:-44, x:0, y:280, w:64, h:77},{ox:-47, oy:-44, x:64, y:280, w:64, h:77},{ox:-47, oy:-44, x:128, y:280, w:64, h:77}];
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
