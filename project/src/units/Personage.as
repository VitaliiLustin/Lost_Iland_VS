package units 
{
	import com.greensock.TweenLite;
	import core.IsoTile;
	import core.Load;
	import flash.display.Bitmap;
	import flash.filters.GlowFilter;
	import flash.utils.setTimeout;
	import ui.Cloud;
	import ui.UserInterface;
	
	public class Personage extends WUnit
	{
		public static const E:int = 0;
		
		public var level:uint = 3;
		
		public var cloud:Cloud;
		public var _flag:* = false;
		public var prevFlag:* = false;
		public var shadow:Bitmap;
		public var preloader:Bitmap = null;
		
		
		public static const BEAR:uint 			= 49;
		public static const BEAVER:uint 		= 622;
		public static const PANDA:uint 			= 390;
		public static const BOOSTER:uint 		= 431;
		public static const HERO:uint			= 8;
		public static const CONDUCTOR:uint		= 457;
		
		public static const SOW:String 		= "sow";
		public static const DIG:String 		= "dig";
		public static const REST:String 	= "rest";
		public static const WALK:String 	= "walk";
		public static const HARVEST:String 	= "harvest";
		public static const STOP:String 	= "stop_pause";
		public static const WORK:String 	= "work";
		public static const BUILD:String 	= "build";
		
		
		private var loaderCoords:Object = {
			'man':{x:-15,y:-100},
			'woman': { x: -18, y: -100 }
		}
		
		public function Personage(object:Object, view:String = '')
		{
			if (object.layer)
				layer = object.layer;
			else
				layer = Map.LAYER_SORT
			
			super(object);
			
			rotateable = false;
			transable = false;
			moveable = false;
			flyeble = true;
			
			if (view !== '') {
				info.view = view;
			}
			
			if(UserInterface.textures.hasOwnProperty(info.view)){
				preloader = new Bitmap(UserInterface.textures[info.view])
				preloader.x = loaderCoords[info.view].x;
				preloader.y = loaderCoords[info.view].y;
			}
			load();
		}
		
		public function load():void
		{
			if (preloader) addChild(preloader);
			Load.loading(Config.getSwf(info.type, info.view), onLoad);
		}
		
		public function onLoad(data:*):void 
		{
			textures = data;
			getRestAnimations();
			addAnimation();
			createShadow();
			
			if (preloader) {
				TweenLite.to(preloader, 0.5, { alpha:0, onComplete:removePreloader } );
			}
		}
		
		public function removePreloader():void
		{
			if (preloader) 
				removeChild(preloader);
			preloader = null;
		}
		
		public function onPathToTargetComplete():void
		{
			
		}
		
		public function onStop():void
		{
			
		}
		
		public var defaultStopCount:uint = 5;
		private var stopCount:uint = defaultStopCount;
		private var restCount:uint = 0;
		override public function onLoop():void
		{	
			if (_framesType == STOP){
				stopCount--;
				if (stopCount <= 0){
					setRest();
				}	
			}else if (rests.indexOf(_framesType) != -1) {
				restCount --;
				if (restCount <= 0){
					stopCount = generateStopCount();
					framesType = STOP;
				}
			}else {
				stopCount = defaultStopCount;
			}
		}
		
		public function setRest():void {
			var randomID:int = int(Math.random() * rests.length);
			var randomRest:String = rests[randomID];
			restCount = generateRestCount();
			framesType = randomRest;
			startSound(randomRest);
		}
		
		public function startSound(type:String):void {
			
		}
		
		public function generateStopCount():uint {
			return int(Math.random() * 5) + 5;
		}
		public function generateRestCount():uint {
			return 1;// int(Math.random() * )
		}
				
		public function set flag(value:*):void {
			
			if (cloud != null)
			{
				removeChild(cloud);
				cloud = null;
			}
				
			_flag = value;
			
			if (_flag)
			{
				if (sid == Personage.BEAR){
					cloud = new Cloud(_flag, { view:'jam' } );
					cloud.y = -140;
				}else{
					cloud = new Cloud(_flag, { view:'fish' } );
					cloud.y = -75;
				}	
					
				addChild(cloud);
				cloud.x = - cloud.width / 2;
			}
		}
		public function get flag():* {
			return _flag;
		}
		
		public function createShadow():void {
			if (shadow) {
				removeChild(shadow);
				shadow = null;
			}
			info
			if (textures && textures.animation.hasOwnProperty('shadow')) {
				shadow = new Bitmap(UserInterface.textures.shadow);
				addChildAt(shadow, 0);
				shadow.smoothing = true;
				shadow.x = textures.animation.shadow.x - (shadow.width / 2);
				shadow.y = textures.animation.shadow.y - (shadow.height / 2);
				shadow.alpha = textures.animation.shadow.alpha;
				shadow.scaleX = textures.animation.shadow.scaleX;
				shadow.scaleY = textures.animation.shadow.scaleY;
			}
		}
		
		override public function get bmp():Bitmap {
			if (bitmap.bitmapData && bitmap.bitmapData.getPixel(bitmap.mouseX, bitmap.mouseY) != 0)
				return bitmap;
			if (multiBitmap && multiBitmap.bitmapData && multiBitmap.bitmapData.getPixel(multiBitmap.mouseX, multiBitmap.mouseY) != 0)
				return multiBitmap;
				
			return bitmap;
		}
		
		override public function set state(state:uint):void {
			if (_state == state) return;
			
			switch(state) {
				case OCCUPIED: bitmap.filters = [new GlowFilter(0xFF0000,1, 6,6,7)]; break;
				case EMPTY: bitmap.filters = [new GlowFilter(0x00FF00,1, 6,6,7)]; break;
				case TOCHED: bitmap.filters = [new GlowFilter(0xFFFF00,1, 6,6,7)]; break;
				case HIGHLIGHTED: bitmap.filters = [new GlowFilter(0x88ffed,0.6, 6,6,7)]; break;
				case IDENTIFIED: bitmap.filters = [new GlowFilter(0x88ffed,1, 8,8,10)]; break;
				case DEFAULT: bitmap.filters = []; break;
			}
			_state = state;
		}
		
		override public function uninstall():void {
			if (tm != null) {
				tm.dispose();
			}
			
			stopWalking();
			super.uninstall();
		}
		
		private var rests:Array = [];
		public function getRestAnimations():void {
			for (var animType:String in textures.animation.animations)
				if (animType.indexOf('rest') != -1)
					rests.push(animType);
		}
		
		public function beginLive():void {
			
		}
		public function stopLive():void {
			
		}
		
	}
}
