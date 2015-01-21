package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = -3;
		public var ay:int = -34;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:-132, oy:-155.5, x:0, y:0, w:206, h:213},{ox:-139, oy:-161.5, x:206, y:0, w:220, h:226},{ox:-143, oy:-166.5, x:426, y:0, w:229, h:236},{ox:-150, oy:-173.5, x:655, y:0, w:243, h:250},{ox:-154, oy:-176.5, x:898, y:0, w:251, h:256},{ox:-155, oy:-176.5, x:0, y:256, w:252, h:256},{ox:-152, oy:-172.5, x:252, y:256, w:246, h:248},{ox:-146, oy:-165.5, x:498, y:256, w:234, h:234},{ox:-136, oy:-154.5, x:732, y:256, w:214, h:213}];
			animations['windmill'] = {frames:getFrames(frames, atlas), chain:[0,1,2,3,4,5,6,7,8]};

			
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
