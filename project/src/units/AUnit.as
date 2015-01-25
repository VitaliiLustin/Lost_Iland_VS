package units
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.Load;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import strings.Strings;
	import ui.Cloud;
	import ui.SystemPanel;
	import units.Unit;
	import wins.SimpleWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class AUnit extends Unit 
	{
		public var framesType:String = "work";
		
		public var framesTypes:Array = [];
		public var multipleAnime:Object = {};
		
		protected var frame:uint = 0;
		protected var frameLength:uint = 0;
		
		private var chain:Object;
		
		public var ax:int = 0;
		public var ay:int = 0;
		
		protected var _cloudY:Number = 0;
		protected var _cloudX:Number = 0;
				
		public var _flag:* = false;
		public var cloud:Cloud = null;
		
		public var loader:Preloader = new Preloader();
		public var hasLoader:Boolean = true;
		
		public function AUnit(object:Object)
		{
			super(object);
			
			if (object.hasOwnProperty('hasLoader'))
			hasLoader = object.hasLoader;
			
			if(hasLoader)
				addChild(loader);
				
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			//return EMPTY;
			if (info.base != null && info.base == 1) 
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						//if (node.b != 0 || node.open == false) {
						if (node.w != 1 || node.object != null || node.open == false) { // 
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
		
		public function onRemoveFromStage(e:Event):void {
			if (animated) {
				stopAnimation();
			}
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		public function onLoad(data:*):void {
			removeChild(loader);
			loader = null;
		}
		
		
		
		public function initAnimation():void {
			framesTypes = [];
			if (textures && textures.hasOwnProperty('animation')) {
				for (var frameType:String in textures.animation.animations) {
					framesTypes.push(frameType);
				}
				addAnimation()
				animate();
				
				/*if (framesTypes.length == 1){
					framesType = framesTypes[0];
					addAnimation();
					animate();
				}else{
					addMultipleAnimation(false, numChildren);
					animateMultiple();
				}*/
			}
		}
		
		public function addAnimation():void
		{
			ax = textures.animation.ax;
			ay = textures.animation.ay;
			
			clearAnimation();
			
			var arrSorted:Array = [];
			for each(var nm:String in framesTypes) {
				arrSorted.push(nm); 
			}
			arrSorted.sort();
			
			for (var i:int = 0; i < arrSorted.length; i++ ) {
				var name:String = arrSorted[i];
				multipleAnime[name] = { bitmap:new Bitmap(), cadr: -1 };
				bitmapContainer.addChild(multipleAnime[name].bitmap);
				
				if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name]['frame'] = 0;
			}
			
			//for each(var name:String in framesTypes) {
				//multipleAnime[name] = { bitmap:new Bitmap(), cadr: -1 };
				//bitmapContainer.addChild(multipleAnime[name].bitmap);
				//
				//if (textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					//multipleAnime[name].bitmap.visible = false;
				//}
				//multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				//multipleAnime[name]['frame'] = 0;
			//}
		}
		
		public function startAnimation(random:Boolean = false):void
		{
			
			if (animated) return;
			
			for each(var name:String in framesTypes) {
				
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				multipleAnime[name].bitmap.visible = true;
				multipleAnime[name]['frame'] = 0;
				if (random) {
					multipleAnime[name]['frame'] = int(Math.random() * multipleAnime[name].length);
				}
			}
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
		public function stopAnimation():void
		{
			
			App.self.setOffEnterFrame(animate);
			animated = false;
			/*for each(var name:String in framesTypes) {
				if (textures.animation.animations[name] != undefined && textures.animation.animations[name]['unvisible'] != undefined && textures.animation.animations[name]['unvisible'] == true) {
					multipleAnime[name].bitmap.visible = false;
				}
			}*/
		}
		
		public function clearAnimation():void {
			stopAnimation();
			if (!SystemPanel.animate) return;
			for (var _name:String in multipleAnime) {
				var btm:Bitmap = multipleAnime[_name].bitmap;
				if (btm && btm.parent)
					btm.parent.removeChild(btm);
			}
		}
		
		override public function animate(e:Event = null):void
		{
			if (!SystemPanel.animate) return;
			
			for each(var name:String in framesTypes) {
				var frame:* 			= multipleAnime[name].frame;
				var cadr:uint 			= textures.animation.animations[name].chain[frame];
				if (multipleAnime[name].cadr != cadr) {
					multipleAnime[name].cadr = cadr;
					var frameObject:Object 	= textures.animation.animations[name].frames[cadr];
					
					multipleAnime[name].bitmap.bitmapData = frameObject.bmd;
					multipleAnime[name].bitmap.smoothing = true;
					multipleAnime[name].bitmap.x = frameObject.ox+ax;
					multipleAnime[name].bitmap.y = frameObject.oy+ay;
				}
				multipleAnime[name].frame++;
				if (multipleAnime[name].frame >= multipleAnime[name].length)
				{
					multipleAnime[name].frame = 0;
				}
			}
		}
		
		
		public function setCloudPosition(dX:Number, dY:Number):void
		{
			_cloudY = dY;
			_cloudX = dX;
			if (cloud != null)
			{
				cloud.y = dy + _cloudY;
				cloud.x = - cloud.width / 2 + _cloudX;
			}
		}
		
		public function set flag(value:*):void {
			
			if (!touchableInGuest && App.user.mode == User.GUEST) return;
			
			_flag = value;
			
			if (cloud != null)
			{
				if(cloud.parent)cloud.parent.removeChild(cloud);
				cloud = null;
			}
			
			if (_flag)
			{
				cloud = new Cloud(_flag, null, _rotate);
				cloud.y = dy + _cloudY;
				cloud.x = - cloud.width / 2 + _cloudX;
				addChild(cloud);
			}
		}
		
		public function setFlag(value:*, callBack:Function = null, settings:Object = null):void {
			
			if (!touchableInGuest && App.user.mode == User.GUEST) return;
			
			_flag = value;
			
			if (cloud != null)
			{
				if (cloud.parent) cloud.parent.removeChild(cloud);
				cloud.dispose();
				cloud = null;
			}
			
			if (_flag)
			{
				cloud = new Cloud(_flag, settings, _rotate, callBack);
				cloud.y = dy + _cloudY;
				cloud.x = - (cloud.bg.width) / 2 + _cloudX + 12;
				addChild(cloud);
			}
		}
		
		public function get flag():* {
			return _flag;
		}
		
		public var smoke_animated:Boolean = false;
		public var smokeAnimations:Array = [];
		public function startSmoke():void {
			smoke_animated = true;
			if (smokeAnimations.length > 0) {
				for each(var anime:Anime in smokeAnimations) {
					anime.startAnimation(true);
					anime.alpha = 1;
					addChild(anime);
				}
			}else{
				if (textures.hasOwnProperty('smokePoints')) {
					
					Load.loading(Config.getSwf('Smoke', 'smoke'), function(data:*):void {
						var animation:Object = data;
						
						
						for each(var point:Object in textures.smokePoints) {
							var anime:Anime = new Anime(animation, 'smoke', point.dx + 28, point.dy + 58, point.scale || 1);
							anime.startAnimation(true);
							anime.alpha = 1;
							addChild(anime);
							smokeAnimations.push(anime);
						}
						
						if (smoke_animated == false)
							stopSmoke();
					});
					
				}
			}
		}
		
		public function stopSmoke():void {
			smoke_animated = false;
			if (info.view == 'mine'){
				trace('stopSmoke ' + info.view + " " + id);
			}	
			if (smokeAnimations.length == 0) return;
			
			for each(var anime:Anime in smokeAnimations) {
				anime.stopAnimation();
				if(this.contains(anime)) removeChild(anime);
			}
			
		}
		
		public function makePost(e:* = null):void
		{
			if (App.user.quests.tutorial || App.self.stage.displayState == StageDisplayState.FULL_SCREEN || App.self.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
				return;

			//var message:String = Strings.__e('AUnit_makePost',[App.data.storage[sid].title, Config.appUrl]);
			//var back:Sprite = new Sprite();
			//var front:Sprite = new Sprite();
			//
			//var _bitmap:Bitmap = new Bitmap(Zone.snapClip(bitmapContainer, 2));
			//_bitmap.scaleX = _bitmap.scaleY = 0.8;
			//_bitmap.smoothing = true;
			//back.addChild(_bitmap);
			//_bitmap.x = -_bitmap.width / 2;
			//
			//var gameTitle:Bitmap = new Bitmap(Window.textures.logo, "auto", true);
			//back.addChild(gameTitle);
			//gameTitle.x = -gameTitle.width/2;
			//gameTitle.y = _bitmap.height - 34;
			//
			//var cont:Sprite = new Sprite();
			//cont.addChild(back);
			//back.x = back.width / 2;
			//
			//var bmd:BitmapData = new BitmapData(cont.width, cont.height, false);
			//bmd.draw(cont);
			//back = null;
			//cont = null;
			//
			//App.self.addChild(new Bitmap(bmd));
			//ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(bmd), App.user.id, message, sid);
			
			WallPost.makePost(WallPost.BUILDING, { sid:sid } ); 
		}
		
	}
	
}