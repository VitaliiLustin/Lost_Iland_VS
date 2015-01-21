package units
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import ui.ContextMenu;
	import ui.Cursor;
	import ui.Hints;
	import wins.SimpleWindow;
	
	public class Decor extends AUnit{

		public function Decor(object:Object)
		{
			layer = Map.LAYER_SORT;
			if (App.data.storage[object.sid].dtype == 1)
				layer = Map.LAYER_LAND;
			
			object['hasLoader'] = false;
			super(object);
			
			touchableInGuest = false;
			multiple = true;
			stockable = true;
			
			//transable = false;
			//if (info.view == 'cloudlet')
				
			
			Load.loading(Config.getSwf(type, info.view), onLoad);
			
			if(!formed) addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			};
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		override public function initAnimation():void {
			framesTypes = [];
			if (textures && textures.hasOwnProperty('animation')) {
				for (var frameType:String in textures.animation.animations) {
					framesTypes.push(frameType);
				}
				addAnimation();
				startAnimation(true);
			}
		}
		
		override public function take():void {
			if (info.dtype == 0) super.take();
		}
		override public function free():void {
			if (info.dtype == 0) super.free();
		}
		
		public function onAfterBuy(e:AppEvent):void
		{
			removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			App.user.stock.add(Stock.EXP, info.experience);
			if(App.data.storage[sid].experience > 0)Hints.plus(Stock.EXP, App.data.storage[sid].experience, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			
			//if (App.social == 'FB') {						
				//ExternalApi._6epush([ "_event", { "event": "gain", "item": "decoration" } ]);
			//}
		}
		
		override public function onLoad(data:*):void {
			textures = data;
			var levelData:Object = textures.sprites[0];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
			
		}
		
		override public function set touch(touch:Boolean):void {
			if (Cursor.type == 'default' || Cursor.type == 'locked') {
				return;
			}
			super.touch = touch;
		}
		
		override public function click():Boolean {
			
			if (!super.click()) return false;
			
			return true;
		}
		
		private function onContextClick():void
		{
			trace("onContextClick");
		}
		
		override public function buyAction():void {
			//Hints.plus(Stock.EXP, info.experience, new Point(this.x*App.map.scaleX + App.map.x, this.y*App.map.scaleY + App.map.y),true);
			//App.user.stock.add(Stock.EXP, info.experience);
			super.buyAction();
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			if (info.dtype == 1)
			{
				for (var i:uint = 0; i < cells; i++) {
					for (var j:uint = 0; j < rows; j++) {
						node = App.map._aStarNodes[coords.x + i][coords.z + j];
						if (node.b != 0 || node.open == false)
						{
							if (node.object && !(node.object is Resource))
									return EMPTY;
							
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
	}
}