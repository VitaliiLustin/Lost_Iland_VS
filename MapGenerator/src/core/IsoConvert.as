package core {
	import flash.display.DisplayObject;
	import flash.geom.Point;
 
	/**
	 * Преобразует экранные координаты контейнера в изометрические и наоботрот
	 * @author HardCoder
	 */
	public class IsoConvert {
		private static const ALPHA:Number = 0.4636476090008062;

		private static const TAN:Number = Math.tan(ALPHA);
		private static const SIN:Number = Math.sin(ALPHA);
		private static const COS:Number = Math.cos(ALPHA);
		/**
		 * Преобразует экранные координаты контейнера в изометрические
		 * @param	x - экранная x
		 * @param	y - экранная y
		 * @return	Object(x:isoX, y:0, z:isoZ)
		 */
		public static function screenToIso(x:Number, y:Number, grid:Boolean = false):Object {
			x -= int(Map.mapWidth * 0.5);
			
			var isoX:int = (x * TAN + ((y - x * TAN) * 0.5)) / SIN;
			var isoZ:int = ((y - x * TAN) * 0.5) / SIN;
			
			if(grid){
				isoX = isoX / IsoTile.spacing;
				isoZ = isoZ / IsoTile.spacing;
			}
			
			return {x:isoX, y:0, z:isoZ};
		}
 
		/**
		 * Преобразует изометрические координаты в экранные координаты контейнера
		 * @param	isoX - изометрическая x
		 * @param	isoZ - изометрическая z
		 * @return	Object{x:x, y:y}
		 */
		public static function isoToScreen(isoX:Number, isoZ:Number, grid:Boolean=false):Object {
			//x -= Main.WORLDWIDTH * .5;
			
			if(grid){
				isoX = isoX * IsoTile.spacing;
				isoZ = isoZ * IsoTile.spacing;
			}
			
			var x:int = isoX * (COS) - isoZ * (COS);
			var y:int = isoX * (SIN) + isoZ * (SIN);
			//return {x:x+int(Map.mapWidth * 0.5), y:y};
			return {x:x+Map.deltaX, y:y};
		}
		
	}
}