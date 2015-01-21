package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -6;
		public var ay:int = -18;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-45, oy:21, x:0, y:0, w:110, h:80},{ox:-45, oy:21, x:110, y:0, w:110, h:80},{ox:-45, oy:22, x:220, y:0, w:110, h:79},{ox:-45, oy:22, x:330, y:0, w:110, h:79},{ox:-45, oy:21, x:440, y:0, w:110, h:80}];
			animations['spring1'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4]};

			frames = [{ox:-48, oy:-44, x:0, y:80, w:65, h:77},{ox:-48, oy:-44, x:65, y:80, w:65, h:77},{ox:-47, oy:-44, x:130, y:80, w:64, h:77},{ox:-47, oy:-44, x:194, y:80, w:64, h:77},{ox:-47, oy:-44, x:258, y:80, w:64, h:77}];
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
