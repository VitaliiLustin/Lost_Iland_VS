package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Security;
	

	public class RocksLib extends Sprite 
	{
		
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		//big
		[Embed(source = "Graphics/Big_rock1.png")]
		private var Big_rock1:Class;
		public var big_rock1:BitmapData = new Big_rock1().bitmapData;
		
		[Embed(source = "Graphics/Big_rock2.png")]
		private var Big_rock2:Class;
		public var big_rock2:BitmapData = new Big_rock2().bitmapData;
		
		[Embed(source = "Graphics/Big_rock3.png")]
		private var Big_rock3:Class;
		public var big_rock3:BitmapData = new Big_rock3().bitmapData;
		
		[Embed(source = "Graphics/Big_rock4.png")]
		private var Big_rock4:Class;
		public var big_rock4:BitmapData = new Big_rock4().bitmapData;
		
		
		
		
		//small
		[Embed(source = "Graphics/Sml_rock1.png")]
		private var Sml_rock1:Class;
		public var sml_rock1:BitmapData = new Sml_rock1().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock2.png")]
		private var Sml_rock2:Class;
		public var sml_rock2:BitmapData = new Sml_rock2().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock3.png")]
		private var Sml_rock3:Class;
		public var sml_rock3:BitmapData = new Sml_rock3().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock4.png")]
		private var Sml_rock4:Class;
		public var sml_rock4:BitmapData = new Sml_rock4().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock5.png")]
		private var Sml_rock5:Class;
		public var sml_rock5:BitmapData = new Sml_rock5().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock6.png")]
		private var Sml_rock6:Class;
		public var sml_rock6:BitmapData = new Sml_rock6().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock7.png")]
		private var Sml_rock7:Class;
		public var sml_rock7:BitmapData = new Sml_rock7().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock8.png")]
		private var Sml_rock8:Class;
		public var sml_rock8:BitmapData = new Sml_rock8().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock9.png")]
		private var Sml_rock9:Class;
		public var sml_rock9:BitmapData = new Sml_rock9().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock10.png")]
		private var Sml_rock10:Class;
		public var sml_rock10:BitmapData = new Sml_rock10().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock11.png")]
		private var Sml_rock11:Class;
		public var sml_rock11:BitmapData = new Sml_rock11().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock12.png")]
		private var Sml_rock12:Class;
		public var sml_rock12:BitmapData = new Sml_rock12().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock13.png")]
		private var Sml_rock13:Class;
		public var sml_rock13:BitmapData = new Sml_rock13().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock14.png")]
		private var Sml_rock14:Class;
		public var sml_rock14:BitmapData = new Sml_rock14().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock15.png")]
		private var Sml_rock15:Class;
		public var sml_rock15:BitmapData = new Sml_rock15().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock16.png")]
		private var Sml_rock16:Class;
		public var sml_rock16:BitmapData = new Sml_rock16().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock17.png")]
		private var Sml_rock17:Class;
		public var sml_rock17:BitmapData = new Sml_rock17().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock18.png")]
		private var Sml_rock18:Class;
		public var sml_rock18:BitmapData = new Sml_rock18().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock19.png")]
		private var Sml_rock19:Class;
		public var sml_rock19:BitmapData = new Sml_rock19().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock20.png")]
		private var Sml_rock20:Class;
		public var sml_rock20:BitmapData = new Sml_rock20().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock21.png")]
		private var Sml_rock21:Class;
		public var sml_rock21:BitmapData = new Sml_rock21().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock22.png")]
		private var Sml_rock22:Class;
		public var sml_rock22:BitmapData = new Sml_rock22().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock23.png")]
		private var Sml_rock23:Class;
		public var sml_rock23:BitmapData = new Sml_rock23().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock24.png")]
		private var Sml_rock24:Class;
		public var sml_rock24:BitmapData = new Sml_rock24().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock25.png")]
		private var Sml_rock25:Class;
		public var sml_rock25:BitmapData = new Sml_rock25().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock26.png")]
		private var Sml_rock26:Class;
		public var sml_rock26:BitmapData = new Sml_rock26().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock27.png")]
		private var Sml_rock27:Class;
		public var sml_rock27:BitmapData = new Sml_rock27().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock28.png")]
		private var Sml_rock28:Class;
		public var sml_rock28:BitmapData = new Sml_rock28().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock29.png")]
		private var Sml_rock29:Class;
		public var sml_rock29:BitmapData = new Sml_rock29().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock30.png")]
		private var Sml_rock30:Class;
		public var sml_rock30:BitmapData = new Sml_rock30().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock31.png")]
		private var Sml_rock31:Class;
		public var sml_rock31:BitmapData = new Sml_rock31().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock32.png")]
		private var Sml_rock32:Class;
		public var sml_rock32:BitmapData = new Sml_rock32().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock33.png")]
		private var Sml_rock33:Class;
		public var sml_rock33:BitmapData = new Sml_rock33().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock34.png")]
		private var Sml_rock34:Class;
		public var sml_rock34:BitmapData = new Sml_rock34().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock35.png")]
		private var Sml_rock35:Class;
		public var sml_rock35:BitmapData = new Sml_rock35().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock36.png")]
		private var Sml_rock36:Class;
		public var sml_rock36:BitmapData = new Sml_rock36().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock37.png")]
		private var Sml_rock37:Class;
		public var sml_rock37:BitmapData = new Sml_rock37().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock38.png")]
		private var Sml_rock38:Class;
		public var sml_rock38:BitmapData = new Sml_rock38().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock39.png")]
		private var Sml_rock39:Class;
		public var sml_rock39:BitmapData = new Sml_rock39().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock40.png")]
		private var Sml_rock40:Class;
		public var sml_rock40:BitmapData = new Sml_rock40().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock41.png")]
		private var Sml_rock41:Class;
		public var sml_rock41:BitmapData = new Sml_rock41().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock42.png")]
		private var Sml_rock42:Class;
		public var sml_rock42:BitmapData = new Sml_rock42().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock43.png")]
		private var Sml_rock43:Class;
		public var sml_rock43:BitmapData = new Sml_rock43().bitmapData;
		
		[Embed(source = "Graphics/Sml_rock44.png")]
		private var Sml_rock44:Class;
		public var sml_rock44:BitmapData = new Sml_rock44().bitmapData;
		
		
		public var rocksBig:Array = [big_rock1, big_rock2, big_rock3, big_rock4];
		
		public var rocks:Array = [sml_rock1, sml_rock2, sml_rock3, sml_rock4, sml_rock5, sml_rock6, sml_rock7, sml_rock8, sml_rock9, sml_rock10, sml_rock11, 
		sml_rock12, sml_rock13, sml_rock14, sml_rock15, sml_rock16, sml_rock17, sml_rock18, sml_rock19, sml_rock20, sml_rock21, sml_rock22, sml_rock23, 
		sml_rock24, sml_rock25, sml_rock26, sml_rock27, sml_rock28, sml_rock29, sml_rock30, sml_rock31, sml_rock32, sml_rock33, sml_rock34, sml_rock35,
		sml_rock36, sml_rock37, sml_rock38, sml_rock39, sml_rock40, sml_rock41, sml_rock42, sml_rock43, sml_rock44];
		
		
		public function RocksLib():void 
		{
		
		}
	}
}