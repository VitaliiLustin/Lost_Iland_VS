package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UpPanel;
	import ui.UserInterface;
	import units.Hut;

	public class HutWindow extends Window
	{
		public var items:Array = new Array();
		private var setTargetBttn:Button;
		public var hut:Hut = null;
		private var bears:Object = null;
		private var bearsCount:int = 0;
		
		private var workers:Array;
		
		public function HutWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			hut = settings.target;
			bears = hut.bears;
			settings['width'] = 612;
			settings['height'] = 650;
			settings['hasPaper'] = true;
						
			settings['title'] = settings.title;
			settings['titleScaleX'] = 0.76;
			settings['titleScaleY'] = 0.76;
			
			settings['hasPaginator'] = false;
			settings['onPageCount'] = 2;
			settings['description'] = Locale.__e("flash:1382952380164");
			
			super(settings);
		}
		
		override public function drawBody():void {
			
			initContent();
			contentChange();
			
			settings.target.addEventListener(WindowEvent.ON_HUT_UPDATE, refresh);
			
			/*if (settings.target.old >= settings.target.info.limit)
			{
				setTimeout(function():void
				{
					new RepairWindow({
						onClose:close,
						title:"flash:1382952379886",
						price:settings.target.info.price,
						onRepair:settings.onRepair,
						popup:true
					}).show();
				}, 500);
			}*/
		}
		
		private function initContent():void
		{
			bears = hut.bears;
			workers = [null, null, null];
			
			for (var i:String in bears) 
			{
				workers[i] = bears[i];
			}
		}
		
		public override function contentChange():void
		{
			for each(var _item:WorkerItem in items)
			{
				bodyContainer.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			
			var X:int = 56;
			var Y:int = 56;
			items = [];
			
			for (var i:int = 0; i < 3; i++)
			{
				var item:WorkerItem = new WorkerItem(this, workers[i], i);
				bodyContainer.addChildAt(item,0);
				
				items.push(item);
				item.x = X;
				item.y = Y; 
				Y += item.bg.height + 10;
			}
			
			if (settings.hasOwnProperty('glowedWorker')) 
			{
				var workerID:uint = settings.glowedWorker;
				setTimeout(function():void
				{
					App.ui.flashGlowing(items[workerID])
				}, 500);
				delete settings.glowedWorker;
			}
		}
		
		override public function dispose():void
		{
			for each(var _item:WorkerItem in items)
			{
				_item.dispose();
				_item = null;
			}
			items = null;
			
			settings.target.removeEventListener(WindowEvent.ON_HUT_UPDATE, refresh);
			super.dispose();
		}
		
		public function refresh(e:WindowEvent = null):void
		{
			initContent();
			contentChange();
		}
	}
}


import adobe.utils.CustomActions;
import api.ExternalApi;
import buttons.Button;
import com.greensock.TweenLite;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.Cloud;
import ui.UserInterface;
import units.Bear;
import units.Hut;
import units.Resource;
import units.Unit;
import wins.Window;
import wins.HutWindow;
import wins.JamWindow;
import wins.WindowEvent;

internal class WorkerItem extends Sprite
{
	public var bg:Bitmap;
	public var imageBg:Bitmap;
	private var bitmap:Bitmap;
	private var back:Bitmap;
	private var sprite:Sprite;
	public var items:Array = [];
	
	private var label1:TextField
	private var label2:TextField
	private var labelCont:Sprite
	
	public var setTargetBttn:Button
	public var fireBttn:Button
	private var feedBttn:Button
	private var fireSmallBttn:Button
	public var win:HutWindow
	
	public var bear:Object;
	private var bearWorker:Bear = null;
	private var sID:*;
	public var id:uint;
	
