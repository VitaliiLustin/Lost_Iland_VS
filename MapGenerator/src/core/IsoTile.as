package core
{
	public class IsoTile 
	{
		
		public static const _tile:tile = new tile();
		public static const width:uint = _tile.width;
		public static const height:uint = _tile.height;
		
		public static const spacing:Number = int(Math.sqrt(5 * Math.pow(_tile.width, 2) / 16));
		
		public var isoX:int = 0;
		public var isoY:int = 0;
		public var isoZ:int = 0;
		
		public var x:int = 0;
		public var y:int = 0;
		
		public var center:Object = { x:x, y:y };
		
		public var b:int = 0;
		public var p:int = 0;
		public var z:int = 0;

		public function IsoTile(x:int = 0, y:int = 0) 
		{
			this.x = x;
			this.y = y;
			
			center.x = x + _tile.width * 0.5;
			center.y = y + _tile.height * 0.5;
		}
		
	}

}