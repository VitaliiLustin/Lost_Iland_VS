package wins 
{
	import buttons.MoneyButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class SpeedWindow extends Window
	{
		private var progressBar:ProgressBar;
		
		private var finishTime:int;
		private var leftTime:int;
		
		private var isBoost:Boolean;
		
		private var timer:TextField;
		
		public var boostBttn:MoneyButton;
		
		private var totalTime:int;
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		
		private var priceKoef:int;
		
		public function SpeedWindow(settings:Object = null) 
		{
			settings["width"] = 490;
			settings["height"] = 192;
			settings["fontSize"] = 38,	
			settings["hasPaginator"] = false;
			
			finishTime = settings.finishTime;
			totalTime = settings.totalTime;
			
			super(settings);	
			
			if (settings.hasOwnProperty('speedKoef'))
				priceKoef = App.data.options['SpeedUpPrice']/settings.speedKoef;
			else
				priceKoef = App.data.options['SpeedUpPrice'];
			
			priceSpeed = Math.ceil((finishTime - App.time) / priceKoef);
		}
		
		private function progress():void
		{
			leftTime = finishTime - App.time;
			
			if (leftTime <= 0) {
				leftTime = 0;
				App.self.setOffTimer(progress);
				close();
			}
		
			timer.text = TimeConverter.timeToStr(leftTime);
			//var percent:Number = (timeToFinish - leftTime) / timeToFinish;
			var percent:Number = (totalTime - leftTime) / totalTime;
			progressBar.progress = percent;
			
			priceSpeed = Math.ceil((finishTime - App.time) / priceKoef);
			
			if (App.user.quests.tutorial)
				return;
		
			if (boostBttn && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				boostBttn.count = String(priceSpeed);
			}
		}
		
		override public function drawBackground():void {
			background = backing2(settings.width, settings.height, 40, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			layer.addChild(background);
		}
		
		override public function drawExit():void {
			super.drawExit();
			
			exit.x = settings.width - exit.width + 12;
			exit.y = -12;
		}
		
		private var iconTarget:Bitmap = new Bitmap();
		private var background:Bitmap;
		override public function drawBody():void 
		{
			titleLabel.y += 4;

			var btmd:BitmapData;
			
			//if (settings.target.sid == 160 || settings.target.sid == 178)
				//btmd = settings.target.textures.sprites[0].bmp;
			//else if (settings.target.textures.sprites[settings.target.level + 1])
				//btmd = settings.target.textures.sprites[settings.target.level + 1].bmp;
			//else 
				//btmd = settings.target.bitmap.bitmapData;
				
			var itm:Object = App.data.storage[settings.target.sid];
			Load.loading(Config.getIcon(itm.type, itm.preview), onPreviewComplete);
			
			//var bitmap:Bitmap = new Bitmap(btmd);
			//bitmap.scaleX = bitmap.scaleY = 0.7;
			//bitmap.smoothing = true;
			//bitmap.x = (245 - bitmap.width) / 2 + 130;
			//bitmap.y = (27 - bitmap.height);
			bodyContainer.addChildAt(iconTarget, 0);
			
			
			var progressBacking:Bitmap = Window.backingShort(433, "prograssBarBacking3");
			progressBacking.x = (settings.width - progressBacking.width) / 2;
			progressBacking.y = settings.height - progressBacking.height - 72;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar( { win:this, width:436, isTimer:false});
			//progress();
			progressBar.x = (settings.width - 433) / 2 - 2;
			progressBar.y = progressBacking.y - 2;
			progressBar.visible = false;
			
			bodyContainer.addChild(progressBar);
			
			progressBar.visible = true;
			
			//var separator:Bitmap = Window.backingShort(420, 'divider');
			//separator.alpha = 0.8;
			//bodyContainer.addChild(separator);
			//separator.x = 30;
			//separator.y = 40;
			var separator:Bitmap = Window.backingShort(230, 'divider', false);
			separator.alpha = 0.8;
			bodyContainer.addChild(separator);
			separator.x = 30;
			separator.y = 40;
			
			var separator2:Bitmap = Window.backingShort(230, 'divider', false);
			separator2.alpha = 0.8;
			separator2.scaleX = -1;
			bodyContainer.addChild(separator2);
			separator2.x = 460;
			separator2.y = 40;
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -40, true, true);
			drawMirrowObjs('diamonds', /*-27*/0, settings.width/* + 24*/, settings.height - 87);
			
			
			timer = Window.drawText(TimeConverter.timeToStr(127), {
				color:			0xffffff,
				borderColor:	0x6d460f,
				fontSize:		34
			});
			
			bodyContainer.addChild(timer);
			timer.y = 30;
			
			timer.x = settings.width / 2 - 50;
			
			timer.height = timer.textHeight;
			timer.width = timer.textWidth + 10;
			
			progress();
			App.self.setOnTimer(progress);
			progressBar.start();
			
			if (App.user.quests.tutorial) {
				priceSpeed = 0;
			}
			
			boostBttn = new MoneyButton( {
				caption: Locale.__e("flash:1382952380104"),
				countText:String(priceSpeed),
				width:192,
				height:56,
				fontSize:32,
				fontCountSize:32,
				radius:26,
				
				bgColor:[0xa8f84a, 0x73bb16],
				borderColor:[0xffffff, 0xffffff],
				bevelColor:[0xcefc97, 0x5f9c11],	
				
				fontColor:0xffffff,			
				fontBorderColor:0x2b784f,
			
				fontCountColor:0xffffff,				
				fontCountBorder:0x2b784f,
				iconScale:0.8
			})
			
			bodyContainer.addChild(boostBttn);
			boostBttn.x = (settings.width - boostBttn.width)/2;
			boostBttn.y = settings.height - boostBttn.height - 10;
			boostBttn.countLabel.width = boostBttn.countLabel.textWidth + 5;
			
			boostBttn.addEventListener(MouseEvent.CLICK, onBoostEvent);
			
		}
		
		private function onPreviewComplete(data:Bitmap):void 
		{
			iconTarget.bitmapData = data.bitmapData;
			iconTarget.smoothing = true;
			iconTarget.x = (settings.width - iconTarget.width) / 2;
			iconTarget.y = (27 - iconTarget.height);
		}
		
		private function onBoostEvent(e:MouseEvent = null):void
		{
			if (settings.doBoost)
				settings.doBoost(priceBttn);
			else
				settings.target.acselereatEvent(priceBttn);
			close();
		}
		
		override public function dispose():void
		{
			if(progressBar)progressBar.dispose();
			progressBar = null;
			if(boostBttn)boostBttn.removeEventListener(MouseEvent.CLICK, onBoostEvent);
			boostBttn = null;
			App.self.setOffTimer(progress);
			super.dispose();
		}
		
	}

}