	public function WorkerItem(win:HutWindow, bear:Object, id:uint)
	{
		this.win = win;
		this.id = id;
		bg = Window.backing(500, 160, 50);
		
		switch(win.hut.sid)
		{
			case Hut.WOOD:
				imageBg = new Bitmap(Window.textures.woodBackLabel);	
				break;
			case Hut.STONE:
				imageBg = new Bitmap(Window.textures.stoneBackLabel);	
				break;
			case Hut.BAG:
				imageBg = new Bitmap(Window.textures.forestBackLabel);	
				break;
			default:
				imageBg = new Bitmap(Window.textures.woodBackLabel);	
				break;
		}
		
		addChild(bg);
		addChild(imageBg);
		imageBg.x = (500 - imageBg.width)/2
		imageBg.y = (160 - imageBg.height) / 2 + 16;
		imageBg.visible = false;
		
		drawWorkerAvatar();
		drawLabel();
		
		if (bear)
		{
			if (bear.hasOwnProperty('bear'))
			{
				if(win.settings.worker == 'bear')
					bitmap.bitmapData = Window.textures.bearHead;
				else
					bitmap.bitmapData = Window.textures.beaverHead;
					
				bitmap.x = (sprite.width - bitmap.width) / 2;
				bitmap.y = (sprite.height - bitmap.height) / 2;
				
				drawBearBttns();
				
				fireBttn.visible = true;
				
				drawCounter(bear.bear.jam);
				
				if (bear.bear.flag != false)
				{
					var view:String;
					if (win.settings.worker == 'bear')
						view = 'jam';
					else	
						view = 'fish';
						
					var cloud:Cloud = new Cloud(bear.bear.flag, {view:view});
					cloud.x = 75;
					cloud.y = 0;
					addChild(cloud);
					
					if (bear.bear.flag == "noJam")
					{
						fireBttn.visible = false;
						feedBttn.visible = true;
					}
				}
			}
			else
			{
				//label1.visible = true;
			}
			
			if (bear.stacks == 0 && !bear.hasOwnProperty("bear"))
			{
				sprite.visible = false;
				drawStartBttn();
				imageBg.visible = true;
				label1.visible = true;
			}
			else
			{
				drawStacks(bear);
			}
		}
		else
		{
			sprite.visible = false;
			drawStartBttn();
			imageBg.visible = true;
			label1.visible = true;
		}
		
		
	}
	
	private function drawCounter(count:int):void
	{
		/*var bg:Bitmap = Window.backing(70, 50, 10, "textSmallBacking");
		bg.x = 2;
		bg.y = 2;
		addChild(bg);*/
		
		var container:Sprite = new Sprite();
		
		
			var spoonIcon:Bitmap = new Bitmap();
			var _text:String;
			
			var textSettings:Object;
			textSettings = {
					color				: 0x614605,
					fontSize			: 16,
					borderColor 		: 0xf5efd9
				}
			if (win.settings.worker == 'bear') {
				spoonIcon = new Bitmap(UserInterface.textures.spoonIcon);
				spoonIcon.scaleX = spoonIcon.scaleY = 0.25;
				
			}else {
				spoonIcon = new Bitmap(UserInterface.textures.spoonIconFish);
				spoonIcon.scaleX = spoonIcon.scaleY = 0.35;
			}
			
			spoonIcon.smoothing = true;
		
		var text:TextField = Window.drawText(Locale.__e("flash:1382952380165"), textSettings);
			
		text.width 	= text.textWidth  + 4;
		text.height = text.textHeight;
		
		var countText:TextField = Window.drawText(String(count), textSettings);
		
		countText.height = countText.textHeight;
		countText.width = countText.textWidth + 4;
		countText.border = false;
		
		countText.x = text.width + 4;
		
		spoonIcon.x = countText.x + countText.width + 4;
		spoonIcon.y = countText.y + (countText.textHeight - spoonIcon.height) / 2;
		
		container.addChild(text);
		container.addChild(countText);
		container.addChild(spoonIcon);
		
		sprite.addChild(container);
		container.x = (back.width - container.width) / 2;
		container.y = back.height - container.height - 18;
	}
	
	private function onBearImageClick(e:MouseEvent):void
	{
		if (bearWorker != null)
		{
			App.map.focusedOn(bearWorker);
		}
	}
	
	private function drawStartBttn():void
	{
		var text:String;
		if (win.settings.worker == 'bear') {
			text = Locale.__e("flash:1382952380166");
		}else{
			text = Locale.__e("flash:1382952380167");
		}
		setTargetBttn = new Button(	{
										caption		:text,
										width		:160,
										height		:45,	
										borderWidth	:2,
										fontSize	:19,
										shadow		:true,
										radius		:25
									});
		setTargetBttn.x = bg.width / 2 - setTargetBttn.width / 2
		setTargetBttn.y = bg.height /2  - 45/2;
		addChild(setTargetBttn);
		setTargetBttn.addEventListener(MouseEvent.CLICK, onSetTargetClick);
	}
	
