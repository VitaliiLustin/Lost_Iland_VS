package ui
{
	import buttons.ContextBttn;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import wins.Window;
	
	public class ContextMenu extends Sprite 
	{
		
		public var content:Array = [];
		public static var self:*;
		
		public function ContextMenu(content:Array):void
		{
			self = this;
			this.content = content;
			
			create();
			
			App.self.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public function create():void
		{
			var X:int = 0;
			var Y:int = 0;
			
			for each(var obj:Object in content)
			{
				if (obj.icon == null) 
					obj.icon = new BitmapData(1, 1, true, 0x00000000);
				
				var contextBttn:ContextBttn = new ContextBttn( { 
					callback:obj.callback, 
					caption:obj.caption, 
					icon:obj.icon, 
					params:obj.params || { },
					width:obj.width || 120,
					height:obj.height || 32
				});
				
				contextBttn.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
				obj.contextBttn = contextBttn;
				contextBttn.y = Y;
					
				addChild(contextBttn);	
				Y += contextBttn.height;
			}
		}
		
		public function onMouseDown(e:MouseEvent):void
		{
			if(!(e.target.parent is SystemPanel)){
				dispose();
			}
		}
		
		public function onClick(e:MouseEvent):void
		{
			if (App.user.quests.lockWhileMove) {
				return;
			}
			
			e.currentTarget.settings.callback(e.currentTarget.settings.params);
			dispose();
		}
		
		public function show():void
		{
			this.x = App.self.mouseX + 10;
			this.y = App.self.mouseY - 10;
			App.ui.addChild(this);
		}
		
		public function dispose():void
		{
			App.self.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			for each(var obj:Object in content)
			{
				obj.contextBttn.removeEventListener(MouseEvent.MOUSE_DOWN, obj.callback);
				removeChild(obj.contextBttn);	
			}
			
			App.ui.removeChild(this);
			content = [];
			self = null;
		}
		
		public static function hide():void
		{
			//if(self)
		}
	}
}