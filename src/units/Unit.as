package units 
{
	import astar.AStarNodeVO;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.junkbyte.console.vos.WeakObject;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UserInterface;
	import units.*;
	import wins.ErrorWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.Window;
	
	public class Unit extends LayerX
	{
		public const OCCUPIED:uint 		= 1;
		public const EMPTY:uint 		= 2;
		public const TOCHED:uint 		= 3;
		public const DEFAULT:uint 		= 4;
		public const IDENTIFIED:uint	= 5;
		public const HIGHLIGHTED:uint	= 6;
		
		public var touchable:Boolean 	= true;
		public var moveable:Boolean 	= true;
		public var transable:Boolean 	= true;
		public var removable:Boolean 	= true;
		public var clickable:Boolean 	= true;
		public var animated:Boolean 	= false;
		public var rotateable:Boolean 	= true;
		public var multiple:Boolean 	= false;
		public var takeable:Boolean 	= true;
		public var stockable:Boolean 	= false;
		
		public var touchableInGuest:Boolean 	= true;
		
		protected var _touch:Boolean 		= false;
		protected var _move:Boolean 		= false;
		protected var _trans:Boolean 		= false;
		protected var _install:Boolean 	= false;
		protected var _ordered:Boolean 	= false;
		protected var _state:uint 		= DEFAULT;
		protected var _rotate:Boolean 	= false;
		
		protected var previosRotate:Boolean	= false;
		
		
		public var helped:Boolean 	= false;
		
		public var bitmap:Bitmap = new Bitmap(null, "auto", true);
		public var animationBitmap:Bitmap;
		public var layer:String;
		
		public var coords:Object = { x:0, y:0, z:0 };
		public var prevCoords:Object = { x:0, y:0, z:0 };
		
		public var id:uint = 0;
		public var sid:uint = 0;
		public var type:String;
		public var depth:uint = 0;
		public var info:Object;
		public var textures:Object;
		
		public var dx:int;
		public var dy:int;
		
		public var cells:uint = 0;
		public var rows:uint = 0;
		
		public var busy:uint = 0;
		
		public var index:uint = 0;
		
		public var fromStock:Boolean = false;
		
		public static var lastUnit:Object;
		public static var lastRemove:int;
		public var created:int;
		public var open:Boolean = false;
		
		private var _limitedCount:int = 0;
		
		//public var levelLabel:TextField;
		//public var loader:Preloader = new Preloader();
		
		public function Unit(data:Object) {
			
			this.id = data.id || 0;
			this.sid = data.sid || 0;
			
			this.fromStock = data.fromStock || false;
			
			if (this.sid != 0) {
				info = App.data.storage[this.sid];
				type = info.type;
				
				_rotate = data['rotate'] || false;
			
				if (data.area) {
					info.area = data.area;
				}
				else
				{
					if (info.area) 
					{
						if(!_rotate){
							cells = info.area.w || 0;
							rows = info.area.h 	|| 0;
						}else{
							cells = info.area.h || 0;
							rows = info.area.w 	|| 0;
						}
					}
				}
			}
			
			generateCenter();
			
			bitmapContainer.addChild(bitmap);
			addChild(bitmapContainer);
			//addChild(bitmap);
			
			/*var b:Bitmap = new Bitmap(IsoTile._tile);
			b.x = -IsoTile.width * .5;
			addChild(b);*/
			
			//var marker:Shape = new Shape()
			//marker.graphics.beginFill(0xFF0000, 1);
			//marker.graphics.drawRect( 0, 0, 2,2);
			//marker.graphics.endFill();
			//addChild(marker);
			
			//data.x += 17;
			//data.z -= 4;
		
			placing(data.x || 0, data.y || 0, data.z || 0);
			install();
			
			//bitmap.scaleX = 0.999;
			//bitmap.scaleY = 0.999;
			
			mouseEnabled = false;
			//cacheAsBitmap = true;
			//this.mouseEnabled = false
			
			//if (sid != 0) {
				//set
			//}
			/*if (sid == 239) {
				trace('');
			};*/
			if(formed){
				open = App.map._aStarNodes[coords.x][coords.z].open;
				if (!open) {
					clickable = false;
					touchable = false;
				}
			}
		}
		
		public function makeOpen():void {
			open = true;
			clickable = true;
			touchable = true;
		}
		
		public var center:Object = {
			x:0,y:0
		};
		public function generateCenter():void {
			if(info && info.hasOwnProperty('area'))
				center = IsoConvert.isoToScreen(Math.floor(info.area.w / 2), Math.floor(info.area.h / 2), true, true);
		}
		
		public static var classes:Object = { };
		public static function add(object:Object):Unit {
			lastUnit = object;
			
			var type:String = 'units.'+App.data.storage[object.sid].type;
		
			var classType:Class;
			if(classes[type] == undefined){
				classType = getDefinitionByName(type) as Class;
				classes[type] = classType;
			}else{
				classType = classes[type];
			}
			
			var unit:Unit = new classType(object);
			if(unit.formed){
				unit.take();
			}
			
			return unit;
		}
		
		public static function addMore():void {
			if(lastUnit != null){
				if (lastUnit.hasOwnProperty('fromStock') && lastUnit.fromStock == true) {
					if (!App.user.stock.check(lastUnit.sid)) {
						Cursor.type = "default";
						return;
					}
				}
				var unit:Unit = add(lastUnit);
				unit.move = true;
				App.map.moved = unit;
			}
		}
		
		public static function sorting(unit:Unit):void {
			App.map.sorted.push(unit);
		}
		
		public function get formed():Boolean {
			return (this.id > 0);
		}
		
		public function can():Boolean {
			return ordered;
		}
		
		public function get bmp():Bitmap {
			return bitmap;
		}
		
		public function take():void {
			
			if (!takeable) return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			var water:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var waters:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			/*if (rotate) {
				cells = info.area.h;
				rows = info.area.w;
			}*/
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					
					nodes.push(node);
					
					node.isWall = true;
					node.b = 1;
					node.object = this;
					if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND) node.isWall = false;
					
					
					if (i> 0 && i < cells - 1 && j>0 && j < rows -1) {
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						
						part.isWall = true;
						part.b = 1;
						part.object = this;
						if (layer == Map.LAYER_FIELD || layer == Map.LAYER_LAND) part.isWall = false;
						
						if (info.base != null && info.base == 1)
						{
							if (App.map._aStarWaterNodes != null)
							{
								water = App.map._aStarWaterNodes[coords.x + i][coords.z + j];
								waters.push(water);
								water.isWall = true;
								water.b = 1;
								water.object = this;
							}
						}
						
						
					}else {
						//trace('Оставляем пустое пространство');
					}
					
					
					
					/*
					 var _tile:Bitmap = new Bitmap(IsoTile._tile);
						_tile.x = node.tile.x - IsoTile.width*.5;
						_tile.y = node.tile.y;
						App.map.mLand.addChild(_tile);
					*/
					
				}
			}
			
			if(layer == Map.LAYER_SORT){
				App.map._astar.take(nodes);
				App.map._astarReserve.take(parts);
			}
			
			if (info.base != null && info.base == 1) {
				if (App.map._astarWater != null)
					App.map._astarWater.take(waters);
			}
		}
		
		public function free():void {
			if (!takeable) return;
			var node:AStarNodeVO;
			var part:AStarNodeVO;
			
			var nodes:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var parts:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			if(App.map._aStarNodes != null){
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						nodes.push(node);
						node.isWall = false;
						node.b = 0;
						node.object = null;
						
						part = App.map._aStarParts[coords.x + i][coords.z + j];
						parts.push(part);
						part.isWall = false;
						part.b = 0;
						part.object = null;
					}
				}
				
				if(layer == Map.LAYER_SORT){
					App.map._astar.free(nodes);
					App.map._astarReserve.free(parts);
				}
				
				if (info.base != null && info.base == 1) {
					if(App.map._astarWater != null)
						App.map._astarWater.free(nodes);
				}
			}
		}
		
		public function set ordered(ordered:Boolean):void {
			_ordered = ordered;
			if (ordered) {
				clickable = false;
				alpha = .5;
				
				if(touch){
					touch = false;
					var idx:int = App.map.touched.indexOf(this);
					if(idx >= 0){
						App.map.touched.splice(idx, 1);
					}
				}
			}else {
				clickable = true;
				alpha = 1;
			}
		}
		
		public function get ordered():Boolean {
			return _ordered;
		}
		
		public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: bitmap.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: bitmap.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: 
					//TweenMax.to(bitmap, 0.2, { colorTransform: { brightness:1.2 }} );
					//TweenMax.to(bitmap, 0.2, {colorTransform:{tint:0xffff00, tintAmount:0.2, brightness:1.1}});
					bitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; 
				break;
				case HIGHLIGHTED: bitmap.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: bitmap.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: 
					bitmap.filters = []; 
					//TweenMax.to(bitmap, 0.2, { colorTransform: { brightness:1 }} );	
					//TweenMax.to(bitmap, 0.2, {colorTransform:{tint:0xffff00, tintAmount:0, brightness:1}});
				break;
			}
			_state = state;
		}
		
		public function get state():uint {
			return _state;
		}
		
		public function canInstall():Boolean
		{
			return (_state != OCCUPIED);
		}
		
		public function placing(x:uint, y:uint, z:uint):void {
			
			var node:AStarNodeVO;
			
			if ((x < 0 || x+cells > Map.cells) || (z < 0 || z+rows > Map.rows))
			{
				//state = OCCUPIED;
				takeable = false;
				//node = App.map._aStarNodes[x][z];
				//coords = { x:x, y:0, z:z };
				//this.x = node.tile.x;
				//this.y = node.tile.y;
				return;
			}else {
				takeable = true;
			}
			
			
			node = App.map._aStarNodes[x][z];
			
			coords = { x:x, y:y, z:z };
			this.x = node.tile.x;
			this.y = node.tile.y;
			
			calcDepth();
			
			if(move) state = calcState(node);
		}
		
		public function calcState(node:AStarNodeVO):int
		{
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.b != 0 || node.open == false || node.object != null) {
						return OCCUPIED;
					}
				}
			}
			return EMPTY;
		}
		
		public function install():void{
			App.map.addUnit(this);
		}
		
		public function uninstall():void {
			free();
			App.map.removeUnit(this);
			//World.removeBuilding(this);
		}
		
		public function sort(index:*):void {
			App.map.mSort.setChildIndex(this, index);
		}
		
		public function calcDepth():void {
			var left:Object = { x:x - IsoTile.width * rows * .5, y:y + IsoTile.height * rows * .5 };
			var right:Object = { x:x + IsoTile.width * cells * .5, y:y + IsoTile.height * cells * .5 };
			depth = (left.x + right.x) + (left.y + right.y) * 100;
		}
		
		public var bitmapContainer:Sprite = new Sprite();
		public function draw(bitmapData:BitmapData, dx:int, dy:int):void {
			
			bitmap.bitmapData = bitmapData;
			bitmap.smoothing = true;
			//bitmap.scaleX = 1;
			
			this.dx = dx;
			this.dy = dy;
			bitmap.x = dx;
			bitmap.y = dy;
			
			if (rotate && scaleX > 0) {
				scaleX = -scaleX;
			}
		}
		
		
		protected var tween:TweenLite;
		public var transTimeID:uint;
		public function set transparent(transparent:Boolean):void {
			if (!transable || _trans == transparent || (App.user.quests.tutorial && transparent == true))
				return;
			var that:* = bitmapContainer;
			if (transparent == true) {
				_trans = true;
				
				transTimeID = setTimeout(function():void{
					if (SystemPanel.animate)
						tween = TweenLite.to(that, 0.2, { alpha:0.3 } );
					else
						that.alpha = 0.3;
				},150);
				
			}else {
				clearTimeout(transTimeID);
				_trans = false;
				if (tween) {
					tween.complete(true);
					tween.kill();
					tween = null;
				}
				that.alpha = 1;
			}
		}
		
		public function get transparent():Boolean {
			return _trans;
		}
		
		public function previousPlace():void {
			if (_move == true) {
				if(formed){
					_move = false;
					
					if (_rotate != previosRotate) {
						_rotate = !_rotate;
						previosRotate = _rotate;
						var temp:uint = cells;
						cells = rows;
						rows = temp;
						scaleX = -scaleX;
						x -= width * scaleX;
					}
						
					placing(prevCoords.x, prevCoords.y, prevCoords.z);
					take();
					state = DEFAULT;
					App.self.setOffEnterFrame(moving);
				}else {
					_move = false;
					App.self.setOffEnterFrame(moving);
					uninstall();
				}
				if (App.map.moved == this) {
					App.map.moved = null;
				}
			}
		}
		
		public function set move(move:Boolean):void {
			if (!moveable || _move == move) {
				return;
			}
			_move = move;
			if (move) {
				if(formed){
					free();
				}
				prevCoords = coords;
				App.self.setOnEnterFrame(moving);
			}else{
				if(state == EMPTY){
					take();
				
					if(fromStock == true){
						stockAction();
					}else if (!formed) {
						buyAction();
					}else {
						moveAction();
					}
					//App.map._astar.reload();
					//App.map._astarReserve.reload();
					state = DEFAULT;
					App.self.setOffEnterFrame(moving);
					
				}else {
					_move = true;
				}
			}
		}
		
		public function get move():Boolean {
			return _move;
		}
		
		protected function moving(e:Event = null):void {
			if (coords.x != Map.X || coords.z != Map.Z) {
				placing(Map.X, 0, Map.Z);
				if (layer == Map.LAYER_SORT)
				{
					//App.map.depths[index] = depth;
					App.map.sorted.push(this);
				}	
			}
		}
		
		public function flip():void {
			var temp:uint = cells;
			cells = rows;
			rows = temp;
			
			scaleX = -scaleX;
			x -= width * scaleX;
			//bitmap.scaleX = -bitmap.scaleX;
			//bitmap.x = bitmap.width + (-bitmap.width - bitmap.x);
			
			placing(coords.x, coords.y, coords.z);
		}
		
		public function set rotate(rotate:Boolean):void {
			if (!rotateable || _rotate == rotate) return;
			previosRotate = _rotate;
			_rotate = rotate;
			
			free();
			
			Cursor.type = "move";
			Cursor.prevType = "rotate";
			App.map.moved = this;
			move = true;
			
			flip();
			/*var node:AStarNodeVO;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.b != 0) {
						state = OCCUPIED;
					}
				}
			}*/
			
			return;
		}
		
		public function get rotate():Boolean {
			return _rotate;
		}
		
		public function set touch(touch:Boolean):void {
			if (Cursor.type == 'stock' && stockable == false) return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			if (Missionhouse.windowOpened) {
				state = DEFAULT;
				_touch = false;
				return;
			}
			
			_touch = touch;
			
			if (touch) {
				if(state == DEFAULT){
					state = TOCHED;
				}else if (state == HIGHLIGHTED) {
					state = IDENTIFIED;
				}
				
			}else {
				if(state == TOCHED){
					state = DEFAULT;
				}else if (state == IDENTIFIED) {
					state = HIGHLIGHTED;
				}
			}
		}
		
		public function get touch():Boolean {
			return _touch;
		}
		
		public function remove(_callback:Function = null):void {
			
			var callback:Function = _callback;
			
			if (info && info.hasOwnProperty('ask') && info.ask == true)
			{
				//if (sid == 132)
					//return
				new SimpleWindow( {
					title:Locale.__e("flash:1382952379842"),
					text:Locale.__e("flash:1382952379968", [info.title]),
					label:SimpleWindow.ATTENTION,
					dialog:true,
					isImg:true,
					confirm:function():void {
						onApplyRemove(callback);
					}
				}).show();
			}
			else
			{
				onApplyRemove(callback)
			}
		}
		
		public function onApplyRemove(callback:Function = null):void
		{
			if (!removable) return;
			
			Post.send( {
				ctr:this.type,
				act:'remove',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, onRemoveAction, {callback:callback});
			
			this.visible = false;
		}
		
		public function onRemoveAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				this.visible = true;
				return;
			}
			World.removeBuilding(this);
			uninstall();
			if (params.callback != null) {
				params.callback();
			}
		}
		
		public function click():Boolean {
			
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			/*
			if (Cursor.type == 'stock' && stockable == true) {
				putAction();
			}else if (Cursor.type == 'stock' && stockable == false){
				return false;
			}
			*/
			
			App.tips.hide();
			
			return true;
		}
		
		public function animate(e:Event = null):void
		{
			
		}
		
		/********************* ПОЛЬЗОВАТЕЛЬСКИЕ СОБЫТИflash:1382952380041 **************************/
		
		
		public function putAction():void {
			if (!stockable) {
				return;
			}
			if (Stock.value >= Stock.limit) {
				var winSettings:Object = {
					title				:Locale.__e('flash:1393576964828'),
					text				:Locale.__e('flash:1393577003645'),
					buttonText			:Locale.__e('flash:1393576915356'),
					//image				:UserInterface.textures.alert_storage,
					image				:Window.textures.errorStorage,
					imageX				:-78,
					imageY				: -76,
					textPaddingY        : -18,
					textPaddingX        : -10,
					hasExit             :true,
					faderAsClose        :true,
					faderClickable      :true,
					forcedClosing       :true,
					closeAfterOk        :true,
					bttnPaddingY        :25,
					ok					:function():void {
						new StockWindow().show();
					}
				};
				new ErrorWindow(winSettings).show();
				return;
			}
			
			uninstall();
			App.user.stock.add(sid, 1);
						
			Post.send( {
				ctr:this.type,
				act:'put',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, function(error:int, data:Object, params:Object):void {
					
			});
		}
		
		public function stockAction(params:Object = null):void {
			
			if (!App.user.stock.check(sid)) {
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}
			
			App.user.stock.take(sid, 1);
						
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}, onStockAction);
		}
		
		protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}

			//App.map._astar.reload();
			//App.map._astarReserve.reload();
			this.id = data.id;
			if(!(multiple && App.user.stock.check(sid))){
				App.map.moved = null;
			}
			App.ui.glowing(this);
		}
		
		public function buyAction():void {
			
			SoundsManager.instance.playSFX('build');
			
			var obj:Object;
			if (info.hasOwnProperty('instance')) {
				obj = info.instance.cost[World.getBuildingCount(info.sid) + 1];
			}else if (info.hasOwnProperty('price')) {
				obj = info.price;
			}
			
			if(App.user.stock.takeAll(obj)){
			
				World.addBuilding(this.sid);
				Hints.buy(this);
				spit();
				
				Post.send( {
					ctr:this.type,
					act:'buy',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:this.sid,
					x:coords.x,
					z:coords.z
				}, onBuyAction);
				
				dispatchEvent(new AppEvent(AppEvent.AFTER_BUY));
			}else {
				ShopWindow.currentBuyObject.type = null;
				uninstall();
			}
		}
		
		protected function onBuyAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			//App.ui.upPanel.update(["coins"]);
			
			this.id = data.id;
		}
		
		public function moveAction():void {
			
			if (Cursor.prevType == "rotate") Cursor.type = Cursor.prevType;
			
			Post.send( {
				ctr:this.type,
				act:'move',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				x:coords.x,
				z:coords.z,
				rotate:int(rotate)
			}, onMoveAction);
		}
		
		public function onMoveAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				
				free();
				_move = false;
				placing(prevCoords.x, prevCoords.y, prevCoords.z);
				take();
				state = DEFAULT;
				
				//TODO меняем координаты на старые
				return;
			}	
			
			//App.map._astar.reload();
			//App.map._astarReserve.reload();
		}
		
		public function rotateAction():void {
			
			Post.send( {
				ctr:this.type,
				act:'rotate',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				rotate:int(rotate)
			}, onRotateAction);
		}
		
		public function onDown():void 
		{
			
		}
		
		private function onRotateAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				//TODO меняем координаты на старые
				return;
			}	
		}
		
		public static function explode(obj:Object):Object
		{
			for (var sID:* in obj) break;
			return {
				sID:sID,
				id:obj[sID]
			};
		}
		
		public function colorize(data:*):void
		{
			if (data.hasOwnProperty('colorize') && data.colorize) 
				return;
			data['colorize'] = true;
			data.sprites[0].bmp = Nature.colorize(data.sprites[0].bmp, info.type);
		}
		
		public var _worker:Hero = null;
		public function get worker():Hero {
			return _worker;
		}
		public function set worker(value:*):void {
			_worker = value;
		}

		public var spitY:Number;
		public var spitX:Number;
		private var spitCallback:Function;
		public function spit(callback:Function = null, target:* = null):void 
		{
			if (target == null)
				target = bitmap;
				
			if (target is Bitmap) 
				target.smoothing = true;
			
			spitCallback = callback;
			var obj:Object = IsoConvert.isoToScreen(info.area.w, info.area.h, true, true);
			spitY = obj.y;
			spitX = obj.x;
			spitIn(target);
		}
		 
		private function spitIn(target:*):void {
			TweenPlugin.activate([TransformAroundPointPlugin]);
			TweenLite.to(target, 0.3, { transformAroundPoint: { point:new Point(spitX, spitY), scaleX:1.1, scaleY:0.9 }, ease:Strong.easeOut} );//1.2 0.8
			setTimeout(function():void {
				spitOut(target)
			}, 200);
		}
		
		private function spitOut(target:*):void {
			TweenLite.to(target, 1, { transformAroundPoint: { point:new Point(spitX, spitY), scaleX:1, scaleY:1 }, ease:Elastic.easeOut, onComplete:function():void{ } } );
			if (spitCallback != null)
				spitCallback();
		}
		
		public function haloEffect(color:* = null, layer:* = null):void {
			
			//return;
			var that:* = this;
			
			if(layer != null)
				that = layer;
				
			var effect:AnimationItem = new AnimationItem( { type:'Effects', view:'halo3', params: { scale:1 }, onLoop:function():void {
				that.removeChild(effect);
			}});
			//effect.blendMode = BlendMode.ADD;
			that.addChild(effect);
			effect.x = that.mouseX;
			effect.y = that.mouseY;
			
			if (color != null) {
				UserInterface.colorize(effect, color, 1);
			}
		}
	}
}
