package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Animation 
	{
		public var animations:Object = { };
		
		public var ax:int = 0;
		public var ay:int = 0;

		
		[Embed(source="sprites/sprite.png", mimeType="image/png")]
		private var Sprite:Class;
		
		public function Animation(){
		
			var frames:Array;
			var atlas:BitmapData = new Sprite().bitmapData;
			
			
			frames = [{ox:67 - 75, oy:-719 + 136, x:0, y:0, w:130, h:59},{ox:67 - 75, oy:-719 + 136, x:130, y:0, w:130, h:59},{ox:66 - 75, oy:-718 + 136, x:260, y:0, w:131, h:58},{ox:66 - 75, oy:-719 + 136, x:391, y:0, w:131, h:60},{ox:66 - 75, oy:-718 + 136, x:0, y:60, w:131, h:59},{ox:67 - 75, oy:-719 + 136, x:131, y:60, w:130, h:59},{ox:67 - 75, oy:-719 + 136, x:261, y:60, w:130, h:58},{ox:67 - 75, oy:-719 + 136, x:391, y:60, w:129, h:59},{ox:67 - 75, oy:-719 + 136, x:0, y:119, w:130, h:59},{ox:66 - 75, oy:-718 + 136, x:130, y:119, w:130, h:59},{ox:66 - 75, oy:-719 + 136, x:260, y:119, w:131, h:60},{ox:66 - 75, oy:-718 + 136, x:391, y:119, w:131, h:59},{ox:67 - 75, oy:-719 + 136, x:0, y:179, w:129, h:59},{ox:67 - 75, oy:-719 + 136, x:129, y:179, w:129, h:59},{ox:67 - 75, oy:-719 + 136, x:258, y:179, w:130, h:58}];
			animations['wrecked_ship2'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14]};

			frames = [{ox:-188 - 72, oy:-530 + 140, x:388, y:179, w:88, h:32},{ox:-188 - 72, oy:-530 + 140, x:0, y:238, w:88, h:33},{ox:-188 - 72, oy:-530 + 140, x:88, y:238, w:87, h:35},{ox:-187 - 72, oy:-530 + 140, x:175, y:238, w:86, h:35},{ox:-187 - 72, oy:-529 + 140, x:261, y:238, w:86, h:34},{ox:-187 - 72, oy:-529 + 140, x:0, y:275, w:86, h:32},{ox:-187 - 72, oy:-529 + 140, x:86, y:275, w:86, h:31},{ox:-188 - 72, oy:-529 + 140, x:172, y:275, w:88, h:31},{ox:-188 - 72, oy:-530 + 140, x:260, y:275, w:87, h:33},{ox:-188 - 72, oy:-530 + 140, x:0, y:306, w:88, h:35},{ox:-188 - 72, oy:-530 + 140, x:88, y:306, w:86, h:36},{ox:-187 - 72, oy:-529 + 140, x:174, y:306, w:85, h:32},{ox:-187 - 72, oy:-529 + 140, x:259, y:306, w:86, h:32},{ox:-187 - 72, oy:-529 + 140, x:0, y:342, w:86, h:31},{ox:-188 - 72, oy:-529 + 140, x:86, y:342, w:88, h:31}];
			animations['wrecked_ship1'] = {frames:getFrames(frames, atlas), chain:[0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14]};

			
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
