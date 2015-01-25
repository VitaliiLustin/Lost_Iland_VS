package units
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import flash.accessibility.Accessibility;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import ui.SystemPanel;
	import ui.UserInterface;
	import wins.ErrorWindow;
	import wins.FurryWindow;
	import wins.JamWindow;
	import wins.SimpleWindow;
	import wins.Window;
	import wins.WindowEvent;
	
	public class Resource extends Unit{
		
		public var capacity:uint;
	//	public var canUseCapacity:uint;
		public var reserved:int = 0;
		public var visited:uint = 0;
		
		public var countLabel:TextField;
		public var title:TextField;
		public var icon:Bitmap = new Bitmap(null, "auto", true);
		public var popupBalance:Sprite;
		public var glowed:Boolean = false;
		public var damage:int = 0;
		
		private var glowInterval:int;
		public var targetWorker:*;
		
		public function Resource(object:Object)
		{
			layer = Map.LAYER_SORT;
			super(object);
			
			if(info.outs){
				for(var _sid:* in info.outs) {
					info['out'] = _sid;
					break;
				}
			}else {
				info['out'] = Stock.COINS;
			}
			
			if (object.hasOwnProperty('capacity')) 
			{
				capacity = object.capacity;
				if (capacity <= 0 && App.user.mode == User.OWNER)
				{
					info['ask'] = false;
					remove();
					return;
				}
			}
			else
			{
				capacity = info.capacity;
			}	
				
			moveable = false;	
			multiple = false;
			rotateable = false;
			removable = true;
			
			if(!formed)
				moveable = true;
			
			tip = function():Object {
				return {
					title:info.title,
					text:info.description,
					desc:Locale.__e('flash:1402650129068'),
					count:String(info.require[Stock.FANTASY]),
					icon:new Bitmap(UserInterface.textures.energyIconSmall)
				};
			};
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
			Load.loading(Config.getIcon(App.data.storage[info.out].type, App.data.storage[info.out].view), onOutLoad);
			//popupBalance.visible = false;
			
			if (sid == 278) {
				transable = false;
			}
			
			App.self.addEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
		}
		
		private function onWheel(e:AppEvent):void 
		{
			if(popupBalance){
				resizePopupBalance();
			}
		}
		
		private function onLoad(data:*):void 
		{
			colorize(data);
			
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		private var containerY:int = 20;
		//private var bitmapContainer:Sprite = new Sprite();
		override public function draw(bitmapData:BitmapData, dx:int, dy:int):void {
			
			//bitmapContainer.removeChild(bitmap);
			bitmap.bitmapData = bitmapData;
			bitmap.scaleX = 0.999;
			
			this.dx = dx;
			this.dy = dy;
			bitmap.x = dx;
			bitmap.y = dy - containerY;
			//var obj:Object = IsoConvert.isoToScreen(info.area.w, info.area.h, true, true);
			bitmap.smoothing = true;
			
			//bitmapContainer.addChild(bitmap);
			//addChild(bitmapContainer);
			bitmapContainer.y = containerY;
			
			if (rotate) {
				scaleX = -scaleX;
			}
			
			startSwing();
		}
		
		override public function get bmp():Bitmap {
			return bitmap;
		}
		
		public function set balance(toogle:Boolean):void {
			if (move) return;
			
			
			if (toogle) {
				createPopupBalance();
				if(!App.map.mTreasure.contains(popupBalance)){
					App.map.mTreasure.addChild(popupBalance);
				}
				if(reserved == 0){
					countLabel.text = String(capacity);
				}else {
					countLabel.text = reserved  + '/' + capacity;
				}
				countLabel.x = (icon.width - countLabel.width) / 2;
			}else {
				if(popupBalance != null && App.map.mTreasure.contains(popupBalance)){
					App.map.mTreasure.removeChild(popupBalance);
					//popupBalance = null;
				}
			}
			//popupBalance.visible = toogle;
		}
		
		private function onOutLoad(data:*):void
		{
			icon.bitmapData = data.bitmapData;
			icon.smoothing = true;
			icon.scaleX = icon.scaleY = 0.5;
			icon.filters = [new GlowFilter(0xf7f2de, 1, 4, 4, 6, 1)];
		}
		
		private function createPopupBalance():void
		{
			if (popupBalance != null)
				return;
			
			popupBalance = new Sprite();
			popupBalance.cacheAsBitmap = true;
			
			popupBalance.addChild(icon);
			
			var textSettings:Object = {
				fontSize:18,
				autoSize:"left",
				color:0xFFFFFF,
				borderColor:0x302411,
				borderSize:4,
				distShadow:0
			}
			
			title = Window.drawText(App.data.storage[info.out].title, textSettings);
			title.x = (icon.width - title.width) / 2;
			title.y = icon.height - 10;
			
			popupBalance.addChild(title);
			
			countLabel = Window.drawText("", textSettings);
			countLabel.x = (icon.width - countLabel.width) / 2;
			countLabel.y = title.y + title.height - 7;
			
			popupBalance.addChild(countLabel);
			popupBalance.x = bitmap.x + (bitmap.width - icon.width) / 2 + x;
			popupBalance.y = bitmap.height + bitmap.y - 110 + y;
		}
		
		private function resizePopupBalance():void
		{
			var scale:Number = 1;
			switch(SystemPanel.scaleMode)
			{
				case 0:	scale = 1; 		break;
				case 1:	scale = 1.3; 	break;
				case 2:	scale = 1.6; 	break;
				case 3:	scale = 2.1; 	break;
			}
			
			var scaleX:Number = scale;
			var scaleY:Number = scale;
			
			//if(rotate) scaleX = -scaleX;
			
			popupBalance.scaleY = scaleY;
			popupBalance.scaleX = scaleX;
			
			popupBalance.x = bitmap.x + (bitmap.width - icon.width*scaleX) / 2 + x;
			popupBalance.y = bitmap.height + bitmap.y - 80 - 40*scaleY + y;
		}
		
		private var timeID:*;
		private var anim:TweenLite;
		override public function set touch(touch:Boolean):void {
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))
			{
				return;
			}
			
			super.touch = touch;
			
			if (touch) {
				if(Cursor.type == 'default' && !Missionhouse.windowOpened/*!clickable*/){
					
					timeID = setTimeout(function():void{
						balance = true;
						popupBalance.alpha = 0;
						resizePopupBalance();
						anim = TweenLite.to(popupBalance, 0.2, { alpha:1} );
					},400);
					
					App.map.lastTouched.push(this);
				}
			}else {
				clearTimeout(timeID);
				if(anim){
					anim.complete(true);
					anim.kill();
					anim = null;
				}
				balance = false;
			}
		}
		
		public function getContactPosition():Object
		{
			var y:int = -1;
			if (this.coords.z + y < 0)
				y = 0;
				
			return {
				x: int(info.area.w),
				y: y,
				direction:0,
				flip:0
			}
		}		
		
		public function getTechnoPosition(order:int = 1):Object
		{
			var workType:String = Personage.HARVEST;
			var z:int = -1;
			if (this.coords.z + z < 0)
				z = 0;
				
			return {
				x: coords.x + info.area.w,
				z: coords.z + z,
				direction:0,
				flip:0,
				workType:workType
			}
		}		
		
		override public function set ordered(ordered:Boolean):void {
			_ordered = ordered;
			if (ordered) {
				bitmap.alpha = .5;
			}else {
				bitmap.alpha = 1;
			}
		}
		
		private function onAfterClose(e:WindowEvent):void
		{
			e.currentTarget.removeEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
			Cursor.type = Cursor.prevType;
		}
		
		private function canTake():Boolean
		{	
			if (info.level > App.user.level) {
				new SimpleWindow( {
					title:Locale.__e('flash:1396606807965', [info.level]),
					text:Locale.__e('flash:1396606823071'),
					label:SimpleWindow.ERROR
				}).show();
				
				return false;
			}
			return true;
		}
		
		public static var isFurryTarget:Boolean = false;
		public var isTarget:Boolean = false;
		override public function click():Boolean {
			if (!super.click()) return false;	
					
			if (!canTake() || (!isFurryTarget && !App.user.stock.canTake(info.outs))) return true;
						
			isFurryTarget = false;
			
			if (reserved >= capacity) {
				Hints.text(Locale.__e('flash:1382952379949'), Hints.TEXT_RED,  new Point(App.map.scaleX * (this.x + this.width / 2) + App.map.x, this.y * App.map.scaleY + App.map.y));
				return true;
			}
			
			if (busy)
			{
				new SimpleWindow( {
					hasTitle:false,
					label:SimpleWindow.ERROR,
					text:Locale.__e("flash:1404201091423"),
					confirm:function():void {
						clearTimeout(glowInterval);
						if (targetWorker) {
							if (targetWorker) {
								App.map.focusedOn(targetWorker, true);
								//targetWorker.startGlowing();
							}
							//glowInterval = setTimeout(function():void { if(targetWorker)targetWorker.hideGlowing();}, 3000);
						}
						
					}
				}).show();
				
				return true;
			}
				
			if (reserved == 0){
				ordered = true;
			}
			
			if (Factory.waitForTarget && !isTarget) {
				new FurryWindow({
					title:info.title,
					info:info,
					mode:FurryWindow.RESOURCE,
					capacity:capacity,
					target:this
					//totalCapacity:App.data.storage[sid].capacity//,
					//onUpgradeEvent:upgradeEvent
				}).show();
				
				ordered = false;
				return true;
			}
				
			if(App.user.addTarget({
				target:this,
				near:true,
				callback:onTakeResourceEvent,
				event:Personage.HARVEST,
				jobPosition:getContactPosition(),
				shortcutCheck:true,
				onStart:function(_target:* = null):void {
					//startCutting();
					//startSwing(true, true);
					//showBranches();
					targetWorker = _target;
					ordered = false;
				}
			})) {
				isTarget = true;
				reserved++;
				balance = true;
				if (sid == 278)	QuestsRules.quest97 = true;
					
			}else {
				ordered = false;
			}
					
			/*	break;			
			}*/
			return true;
		}
		
		private function onNeedBeavers():void
		{
			var beaver:Bear = Bear.isFreeBears();
						
			if (beaver == null)
			{
				var settings:Object = { view:'jam' };
					settings['view'] = 'fish';
				
				new JamWindow(settings).show();
			}
			else
			{
				App.map.focusedOn(beaver);
				beaver.createWorkIcons();
			}
		}
		
		public function takeResource(count:uint = 1):void
		{
			if (capacity - count >= 0)	
				capacity -= count;
			if (capacity == 0)
				uninstall();
		}
		
		private function fireWorker():void
		{
			for (var i:int = 0; i < Bear.bears.length; i++)
			{
				var bear:Bear = Bear.bears[i];
				if (bear.resource == this)
				{
					bear.fireAction();
					return;
				}
			}
		}
		
		public function onTakeResourceEvent(guest:Guest = null):void
		{
			stopSwing();
			
			if (guest != null) {	
				Post.send( {
					ctr:this.type,
					act:'helpkick',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:this.sid,
					id:id,
					helper:guest.friend.uid
				}, onKickEvent, {friend:guest});
			}else if (App.user.mode == User.OWNER) {
				
				if(App.user.stock.canTake(info.outs) && App.user.stock.takeAll(info.require)){
				
				for (var _sid:* in info.require) {
					Hints.minus(_sid, info.require[_sid], new Point(worker.x * App.map.scaleX + App.map.x, worker.y * App.map.scaleY + App.map.y), false);	
				}
					var postObject:Object = {
						ctr:this.type,
						act:'kick',
						uID:App.user.id,
						wID:App.user.worldID,
						sID:this.sid,
						id:id
					}
					
					if (!QuestsRules.quest6 && App.user.quests.data[6] != null && App.user.quests.data[6].finished == 0) {
						QuestsRules.quest6 = true;
						postObject['tr'] = 'Stone_quest';
					}
					
					Post.send(postObject, onKickEvent);
					
					//if (App.social == 'FB') {						
						//ExternalApi._6epush([ "_event", {  "event":"achievement", "achievement":"clear" } ]);
					//}
				}else{
					App.user.onStopEvent();
					reserved = 0;
					return;
				}
			}else{
				if(App.user.friends.takeGuestEnergy(App.owner.id)){
					Post.send({
						ctr:'user',
						act:'guestkick',
						uID:App.user.id,
						sID:this.sid,
						fID:App.owner.id
					}, onKickEvent, { guest:true } );
				}else{
					Hints.text(Locale.__e('flash:1382952379907'), Hints.TEXT_RED,  new Point(App.map.scaleX*(x + width / 2) + App.map.x, y*App.map.scaleY + App.map.y));
					App.user.onStopEvent();
					reserved = 0;
					return;
				}
			}
			
			if (guest == null){
				reserved--;
				if (reserved < 0) {
					reserved = 0;
				}
			}
			takeResource();
		}
		
		private function onKickEvent(error:int, data:Object, params:Object):void
		{
			if (error) {
				Errors.show(error, data);
				if(params != null && params.hasOwnProperty('guest')){
					App.user.friends.addGuestEnergy(App.owner.id);
				}
				//TODO ������ kick
				return;
			}
			/*if (data.__achstate) {
				for (var ach:* in data.__achstate) {
					if (!App.user.ach[ach]) {
						App.user.ach[ach] = data.__achstate[ach];
						continue;
					}
					for (var mis:* in data.__achstate[ach]) {
						App.user.ach[ach][mis] = data.__achstate[ach][mis];
					}
				}
			}*/
				
			if(touch)
				balance = true;
				
			if (data.hasOwnProperty("bonus")){
				var that:* = this;
				spit(function():void{
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
				});
			}
			
			if (data.hasOwnProperty("energy") && data.energy > 0) {
				App.user.friends.updateOne(App.owner.id, "energy", data.energy);
			}
			
			//if (data.hasOwnProperty("bonus")) {
				//Treasures.bonus(data.bonus, new Point(this.x, this.y));
			//}
			
			if(App.user.mode == User.GUEST)
				App.user.friends.giveGuestBonus(App.owner.id);
				
			//if (params != null) { 
				//if(params['friend'] != undefined) {
					//var guest:Guest = params.friend;
					//if (guest.friend['helped'] != undefined && guest.friend.helped > 0) {
						//guest.friend.helped--;
					//}
					//if (guest.friend['helped'] == undefined || guest.friend.helped == 0) {
						//guest.uninstall();
						//guest = null;
					//}
				//}
				
				//if (params['guest'] != undefined) {
					//if (data.hasOwnProperty('energy')) {
						//if(App.user.friends.data[App.owner.id].energy != data.energy){
							//App.user.friends.data[App.owner.id].energy = data.energy;
							//App.ui.leftPanel.update();
						//}
					//}
					//App.user.friends.giveGuestBonus(App.owner.id);
				//}
			//}
			ordered = false;
			
			/*if (data.hasOwnProperty(Stock.FANTASY)) {
				Hints.minus(Stock.FANTASY, 1, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
				App.user.stock.setFantasy(data[Stock.FANTASY]);
			}*/
			//ordered = false;
		}
		
		override public function can():Boolean{
			return reserved > 0
		}
		
		public function glowing():void {
			glowed = true; 
			var that:Resource = this;
			TweenMax.to(this, 0.8, { glowFilter: { color:0xFFFF00, alpha:1, strength: 6, blurX:15, blurY:15 }, onComplete:function():void {
				TweenMax.to(that, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 4, blurX:6, blurY:6 }, onComplete:function():void {
					that.filters = [];
					glowed = false;
				}});	
			}});
		}
		
		public var withWhispa:Boolean = false;
		public var whispa:Whispa;
		public var whispaTimeID:uint; 
		
		public static var countWhispa:uint = 0;
		
		public function showWhispa():void {
			if (withWhispa == true || countWhispa > 4) return;
			
			countWhispa++;
			
			withWhispa = true;
			whispa = new Whispa( { cells:cells, rows:rows } );
			addChild(whispa);
			
			whispa.y = dy;
			
			whispa.alpha = 0;
			TweenLite.to(whispa, 2, { alpha:1 } );
			
			whispaTimeID = setTimeout(function():void {
				TweenLite.to(whispa, 2, { alpha:0, onComplete:function():void {
					removeChild(whispa);
					withWhispa = false;
					whispa = null;
					countWhispa--;
				} } );
				
			},8000 + Math.random() * 20000);
		}
		
		public function dispose():void {
			clearTimeout(glowInterval);
			App.self.removeEventListener(AppEvent.ON_WHEEL_MOVE, onWheel);
			
			if (withWhispa == true && whispa != null) { 
				clearTimeout(whispaTimeID);
			}
			uninstall();
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			moveable = false;
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.id = data.id;
			moveable = false;
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			//return EMPTY;
			if (info.base != null && info.base == 1) 
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						if (node.w != 1 || node.open == false || node.object != null) {
							return OCCUPIED;
						}
					}
				}
				return EMPTY;
			}
			else
			{
				return super.calcState(node);
			}
		}
		
		public function showDamage():void 
		{
			Hints.minus(info.out, damage, new Point(), false, this);
			var bonus:Object = { };
			bonus[info.out] = { "1":damage };
			Treasures.bonus(bonus, new Point(this.x, this.y));
			takeResource(damage);
			
			damage = 0;
			busy = 0;
			clickable = true;
		}
		
		public static var swingSettings:Object = {
			'bush': 	{amp:0.025, a:0, da:50, dda:-1},
			'grass': 	{amp:0.025, a:0, da:50 },
			'fir': 		{amp:0.025, a:0, da:50, dda:-1}
		}
		
		public function startSwing(random:Boolean = true, getType:Boolean = true):void {
			return;
			
			if (info.view.indexOf('stone') != -1 ||
				info.view.indexOf('gold') != -1)
				return;
				
			a = 0;
			dda = -1;
			amp = 0.05;
			da = 0.05;
			
			if (random)
				a = int(Math.random() * 360);
				
			App.self.setOnEnterFrame(swinging);
		}
		
		public function stopSwing():void {
			App.self.setOffEnterFrame(swinging);
			a = 0;
			da = 0;
			dda = 0;
			amp = 0;
			//hideBranches();
		}
		
		private var a:Number = 0;
		private var da:Number = 0;
		private var dda:Number = 0;
		private var amp:Number = 0;//0.025
		private function swinging(e:Event):void {
			a += da;//2
			if (a >= 360) a -= 360;
			
			if (da > 0)
				da += dda;
			var c:Number = amp * Math.sin(a * Math.PI / 180);//0.025
			var matrix:Matrix = new Matrix();
			matrix.c = c;
			matrix.ty = containerY;
			
			bitmapContainer.transform.matrix = matrix;
		}
		
		public function setCapacity(count:int):void {
			capacity = count;
			if (capacity <= 0)
				uninstall();
		}
		
	}
}