	private function drawBearBttns():void
	{
		fireBttn = new Button(	{
										caption		:Locale.__e("flash:1382952380168"),
										fontSize:22,
										width:94,
										height:30
									});
									
		fireBttn.x = (back.width - fireBttn.width) / 2;
		fireBttn.y = back.height - 20;
		sprite.addChild(fireBttn);
		
		fireSmallBttn = new Button(	{
										caption		:Locale.__e("flash:1382952380168"),
										fontSize:18,
										width:84,
										height:26
									});
									
		fireSmallBttn.x = (back.width - fireSmallBttn.width) / 2;
		fireSmallBttn.y = (back.height + 12)// - fireSmallBttn.height)/2 + 10;
		
		fireSmallBttn.visible = false;
		
		feedBttn = new Button(	{
										caption		:Locale.__e("flash:1382952379872"),
										fontSize:22,
										width:94,
										height:30,
										borderColor:			[0xf3a9b3,0x550f16],
										fontColor:				0xe6dace,
										fontBorderColor:		0x550f16,
										bgColor:				[0xbf3245,0x761925]
									});
		feedBttn.x = (back.width - feedBttn.width) / 2;
		feedBttn.y = back.height - 20;
		sprite.addChild(feedBttn);
		
		sprite.addChild(fireSmallBttn);
		
		fireBttn.visible = false;
		feedBttn.visible = false;
		
		feedBttn.addEventListener(MouseEvent.CLICK, onFeedBttnClick);
		fireSmallBttn.addEventListener(MouseEvent.CLICK, onFireBttnClick);
		fireBttn.addEventListener(MouseEvent.CLICK, onFireBttnClick);
	}
	
	private function onSetTargetClick(e:MouseEvent):void {
			
			win.settings.selectTargetAction(id);
			win.close();
	}
	
	private function onFireBttnClick(e:MouseEvent):void {
			win.settings.fireAction(id);
			win.refresh();
	}
	
	private function onFeedBttnClick(e:MouseEvent):void {
			bear.bear.feedAction();
			win.close();
	}
	
	public function dispose():void
	{
		for each(var _item:StackItem in items)
		{
			_item.dispose();
			_item = null;
		}
		items = null;
		
		if (bearWorker != null) bearWorker.removeEventListener(WindowEvent.ON_HUT_UPDATE, win.refresh);
		if (back != null) 		back.removeEventListener(MouseEvent.CLICK, onBearImageClick);
		
		this.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		this.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		if(feedBttn) feedBttn.removeEventListener(MouseEvent.CLICK, 		onFeedBttnClick);
		if(fireSmallBttn) fireSmallBttn.removeEventListener(MouseEvent.CLICK, onFireBttnClick);
		if (fireBttn) fireBttn.removeEventListener(MouseEvent.CLICK, 		onFireBttnClick);
		
		sprite.removeEventListener(MouseEvent.MOUSE_OVER, onAvaOver);
		sprite.removeEventListener(MouseEvent.MOUSE_OUT, onAvaOut);
	}
	
	private var jamTick:Bitmap
	private function drawStacks(bear:Object):void
	{
		this.bear = bear;
		var	target:Resource = null;
		var tID:uint;
		var tsID:uint;
		
		if (bear.target is Resource)
		{
			sID 	= bear.target.info.out;
			target 	= bear.target;
			tID 	= target.id;
			tsID 	= target.sid;
		}
		else
		{
			if (bear.target.hasOwnProperty('info')) {
				sID = bear.target.info.out;
				tsID = bear.target.info.sid;
			}
			else
			{
				tID 	= Unit.explode(bear.target).id;
				tsID	= Unit.explode(bear.target).sID
				sID		= App.data.storage[tsID].out;
				target 	= Map.findUnit(tsID, tID);
			}
		}
		
		if (target == null || target.capacity == 0)
		{
			jamTick = new Bitmap(UserInterface.textures.tick);
			addChild(jamTick);
			jamTick.x = back.x + back.width - 5;
			jamTick.y = back.y + 5;
			
			var label:TextField = Window.drawText(Locale.__e("flash:1382952380169"), {
				fontSize:20,
				color:0x5d450f,
				borderColor:0xefe5c3
			});
			label.width = label.textWidth + 5;
			label.height = label.textHeight;
			
			addChild(label);
			label.x = sprite.x + back.width / 2 - label.width / 2;
			label.y = back.y + back.height - 24;
			
			Load.loading(Config.getIcon("Resource", App.data.storage[tsID].preview), function(data:Bitmap):void{
				bitmap.bitmapData = data.bitmapData;
				bitmap.x = back.width / 2 - bitmap.width / 2;
				bitmap.y = back.height / 2 - bitmap.height / 2 - 6;
			});
		}
		
		var X:int = 160;
		for (var i:int = 0; i < 3; i++)
		{
			var stack:StackItem = new StackItem(sID, this, i);
			addChild(stack);
			items.push(stack);
			stack.x = X;
			X += stack.bg.width + 10;
			stack.y = (bg.height - stack.bg.height) / 2;
			stack.Ys = stack.y;
			
			if (i < bear.stacks)
			{
				stack.state = StackItem.FULL; 
			}
			else if (i == bear.stacks && bear.hasOwnProperty('bear'))
			{
				if (bear.bear.jam == 0)	continue;
				
				stack.state = StackItem.PROGRESS; 
				stack.addProgressBar(bear.bear);
			}
		}
		
		if (bear.hasOwnProperty('bear'))
		{
			bearWorker = bear.bear;
			bearWorker.addEventListener(WindowEvent.ON_HUT_UPDATE, win.refresh);
		}
		
		var targetName:TextField = Window.drawText(App.data.storage[sID].title+":", {
				fontSize:24,
				color:0x5d450f,
				borderColor:0xefe5c3,
				textAlign:"center",
				autoSize:"center"
			});	
			
			targetName.x = 170;
			targetName.y = 5;
			targetName.width = 300;
			addChild(targetName);
	}
	
