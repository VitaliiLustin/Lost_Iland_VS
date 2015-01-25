package  
{
	import adobe.utils.CustomActions;
	import astar.AStar;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Debug;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Log;
	import core.Post;
	import effects.OrbitalMagic;
	import effects.Waves;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.ContextMenu;
	import ui.Cursor;
	import ui.SystemPanel;
	import ui.UserInterface;
	import wins.InstanceWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import units.*;
	
	public class Map extends LayerX
	{
		public static var deltaX:int 	= 1000;
		public static var deltaY:int 	= 1000;
		public static var mapWidth:int 	= 3000;
		public static var mapHeight:int	= 3000;
		
		public static const LAYER_LAND:String 		= 'mLand';
		public static const LAYER_FIELD:String 		= 'mField';
		public static const LAYER_SORT:String 		= 'mSort';
		public static const LAYER_TREASURE:String 	= 'mTreasure';
		
		public static const DEBUG:Boolean 	= false;
		
		public static var X:int = 0;
		public static var Z:int = 0;
		
		public static var cells:int = 0;
		public static var rows:int = 0;
		
		public var mTreasure:Sprite 	= new Sprite();
		public var mLayer:Sprite 		= new Sprite();
		public var mUnits:Sprite 		= new Sprite();
		public var mIso:Sprite	 		= new Sprite();
		public var mLand:Sprite		 	= new Sprite();
		public var mField:Sprite	 	= new Sprite();
		public var mSort:Sprite		 	= new Sprite();
		
		public var _aStarNodes:Vector.<Vector.<AStarNodeVO>>;
		public var _aStarWaterNodes:Vector.<Vector.<AStarNodeVO>>;
		public var _aStarParts:Vector.<Vector.<AStarNodeVO>>;
		public var _astar:AStar;
		public var _astarReserve:AStar;
		public var _astarWater:AStar;
		
		public var touched:Vector.<*> = new Vector.<*>();
		
		public var lastTouched:Vector.<Unit> = new Vector.<Unit>();
		
		public var transed:Vector.<Unit> = new Vector.<Unit>();
		public var sorted:Array = [];
		public var depths:Array = [];
		
		public var moved:Unit;
		public var _grid:Bitmap;
		
		private var _units:Object;
		
		public var butterflies:Vector.<Butterfly> = new Vector.<Butterfly>();
		public var whispas:Vector.<Whispa> = new Vector.<Whispa>();
		
		public var id:uint;
		public var info:Object = { };
		
		private var building:Building;
		private var personage:Personage;
		private var resource:Resource;
		private var decor:Decor;
		private var field:Field;
		private var hut:Hut;
		private var jam:Jam;
		private var animal:Animal;
		private var sphere:Sphere;
		private var tribute:Tribute;
		private var treasure:Treasure;
		private var boiler:Boiler;
		private var farm:Farm;
		private var golden:Golden;
		private var share:Share;
		private var tree:Tree;
		private var collector:Collector;
		private var gamble:Gamble;
		private var panda:Panda;
		private var helper:Helper;
		private var guide:Guide;
		private var bar:Bar;
		private var table:Table;
		private var tower:Tower;
		private var floors:Floors;
		private var bridge:Bridge;
		private var fake:Fake;
		private var box:Box;
		private var dock:Dock;
		private var firework:Firework;
		private var chest:Chest;
		private var mining:Mining;
		private var trade:Trade;
		private var storehouse:Storehouse;
		private var factory:Factory;
		private var techno:Techno;
		private var missionhouse:Missionhouse;
		private var moneyhouse:Moneyhouse;
		private var character:Character;
		private var fplant:Fplant;
		private var walkGolden:Walkgolden;
		private var tradeshop:Tradeshop;
		private var buffer:Buffer;
		private var cowboy:Cowboy;
		private var tradesman:Tradesman;
		private var pathfinder:Pathfinder;

		public var workmen:Object = {0:Personage.BEAR};
		public var heroPosition:Object = { x:36, z:65};
		public static var ready:Boolean = false
		
		public function Map(id:int, units:Object = null, load:Boolean=true)
		{
			Map.ready = false;
			this._units = units;
			this.id = id;
			
			//Добавляем себя на сцену
			//App.self.addChildAt(this, 0);
			App.self.drawBackground();
			App.self.addChildAt(this, 1);
			if(load)
				Load.loading(Config.getDream(takeDreamName()), onLoadTile);
			
			mouseEnabled = false;
			if(App.data.storage[id].workmen != null)
				workmen = App.data.storage[id].workmen;
		}
		
		private function takeDreamName():String
		{
			if (App.user.id == '1')
				return 'land_0';
			
			return 'land1'
			//return App.data.storage[id].view;
		}
		
		public function load():void {
			Load.loading(Config.getDream(takeDreamName()), onLoadTile);
		}
		
		public function dispose():void {
				
			sorted = [];
			depths = [];
			
			var unit:*;
			
			App.self.setOffEnterFrame(sorting);
			
			var childs:int = mSort.numChildren;
			
			while (childs--) {
				try
				{
					unit = mSort.getChildAt(childs);
					
					if (unit is Resource) {
						unit.dispose();
					}else{
						if(!(unit is Plant)){
							unit.uninstall();
						}
					}
				
				}catch (e:Error) {
					
				}
			}
			
			childs = mLand.numChildren;
			while (childs--) {
				try
				{
					unit = mLand.getChildAt(childs);
					
					if (unit is Unit) {
						unit.uninstall();
					}
				}catch (e:Error) {
					
				}	
			}
			
			childs = mField.numChildren;
			while (childs--) {
				try
				{
					unit = mField.getChildAt(childs);
					
					if (unit is Unit) {
						unit.uninstall();
					}
				}catch (e:Error) {
					
				}	
			}
			
			Resource.countWhispa = 0;
			
			if (butterflies.length > 0) {
				for each(unit in butterflies) {
					unit.dispose();
					unit = null;
				}
				butterflies = new Vector.<Butterfly>();
			}
			
			if (whispas.length > 0) {
				for each(unit in whispas) {
					unit.dispose();
					unit = null;
				}
				whispas = new Vector.<Whispa>();
			}
					
			_aStarNodes = null;
			_aStarParts = null;
			_aStarWaterNodes = null;
			_astar = null;
			_astarReserve = null;
			_astarWater = null;
			
			App.user.removePersonages();
			App.self.removeChild(this);
			Bear.dispose();
			//Lantern.dispose();
			Boss.dispose();
			Hut.dispose();
			SoundsManager.instance.dispose();
			Pigeon.dispose();
			Nature.dispose();
			Waves.dispose();
		}
		
		public function inGrid(point:Object):Boolean
		{
			if (point.x >= 0 && point.x < Map.cells)
			{
				if (point.z >= 0 && point.z < Map.rows) return true;
			}
			return false
		}
		
		
		/**
		 * Событие окончания загрузки SWF карты
		 * @param	data
		 */
		public var bitmap:Bitmap;
		public var assetZones:Object;
		private function onLoadTile(data:Object):void 
		{			
			var t1:uint;
			var t2:uint;
			
			deltaX 	= 0;//data.gridDelta;
			deltaY 	= 0;
			
			x = -deltaX;
			y = -deltaY;
			
			assetZones = { };// data.assetZones;
			
			t1 = getTimer();
			//Назначаем параметры карты
			Map.mapWidth 	= data.mapWidth;
			Map.mapHeight 	= data.mapHeight;
			Map.cells		= data.isoCells;
			Map.rows 		= data.isoRows;
			
			var widthTile:int 	= data.tile.width;
			var heightTile:int 	= data.tile.height;
			
			var mapCells:int 	= Math.ceil(data.mapWidth / widthTile); 
			var mapRows:int 	= Math.ceil(data.mapHeight / heightTile); 
			
			var tileDX:int = 0;
			var tileDY:int = 0;
			
			if (data.hasOwnProperty('tileDX')){
				tileDX = data.tileDX;
				tileDY = data.tileDY;
			}
						
			if (data.hasOwnProperty('type') && data.type == 'image') {
				addTile(0,0);
			}else{
				//Дублируем тайлы карты по всему миру
				for (var j:int = 0; j < mapRows; j++ ) {
					for (var i:int = 0; i < mapCells; i++ ) {
						addTile(i, j);
					}
				}
			}
			
			if (data.hasOwnProperty('additionalTiles'))
			{
				for each(var coords:Object in data.additionalTiles)
				{
					addTile(coords.i, coords.j);
				}
			}
			
			var count:int = 0;
			function addTile(i:int, j:int):void
			{
				bitmap = new Bitmap(data.tile);
				
				addChild(bitmap);
				bitmap.x = (i * widthTile) + tileDX;
				bitmap.y = (j * heightTile) + tileDY;
				bitmap.smoothing = true;
			}
			
			drawLandscape(data.elements);
			//Добавляем слой с нарисованой из тайликов сеткой
			addChild(mIso);
			
			//Создаем сетку 
			initGridNodes(data.gridData);
			
			if (data.hasOwnProperty('info')) {
				info = data.info;
				if (info.hasOwnProperty('bridges'))
					Bridge.init(info.bridges);
			}
			
			addChild(mUnits);

			mUnits.addChild(mLand);
			mUnits.addChild(mField);
			mUnits.addChild(mSort);
			
			var land_decor:Array = [];
			//раставляем полученные юниты
			for each(var item:Object in _units) {
				/*if (App.data.storage[item.sid].type != 'Fake') 
					continue;*/
				if (item.type == 'Decor' && App.data.storage[item.sid].dtype == 1) {
					land_decor.push(item);
					continue;
				}
				if (item.sid == 350 && Tradeshop.countShips > 0)
					continue;
					
				World.tagUnit(item.sid);
				var unit:Unit = Unit.add(item);
			}
			
			if (data.hasOwnProperty('heroPosition')) {
				heroPosition = data.heroPosition;
			}
			//World.defindEnergyLimit();
			
			land_decor.sortOn('id');
			var land_decor_lenght:int = land_decor.length;
			for (i = 0; i < land_decor_lenght; i++) {
				Unit.add(land_decor[i]);
			}
			
			land_decor = null;
			//grid = true;
				
			allSorting();
			
			/*showWhispas();
			
			for (i = 0; i < 2; i++) {
				var count:int = 2 + Math.random() * 2;
				var whispa:Whispa = new Whispa( { cells:count, rows:count } );
				whispa.show();
				whispas.push(whispa);
			}*/
			
			addChild(mTreasure);
			
			//if (data.hasOwnProperty('heroPosition'))
				//heroPosition = data.heroPosition;
		
			Map.ready = true;
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_COMPLETE));
			App.self.setOnEnterFrame(sorting);
			
			if (data.hasOwnProperty('zones'))
			{
				if (App.user.mode == User.OWNER)
					App.user.world.drawZones(data.zones);
				else	
					App.owner.world.drawZones(data.zones);
			}
			
			/*var _bgColor:*;
			if (data.hasOwnProperty('bgColor')){
				App.self.bgColor = data.bgColor;
				_bgColor = data.bgColor;
			}else {
				_bgColor = Nature.settings.bgColor;
				App.self.bgColor = _bgColor;
			}*/
			
			Zone.createFog();
			
			/*if (App.user.mode == User.OWNER && App.user.worldID == User.HOME_WORLD && !App.user.quests.tutorial)
				Pigeon.checkNews();*/
			
			Nature.init();
			parallax = new Parallax();
			
			if (data.hasOwnProperty('waves'))
				Waves.add(id, data.waves);
				
			/*if (App.user.mode == User.GUEST)
				App.ui.bottomPanel.removeFriendsInt();*/
		}
		
		public var parallax:Parallax;
		
		/*private var background:Shape;
		private function addBackground():void {
			background = new Shape();
			var point1:Object = IsoConvert.isoToScreen(0, Map.rows, true);
			var point2:Object = IsoConvert.isoToScreen(Map.cells, 0, true);
			
			var point3:Object = IsoConvert.isoToScreen(0, 0, true);
			var point4:Object = IsoConvert.isoToScreen(Map.cells, Map.rows, true);
			
			var _width:int = point2.x - point1.x;
			var _height:int = point4.y - point3.y;
			background.graphics.beginFill(App.self.bgColor, 1);//(0x284c71,1);
			background.graphics.drawRect(0, 0, _width, _height);
			background.graphics.endFill();
			addChildAt(background, 0);
		}*/

		/**
		 * Добавляем элементы ландшафта
		 */
		private function drawLandscape(elements:Array):void
		{
			var elementsList:Array = [];
			for each(var element:Object in elements)
			{
				elementsList.push(element);
			}
			elementsList.sortOn("depth", Array.NUMERIC);
			
			var tileDX:int = 147;
			var tileDY:int = 120;
			
			if (id == 229)
			{
				tileDX = 0;
				tileDY = 0;
			}
			
			for (var e:int = 0; e < elementsList.length; e++)
			{
				var elementBitmap:LandscapeElement = new LandscapeElement(elementsList[e].name);
			
				element = elementsList[e];
				if (element.iso != null)
				{
					var coords:Object = IsoConvert.isoToScreen(elementsList[e].x, elementsList[e].y);
					elementBitmap.x = coords.x;
					elementBitmap.y = coords.y;
				}
				else
				{
					elementBitmap.x = elementsList[e].x - IsoTile._tile.width + tileDX;
					elementBitmap.y = elementsList[e].y
				}
				
				if (elementsList[e].scaleX != null)
				{
					elementBitmap.scaleX = elementsList[e].scaleX;
				}
				
				addChild(elementBitmap);
			}
		}
		
		/**
		 * Создание сетки
		 * @param	markersData сетка поверхности
		 * @param	zonesData сетка зон
		 */
		private function initGridNodes(gridData:Array) : void {
			
			if(id == 81) 
				gridData[65][3].z = 4;
				
			var hasWater:Boolean = false;
			_aStarNodes = new Vector.<Vector.<AStarNodeVO>>();
			_aStarParts = new Vector.<Vector.<AStarNodeVO>>();
			_aStarWaterNodes = new Vector.<Vector.<AStarNodeVO>>();
			var x : uint = 0;
			var z : uint = 0;
			
			while ( x < Map.cells) {
				_aStarNodes[x] = new Vector.<AStarNodeVO>();
				_aStarParts[x] = new Vector.<AStarNodeVO>();
				_aStarWaterNodes[x] = new Vector.<AStarNodeVO>();
				
				while ( z < Map.rows){
					var node :AStarNodeVO  = new AStarNodeVO();
					var part :AStarNodeVO  = new AStarNodeVO();
					var water :AStarNodeVO  = new AStarNodeVO();
					
					node.h = 0;
					part.h = 0;
					
					node.f = 0;
					part.f = 0;
					
					node.g = 0;
					part.g = 0;
					
					node.visited = false;
					part.visited = false;
					water.visited = false;
					
					node.parent = null;
					part.parent = null;
					water.parent = null;
					
					node.closed = false;
					part.closed = false;
					water.closed = false;
					
					node.position = new Point(x, z);
					part.position = new Point(x, z);
					water.position = new Point(x, z);
					
					node.isWall = gridData[x][z].p;
					part.isWall = gridData[x][z].p;
					water.isWall = !gridData[x][z].w;
					if (gridData[x][z].w != null)	hasWater = true;
					
					var _z:int = assetZones[gridData[x][z].z];
					node.z = _z;
					
					/*if (World.zoneIsOpen(_z))*/	node.open = true;
					
					node.b = gridData[x][z].b;
					node.p = gridData[x][z].p;
					node.w = gridData[x][z].w;
					
					var point:Object = IsoConvert.isoToScreen(x, z, true);
					var cell:IsoTile = new IsoTile(point.x, point.y);
					
					node.tile = cell;
					part.tile = cell;
					water.tile = cell;
					
					_aStarNodes[x][z]  = node;
					_aStarParts[x][z]  = part;
					_aStarWaterNodes[x][z]  = water;
					
					z++;
				}
				z=0;
				x++;
			}
			
			_astar 			= new AStar(_aStarNodes);
			_astarReserve 	= new AStar(_aStarParts);
			
			if(hasWater)
				_astarWater		= new AStar(_aStarWaterNodes);
			else
				_aStarWaterNodes = null;
		}
		
		/**
		 * Управление сеткой
		 */
		public function set grid(value:Boolean):void
		{
			if (value) createGrid();
			else {	if (this.contains(_grid)){
					this.removeChild(_grid);
					_grid = null;
				}}
		}
		public function get grid():Boolean
		{
			if (_grid) 	return true;
			else 		return false;
		}
		
		public function createGrid():void
		{
			var _plane:Sprite = new Sprite();
			_plane.graphics.lineStyle(1, 0x000000, 0.5);
			addChild(_plane);
			
			for (x = 0; x < Map.cells; x++)
			{
				var _point1:Object = IsoConvert.isoToScreen(x, 0, true);
				var _point2:Object = IsoConvert.isoToScreen(x, Map.rows, true);
				
				_plane.graphics.moveTo(_point1.x, _point1.y);
				_plane.graphics.lineTo(_point2.x, _point2.y);
			}
			
			for (z = 0; z < Map.rows; z++)
			{
				_point1 = IsoConvert.isoToScreen(0, z, true);
				_point2 = IsoConvert.isoToScreen(Map.cells, z, true);
				
				_plane.graphics.moveTo(_point1.x, _point1.y);
				_plane.graphics.lineTo(_point2.x, _point2.y);
			}
			
			var bmd:BitmapData = new BitmapData(_plane.width, _plane.height, true, 0);
				bmd.draw(_plane);
				
				removeChild(_plane);
				_plane = null;
				
			_grid = new Bitmap(bmd);
			addChild(_grid);
		}
		
		private var mapPadding:int = 350;
		/**
		 * Перерисовка карты при ее перемещении
		 * @param	dx	смещение по X оси
		 * @param	dy	смещение по Y оси
		 */
		
		private var replacingDist:int = 0;
		public function redraw(dx:int, dy:int):void {
						
			if (focusTween) {
				focusTween.kill()
				focusTween = null;
			}
			if (focusCenTween) {
				focusCenTween.kill()
				focusCenTween = null;
			}
			
			if (!(x + dx - mapPadding < 0 && x + dx > stage.stageWidth - mapWidth*scaleX - mapPadding*2)) {
				dx = 0;
			}
			
			if (!(y + dy - mapPadding< 0 && y + dy > stage.stageHeight - mapHeight*scaleY - mapPadding)) {
				dy = 0;
			}
			
			if (dx || dy) {
				x += dx;
				y += dy;
				
				parallax.redraw(dx, dy);
			}
			
			replacingDist ++;
			if (replacingDist > 20) {
				replacingDist = 0;
				SoundsManager._instance.soundReplace();
			}
		}
		
		public function set scale(value:Number):void {
			
			
			//TweenLite.to(App.map, 0.5, { scaleX:value, scaleY:value } );
			/*
			if (value == 1)
				parallax.layer2.visible = false;
			else 
				parallax.layer2.visible = true;*/
		
			
			App.map.scaleX = value;
			App.map.scaleY = value;
			if(parallax)
				parallax.dScale();
			App.map.center();
		}
		
		public function center():void {
			
			if (App.user.personages.length > 0)
				focusedOn(App.user.hero, false, null, false);
			else {
				var position:Object = IsoConvert.isoToScreen(App.map.heroPosition.x, App.map.heroPosition.z, true);
				App.map.focusedOn(position, false, null, false);
				//parallax.layer1.x = 0;
				//parallax.layer2.x = 0;
			}
			
			//x = -mapWidth/2*scaleX+App.self.stage.stageWidth/2;
			//y = 0;//-mapHeight/2*scaleY+App.self.stage.stageHeight/2;
		}
		
		public function addUnit(unit:*):void {
			switch(unit.layer) {
				case LAYER_FIELD: 		mField.addChild(unit); break;
				case LAYER_LAND:  		mLand.addChild(unit); break;
				case LAYER_TREASURE:  	mTreasure.addChild(unit); break;
				case LAYER_SORT:  
					depths.push(unit);
					sorted.push(unit);
					//depths.sort(Array.NUMERIC);
					//unit.index = depths.indexOf(unit.depth);
					//mSort.addChildAt(unit, unit.index); 
					mSort.addChild(unit); 
				break;
			}
		}
		
		
		public function removeUnit(unit:*):void {
			switch(unit.layer) {
				case LAYER_FIELD: 		if(mField.contains(unit)) 		mField.removeChild(unit); break;
				case LAYER_LAND:  		if(mLand.contains(unit))		mLand.removeChild(unit); break;
				case LAYER_SORT:  		
					
					var index:int = depths.indexOf(unit);
					if(index>0)	depths.splice(index, 1);
					
					index = sorted.indexOf(unit);
					if (index > 0) sorted.splice(index, 1);
					
					if (mSort.contains(unit)) 		
						mSort.removeChild(unit); 
					
					break;
				case LAYER_TREASURE:  	if(mTreasure.contains(unit)) 	mTreasure.removeChild(unit); break;
			}
		}
		
		private var globalSorting:int = 0;
		
		public function sorting(e:Event = null):void {
			globalSorting++;
			if (globalSorting % 2 == 0) return;
			
			if (sorted.length > 0) {
				
				depths.sortOn('depth', Array.NUMERIC);
				
				for each(var unit:* in sorted) {
					var index:int = depths.indexOf(unit);
					unit.index = index;
					
					if(mSort.contains(unit)){
						try {
							//unit.setTint();
							unit.sort(index);
							//mSort.setChildIndex(unit, index);
						}catch (e:Error) {
							
						}
					}
				}	
				sorted = [];
						
				if (globalSorting >= 60) {
					var err:Boolean = false;
					for (var i:* in depths) {
						try{
							mSort.setChildIndex(depths[i], int(i));
						}catch (e:Error) {
							err = true;
						}
					}
					if (err) {
						globalSorting = 59;
					}else{
						globalSorting = 0;
					}
				}
			}
			if (globalSorting >= 60) {
				globalSorting = 0;
			}
		}
		
		public function allSorting():void {
			depths.sortOn('depth', Array.NUMERIC);
			for (var i:* in depths) {
				//if(mSort.contains(depths[i])){
					mSort.setChildIndex(depths[i], int(i));
				//}
			}
		}
		
		public function untouches():void {
			for each(var touch:* in touched) {
				touch.touch = false;
			}
			touched = new Vector.<*>();
			
			Zone.untouches();
		}
		
		public var under:Array = [];
		public function touches(e:MouseEvent):void {
			var bmp:Bitmap;
			under = [];
			under = getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			
			Zone.touches();
			
			var length:uint = under.length;
			if (length > 0) {
						
				for each(var touch:* in touched) {
					
					bmp = touch.bmp;
					if (bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0 || !touch.touchable) {
						touch.touch = false;
						touched.splice(touched.indexOf(touch), 1);
					}
				}
				
				for (var i:int = length-1; i >= 0; i--) {
					if (under[i].parent is BonusItem) {
						BonusItem(under[i].parent).cash();
					}
					if (under[i].parent is AnimationItem) {
						under[i].parent.touch = true;
						touched.push(under[i].parent);
						break;
					}
					
					var unit:Unit = null;
					if (under[i].parent is Unit) {
						unit = under[i].parent;
					}
					else if (under[i].parent.parent is Unit)
					{
						unit = under[i].parent.parent;
					}
					
					if (unit != null){
						
						if (!unit.clickable || !unit.visible) {
							continue;
						}
						//if(unit.sid == 344) return	
						if (
							(unit.bmp.bitmapData && unit.bmp.bitmapData.getPixel(unit.bmp.mouseX, unit.bmp.mouseY) != 0) || 
							(unit.animationBitmap && unit.animationBitmap.bitmapData && unit.animationBitmap.bitmapData.getPixel(unit.animationBitmap.mouseX, unit.animationBitmap.mouseY) != 0)
						) {
							
							var toTouch:Boolean = true;
							if ((unit.cells + unit.rows) * .5 < 4) {
								toTouch = (Map.X+5 >= unit.coords.x && Map.Z+5 >= unit.coords.z || !unit.transable);
							}else {
								toTouch = (Map.X+2 >= unit.coords.x && Map.Z+2 >= unit.coords.z || !unit.transable);
							}
							//Убираем прозрачность
							if (toTouch) {
								
								if (unit.transparent) {
									unit.transparent = false;
								}
								
								//Выделяем объект
								if (moved == null && !unit.touch && touched.length == 0) {
									
									if (unit.layer == Map.LAYER_LAND)
									{
										if (Cursor.type == 'default') break;
									}
									touched.push(unit);
									unit.touch = true;
									//Выделили самый верхний не прозрачный и выходим
									break;
								}
								
							}else {
								if (!unit.transparent) {
									unit.transparent = true;
									transed.push(unit);
									
									if(unit.touch){
										unit.touch = false;
										touched.splice(touched.indexOf(unit), 1);
									}
								}
							}
						}
						
					}
				}
				
				for each(var trans:Unit in transed) {
					bmp = trans.bmp;
					
					if (bmp.bitmapData && trans.animationBitmap && trans.animationBitmap.bitmapData){
						if (
							(bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0) &&
							(trans.animationBitmap && trans.animationBitmap.bitmapData && trans.animationBitmap.bitmapData.getPixel(trans.animationBitmap.mouseX, trans.animationBitmap.mouseY) == 0)
						) {
							trans.transparent = false;
							transed.splice(transed.indexOf(trans), 1);
						}
					}else {
						if ((bmp.bitmapData && bmp.bitmapData.getPixel(bmp.mouseX, bmp.mouseY) == 0)) {
							trans.transparent = false;
							transed.splice(transed.indexOf(trans), 1);
						}
					}
				}
			}
		}

		
		public function click():void
		{
			if ((Cursor.type != "default" || Cursor.plant || Cursor.type == "instance") && Cursor.type != "locked") 
			{	
				Cursor.type = 'default';
					return;
			}
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_CLICK));
			
			var world:World;
			if (App.user.mode == User.OWNER){
				if (!App.user.world.checkZone(null, true)) return;
			}else{
				if (!App.owner.world.checkZone(null, true)) return;
			}
			
			if (App.user.hero && App.user.hero.tm.status != TargetManager.FREE) return;
			var point:Object = IsoConvert.screenToIso(this.mouseX, this.mouseY, true);
			
			if(App.user.personages.length > 0)
				App.user.initPersonagesMove(point.x, point.z);
			
			
			var effect:AnimationItem = new AnimationItem( { type:'Effects', view:'clickEffect', params: { scale:0.4 }, onLoop:function():void {
				App.map.mLand.removeChild(effect);
			}});
			SoundsManager.instance.playSFX('map_sound_1v3');
			mLand.addChild(effect);
			effect.x = this.mouseX;
			effect.y = this.mouseY;
			
			//App.tutorial.setCirclePosition( { x:App.self.mouseX, y:App.self.mouseY } );
		}
		
		public function touch():void
		{
			if (Cursor.type == "instance") {
				Cursor.type = 'default';
				//touched.splice(0, 1);
				return;
			}
			
			if (!(touched[0] is Unit)) return;
			
			var unit:Unit = touched[0];
			
			if(!(unit is Hero))App.self.dispatchEvent(new AppEvent(AppEvent.ON_MAP_TOUCH));
			
			var world:World;
			if (App.user.mode == User.OWNER)
				world = App.user.world;
			else	
				world = App.owner.world;
			
			switch(Cursor.type)
			{
				case "move":
					if (!world.checkZone(null, true)) return;
					if (unit.can()) {
						break;
					}
					unit.fromStock = false;
					unit.move = true;
					if (unit.move) {
						moved = unit;
					}
					break;
					
				case "remove":
					if (!world.checkZone(null, true)) return;
					if (unit.can()) {
						break;
					}
					touched.splice(0, 1);
					unit.touch = false;
					unit.remove();
					
					break;
					
				case "rotate":
					if (!world.checkZone(null, true)) return;
					if (unit.can()) {
						break;
					}
					unit.rotate = !unit.rotate;
					break;
				
				case "stock":
					if(Cursor.toStock){
						if (!world.checkZone(null, true)) return;
						if (unit.can()) {
							break;
						}
						unit.putAction();
						break;	
					}
					
				default:
					if (!(unit is Field)) {
						Cursor.plant = null;
						ShopWindow.currentBuyObject.type = null;
					}
					//if (!(unit is Lantern) && !(unit is BonusItem)) {
					if (!(unit is Boss) && !(unit is BonusItem)) {
						if (!world.checkZone(null, true)) return;
					}
					
					unit.click();
					if(!(unit is Animal))
						App.self.dispatchEvent(new AppEvent(AppEvent.ON_STOP_MOVE));
				break;
			}
		}
		
		public static function findUnit(sID:uint, id:uint):*
		{
			var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				if (unit is Unit && unit.sid == sID  && unit.id == id)
				{
					return unit;
				}
			}
			
			return null;
		}
		
		public static function findUnits(sIDs:Array):Array
		{
			if (!App.map) return new Array();
			var result:Array = [];
			var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				var index:int = sIDs.indexOf(unit.sid);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			return result;
		}
		
		public static function findUnitsByType(types:Array):Array
		{
			var result:Array = [];
			var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				if (!unit.hasOwnProperty('type')) continue;
				var index:int = types.indexOf(unit.type);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			return result;
		}
		
		public static function findUnitsByTypeinLand(types:Array):Array
		{
			var result:Array = [];
			var i:int = App.map.mLand.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mLand.getChildAt(i);
				var index:int = types.indexOf(unit.type);
				if (index != -1)
				{
					result.push(unit);
				}
			}
			
			return result;
		}
		
		private var focusTween:TweenLite;
		public function focusedOn(unit:*, glowing:Boolean = false, callback:Function = null, tween:Boolean = true, scale:* = null, considerBoder:Boolean = true, tweenTime:Number = 1, focusOnCenter:Boolean = false):void
		{
			if (App.user.quests.tutorial && tweenTime == 1)
				tweenTime = 0.5;
				
			if (scale == null)
				scale = this.scaleX;
			
			var targetX:int = -unit.x * scale + App.self.stage.stageWidth / 2;
			var targetY:int = -unit.y * scale + App.self.stage.stageHeight / 2;
			
			if(considerBoder){
				if (targetX > 0) targetX = 0;
				else if (targetX < stage.stageWidth - mapWidth * scale) 	targetX = stage.stageWidth - mapWidth * scale;
				
				if (targetY > 0) 
					targetY = 0;
				else if  (targetY < stage.stageHeight - mapHeight * scale) 
					targetY = stage.stageHeight - mapHeight * scale;
			}
			
			if (tween == false || (x == targetX && y == targetY)) {
				x = targetX;
				y = targetY;
				if (callback != null) callback();
				return;
			}
			
			if(scale == this.scaleX)
				focusTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, onComplete:onComplete } );
			else
				focusTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, scaleX:scale, scaleY:scale, onComplete:onComplete } );
			
			function onComplete():void {
				if (glowing) App.ui.flashGlowing(unit);
				if(callback != null){
					callback();
				}
				focusTween = null;
			}
		}
		
		private var focusCenTween:TweenLite;
		public function focusedOnCenter(unit:*, glowing:Boolean = false, callback:Function = null, tween:Boolean = true, scale:* = null, considerBoder:Boolean = true, tweenTime:Number = 1, focusOnCenter:Boolean = false):void
		{
			if (App.user.quests.tutorial)
				tweenTime = 0.5;
			
			if (scale == null)
				scale = this.scaleX;
				
			var posX:int;
			var posY:int;
			
			if (unit.scaleX == 1) {
				posX = unit.x + unit.bitmap.x + unit.bitmap.width / 2;
				posY = unit.y + unit.bitmap.y + unit.bitmap.height / 2;
			}else {
				posX = unit.x + unit.bitmap.width / 2 - (unit.bitmap.width + unit.bitmap.x);
				posY = unit.y + unit.bitmap.y + unit.bitmap.height / 2;
			}
			
			var targetX:int = -posX * scale + App.self.stage.stageWidth / 2;
			var targetY:int = -posY * scale + App.self.stage.stageHeight / 2;
			
			if(considerBoder){
				if (targetX > 0) targetX = 0;
				else if (targetX < stage.stageWidth - mapWidth * scale) 	targetX = stage.stageWidth - mapWidth * scale;
				
				if (targetY > 0) 
					targetY = 0;
				else if  (targetY < stage.stageHeight - mapHeight * scale) 
					targetY = stage.stageHeight - mapHeight * scale;
			}
			
			if (tween == false || (x == targetX && y == targetY)) {
				x = targetX;
				y = targetY;
				if (callback != null) callback();
				return;
			}
			
			SystemPanel.scaleValue = scale;
			SystemPanel.updateScaleMode();
			App.ui.systemPanel.updateScaleBttns();
			
			if(scale == this.scaleX)
				focusCenTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, onComplete:onComplete } );
			else
				focusCenTween = TweenLite.to(this, tweenTime, { x:targetX, y:targetY, scaleX:scale, scaleY:scale, onComplete:onComplete } );
			
			function onComplete():void {
				if (glowing) App.ui.flashGlowing(unit);
				if(callback != null){
					callback();
				}
				focusCenTween = null;
			}
		}
		
		public function showWhispas():void {
			if(lastTouched.length > 0){
				var unit:Resource = lastTouched.pop();
				
				unit.showWhispa();
				lastTouched = new Vector.<Unit>();
			}
			
			setTimeout(showWhispas, 10000 + Math.random() * 5000);
		}
		
		public static function glow(width:int, height:int, blur:int = 100):Bitmap 
		{
			var glow:Shape = new Shape();
			glow.graphics.beginFill(0x8de8b6, 1);
			glow.graphics.drawEllipse(0, 0, width, height);
			glow.graphics.endFill();
			
			glow.filters = [new BlurFilter(blur, blur, 3)];
			
			var padding:int = 80;
			var cont:Sprite = new Sprite();
			cont.addChild(glow);
			glow.x = padding;
			glow.y = padding;
			
			var bmd:BitmapData = new BitmapData(glow.width + 2 * padding, glow.height + 2 * padding, true, 0);
			bmd.draw(cont);
			bmd = Nature.colorize(bmd);
			
			cont = null;
			glow = null;
			
			return new Bitmap(bmd);
		}
		
		private static var contLight:LayerX;
		public static function createLight(coords:Object, /*cells:int, rows:int,*/ view:String, focused:Boolean = true, color:int = 0x2bed6f, alpha:Number = 0.3):void
		{
			var _coords:Object = IsoConvert.isoToScreen(coords.x, coords.z, true);
			removeLight();
			
			contLight = new LayerX();
			
			var sqSize:int = 30;
			
			var cont:Sprite = new Sprite();
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(color);
			sp.graphics.drawRoundRect(0, 0, sqSize * coords.x, sqSize * coords.z, sqSize * coords.x, sqSize * coords.z);
			sp.rotation = 45;
			sp.alpha = alpha;
			//sp.height = lightPositions[view].height * 0.7;
			cont.addChild(sp);
			cont.height = sqSize * coords.z * 0.7;
			
			contLight.addChild(cont);
			contLight.x = _coords.x ;
			contLight.y = _coords.y;
		
			contLight.showPointing("top", - cont.width/2 , cont.height/2);
			
			//contLight.showPointing("bottom");//bottom
			
			
			doLightEff();
			
			Tutorial.watchOnTarget = null;
			Tutorial.focusOnTarget = contLight;
			
			App.map.mLand.addChild(contLight);
		}
		
		public static var lightPositions:Object = {
			'craft_workshop':{
				width:8*30,
				height:8*30,
				arrowX:0,
				arrowY:0
			},
			'commercial_building':{
				width:8*30,
				height:8*30,
				arrowX:0,
				arrowY:0
			},
			'master_sculptor':{
				width:8*30,
				height:8 * 30,
				arrowX:0,
				arrowY:0
			},
			'ceramics_workshop':{
				width:7*30,
				height:7*30,
				arrowX:0,
				arrowY:0
			},
			'plantation_plants':{
				width:14*30,
				height:14*30,
				arrowX:0,
				arrowY:0
			},
			'pit_mine':{
				width:8*30,
				height:8*30,
				arrowX:0,
				arrowY:0
			},
			'hotel':{
				width:8*30,
				height:7*30,
				arrowX:0,
				arrowY:0
			},
			'hostess':{
				width:8*30,
				height:7*30,
				arrowX:0,
				arrowY:0
			},
			'hotel_small':{
				width:7*30,
				height:6*30,
				arrowX:0,
				arrowY:0
			},
			'mill':{
				width:6*30,
				height:6*30,
				arrowX:0,
				arrowY:0
			},
			'nectar_spring':{
				width:5*30,
				height:5*30,
				arrowX:0,
				arrowY:0
			},
			'laboratory_plant':{
				width:7*30,
				height:7*30,
				arrowX:0,
				arrowY:0
			},
			'plantation2':{
				width:6*30,
				height:6*30,
				arrowX:0,
				arrowY:0
			},
			'money_house_prem':{
				width:8*30,
				height:8*30,
				arrowX:0,
				arrowY:0
			},
			'silo':{
				width:6*30,
				height:6*30,
				arrowX:0,
				arrowY:0
			},
			'kitchen':{
				width:9*30,
				height:9*30,
				arrowX:0,
				arrowY:0
			},
			'robobuild':{
				width:9*30,
				height:10*30,
				arrowX:0,
				arrowY:0
			},
			'animal_farm':{
				width:12*30,
				height:13*30,
				arrowX:40,
				arrowY:80
			},
			'hotel':{
				width:8*30,
				height:7*30,
				arrowX:0,
				arrowY:0
			},
			'storage1':{
				width:6*30,
				height:6*30,
				arrowX:0,
				arrowY:0
			},
			'storage2':{
				width:4*30,
				height:4*30,
				arrowX:0,
				arrowY:0
			},
			'storage3':{
				width:6*30,
				height:6*30,
				arrowX:0,
				arrowY:0
			},
			'storage4':{
				width:6*30,
				height:6*30,
				arrowX:0,
				arrowY:0
			},
			'storage5':{
				width:6*30,
				height:6*30,
				arrowX:0,
				arrowY:0
			}
		}
		
		public static function removeLight():void
		{
			removeLightEff();
			
			if (contLight) {
				contLight.hidePointing();
				if(contLight.parent)contLight.parent.removeChild(contLight);
			}
			contLight = null;
		}
		
		private static var lightTween:TweenMax;
		private static var lightTween2:TweenMax;
		static private function doLightEff():void 
		{
			lightTween = TweenMax.to(contLight, 1, { glowFilter: { color:0x2bed6f, alpha:0.8, strength: 7, blurX:32, blurY:32 }, onComplete:function():void {
				lightTween2 = TweenMax.to(contLight, 0.8, { glowFilter: { color:0x2bed6f, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:doLightEff});	
			}});
		}
		
		static private function removeLightEff():void 
		{
			if(lightTween)lightTween.kill();
			if(lightTween2)lightTween2.kill();
			lightTween = null;
		}
		
		public static function traceAllResource(_units:*):void
		{
			var res:Object = { };
			var totalCount:uint = 0;
			
			for each(var item:Object in _units) {
				if ( App.data.storage[item.sid].type == "Resource")
				{
					var resource:Object =App.data.storage[item.sid];
					if (!res.hasOwnProperty(resource.title))
					{
						res[resource.title] = {count:0, capacity:0};
					}
					
					res[resource.title].count ++;
					res[resource.title].capacity += item.capacity;
					totalCount ++;
				}
			}
			
			for ( var type:String in res)
			{
				trace(type + " - количество: " + res[type].count + " общая емкость: " + res[type].capacity);
			}
			trace("totalCount: " + totalCount);
		}
	}
}

import flash.display.Bitmap;
import core.Load;
import core.Debug;

internal class LandscapeElement extends Bitmap
{
	private var _name:String
	public function LandscapeElement(name:String)
	{
		_name = name;
		Load.loading(Config.getDream(name), onLoad)
	}
	
	private function onLoad(data:*):void
	{
		if (data.hasOwnProperty('bmd')) 
		{
			/*if (data.hasOwnProperty('colorize') && data.colorize){}else{
				data['colorize'] = true;
				data.bmd = Nature.colorize(data.bmd);
			}*/
			this.bitmapData = data.bmd;
		}
		else {
			Debug.log(_name);
		}
	}
}