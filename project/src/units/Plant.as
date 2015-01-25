package units 
{
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Plant extends Bitmap{
		
		private var _level:uint = 0;
		public var field:Field;
		public var info:Object;
		public var sid:uint = 0;
		public var planted:int = 0;
		public var type:String = "Plant";
		public var textures:Object;
		
		public var levelData:Object;
		public var glowed:Boolean = false;
		
		public var layer:String = Map.LAYER_SORT;
		
		override public function get parent():DisplayObjectContainer
		{
			return field;
		}
		
		public function Plant(object:Object)
		{
			sid = object.sid;
			planted = object.planted;
			
			info = App.data.storage[this.sid];
			field = object.field;
			name = 'plant';
			this.x = field.x;
			this.y = field.y;
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		public function onRemoveFromStage(e:Event):void {
			App.self.setOffTimer(growth);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		public function get index():int {
			return field.index;
		}
		
		public function set index(index:int):void {
			field.index = index;
		}
		
		public function get depth():int {
			return field.depth;
		}
		
		public function glowing():void {
			glowed = true; 
			var that:Plant = this;
			TweenMax.to(this, 0.8, { glowFilter: { color:0xFFFF00, alpha:1, strength: 6, blurX:15, blurY:15 }, onComplete:function():void {
				TweenMax.to(that, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 4, blurX:6, blurY:6 }, onComplete:function():void {
					that.filters = [];
					glowed = false;
				}});	
			}});
		}
		
		
		public function growth():void {
			if (level >= info['levels']) {
				App.self.setOffTimer(growth);
			}
		}
		
		public function get level():uint {
			var grownTime:int;
			//var s:int = App.time-planted;
			var currentLevel:uint = int((App.time - planted) / info.levelTime);
			
			if (_level != currentLevel) {
				_level = currentLevel > info.levels ? info.levels : currentLevel;
				updateLevel();
			}
			return _level;
		}
		
		public function set level(level:uint):void {
			_level = level;
		}
		
		public function get ready():Boolean {
			return _level == info.levels;
		}
		
		private function onLoad(data:*):void {
			
			textures = data;
			if(level < info['levels']){
				App.self.setOnTimer(growth);
			}
			updateLevel();
		}
		
		private function updateLevel():void {
			levelData = textures.sprites[_level];
			bitmapData = levelData.bmp;
			x = levelData.dx + field.x;
			y = levelData.dy + field.y;
		}
	}
}