package 
{
	import core.IsoConvert;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getAliasName;
	
	/**
	 * ...
	 * @author 
	 */
	public class Zones extends Sprite 
	{	
		
		public static var mode:Boolean = false;
		public static var draw:Boolean = false;
		public static var clear:Boolean = false;
		public static var brush:int = 10;
		
		public static var fullTile:BitmapData;
		public static var emptyTile:BitmapData;
		public static var zoneTile1:BitmapData
		public static var zoneTile2:BitmapData
		public static var zoneTile3:BitmapData
		public static var zoneTile4:BitmapData
		
		private static const RED:uint = 0xFF0000;
		private static const GREEN:uint = 0x00FF00;
		private static const BLUE:uint = 0x0000FF;
		private static const BLACK:uint = 0x000000;
		private static const WHITE:uint = 0xFFFFFF;
		private static const CYAN:uint = 0x00FFFF;
		private static const MAGENTA:uint = 0xFF00FF;
		private static const YELLOW:uint = 0xFFFF00;
		private static const LIGHT_GREY:uint = 0xCCCCCC;
		private static const MID_GREY:uint = 0x999999;
		private static const DARK_GREY:uint = 0x666666;
		
		public static var currentZoneTile:BitmapData = null
		public static var currentZoneIndex:int = -1;
		
		public function Zones()
		{
			
		}
		
		public static function createTiles():void
		{
			fullTile = drawTile(BLACK, 1);
			emptyTile = drawTile(WHITE, 1);
			zoneTile1 = drawTile(GREEN, 1);
			zoneTile2 = drawTile(BLUE, 1);
			zoneTile3 = drawTile(YELLOW, 1);
			zoneTile4 = drawTile(MAGENTA, 1);
			
			currentZoneTile = zoneTile1;
			currentZoneIndex = 1;
		}	
		
		private static function drawTile(color:*, alpha:Number):BitmapData
		{
			var cont:Sprite = new Sprite();
			var _cont:Sprite = new Sprite();
			var shape:Shape = new Shape();
			var bmd:BitmapData;
			shape.graphics.beginFill(color, alpha);
			shape.graphics.drawRect(0, 0, 26, 26);
			shape.graphics.endFill();
			shape.rotation = 45;
			
			cont.addChild(shape)
			cont.height = cont.height / 2;
			_cont.addChild(cont);
			cont.x = cont.width/2;
			bmd = new BitmapData(_cont.width, _cont.height, true, 0);
			bmd.draw(_cont);
			
			return bmd;
		}
		
		public static function changeZoneMarker(marker:uint):void
		{
			currentZoneIndex = marker;
			switch(marker)
			{
				case 1:
					currentZoneTile = zoneTile1;
					break;
				case 2:
					currentZoneTile = zoneTile2;
					break
				case 3:
					currentZoneTile = zoneTile3;
					break
				case 4:
					currentZoneTile = zoneTile4;
					break	
			}
		}
		
		public static function onZoneBttnClick(e:Event):void
		{
			mode = !mode;
			if (mode == false)
			{
				Map.self.mIso.visible = false;
				Map.self.setOffEnterFrame(onMouseMove);
			}
			else
			{
				Map.self.createIsoTiles();
				Map.self.setOnEnterFrame(onMouseMove);
			}
		}
		
		public static function changeBrush(event:Event):void
		{
			brush = event.currentTarget.data;
		}
		
		public static function showZones():void
		{
			Map.self.zonesLayer.visible = !Map.self.zonesLayer.visible; 
		}
		
		public static function onMouseMove():void
		{
			var point:Object = IsoConvert.screenToIso(Map.self.mouseX, Map.self.mouseY, true);
			var i:int = 0;
			var j:int = 0;
				
			if (draw == true)
			{
				for (i = 0; i < brush; i++)
				{
					for (j = 0; j < brush; j++)
					{
						if (Map.markersData[point.x + i] == null) return;
						if (Map.markersData[point.x + i][point.z + j] == null) return;
						Map.self.changeGridItem(point.x + i, point.z + j, "1");
					}
				}
			}
			
			if (clear == true)
			{
				for (i = 0; i < brush; i++)
				{
					for (j = 0; j < brush; j++)
					{
						if (Map.markersData[point.x + i] == null) return;
						if (Map.markersData[point.x + i][point.z + j] == null) return;
						Map.self.changeGridItem(point.x + i, point.z + j, "0");
					}
				}
			}
		}
	}
}