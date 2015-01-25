package units
{
	import astar.AStarNodeVO;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ui.Cloud;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import wins.BuildingConstructWindow;
	import wins.ErrorWindow;
	import wins.HutWindow;
	import wins.JamWindow;
	import wins.ProductionWindow;
	import wins.RepairWindow;
	import wins.SimpleWindow;
	import wins.WindowEvent;
	
	public class Hut extends AUnit
	{
		public static const WOOD:uint 	= 18;
		public static const STONE:uint 	= 108;
		public static const BAG:uint 	= 114;
		public static const WATER:uint 	= 608;
		
		public static const FREE:uint 		= 0;
		public static const BUSY:uint 		= 1;
		public static const DAMAGED:uint 	= 2;
		
		public static var selectedHut:Hut 	= null;
		public static var huts:Array 		= [];
		
		public var level:uint = 0;
		public var workers:Object;
		public var stacks:Object;
		public var targets:Object;
		public var bears:Object = { };
		
		public var _working:Boolean = false;
		public var old:int = 0;
		private var workerType:String;
		
		public function Hut(object:Object)
		{
			layer = Map.LAYER_SORT;
			
			bears = object.bears || { };
			
			
			if (!formed)
				addEventListener(AppEvent.AFTER_BUY, onAfterBuy); 
				
			super(object);
			
			touchableInGuest = false;
			
			/*if (sid == STONE) {
				var _target:Resource = Map.findUnit(74, 124);
				var time:uint = App.time;
				trace(sid);
			}*/
			
			if (object.hasOwnProperty('old'))
			{
				old = object.old;
				if (old >= info.limit) 
				{
					level = DAMAGED;
					if (textures) updateLevel();
					flag = "needRepair";
				}
			}	
				
			Load.loading(Config.getSwf(type, info.view), onLoad);
			
			if (formed){
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, initStacks);
			}
			
			working = false;
			
			tip = function():Object { 
				return {
					title:info.title,
					text:info.description
				};
			};
			
			if (info.worker == Personage.BEAVER)
				workerType = 'beaver';
			else
				workerType = 'bear';
		}
		
		public override function install():void{
			
			if (Hut.huts.indexOf(this) == -1)
			{
				Hut.huts.push(this);
			}
			super.install();
		}
		
		override public function remove(callback:Function = null):void {
			
			var doRemove:Boolean = true;
			for (var i:* in bears)	
			{
				if (bears[i].stacks > 0)				doRemove = false;
				if (bears[i].hasOwnProperty('bear'))	doRemove = false;
			}
			
			if (!doRemove)
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1382952379927"),
					label:SimpleWindow.ERROR,
					text:Locale.__e("flash:1382952379928")
				}).show();
				
				return;
			}
			
			super.remove();
		}
		
		public override function uninstall():void {
			var index:uint = Hut.huts.indexOf(this);
			if (index != -1)
			{
				Hut.huts.splice(index, 1);
			}
			super.uninstall();
		}
		
		private function onAfterBuy(e:AppEvent):void
		{
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			App.user.stock.add(Stock.EXP, info.experience);
			Hints.plus(Stock.EXP, info.experience, new Point(this.x + App.map.x, this.y + App.map.y), true);
			
			if (Bear.selectedBear != null)
			{
				Hut.selectedHut = this;
				Bear.selectedBear.createWorkIcons();
				Bear.selectedBear = null;
			}
			
			App.ui.flashGlowing(this);
		}
		
		private function initStacks(e:AppEvent):void
		{
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, initStacks);
			
			var bear:Bear;
			var bearID:uint;
			var target:*;
			
			for (var i:String in bears)
			{
				if (bears[i].hasOwnProperty("bear"))
				{
					//bearID = bears[i].bear[Personage.BEAR];
					var bear_sID:uint = Unit.explode(bears[i].bear).sID;
					bearID = Unit.explode(bears[i].bear).id;
					
					var tsID:uint = Unit.explode(bears[i].target).sID;
					var tID:uint = Unit.explode(bears[i].target).id;
					
					target = Map.findUnit(tsID, tID);
					if (target == null) {
						target = { info:App.data.storage[tsID] };
						target.info['sid'] = tsID;
					}
					bears[i].target = target;
					
					if (bears[i].stacks < 0) 
						bears[i].stacks = 0;
						
					var targetBear:* = Bear.findBear(bearID);
					if (targetBear == false)
					{
						if (App.user.mode == User.OWNER)
							fireWorkerEvent(i);
							
						delete bears[i].bear;
						continue;
					}
					
					bear = targetBear;
					// Расчитываем сколько должно быть стеков собранно
					var newStacksCount:uint = Hut.stacksCanBeCompleted(info.stacks - bears[i].stacks, bear, bears[i].started, target);
					bears[i].stacks = bears[i].stacks + newStacksCount;
					
					//Занимаем стеки, отнимаем jam и ресурсы
					bear.takeJam(newStacksCount);
					if(target is Resource) target.takeResource(newStacksCount);
					
					var newStarted:uint = bears[i].started + newStacksCount * target.info.jobtime;
					
					//Решаем что делать медведю
					bear.hut = this;
					bear.status = Bear.HIRED;
					bears[i].bear = null;
					bears[i].bear = bear;
					bear.loadStack(sid);
					Hut.checkBearToDo(bears[i].stacks, bear, target, this, newStarted);
				}
			}
			
			checkOnFullStacks();
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			
			textures = data;
			updateLevel();
			
			if (cloud != null) {
				cloud.y = dy// - cloud.height - 3;
			}
		}
		
		public function updateLevel(checkRotate:Boolean = false):void {
			var levelData:Object = textures.sprites[this.level];	
			
			if (this.level == BUSY) {
				startSmoke();
			}else {
				stopSmoke();
			}
			
			if (checkRotate && rotate) {
				flip();
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			if (textures.hasOwnProperty('animation')){
				addAnimation();
				startAnimation();
			}
		}
		
		override public function click():Boolean{
			if (!super.click()) return false;
			//addDataToArchive();
			if (old >= info.limit)
			{
				new RepairWindow({
					title:Locale.__e("flash:1382952379886"),
					price:info.price,
					onRepair:repairEvent,
					popup:true
				}).show();
				return false;		
			}			
			
			new HutWindow({
				title:info.title,
				target:this,
				selectTargetAction:selectTargetAction,
				storageAction:onStorageAction,
				fireAction:fireAction,
				onRepair:repairEvent,
				worker:workerType
			}).show();
			
			return true;
		}
		
		private function repairEvent():void
		{
			if (!App.user.stock.takeAll(info.price)) return;
			
			App.ui.flashGlowing(this);
			
			old = 0;
			Post.send( {
				ctr:this.type,
				act:'repair',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, 
			function(error:int, data:Object, params:Object = null):void
			{
				if (error)
				{
					Errors.show(error, data);
					return;
				}
				
				// Зачисляем на склад
				Treasures.bonus(data.bonus, new Point(this.x, this.y));
			});	
			
			working = false;
		}
		
		private function onStorageAction(workerID:uint):void
		{
			bears[workerID].stacks --;
			if (bears[workerID].bear != null && bears[workerID].bear.started == 0) {
					Hut.checkBearToDo(bears[workerID].stacks, bears[workerID].bear, bears[workerID].target, this, App.time); 
			}
			old++;
			
			if (bears[workerID].stacks == 0 && bears[workerID].bear == null)
			{
				delete bears[workerID];
			}
			
			checkOnFullStacks();
			
			Post.send( {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				worker:workerID
			},
			function(error:int, data:Object, params:Object = null):void
			{
				if (error)
				{
					addDataToArchive();
					Errors.show(error, data);
					return;
				}
				
				//return;
				old = data.old;
				delete data['old'];
				
				// Зачисляем на склад
				for (var sID:* in data)	App.user.stock.data[sID] = data[sID];
			});	
			
			if (old >= info.limit)
			{
				new RepairWindow({
					title:Locale.__e("flash:1382952379929"),
					price:info.price,
					onRepair:repairEvent,
					popup:false,
					forcedClosing:true
				}).show();
					
				level = DAMAGED;	
				flag = "needRepair";
				updateLevel(true);
			}
		}
		
		private function selectTargetAction(workerID:uint):void
		{
			var bear:Bear = Bear.isFreeBears();
			selectedHut = this;
			
			if (bear == null)
			{
				var settings:Object = { view:'jam' };
				if (workerType == 'beaver')
					settings['view'] = 'fish';
				
				new JamWindow(settings).show();
			}
			else
			{
				App.map.focusedOn(bear);
				bear.createWorkIcons();
			}
		}
		
		private function fireAction(workerID:uint):void
		{
			fireWorker(bears[workerID].bear);
		}
		
		public function beginWork(target:Resource, bear:Bear):void
		{
			var self:Hut = this;
			Post.send( {
				ctr:this.type,
				act:'hire',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				tID:target.id,
				tsID:target.sid,
				bID:bear.id,
				bsID:bear.sid
			}, 
				function(error:int, data:Object, params:Object = null):void
				{
					if (error)
					{
						addDataToArchive();
						Errors.show(error, data, {
							buttonText			:Locale.__e("flash:1382952379930"),
							ok					:null,
							closeAfterOk		:true
						});
						return;
					}
					
					bear.beginWork(data.started, target, self);
					addBear(bear);
				}
			);
		}
		
		public function addBear(bear:Bear):void
		{
			var newID:uint = 0;
			for (var i:int = 0; i < 3; i++)
			{
				if (bears[i] == null || (bears[i].bear == null && bears[i].stacks == 0))
				{
					newID = i;
					break;
				}
			}
			
			var target:Resource = bear.resource;
				
			bears[newID] = { 
				bear:bear,
				started:bear.started,
				target:target,
				stacks:0
			}
			
			working = true;
		}
		
		public function fireWorker(bear:Bear):void
		{
			var workerID:int = -1;
			for (var i:* in bears)	
			{
				if (bears[i].hasOwnProperty("bear"))
				{
					if (bear.id == bears[i].bear.id) 
					{
						workerID = i;
					}
				}	
			}
			if (workerID == -1) return;
			
			bears[workerID].bear.fire();
			delete 	bears[workerID].bear;
			
			var target:* = bears[workerID].target;
			if (target is Resource) target.busy = 0;
			
			if (bears[workerID].stacks == 0) delete bears[workerID];
			
			fireWorkerEvent(workerID);
			
			working = false;
		}
		
		private function fireWorkerEvent(workerID:*):void {
			Post.send( {
				ctr:this.type,
				act:'fire',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				worker:workerID
			}, 
				function(error:int, data:Object, params:Object = null):void
				{
					if (error)
					{
						Errors.show(error, data);
						return;
					}
				}
			);
		}
		
		public function isFreeWorkPlaces():Boolean
		{
			var count:int = 0;
			for (var i:* in bears)
			{
				if (bears[i].bear == null && bears[i].stacks == 0) continue;
				count++;
			}
			
			if(count<info.workers)	return true;			
			else
			{
				/*new SimpleWindow({ 
						text:Locale.__e("flash:1382952379931"),
						label:SimpleWindow.ERROR
					}).show();*/
				return false;	
			}
		}
		
		public function addResource(bear:Bear, resource_sID:uint):*
		{
			//trace("addResource");
			
			var stacks:uint = 100;
			for (var i:* in bears)
			{
				if (!bears[i].bear) continue;
				if (bear.id == bears[i].bear.id)
				{
					if (bears[i].stacks < info.stacks)
					{
						bears[i].stacks ++;
						stacks = bears[i].stacks
						break;
					}
				}
			}
			
			dispatchEvent(new WindowEvent("onHutUpdate"));
			checkOnFullStacks();
			
			return stacks;
		}
		
		public static function stacksCanBeCompleted(freeStacks:uint, bear:Bear, started:uint, resource:*):uint
		{
			var resTaken:uint = Math.floor((App.time - started) / resource.info.jobtime);
			var jam:uint = bear.jam;
			var capacity:uint = 0;
			if (resource is Resource) capacity = resource.capacity;
			
			var result:uint = Math.min(freeStacks, jam, capacity, resTaken);
			return result;
		}
		
		public static function checkBearToDo(stacks:uint, bear:Bear, resource:*, hut:Hut, started:uint):void
		{
			if (resource == null || !(resource is Resource) ||resource.capacity == 0)
			{
				bear.cantWork("noTarget");
				return;
			}
			else
			{
				bear.resource = resource;
				resource.busy = true;
			}
			
			if (bear.jam <= 0)
			{
				bear.cantWork("noJam");
				return;
			}
			
			if (stacks >= hut.info.stacks)
			{
				bear.cantWork("noStacks");
				return;
			}
			
			// Если все есть отправляем работать
			bear.beginWork(started, resource, hut);
		}
		
		public function findPlaceNear():Object
		{
			var radius:uint = 5;
			var places:Array = [];
			for (var pX:int = 0; pX < info.area.w + radius; pX++)
			{
				for (var pY:int = 0; pY < info.area.h + radius; pY++)
				{
					if (pX <= info.area.w  && pY <= info.area.h) continue; 
					
					var placeX:Number = pX + coords.x;
					var placeY:Number = pY + coords.z;
					
					if (placeX >= Map.cells || placeY >= Map.rows)	continue;
					
					if (info.base && info.base == 1){
						if (App.map._aStarWaterNodes[placeX][placeY].isWall){ continue;}
					}else{
						if (App.map._aStarNodes[placeX][placeY].isWall) { continue; }
					}	
					
					places.push( { x:pX, z:pY} );
				}
			}
			
			if (places.length == 0) {
				places.push( { x:coords.x, z:coords.z } );
			}
			var random:uint = int(Math.random() * (places.length - 1));
			return places[random];
		}
		
		public function takeWorkerID(bear:Bear):int
		{
			for (var i:* in bears)	
			{
				if (bears[i].hasOwnProperty("bear"))
				{
					if (bear.id == bears[i].bear.id) 
					{
						return i;
					}
				}	
			}
			
			return -1;
		}
		
		public function set working(value:Boolean):void
		{
			if (!value)
			{
				for (var i:* in bears)
				{
					if (bears[i].hasOwnProperty("bear"))	value = true;
				}
			}	
				
			if(value)
				level = BUSY;
			else
				level = FREE;
				
			if (checkOnFullStacks() && flag == Cloud.HAND) {
				
			}else{
				flag = false;
			}
			if (old >= info.limit)
			{
				level = DAMAGED;	
				flag = "needRepair";
			}
				
			_working = value;
			if (textures) updateLevel(true);
		}
		public function get working():Boolean
		{
			return _working;
		}
		
		public static function checkHuts(type:uint):Boolean
		{
			for each(var hut:Hut in huts)
			{
				if (hut.sid == type) return true
			}
			
			return false;
		}
			
		public static function findHuts(sID:uint):Array
		{
			var possibleHuts:Array = [];
			for each(var hut:Hut in huts)
			{
				if (hut.sid == sID && hut.isFreeWorkPlaces())
				{
					possibleHuts.push(hut);
				}
			}
			return possibleHuts;
		}
		
		/**
		 * Определяем ближайший домик к целе flash:1382952379993 списка возможных
		 * @param	resource
		 * @param	possibleHuts
		 * @return
		 */
		public static function findNearestHut(resource:Resource, possibleHuts:Array):Hut
		{
			if (Hut.selectedHut != null) return Hut.selectedHut;
			
			var selectedHut:Hut = null;
			var minDistants:int = 10000;
			for each(var hut:Hut in possibleHuts)
			{
				var path:Vector.<AStarNodeVO> = App.map._astar.search(App.map._aStarNodes[hut.coords.x][hut.coords.z], App.map._aStarNodes[resource.coords.x][hut.coords.z]);
				if (path == null) continue
				
				if (path.length < minDistants)
				{
					minDistants = path.length;
					selectedHut = hut;
				}
			}
			
			if (selectedHut == null)
			{
				return possibleHuts[0];
			}
			
			return selectedHut;
		}
		
		public function checkOnFullStacks():Boolean
		{
			for (var i:* in bears)	
			{
				if (bears[i].stacks == info.stacks)
				{
					if (old >= info.limit)
						flag = "needRepair"
					else
						flag = "hand";
					return true
				}
			}
			
			if (flag != "needRepair") flag = false;
			return false;
		}
		
		/**
		 * Показываем рабочее место мишки
		 * @param	bear
		 */
		public function ShowBearWorkPlace(bear:Bear):void
		{
			var workerID:int = takeWorkerID(bear);
			if (workerID < 0) return;
			var that:Hut = this;
			
			if (old >= info.limit)
			{
				new SimpleWindow( {
					title:Locale.__e("flash:1382952379932"),
					height:380,
					label:SimpleWindow.ATTENTION,
					text:Locale.__e("flash:1382952379933"),
					buttonText:Locale.__e("flash:1382952379934"),
					ok:function():void {
						
						App.map.focusedOn(that);
						new RepairWindow({
							title:Locale.__e("flash:1382952379935"),
							price:info.price,
							onRepair:repairEvent,
							popup:true
						}).show();
					}
				}).show()
				return;		
			}			
			
			new HutWindow({
				title:info.title,
				target:this,
				selectTargetAction:selectTargetAction,
				storageAction:onStorageAction,
				fireAction:fireAction,
				onRepair:repairEvent,
				glowedWorker:workerID,
				worker:workerType
			}).show();
		}
		
		public static function dispose():void
		{
			huts = [];
		}
		
		public function getPosition():Object {
			if(info.view == 'waterhut')
				return	{ x:info.area.w - 1, y:info.area.h - 1 }
			
			return	{ x:info.area.w + 1, y:info.area.h - 1 }	
		}
		
		private function addDataToArchive():void
		{
			try{
			var result:String = "--- HuT ---\n"
			for (var bID:* in bears)
			{
				result += bID +":   " + bears[bID].bear + " stacks:" + bears[bID].stacks + " started:" + bears[bID].started + " target:" + bears[bID].target + " \n";
				if (bears[bID].bear && bears[bID].bear is Bear)
				{
					result += "bearID: " + bears[bID].bear.id +'\n';
				}
				if (bears[bID].target)
				{
					if(bears[bID].target is Resource)
						result += "capacity: " + bears[bID].target.capacity +'\n';
				}	
			}
			
			Post.addToArchive(result, false)
			}catch (e:Error) {
				Post.addToArchive('error: addDataToArchive')
			}
		}
	}
}

