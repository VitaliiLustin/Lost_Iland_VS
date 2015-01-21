package ui 
{
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class InstanceCloud extends CloudsMenu
	{
		
		public function InstanceCloud(onEvent:Function, target:*, sID:int, settings:Object = null) 
		{
			super(onEvent, target, sID, settings);
		}
		
		private var iconsCont:Sprite = new Sprite();
		public function init(arrSids:Array, startTime:int, endTime:int):void
		{
			var posX:int = 0;
			var posY:int = 0;
			
			var count:int = arrSids.length;
			var center:Number;
			
			if (count % 2 == 0) center = count / 2  + 0.5;
			else center = Math.ceil(count / 2);
			
			for (var i:int = 0; i < arrSids.length; i++ ) {
				var container:Sprite = new Sprite();
				
				var bg:Bitmap = new Bitmap(Window.textures.buildingsActiveBacking);
				bg.smoothing = true;
				bg.scaleX = bg.scaleY = 0.7;
				container.addChild(bg);
				
				var icon:Bitmap = getIconBtm(arrSids[i]);
				icon.height = bg.height - 8;
				icon.scaleX = icon.scaleY;
				icon.smoothing = true;
				if (arrSids[i] == 292)
				{
					icon.x = (bg.width - icon.width) / 2 + 3;
					icon.y = (bg.height - icon.height) / 2 - 2;
				}
				else {
					icon.x = (bg.width - icon.width) / 2 + 1;
					icon.y = (bg.height - icon.height) / 2 - 3;
				}
				
				
				container.addChild(icon);
				if (target.sid == 239) {
					container.x = posX;
					container.y = posY - 65;
				}else {
					container.x = posX - 35;
					container.y = posY + 25;
				}
				
				
				if (i + 1 == Math.floor(center) || i + 1 == Math.ceil(center)) {
					if (center  == i + 1) 
						posY += 10;
					else if (i + 1 > center) 
						posY += 10;
				}else if (i+1 > Math.ceil(center)) {
					posY += 10;
				}else {
					posY -= 10;
				}
				
				posX += bg.width + 6;
				
				iconsCont.addChild(container);
			}
		
			addChild(iconsCont);
			
			addProgressBar();
			if (target.sid == 239) {
				progressContainer.x = (iconsCont.width - progressContainer.width) / 2;
				progressContainer.y = iconsCont.height - 60;
			}else {
				progressContainer.x = (iconsCont.width - progressContainer.width) / 2 - 35;
				progressContainer.y = iconsCont.height + 4 + 30;
			}
			
			
			setProgress(startTime, endTime);
		}
		
		public function updateTime(stTime:int, edTime:int):void {
			startTime = stTime;
			endTime = edTime;
		}
		
		private var callBack:Function;
		private var rewardsCont:Sprite = new Sprite();
		private var arrRewards:Array = [];
		public var rewIcon:RewardIcon
		public function showReward(rewards:Object, callBack:Function = null):void
		{
			var posX:int = 0;
			var count:int = 0;
			var rewWidth:int;
			
			//for (var itm:* in rewards) {
				//var container:Sprite = new Sprite();
				
				rewIcon = new RewardIcon(242, callBack);
				arrRewards.push(rewIcon);
				
				/*container.*/addChild(rewIcon);
				
				count++;
				
				//container.x = posX;
				rewIcon.x = posX;
				
				posX += rewIcon.bgWidth + 6;
				
				//rewardsCont.addChild(container);
				//rewardsCont.addChild(rewIcon);
				rewWidth = rewIcon.bgWidth;
			//}
			rewIcon.x = (iconsCont.width - (count * rewWidth + (count -1) * 6)) / 2;
			rewIcon.y = rewIcon.y + /*rewIcon.height*/ 116 + 16;
			
			//rewardsCont.x = (iconsCont.width - (count * rewWidth + (count -1) * 6)) / 2;
			//rewardsCont.y = iconsCont.y + iconsCont.height + 16;
			
			
			//addChild(rewardsCont);
			if (App.user.quests.tutorial)
				rewIcon
		}
		
		override public function stopProgress():void
		{
			App.self.setOffTimer(progress);
			isProgress = false;
			stopedProgress = true;
			progressContainer.visible = false;
			//if (iconBttn) 
				//iconBttn.buttonMode = iconBttn.mouseEnabled = true;
			//doIconEff();
		}
		
		private function getIconBtm(sid:int):Bitmap 
		{
			var icon:Bitmap
			switch(sid) {
				case 162:
					icon = new Bitmap(UserInterface.textures.manIcon);
				break;
				case 163:
					icon = new Bitmap(UserInterface.textures.womanIcon);
				break;
				case 292:
					icon = new Bitmap(UserInterface.textures.stumpyInstanceIco);
				break;
				default:
					icon = new Bitmap(UserInterface.textures.manIcon);
			}
			return icon;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			for (var i:int = 0; i < arrRewards.length; i++ ) {
				arrRewards[i].dispose();
				arrRewards[i] = null;
			}
			arrRewards.splice(0, arrRewards.length);
			arrRewards = null;
			
			if (rewardsCont && contains(rewardsCont))
				removeChild(rewardsCont);
				
			if (iconsCont && contains(iconsCont))
				removeChild(iconsCont);
				
			iconsCont = null;
			rewardsCont = null;
		}
		
	}

}

