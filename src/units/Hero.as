package units 
{
	import astar.AStar;
	import astar.AStarNodeVO;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.AvaLoad;
	import core.Load;
	import core.Log;
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
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import ui.Cursor;
	import ui.Hints;
	import ui.ProgressBar;
	import ui.UserInterface;
	import wins.HeroWindow;
	import wins.InstanceWindow;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Hero extends WorkerUnit
	{
		private var progressBar:ProgressBar;
		
		public static const PRINCE:String = 'man';
		public static const PRINCESS:String = 'woman';
		
		public var owner:*;
		public var fly:Boolean = false;
		public var wingsAnimation:Object = { };
		
		public var cloth:Object = {
			'head':0,
			'body':0,
			'sex':'m'
		};
		
		public var transport:Transport = null;
		public var alien:String = PRINCE;
		public var aka:String = '';
		
		//75, 76, 74,	84, 85, 86
		
		public static var allTargets:Object = {
			162: [
				65, 67, 69, 77, 78,
				88, 89, 92, 93, 94, 97, 98, 99, 278
			],
			163: [
				106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 118, 119, 120, 121, 122, 123, 124, 125, 126,
				116, 117
			]
		}
		
		public static function isMain(hero:Hero):Boolean 
		{
			if((hero.sid == 162 && App.user.sex == 'm') ||
			(hero.sid == 163 && App.user.sex == 'f'))
				return true;
				
			return false;	
		}
		
		public static function getNeededHero(sid:int):Hero {
			
			var persSID:int = 0;
			for (var pers_sid:* in allTargets) {
				if (allTargets[pers_sid].indexOf(sid) != -1) {
					persSID = pers_sid;
				}
			}
			
			if (persSID == 0) {
				// Нужны фурии
				return null;
			}
				
			for each(var pers:Hero in App.user.personages) {
				if(pers.sid == persSID)
					return pers;
			}
			
			return null;// App.user.personages[0];
		}
		
		public var targets:Array = [];
		
		public function Hero(owner:*, object:Object)
		{
			this.owner = owner;
			this.alien = object.alien;
			
			if (owner.head == null || owner.head == 0)
			{
				if (owner.sex == 'm')
					owner.head = User.BOY_HEAD;
				else
					owner.head = User.GIRL_HEAD;
			}
			
			if (owner.body == null || owner.body == 0)
			{
				if (owner.sex == 'm')
					owner.body = User.BOY_BODY;
				else
					owner.body = User.GIRL_BODY;
			}
			
			cloth.sex = owner.sex;
			cloth.head = owner.head;
			cloth.body = owner.body;
			
			if(App.map.id == User.HOME_WORLD){
				if(object.sid == 162){
					object.x = 41;
					object.z = 78;
				}
				if(object.sid == 163){
					object.x = 49;
					object.z = 87;
				}
			}
			
			super(object, alien);
			velocities = [0.1, 0.07];
						
			moveable = false;
			removable = false;
			transable = false;
			flyeble = true;
			rotateable = false;
			
			if (owner is Owner) {
				touchable = false;
				clickable = false;
				if(owner.id != 1){
					createAva(owner);
				}
			}
			
			//hasMultipleAnimation = true;
			
			tm = new TargetManager(this);
			framesType = STOP;
			
			aka = object.aka;
			
			tip = function():Object {
				return {
					title:aka
				}
			}
			
			if (info.view == PRINCESS) {
				this.scaleX = this.scaleY = 0.8;
			}
			
			targets = allTargets[sid];
			
			main = isMain(this);
		}
		
		public var main:Boolean = false;
		private var liveTimer:uint = 0;
		override public function beginLive():void {
			if (main) return;
			return;
			
			var time:uint = 3000 + int(Math.random() * 3000);
			liveTimer = setTimeout(goHome, time);
		}
		
		override public function onGoHomeComplete():void {
			stopRest();
			var time:uint = Math.random() * 5000 + 5000;
			liveTimer = setTimeout(goHome, time);
		}
		
		override public function goHome(_movePoint:Object = null):void 
		{
			clearTimeout(liveTimer);
			liveTimer = 0;
			
			if (isRemove)
				return;
			
			if (move) {
				var time:uint = Math.random() * 5000 + 5000;
				liveTimer = setTimeout(goHome, time);
				return;
			}
			
			if (workStatus == BUSY) 
				return;
				
			var place:Object;	
				place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:movePoint.x, z:movePoint.y}}, homeRadius);
			
			framesType = Personage.WALK;
			initMove(
				place.x, 
				place.z,
				onGoHomeComplete
			);
		}
		
		override public function stopLive():void {
			if (main) return;
			
			if (liveTimer > 0){
				clearTimeout(liveTimer);
				liveTimer = 0;
			}	
		}
		
		private function getClothView(sID:uint):String
		{
			return App.data.storage[sID].view;
		}
		
		override public function load():void
		{
			if (preloader) addChild(preloader);
			Load.loading(Config.getSwf('Personage', info.view), onLoad);
		}
		
		public function change(clothSettings:Object , callback:Function = null):void
		{
			cloth.body = clothSettings.body;
			cloth.head = clothSettings.head;
			cloth.sex = clothSettings.sex;
			
			Load.loading(Config.getSwf('Clothing', getClothView(cloth.body)), 
				function(data:*):void {
					textures = data;
					if (callback != null) callback();
				}
			);
			Load.loading(Config.getSwf('Clothing', getClothView(cloth.head)), 
			function(data:*):void {
					multipleAnime = data.animation.animations;
					if (callback != null) callback();
				}
			);	
		}
		
		private function onHeadLoad(data:*):void {
			hasMultipleAnimation = true;
			multipleAnime = data.animation.animations;
			
			if (textures != null)
				removePreloader();
		}
		
		public var ava:Sprite;
		
		private var avatarSprite:Sprite = new Sprite();
		private var avatar:Bitmap;
		private var friendID:*;
		
		public function createAva(friend:Object):void {
			//Аватар
						
			if (friend.hasOwnProperty('uid'))
				friendID = friend.uid;
			else
				friendID = friend.id;
				
				
			ava = new Sprite();
			ava.name = 'ava';
			var bg:Bitmap = Window.backing(74, 74, 10, "textSmallBacking");
			ava.addChild(bg);
			
			avatar = new Bitmap(null, "auto", true);
			avatarSprite.addChild(avatar);
			avatarSprite.x = 12;
			avatarSprite.y = 12;
			ava.addChild(avatarSprite);
			
			if (App.user.friends.data[friendID].first_name != null) {
				drawAvatar();
			}else {
				App.self.setOnTimer(checkOnLoad);
			}
			
			var arrow:Sprite = Window.shadowBacking(10, 10, 6);
			ava.addChild(arrow);
			arrow.x = ava.width / 2 - 5;
			arrow.y = bg.x + bg.height - 2;
			
			App.map.mTreasure.addChild(ava);
			ava.x = x - 38;
			ava.y = y - 168;
			
			ava.mouseChildren = false;
		}
		
		private function checkOnLoad():void {
			if (App.user.friends.data[friendID].first_name != null) 
			{
				App.self.setOffTimer(checkOnLoad);
				drawAvatar();
			}
		}
		
		override public function uninstall():void {
			super.uninstall();
			App.self.setOffTimer(checkOnLoad);
		}
		
		private function drawAvatar():void 
		{
			var friend:Object = App.user.friends.data[friendID];
			var name:TextField = Window.drawText(friend.aka || friend.first_name, {
				fontSize:18,
				color:0x502f06,
				borderColor:0xf8f2e0,
				autoSize:"left"
			});
			
			ava.addChild(name);
			name.x = (ava.width - name.width) / 2;
			name.y = -6;
			
			new AvaLoad(friend.photo, function(data:*):void {
				avatar.bitmapData = data.bitmapData;
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0x000000, 1);
				shape.graphics.drawRoundRect(0, 0, 50, 50, 15, 15);
				shape.graphics.endFill();
				avatarSprite.mask = shape;
				avatarSprite.addChild(shape);
			});
		}
		
		override public function initMove(cell:int, row:int, _onPathComplete:Function = null):void {
			if (this.cell != cell || this.row != row) framesType = Personage.WALK;
			super.initMove(cell, row, _onPathComplete);
		}
		
		override public function findPath(start:*, finish:*, _astar:*):Vector.<AStarNodeVO> {
			
			var needSplice:Boolean = checkOnSplice(start, finish);
			
			if (App.user.quests.tutorial && tm.currentTarget != null)
				tm.currentTarget.shortcutCheck = true;
				
			if (!needSplice) {
				var path:Vector.<AStarNodeVO> = _astar.search(start, finish);
				if (path == null) 
					return null;
					
				if (tm.currentTarget != null && tm.currentTarget.shortcutCheck) {
					if (path.length > shortcutDistance) {
						path = path.splice(path.length - shortcutDistance, shortcutDistance);
						placing(path[0].position.x, 0, path[0].position.y);
						alpha = 0;
						TweenLite.to(this, 1, { alpha:1 } );
						return path;
					}
				}
					
				if (!inViewport() || (tm.currentTarget != null && tm.currentTarget.shortcut)) {
					path = path.splice(path.length - 5, 5);
					placing(path[0].position.x, 0, path[0].position.y);
					alpha = 0;
					TweenLite.to(this, 1, { alpha:1 } );
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
		
		
		

		/**
		 * Отправляем цель в TargetManager
		 * @param	targetObject имеет target, jobPosition, callback
		 */
		override public function addTarget(targetObject:Object):Boolean
		{
			if (transport != null && !(targetObject.target is Dock)) {
				new SimpleWindow( {
					title:Locale.__e('flash:1383572998112'),
					label:SimpleWindow.ATTENTION,
					text:Locale.__e('flash:1383573037900')
				}).show();
				Transport.showGlowDocks();
				return false;
			}
			
			makeVoice();
			
			tm.add(targetObject);
			stopLive();
				
				
			return true;
		}
		
		/**
		 * Выполняется когда персонаж останавливается без цели
		 */ 
		override public function onStop():void
		{
			framesType = Personage.STOP;
		}
		
		/**
		 * Выполняется когда персонаж доходит до цели
		 */ 
		override public function onPathToTargetComplete():void
		{
			startJob();
		}
		
		override public function set touch(touch:Boolean):void {
			if (Cursor.type == 'stock' && stockable == false) return;
			
			if (!touchable || (App.user.mode == User.GUEST && touchableInGuest == false)) return;
			
			
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
		
		/**
		 * Выполняем действие
		 */
		
		private function startJob():void
		{
			var jobTime:int = tm.currentTarget.target.info.jobtime;
			if (jobTime <= 0) jobTime = 2;
			if (progressBar == null) {
				progressBar = new ProgressBar(jobTime, 110);
			}
			
			if (tm.currentTarget == null) {
				return;
			}
			
			if (tm.currentTarget.target.hasOwnProperty('isTarget'))
				tm.currentTarget.target.isTarget = true;
			
			if (tm.currentTarget.onStart)	
				tm.currentTarget.onStart();
			
			framesType = tm.currentTarget.event;
			var ft:String = tm.currentTarget.event;
			
			position = tm.currentTarget.jobPosition;
			
			switch(ft) 
			{
				case "harvest": 
						progressBar.label = Locale.__e('flash:1382952379925'); 
						//SoundsManager.instance.playSFX(sounds[sid]['gathering'], this);
					break;
					
				default : 		
						progressBar.label = Locale.__e('flash:1382952379926'); 
					break;
			}
			
			progressBar.x = x - progressBar.maxWidth / 2; 
			progressBar.y = y - height - 10;
			
			App.map.mTreasure.addChild(progressBar);
			
			progressBar.addEventListener(AppEvent.ON_FINISH, finishJob);
			progressBar.start();
		}
		
		override public function onLoop():void
		{	
			super.onLoop();
			/*if(_framesType == HARVEST)
				SoundsManager.instance.playSFX(sounds[sid]['gathering'], this);*/  // не забыть включить
		}
		
		override public function walk(e:Event = null):* 
		{
			switch(alien) {
				case PRINCE:
					velocity = velocities[0];
					break;
				case PRINCESS:
					velocity = velocities[1];
					break;	
			}
			/*if (flyeble && path.length > 10 && pathCounter > 2 && pathCounter < path.length - 5){
				startFly();
				velocity = velocities[1];
			}else{	
				finishFly();
				velocity = velocities[0];
			}*/	
			super.walk();
		}	
		
		private function startFly():void
		{
			if (fly) return;
			fly = true;
			velocity = velocities[1];
			framesType = "_fly";
			TweenLite.to(shadow, 0.3, { alpha:0.4 } );
			addEventListener(Event.COMPLETE, onStartFly)
			SoundsManager.instance.playSFX("flyStart", this);
		}
		
		private function onStartFly(e:Event):void
		{
			removeEventListener(Event.COMPLETE, onStartFly)
			framesType = "fly";
		}
		
		private function onFinishFly(e:Event):void
		{
			removeEventListener(Event.COMPLETE, onFinishFly)
			framesType = "walk";
		}
		
		private function finishFly():void
		{
			if (!fly) return;
			fly = false;
			velocity = velocities[0];
			framesType = "fly_";
			TweenLite.to(shadow, 0.3, { alpha:1, ease:Strong.easeIn } );
			addEventListener(Event.COMPLETE, onFinishFly);
			SoundsManager.instance.playSFX("flyEnd", this);
		}
		
		/**
		 * Заканчиваем действие и flash:1382952379993меняем цель
		 * @param	e
		 */
		public function finishJob(e:AppEvent = null):void
		{
			if(progressBar!= null){
				progressBar.removeEventListener(AppEvent.ON_FINISH, finishJob);
				
				if(App.map.mTreasure.contains(progressBar)){
					App.map.mTreasure.removeChild(progressBar);
				}
				progressBar = null;
			}
			
			if (hasEventListener(Event.COMPLETE))	
				removeEventListener(Event.COMPLETE, onFinishFly);
			
			if (hasEventListener(Event.COMPLETE))
				removeEventListener(Event.COMPLETE, onStartFly)
				
			if(tm.length == 0) framesType = Personage.STOP;
			if (tm.currentTarget != null) {
				
				if (tm.currentTarget.target.hasOwnProperty('isTarget'))
					tm.currentTarget.target.isTarget = false;
				
				if (App.user.quests.tutorial) {
					if (App.user.quests.currentTarget != null && tm.currentTarget.target == App.user.quests.currentTarget) {
						App.user.quests.currentTarget = null;
						App.user.quests.lock = false;
					}
				}
				
				tm.onTargetComplete();
			}
		}
		
		public function inViewport():Boolean 
		{
			var globalX:int = this.x * App.map.scaleX + App.map.x;
			var globalY:int = this.y * App.map.scaleY + App.map.y;
			
			if (globalX < -10 || globalX > App.self.stage.stageWidth + 10) 	return false;
			if (globalY < -10 || globalY > App.self.stage.stageHeight + 10) return false;
			
			return true;
		}
		
		
		override public function click():Boolean {
			//inViewport();
			
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var backWindow:* = App.self.windowContainer.getChildAt(i);
				
				if (backWindow is InstanceWindow) {
					(backWindow as InstanceWindow).setHeroInto(sid);
					break;
				}
			}
			
			return true;
		}
		
		
		public static function randomSound(sid:uint, type:String):String {
			if (sounds[sid][type] is Array)
				return sounds[sid][type][int(Math.random() * sounds[sid][type].length)];
			else
				return sounds[sid][type];
		}
		
		public static var sounds:Object = {
			5: {//Трик
				gathering:'gathering_sound_3',
				voice:['speak_7','speak_8','speak_9']
			},
			230: {//Леа
				gathering:'gathering_sound_2',
				voice:['speak_4','speak_5','speak_6']
			},
			229: {//Хек
				gathering:'gathering_sound_1',
				voice:['speak_1','speak_2','speak_3']
			}
		}
		
		private var lastVoice:uint = 0;
		public function makeVoice():void {
			if (!canVoice()) return;
			SoundsManager.instance.playSFX(randomSound(sid, 'voice'), null, 0, 3);
			lastVoice = App.time;
		}
		
		public function canVoice():Boolean {
			
			return false;
			
			if (lastVoice +10 < App.time)
				return true;
				
			return false;	
		}
		
		public function getJobFramesType(sid:int):String {
			
			if (this.sid == User.PRINCE) {
				if (App.user.mode == User.GUEST)
					return 'work3';
					
				if ([65, 67, 69, 75, 76, 77, 78, 278].indexOf(sid) != -1) {
					return 'work2';
				}
				return Personage.HARVEST;
				
			}else if (this.sid == User.PRINCESS) 
			{
				if (App.user.mode == User.GUEST)
					return 'work2';
					
				if ([116, 117].indexOf(sid) != -1) {
					return 'work2';
				}
					
				return Personage.HARVEST;
			}
			
			return Personage.HARVEST;
		}
		
		/*override public function set framesType(value:String):void {
			if (value == 'fly')
				multipleAnime = wingsAnimation;
			else
				multipleAnime = null;
				
			super.framesType = value;	
		}*/
	}
}