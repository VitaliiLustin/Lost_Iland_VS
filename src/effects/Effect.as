package effects
{
	import core.IsoConvert;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class Effect extends Sprite
	{
		private var content:*;
		private var layer:*;
		public function Effect(type:String, layer:Sprite, info:Object = null)
		{
			this.layer = layer;
			this.layer.addChild(this);
			
			switch(type)
			{
				case "OrbitalMagic":
						content = new OrbitalMagic(0.2, 360);
					break;
				case "FlashLight":
						content = new FlashLight(info);
					break;
				case "Sparks":
						content = new Sparks();
					break;	
				
			}
			
			if(content != null)
				addChild(content);
		}
		
		public function dispose():void {
			if (content != null) {
				content.dispose();
				removeChild(content);
			}
				
			if (layer is DisplayObject && layer.contains(this))
				layer.removeChild(this); 
				
			content = null;	
		}
	}
}