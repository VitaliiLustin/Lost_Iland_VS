package wins.elements 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Techno;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class PriceLabelShop extends Sprite
	{
		public var icon:Bitmap;
		public var text:TextField;
		
		private var num:int = 0;
		
		public function PriceLabelShop(price:Object) 
		{
			if (price == null) return;
			var count:int = 0;
			
			for (var sID:* in price) {
				count = price[sID];
			
				if (sID == null) return;
				switch(sID) {
					case Stock.COINS:
						icon = new Bitmap(UserInterface.textures.coinsIcon, "auto", true);
						icon.height = 24;
						break;
					case Stock.FANT:
						icon = new Bitmap(UserInterface.textures.fantsIcon, "auto", true);
						icon.height = 24;
						break;	
					case Stock.FANTASY:
						icon = new Bitmap(UserInterface.textures.energyIcon, "auto", true);
						icon.height = 20;
						break;	
					case Techno.TECHNO:
						continue;
						break;	
				}
				
				addChild(icon);
				
				var settings:Object = {
						fontSize:20,
						autoSize:"left",
						color:0xffdc39,
						borderColor:0x6d4b15
					}
					
				if (sID == Stock.FANT)
				{
					settings["color"]	 	= 0xfcb3c4;
					settings["borderColor"] = 0x9b1457;
				}
				
				if (sID == Stock.FANTASY)
				{
					settings["color"]	 	= 0xfefdcf;//0xfebde8;
					settings["borderColor"] = 0x775002;//0x9b174b;
				}
				
				text = Window.drawText(String(count), settings);
				
				addChild(text);
				text.height = text.textHeight;
				
				
				icon.scaleX = icon.scaleY;
				icon.smoothing = true;
				
				icon.x = 6;
				icon.y = 0 - (icon.height +2) * num;
				
				text.x = icon.width + 8;
				text.y = icon.height / 2 - text.textHeight / 2 - (text.height-2) * num;
				
				num++;
				
			}
		
			if (num == 1) {
				icon.y -= 20;
				text.y -= 20;
			}
		}
		
		public function getNum():int
		{
			return num;
		}
		
	}

}