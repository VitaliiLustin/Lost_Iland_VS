package units 
{
	import astar.AStarNodeVO;
	import core.Post;
	import ui.Cursor;
	/**
	 * ...
	 * @author 
	 */
	public class Fake extends Decor
	{
		
		public function Fake(object:Object) 
		{
			super(object);
			moveable = false;
			clickable = false;
			touchable = false;
			removable = false;
			rotateable = false;
			stockable = false;
			
			switch(sid) {
				case 276:
				case 277:
				case 297:
					moveable = true;
					removable = true;
					clickable = true;
					touchable = true;
					rotateable = true;
					stockable = true;
					break;
			}
			
			
		}
		
		override public function onLoad(data:*):void {
			var level:int = 0;
			if (sid == 275 && App.user.world.zones.indexOf(182) != -1) {
				level = 1;
			}
			
			textures = data;
			var levelData:Object = textures.sprites[level];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
			
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			return EMPTY;
		}
		
		override public function buyAction():void 
		{
			Post.send( {
				ctr:this.type,
				act:'buy',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}, onBuyAction);
		}
		
		/*override public function set touch(touch:Boolean):void 
		{
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))
				//(!touchableCursor.type == 'default')
			{
				return;
			}
			
			super.touch = touch;
		}*/
	}
}