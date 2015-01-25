package units 
{
	import astar.AStarNodeVO;
	import buttons.MoneySmallButton;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.AvaLoad;
	import core.Load;
	import core.Log;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import mx.core.ByteArrayAsset;
	import ui.AnimalCloud;
	import ui.Hints;
	import ui.ProgressBar;
	import ui.UserInterface;
	import wins.FurryWindow;
	import wins.FurryWorkWindow;
	import wins.HeroWindow;
	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Techno extends WorkerUnit
	{
		public static const TECHNO:uint = 164;
		
		public var capacity:int = -1;
		public var targetObject:Object = null;
		
		public var collector:Collector;
		
		public static function checkForOpening():Boolean 
		{
			if (App.user.quests.data[92] != null && App.user.quests.data[92].finished > 0)
				return false;
			
			return true;
		}
		
		public function Techno(object:Object)
		{
			if (object.id == 1 && Techno.checkForOpening())
				opening();
				
			super(object);
			
			info['area'] = {w:1, h:1};
			cells = rows = 1;
			velocities = [0.1];
			
			removable = false;
			
			if(object.capacity) capacity = object.capacity;
			if (object.finished) {
				targetObject = { };
				targetObject['sid'] = object.rID;
				targetObject['id'] = object.mID;
				finished = object.finished;
			}
				
			if(!object.hasOwnProperty('spirit')){
				App.user.techno.push(this);
				App.ui.upPanel.update();
			}
			defaultStopCount = 2;
			
			tip = function():Object {
				
				var status:String = Locale.__e("flash:1394010518091");
				
				if (collector) {
					var finishTime:int = finished - App.time;
					if (finishTime < 0) 
						status = Locale.__e('flash:1409154392405');
					else
						status = Locale.__e('flash:1409154426227') + ' ' + TimeConverter.timeToStr(finished - App.time);
				}else if (workStatus == BUSY){
					status = Locale.__e("flash:1394010372134");
				}else if (finished > 0) {
					if(finished > App.time)
						status = Locale.__e('flash:1393581955601') + ' ' + TimeConverter.timeToStr(finished - App.time);
					else
						status = Locale.__e('flash:1409154392405');
				}else if (hasProduct){
					status = Locale.__e('flash:1409154392405');
				}	
				return {
					title:info.title,
					text:status,
					timer:true
				}
			}
			
			if (_opening) {
				//opening();
			}else{
				//App.self.addEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete)
				if (object.fromStock) {
					moveable = true;
				}else{
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
				}
			}
			moveable = true;
			
			homeRadius = 3;
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
		}
		
		private var _opening:Boolean = false;
		private function opening():void {
			workStatus = BUSY;
			_opening = true;
			framesType = 'opening';
		}
		
		public function showOpen():void {
			_opening = false;
			framesType = 'opening';
			addAnimation();
			if(shadow)shadow.visible = true;
		}
		
		override public function addAnimation():void
		{
			if (_opening) {
				framesType = 'opening';
				update();
				return;
			}
				
			if(textures)
				super.addAnimation();	
		}
		
		override public function createShadow():void 
		{
			super.createShadow();
			
			if (_opening)
				shadow.visible = false;
		}
		
		private var contLight:LayerX;
		private function showBorders():void 
		{
			contLight = new LayerX();
			
			var sqSize:int = 30;
			
			var cont:Sprite = new Sprite();
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x89d93c);
			sp.graphics.drawRoundRect(0, 0,400,400,400,400);
			sp.rotation = 45;
			sp.alpha = 0.5;
			
			cont.addChild(sp);
			cont.height = 400 * 0.7;
			
			contLight.addChild(cont);
			
			contLight.y = -contLight.height / 2;
			
			addChildAt(contLight, 0);
		}
		
		override public function free():void {
			showBorders();
			super.free();
		}
		
		private function onUp(e:AppEvent):void 
		{
			if (isMoveThis) {
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false;
			}
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
		}
		
		private var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		private var intervalMove:int;
		override public function onDown():void 
		{
			if (workStatus == BUSY) return;
			
			if (App.user.mode == User.OWNER) {
				if (isMoveThis) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false
				}else{
					var that:Techno = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true;
						that.move = true;
						App.map.moved = that;
					}, 400);
				}
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			if(workStatus != BUSY){
				stopWalking();
				onGoHomeComplete();
			}
			if (App.user.mode == User.GUEST)
				return;
				
			super.touch = touch;
		}
		
		override public function set move(move:Boolean):void {
			
			if (busy == BUSY)
				return;
			
			super.move = move;
			
			if (!move && isMoveThis)
				previousPlace();
		}
		
		override public function previousPlace():void {
			super.previousPlace();
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void 
		{
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
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
			this.cell = coords.x;
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			goHome();
				
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false
		}
		
		override public function click():Boolean
		{
			if (collecterBonus) {
				collecterBonus = false;
				collector.storageCollector(id);
				homeCoords = null;
				return true;
			}
			
			if (hasProduct) {
				storageEvent();
				return true;
			}
			
			var that:Techno = this;
			App.map.focusedOn(this, false, function():void 
			{
				new FurryWindow({
					//title:info.title,
					info:info,
					target:that
				}).show();					
			}, true, 1, true, 0.5);
			
			clearTimeout(intervalMove);
			
			if(isMoveThis){
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
				return true;
			}
			return true;
		}
		
		private function onGameComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			
			if (finished > 0) {
				busy = BUSY;
				findResourceTarget();
				return;
			}
			
			if (busy == FREE)
				goHome();
		}
		
		override public function born(settings:Object = null):void 
		{
			this.alpha = 1;
			
			if (settings && settings['capacity'])
				capacity = settings.capacity;
			
			this.cell = coords.x;
			this.row = coords.z;
			
			if (_opening) {
				this.alpha = 1;
				//showOpen();
				return;
			}
				
			var that:Techno = this;
			TweenLite.to(this, 1.8, { alpha:1, onComplete:function():void {
				var index:int = App.user.techno.indexOf(that)
				if (index != -1)
					goHome();
			}});
		}
		
		override public function uninstall():void {
			var index:int = App.user.techno.indexOf(this)
			if (index != -1)
			App.user.techno.splice(index, 1);
			cell = 0;
			row = 0;
			//App.self.removeEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onGameComplete);
			
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			
			super.uninstall();
			App.ui.upPanel.update();
		}
		
		public static function getBusyTechno():uint {
			var count:int = 0;
			for each( var bot:Techno in App.user.techno) {
				if (!bot.isFree())
					count ++;
			}
			
			return count;
		}
		
		public static function freeTechno():Array {
			var result:Array = [];
			for each(var bot:Techno in App.user.techno) {
				if (bot.isFree())
					result.push(bot);
			}
			
			return result;
		}
		
		//public static function queueTechno():Array {
			//var result:Array = [];
			//for each(var bot:Techno in App.user.techno) {
				//if (bot.isQueuee())
					//result.push(bot);
			//}
			//
			//return result;
		//}
		
		public var collecterBonus:Boolean = false;
		public function setMoneyDone():void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (cloudAnimal) {
				cloudAnimal.dispose();
				cloudAnimal = null;
			}
			
			collecterBonus = true;
				
			cloudAnimal = new AnimalCloud(collector.storageCollector, this, Stock.COINS, AnimalCloud.MODE_DONE, {scaleIcon:0.5});
			cloudAnimal.create('productBacking2');
			cloudAnimal.show();
			cloudAnimal.x = - 30;
			cloudAnimal.y = - 120;
			cloudAnimal.pluck(30);
		}
		
		public function removeCloud():void
		{
			if (cloudAnimal) {
				cloudAnimal.dispose();
				cloudAnimal = null;
			}
		}
		
		public var target:*;
		private var jobPosition:Object;
		public function goToJob(target:*, order:int=0):void {
			stopRest();
			this.target = target;
			workStatus = BUSY;
			jobPosition = target.getTechnoPosition(order);
			
			_move = false;
			
			initMove(
				jobPosition.x, 
				jobPosition.z,
				startWork
			);
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			if (!needSplice) {
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
					
				if (workStatus == BUSY && path.length > shortcutDistance) {
					path = path.splice(path.length - shortcutDistance, shortcutDistance);
					placing(path[0].position.x, 0, path[0].position.y);
					alpha = 0;
					TweenLite.to(this, 1, { alpha:1 } );
					return path;
				}else {
					return path;
				}
				
			}else {
				placing(finish.position.x, 0, finish.position.y);
				cell = finish.position.x;
				row = finish.position.y;
				alpha = 0;
				TweenLite.to(this, 1, { alpha:1 } );
				return null;
			}
			
			return path;
		}
		
		public function fire(minusCapasity:int = 0):void {
			stopSound();
			workStatus = FREE;
			disposeSparks();
			
			//target = null;
			
			//worldId = 0;
			
			if (capacity > 0) capacity-=minusCapasity;
			
			if (capacity == 0) {
				removable = true;
				remove();
			}else {
				goHome();
			}
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_TECHNO_CHANGE));
		}
		
		private function startWork():void {
			
			if (hasProduct) {
				framesType = 'stop_pause';
				return;
			}
			
			if(target && target.hasOwnProperty('targetWorker'))
				target.targetWorker = this;
			
			framesType = jobPosition.workType;
			position = jobPosition;
			
			//if (capacity > 0) capacity--;
			
			if (jobPosition.workType == Personage.BUILD)
				startSparks();	
				
			startSound(jobPosition.workType);	
		}
		
		override public function generateStopCount():uint {
			return int(Math.random() * 2) + 1;;
		}
		
		override public function generateRestCount():uint {
			return int(Math.random() * 2) + 1;
		}
		
		
		
		public function inViewport():Boolean 
		{
			var globalX:int = this.x * App.map.scaleX + App.map.x;
			var globalY:int = this.y * App.map.scaleY + App.map.y;
			
			if (globalX < -10 || globalX > App.self.stage.stageWidth + 10) 	return false;
			if (globalY < -10 || globalY > App.self.stage.stageHeight + 10) return false;
			
			return true;
		}
		
		
		
		
		public static function nearlestTechno(target:*, bots:Array):Techno {
			var resultTechno:Techno;
			var dist:int = 0;
			for each(var bot:Techno in bots){
				var _dist:int = Math.abs(bot.coords.x - target.coords.x) + Math.abs(bot.coords.z - target.coords.z);
				if (dist == 0 || dist > _dist) {
					dist = _dist;
					resultTechno = bot;
				}
			}
			
			return resultTechno;
		}
		
		public static function nearestTechnos(target:*, bots:Array, count:uint):Array {
			var resultTechnos:Array = [];
			var dist:int = 0;
			for each(var bot:Techno in bots){
				var _dist:int = Math.abs(bot.coords.x - target.coords.x) + Math.abs(bot.coords.z - target.coords.z);
				{
					resultTechnos.push( { bot:bot, dist:dist } );	
				}
			}
			
			resultTechnos.sortOn('dist', Array.NUMERIC);
			resultTechnos = resultTechnos.splice(0, count);
			return resultTechnos;
		}
		
		public static function takeTechno(needTechno:int, target:*):Array 
		{
			var bots:Array = Techno.freeTechno();
			if (bots.length == 0 && App.user.mode != User.GUEST) 
			{
				new PurchaseWindow( {
					width:716,
					itemsOnPage:4,
					useText:true,
					shortWindow:true,
					popup:true,
					description:Locale.__e('flash:1393599816743'),
					descWidthMarging:-120,
					content:PurchaseWindow.createContent("Energy", {inguest:0, view:'furry'}),
					title:App.data.storage[Techno.TECHNO].title,
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();
			}
				
			var _technos:Array = Techno.nearestTechnos(target, bots, needTechno);
			return _technos;
		}
		
		public static function getTechnoById(id:int):Techno
		{
			var techno:Techno;
			for (var i:int = 0; i < App.user.techno.length; i++) 
			{
				techno = App.user.techno[i];
				if (id == techno.id) {
					break;
				}
			}
			return techno;
		}
		
		
		private var sparksContainer:Sprite;
		private var sparksInterval:int = 0;
		public function startSparks():void 
		{
			if (sparksContainer != null)
				disposeSparks();
			
			sparksContainer = new Sprite();
			addChildAt(sparksContainer, 0);
			generateSpark();
			sparksInterval = setInterval(generateSpark, 1000);
			
			if(framesFlip == 0){
				sparksContainer.x = -50;
				sparksContainer.y = -60;
			}else {
				sparksContainer.scaleX = -1;
				sparksContainer.x = 50;
				sparksContainer.y = -60;
			}
		}
		
		private function generateSpark():void 
		{
			var spark:AnimationItem = new AnimationItem( { type:'Effects', view:'spark', onLoop:function():void {
					spark.dispose();
					if(spark && spark.parent)spark.parent.removeChild(spark);
				}});
				
			var random:int = Math.random();
			if (Math.random() > 0.5)
				spark.scaleX = -1;
			
			sparksContainer.addChild(spark);
			spark.x = int(Math.random() * 50) - 25;
			spark.y = int(Math.random() * 50) - 25;
		}
		
		public static function randomSound(sid:uint, type:String):String {
			if (sounds[sid][type] is Array)
				return sounds[sid][type][int(Math.random() * sounds[sid][type].length)];
			else
				return sounds[sid][type];
		}
		
		
		
		private function disposeSparks():void {
			if (sparksInterval > 0)
				clearInterval(sparksInterval);
				
			if (sparksContainer) {
				removeChild(sparksContainer);
				sparksContainer = null;
			}
		}
		
		override public function startSound(type:String):void {
			
			//if (!SoundsManager.instance.allowSFX) return;
			
			switch(type) {
				case Personage.BUILD:
						SoundsManager.instance.addDinamicEffect(sounds['build'], target);
					break;
				case Personage.WORK:
						SoundsManager.instance.addDinamicEffect(sounds['work'], target);
					break;
				/*case 'rest':
						SoundsManager.instance.playSFX(sounds['idle1'], this);
					break
				case 'rest2':
						SoundsManager.instance.playSFX(sounds['idle2'], this);
					break	*/
			}
		}
		
		public function stopSound():void {
			SoundsManager.instance.removeDinamicEffect(target);
		}
		
		public static var sounds:Object = {
			build:'robot_4',
			idle1:'robot_2',
			idle2:'robot_3',
			work:'robot_1'
		}
		
		public var countRes:int = 0;
		//- auto - выбор ресурса, параметры: uID, wID, sID, id (фурии), rID - sid ресурса, mID - id ресурса на карте, count - кол-во ресурса, ответ finished - время окончания работы фуриии
		//- storage - сбор собранных ресурсов, параметры: uID, wID, sID, id фурии, ответ bonus - собранные ресы с кладами
		public function autoEvent(target:Resource, count:int = 1):void {
			countRes = count;
			Post.send( {
				ctr:this.type,
				act:'auto',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id,
				rID:target.sid,
				mID:target.id,
				count:count
			}, function(error:int, data:Object, params:Object):void{
				if (error) {
					Errors.show(error, data);
					return;
				}
				finished = data.finished;
				busy = BUSY;
				target.busy = 1;
				App.self.setOnTimer(work);
				goToJob(target);
			});
		}
		
		public var finished:uint = 0;
		public function findResourceTarget():void {
			var isWork:Boolean = true;
			if (target == null) {
				var resource:Resource = Map.findUnit(targetObject.sid, targetObject.id);
				if (resource != null){
					target = resource;
					target.busy = 1;
					goToJob(target);
					if (resource.hasOwnProperty('targetWorker'))
						resource.targetWorker = this;
				}else {
					busy  = FREE;
					finished = 0;
					isWork = false;
					_hasProduct = false;
				}
			}else {
				target.busy = 1;
				goToJob(target);
			}
			
			if(isWork){
				App.self.setOnTimer(work);
				work();
			}
		}
		
		public function startCollectorWork(targetSid:int, targetId:int, started:int, finished:int):void
		{
			target = Map.findUnit(targetSid, targetId);
			
			if (!target)
				return;
			
			this.finished = finished;
			
			target.furry = this;
			target.colector = collector;
			target.resetStart(started);
			target.removable = false;
			target.moveable = false;
			target.stockable = false;
			
			if(target.crafted <= App.time && started < target.crafted)
				collector.doSync(id);
			
			goToJob(target);
			App.self.setOnTimer(work);
			work();
		}
		
		private function work():void {
			if (App.time > finished) {
				App.self.setOffTimer(work);
				//framesType = 'stop_pause';
				hasProduct = true;
				workStatus = 3;
				
				if (collector) {
					homeCoords = { };
					homeCoords['info'] = { };
					homeCoords['info']['area'] = { };
					homeCoords['info']['area'] = collector.info.area;
					
					homeCoords['coords'] = { };
					homeCoords['coords']['x'] = collector.coords.x;
					homeCoords['coords']['z'] = collector.coords.z;
					collecterBonus = true;
				}
				if(target.hasOwnProperty('furry'))
					target.furry = null;
				goHome();
				//if (collector) {
					//collector.furryFinished(id);
				//}
			}
		}
		
		private var homeCoords:Object;
		public function collectorFinished():void
		{
			target.removable = true;
			target.moveable = true;
			workStatus = FREE;
			hasProduct = false;
			target.busy = 0;
			target.colector = null;
			homeCoords = null;
			
			collector = null;
			target = null;
			//App.ui.upPanel.update();
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			clearTimeout(timer);
			
			if (isRemove)
				return;
			
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY)
				return;
			
			var place:Object;
			if (_movePoint != null) {
				place = _movePoint;
			}else if (homeCoords != null) { 
				place = findPlaceNearTarget({info:homeCoords.info, coords:homeCoords.coords}, homeRadius);
			}else {
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
			}
			
			framesType = Personage.WALK;
			initMove(
				place.x,
				place.z,
				onGoHomeComplete
			);
		}
		
		
		private var _hasProduct:Boolean = false;
		
		public function set hasProduct(value:Boolean):void
		{
			_hasProduct = value;
			
			if (_hasProduct) {
				showIcon('outs', storageEvent, AnimalCloud.MODE_DONE, 'productBacking2', 0.7);
				//goHome();
			}else {
				if (cloudAnimal) {
					cloudAnimal.dispose();
					cloudAnimal = null;
				}
			}
		}
		
		public function get hasProduct():Boolean
		{
			return _hasProduct;
		}
		
		public function storageEvent(count:int = 1):void {
			
			if (collector) {
				collector.storageCollector(id);
				return;
			}
				
			
			var rew:Object = { };
			rew[target.sid] = countRes;
			
			if (!App.user.stock.canTake(rew))
				return;
				
			if(target && target.hasOwnProperty('targetWorker'))
				target.targetWorker = null;
			
			var that:* = this;
			hasProduct = false;
			fire();
			Post.send( {
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:id
			}, function(error:int, data:Object, params:Object):void{
				if (error) {
					Errors.show(error, data);
					return;
				}
				if (data.hasOwnProperty("bonus")){
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
					fire(capacity);
				}
				if(target){
					target.busy = 0;
					target.setCapacity(data.cap);
					target = null;
				}
				finished = 0;
				busy = 0;
			});
		}
		
		public var cloudAnimal:AnimalCloud;
		private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'productBacking2', scaleIcon:Number = 0.6):void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (cloudAnimal) {
				cloudAnimal.dispose();
				cloudAnimal = null;
			}
			var sidOut:int = target.sid;
			
			if (collector)
				sidOut = Stock.COINS;
				
			cloudAnimal = new AnimalCloud(callBack, this, sidOut, mode, {scaleIcon:scaleIcon});
			cloudAnimal.create(btmDataName);
			cloudAnimal.show();
			cloudAnimal.x = - 30;
			cloudAnimal.y = - 120;
			cloudAnimal.pluck(30);
		}
		
		override public function onLoop():void 
		{
			if (_framesType == 'opening') {
				workStatus = FREE;
				goHome({
					x:coords.x + 5, 
					z:coords.z + 2
				});
				QuestsRules.furryComplete();
				return;
			}
			super.onLoop();
		}
	}
}