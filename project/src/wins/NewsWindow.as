package wins 
{
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Hut;
	import units.Pigeon;

	public class NewsWindow extends Window
	{
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var okBttn:Button;
		private var descriptionLabel:TextField;
		
		public function NewsWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			action = settings['news'];
			settings['width'] = 457;
			settings['height'] = 329;
			var text:String = Locale.__e(action.description);
			
			text = text.replace(/\r/g, '');
						
			descriptionLabel = drawText(text, {
				fontSize:28,
				autoSize:"left",
				textAlign:"left",
				color:0x65371b,
				borderColor:0xffffff,
				border:false,
				multiline:true
			});
			
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = 380;
			descriptionLabel.height = descriptionLabel.textHeight;
			descriptionLabel.y = 220;
			descriptionLabel.x = 50;
			
			if (descriptionLabel.numLines > 5)
			{
				var delta:int = (descriptionLabel.numLines - 5) * 30;
				settings['height'] = 400 + delta;
			}
						
			settings['title'] = action.title;
			settings['hasExit'] = false;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 4;
			
			super(settings);
		}
		
		override public function drawBackground():void {
			
			//var background:Bitmap = backing(settings.width, settings.height, 45, "questsSmallBackingTopPiece");
			//layer.addChild(background);
		}
		
		
		override public function drawBody():void {
			
			var heightBgTxt:int = descriptionLabel.height + 40;
			var heightWin:int = heightBgTxt + 145;
			
			background = backing(settings.width, heightWin, 45, "questBacking"/*, "questsSmallBackingBottomPiece"*/);
			layer.addChild(background);
			bg = Window.backing(settings.width - 22, heightWin - 105, 30, 'dialogueBacking');
			bg.x = (settings.width - bg.width) / 2;
			bg.y = (settings.height - bg.height) / 2;
			bodyContainer.addChild(bg);
			
						
			background.y += 95;
			bg.y += 95;
			
			bodyContainer.addChild(titleLabel);
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = bg.y - titleLabel.height/2 + 5;
			
			descriptionLabel.y = bg.y + 30;
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, titleLabel.y + 10, true, true);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, background.y + 75, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -5, settings.width + 5, background.y + background.height - 70);
			
			bodyContainer.addChild(descriptionLabel);
			drawImage();
			
			okBttn = new Button( {
				caption:Locale.__e('flash:1382952380228'),
				fontSize:34,
				width:170,
				height:54,
				hasDotes:false
			});
				
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = background.y + background.height - 50;
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
		}
		
		private function onOkBttn(e:MouseEvent):void {
			
			close();
			new ShopWindow( { section:100, page:0 } ).show();
			//Pigeon.pigeon.parent.removeChild(Pigeon.pigeon);
			Pigeon.dispose();
		}
		
		private var preloader:Preloader = new Preloader();
		private var background:Bitmap;
		private var bg:Bitmap;
		private function drawImage():void {
			
			bodyContainer.addChild(preloader);
			preloader.x = (settings.width )/ 2;
			preloader.y = 50;
			
			Load.loading(Config.getImageIcon('updates/images', action.preview), function(data:Bitmap):void {
				
				bodyContainer.removeChild(preloader);
				
				var image:Bitmap = new Bitmap(data.bitmapData);
				bodyContainer.addChildAt(image,0);
				image.x = (settings.width - image.width) / 2;
				image.y = -image.height + 195;
				bodyContainer.addChild(titleLabel);
			});
		}
	}
}