package 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.Debug;
	import core.IsoConvert;
	import core.IsoTile;
	import core.Load;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import strings.Strings;
	import ui.Hints;
	import units.Conductor;
	import units.Personage;
	import units.Storehouse;
	import units.Unit;
	import wins.OpenZoneWindow;
	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class World 
	{
		public static const zoneIcon:String = Config.getIcon("Material", 'land');
		public var data:Object;
		public var zones:Array = [];
		public var faders:Object = { };
		public var zoneUnits:Object = { };
		
		private var bonusCoords:Point;
		
		public static var buildingStorage:Object = new Object();
		
		public function World(data:Object)
		{
			faders = new Object();
			zones = new Array();
			
			this.data = data;
			for each(var zone:* in data.zones) {
				zones.push(zone);
			}
			
			buildingStorage = null;
			buildingStorage = new Object();
		}
		
		public static function isOpen(worldID:uint):Boolean {
			if (App.user.worlds.hasOwnProperty(worldID))
				return true;
			
			return false;
		}
		
		public function addUnitToZone(unit:Object, zID:uint):void
		{
			if (zoneUnits[zID] != null) 
				zoneUnits[zID].push(unit);
			else {
				zoneUnits[zID] = new Array();
				zoneUnits[zID].push(unit);
			}
		}
		
		public function drawZones(mapZones:Object):void
		{
			for (var sID:* in mapZones)
			{
				if (zones.indexOf(sID) != -1) continue;
				var fader:Zone = new Zone(sID, mapZones[sID]);
				faders[sID] = fader;
			}
			
			/*Load.loading(Config.resources +'dreams/'+'openZoneLabel.png', function(data:Bitmap):void {
				Zone.openZoneImage = data.bitmapData;
			});*/
		}
		
		public function showOpenZoneWindow(zoneID:uint):void
		{
			if (App.user.quests.tutorial) return;
			
			var data:Object = App.data.storage[zoneID];
			
			var zones:Array = App.user.world.zones;
			var check:int = 0;
			var needZones:Array = [];
			for (var sID:* in data.require)
			{
				if (App.data.storage[sID].type == "Zones")	
				{	
					needZones.push(sID);
					if (App.user.world.zones.indexOf(sID) != -1)
						check++;
				}
			}
			
			if (check == 0 && needZones.length>0)
			{
				new SimpleWindow( {
						title:App.data.storage[zoneID].title,
						label:SimpleWindow.ATTENTION,
						text:Locale.__e("flash:1382952380332")
					}).show();
					return;
			}
			
			if (data.level > App.user.level) {
				new SimpleWindow( {
					title:Locale.__e('flash:1396606807965', [data.level]),
					text:Locale.__e('flash:1405002933543'),
					label:SimpleWindow.ERROR
				}).show();
				
				return;
			}
			
			new OpenZoneWindow({
				sID:zoneID,
				require:data.require,
				unlock:data.unlock,
				openZone:openZone
			}).show();
		}
		
		public static function nodeDefinion(X:Number, Y:Number):AStarNodeVO
		{
			var place:Object = IsoConvert.screenToIso(X, Y, true);
			
			if (place.x<0 || place.x>Map.X) return null;
			if (place.z<0 || place.z>Map.Z) return null;
			
			//var obj:Object = App.map._aStarNodes[place.x][place.z];
			//Debug.log([obj.position.x, obj.position.y,"    ",obj.z], 0xFFFFFF);
			
			return App.map._aStarNodes[place.x][place.z];
		}
		
		public static function checkUnitZone(target:Object):Object
		{
			var node:AStarNodeVO = App.map._aStarNodes[target.x][target.z];
			if (!node.open)
			{
				return{
					result:false,
					zone:node.z
				};
			}else{
				return{
					result:true
				};
			}
		}
		
		public static const ALWAYS_OPENED_ZONE:int = 4;
		public function checkZone(target:Unit = null, openWindow:Boolean = false):Boolean
		{
			var node:AStarNodeVO;
			if (target == null)
				node = World.nodeDefinion(App.map.mouseX, App.map.mouseY);
			else
				node = App.map._aStarNodes[target.coords.x][target.coords.z];
				
			if (node == null || node.z == 0)	return false;
			if (!node.open && node.z != ALWAYS_OPENED_ZONE)
			{
				if (openWindow && App.user.mode == User.OWNER){
					showOpenZoneWindow(node.z);
				}else{
					Hints.text(Locale.__e('flash:1382952380333'), Hints.TEXT_RED,  new Point(App.self.mouseX, App.self.mouseY));
				}
				return false;
			}
			return true;
		}
		
		public function openZone(sID:uint, buy:Boolean = false):void
		{
			var require:Object;
			if (buy)
			{
				var price:int = App.data.storage[sID].price;
				if (!App.user.stock.takeAll(price)) return;
			}
			else
			{
				require = App.data.storage[sID].require;
				for (var sid:* in require)
				{
					if (App.data.storage[sid].type != "Material") {
						delete require[sid];
					}
				}
				if (!App.user.stock.takeAll(require))	return;
			}
			
			Post.send({
				ctr:'world',
				act:'zone',
				uID:App.user.id,
				wID:App.user.worldID,
				zID:sID,
				buy:int(buy)
			},
			function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					for (var _sID:* in require)
					{
						App.user.stock.add(_sID, require[_sID]);
					}
					return;
				}
				
				var fader:Zone = faders[sID];
				//bonusCoords = new Point(fader.x + fader.width / 2, fader.y + fader.height / 2);
				if (data.hasOwnProperty("bonus")) Treasures.bonus(data.bonus, new Point(0,0));
				
				onOpenComplete(sID);
				bonusCoords = null;
				fader = null;
				openUnits(sID);
				openBridge(sID);
				
				if (sID == 180) {
					var fake:* = Map.findUnit(297, 7);
					if (fake != null)
						fake.onApplyRemove();
				}
			});	
		}
		
		private function openUnits(zone_sid:uint):void {
			
			/*var i:int = App.map.mSort.numChildren;
			while (--i >= 0)
			{
				var unit:* = App.map.mSort.getChildAt(i);
				var node:AStarNodeVO = App.map._aStarNodes[unit.coords.x][unit.coords.z];
				if (node.z == zone_sid)
					unit.makeOpen();
			}*/
		}
		
		private function onOpenComplete(sID:uint):void
		{
			changeNodes(sID);
			//faders[sID].dispose();
			//delete faders[sID];
			zones.push(sID);
			
			new SimpleWindow( {
				title:App.data.storage[sID].title,
				label:SimpleWindow.BUILDING,
				text:Locale.__e("flash:1382952380334"),
				sID:sID,
				confirm:function():void {
					openZonePost(sID);
				}
			}).show();
		}
		
		public function dispose():void
		{
			for each(var zone:Zone in faders)
			{
				zone.dispose();
			}
			zoneUnits = { };
			faders = null;
			zones = [];
			data = null;
		}
		
		public static function zoneIsOpen(sID:uint):Boolean
		{	
			if (sID == 83) return true;
			var world:World;
			if (App.user.mode == User.OWNER)
				world = App.user.world;
			else	
				world = App.owner.world;
				
			if (world.zones.indexOf(sID) == -1) 
				return false;
				
			return true;
		}
		
		public function changeNodes(sID:uint):void
		{
			var x : uint = 0;
			var z : uint = 0;
			
			while ( x < Map.cells) {
				z = 0;
				while ( z < Map.rows){
					if (App.map._aStarNodes[x][z].z == sID)
					{
						App.map._aStarNodes[x][z].open = true;
						if (App.map._aStarNodes[x][z].object != null){
							App.map._aStarNodes[x][z].object.makeOpen();
						}
					}	
					z++;	
				}
				x++;
			}		
			
			
		}
		
		public function openZonePost(sID:uint):void
		{
			//Пост на стену
			//var message:String = Locale.__e('flash:1382952380041 открыл новую территорию \"%s\" в игре \"flash:1382952379705\". %s',[App.data.storage[sID].title, Config.appUrl]);
			
			
			//var message:String = Strings.__e('World_openZonePost',[App.data.storage[sID].title, Config.appUrl]);
			//
			//var back:Sprite = new Sprite();
			//var front:Sprite = new Sprite();
			//
			//var bitmap:Bitmap = new Bitmap(Zone.openZoneImage);
			//back.addChild(bitmap);
			//bitmap.smoothing = true;
			//var gameTitle:Bitmap = new Bitmap(Window.textures.logo, "auto", true);
			//back.addChild(gameTitle);
			//gameTitle.x = 0;
			//gameTitle.y = bitmap.height - 34;
			//bitmap.x = (gameTitle.width - bitmap.width) / 2 - 5;
			//var bmd:BitmapData = new BitmapData(Math.max(bitmap.width, gameTitle.width), back.height);//, true, 0);
			//bmd.draw(back);
			//
			//ExternalApi.apiWallPostEvent(ExternalApi.NEW_ZONE, new Bitmap(bmd), App.user.id, message);
			
			WallPost.makePost(WallPost.NEW_ZONE, {sid:sID});
			
			//End Пост на стену
		}
		
		/*public var conductor:Conductor
		public function addConductor():void {
			if (App.user.worldID == User.HOME_WORLD) return;
			conductor = new Conductor({ id:0, sid:Personage.CONDUCTOR, x:App.map.heroPosition.x - 5, z:App.map.heroPosition.z + 2} );
			Unit.sorting(conductor);
		}*/
		
		public function openWorld(wID:uint, buy:Boolean = false, callback:Function = null):void
		{
			var worldID:uint = wID;
			var require:Object;
			if (buy)
			{
				var price:int = App.data.storage[wID].unlock.price;
				if (!App.user.stock.take(Stock.FANT, price)) return;
			}
			else
			{
				require = App.data.storage[wID].require;
				for (var sid:* in require)
				{
					if (App.data.storage[sid].type != "Material") {
						delete require[sid];
					}
				}
				if (!App.user.stock.takeAll(require))	return;
			}
			
			Post.send({
				ctr:'world',
				act:'open',
				uID:App.user.id,
				wID:worldID,
				buy:int(buy)
			},
			function(error:*, data:*, params:*):void {
				
				if (error) {
					Errors.show(error, data);
					for (var _sID:* in require)
						App.user.stock.add(_sID, require[_sID]);
					return;
				}
				
				App.user.worlds[worldID] = worldID;
				if (callback != null) callback(worldID);
			});	
		}
		
		
		public static function tagUnit(sid:uint):void {
			
			var type:String = App.data.storage[sid].type;
			switch(type) {
				case 'Building':
				case 'Mining':
				case 'Storehouse':	
				case 'Factory':	
				case 'Field':
				case 'Moneyhouse':	
				case 'Trade':		
				case 'Fplant':		
				case 'Buffer':		
				case 'Collector':
				case 'Tradesman':	
						addBuilding(sid);
					break;
			}
		}
		
		public static function addBuilding(sid:int):void
		{
			if (buildingStorage[sid]) {
				buildingStorage[sid] += 1;
				return;
			}
			
			buildingStorage[sid] = 1;
		}
		
		public static function removeBuilding(unit:Unit):void
		{
			//buildingStorage[sid] -= 1;
		
			switch(unit.type) {
				case 'Building':
				case 'Mining':
				case 'Storehouse':
				case 'Factory':	
				case 'Moneyhouse':	
				case 'Trade':	
				case 'Fplant':	
				case 'Buffer':
				case 'Collector':		
				case 'Tradesman':		
						buildingStorage[unit.sid] -= 1;
					break;
				case 'Field':
						buildingStorage[unit.sid] -= 1;
					break;
			}
		}
		
		public static function getBuildingCount(sid:int):int 
		{
			if (buildingStorage[sid]) {
				return buildingStorage[sid];
			}
			return 0;
		}
		
		public function openBridge(zone_sid:int):void 
		{
			if(bridges.hasOwnProperty(zone_sid)){
				var unit:Unit = Unit.add(bridges[zone_sid]);
				unit.buyAction();
			}
		}
		
		public var bridges:Object = {
			186:{// северный островок 
				sid: 271,
				x: 17,
				z: 34
			},
			181:{// водопад 
				sid: 272,
				x: 29,
				z: 40
			},
			184:{// березова роща
				sid: 273,
				x: 97,
				z: 115
			},
			185:{// Западный островок
				sid: 274,
				x: 57,
				z: 135
			},
			183:{// Маяк
				sid: 372,
				x: 130,
				z: 74
			}
		}
	}
}