	private var strings:Object = {
		'bear':{
			1:Locale.__e('flash:1382952380170'),
			2:Locale.__e('flash:1382952380171'),
			3:Locale.__e('flash:1382952380172'),
			4:Locale.__e('flash:1382952380173')
		},
		'beaver':{
			1:Locale.__e('flash:1382952380174'),
			2:Locale.__e('flash:1382952380175'),
			3:Locale.__e('flash:1382952380176'),
			4:Locale.__e('flash:1382952380177')
		}
	}
	
	private function drawWorkerAvatar():void {
		var sprTip:LayerX = new LayerX();
		
		sprite = new Sprite();
		
		back = Window.backing(120, 140, 10, "textBacking");
		bitmap = new Bitmap();
		
		sprite.addChild(back);
		sprTip.addChild(bitmap);
		sprite.addChild(sprTip);
		addChild(sprite);
		
		sprite.x = 20;
		sprite.y = 160 / 2 - 140 / 2; 
		
		this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		
		sprite.addEventListener(MouseEvent.CLICK, onBearImageClick);
		sprite.addEventListener(MouseEvent.MOUSE_OVER, onAvaOver);
		sprite.addEventListener(MouseEvent.MOUSE_OUT, onAvaOut);
		
		sprTip.tip = function():Object {
			
			var text:String = '';
			var _bear:Object = bear;
			if (bear)
			{
				text = strings[win.settings.worker][1];
				
				if (bear.target == null){
					text = strings[win.settings.worker][2];
				}else{
					
					if (bear.target is Resource)
					{
						if (bear.target.capacity == 0)	text = strings[win.settings.worker][2];
					}
					else
					{
						text = strings[win.settings.worker][2];
					}
				}
				
				if (bear.bear)
				{
					if (bear.bear.flag == "noJam")
					{
						text = strings[win.settings.worker][3];
					}
					else if (bear.bear.flag == "noPlace")
					{
						text = strings[win.settings.worker][4];
					}
				}
			}
			
			return {
				title:text
			}
		}	
	}
	
	private function onOver(e:MouseEvent):void
	{
		label1.alpha = 1;
	}
	
	private function onOut(e:MouseEvent):void
	{
		label1.alpha = 0.5;
	}
	
	private function onAvaOver(e:MouseEvent):void
	{
		if (feedBttn != null && feedBttn.visible == true)
		{
			if (fireSmallBttn) fireSmallBttn.visible = true
		}	
	}
	
	private function onAvaOut(e:MouseEvent):void
	{
		if(fireSmallBttn) fireSmallBttn.visible = false;
	}
	
	private function drawLabel():void
	{
		var text:String;
		if (win.settings.worker == 'bear') {
			text = Locale.__e("flash:1383215332397");
		}else{
			text = Locale.__e("flash:1382952380179");
		}
		label1 = Window.drawText(text,{
				fontSize:20,
				color:0x5d450f,
				borderColor:0xefe5c3,
				textAlign:"center",
				autoSize:"center"
			});
					
		label1.wordWrap = true;
		label1.width = 500;
		
		label1.x = (bg.width - label1.width) / 2;
		label1.y = (bg.height - label1.height) / 2 - 40;
		
		addChild(label1);
		label1.visible = false;
		label1.alpha = 0.5;
	}
}

import units.Bear;
import wins.ProgressBar;
import wins.SimpleWindow;