import buttons.ImageButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import wins.Window;

internal class RewardIcon  extends Sprite {
	
	public var bgWidth:int = 65;
	public var bgHeight:int = 68;
	
	private var callBack:Function;
	public var bttn:ImageButton;
	
	public function RewardIcon(sid:int, callBack:Function = null) {
		
		this.callBack = callBack;
		
		bttn = new ImageButton(new BitmapData(1,1,true,0));
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		addChild(iconCont);
		iconCont.addChild(bttn);
		bttn.y -= 14;
		bttn.x -= 6;		
		Load.loading(Config.getImage('interface', 'box_open'), function(data:*):void {
			
			bttn.bitmapData = data.bitmapData;
			bttn.bitmap.smoothing = true;
			
			addGlow(Window.textures.iconEff, 0);
		});
	}
	
	private var iconCont:LayerX = new LayerX();
	private var container:Sprite = new Sprite();
	private var startInterval:int = 0;
	private var interval:int = 0;
	public function addGlow(bmd:BitmapData, layer:int, scale:Number = 1):void
	{
		var btm:Bitmap = new Bitmap(bmd);
		container = new Sprite();
		container.addChild(btm);
		btm.scaleX = btm.scaleY = scale;
		btm.smoothing = true;
		btm.x = -btm.width / 2;
		btm.y = -btm.height / 2;
		
		addChildAt(container, layer);
		
		
		container.mouseChildren = false;
		container.mouseEnabled = false;
		
		container.x = bgWidth / 2;
		container.y = bgHeight / 2;
		
		App.self.setOnEnterFrame(rotateBtm);
		if(iconCont)iconCont.startGlowing();
		
		var that:* = this;
		startInterval = setInterval(function():void {
			clearInterval(startInterval);
			interval = setInterval(function():void {
				iconCont.pluck();
			}, 10000);
		}, int(Math.random() * 3000));
	}
	
	private function rotateBtm(e:Event):void 
	{
		container.rotation += 1;
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (callBack != null) callBack();
	}
	
	public function dispose():void
	{
		if (iconCont && contains(iconCont)) removeChild(iconCont);
		iconCont = null;
		
		if (container && contains(container)) removeChild(container);
		container = null;
		
		removeEventListener(MouseEvent.CLICK, onClick);
		
		App.self.setOffEnterFrame(rotateBtm);
		clearInterval(startInterval);
		clearInterval(interval);
	}
}