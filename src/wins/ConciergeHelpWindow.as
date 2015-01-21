package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class ConciergeHelpWindow extends Window
	{
		private var bttn:Button;
		
		public function ConciergeHelpWindow(settings:Object = null) 
		{
			settings['title'] = settings.title;
			settings['width'] = 500;
			settings['height'] = 310;
			settings['popup']  = true;
			settings['hasPaginator']  = false;
			settings['background'] = 'questsSmallBackingTopPiece';
			
			super(settings);
			
		}
		
		override public function drawBody():void
		{
			exit.y -= 10;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			drawMirrowObjs('storageWoodenDec',12, settings.width - 12, settings.height - 120);
			
			var icon1:Bitmap = new Bitmap(Window.textures.doorMan3);
			icon1.x = - icon1.width/2 + 20;
			icon1.y = -145;
			bodyContainer.addChild(icon1);
			
			var icon2:Bitmap = new Bitmap(Window.textures.moneymanBig);
			icon2.x = settings.width -  icon1.width/2 - 30;
			icon2.y = settings.height - 210;
			bodyContainer.addChild(icon2);
			
			var txtInfo1:TextField = Window.drawText(Locale.__e("flash:1410423986359"), {
				fontSize:26,
				textLeading:2,
				color:0x65371b,
				borderColor:0xeed3a4,
				multiline:true,
				textAlign:"center"
			});
			txtInfo1.wordWrap = true;
			txtInfo1.width = 330;
			txtInfo1.height = txtInfo1.textHeight + 10;
			bodyContainer.addChild(txtInfo1);
			txtInfo1.x = 130;
			txtInfo1.y = 6;
			
			var separator:Bitmap = Window.backingShort(310, 'divider');
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			separator.x = (settings.width - separator.width)/2;
			separator.y = 110;
			
			var txtInfo2:TextField = Window.drawText(Locale.__e("flash:1410424020110"), {
				fontSize:26,
				textLeading:2,
				color:0x65371b,
				borderColor:0xeed3a4,
				multiline:true,
				textAlign:"center"
			});
			txtInfo2.wordWrap = true;
			txtInfo2.width = 330;
			txtInfo2.height = txtInfo2.textHeight + 10;
			bodyContainer.addChild(txtInfo2);
			txtInfo2.x = 40;
			txtInfo2.y = 140;
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380298"),
				fontSize:26,
				width:154,
				height:45
			};
			
			bttn = new Button(bttnSettings);
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 20;
			bodyContainer.addChild(bttn);
			
			bttn.addEventListener(MouseEvent.CLICK, close);
		}
		
		override public function close(e:MouseEvent = null):void
		{
			bttn.removeEventListener(MouseEvent.CLICK, close);
			bttn.dispose();
			bttn = null;
			
			super.close(e);
		}
		
		
	}

}