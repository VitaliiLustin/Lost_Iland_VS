package units 
{
	import api.ExternalApi;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.CloudsMenu;
	import ui.Hints;
	import wins.SpeedWindow;
	/**
	 * ...
	 * @author ...
	 */
	public class Walkgolden extends WorkerUnit
	{
		public var crafted:uint		= 0;
		public var started:int = 0;
		public var crafting:Boolean = false;
		public var hasProduct:Boolean = false;
		
		public var fID:int = 0;
		
		public var _cloud:CloudsMenu;
		public var _showCloud:Boolean = false;
		
		private var _tribute:Boolean = false;
		
		public function Walkgolden(object:Object) 
		{
			crafted = object.crafted || 0;
			
			crafting = true;
			
			
			if (object.hasOwnProperty('level'))
				level = object.level;
			//else
				//addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			
				
			super(object);
			
			moveable = true;
			stockable = false;
			
			tip = function():Object {
				
				if (_tribute){
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379966")
					};
				}
				
				return {
					title:info.title,
					text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(crafted - App.time)]),
					timer:true
				};
			}	
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
			shortcutDistance = 50;
			homeRadius = 4;
			
			if (object.buy || object.fromStock) {
				showBorders();
			}
			
			beginCraft(0, crafted);
			
			if (formed && Map.ready)
				goHome();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
		}
		
		override public function onDown():void 
		{
			if (App.user.mode == User.OWNER) {
				if (isMove) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false;
				}else{
					var that:Walkgolden = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true
						that.move = true;
						App.map.moved = that;
					}, 200);
				}
			}
		}
		
		private var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		private var intervalMove:int;
		private function onUp(e:AppEvent):void 
		{
			if (isMoveThis) {
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
			}
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false;
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			if (formed)
				goHome();
		}
		
		override public function goHome(_movePoint:Object = null):void
		{
			if(info.moveable == 1)super.goHome(_movePoint);
		}
		
		override public function onGoHomeComplete():void {
			stopRest();
			//if(started > 0){
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
			//}
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			
			this.cell = coords.x 
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			this.id = data.id;
			
			started = App.time;
			
			created = App.time + App.data.storage[sid].time;
			crafted = App.time + App.data.storage[sid].time;
			
			beginCraft(0, created);
			
			tribute = false;
			hasProduct = false;
			flag = false;
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
			
			this.id = data.id;
			started = App.time;
			
			this.cell = coords.x; 
			this.row = coords.z;
			
			movePoint.x = coords.x;
			movePoint.y = coords.z;
			
			created = App.time + App.data.storage[sid].time;
			crafted = 0;// App.time + App.data.storage[sid].time;
			
			beginCraft(0, crafted);
			
			moveable = true;
			
			tribute = false;
			//crafting = true;
			//initAnimation();
			//beginAnimation();
		}
		
		override public function onMoveAction(error:int, data:Object, params:Object):void {
			
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
			
			if (started > 0)
				goHome();
				
			clearTimeout(intervalMove);
			isMove = false;
			isMoveThis = false
		}
		
		override public function click():Boolean 
		{
			clearTimeout(intervalMove);
			
			if(isMoveThis){
				this.move = false;
				App.map.moved = null;
				isMove = false;
				isMoveThis = false
				return true;
			}
			
			if (App.user.mode == User.GUEST) {
				return true;
			}
			
			if (!isReadyToWork()) return true;
			if (isProduct()) return true;
			
			return true;
		}
		
		public function isReadyToWork():Boolean
		{
			if (crafted > App.time) { 
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:crafted,
					totalTime:App.data.storage[sid].time,
					doBoost:onBoostEvent,
					btmdIconType:App.data.storage[sid].type,
					btmdIcon:App.data.storage[sid].preview
				}).show();
				return false;	
				
			}	
			return true;
		}
		
		public function onBoostEvent(count:int = 0):void {
			
			if (App.user.stock.take(Stock.FANT, count)){
				
				started = App.time - info.time;
				crafted = App.time - info.time;
				
				var that:Walkgolden = this;
				
				onProductionComplete();
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (!error && data) {
						started = data.started;
						App.ui.flashGlowing(that);
					}
					
				});	
			}
		}
		
		protected function beginCraft(fID:uint, crafted:uint):void
		{
			this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			
			App.self.setOffTimer(work);
			App.self.setOnTimer(work);
		}
		
		//public function onAfterBuy(e:AppEvent):void
		//{
			//if(textures != null){
				//var levelData:Object = textures.sprites[this.level];
				//removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
				//App.ui.flashGlowing(this, 0xFFF000);
			//}
			//
			//SoundsManager.instance.playSFX('building_1');
			//
			//started = App.time;
			//App.self.setOnTimer(work);
			//crafting = true;
			//goHome();
		//}
		
		public function work():void
		{
			if (App.time >= crafted)
			{
				App.self.setOffTimer(work);
				tribute = true;
				onProductionComplete();
			}
		}
		
		public function onProductionComplete():void
		{
			hasProduct = true;
			crafting = false;
			crafted = 0;
		}
		
		public function getPrice():Object
		{
			var price:Object = { }
			price[Stock.FANTASY] = 0;
			return price;
		}
		
		public function isProduct():Boolean
		{
			if (hasProduct)
			{
				var price:Object = getPrice();
						
				if (!App.user.stock.checkAll(price))	return true;
				
				storageEvent();
				
				ordered = false;
				
				return true; 
			}
			return false;
		}
		
		public function storageEvent():void
		{
			if (App.user.mode == User.OWNER) {
				
				var price:Object = { }
				price[Stock.FANTASY] = 1;
					
				if (!App.user.stock.takeAll(price))	return;
					Hints.minus(Stock.FANTASY, 1, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y), true);
				
				Post.send({
					ctr:this.type,
					act:'storage',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onStorageEvent);
			}
				
			tribute = false;
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			//Делаем push в _6e
			//if (App.social == 'FB') {
				//ExternalApi._6epush([ "_event", { "event": "gain" } ]);
			//}
			
			ordered = false;
			
			crafted = App.time + App.data.storage[sid].time;
			
			if(data.hasOwnProperty('started')){
				App.self.setOnTimer(work);
				//beginAnimation();
			}
			
			Treasures.bonus(data.bonus, new Point(this.x, this.y));
			SoundsManager.instance.playSFX('bonus');
			
			tribute = false;
			hasProduct = false;
			flag = false;
		}
		
		public function cloudResource(flag:Boolean, sid:int, callBack:Function, btm:String = 'productBacking', scaleIcon:*=null, isStartProgress:Boolean = false, start:int = 0, end:int = 0, offIcon:Boolean = false):void
		{
			if (_cloud)
				_cloud.dispose();
			
			_cloud = null;
			
			if (App.user.mode == User.GUEST)
				return;
				
			if (flag)
			{
				_showCloud = true;
				_cloud = new CloudsMenu(callBack, this, sid, {offIcon:offIcon, scaleIcon:scaleIcon } );// , tint:isTint } );
				_cloud.create(btm);
				_cloud.show();
				
				setCloudCoords();
				
				if (rotate) {
					_cloud.scaleX = -_cloud.scaleX;
					setCloudCoords();
				}
			}
			if(isStartProgress)_cloud.setProgress(start, end);
		}
		
		public function setCloudCoords():void      
		{
			if(cloudPositions.hasOwnProperty(info.view)){
				_cloud.y = cloudPositions[info.view].y;
				if (rotate) _cloud.x = cloudPositions[info.view].x + 70;
				else _cloud.x = cloudPositions[info.view].x;
			}
		}
		
		public var cloudPositions:Object = {
			'white_furry':{
				x:-35,
				y:-130
			},
			'unicorn':{
				x:-35,
				y:-130
			}
		}
		
		private var contLight:LayerX;
		private function showBorders():void 
		{
			contLight = new LayerX();
			
			var sqSize:int = 30;
			
			var cont:Sprite = new Sprite();
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x89d93c);//(0x2bed6f);
			sp.graphics.drawRoundRect(0, 0,400,400,400,400);
			sp.rotation = 45;
			sp.alpha = 0.5;
			
			cont.addChild(sp);
			cont.height = 400 * 0.7;
			
			contLight.addChild(cont);
			
			contLight.y = -contLight.height / 2;
			
			addChildAt(contLight, 0);
		}
		
		override public function previousPlace():void {
			super.previousPlace();
			
			if (contLight) {
				removeChild(contLight);
				contLight = null;
			}
		}
		
		override public function free():void {
			showBorders();
			super.free();
		}
		
		override public function uninstall():void 
		{
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			
			super.uninstall();
		}
		
		override public function set move(move:Boolean):void {
			super.move = move;
			
			if (!move && isMoveThis)
				previousPlace();
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			stopWalking();
			onGoHomeComplete();
			
			super.touch = touch;
		}
		
		public function set tribute(value:Boolean):void {
			_tribute = value;
			
			if (_cloud)_cloud.dispose();
				_cloud = null;
			
			if (_tribute)
			{
				cloudResource(true, Stock.EXP, isProduct);
			}
			else
			{
				if (_cloud)_cloud.dispose();
				_cloud = null;
			}
		}
		
	}

}