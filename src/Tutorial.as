package  
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.TipsPanel;
	import ui.UserInterface;
	import units.Guide;
	import units.Hero;
	import units.Resource;
	import units.Unit;
	import wins.DialogWindow;
	import wins.InstanceWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class Tutorial extends LayerX
	{
		//static
		public var quotes:Object = {
			90: [
				{dY:60, pers:User.PRINCESS, text:Locale.__e('Что это было? Куда делось море?! Мы же только что были на корабле!')},
				{dY:140, pers:User.PRINCE, text:Locale.__e('Это какая-то черная магия. Главное, что мы хотя бы целые! А куда корабль подевался? О, один из наших сундуков тоже здесь.'), isBttn:true},
			],
			91: [
				{dY:60, pers:User.PRINCESS, text:Locale.__e('Злодей!')},
				{dY:100, pers:User.PRINCE, text:Locale.__e('То есть, этот остров - кусок нашего Королевства?!'), isBttn:true},
			],
			92: [
				{dY:60, pers:User.PRINCESS, text:Locale.__e('Я не верю, что это происходит! Наше Королевство разрозненно, и мы вдали от дома!')},
				{dY:100, pers:User.PRINCE, text:Locale.__e('Ничего, мы все вернем на круги своя. Но что это за создания?'), isBttn:true},
			],
			93: [
				{dY:60, pers:User.PRINCESS, text:Locale.__e('Столько Нектара, а нам даже негде его хранить...')},
				{dY:110, pers:User.PRINCE, text:Locale.__e('Не беда, тут полно деревьев и камней - я думаю, мы сможем добыть необходимые материалы для постройки хранилища!'), isBttn:true},
			],
			94: [
				{dY:60, pers:User.PRINCESS, text:Locale.__e('Это же Дракон! Живой Дракон!')},
				{dY:110, pers:User.PRINCE, text:Locale.__e('Спасибо! Мы приступим к их выращиванию прямо сейчас!'), isBttn:true},
			],
			95: [
				{dY:110, pers:User.PRINCESS, text:Locale.__e('Смотри, это же Присцилла, командующая Королевских Разведчиков!'), isBttn:true}
			],
			0: [
				{dY:110, pers:User.PRINCE, text:Locale.__e('Ох, моя голова... Где это мы? А где же принцесса?'), isBttn:true}
			]
		}
		
		public static var tips:Object = {
			2: {
				descr:Locale.__e('Кликни на Грядку и посади на ней Огурцы!')
			},
			4: {
				descr:Locale.__e('Кликни на Рынок и выполни один Заказ!')
			},
			31: {
				descr:Locale.__e('Кликни на Колодец и набери в нем Воды!')
			},
			14: {
				descr:Locale.__e('Кликни на Ягодный куст и собери с него корзинку Лесных ягод!'),
				height:90,
				width:320
			},
			15: {
				descr:Locale.__e('Кликни на Кухню и приготовь на ней Варенье. Но не забудь сперва собрать Воду с Колодца!'),
				height:100,
				width:320
			}
		}
		
		//public var marker:Shape = new Shape();
		public function goCircleTo(position:Object, scales:Object = null, arrow:* = null, hasText:Boolean = false):void {
			circle.visible = true;
			circle.x = position.x;
			circle.y = position.y;
			circle.scaleX = circle.scaleY = 0.5;
			TweenLite.to(circle, 0.5, { scaleX:scales.scaleX, scaleY:scales.scaleY, ease:Back.easeOut, onComplete:function():void {
				
				if (arrow)
					showCirclePointing(arrow);
					
				if (hasText)
					addTextHelp();
					
				//App.user.quests.unlockFuckAll();
			}});
			
			/*marker.x = circle.x;
			marker.y = circle.y;*/
		}
		
		public static var watchOnTarget:Object = null;
		public static var focusOnTarget:Object = null;
		
		public static function watchOn(target:*, arrow:* = null, hasText:Boolean = false, corrs:Object= null):void 
		{
			watchOnTarget = null;
			focusOnTarget = null;
			if(App.user.quests.tutorial){
				watchOnTarget = {
					target:target,
					arrow:arrow,
					hasText:hasText,
					corrs:corrs
				}
			}
			var _arrow:Object = null;
			var text:String = '';
			
			if (App.tutorial == null)
				return;
				
			App.tutorial.hidePointing();
				
			if(arrow != false)	{
				_arrow = { position: arrow || 'top' };
				if (corrs) {
					if (corrs.arrow_dx) _arrow['arrow_dx'] = corrs.arrow_dx;
					if (corrs.arrow_dy) _arrow['arrow_dy'] = corrs.arrow_dy;
				}
			}
			
			App.tutorial.show();	
			App.tutorial.goCircleTo(
					Tutorial.getAbsCoords(target, corrs),
					Tutorial.getCircleScales(target, corrs),
					_arrow,
					hasText
				);
			App.self.addChild(App.tutorial);
			//if (!Window.isOpen)
				//App.user.quests.lockFuckAll();
		}
		
		public function showCirclePointing(settings:Object):void {
			hidePointing();
			var _deltaX:int = circle.x;
			var _deltaY:int = circle.y - circle.height / 3;
			
			if (settings.position == 'left') {
				_deltaX = circle.x - circle.width / 2;
				_deltaY = circle.y;
			}else if (settings.position == 'right') {
				_deltaX = circle.x + circle.width / 2;
				_deltaY = circle.y;
			}
			
			if (settings.arrow_dx) {
				_deltaX += settings.arrow_dx;
			}
			if (settings.arrow_dy) {
				_deltaY = circle.y + settings.arrow_dy;
			}
			
			showPointing(settings.position, _deltaX, _deltaY, this);
		}

		public static function getAbsCoords(target:*, corrs:Object = null):Object {
			
			var globalPoint:Object = target.localToGlobal(new Point(0, 0));
			var absX:int = globalPoint.x;
			var absY:int = globalPoint.y;
			
			if(target is Resource){
			
			}else if (target is Unit) {
				//absX += target.center.x//target.bitmap.x + target.bitmap.width / 2;
				//absY += target.center.y//target.bitmap.y + target.bitmap.height / 2;
			}else{
				absX += target.width / 2;
				absY += target.height / 2;
			}
			
			if(corrs){
				if (corrs.hasOwnProperty('dx'))	absX += corrs.dx;
				if (corrs.hasOwnProperty('dy'))	absY += corrs.dy;
			}	
			
			return {
				x:absX,
				y:absY
			}
		}
		
		public function initCursorShleif():void
		{
			//cursorShleif = new CursorShleif();
		}
		
		public static function getCircleScales(target:*, corrs:Object = null):Object {
			/*var _x:int = unit.x + App.map.x;
			var _y:int = unit.y + App.map.y;*/
			
			var _scales:Object = {
				scaleX:1,
				scaleY:1
			};
			if (corrs) {
				if (corrs.scaleX) _scales.scaleX = corrs.scaleX;
				if (corrs.scaleY) _scales.scaleY = corrs.scaleY;
			}
			
			if (target is Unit) {
				
			}
			return _scales;
		}
		
		
		public static function getCorrections(id:*):* 
		{
			switch(id) {
				
				case 268: // сундук
					return {
						scaleX:1,
						scaleY:1,
						dy: 20
					}	
				break;
				/*
				
				
				case 159: 
					return {
						scaleX:1.5,
						scaleY:1.5,
						dy:40,
						dx:10
					}	
				break;
				
				case 179: 
					return {
						scaleX:1.5,
						scaleY:1.5
					}	
				break;	*/
				
				case 160: // Поле
					return {
						scaleX:1.6,
						scaleY:1.6,
						dy:30
					}	
				break;
				case 165: 
					return {
						scaleX:1.5,
						scaleY:1.5
					}	
				break;
				case 161: // Хранилище
					return {
						scaleX:1.5,
						scaleY:1.5,
						dy:50
					}	
				break;	
				case 140: // Источник
					return {
						scaleX:1.5,
						scaleY:1.5
					}	
				break;
				case 278: // дерево
					return {
						scaleX:1.7,
						scaleY:1.7,
						dy: -70
					}	
				break;
				
			}
			
			return null;
		}
		
		private var helpText:TutorialHelpText;
		public function addTextHelp():void {
			removeTextHelp();
			
			var iconType:String = TutorialHelpText.MOUSE;
			var text:String = '';
			
			switch(App.user.quests.currentQID) 
			{
				case 85:
						if(App.user.quests.currentMID == 1){
							text = Locale.__e('flash:1403170779703');
						}else {
							if(!QuestsRules.quest85)
								text = Locale.__e('flash:1396867388905');
							else
								text = Locale.__e('flash:1403170965448');
						}
							
						iconType = TutorialHelpText.EMPTY;
					break;
			}
			if (text == '') return;
			
			helpText = new TutorialHelpText(text, iconType);
			this.addChild(helpText);
			helpText.x = circle.x - helpText.width / 2;
			helpText.y = circle.y + circle.height / 2 + 20;
		}
		
		public function removeTextHelp():void {
			if (helpText != null) {
				this.removeChild(helpText);
				helpText = null;
			}
		}
		
		public var step:int = 0;
		public var currentQID:int = 0;
		public function nextStep(qID:int, _step:int = 0):void {
			
			if (currentQID != qID)
				step = _step;
			else 
				step ++;
				
			if (_step > 0)
				step = _step;
				
			currentQID = qID;	
				
			trace('nextStep - qID:' + qID + '  step:' + step);	
		}
		
		public var cat:*;
		public function focusedOnCat():void {
			App.user.quests.lockFuckAll();
			hide();
			hidePointing();
			cat = Map.findUnit(206, 1);
			
			if (cat == null) {
				cat = Unit.add( { sid:206, id:1, x:39, z:46 } );
				cat.buyAction();
			}
			
			App.map.focusedOn(cat, true, function():void {
				App.user.quests.lockWhileMove = false;
				App.user.quests.unlockFuckAll();
				new DialogWindow( { qID:79, mID:1 } ).show();
			});
		}
		
		
		
		public function focusOnInstanseStart():void {
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var win:* = App.self.windowContainer.getChildAt(i);
				
				if (win is InstanceWindow)
				{
					var bttn:Button = win.btnnStartReq;
					bttn.showGlowing();
					
					App.user.quests.currentTarget = bttn;
					App.user.quests.lock = false;
					
					var pos:Object = getAbsCoords(bttn);
					
					Tutorial.watchOn(bttn, 'left', false);
					/*App.tutorial.showPointing("right", pos.x - 10, pos.y + 65, App.tutorial);
					App.tutorial.setCirclePosition({
						x:pos.x + bttn.width/2,
						y:pos.y,
						scaleX:1.5
					});*/
					
					break;
				}
			}
		}
		
		
		
		public function waitForComplete():void {
			App.user.quests.lockFuckAll();
		}
		
		public function onCompleteTechno2():void {
			App.user.quests.unlockFuckAll();
			App.user.quests.continueTutorial();
		}
		
		private var fader:Bitmap;
		public var circle:Shape;
		public function Tutorial()
		{
			//quotes = quotesData;
			
			
			var bmd:BitmapData = new BitmapData(App.self.stage.stageWidth, App.self.stage.stageHeight, false, 0x000000);
			fader = new Bitmap(bmd);
			fader.alpha = 0.5;
			addChild(fader);
			
			circle = new Shape();
			circle.graphics.beginFill(0xFFFFFF, 1);
			circle.graphics.drawCircle(0, 0, 100);
			circle.graphics.endFill();
			addChild(circle);
			circle.filters = [new BlurFilter(20, 20, 3)];
			
			circle.graphics.beginFill(0xFF0000, 1);
			circle.graphics.drawCircle(0, 0, 3);
			circle.graphics.endFill();
			
			circle.x = 300;
			circle.y = 300;
			circle.blendMode = BlendMode.OVERLAY;
			this.mouseEnabled = false;
			this.mouseChildren = false;
			circle.visible = false;
			
			/*marker.graphics.beginFill(0xFF0000, 1);
			marker.graphics.drawCircle(0,0,3);
			marker.graphics.endFill();*/
			//addChild(marker);
		}
		
		public static function init():void {
			App.tutorial = new Tutorial();
			App.self.addChildAt(App.tutorial,1);
			App.tutorial.hide();
			//App.tutorial.step(1);
		}
		
		public function hide():void {
			circle.visible = false;
			this.visible = false;
			removeTextHelp();
		}
		
		public function show():void {
			this.visible = true;
			//resize();
			fader.width = App.self.stage.stageWidth;
			fader.height = App.self.stage.stageHeight;
		}
		
		public function resize():void {
			fader.width = App.self.stage.stageWidth;
			fader.height = App.self.stage.stageHeight;
			
			resetStep();
		}
		
		public function resetStep():void {
			//if (watchOnTarget != null) 
			//{
				//if (watchOnTarget.target is Unit) {
					//App.map.focusedOn(watchOnTarget.target, false, reWatchOn, false);
				//}else {
					//reWatchOn();
				//}
			//}
			setTimeout(function():void{
				if (watchOnTarget != null) 
				{
					if (watchOnTarget.target is Unit) {
						App.map.focusedOn(watchOnTarget.target, false, reWatchOn, false);
					}else {
						reWatchOn();
					}
				}else if (focusOnTarget != null) {
					App.map.focusedOn(focusOnTarget, false, null, false);
				}
			},300);
		}
		
		private function reWatchOn():void {
			if (watchOnTarget){
				Tutorial.watchOn(watchOnTarget.target, watchOnTarget.arrow, watchOnTarget.hasText, watchOnTarget.corrs);
				watchOnTarget = null;
			}	
		}
		
		private static var tipTimer:int = 0;
		public static function showTip(qID:uint):void 
		{
			if (!Tutorial.tips.hasOwnProperty(qID)) 
			{
				if(tipTimer>0){
					clearTimeout(tipTimer);
					tipTimer = 0;
				}
				TipsPanel.hide();
				return;
			}	
				
			var object:Object = tips[qID];
			
			var params:Object = {
				title:Locale.__e('flash:1404809873565'), 
				desc:object.descr,
				indCharacter:App.data.quests[qID].character,
				qID:qID,
				mID:1
			}
			
			if(object.hasOwnProperty('height'))
				params['height'] = object.height;
			
			tipTimer = setTimeout(function():void {
				TipsPanel.show(params);
			}, 2000);
		}
		
		public function showTutorialPointing(target:*, position:String = "top", deltaX:int = 0, deltaY:int = 0, container:* = null, text:String = '', textSettings:Object = null, arrowBig:Boolean = false):void 
		{
			/*var _deltaX:int = deltaX + target.x + App.map.x;
			var _deltaY:int = deltaY + target.y + App.map.y;
			showPointing(position, _deltaX, _deltaY, this, text, textSettings, arrowBig);*/
		}
		
		public static function dispose():void {
			App.self.removeChild(App.tutorial);
			App.tutorial = null;
		}
		
		import com.greensock.easing.Back;
		public function setCirclePosition(position:Object):void {
			circle.visible = true;
			circle.x = position.x;
			circle.y = position.y;
			circle.scaleX = circle.scaleY = 0.3;
			
			var scaleX:Number = position.scaleX || 1;
			var scaleY:Number = position.scaleY || 1;
			
			if (position.hasOwnProperty('scale')){
				scaleX = position.scale;
				scaleY = position.scale;
			}	
			
			TweenLite.to(circle, 0.5, { scaleX:scaleX, scaleY:scaleY, ease:Back.easeOut } );
			
			if (position.hasOwnProperty('layer')) {
				App.self.addChild(App.tutorial);
			}
			
			/*if(position.hasText)
				addTextHelp();*/
				
			show();
		}
			
		public function getCirclePosition(unit:*, qID:int, mID:int = 0):Object
		{
			var _x:int = unit.x + App.map.x;
			var _y:int = unit.y + App.map.y;
			var _scale:Number = 1;
			var _hasText:Boolean = true;
			
			switch(qID) {
				case 75:
					_scale = 1;
				break;	
				case 77:
					_scale = 3;
				break;	
				case 5:
					_scale = 1.7;
					_y += 15;
					_x -= 10;
				break;	
			}
			
			return {
				x:_x,
				y:_y,
				scale:_scale,
				hasText:_hasText
			};
		}
		
		private var fullBttn:ImagesButton
		public function addFullScreenBttn():void {
			removeTextHelp();
			var bg:Shape = new Shape();
			var bg2:Shape = new Shape();
			
			bg2.graphics.beginFill(0x7492b3, 1);
			bg2.graphics.drawRoundRect(0, 0, 138, 138, 30, 30);
			bg2.graphics.endFill();
			
			bg.graphics.beginFill(0xa8b1d7, 1);
			bg.graphics.drawRoundRect(2, 2, 134, 134, 30, 30);
			bg.graphics.endFill();
			var cont:Sprite = new Sprite();
			cont.addChild(bg2);
			cont.addChild(bg);
			
			var bmd:BitmapData = new BitmapData(cont.width, cont.height, true, 0);
			bmd.draw(cont);
			
			show();
			this.mouseEnabled = true;
			this.mouseChildren = true;
			fullBttn = new ImagesButton(UserInterface.textures.fullscreenBacking, UserInterface.textures.fullscreenBttnBig);
			fullBttn.bitmap.alpha = 1;
			addChild(fullBttn);
			fullBttn.x = (App.self.stage.stageWidth - fullBttn.width) / 2;
			fullBttn.y = (App.self.stage.stageHeight - fullBttn.height) / 2;
			fullBttn.addEventListener(MouseEvent.CLICK, onFullScreen);
			
			fullBttn.alpha = 0;
			TweenLite.to(fullBttn, 0.5, {alpha:1})
			
			//App.user.quests.lockFuckAll();
			App.user.quests.currentTarget = fullBttn;
			fullBttn.showPointing('top', fullBttn.x+fullBttn.width/2,  0, this);
		}
		
		private function onFullScreen(e:MouseEvent):void {
			removeFullScreenBttn();
			hide();
			this.mouseEnabled = false;
			this.mouseChildren = false;
			App.ui.systemPanel.onFullscreenEvent(e);
			App.user.quests.readEvent(99, function():void { } );
		}
		
		public function removeFullScreenBttn():void {
			fullBttn.hidePointing();
			fullBttn.removeEventListener(MouseEvent.CLICK, onFullScreen);
			removeChild(fullBttn);
			fullBttn = null;
		}
		
		public function personagesMoveToCat():void 
		{
			App.user.quests.lockFuckAll();
			var targets:Array = Map.findUnits([206]);
			if (targets.length > 0){
				for each(var _hero:Hero in App.user.personages) {
					_hero.initMove(targets[0].coords.x, targets[0].coords.z, _hero.onStop);
				}
			}
			setTimeout(glowForTeleport, 2000);
		}
		
		private function glowForTeleport():void 
		{
			for each(var _hero:Hero in App.user.personages) {
				App.ui.flashGlowing(_hero, 0x56ffff);
				TweenLite.to(_hero, 1, { alpha:0, ease:Strong.easeIn} );
			}
			App.ui.flashGlowing(cat, 0x56ffff, startTeleportation);
			TweenLite.to(cat, 1, { alpha:0, ease:Strong.easeIn} );
		}
		
		private function startTeleportation():void {
			App.user.quests.unlockFuckAll();
			Travel.goTo(User.HOME_WORLD);
		}
		
		public function showMarketPanel():void {
			App.ui.bottomPanel.show('mainPanel');
		}
	}
}

import flash.display.Bitmap;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class TutorialHelpText extends LayerX
{
	public static const MOUSE:String = 'mouse';
	public static const EMPTY:String = 'empty';
	private var textField:TextField;
	private var iconImg:Bitmap;
	
	public function TutorialHelpText(text:String, iconType:String) {
		textField = Window.drawText(text,{
			fontSize:30,
			color:0xFFFFFF,
			autoSize:"left",
			borderColor:0x713e13//0x1d3b3d//0x2b3b64
		});

		addChild(textField);
		startAlphaEff(null, 0.2, 0.5);
		
		if (iconType == EMPTY)
			return;
			
		iconImg = new Bitmap(UserInterface.textures[iconType]);
		iconImg.x = textField.x + (textField.width - iconImg.width) / 2;
		iconImg.y = textField.y + textField.height + 3;
		addChild(iconImg);
		
		
	}
	
}