package units
{
	import api.ExternalApi;
	import com.greensock.TweenAlign;
	import com.greensock.TweenLite;
	import core.Debug;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import ui.Cloud;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import wins.BuildingConstructWindow;
	import wins.CollectionWindow;
	import wins.CollectorWindow;
	import wins.HelperWindow;
	import wins.HutWindow;
	import wins.ProductionWindow;
	import wins.ProgressBar;
	import wins.RecipeWindow;
	import wins.RepairWindow;
	import wins.SimpleWindow;
	import wins.TributeWindow;
	import wins.WindowEvent;
	
	public class Helper extends Building
	{
		public static const FREE:uint 		= 0;
		public static const BUSY:uint 		= 1;
		public static const DAMAGED:uint 	= 2;
		
		public var old:int = 0;
		public var started:uint = 0;
		public var stacks:Object = {};
		public var cID:uint = 0;
		public var mID:uint = 0;
		public var bear:Bear;
		public var time:uint;
		public var first:uint = 1;
		
		public function Helper(object:Object)
		{
			started = object.started || 0;
			stacks = object.stacks || {};
			super(object);
			
			touchableInGuest = false;
			
			setCloudPosition(0, -50);
			init(object);
			
			if (!stacksIsEmpty())
				flag = Cloud.HAND;
		}
		
		override public function onAfterBuy(e:AppEvent):void
		{
			first = 0;
			super.onAfterBuy(e);
			started = App.time - info.time + 5;
			startWaiting();
			App.self.setOnTimer(wait);
			
			//Делаем push в _6e
			//if (App.social == 'FB') {						
				//ExternalApi._6epush([ "_event", { "event": "gain", "item": info.view } ]);
			//}
		}
		
		public function stacksIsEmpty():Boolean
		{
			for (var i:* in stacks) {
				return false;
			}
			return true;
		}
		
		private var boosterIsWait:Boolean = false;
		private var waitTime:uint = 0
		private var waitedTime:uint = 0
		private function wait():void {
			
			if(boosterIsWait){
				waitedTime ++;
				if (waitedTime > waitTime){
					stopWaiting();
					bearToWork();
				}	
			}
			//Debug.log(started + ' wait  ' + (started + info.time)+ "  <  " + App.time);
			if (started + info.time < App.time) {
				//started = App.time;
				assistEvent();
			}
		}
		
		private function startWaiting():void {
			waitTime = int(Math.random() * 20) + 20;
			boosterIsWait = true;
		}
		
		private function stopWaiting():void {
			boosterIsWait = false;
			waitedTime = 0;
			waitTime = 0;
		}
		
		override public function onRemoveFromStage(e:Event):void {
			App.self.setOffTimer(wait);
			super.onRemoveFromStage(e);
		}
		
		public function init(object:Object):void {
			
			if (formed && App.user.mode == User.OWNER && (App.time > started + info.time)){
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, initStacks);
			}
			
			if(formed && App.user.mode == User.OWNER){
				startWaiting();
				App.self.setOnTimer(wait);
				this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			}
			
			tip = function():Object {
					
				if (flag == Cloud.HAND){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379915", [TimeConverter.timeToStr((started + info.time) - App.time)]),
						timer:true
					};
				};
				
				if(started > 0){
					return {
						title:info.title,
						timer:true,
						text:info.description + "\n"+Locale.__e("flash:1382952379918", [TimeConverter.timeToStr((started + info.time) - App.time)])
					};
				}
				
				return {
					title:info.title,
					text:info.description
				};
			}	
		}
		
		private function initStacks(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, initStacks);
			assistEvent();
		}
		
		public function assistEvent():void {
			
			started = App.time;
			
			Post.send({
				ctr:this.type,
				act:'assist',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				first:first,
				ids:JSON.stringify(findTargetsIDs())
			}, 	function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					stacks = data.stacks;
					if(data.hasOwnProperty('started') && data.started != 0)
						started = data.started;
						
					correctTimes(data.times);
					if (!stacksIsEmpty()) 
						flag = Cloud.HAND;
			});
			
			first = 0;
		}
		
		private function correctTimes(times:Object):void {
			for (var sID:* in times) {
				for (var id:* in times[sID]) {
					var unit:* = Map.findUnit(sID, id);
					unit.onHelperStorage(times[sID][id]);
				}
			}
		}
		
		private function findTargetsIDs():Array {
			var result:Array = [];
			var data:Array = Map.findUnitsByType(['Tribute', 'Golden', 'Animal']);
			
			for (var i:int = 0; i < data.length ; i++)
			{
				var unit:* = data[i];
				if (!(unit is Animal) && unit.level < unit.totalLevels)
					continue;
					
				if (unit is Golden || unit is Tribute) {
					if (App.time < unit.started + unit.info.time)
						continue
				}
				
				if (unit is Animal) {
					if (unit.time + unit.info.time >= unit.started + unit.info.jobtime)
						continue;
						
					if (unit.time + unit.info.time > App.time)	
						continue;
				}
					
				var obj:Object = { };
				obj[data[i].sid] = data[i].id;
				result.push(obj);
			}
			
			return result;
		}
		
		override public function click():Boolean{
			if (!clickable || (App.user.mode == User.GUEST && touchableInGuest == false)) return false;
			
			App.tips.hide();
			
			new HelperWindow( {
					target:this,
					onTakeEvent:storageEvent
				}).show();
			
			return true;
		}
		
		override public function storageEvent(value:int = 0):void
		{
			flag = false;
			ordered 	= true;
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);
		}
		
		public override function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			takeBonus();
			stacks = { };
		}
		
		override public function beginAnimation():void {
			
			startAnimation(true);
				
			if (crafting == false) 
				animationBitmap.visible = true;
			else
				animationBitmap.visible = false;
		}
		
		private var bonusNum:int = 0;
		private var bonuses:Array = [];
		private function takeBonus():void {
			
			bonusNum = 0;
			bonuses = [];
			
			for (var i:* in stacks) {
				for(var sID:* in stacks[i])
				var bonus:Object = stacks[i][sID];
				bonuses.push(bonus);
			}
			
			openBonus();
		}
		
		private function openBonus():void {
			
			Treasures.bonus(bonuses[bonusNum], new Point(this.x, this.y));
			bonusNum ++;
			if (bonusNum < bonuses.length)
				setTimeout(openBonus, 1000);
			else
				ordered = false;
		}
		
		public var targetID:uint = 0;
		public var targets:Array;
		public function bearToWork():void {
			
			//if (bear != null)
			//	return;
				
			bear = new Booster( { id:0, sid:Personage.BOOSTER, x:this.coords.x+info.area.w, z:this.coords.z + info.area.h - 3 } );
			TweenLite.to(bear, 0.5, { alpha:1 } );
			Unit.sorting(bear);
			
			bear.action 		= Bear.ACTION_WALK;
			bear.framesType 	= Bear.ANIM_WALK;
			
			var _targets:Array = selectTargets();
			targets = [];
			
			for (var i:int = 0; i < 2; i++) {
				var randomID:int = int(Math.random() * _targets.length);
				targets.push(_targets[randomID]);
				Debug.log(_targets[randomID]);
			}
			_targets = [];
			
			targets.push(this);
			targetID = 0;
			
			if (targets.length < 2) {
				uninstallBear();
				return;
			}
			toTarget();
			
			this.animationBitmap.visible = false;
		}
		
		public function toTarget():void
		{
			if (bear == null) return;
			bear.action 		= Bear.ACTION_WALK;
			bear.framesType 	= Bear.ANIM_WALK;
			
			var target:* = targets[targetID];
			var jobPosition:Object = {
				x:int(target.info.area.w/2),
				y:-1,
				direction:0,
				flip:0
			}
			
			if (target.coords.z - 1 <= 0)
				jobPosition.y = 0;
			
			if (target == this) {
				jobPosition.x = info.area.w;
				jobPosition.y = info.area.h - 3;
			}
			//Debug.log('toTarget '+ target);
			bear.addTarget({
				target:target,
				callback:startWork,
				event:Bear.ACTION_BORN,
				jobPosition:jobPosition
			});
		}
		
		private function startWork():void {
			
			if (targets[targetID] == this) {
				uninstallBear()
				startWaiting();
				return;
			}
			
			targetID ++;
			if (targetID > targets.length) return;
			toTarget();
		}
		
		private function uninstallBear():void {
			if (bear != null) 
			{
				//var index:int = Bear.bears.indexOf(bear);
				//Bear.bears.splice(index, 1);
				//App.ui.upPanel.update();
				this.animationBitmap.visible = true;
				targets = [];
				
				bear.uninstall();
				bear = null;
			}
		}
		
		public function selectTargets():Array {
			var unit:*;
			var num:int = App.map.mSort.numChildren;
			var childs:Array = [];
			while (num--) {
				unit = App.map.mSort.getChildAt(num);
				
				if (unit is Resource || unit is Decor || unit is Building)
				{
					if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false) {
						continue;
					}
					childs.push(unit);
				}
			}
			
			return childs;
		}
		
		override public function uninstall():void {
			App.self.setOffTimer(wait);
			uninstallBear();
			super.uninstall();
		}
	}
}