internal class StackItem extends Sprite
{
	public static const EMPTY:uint = 0;
	public static const FULL:uint = 1;
	public static const PROGRESS:uint = 2;
	
	public var bg:Bitmap;
	private var takeBttn:Button;
	private var bitmap:Bitmap;
	private var worker:WorkerItem;
	private var id:uint;
	public var _state:uint;
	private var bear:Bear;
	private var progressBar:ProgressBar;
	public var Ys:int = 0;
	public var sID:uint;
	
	public var preloader:Preloader = new Preloader();
	
	public function StackItem(sID:uint, worker:WorkerItem, id:uint)
	{
		this.worker = worker;
		this.id = id;
		this.sID = sID;
		bg = Window.backing(100, 100, 10, "textBacking");
		addChild(bg);
		
		bitmap = new Bitmap();
		addChild(bitmap);
		
		addChild(preloader);
		preloader.x = bg.width / 2;
		preloader.y = bg.height / 2 - 10;
		
		Load.loading(Config.getIcon("Material", App.data.storage[sID].preview), onLoad);
		drawBttn();
		state = EMPTY;
	}
	
	
	private function onLoad(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 0.8;
		bitmap.smoothing = true;
		
		bitmap.x = bg.width / 2 - bitmap.width / 2;
		bitmap.y = bg.height / 2 - bitmap.height / 2;
	}
	
	
	public function set state(value:uint):void
	{
		_state = value;
		this.y = Ys;
		switch(_state)
		{
			case EMPTY:
				bg.alpha = 0.5;
				bitmap.alpha = 0;
				takeBttn.visible = false;
			break
			case FULL:
				bg.alpha = 1;
				bitmap.alpha = 1;
				takeBttn.visible = true;
			break
			case PROGRESS:
				this.y = Ys - 4;
				bg.alpha = 1;
				bitmap.alpha = 1;
				takeBttn.visible = false;
			break
		}
	}
	
	public function get state():uint
	{
		return _state;
	}
	
	public function addProgressBar(bear:Bear):void
	{
		this.bear = bear;
		App.self.setOnTimer(working);
		progressBar = new ProgressBar( { win:this, width:bg.width + 10, timeFormat:TimeConverter.M_S} );
		addChild(progressBar);
		progressBar.x = 0 - 5;
		progressBar.y = bg.height - 9;
		working();
		progressBar.start();
	}
	
	private function working():void
	{
		var result:Object = bear.work();
		progressBar.time = result.leftTime;
		progressBar.progress = result.progress;
		if (result.leftTime == 0)
		{
			App.self.setOffTimer(working);
		}
	}
	
	public function drawBttn():void
	{
		takeBttn = new Button(	{
								caption		:Locale.__e("flash:1382952379737"),
								width		:100,
								height		:36,
								fontSize	:18
							});
							
		takeBttn.x = 100 / 2 - takeBttn.width / 2;
		takeBttn.y = 70;
		addChild(takeBttn);
		takeBttn.addEventListener(MouseEvent.CLICK, onTakeBttnClick);
	}
	
	private function onTakeBttnClick(e:MouseEvent):void
	{
		/*if (worker.bear.hasOwnProperty('bear') && worker.bear.started == 0)
		{
			new SimpleWindow( {
				lable:SimpleWindow.ATTENTION,
				title:Locale.__e('flash:1382952379893'),
				text:Locale.__e('flash:1382952380180'),
				popup:true
			}).show();
			return;
		}*/
		worker.win.settings.storageAction(worker.id);
		
		//if (App.social == 'FB') {						
			//ExternalApi._6epush([ "_event", { "event": "gain", "item":App.data.storage[sID].title } ]);
		//}
		
		var icon:Bitmap	= new Bitmap(bitmap.bitmapData);
				icon.smoothing = true;
				icon.scaleX = icon.scaleY = 0.8;
				
			icon.x = App.self.windowContainer.mouseX - this.mouseX + bitmap.x;
			icon.y = App.self.windowContainer.mouseY - this.mouseY + bitmap.y;
			App.self.windowContainer.addChild(icon);
			
			var bttn:* = App.ui.bottomPanel.bttnMainStock;
			var p:Object = { x:bttn.x + App.ui.bottomPanel.x, y:bttn.y + App.ui.bottomPanel.y };
			
			TweenLite.to(icon, 0.8, { x:p.x, y:p.y, onComplete:function():void {
				App.self.windowContainer.removeChild(icon);
				icon = null;
			}});
			
		worker.win.refresh();
	}
	
	public function dispose():void
	{
		bear = null;
		App.self.setOffTimer(working);
	}
}