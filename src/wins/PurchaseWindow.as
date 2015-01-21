package wins 
{
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import wins.elements.PurchaseItem;

	public class PurchaseWindow extends Window
	{
		public var items:Array = new Array();
		public var handler:Function; 
		
		private var find:int = 0;
		
		
		public function PurchaseWindow(settings:Object = null)
		{
			var defaults:Object = {
				width: 730,
				height:320,
				hasPaper:true,
				title:Locale.__e("flash:1382952380240"),
				titleScaleX:0.76,
				titleScaleY:0.76,
				hasPaginator:true,
				hasArrows:true,
				hasButtons:false,
				shortWindow:false,
				useText:false,
				itemsOnPage:3,
				descWidthMarging:0,
				description:Locale.__e("flash:1382952380241"),
				closeAfterBuy:false,
				autoClose:true,
				popup:true
			};
			
			if (settings == null) {
				settings = new Object();
			}
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			settings = defaults;
			
			settings["noDesc"] = settings.noDesc || false;
			
			handler = settings.callback;
			
			if (settings.find != undefined) this.find = settings.find;
			
			super(settings);
		}
		
		override public function drawTitle():void 
		{
		}
		
		override public function drawBackground():void {
			//var background:Bitmap = backing2(settings.width, settings.height, 45, "questsSmallBackingTopPiece", "questsSmallBackingBottomPiece");
			//layer.addChild(background);
		}
		
		public static function createContent(type:String, params:Object = null):Array
		{
			var list:Array = new Array();
			var makeGlow:Boolean = false;	
			
			for (var sID:* in App.data.storage) {
				var object:Object = App.data.storage[sID];
				object['sID'] = sID;
				
				if (params != null) {
					var _continue:Boolean = false;
					for (var prop:* in params) {
						if (object[prop] == undefined || object[prop] != params[prop] /*|| object.out != params.out*/) {
							_continue = true;
							break;
						}
					}
					if (_continue) {
						continue;
					}
				}
				
				if (object.type == type)
				{
					list.push( { sID:sID, order:object.order, glow:makeGlow } );
				}
			}
			
			list.sortOn("order", Array.NUMERIC);
			return list;
		}
		
		override public function dispose():void {
			removeItems();
			super.dispose();
		}
		
		public function removeItems():void
		{
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i] != null)
				{
					items[i].dispose();
					items[i] = null;
				}
			}
			items.splice(0, items.length);
		}
		
		/*public function drawDescription():void {
			var descriptionLabel:TextField = drawText(settings.description, {
				fontSize:28,
				autoSize:"left",
				textAlign:"center",
				multiline:true,
				color:0xffffff,
				borderColor:0x6d4b15
			});
			descriptionLabel.width = settings.width - 60;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 0;
						
			descriptionLabel.width = settings.width - 80;
			
			bodyContainer.addChild(descriptionLabel);
		}*/
		
		private var descriptionLabel:TextField
		override public function drawBody():void {
			//titleLabel.y -= 4;
			exit.y -= 1;
			exit.x += 6;
			
			if (settings.shortWindow) {
				settings.width = 552;
				exit.x -= 164;
			}
			
			if (settings.useText) {
				descriptionLabel = drawText(settings.description, {
					fontSize:24,
					autoSize:"center",
					textAlign:"center",
					multiline:true,
					color:0xffffff,
					borderColor:0x7a4b1f
				});
				descriptionLabel.wordWrap = true;
				descriptionLabel.width = settings.width - 60 + settings.descWidthMarging;
				if (settings.title == "Фури")
				{
					descriptionLabel.x = (settings.width - descriptionLabel.width) / 2 + 50;
				}else {
					descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
				}
				
				descriptionLabel.y = -8;
				
				bodyContainer.addChild(descriptionLabel);
				settings.height += descriptionLabel.textHeight - 18;
			}
			
			var bg:Bitmap = backing(settings.width + 20, settings.height + 30, 45, "questBacking");
			if (settings.title == "Фури")
				{
					bg.x = 50;
				}else {
					bg.x = 0;
				}
			
			layer.addChild(bg);
			
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			
			if (settings.title == "Фури")
				{
					titleLabel.x = (settings.width - titleLabel.width) * .5 + 60;
				}else {
					titleLabel.x = (settings.width - titleLabel.width) * .5;
				}
			titleLabel.y = -23;// титульный текст
			headerContainer.addChild(titleLabel);
			
			//drawDescription();
			
			createItems();
			contentChange();
			
			if (settings.image) {
				var img:Bitmap = settings.image;
				bodyContainer.addChild(img);
				img.x = -50;
				img.y = -150;
			}
			
			if (settings.title == "Фури")
			{
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5 + 50, settings.width / 2 + settings.titleWidth / 2 + 5 + 50, -45, true, true);
				drawMirrowObjs('storageWoodenDec', -4 + 50, settings.width + 22 + 50, settings.height - 76);
				drawMirrowObjs('storageWoodenDec', -4 + 50, settings.width + 22 + 50, 39, false, false, false, 1, -1);
			}else {
				drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
				drawMirrowObjs('storageWoodenDec', -4, settings.width + 22, settings.height - 76);
				drawMirrowObjs('storageWoodenDec', -4, settings.width + 22, 39, false, false, false, 1, -1);
			}
			
			
			//var furryBimtap:Bitmap = new Bitmap(UserInterface.textures.alert_techno);
			var furryBimtap:Bitmap = new Bitmap(Window.textures.errorWork);
			furryBimtap.x = -100;
			furryBimtap.y = -30;
			
			if (settings.title == "Фури")
			{
				bodyContainer.addChild(furryBimtap);
			}			
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			if (settings.title == "Фури")
				{
					exit.x = settings.width - 34 + 50;
				}else {
					exit.x = settings.width - 34;
				}
			
			exit.y = 0;
		}
		
		override public function drawArrows():void {
			//if(items.length){
				paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -0.8, scaleY:0.8 } );
				paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:0.8, scaleY:0.8 } );
				
				var y:int = (settings.height - paginator.arrowLeft.height) / 2;
				if (settings.title == "Фури")
				{
					paginator.arrowLeft.x = paginator.arrowLeft.width - 77 + 50;
					paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 25 + 50;
				}else {
					paginator.arrowLeft.x = paginator.arrowLeft.width - 77;
					paginator.arrowRight.x = settings.width - paginator.arrowRight.width + 25;
				}
				
				paginator.arrowLeft.y = y;
				paginator.arrowRight.y = y;
			//}
		}
		
		override public function contentChange():void {
			for (var i:int = 0; i < items.length; i++)
			{
				items[i].visible = false;
			}

			var itemNum:int = 0
			
			var yPos:int = 25; 
			
			if (settings.useText) {
				yPos = descriptionLabel.y + descriptionLabel.textHeight + 10;
			}
			
			if(items.length){
				for (i = paginator.startCount; i < paginator.finishCount; i++)
				{
					items[i].y = 10 + yPos;
					if (settings.title == "Фури")
					{
						items[i].x = 49 + itemNum * items[i].bgWidth + 10*itemNum + 50;
					}else {
						items[i].x = 49 + itemNum * items[i].bgWidth + 10*itemNum;
					}
					
					itemNum++;
					items[i].visible = true;
				}
			}
		}
		
		public function createItems():void {
			var glow:Boolean = false;
			
			for (var j:int = 0; j < items.length; j++) 
			{
				items[i].dispose();
			}
			items = [];
			
			for (var i:int = 0; i < settings.content.length; i++) {
				if (App.data.storage[settings.content[i].sID].out == find) glow = true;
				var item:PurchaseItem = new PurchaseItem(settings.content[i].sID, handler, this, i, glow, settings.shortWindow, settings.noDesc);
				item.visible = false;
				bodyContainer.addChild(item);
				items.push(item);
				glow = false;
			}
			sortItems();
		}
		
		private function sortItems():void 
		{
			var arr:Array = [];
			for ( var i:int = 0; i < items.length; i++ ) {
				if (items[i].doGlow) {
					arr.push(items[i]);
					items.splice(i, 1);
					i--;
				}
			}
			for ( i = 0; i < items.length; i++ ) {
				arr.push(items[i]);
			}
			items.splice(0, items.length);
			items = arr;
		}
		
		public function set callback(handler:Function):void {
			this.handler = handler;
		}
		
		public function blokItems(value:Boolean):void
		{
			var item:*;
			if (value)	for each(item in items) item.state = Window.ENABLED;
			else 		for each(item in items) item.state = Window.DISABLED;
		}
		
	}
}
