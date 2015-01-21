package ui 
{
	
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
    import flash.ui.Mouse;
    import flash.ui.MouseCursorData;
    import flash.geom.Point;
    import flash.display.BitmapData;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author 
	 */
	public class Cursor 
	{
		private static var _type:String = "default";
		
		private static var cursorBitmapData:BitmapData;
		private static var cursorData:MouseCursorData;
		private static var cursorVector:Vector.<BitmapData> = new Vector.<BitmapData>();
		
		private static var types:Array = [ ];
		private static var icon:Bitmap = new Bitmap();
		
		public static var prevType:String = "default";
		public static var toStock:Boolean = false;
		
		//private static var effect:MovieClip = new clickEffect();
		
		public static function init():void
		{
			_type = prevType;//"default";
			
			types = [ 
					{type:"default", 		bmd:UserInterface.textures.cursorDefault},
					{type:"reset", 			bmd:UserInterface.textures.cursorDefault},
					{type:"move", 			bmd:UserInterface.textures.cursorMove},
					{type:"remove", 		bmd:UserInterface.textures.cursorRemove},
					{type:"locked", 		bmd:UserInterface.textures.cursorLocked},
					{type:"stock", 			bmd:UserInterface.textures.cursorStock },
					{type:"rotate", 		bmd:UserInterface.textures.cursorRotate},
					{type:"woodCollect", 	bmd:UserInterface.textures.cursorWoodCollect},
					{type:"buildingIn", 	bmd:UserInterface.textures.cursorBuildingIn},
					{type:"stoneCollect", 	bmd:UserInterface.textures.cursorStoneCollect},
					{type:"take", 			bmd:UserInterface.textures.cursorTake},
					{type:"water", 			bmd:UserInterface.textures.cursorWaterDrop}
				];
			
			for (var i:String in types)
			{
				cursorVector[0] = types[i].bmd;
				
				cursorData = new MouseCursorData();
				cursorData.hotSpot = new Point(1, 1);
				cursorData.data = cursorVector;
             
				Mouse.registerCursor(types[i].type, cursorData);
			}
			
			Mouse.cursor = _type;
		}
		
		public static function get type():String
		{
			return _type
		}
		
		public static function set type(type:String):void
		{
			try {
				if(type == "locked" && _type != "locked")
					prevType = _type;
				else if(prevType == "locked")	
					prevType = "default";
				
				if (type != "locked")
					prevType = type;	
					
				
				_type = type;
				Mouse.cursor = _type;
			}catch (e:Error) {
				
			}
		}
		
		public static function set plant(value:*):void
		{
			if (icon.bitmapData) {
					App.self.setOffEnterFrame(move);
					App.self.contextContainer.removeChild(icon);
					icon.bitmapData = null;
			}
			
			if (value)
			{
				//icon = new Bitmap();
				Load.loading(Config.getIcon("Material", App.data.storage[value].preview),
					
					function(data:Bitmap):void
					{
						icon.bitmapData = data.bitmapData;
						icon.scaleX = icon.scaleY = 0.5;
						icon.smoothing = true;
					}
				);
					
				App.self.contextContainer.addChild(icon);
				App.self.setOnEnterFrame(move);
			}
		}
		
		public static function get plant():* {
			return icon.bitmapData == null ? null : icon;
		}
		
		private static var _loading:Boolean = false;
		private static var preloader:Preloader = new Preloader();
		public static function set loading(loading:Boolean):void {
			if (_loading == loading) return;
			
			if (loading) {
				preloader.scaleX = preloader.scaleY = 0.7;
				App.self.contextContainer.addChild(preloader);
				App.self.setOnEnterFrame(moveLoader);
			}else{
				App.self.setOffEnterFrame(moveLoader);
				App.self.contextContainer.removeChild(preloader);
			}
			_loading = loading;
		}
		
		public static function get loading():Boolean {
			return _loading;
		}
		
		private static function moveLoader(e:Event = null):void {
			preloader.x = App.self.mouseX;
			preloader.y = App.self.mouseY;
		}
		
		private static function move(e:Event = null):void
		{
			icon.x = App.self.mouseX;
			icon.y = App.self.mouseY;
		}
		
		public static function click():void
		{
			//new Click();
		}
	}
}
/*import flash.events.Event;

internal class Click extends clickEffect
{
	public function Click()
	{
		App.self.addChild(this);
		this.x = App.self.mouseX;
		this.y = App.self.mouseY;
		
		addEventListener(Event.ENTER_FRAME, check);
	}
	
	private function check(e:Event):void
	{
		if (this.currentFrame == this.totalFrames) {
			removeEventListener(Event.ENTER_FRAME, check);
			remove();
		}
	}
	
	private function remove():void
	{
		App.self.removeChild(this);
	}
}*/
  