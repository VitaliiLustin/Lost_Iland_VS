package units 
{
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
	import flash.events.MouseEvent;
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
	import ui.AnimalCloud;
	import ui.Cursor;
	import ui.Hints;
	import ui.ProgressBar;
	import ui.UserInterface;
	import wins.HeroWindow;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class Animal extends WorkerUnit
	{
		public static var waitForTarget:Boolean = false;
		
		public var count:int = 0;
		public var cloudAnimal:AnimalCloud;
		private var countRequireItems:int = 0;
		
		public var canAddCowboy:Boolean = false;
		
		public var cowboy:Cowboy;
		
		public function Animal(object:Object)
		{
			started = object.started || 0;
			count = object.count || 0;
			hasProduct
			if (started > App.time) 
				producting = true;
			
			super(object);
			
			info['area'] = { w:1, h:1 };
			cells = rows = 1;
			velocities = [0.05];
			
			App.user.animals.push(this);
			App.ui.upPanel.update()
			
			
			moveable = true;
			takeable = false;
			
			if (started > 0)
				App.self.setOnTimer(work);
			else 
				hungry();
			
			tip = function():Object {
				var cnt:int = info.count - count;
				if (cnt < 0) cnt = 0;
				if(started != 0){
					if (started > App.time) {
						return {
							title:info.title,
							text:Locale.__e('flash:1396606641768', [TimeConverter.timeToStr(started - App.time)] + "\n" + Locale.__e("flash:1403797940774", [String(cnt)])),
							timer:true
						}
					}else {
						return {
							title:info.title,
							text:Locale.__e('flash:1396606659545')
						}
					}
				}	
				
				return {
					title:info.title,
					text:info.description + "\n" + Locale.__e("flash:1403797940774", [String(cnt)])
				}
			}
			
			for (var out:* in App.data.storage[sid].require) {
				break;
			}
			countRequireItems = App.data.storage[sid].require[out];
			
			startHungryCloud = generateHungryStart();
			
			if (Map.ready && started > 0)
				goHome();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				
			if (object.buy) {
				showBorders();
			}
			
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onUp);
			shortcutDistance = 50;
			homeRadius = 4;
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
		}
		
		private function onChangeStock(e:AppEvent):void 
		{
			if (!hasProduct && cloudAnimal && !producting) {
				cloudAnimal.dispose();
				cloudAnimal = null;
				hungry();
			}
		}
		
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
		
		override public function set move(move:Boolean):void {
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
		
		override public function spit(callback:Function = null, target:* = null):void 
		{
			
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
			
			this.id = data.id;
			//setTimeout(goHome, 2000);
		}
		
		override public function free():void {
			showBorders();
			super.free();
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
		override public function take():void {
			
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			if (started > 0)
				goHome();
		}
		
		//private var intervalHungry:int;
		//private var hungryDelayTime:int = 60000;
		public function hungry():void
		{
			if (/*started <= 0 && */!cloudAnimal) {
				showIcon('require', feedEvent, AnimalCloud.MODE_NEED, 'productBacking', 0.4, /*hungryDelayTime*/0, 0.8);
				//intervalHungry = setInterval(closeHungryCloud, hungryDelayTime);
			}
		}
		
		override public function set touch(touch:Boolean):void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			stopWalking();
			onGoHomeComplete();
			
			super.touch = touch;
		}
		
		override public function onGoHomeComplete():void {
			stopRest();
			if(started > 0){
				var time:uint = Math.random() * 5000 + 5000;
				timer = setTimeout(goHome, time);
			}
		}
		
		private var hungryCloseTween:TweenLite;
		private function closeHungryCloud():void 
		{
			//clearInterval(intervalHungry);
			if(cloudAnimal)hungryCloseTween = TweenLite.to(cloudAnimal, 1, { alpha:0, scaleX:0.3, scaleY:0.3, x:(cloudAnimal.x + 20), y:(cloudAnimal.y + 60), onComplete:realHungCloudClose});
		}
		
		private function realHungCloudClose():void
		{
			//clearInterval(intervalHungry);
			if (hungryCloseTween) {
				hungryCloseTween.kill();
				hungryCloseTween = null;
			}
			if(cloudAnimal)cloudAnimal.dispose();
			cloudAnimal = null;
		}
		
		public function updateCount():void
		{
			if (sid == 135)
				trace();
				
			if (count == 0) {
				count = int((App.time - started) / info.duration);
			}else {
				count += int((App.time - started) / info.duration);
			}
			//if (count > info.count) {
				//cowboy.animalDone();
				//uninstall();
			//}
			trace();
		}
		
		override public function uninstall():void {
			App.self.setOffTimer(work);
			var index:int = App.user.animals.indexOf(this)
			if (index != -1)
			App.user.animals.splice(index, 1);
			
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onUp);
			
			super.uninstall();
		}
		
		private var isMoveThis:Boolean = false;
		public static var isMove:Boolean = false;
		private var intervalMove:int;
		override public function onDown():void 
		{
			if (App.user.mode == User.OWNER) {
				if (isMove) {
					clearTimeout(intervalMove);
					isMove = false;
					isMoveThis = false;
				}else if(!cowboy){
					var that:Animal = this;
					intervalMove = setTimeout(function():void {
						isMove = true;
						isMoveThis = true
						that.move = true;
						App.map.moved = that;
					}, 200);
				}
			}
		}
		
		private var lock:Boolean = false;
		public var hasProduct:Boolean = false;
		override public function click():Boolean
		{
			clearTimeout(intervalMove);
			
			if (canAddCowboy && Animal.waitForTarget) {
				Cowboy.cowboy.tie(this);
				cowboy = Cowboy.cowboy;
				if (started <= 0) {
					started = App.time + info.duration;
					App.self.setOnTimer(work);
					work();
				}
				
				if (cloudAnimal)
					cloudAnimal.dispose();
				cloudAnimal = null;
				return true;
			}
			
			if (cowboy) {
				cowboy.showSpeedWindow();
				return true;
			}
			
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
			
			if (lock) return false;
			
			if (producting) {
				//Hints.text(Locale.__e('Уже производит'), Hints.TEXT_RED,  new Point(App.map.scaleX * (this.x + this.width / 2) + App.map.x, this.y * App.map.scaleY + App.map.y));
				
				if (!cloudAnimal) {
					showIcon('outs', storageEvent, AnimalCloud.MODE_CRAFTING, 'productBacking2', 0.7);
					cloudAnimal.setProgress(started - info.duration, started);
					return true;
				}
				return false;
			}
			
			if (hasProduct)
			{
				storageEvent();
				return true;
			}
			
			//if (cloudAnimal && cloudAnimal.getMode() == AnimalCloud.MODE_HUNGRY) 
				//realHungCloudClose();
			
			if (cloudAnimal)feedEvent();
			else showIcon('require', feedEvent, AnimalCloud.MODE_NEED);
			
			return true;
		}
		
		private function showIcon(typeItem:String, callBack:Function, mode:int, btmDataName:String = 'productBacking2', scaleIcon:Number = 0.6, timeDelay:int = 4000, scaleBttn:Number = 1):void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (cloudAnimal) {
				cloudAnimal.dispose();
				cloudAnimal = null;
			}
				
			cloudAnimal = new AnimalCloud(callBack, this, sid, mode, {scaleIcon:scaleIcon, timeDelay:timeDelay, scaleBttn:scaleBttn});
			cloudAnimal.create(btmDataName);
			cloudAnimal.show();
			cloudAnimal.x = - 30;
			cloudAnimal.y = - 120;
			
			if(mode == AnimalCloud.MODE_CRAFTING)
				cloudAnimal.y = - 160;
			
			if (scaleBttn < 1) {
				cloudAnimal.y += 20;
				cloudAnimal.x += 6;
			}
			
			cloudAnimal.pluck(30);
		}
		
		private var producting:Boolean = false;
		private var started:uint = 0;
		private function feedEvent(value:int = 0):void {
			
			if (!App.user.stock.takeAll(App.data.storage[sid].require)) {
				for (var req:* in App.data.storage[sid].require) {
					break;
				}
				
				new PurchaseWindow( {
					width:395,
					itemsOnPage:2,
					content:PurchaseWindow.createContent("Energy", { inguest:0, view:'Feed'} ),
					find:req,
					title:Locale.__e("flash:1396606700679"),
					description:Locale.__e("flash:1382952379757"),
					callback:function(sID:int):void {
						var object:* = App.data.storage[sID];
						App.user.stock.add(sID, object);
					}
				}).show();
				if (cloudAnimal) cloudAnimal.dispose();
				cloudAnimal = null;
				return;
			}
			for (var out:* in App.data.storage[sid].require) {
				break;
			}
			
			var point:Point = new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y);
			Hints.minus(out, App.data.storage[sid].require[out], point);
			
			if (cloudAnimal) cloudAnimal.dispose();
			cloudAnimal = null;
			
			App.ui.flashGlowing(this, 0x83c42a);
			
			flyMaterial(out);
			
			//clearInterval(intervalHungry);
			
			producting = true;
			Post.send({
				ctr:this.type,
				act:'feed',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				movePoint.x = coords.x;
				movePoint.y = coords.z;
				
				started = data.started;
				App.self.setOnTimer(work);
				goHome();
			});		
		}
		
		private function flyMaterial(sid:int):void
		{
			var item:BonusItem = new BonusItem(sid, 0);
			
			var point:Point = Window.localToGlobal(App.ui.bottomPanel.bttnMainStock);
			var moveTo:Point = new Point(App.self.mouseX, App.self.mouseY);
			item.fromStock(point, moveTo, App.self.tipsContainer);
		}
		
		private function work():void 
		{
			if (App.time >/*=*/ started) {
			
				if (cowboy) {
					started = App.time + info.duration;
					cowboy.animalDone();
					
					if (cloudAnimal)
						cloudAnimal.dispose();
					cloudAnimal = null;
					
					count++;
					if (count >= info.count) {
						var that:* = this;
						TweenLite.to(this, 1, { alpha:0, onComplete:function():void 
						{
							//cowboy.animal = null;
							removable = true;
							uninstall();
							new SimpleWindow({
								title:App.data.storage[that.sid].title,
								text:Locale.__e('flash:1396606732168')
							}).show();
						}});	
					}
				}else{
					App.self.setOffTimer(work);
					hasProduct = true;
					showIcon('outs', storageEvent, AnimalCloud.MODE_DONE, 'productBacking2', 0.7);
					if(cloudAnimal)cloudAnimal.doIconEff();
					producting = false;
				}
			}
		}
		
		public function onBoostEvent(count:int = 0):void {
			
			if (!App.user.stock.take(Stock.FANT, count)) return;//заменить
				
				var that:Animal = this;
			
				producting = false;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					if (!error && data) {
						
						App.ui.flashGlowing(that);
						
						started = data.started;
						
						if (cloudAnimal) cloudAnimal.dispose();
						cloudAnimal = null;
						
					}
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		private function storageEvent(value:int = 0):void {
			
			if (!App.user.stock.canTake(info.outs)) 
			return;
			
			if (cloudAnimal) cloudAnimal.dispose();
			cloudAnimal = null;
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},onStorageEvent);
		}
		
		private function onStorageEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			hasProduct = false;
			started = 0;
			var outs:Object = Treasures.convert(info.outs)
			Treasures.bonus(outs, new Point(this.x, this.y));
			
			hungry();
			stopWalking();
			onGoHomeComplete();
			clearTimeout(timer);
			
			count++;
			if (count >= info.count) {
				var that:* = this;
				TweenLite.to(this, 1, { alpha:0, onComplete:function():void 
				{
					removable = true;
					uninstall();
					new SimpleWindow({
						title:App.data.storage[that.sid].title,
						text:Locale.__e('flash:1396606732168')
					}).show();
				}});	
			}
		}
		
		private var startHungryCloud:int;
		override public function onLoop():void
		{	
			super.onLoop();
			if (cloudAnimal || started > 0) return;
			
			if (!cloudAnimal && !producting) 
				hungry();
			//startHungryCloud--;
			//if (startHungryCloud <= 0) {
				//startHungryCloud = generateHungryStart();
				//hungry();
			//}
		}
		
		public function addCowboy(cowboy:Cowboy):void
		{
			this.cowboy = cowboy;
			if (hasProduct)
			{
				cowboy.animalDone();
				if(cloudAnimal)cloudAnimal.doIconEff();
			}
			removable = false;
		}
		
		private function generateHungryStart():int 
		{
			var rnd:int = 20;/*Math.random() * 15 + 5;*/
			return rnd;
		}
		
		override public function onRemoveFromStage(e:Event):void 
		{
			clearTimeout(timer);
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			realHungCloudClose();
			
			super.onRemoveFromStage(e);
		}
		
		override public function checkOnSplice(start:*, finish:*):Boolean {
			return false;
		}
		
	}
}