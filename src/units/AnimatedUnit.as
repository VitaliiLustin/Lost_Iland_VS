package units 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.Event;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class AnimatedUnit extends AUnit 
	{
		private var imageData:Object;
		
		public function AnimatedUnit(settings:Object = null) 
		{
			super(settings);
			Load.loading(Config.getSwf(settings.type, settings.view), onLoad);
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			textures = data; 
			imageData = textures.sprites[0];
			draw(imageData.bmp, imageData.dx, imageData.dy);
			initAnimation();
			beginAnimation();
		}
		
		private function beginAnimation():void 
		{
			if(textures && textures.animation != null && !animated)
				startAnimation();
		}
		
	}

}