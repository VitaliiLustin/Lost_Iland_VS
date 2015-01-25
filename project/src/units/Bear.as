package units 
{
	import astar.AStar;
	import com.greensock.TweenLite;
	import core.Debug;
	import core.IsoTile;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.Cloud;
	import ui.ContextMenu;
	import ui.Cursor;
	import ui.IconsMenu;
	import ui.ProgressBar;
	import ui.UpPanel;
	import ui.UserInterface;
	import wins.ErrorWindow;
	import wins.JamWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.WindowEvent;
	import astar.AStarNodeVO;
	/**
	 * ...
	 * @author 
	 */
	public class Bear extends Personage
	{
		public static var bears:Array = new Array();
		private var time:uint					= 1000;
		private var onTimerCallback:Function 	= null;
		
		public static const WOOD_HUT:uint 	= 18;
		public static const STONE_HUT:uint 	= 108; 
		public static const FOREST_HUT:uint = 114;
		public static const WATER_HUT:uint 	= 608;
		
		public static const	ANIM_WALK:String 		= "walk";
		public static const	ANIM_WORK:String 		= "work";
		public static const	ANIM_WAIT:String 		= "wait";
		public static const	ANIM_CARRY:String 		= "carry";
		public static const	ANIM_STOP:String 		= "walk";
		public static const	ANIM_LEARN:String 		= "work";
			
		public static const ACTION_WAIT:uint		= 0;
		public static const ACTION_WALK:uint 		= 1;
		public static const ACTION_WORK:uint 		= 2;
		public static const ACTION_LEARN:uint 		= 3;
		public static const ACTION_STOP:uint 		= 4;
		public static const ACTION_BORN:uint 		= 5;
		
		public static const FREE:uint 				= 0;
		public static const HIRED:uint 				= 1;
		
		public var _status:uint = Bear.FREE;
		public var _action:uint = ACTION_WALK;
		
		public var hut:Hut				= null;
		public var resource:Resource   	= null;
		public var jam:uint 			= 0;
		public var job:uint 			= 0;
		public var lived:uint 			= 0;
		public var started:uint 		= 0;
		public var hired:Boolean		= false;
		
		public var alert:String = "";
		
		public var progressBar:ProgressBar;
		
		private var timer:Timer; 
		private var direction:String = "";
		
		public var possibleTargets:Array = [];
		public var possibleSIDs:Array = [];
		public var possibleHuts:Array = [];
		
		public static var selectedBear:Bear = null;
		
		public var work:Function = null;
		public var stackAnimation:Object = null;
		
		public function Bear(object:Object)
		{
			if (object.sid != Personage.BEAVER) {
				preloader = new Bitmap(UserInterface.textures.bearLoader);
				preloader.x = -37;
				preloader.y = -85;
			}
			else
			{
				preloader = new Bitmap(UserInterface.textures.beaverLoader);
				preloader.x = -30;
				preloader.y = -40;
			}	
				
			//App.data.storage[object.sid].view = 'beaver';
			super(object);
			
			takeable 			= false;
			clickable 			= false;
			touchableInGuest 	= false;
			transable 			= false;
			removable 			= false;
			moveable			= true;
			rotateable			= false;
			
			hasMultipleAnimation = true;
			
			tm = new TargetManager(this);
			framesType = ANIM_STOP;
			
			addToBearList();
			
			timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER, finishAction);
			
			if (formed) 
			{
				job = object.job;
				jam = object.jam;
				doWait();
				
				if (jam == 0)
				{
					alert = Locale.__e("flash:1382952379857");
					flag = "noJam";
					//checkOnDie(lived);
				}
			}
			else
			{
				//App.ui.glowing(App.ui.upPanel.bearBar, 0xFFFF00);
			}
			
			tip = function():Object { 
				var text:String = '';
				if (jam) {
					if(sid == Personage.BEAR)
						text = Locale.__e("flash:1382952379858", [jam]) + "\n";
					else
						text = Locale.__e("flash:1382952379859", [jam]) + "\n";
				}
				text += alert;
			
				if (started != 0) text += "\n" + TimeConverter.timeToStr((resource.info.jobtime + started) - App.time);
				return {
					title:info.title,
					text:text,
					timer:true
				};
			};
			
			work = function():Object {
				
				if (resource == null)
				{
					return {
						leftTime: 0,
						progress: 0
					}
				}
				return {
					leftTime: resource.info.jobtime - (App.time - started),
					progress: (App.time - started) / resource.info.jobtime
				}
			}
			
			Unit.sorting(this);
			
			/*if(sid == Personage.BEAR){
				if (Nature.mode == Nature.HALLOWEEN) {
					UserInterface.effect(this, 0, 0);
					this.alpha = 0.5
					//this.filters = [new GlowFilter(0xFFFFFF, 1, 10, 10)];
				}
			}*/
		}
		
		public function addToBearList():void {
			bears.push(this);
			App.ui.upPanel.update();
		}
		
		private function onStackLoad(data:*):void
		{
			stackAnimation = data.animation.animations
		}
		
		private function checkOnDie(lived:uint):void
		{
			if (App.time - lived > 3000)
			{
				kickAwayAction();
			}
		}
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			
			//Не пересчитываем маршрут, если идем в ту же клетку
			onPathComplete = _onPathComplete;
			
			if (_walk) {
				if (path[path.length - 1].position.x == cell && path[path.length - 1].position.y == row) {
					return;
				}
			}
			
			if (!(cell in App.map._aStarNodes)) {
				return;
			}
			if (!(row in App.map._aStarNodes[cell])) {
				return;
			}
			
			var _astar:AStar;
			var _aStarNodes:Vector.<Vector.<AStarNodeVO>>;
			if(sid == Personage.BEAVER)	{
				_astar = App.map._astarWater;
				_aStarNodes = App.map._aStarWaterNodes;
				
				if (_aStarNodes[cell][row].isWall ){
					walking();
					return;
				}
			}else{
				_astar = App.map._astar;
				_aStarNodes = App.map._aStarNodes;
				
				if (App.map._aStarParts[cell][row].isWall ){
					walking();
					return;
				}
			}
				
			path = _astar.search(_aStarNodes[this.cell][this.row], _aStarNodes[cell][row]);
				
			if (path == null) {
				trace('Не могу туда пройти по-нормальному!');
				//App.map._astarReserve.reload();
				if(sid != Personage.BEAVER)
					path = App.map._astarReserve.search(App.map._aStarParts[this.cell][this.row], App.map._aStarParts[cell][row]);
				
				if(path == null){
					this._walk = false;
					pathCounter = 1;
					t = 0;
					App.self.setOffEnterFrame(walk);
					trace('Не могу туда пройти!');
					return;
				}
			}
			
			
			/*for each(var node:* in path) {
				var _tile:Bitmap = new Bitmap(IsoTile._tile);
				_tile.x = node.tile.x - IsoTile.width*.5;
				_tile.y = node.tile.y;
				App.map.mLand.addChild(_tile);
			}*/
			
			pathCounter = 1;
			t = 0;
			walking();
		}
		
		/**
		 * Ищем путь к цели
		 */
		/*public function findPath(start_cell:int, start_row:int, finish_cell:int, finish_row:int):Vector.<AStarNodeVO>
		{
			if (sid == Personage.BEAR)
				return super.findPath(start_cell, start_row, finish_cell, finish_row);
			
			var path:Vector.<AStarNodeVO>;
			if (App.map._astarWater != null)
				path = App.map._astarWater.search(App.map._aStarWaterNodes[start_cell][start_row], App.map._aStarWaterNodes[finish_cell][finish_row]);
					
			return path;
		}*/
		
		/**
		 * Отправляем цель в TargetManager
		 * @param	targetObject имеет target, jobPosition, callback
		 */
		public function addTarget(targetObject:Object):void
		{
			tm.add(targetObject);
		}
		
		public function takeJam(count:uint = 1):Boolean
		{
			if (jam - count >= 0)
			{
				jam -= count;
				if (jam == 0) flag = "noJam";
				return true
			}
			return false;
		}
		
		public function addJam(count:uint = 1):void
		{
			jam += count;
		}
		
		/**
		 * Кликаем по голове
		 */
		override public function click():Boolean {
			if (!super.click()) return false;
			
			if (flag != false || jam == 0)
			{
				prevFlag = flag;
				flag = false;
				createBearIcons();
				
			}else{
				
				if (_status == Bear.HIRED) return false;
				createWorkIcons();
			}
			
			return true;
		}
		
		public var iconMenu:IconsMenu;
		
		public function createWorkIcons():void
		{
			var icons:Array = [];
			var dY:int = 0;
			if(sid == Personage.BEAR){
				icons.push( { status:Hut.checkHuts(WOOD_HUT),	image:UserInterface.textures.bearIconWood, 	callback:showTargets, params:WOOD_HUT, description:Locale.__e("flash:1382952379860") } );
				icons.push( { status:Hut.checkHuts(STONE_HUT), 	image:UserInterface.textures.bearIconStone,	callback:showTargets, params:STONE_HUT, description:Locale.__e("flash:1382952379861") } );
				icons.push( { status:Hut.checkHuts(FOREST_HUT), image:UserInterface.textures.bearIconTake,	callback:showTargets, params:FOREST_HUT, description:Locale.__e("flash:1383658919413") } );
				
			}	
			
			if (sid == Personage.BEAVER) {
				dY = 55;
				icons.push( { status:Hut.checkHuts(WATER_HUT),	image:UserInterface.textures.bearIconBeaver, callback:showTargets, params:WATER_HUT, description:Locale.__e("flash:1382952379860") } );
			}	
			
			icons.push( { status:true,	image:UserInterface.textures.bearIconKick, 	callback:kickAwayAction, params:null, scale:0.7, description:Locale.__e("flash:1382952379871") } );
			iconMenu = new IconsMenu(icons, this, null, dY);
			iconMenu.show();
				
			if(Hut.selectedHut == null) return;
			for each(var _icon:* in iconMenu.icons)
			{
				if (_icon.settings.params == Hut.selectedHut.sid)	_icon.showGlowing();
			}
		}
		
		public function createBearIcons():void
		{
			var dY:int = 0;
			var icons:Array = [];
			if (jam == 0) {
				if (sid == Personage.BEAR) {
					icons.push( { status:true,	image:UserInterface.textures.bearIconJam, 	callback:feedAction, params:null, description:Locale.__e("flash:1382952379872")} );
				}
				if (sid == Personage.BEAVER) {
					icons.push( { status:true,	image:UserInterface.textures.bearIconJamFish, 	callback:feedAction, params:null, description:Locale.__e("flash:1382952379872")} );
				}
			}
				
			if (prevFlag == Cloud.NO_PLACE)	
				icons.push( { status:true,	image:UserInterface.textures.bearIconHand, 	callback:showInHutAction, params:null, description:Locale.__e("flash:1382952379873") } );
				
			icons.push( { status:true,	image:UserInterface.textures.bearIconKick, 	callback:kickAwayAction, params:null, description:Locale.__e("flash:1382952379871") } );

			if (sid == Personage.BEAVER)
				dY = 55;
				
			new IconsMenu(icons, this, function():void
			{
				flag = prevFlag;
			}, dY).show();
		}
		
		/**
		 * Прогоняем медведя
		 */
		public function kickAwayAction(params:Object = null):void
		{
			if (hut) hut.fireWorker(this);
			clickable = false;
			touchable = false;
			removable = true;
			TweenLite.to(this, 0.4, { alpha:0, onComplete:remove } );
			
			// Убирем flash:1382952379993 списка
			var index:uint = bears.indexOf(this);
			bears.splice(index, 1);
			App.ui.upPanel.update();
			
			//App.ui.glowing(App.ui.upPanel.bearBar, 0xFFFF00);
		}
		
		/**
		 * Показываем рабочее место в Hut
		 * @param	params
		 */
		private function showInHutAction(params:Object = null):void
		{
			if (hut) hut.ShowBearWorkPlace(this);
		}
				
		/**
		 * Выбираем цели
		 * @param	params
		 */
		private function showTargets(type:uint):void
		{
			selectedBear = this;
			
			if (!Hut.checkHuts(type))
			{
				new ShopWindow( { find:[type] } ).show();
				return;
			}
			
			for each(var _res:Resource in possibleTargets)
			{
				_res.state = _res.DEFAULT;
			}
			
			switch(type)
			{
				case WOOD_HUT:
					Cursor.type = "woodCollect";
				break
				case STONE_HUT:
					Cursor.type = "stoneCollect";
				break
				case FOREST_HUT:
				case WATER_HUT:
					Cursor.type = "take";
				break
			}
			
			possibleHuts = Hut.findHuts(type);
			if (possibleHuts.length == 0)
			{
				new SimpleWindow({ 
					text:Locale.__e("flash:1382952379874"),
					label:SimpleWindow.ERROR,
					buttonText:Locale.__e("flash:1382952379875"),
					ok:function():void
					{
						new ShopWindow( { section:4 } ).show();
					}
				}).show();
				return;
			}
			
			possibleSIDs = [];
			var hutTargets:Object = App.data.storage[type].targets;  
			for each(var sID:* in hutTargets)	possibleSIDs.push(sID);
			
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:Resource in possibleTargets)
			{
				if (res.busy == 1) continue;
				res.state = res.HIGHLIGHTED;
			}
			
			if(sid == Personage.BEAR)
				App.ui.upPanel.showHelp(Locale.__e("flash:1382952379876"));
			else if(sid == Personage.BEAVER)
				App.ui.upPanel.showHelp(Locale.__e("flash:1382952379877"));
			
			App.self.addEventListener(MouseEvent.CLICK, unselectPossibleTargets);
		}
		
		private function unselectPossibleTargets(e:MouseEvent):void
		{
			if (App.self.moveCounter > 4) return;
			App.self.removeEventListener(MouseEvent.CLICK, unselectPossibleTargets);
			for each(var _res:Resource in possibleTargets)
			{
				_res.state = _res.DEFAULT;
			}
			Cursor.type = "default";
			
			App.ui.upPanel.hideHelp();
			
			Hut.selectedHut = null;
			Bear.selectedBear = null;
		}
		
		public function collect(resource:Resource):void
		{
			hut = Hut.findNearestHut(resource, possibleHuts);
			hut.beginWork(resource, this);
			loadStack(hut.sid);
		}
		
		/**
		 * Подходит к варенью
		 */
		public function onBornEvent():void
		{
			action 		= Bear.ACTION_BORN;
			framesType 	= Bear.ANIM_WORK;
			initAction(onEatComplete);
		}
		
		private function onEatComplete():void
		{
			doWait();
			addJam(tm.currentTarget.target.info.capacity);
			
			App.ui.flashGlowing(this, 0xFFFF00);
			
			// Удаляем варенье
			tm.currentTarget.target.uninstall();
			
			Post.send( {
				ctr:this.type,
				act:'eat',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z,
				jID:tm.currentTarget.target.id,
				jsID:tm.currentTarget.target.sid
			}, onEatAction);
		}
		
		private function onEatAction(error:int, data:Object, params:Object = null):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			createWorkIcons();
		}
		
		/**
		 * Кормим вареньем
		 */
		public function feedAction(params:Object = null):void
		{
			var settings:Object = { view:'jam', onFeedAction:onFeedAction};
				if (sid == Personage.BEAVER)
					settings['view'] = 'fish';
			new JamWindow(settings).show();
		}
		 
		private function onFeedAction(jsID:uint):void
		{
			var workerID:int = -1;
			if (hut != null) workerID = hut.takeWorkerID(this);
			doWait();
			App.user.stock.take(jsID, 1);
			addJam(App.data.storage[jsID].capacity);
			App.ui.flashGlowing(this, 0xFFFF00);
			
			var postObject:Object = {
				ctr:this.type,
				act:'feed',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				worker:workerID,
				jsID:jsID
			}
			
			if (workerID == -1)
				delete postObject.worker;
			
			Post.send( postObject, 
				function(error:int, data:Object, params:Object = null):void
				{
					if (error)
					{
						Errors.show(error, data);
						return;
					}
					
					this.jam = data.jam;
					if (flag == "noJam") flag = false;
					returnToWork();
			});
		}
		
		public function returnToWork():void
		{
			if (jam <= 0) return;
			if (resource == null) return;
			if (hut == null) return;
			
			var workerID:int = hut.takeWorkerID(this);
			var stacks:int = hut.bears[workerID].stacks;
			
			Hut.checkBearToDo(stacks, this, resource, hut, App.time);
			//beginWork(App.time, resource, hut);
		}
		
		/**
		 * Выполняется когда персонаж доходит до цели
		 */
		override public function onPathToTargetComplete():void
		{
			
			tm.status = TargetManager.FREE;
			
			position = tm.currentTarget.jobPosition;
			tm.currentTarget.callback();
			//tm.currentTarget.framesDirection 	= tm.currentTarget.jobPosition.direction;
			//tm.currentTarget.framesFlip 		= tm.currentTarget.jobPosition.flip;
			
			//tm.onTargetComplete();
			//startJob();
		}
		
		/**
		 * Начинаем сбор ресурса
		 * @param	target - цель сбора
		 * @param	hut - хижина сбора
		 */
		public function beginWork(started:uint, target:Resource, hut:Hut):void
		{
			//trace("beginWork " + started, target, hut);
			this.started 	= started;
			status 			= Bear.HIRED;
			this.resource 	= target;
			resource.busy = 1;
			this.hut 		= hut;
			flag = false;	
			alert = Locale.__e("flash:1382952379878");
			
			setTimeout(function():void {
				toResource();
				App.self.setOnTimer(working);
			}, 200);
		}
		
		public function loadStack(sID:uint):void
		{
			var stack:String = "wood"
			switch(sID)
			{
				case Hut.WOOD:
						stack = "wood";
					break;
				case Hut.STONE:
						stack = "stone";
					break;
				case Hut.BAG:
						stack = "bag";
					break;	
				case Hut.WATER:
						stack = "water";
					break;		
			}
			Load.loading(Config.getSwf("Bear", stack), onStackLoad)
		}
		
		private function working():void
		{
			//trace(App.time + " " + (resource.info.jobtime + started));
			if(App.time > (resource.info.jobtime + started))
			{
				App.self.setOffTimer(working);
				completeWork();
			}
		}
		
		/**
		 * Идем к ресурсу
		 */
		private function toResource():void
		{
			if (direction == "toResource") return;
			direction = "toResource";
			
			////Debug.log("toResource: "+resource, 0xFFFF00)
			action 		= Bear.ACTION_WALK;
			framesType 	= Bear.ANIM_WALK;
			
			addTarget({
					target:resource,
					callback:startJob,
					event:Bear.ACTION_WORK,
					jobPosition:resource.getContactPosition(),
					priority:true
				});	
		}
		
		/**
		 * Выполняем действие
		 */
		private function startJob():void
		{
			status 		= Bear.HIRED;
			action 		= Bear.ACTION_WORK;
			framesType 	= Bear.ANIM_WORK;
			
			position = resource.getContactPosition();
			initAction(toHut);
		}
		
		/**
		 * Несем к хижине
		 */
		private function toHut():void
		{
			if (direction == "toHut") return;
			direction = "toHut";
			
			//Debug.log("toHut", 0xFFFF00)
			action 		= Bear.ACTION_WALK;
			framesType 	= Bear.ANIM_CARRY;
			
			addTarget({
					target:hut,
					callback:toResource,
					event:Bear.ACTION_WALK,
					jobPosition:hut.getPosition()
				});
		}
		
		override public function set framesType(value:String):void {
			
			if (value == ANIM_CARRY)
				multipleAnime = stackAnimation;
			else
				multipleAnime = null;
				
			super.framesType = value;	
		}
		
		/**
		 * Собрали материал
		 */
		private function completeWork():void
		{
			direction = "stackComplete";
			stopWalking();
			tm.stop();
			takeJam();
			resource.takeResource();
			
			var stacks:int = hut.addResource(this, resource.sid);
			started = 0;
			
			Hut.checkBearToDo(stacks, this, resource, hut, App.time);
		}
		
		/**
		 * Увольняем рабочего
		 */
		public function fireAction(params:Object = null):void
		{
			if (App.user.mode == User.OWNER){
				if (hut) hut.fireWorker(this);
			}
			fire();
		}
		
		public function fire():void
		{
			hut = null;
			//Debug.log("fire", 0x00FF00);
			stopWalking();
			tm.stop();
			stopTimer();
			App.self.setOffTimer(working);
			started = 0;
			doWait();
			status = FREE;
			dispatchEvent(new WindowEvent("onHutUpdate"));
			if (jam == 0) flag = "noJam";
		}
		 
		/**
		 * Ожидание
		 */
		private function doWait():void
		{
			multipleAnime = null;
			direction = "wait";
			//Debug.log("doWait", 0x00FF00);
			clickable 	= true;
			action 		= Bear.ACTION_WAIT;
			framesType 	= Bear.ANIM_WAIT;
			alert = Locale.__e("flash:1382952379879");
			flag = false;
		}
		
		public function cantWork(reason:String):void
		{
			//Debug.log("cantWork: "+reason, 0x00FFFF);
			switch(reason)
			{
				case "noJam":
						alert = Locale.__e("flash:1382952379857");
						flag = "noJam";
						toPlaceNearHut();
					break;
				case "noTarget":
						fireAction();
					break;
				case "noStacks":
						alert = Locale.__e("flash:1382952379880");
						flag = "noPlace";
						toPlaceNearHut();
					break;	
			}
			//setTimeout(toPlaceNearHut, 500);
		}
		
		private function toPlaceNearHut():void
		{
			if (hut == null) return;
			if (direction == "toPlaceNearHut") return;
			direction = "toPlaceNearHut";
			
			//Debug.log("toPlaceNearHut", 0xFFFF00);
			
			breakeAction();
			
			action 		= Bear.ACTION_WALK;
			framesType 	= Bear.ANIM_WALK;
			
			var onPlaceComplete:Function = function():void{
				clickable 	= true;
				action 		= Bear.ACTION_WAIT;
				framesType 	= Bear.ANIM_WAIT;
				}
			
			var place:Object = hut.findPlaceNear();
			
			addTarget({
					target:hut,
					callback:onPlaceComplete,
					event:Bear.ACTION_WALK,
					jobPosition:{x:place.x, y:place.z}
				});
		}
		
		/**
		 * Status
		 */ 
		public function set status(value:uint):void
		{
			_status = value;
			
			if (_status == Bear.HIRED)
				moveable = false;
			else
				moveable = true;
		}
		
		public function get status():uint
		{
			return _status;
		}
		
		/**
		 * Action
		 */ 
		public function set action(value:uint):void
		{
			_action = value;
		}
		
		public function get action():uint
		{
			return _action;
		}
		
		public function initAction(callback:Function):void
		{
			//Debug.log("initAction");
			onTimerCallback = callback;
			
			switch(_action)
			{
				case Bear.ACTION_LEARN: time = 5000; break;
				case Bear.ACTION_WORK: 	time = 5000; break;
				case Bear.ACTION_BORN: 	time = 1500; break;
				case Bear.ACTION_WAIT: 	time = 10000; break;
			}
			
			timer.reset();
			timer.delay = time;
			timer.start();
		}
		
		private function breakeAction():void
		{
			timer.stop();
			//Debug.log("breakeAction");
		}
		
		private function finishAction(e:TimerEvent):void
		{
			//Debug.log("finishAction");
			onTimerCallback();
		}
		
		private function stopTimer():void
		{
			timer.reset();
		}
		
		/**
		 * Есть ли свободные медведи
		 * @return
		 */
		public static function isFreeBears():*
		{
			for each(var bear:Bear in Bear.bears)
			{
				if (bear._status == Bear.FREE && bear.jam > 0)
				{
					return bear;
				}
			}
			
			return null;
		}
		
		/**
		 * Есть ли свободные обученные медведи
		 * @return
		 */
		public static function isFreeMasterBears(job:uint):*
		{
			for each(var bear:Bear in Bear.bears)
			{
				if (bear._status == Bear.FREE && bear.job == job)
				{
					return bear;
				}
			}
			
			return null;
		}
		
		/**
		 * Возвращает медведя с укаflash:1382952379984нным id
		 * @return
		 */
		public static function findBear(id:uint):*
		{
			for (var i:int = 0 ; i < Bear.bears.length; i++)
			{
				if (Bear.bears[i].id == id) return Bear.bears[i];
			}
			return false;
		}
		
		/**
		 * Возвращает первого попавшегося голодного медведя
		 * @return
		 */
		public static function findHungryBear():Object
		{
			for (var i:int = 0 ; i < Bear.bears.length; i++)
			{
				if (Bear.bears[i].jam == 0 && Bear.bears[i].formed) return {bear:Bear.bears[i], result:true};
			}
			return {result:false};
		}
		
		public static function dispose():void
		{
			for each(var bear:Bear in bears) {
				bear.tm.dispose();
			}
			bears = new Array();
			App.ui.upPanel.update();
		}
		
		public static function possibleTarget(sID:uint):Boolean
		{
			if (selectedBear.possibleSIDs.indexOf(sID) != -1)
				return true;
			else 
				return false;
		}
		
		override public function sort(index:*):void {
			var object:Unit
			if (App.map._aStarNodes[coords.x][coords.z].object != null) {
				object = App.map._aStarNodes[coords.x][coords.z].object;
				if (object is Bridge) {
					index = 0;
					//this.alpha = 0.5;
				}
			}else {
				//this.alpha = 1;
				}
			App.map.mSort.setChildIndex(this, index);
		}
	}
}