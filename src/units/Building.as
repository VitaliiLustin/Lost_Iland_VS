package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.Cloud;
	import ui.CloudsMenu;
	import ui.SystemPanel;
	import wins.ConstructWindow;
	import wins.ItemsWindow;
	import wins.SpeedWindow;

	import ui.Hints;
	import ui.Cursor;
	import ui.UserInterface;
	import wins.BankWindow;
	import wins.BuildingConstructWindow;
	import wins.ProductionWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Building extends AUnit
	{
		public static const BUILD:String = 'build';
		public static const BOOST:String = 'boost';
		
		public var level:uint = 0;
		public var totalLevels:uint = 0;
		public var formula:Object;
		public var fID:uint			= 0;
		public var crafted:uint		= 0;
		public var instance:uint	= 1;
		public var helpers:Object	= { };
		public var hasProduct:Boolean = false;
		
		public var _crafting:Boolean = false;
		public var gloweble:Boolean = false;
		
		public var hasBuilded:Boolean = false;
		public var hasUpgraded:Boolean = false;
		
		public var upgradedTime:int;
	
		public var hasPresent:Boolean = false;
		
		public var _cloud:CloudsMenu;
		public var _showCloud:Boolean = false;
		
		public var completed:Array	= [];
		public var began:int 		= 0;
		public var queue:Array = [];
		public var openedSlots:int;
		
		public function Building(object:Object)
		{	
			if(layer == null)
				layer = Map.LAYER_SORT;
								
			helpers = object.helpers || { };
			
			if (object.hasOwnProperty('level'))
				level = object.level;
			else
				addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
				
				
			super(object);
			touchableInGuest = true;
			
			if (sid == 128) {
				trace('');
			}
			
			setCraftLevels();
			
			//if(info.devel){
				//for each(var obj:* in info.devel.req) {
					//totalLevels++;
				//}
			//}
			
			if (sid == 350)
				trace();
			
			if(info.devel){
				for each(var obj:* in info.devel.req) {
					totalLevels++;
				}
			}
			
			initProduction(object);
			
			/*if (level >= totalLevels - craftLevels && object.crafted > 0)
				beginCraft(object.fID, object.crafted);*/
			if (object.hasOwnProperty("slots"))
			{
				openedSlots = object.slots;
			}else {
				for each(var slot:* in info.slots)
				{
					if (slot.status == 1)
					{
						openedSlots++;
					}
				}
			}
		
			upgradedTime = object.upgrade;
			created = object.created;
			
			if (formed) 
			{
				addConstructFlag();
				
				hasBuilded = true;
				hasUpgraded = true;
				/*if (level == 0) {
					gloweble = true;
					hasBuilded = false;
					build();
					if(!hasBuilded){
						App.self.setOnTimer(build);
						addProgressBar();
						checkTechnoNeed();	
						addEffect(Building.BUILD);
					}	
				}	*/
				
				if(upgradedTime > 0){
					//level += 1;
					hasUpgraded = false;
					upgraded();
					if (!hasUpgraded) {
						App.self.setOnTimer(upgraded);
						addProgressBar();
						checkTechnoNeed(true);	
						addEffect(Building.BUILD);
					}	
				}
			}
			
			load();
			
			tip = function():Object 
			{
				if (hasProduct) {
					var text:String = '';
					for (var i:int = 0; i < completed.length; i++ ) {
						if (text.length > 0) text += ', ';
						text += App.data.storage[getFormula(completed[i]).out].title;
					}
					
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379845", [text])
					};
				}else if (created > 0 && !hasBuilded) {
					
					return {
						title:info.title,
						text:Locale.__e('flash:1395412587100') +  '\n' + TimeConverter.timeToStr(created-App.time),
						timer:true
					}
				}else if (upgradedTime > 0 && !hasUpgraded) {
					
					return {
						title:info.title,
						text:Locale.__e('flash:1395412562823') +  '\n' + TimeConverter.timeToStr(upgradedTime-App.time),
						timer:true
					}
				}else if (crafting) {
						return {
						title:info.title,
						text:Locale.__e(Locale.__e('flash:1395853416367') +  '\n' + TimeConverter.timeToStr(crafted-App.time)),
						timer:true
					}
				}
				
				return {
					title:info.title,
					text:info.description
				};
			}
			
			if (App.user.mode == User.GUEST) {
				flag = false;
				setFlag(Cloud.TRIBUTE, guestClick );
				//initAnimation();
				//beginAnimation();
			}
			
			if (sid == 132)
				removable = false;
		}
		
		public function addConstructFlag():void
		{
			if(type != "Tradeshop" && type != "Trade" &&level <= totalLevels - craftLevels)
			{
				setFlag("constructing", isPresent, { target:this, roundBg:false, addGlow:false } );
			}
		}
		
		public function getFormula(fID:*):Object {
			return (App.data.crafting[fID] != null) ? App.data.crafting[fID] : null;
		}
		
		public function initProduction(object:Object):void {
			
			if (object.hasOwnProperty('fID')) {
				
				var willCrafted:int;
				
				if (object.fID is Number && getFormula(object.fID) && object.crafted) {
					formula = getFormula(object.fID);
					fID = object.fID;
					began = object.crafted - formula.time;
					crafted = object.crafted;
					queue.push( {
						order:		0,
						fID:		object.fID,
						crafted:	crafted
					});
					
					willCrafted = crafted;
					
					checkProduction();
				}else if (typeof(object.fID) == 'object') {
					queue = [];
					willCrafted = object.crafted;
					for (var id:String in object.fID) {
						
						if(id != "0")
							willCrafted += getFormula(object.fID[id]).time;
							
						queue.push( {
							order:		int(id),
							fID:		object.fID[id],
							crafted:	willCrafted//_crafted
						});
					}
					queue.sortOn('order', Array.NUMERIC);
					
					checkProduction();
				}
			}
			
			if(Map.ready)
				setTechnoesQueue();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, setTechnoesQueue);
				
		}
		
		private function setTechnoesQueue(e:AppEvent = null):void 
		{
			for (var i:int = 0; i < queue.length-1; i++ ) {
				if (technos != null && technos.length > 0 && technos[0].capacity >= 0 && queue[i].crafted > App.time ) {
					//var _technos:Array = Techno.freeTechno();
					//if(_technos.length > 0)
						//_technos[0].workStatus = WorkerUnit.QUEUE;
					rentTechno();
				}
			}
		}
		
		public function checkProduction():void {
			completed = [];
			crafting = false;
			
			for (var i:int = 0; i < queue.length; i++) {
				var product:Object = queue[i];
				
				if (product.crafted <= App.time) {
					completed.push(product.fID);
					hasProduct = true;
					formula = getFormula(product.fID);
					cloudResource(true, formula.out, isProduct, 'productBacking2', 0.6, true, began, crafted);
					if(_cloud) _cloud.stopProgress();
				}else {
					beginCraft(product.fID, product.crafted);
					break;
				}
			}
			
			if (!crafting) {
				began = 0;
				crafted = 0;
				fID = 0;
			}else {
				initAnimation();
				startAnimation();	
			}
		}
		
		
		public function checkTechnoNeed(isUpgrade:Boolean = false):void
		{
			var req:Object;
			
			req = info.devel.obj[level + 1];
			
			for (var itm:* in req) {
				if (itm == Techno.TECHNO) {
					needTechno = req[itm];
					break;
				}
			}	
			
			if (needTechno <= 0) return;
			
			if (Map.ready)
				rentTechno();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete)
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete)
			rentTechno();
		}
		
		public function load():void {
			
			var curLevel:int = level;
			if (curLevel <= 0) curLevel = 1;
			
			if (info.devel.req[curLevel] == null) {
				curLevel --;
			}
			Load.loading(Config.getSwf(type, info.devel.req[curLevel].v), onLoad);
		}
		
		public function isBuilded():Boolean 
		{
			if (created == 0) return false;
			
			var curLevel:int = level + 1;
			if (curLevel >= totalLevels) curLevel = totalLevels;
			if (created <= App.time) {
				if (level == 0) level = 1;
				//updateLevel();  
				hasBuilded = true;
				
				//hasUpgraded = true;
				return true;
			}
			
			return false;
		}
		
		public function build():void {
			updateProgress(created - info.devel.req[level+1].t, created);

			if (isBuilded()){
				App.self.setOffTimer(build);
				if (App.user.mode != User.GUEST) {
					setFlag("hand", isPresent, {target:this, roundBg:true, addGlow:true } );
				}
				hasPresent = true;
				//moveable = true;
				updateLevel();
				fireTechno(1);
				removeProgress();
				hasUpgraded = true;
				onBuildComplete();
			}
		}
		
		public function onBuildComplete():void 
		{

		}
		
		public function isUpgrade():Boolean 
		{
			if (upgradedTime <= App.time) {
				hasUpgraded = true;
				//moveable = true;
				return true;
			}
			
			return false;
		}
		
		public function upgraded():void {
			updateProgress(upgradedTime - info.devel.req[level+1].t,upgradedTime);
			if (isUpgrade()){
				App.self.setOffTimer(upgraded);
				if (App.user.mode != User.GUEST) {
					setFlag("hand", isPresent, {target:this, roundBg:true, addGlow:true } );
				}
				if (!hasUpgraded)
				{
					instance = 1;
					created = App.time + info.devel.req[1].t;
					App.self.setOnTimer(build);
					addProgressBar();
					addEffect(Building.BUILD);
					checkTechnoNeed();
				}else
				{
					hasUpgraded = true;
					hasPresent = true;
					finishUpgrade();
					this.level++;
					updateLevel();
					fireTechno(1);
					removeProgress();	
				}
				
				
			}
		}
		
		public function updateProgress(startTime:int, endTime:int):void
		{
			if (!progressContainer) return;
			
			progressContainer.visible = true;
			var totalTime:int = endTime-startTime;
			var curTime:int = endTime - App.time;
			var timeForSlider:int = totalTime - curTime;
			
			if (timeForSlider < 0) timeForSlider = 0;
			UserInterface.slider(slider, timeForSlider, totalTime, "productionProgressBarGreen", true);
		}
		
		public var progressContainer:Sprite = new Sprite();                                       
		public var slider:Sprite = new Sprite();
		private var bgProgress:Bitmap;
		
		public function addProgressBar():void 
		{
			bgProgress = new Bitmap(Window.textures.productionProgressBarBacking);
			progressContainer.addChild(bgProgress);
			progressContainer.addChild(slider);
			slider.x = 4; slider.y = 2;
			
			addChild(progressContainer);
			
			if(rotate)
				progressContainer.scaleX = -1
			
			if(progressPositions.hasOwnProperty(info.view)){
				progressContainer.y = progressPositions[info.view].y;
				progressContainer.x = progressPositions[info.view].x;
			}else{
				progressContainer.y = -60;
				progressContainer.x = -40;
			}
			
			if (progressContainer.scaleX == -1) {
				progressContainer.x += progressContainer.width/2;
			}
			
			progressContainer.visible = false;
		}
		
		public function removeProgress():void
		{
			if (slider && slider.parent) {
				slider.parent.removeChild(slider);
			}
			
			if (bgProgress && bgProgress.parent) {
				bgProgress.parent.removeChild(bgProgress);
			}
			
			if (progressContainer && progressContainer.parent) {
				progressContainer.parent.removeChild(progressContainer);
			}
		}																							
		 
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			addConstructFlag();
			
			this.id = data.id;
			//checkTechnoNeed();
			
			/*setTimeout(function():void { hidePointing(); }, 3000);
			if(sid == 160 || sid == 178)
				showPointing("top", dx, -63);
			else
				showPointing("top", dx, dy);*/
				
				
				
			openConstructWindow();
			//instance = 1;
			/*created = App.time + info.devel.req[1].t;
			App.self.setOnTimer(build);
			addProgressBar();
			addEffect(Building.BUILD);
			*/
		}
		
		public function onAfterBuy(e:AppEvent):void
		{
			if(textures != null){
				var levelData:Object = textures.sprites[this.level];
				removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
				App.ui.flashGlowing(this, 0xFFF000);
			}
			
			hasUpgraded = true;
			hasBuilded = true;
			
			SoundsManager.instance.playSFX('building_1');
		}
		
		override public function onLoad(data:*):void {
			
			super.onLoad(data);
			
			textures = data;
			updateLevel();
			
			setCloudPosition(0, -25);
			if (info.view == "mill")
				setCloudPosition(0, 10);
			if (info.view == "brown_field")
				setCloudPosition(this.width / 3 - this.width / 2, -30);
			if (info.view == "white_field")
				setCloudPosition(this.width / 3 - this.width / 2, -30);
			if (info.view == "barrels1")
				setCloudPosition(this.width / 3 - this.width / 2 + 10, -50);
			if (info.view == "kitchen")
				setCloudPosition(this.width / 3 - this.width / 2 + 50, 0);
			if (info.view == "mine")
				setCloudPosition(this.width / 3 - this.width / 2 + 55, 60);
			if (info.view == "farm_stable")
				setCloudPosition(this.width / 3 - this.width / 2, -10);
			if (info.view == "workshop")
				setCloudPosition(this.width / 3 - this.width / 2, -10);
			if (info.view == "windmill")
				setCloudPosition(this.width / 3 - this.width / 2 + 55, -10);
			if (info.view == "hostess")
				setCloudPosition(this.width / 3 - this.width / 2 + 30, 25);
			if (info.view == "hostess_mini")
				setCloudPosition(this.width / 3 - this.width / 2 + 60, -30);
			if (info.view == "smithy")
				setCloudPosition(this.width / 3 - this.width / 2 + 35, -40);
			if (info.view == "spring")
				setCloudPosition(this.width / 3 - this.width / 2, -60);	
			if (info.view == "quarry")
				setCloudPosition(this.width / 3 - this.width / 2 + 40, -35);
			if (info.view == "plant_lake")
				setCloudPosition(this.width / 3 - this.width / 2 + 70, -35);
			if (info.view == "worker_house_1")
				setCloudPosition(this.width / 3 - this.width / 2 + 25, -35);	
			if (info.view == "worker_house_2")
				setCloudPosition(this.width / 3 - this.width / 2 + 25, -35);	
			if (info.view == "worker_house_3")
				setCloudPosition(this.width / 3 - this.width / 2 + 25, -35);	
			if (info.view == "magic_achives")
				setCloudPosition(this.width / 3 - this.width / 2 + 80, -35);
			if (info.view == "mount_dragon")
				setCloudPosition(this.width / 3 - this.width / 2 + 10, -35);				
				
				var _flag:* = flag;
			if (_flag == "hand") 
				setFlag("hand", isPresent, {target:this, roundBg:true, addGlow:true } );
			else
				flag = _flag;
			
			
			if (App.user.mode == User.GUEST && formed) {
				if (level > totalLevels - craftLevels) {
					initAnimation();
					startAnimation();
				}	
			}
		}
		
		public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (textures == null) return;
			
			
			var levelData:Object;
			if (this.level && info.devel && info.devel.req[this.level].hasOwnProperty("s")) {
				levelData = textures.sprites[info.devel.req[this.level].s];
			}else{
				levelData = textures.sprites[this.level];
			}
			
			if (levelData == null)
				levelData = textures.sprites[0];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			//if(this.level == 0
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0xFFF000)//0x6fefff);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			checkOnAnimationInit();
		}
		
		public function checkOnAnimationInit():void {
			if (level > totalLevels - craftLevels) {
				initAnimation();
				beginAnimation();
			}	
			if (crafted == 0) {
				finishAnimation();
			}
			
			if (_cloud) setCloudCoords();
		}
		
		private var cantClick:Boolean = false;
		public var helpTarget:int = 0;
		override public function click():Boolean {
			
		/*	addEffect(Building.BUILD);
			return false;*/
			
			if (cantClick)
				return false;
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			//var isConstruct:Boolean = true;
			//if (this.info.devel && this.info.devel.craft) {
				//var lvl:int = this.level;
				//if (lvl == 0)
					//lvl = 1;
				//for each(var _sid:* in this.info.devel.craft[this.level]) {
					//isConstruct = false;
					//break;
				//}
			//}else {
				//isConstruct = false;
			//}
			//
			//if (isConstruct)
			//{
				//if (App.user.mode == User.OWNER)
				//{
					//if (hasUpgraded)
					//{
						//openConstructWindow();
						//
						//return true;
					//}
				//}
			//}			
			//Map.createLight( { x:this.x, y:this.y },App.data.storage[sid].preview); 
			
			if (!super.click() || this.id == 0) return false;
			
			if (!isReadyToWork()) return true;
			
			if (isPresent()) return true;
			
			if (isProduct()) return true;
			
			//var isConstruct:Boolean = true;
			//if (this.info.devel && this.info.devel.craft) {
				//var lvl:int = this.level;
				//if (lvl == 0)
					//lvl = 1;
				//for each(var _sid:* in this.info.devel.craft[this.level]) {
					//isConstruct = false;
					//break;
				//}
			//}else if(this.level > 0){
				//isConstruct = false;
			//}
			
			//if (level < totalLevels - craftLevels || level == 0)
			//{
				//if (App.user.mode == User.OWNER)
				//{
					//if (hasUpgraded)
					//{
						if (openConstructWindow()) return true;
						
						//return true;
					//}
				//}
			//}			
			
			openProductionWindow();
			//helpTarget = 0;
			return true;
		}
		
		public function openConstructWindow():Boolean 
		{
			if (level <= totalLevels - craftLevels || level == 0)
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true
						}).show();
						
						return true;
					}
				}
			}
			return false;
		}
		
		private var guestDone:Boolean = false;
		public function guestClick():void 
		{
			if (guestDone) return;
			
			if(App.user.addTarget({
				target:this,
				near:true,
				callback:onGuestClick,
				event:Personage.HARVEST,
				jobPosition:getContactPosition(),
				shortcut:true
			})) {
				ordered = true;
			}else {
				ordered = false;
			}
		}
		
		public function onGuestClick():void {
			if (App.user.friends.takeGuestEnergy(App.owner.id)) {
				
				guestDone = true;
				flag = false;
				
				var that:* = this;
				Post.send({
					ctr:'user',
					act:'guestkick',
					uID:App.user.id,
					sID:this.sid,
					fID:App.owner.id
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return;
					}	
					if (data.hasOwnProperty("bonus")){
						spit(function():void{
							Treasures.bonus(data.bonus, new Point(that.x, that.y));
						},bitmapContainer);
					}
					ordered = false;
					
					if (data.hasOwnProperty('energy')) {												//
						if(App.user.friends.data[App.owner.id].energy != data.energy){					//
							App.user.friends.data[App.owner.id].energy = data.energy;					//
							App.ui.leftPanel.update();													//test
						}																				//
					}																					//
					App.user.friends.giveGuestBonus(App.owner.id);										//
				});
			}else {
				ordered = false;
			}
		}
		
		public function isPresent():Boolean
		{
			if (hasPresent) {
				hasPresent = false;
				
				if(level >= totalLevels - craftLevels + 1)
					makePost();
				
				Post.send({
					ctr:this.type,
					act:'reward',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onBonusEvent);
				
				addConstructFlag();
				return true;
			}
			return false;
			
		}
		
		public function isReadyToWork():Boolean
		{
			var finishTime:int = -1;
			var totalTime:int = -1;
			if (created > 0 && !hasBuilded){ // еще строится
				var curLevel:int = level + 1;
				if (curLevel >= totalLevels) curLevel = totalLevels;
				finishTime = created;
				totalTime = App.data.storage[sid].devel.req[1].t;
			}else if (upgradedTime >0 && !hasUpgraded) { // еще апграйдится
				finishTime = upgradedTime;
				totalTime = App.data.storage[sid].devel.req[level+1].t;
			}	
				
			if(finishTime >0){
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:finishTime,
					totalTime:totalTime
				}).show();
				return false;	
			}		
			
			return true;
		}
		
		public function isProduct(value:int = 0):Boolean
		{
			//return;
			
			if (hasProduct)
			{
				var price:Object = getPrice();
						
				var out:Object = { };
				out[formula.out] = formula.count;
				if (!App.user.stock.checkAll(price) || !App.user.stock.canTake(out))	return true;  // было false
				
				// Отправляем персонажа на сбор
				storageEvent();
				/*App.user.addTarget( {
					target:this,
					near:true,
					callback:storageEvent,
					event:Personage.HARVEST,
					jobPosition: findJobPosition(),
					shortcut:true,
					isPriority:true
				});
				
				ordered = true;*/
				
				return true; 
			}
			return false;
		}
		
		public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			removeEffect();
			if(type != "Trade" && level > totalLevels - craftLevels)
			{
				flag = false;
			}
			//flag = false;
			Treasures.bonus(Treasures.convert(info.devel.rew[level]), new Point(this.x, this.y));
		}
		
		public function showPostWindow():void {
			
			var text:String = 'flash:1382952379896';//Поздравляем! Вы закончили строительство здания!
			
			if (level > 1)
				text = 'flash:1395849886254';//Поздравляем! Вы улучшили здание!
			new SimpleWindow( {
				title:info.title,
				label:SimpleWindow.BUILDING,
				text:Locale.__e("flash:1382952379896"),
				sID:sid,
				ok:(App.social == 'PL')?null:makePost
			}).show();
		}
		
		public function findJobPosition():Object
		{
			var _y:int = -1;
			if (coords.z + _y < 0)
				_y = 0;
				
			var _x:int = int(info.area.w / 2);
			var _direction:int = 0;
			var _flip:int = 0;
				
			return {
				x:_x,
				y:_y,
				direction:_direction,
				flip:_flip
			}		
		}
		
		public function openProductionWindow():void {
			// Открываем окно продукции
			//if (level >= 1)
			//{
			new ProductionWindow( {
				title:			info.title,
				crafting:		info.devel.craft,
				target:			this,
				onCraftAction:	onCraftAction,
				hasPaginator:	true,
				hasButtons:		true,
				find:helpTarget
			}).focusAndShow();
			//}
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
		
		public function setCloudCoords():void        //cloud - готовый продукт над зданием, функция занимается размещением
		{
			if(cloudPositions.hasOwnProperty(info.view)){
				_cloud.y = cloudPositions[info.view].y;
				if (rotate) _cloud.x = cloudPositions[info.view].x + 70;
				else _cloud.x = cloudPositions[info.view].x;
			}
		}
		
		public function onCraftAction(fID:uint):void
		{
			var isBegin:Boolean = true;
			if (queue.length > 0)
				isBegin = false;
			
			addToQueue(fID);
			
			//if (isBegin) {
				beginCraft(fID, App.time + App.data.crafting[fID].time);
			//}else {
				
				//if (technos != null && technos.length > 0 && technos[0].capacity >= 0) {
					//var _technos:Array = Techno.freeTechno();
					//if(_technos.length > 0)
						//_technos[0].workStatus = WorkerUnit.QUEUE;
				//}
				//var technos:Array = Techno.freeTechno();
				//if(technos.length > 0)
					//technos[0].workStatus = WorkerUnit.QUEUE;
			//}
			
			startSmoke();
			if (textures.hasOwnProperty('animation')){
				beginAnimation();
			}
			
			var formula:Object = App.data.crafting[fID];
			for (var sID:* in formula.items){
				App.user.stock.take(sID, formula.items[sID]);
			}
			
			//Делаем push в _6e
			//if (App.social == 'FB') {
				//var out:String = App.data.storage[formula.out].view;
				//ExternalApi._6epush([ "_event", { "event": "gain", "item":out } ]);
			//}
			
			Post.send({
				ctr:this.type,
				act:'crafting',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}, onCraftEvent);
		}
		
		protected function onCraftEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			this.crafted = data.crafted;
		}
		
		protected function addToQueue(fID:int, order:* = null):void {
			// Выбираем самое позднее окончание производства
			var _crafted:int = 0;
			var _order:int = 0;
			for (var i:int = 0; i < queue.length; i++) {
				if (queue[i].crafted > _crafted)
					_crafted = queue[i].crafted;
				
				if (order === null && queue[i].order > _order)
					_order = queue[i].order;
			}
			if (_crafted == 0) _crafted = App.time;
			if (order === null) order = _order;
			
			queue.push( {
				order:		int(order),
				fID:		fID,
				crafted:	_crafted + getFormula(fID).time
			});
		}
		
		public function onBoostEvent(count:int = 0):void {
			
			if (!App.user.stock.take(Stock.FANT, count)) return;
				
				App.self.setOffTimer(production);
				onProductionComplete();
				
				cantClick = true;
				
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
					
					if (data) {
						for (var i:int = 0; i < queue.length; i++) {
							if (crafted == queue[i].crafted) {
								var delta:int = crafted - App.time;
								for (var j:int = 0; j < queue.length; j++) {
									queue[j].crafted -= delta;
								}
								break;
							}
						}
						checkProduction();
						
						cantClick = false;
					}
				
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		public function getPrice():Object
		{
			var price:Object = { }
			price[Stock.FANTASY] = 0;
			return price;
		}
		
		public function storageEvent(value:int = 0):void
		{
			var out:Object = { };
			out[formula.out] = formula.count;
			if (!App.user.stock.canTake(out)){
				ordered = false;
				return;
			}
			hasProduct = false;
					
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);			
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			ordered = false;
			hasProduct = false;
			
			for (var i:int = 0; i < queue.length; i++) {
				if (queue[i].crafted <= App.time) {
					var formula:Object = getFormula(queue[i].fID);
					
					// Удаляем из готовых
					var index:int = completed.indexOf(queue[i].fID);
					if (index >= 0) completed.splice(index, 1);
					
					queue.splice(i, 1);
					i--;
				}
			}
			
			if (data.hasOwnProperty('bonus')) {
				var that:* = this;
					Treasures.bonus(data.bonus, new Point(that.x, that.y));
				if (_cloud)
					_cloud.dispose();
					_cloud = null;
				flag = false;
			}
			
			if(queue.length > 0)
				cloudResource(true, App.data.crafting[queue[0].fID].out, isProduct, 'productBacking2', 0.6, true, queue[0].crafted - App.data.crafting[queue[0].fID].time, queue[0].crafted);
		}
		
		public var needTechno:uint = 0;
		protected function beginCraft(fID:uint, crafted:uint):void
		{
			
			
			if (crafting) {
				var formulaNew:Object = getFormula(fID);
				needTechno = formulaNew.items[164];
				if (needTechno > 0) {
					if(Map.ready)
						rentTechno();
					else
						App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				}	
				return;
			}
			
			formula = getFormula(fID);
			if (crafted == 0) crafted = App.time + formula.time;
			
			this.fID = fID;
			this.crafted = crafted;
			began = crafted - formula.time;
			crafting = true;
			
			App.self.setOnTimer(production);
			
			if (this.type == "Building" && _cloud) {
				if (technos.length == 0) {
					needTechno = formula.items[164];
					if (needTechno > 0) {
						if(Map.ready)
							rentTechno();
						else
							App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
					}	
				}
				return;
			}
			cloudResource(true, formula.out, isProduct, 'productBacking2', 0.6, true, began, crafted);
			needTechno = formula.items[164];
			
			/*this.fID = fID;
			this.crafted = crafted;
			hasProduct = false;
			crafting = true;
			

			formula = App.data.crafting[fID];
			
			for (var _sid:* in formula.items) {
				if (_sid == Techno.TECHNO) {
					needTechno = formula.items[_sid];
					break;
				}
			}	
			
			App.self.setOnTimer(production);
			production();
			
			cloudResource(true, formula.out, isProduct, 'productBacking2', 0.6, true, crafted - formula.time, crafted);
			
			Load.loading(Config.getIcon(App.data.storage[formula.out].type, App.data.storage[formula.out].view), onOutLoad);
			*/
			if (needTechno > 0) {
				if(Map.ready)
					rentTechno()
				else
					App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			}	
		}
		
		public var countLabel:TextField;
		public var title:TextField;
		public var icon:Bitmap = new Bitmap(null, "auto", true);
	//public var popupBalance:Sprite = new Sprite();
		
		protected function onOutLoad(data:*):void {
			
			/*icon.bitmapData = data.bitmapData;
			icon.smoothing = true;
			icon.scaleX = icon.scaleY = 0.34;
			icon.filters = [new GlowFilter(0xf7f2de, 1, 3, 3, 6, 1)];
			
			if (contains(popupBalance)) {
				return;
			}
			
			popupBalance.addChild(icon);
			
			countLabel = Window.drawText("", {
				fontSize:20,
				autoSize:"left",
				color:0x413116,
				borderColor:0xf7f2de,
				borderSize:4,
				distShadow:0
			});
			countLabel.x = (icon.width - countLabel.width) / 2;
			countLabel.y = icon.y + icon.height - 7;
			
			popupBalance.addChild(countLabel);
		
			addChild(popupBalance);
			
			popupBalance.x = bitmap.x + (bitmap.width - popupBalance.width) / 2;
			popupBalance.y = bitmap.y + (bitmap.height - popupBalance.width) / 2;*/
		}
		
		public function set material(toogle:Boolean):void {
			if (countLabel == null) return;
			if (toogle) {
				if(crafted > App.time){
					countLabel.text = TimeConverter.timeToStr(crafted - App.time);
					countLabel.x = (icon.width - countLabel.width) / 2;
				}
			}
			//popupBalance.visible = toogle;
		}
		
		private function resizePopupBalance():void
		{
			/*var scale:Number = 1;
			switch(SystemPanel.scaleMode)
			{
				case 0:	scale = 1; 		break;
				case 1:	scale = 1.3; 	break;
				case 2:	scale = 1.6; 	break;
				case 3:	scale = 2.1; 	break;
			}
			
			var scaleX:Number = scale;
			var scaleY:Number = scale;
			
			if(rotate) scaleX = -scaleX;
			
			popupBalance.scaleY = scaleY;
			popupBalance.scaleX = scaleX;
			
			popupBalance.x = bitmap.x + (bitmap.width - icon.width * scaleX) / 2;
			popupBalance.y = bitmap.height + bitmap.y - 80 - 40*scaleY;*/
		}
		
		protected var timeID:uint;
		protected var anim:TweenLite;
		override public function set touch(touch:Boolean):void {
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))
			{
				return;
			}
			
			super.touch = touch;	
			if (touch) {
				if(Cursor.type == 'default' && crafted && App.user.mode == User.OWNER){
					timeID = setTimeout(function():void{
						material = true;
						//popupBalance.alpha = 0;
						resizePopupBalance();
						//anim = TweenLite.to(popupBalance, 0.2, { alpha:1} );
					},400);
				}
			}else {
				clearTimeout(timeID);
				if(anim){
					anim.complete(true);
					anim.kill();
					anim = null;
				}
				material = false;
			}
		}
		
		protected function production():void
		{
			if (progress) {
				if (textures)
				{
					finishAnimation();
				}
				App.self.setOffTimer(production);
			}
		}
		
		public function get progress():Boolean {
			
			if (fID == 0 || began + formula.time <= App.time)
			{
				onProductionComplete();
				if (queue.length - completed.length <= 0) return true;
			}
			//if (crafted <= App.time)
			//{
				//onProductionComplete();
				//return true;
			//}
			
			if(countLabel != null){
				countLabel.text = TimeConverter.timeToStr(crafted - App.time);
			}
			
			return false;
		}
		
		public function set crafting(value:Boolean):void
		{
			_crafting = value;
		}
		public function get crafting():Boolean
		{
			return _crafting;
		}
		
		public function onProductionComplete():void
		{
			//if (_cloud)_cloud.dispose();
				//_cloud = null;
				
			//if (queue.length > 0)
				//queue.splice(0, 1);
			//
			//hasProduct = true;
			//crafting = false;
			//crafted = 0;
			//flag = "hand";
			//
			//finishAnimation();
			
			if (queue.length == 0 || technos.length > 1) {
				fireTechno(1);
			}else if (queue.length > 0) {
				var counter:int = 0;
				for (var i:int = 0; i < queue.length; i++ ) {
					var product:Object = queue[i];
					if (product.crafted <= App.time) {
						counter++;
					}
				}
				
				if(counter == queue.length)
					fireTechno(1);
			}
			
			checkProduction();
		}
		
		public function upgradeEvent(params:Object, fast:int = 0):void {
			
			if (level  >= totalLevels) {
				return;
			}
			
			var price:Object = { };
			for (var sID:* in params) {
				if (sID == Techno.TECHNO) {
					//needTechno = params[sID];
					//delete params[sID];
					continue;
				}
				price[sID] = params[sID];
			}
			// Забираем материалы со склада
			if (fast == 0)
			{
				if (!App.user.stock.takeAll(price)) return;
			}else {
				if (!App.user.stock.take(Stock.FANT,fast)) return;
				//if (!App.user.stock.takeAll(skipPrice)) return;
			}
		
			if(fast < 1)//if (needTechno > 0)rentTechno();
			checkTechnoNeed(true);
			
			gloweble = true;
			
			//this.level++;           //если что вернуть это, а с upgraded убрать this.level++; и в Factory
			//updateLevel(true);
			//var fast:uint = 0//params[Stock.FANT] || 0;
			//App.self.setOnTimer(upgraded);

			Post.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fast:fast
			},onUpgradeEvent, params);
		}
		
		public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}else {
				//moveable = false;
				hasUpgraded = false;
				hasBuilded = true;
				upgradedTime = data.upgrade;
				App.self.setOnTimer(upgraded);
				addProgressBar();
				addEffect(Building.BUILD);
			}
		}
		
		
		
		public function finishUpgrade():void
		{
			if (level == totalLevels && App.user.mode != User.GUEST)
			{
				new SimpleWindow( {
					title:info.title,
					label:SimpleWindow.BUILDING,
					text:Locale.__e("flash:1382952379896"),
					sID:sid,
					ok:(App.social == 'PL')?null:makePost
				}).show();
				
				//Делаем push в _6e
				//if (App.social == 'FB') {						
					//ExternalApi._6epush([ "_event", { "event": "gain", "item": info.view } ]);
				//}
			}else {
				//Делаем push в _6e
				//if (App.social == 'FB') {						
					//ExternalApi._6epush([ "_event", { "event": "achievement", "achievement": "building_construction" } ]);
				//}
			}
		}
		
		public function acselereatEvent(count:int):void
		{
			if (!App.user.stock.check(Stock.FANT, count)) return;
			
			Post.send( {
				ctr:this.type,
				act:'speedup',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},onAcselereatEvent);
		}
		
		public function onAcselereatEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			var minusFant:int = App.user.stock.count(Stock.FANT) - data[Stock.FANT];
			
			var price:Object = { }
			price[Stock.FANT] = minusFant;
			
			if (!App.user.stock.takeAll(price))	return;
			
			if(!App.user.quests.tutorial)
				Hints.minus(Stock.FANT, minusFant, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			//App.ui.upPanel.update();
			
			
			upgradedTime = data.upgrade;	
			created = data.created;
		}
		
		/*
		 * Изменяем помощников
		 */ 
		public function changeHelpers(role:String, data:String):void
		{
			if (helpers == null) return;
			
			if (data == "rent")
				helpers[role] = 0;
			else if (data == "remove")
				delete helpers[role];
			else
				helpers[role] = data;
		}
		
		
		public function beginAnimation():void 
		{
			if (crafting == true || (textures.animation != null && textures.animation.hasOwnProperty('infinityAnimation') && textures.animation.infinityAnimation))
			{
				startAnimation();
			}
			
			if (crafting == true) 
			{
				if (animationBitmap != null && animationBitmap.visible == false) 
					animationBitmap.visible = true;
					
				startSmoke();
			}
			
			if (animationBitmap != null) {
				if (crafting == true) 
					animationBitmap.visible = true;
				else
				{
					if (info.view == 'firefactory')
						animationBitmap.visible = false;
				}
			}
			
		}
		
		public function finishAnimation():void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (textures && textures.hasOwnProperty('animation'))
			{
				if (textures.animation != null && textures.animation.hasOwnProperty('infinityAnimation') && textures.animation.infinityAnimation)
				{
					stopSmoke();
					return;
				}
				stopAnimation();
				
			}
			
			stopSmoke();
			
			if(animationBitmap != null){
				if (info.view == 'firefactory') 
				{
					animationBitmap.visible = false;
				}
			}
		}
		
		public var isTechnoWork:Boolean = false;
		public var technos:Array = [];
		public function rentTechno(e:AppEvent = null):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, rentTechno);
			
			
			if(needTechno > 0 && (technos.length == 0 || technos[0].capacity >= 0)){
				var bots:Array = Techno.takeTechno(needTechno, this);
				for (var i:int = 0; i < bots.length; i++) {
					var bot:Techno = bots[i].bot;
					technos.push(bot);
					bot.goToJob(this, i);
				}
			}
		}
		
		public function fireTechno(minusCapasity:int = 0):void 
		{
			if(technos.length > 0){
				technos[0].fire(minusCapasity);
				technos.splice(0, 1);
			}
			
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, rentTechno);
			needTechno = 0;
		}
		
		public function getTechnoPosition(id:int = 0):Object 
		{
			var workType:String = Personage.HARVEST;
			var direction:int = 0;
			var flip:int = 0;
			
			if (!crafting){
				workType = Personage.HARVEST;
				direction = 1;
			}
			
			return {
				x:coords.x + info.area.w - 1,
				z:coords.z + int(info.area.h / 2) + 2*id,
				direction:direction,
				flip:flip,
				workType:workType
			}
		}
		
		public function dontCheckTechno():Boolean
		{
			var dontCheck:Boolean = false;
			
			if (crafting)
				dontCheck = true;
			
			for (var i:int = 0; i < technos.length; i++ ) {
				if (technos[i].capacity >= 1) {
					dontCheck = false;
					break
				}
			}
			
			return dontCheck;
		}
		
		override public function moveAction():void 
		{
			super.moveAction();
			
			for (var i:int = 0; i < technos.length; i++ ) {
				technos[i].fire();
				technos[i].goToJob(this);
			}
		}
		
		override public function flip():void {
			super.flip();
			
			if (_cloud) {
				_cloud.scaleX = -_cloud.scaleX;
				setCloudCoords();
			}
			
			if(progressContainer){
				progressContainer.scaleX = this.scaleX;
				
				if (progressContainer.scaleX == -1) {
					progressContainer.x += progressContainer.width/2;
				}else {
					if(progressPositions.hasOwnProperty(info.view)){
						progressContainer.y = progressPositions[info.view].y;
						progressContainer.x = progressPositions[info.view].x;
					}else{
						progressContainer.y = -60;
						progressContainer.x = -40;
					}
				}
			}
				
			
			if (flag != false) {
				if (flag == Cloud.HAND)
					setFlag("hand", isPresent, {target:this, roundBg:true, addGlow:true } );
				else
					flag = _flag;
			}
		}
		
		override public function uninstall():void {
			if (slider && slider.parent) {
				slider.parent.removeChild(slider);
				slider = null;
			}
			
			if (bgProgress && bgProgress.parent) {
				bgProgress.parent.removeChild(bgProgress);
				bgProgress = null;
			}
			
			if (progressContainer && progressContainer.parent) {
				progressContainer.parent.removeChild(progressContainer);
				progressContainer = null;
			}
			
			super.uninstall();
			fireTechno();
		}
		
		public function getContactPosition():Object
		{
			var y:int = -1;
			if (this.coords.z + y < 0)
				y = 0;
				
			return {
				x: int(info.area.w / 2),
				y: y,
				direction:0,
				flip:0
			}
		}	
		
		private var effect:AnimationItem;
		public function addEffect(type:String):void 
		{
			var layer:int = 0;
			if (type == BUILD) {
				effect = new AnimationItem( { type:'Effects', view:type, params:AnimationItem.getParams(type, info.view) } );
				effect.blendMode = BlendMode.HARDLIGHT;
				layer = 1;
			}else if (type == BOOST) {
				effect = new AnimationItem( { type:'Effects', view:type, params:AnimationItem.getParams(type, info.view) } );
			}
			addChildAt(effect, layer);
			var pos:Object = IsoConvert.isoToScreen(int(cells / 2), int(rows / 2), true, true);
			effect.x = pos.x;
			effect.y = pos.y - 5;
		}
		
		public function removeEffect():void {
			if (effect){
				if(effect.parent)effect.parent.removeChild(effect);
				effect.stopAnimation();
				effect.dispose();
			}	
		}
		
		public var cloudPositions:Object = {
			'magic_market':{
				x:-33,
				y:-150
			},
			'quarry':{
				x:-35,
				y:-130
			},
			'brazier':{
				x:-25,
				y:-130
			},
			'burning_torch':{
				x:-25,
				y:-130
			},
			'smeltery':{
				x:-50,
				y:-160
			},
			'clocktower':{
				x:-30,
				y:-270
			},
			'woter_weel':{
				x:-50,
				y:-160
			},
			'brown_field':{
				x:-60,
				y:-100
			},
			'plant_lake':{
				x:0,
				y:-90
			},
			'kitchen':{
				x:-50,
				y:-90
			},
			'workshop':{
				x:-45,
				y:-155
			},
			'windmill':{
				x:-35,
				y:-240
			},
			'well':{
				x:-35,
				y:-150
			},
			'farm_stable':{
				x:-35,
				y:-150
			},
			'smithy':{
				x:-35,
				y:-130
			},
			'mine':{
				x:-35,
				y:-100
			},
			'spring':{
				x:-35,
				y:-100
			},
			'white_field': {
				x:-60,
				y:-100
			},
			'hostess':{
				x:-65,
				y:-140
			},
			'hostess_mini':{
				x:-25,
				y:-140
			},
			'worker_house_1':{
				x:-25,
				y:-100
			},
			'worker_house_2':{
				x:-32,
				y:-180
			},
			'worker_house_3':{
				x:-32,
				y:-180
			},
			'iron_machine':{
				x:-10,
				y:-100
			},
			'gold_crown_jevels':{
				x:-25,
				y:-150
			},
			'gold_jewelery_box':{
				x:-30,
				y:-150
			},
			'gold_nectar_geyser1':{
				x:-25,
				y:-150
			},
			'jewelry':{
				x:-30,
				y:-150
			},
			'gold_yarn_machine':{
				x:-30,
				y:-150
			},
			'gold_yarn_mach':{
				x:-30,
				y:-150
			},
			'spinnery':{
				x:-30,
				y:-150
			},
			'swan':{
				x:-30,
				y:-150
			},
			'vase':{
				x:-30,
				y:-195
			},
			'pottery':{
				x:-30,
				y:-155
			},
			'workshop_sculptor':{
				x:-30,
				y:-155
			},
			'skulptor_fontain':{
				x:-16,
				y:-125
			},
			'skulpture_arc':{
				x:10,
				y:-150
			},
			'library':{
				x:-10,
				y:-185
			},
			'magic_achives':{
				x:-10,
				y:-185
			},
			'magic_tom':{
				x:-25,
				y:-165
			},
			'magic_ball':{
				x:-25,
				y:-165
			},
			'lighthouse':{
				x:50,
				y:-170
			},
			'mount_dragon':{
				x:50,
				y:-170
			},
			'gold_furry':{
				x:-35,
				y:-185
			},
			'fabulous_spring':{
				x:-5,
				y:-155
			},
			'tree_of_life':{
				x:-25,
				y:-195
			},
			'royal_standard':{
				x:-27,
				y:-200
			},
			'blazon':{
				x:-25,
				y:-185
			}
			
			
			//
						//if (info.view == "gold_crown_jevels")
				//setCloudPosition(this.width / 3 - this.width / 2 - 200, -35);	
			//if (info.view == "gold_jewelery_box")
				//setCloudPosition(this.width / 3 - this.width / 2 - 200, -35);
			
			
		}
		
		public var progressPositions:Object = {
			'windmill':{
				x:-44,
				y:-150
			},
			'worker_house_2':{
				x:-40,
				y:-80
			},
			'worker_house_3':{
				x:-40,
				y:-80
			},
			'brown_field':{
				x:-40,
				y:-30
			},
			'plant_lake':{
				x:-20,
				y:-30
			}
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			// return EMPTY;
			if (App.user.quests.tutorial && App.user.quests.currentQID != 11)  {
				
				var _coords:Object = QuestsRules.rightPosition[App.user.quests.currentQID];
				if (coords.x == _coords.x && coords.z == _coords.z)
					return EMPTY;
				else
				{
					if (
						(_coords.x - 2 < coords.x) && (coords.x < _coords.x + 2) &&
						(_coords.z - 2 < coords.z) && (coords.z < _coords.z + 2)
					) {
						coords.x = _coords.x;
						coords.z = _coords.z;
						var node:AStarNodeVO = App.map._aStarNodes[coords.x][coords.z];
						this.x = node.tile.x;
						this.y = node.tile.y;
						return EMPTY;
					}
				}
				
				return OCCUPIED;
			}
			
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (node.b != 0 || node.open == false) {
						return OCCUPIED;
					}
				}
			}
			return EMPTY;
		}
		
		public var craftLevels:int = 0;
		public function setCraftLevels():void
		{
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('craft')) {
				for each(var obj:* in info.devel.craft) {
					craftLevels++;
				}
			}else if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('open')) {
				for each(obj in info.devel.open) {
					craftLevels++;
				}
			}
		}
		
		public function isPhase():Boolean
		{
			var phase:Boolean = true;
			
			if (level > totalLevels - craftLevels) {
				phase = false;
			}
			
			
			return phase;
		}
	}
}
