package  
{
	import astar.AStar;
	import astar.AStarNodeVO;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import spark.filters.GlowFilter;

	public class Map extends Sprite
	{
		public static var deltaX:int 	= 1000;
		public static var deltaY:int 	= 1000;
		
		//public static var isoCells:int 	= 20; 		//X
		//public static var isoRows:int 	= 20; 		//Z
		public static var mapWidth:int 	= 0;
		public static var mapHeight:int	= 0;
		
		public static const LAYER_LAND:String 	= 'mLand';
		public static const LAYER_FIELD:String 	= 'mField';
		public static const LAYER_SORT:String 	= 'mSort';
		
		public static const DEBUG:Boolean 	= true;
		public static var self:Map;
		
		public static var X:int = 10;
		public static var Z:int = 10;
		
		public var mTreasure:Sprite 	= new Sprite();
		public var mLayer:Sprite 		= new Sprite();
		public var mUnits:Sprite 		= new Sprite();
		public var mIso:Sprite	 		= new Sprite();
		public var mLand:Sprite		 	= new Sprite();
		public var mField:Sprite	 	= new Sprite();
		public var mSort:Sprite		 	= new Sprite();
		
		public var frameCallbacks:Vector.<Function> = new Vector.<Function>();
		
	
		public static var main:Main
		public var depths:Vector.<uint> = new Vector.<uint>();
		
		public static var units:Array = [];
		
		public var touched:Vector.<Unit> = new Vector.<Unit>();
		public var moved:Unit;
		
		[Embed(source="img/tile.jpg")]
		private var Tile:Class;
		public var _tile:Bitmap = new Tile();
		private var tiles:Array = [];
		
		public var plane:Bitmap = null;
		public var iso:Bitmap = new Bitmap();
		public static var deleteMode:Boolean = false;
		
		public static var markersData:Vector.<Vector.<Object>> = new Vector.<Vector.<Object>>;
		public static var loadedMarkersData:Array = [];
		
		public var selectedUnit:Unit;
		
		public var personagesLayer:Bitmap 	= new Bitmap();
		public var buildingsLayer:Bitmap 	= new Bitmap();
		public var zonesLayer:Bitmap 		= new Bitmap();
		
		
		public function Map(id:int, _main:Main) 
		{
			self = this;
			main = _main;
			Save.loadSavedGrid(init);
		}
		
		public function init(data:Array):void
		{
			Map.X = data.length
			if(data[0] != null)		Map.Z = data[0].length
			
			
			main.TZ.value = Map.Z;
			main.TX.value = Map.X;
			
			loadedMarkersData = data;
			
			Zones.createTiles();
			main.holder.addChildAt(this, 0);
			createTiles();
			createPlane();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//createIsoTiles()
			
			addChild(mUnits);
		}
		
		public function createIsoTiles():void
		{
			createMarkersData();
			drawLayers();
			this.setChildIndex(mUnits, this.numChildren-1);
		}
		
		private function drawLayers():void
		{
			personagesLayer = new Bitmap();
			buildingsLayer = new Bitmap();
			zonesLayer = new Bitmap();
			
			var rect:Rectangle = new Rectangle(0, 0, Zones.emptyTile.width, Zones.emptyTile.height);
			var persBmd:BitmapData = new BitmapData(plane.width, plane.height, true, 0);
			var buildBmd:BitmapData = new BitmapData(plane.width, plane.height, true, 0);
			var zonesBmd:BitmapData = new BitmapData(plane.width, plane.height, true, 0);
			
			for (var x:int = 0; x < Map.X; x++)
			{
				for (var y:int = 0; y < Map.Z; y++)
				{
					var tx:Number = markersData[x][y].x;
					var ty:Number = markersData[x][y].y;
					
					if (markersData[x][y].b == 0) 		buildBmd.copyPixels(Zones.emptyTile, rect, new Point(tx, ty),null,null,true);
					else								buildBmd.copyPixels(Zones.fullTile, rect, new Point(tx, ty),null,null,true);
					
					if (markersData[x][y].p == 0) 		persBmd.copyPixels(Zones.emptyTile, rect, new Point(tx, ty),null,null,true);
					else								persBmd.copyPixels(Zones.fullTile, rect, new Point(tx, ty), null, null, true);
					
					drawZonesLayer(markersData[x][y].z, tx, ty, zonesBmd, rect);
				}
			}
			
			personagesLayer.bitmapData = persBmd;
			buildingsLayer.bitmapData = buildBmd;
			zonesLayer.bitmapData = zonesBmd;
			
			addChild(personagesLayer);
			addChild(buildingsLayer);
			addChild(zonesLayer);
			
			buildingsLayer.alpha = 0.5;
			personagesLayer.alpha = 0.5;
			zonesLayer.alpha = 0.5;
		}
		
		private function drawZonesLayer(zone:int, x:Number, y:Number, zonesBmd:BitmapData, rect:Rectangle):void
		{
			var zoneTile:BitmapData;
			
			switch(zone)
			{
				case 0: zoneTile = Zones.emptyTile; break;
				case 1: zoneTile = Zones.zoneTile1; break;
				case 2: zoneTile = Zones.zoneTile2; break;
				case 3: zoneTile = Zones.zoneTile3; break;
				case 4: zoneTile = Zones.zoneTile4; break;
			}
			
			zonesBmd.copyPixels(zoneTile, rect, new Point(x, y), null, null, true);
		}
		
		private function createMarkersData():void
		{
			var point:Object;
			markersData = new Vector.<Vector.<Object>>;
			
			for (var x:int = 0; x < Map.X; x++)
			{
				var row:Vector.<Object> = new Vector.<Object>;
				for (var y:int = 0; y < Map.Z; y++)
				{
					point = IsoConvert.isoToScreen(x, y, true);
					var tx:Number = point.x - IsoTile._tile.width * .5;
					var ty:Number = point.y;
					var _tile:IsoTile = new IsoTile(tx, ty);
					
					if (loadedMarkersData.length != 0)
					{
						_tile.b = loadedMarkersData[x][y].b;
						_tile.p = loadedMarkersData[x][y].p;
						_tile.z = loadedMarkersData[x][y].z;
					}
					
					row.push(_tile);
				}
				markersData.push(row);
			}
			
			//loadedMarkersData = null;
		}
		
		public function changeGridItem(x:int, y:int, value:String):void
		{
			if (personagesLayer.visible)		changePersTile(x, y, value);
			if (buildingsLayer.visible)			changeBuildTile(x, y, value);
			if (zonesLayer.visible)				changeZoneItem(x, y);
		}
		
		private function changeZoneItem(x:Number, y:Number):void
		{
			if (markersData[x][y].z == Zones.currentZoneIndex) return;
				markersData[x][y].z = Zones.currentZoneIndex;
			
			var tx:Number = markersData[x][y].x;
			var ty:Number = markersData[x][y].y;
			
			zonesLayer.bitmapData.copyPixels(Zones.currentZoneTile, Zones.currentZoneTile.rect, new Point(tx, ty), null, null, true);
		}
		
		public function changeBuildTile(x:int, y:int, value:String):void
		{
			if (markersData[x][y].b == value) return;
				markersData[x][y].b = value;
				
			var tx:Number = markersData[x][y].x;
			var ty:Number = markersData[x][y].y;
			
			var tileBmd:BitmapData;
			if (value == "1") 	tileBmd = Zones.fullTile;
			else				tileBmd = Zones.emptyTile;
			
			buildingsLayer.bitmapData.copyPixels(tileBmd, tileBmd.rect, new Point(tx, ty), null, null, true);
		}
		
		public function changePersTile(x:int, y:int, value:String):void
		{
			if (markersData[x][y].p == value) return;
				markersData[x][y].p = value;
				
			var tx:Number = markersData[x][y].x;
			var ty:Number = markersData[x][y].y;
			
			var tileBmd:BitmapData;
			if (value == "1") 	tileBmd = Zones.fullTile;
			else				tileBmd = Zones.emptyTile;
			
			personagesLayer.bitmapData.copyPixels(tileBmd, tileBmd.rect, new Point(tx, ty), null, null, true);
		}
		
		public function changeDepth(value:String):void
		{
			if (selectedUnit != null)
			{
				var index1:uint = mUnits.getChildIndex(selectedUnit);
				if(value == "+" && index1 + 1 < mUnits.numChildren)
				{
					mUnits.swapChildrenAt(index1, index1 + 1);
					selectedUnit.index = index1 + 1
				}
				else if (value == "-" && index1 - 1 >= 0 )
				{
					mUnits.swapChildrenAt(index1, index1 - 1)
					selectedUnit.index = index1 - 1
				}
			}
		}
		
		private function clear(child:Boolean = false):void
		{
			if (this.contains(mUnits)) removeChild(mUnits);
			
			for each(var t:Bitmap in tiles) removeChild(t);
			tiles = [];
			
			removeChild(plane);
			plane = null;
		}
		
		private function createPlane():void
		{
			var _plane:Sprite = new Sprite();
			_plane.graphics.lineStyle(1, 0x000000, 0.5);
			addChild(_plane);
			
			for (x = 0; x < Map.X; x++)
			{
				var _point1:Object = IsoConvert.isoToScreen(x, 0, true);
				var _point2:Object = IsoConvert.isoToScreen(x, Map.Z, true);
				
				_plane.graphics.moveTo(_point1.x, _point1.y);
				_plane.graphics.lineTo(_point2.x, _point2.y);
			}
			
			for (z = 0; z < Map.Z; z++)
			{
				_point1 = IsoConvert.isoToScreen(0, z, true);
				_point2 = IsoConvert.isoToScreen(Map.X, z, true);
				
				_plane.graphics.moveTo(_point1.x, _point1.y);
				_plane.graphics.lineTo(_point2.x, _point2.y);
			}
			
			var bmd:BitmapData = new BitmapData(_plane.width, _plane.height, true, 0);
				bmd.draw(_plane);
				
				removeChild(_plane);
				
			plane = new Bitmap(bmd);
			addChild(plane);
		}
		
		public function changePlane():void {
			clear();
			createTiles();
			createPlane();
			addChild(mUnits);
		}
		
		public function addUnit(settings:Object):void {
			var unit:Unit = new Unit(settings)
			mUnits.addChild(unit);
			unit.index = mUnits.getChildIndex(unit);
		}
		
		public function removeUnit(unit:Unit):void {
			var index:int = units.indexOf(unit);
			if (index != -1) { units.splice(unit) };
			mUnits.removeChild(unit);
			unit = null;
		}
		
		/**
		 * Событие окончания загрузки SWF карты
		 * @param	data
		 */
		private function createTiles():void {
			
			Map.mapWidth = 0;
			deltaY 	= 0;
			deltaX  = 0;
			
			var _pointO:Object = IsoConvert.isoToScreen(0, 0, true); 
			var _pointR:Object = IsoConvert.isoToScreen(Map.X, 0, true);
			var _pointL:Object = IsoConvert.isoToScreen(0, Map.Z, true);
			
			var WIDTH_R:int = _pointR.x;
			var WIDTH_L:int = _pointL.x * -1;
			var WIDTH:uint = WIDTH_R + WIDTH_L;
			
			Save.gridDelta	= WIDTH_L;
			
			var _pointD:Object = IsoConvert.isoToScreen(Map.X, Map.Z, true);
			var HEIGHT:uint = _pointD.y;
			
			Map.mapWidth = WIDTH;
			Map.mapHeight = HEIGHT;
			
			deltaX = Map.Z *(IsoTile.width/2);
			
			x = -deltaX;
			y = -deltaY;
			
			var cellsTilesCount:Number 	= WIDTH / _tile.width; 
			var rowsTilesCount:Number 	= HEIGHT / _tile.height; 
			
			var mapCells:int 	= Math.ceil(cellsTilesCount);
			var mapRows:int 	= Math.ceil(rowsTilesCount);
			
			//var difCells:Number = cellsTilesCount - mapCells;
			//var difRows:Number 	= rowsTilesCount - mapRows;
			
			//Дублируем тайлы карты по всему миру
			for (var j:int = 0; j < mapRows; j++ ) {
				drawCells();
			}
			
			function drawCells():void
			{
				for (var i:int = 0; i < mapCells; i++ ) 
				{
					//var bmd:BitmapData = _tile.bitmapData//new BitmapData(_tile.width, _tile.height, true, 0)
					var bitmap:Bitmap = new Bitmap(_tile.bitmapData);
					addChild(bitmap);
					//bitmap.alpha = (70+Math.random()*30)/100;
					tiles.push(bitmap);
					bitmap.x = i * _tile.width;
					bitmap.y = j * _tile.height;
				}
			}
		}
		
		/**
		 * Перерисовка карты при ее перемещении
		 * @param	dx	смещение по X оси
		 * @param	dy	смещение по Y оси
		 */
		public function redraw(dx:int, dy:int):void {
			
			/*if (!(x + dx < 0 && x + dx > stage.stageWidth - mapWidth)) {
				dx = 0;
			}
			
			if (!(y + dy < 0 && y + dy > stage.stageHeight - mapHeight)) {
				dy = 0;
			}*/
			
			if (dx || dy) {
				x += dx;
				y += dy;
			}
		}
		
		public function touches(e:MouseEvent):void {
			var bmp:Bitmap;
			var objects:Array = getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			var length:uint = objects.length;
			if (length > 0) {
						
				for each(var touch:Unit in touched) {
					bmp = touch.bmp;
					if (bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0) {
						touch.touch = false;
						touched.splice(touched.indexOf(touch), 1);
					}
				}
								
				for (var i:int = length-1; i >= 0; i--) {
					if(objects[i].parent is Unit){
						var unit:Unit = objects[i].parent;
							
						if (unit.bmp.bitmapData && unit.bmp.bitmapData.getPixel(unit.bmp.mouseX, unit.bmp.mouseY) != 0) {
							
								//Выделяем объект
								if(!unit.touch && touched.length == 0){
									touched.push(unit);
									unit.touch = true;
									//Выделили самый верхний не прозрачный и выходим
									break;
								}
								
							}else {
									if(unit.touch){
										unit.touch = false;
										touched.splice(touched.indexOf(unit), 1);
									
								}
							}
						}
					}
				}
			}
			
		/**
		 * Добавление функции обратного вызова на событие EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public function setOnEnterFrame(callback:Function):void {
			frameCallbacks.push(callback);
		}
		
		/**
		 * Удаление функции обратного вызова с события EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public function setOffEnterFrame(callback:Function):void {
			var index:int = frameCallbacks.indexOf(callback);
			if(index != -1){
				frameCallbacks.splice(index,1);
			}
		}
		
		/**
		 * Событие EnterFrame
		 * @param	e	объект события
		 */
		private function onEnterFrame(e:Event):void {
			for (var i:int = 0; i < frameCallbacks.length; i++ ) {
				frameCallbacks[i].call();
			}
		}
		
		public function touch():void
		{
			var unit:Unit = touched[0];
				
			if (Map.deleteMode)
			{
				removeUnit(unit);
				return;
			}
			
			selectedUnit = unit;
			moved = unit;
			unit.move = true;
		}
		
	}
}