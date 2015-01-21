package core 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	import ui.UserInterface;
	import wins.AchivementsWindow;
	import wins.ErrorWindow;
	import wins.SimpleWindow;
	//import com.adobe.serialization.json.JSON;

	public class Post 
	{
		private static const BUSY:uint = 1;
		private static const FREE:uint = 0;
		
		private static var queue:Vector.<Object> = new Vector.<Object>();
		private static var sends:Vector.<Object> = new Vector.<Object>();
		
		private static var status:uint = Post.FREE;
		
		private static var loader:URLLoader;
		public static var archive:Array = [];
		public static var time1:uint = 0;
		public static var time2:uint = 0;
		
		public function Post() 
		{
			
		}
		
		public static function send(action:Object, callback:Function, params:Object = null):void {
			action['ref'] = App.ref || "";
			queue.push( { action:action, callback:callback, params:params } );
			
			if (App.ui && App.ui.bottomPanel)
				App.ui.bottomPanel.addPostPreloader();
			
			if (status == FREE) {
				request();
			}
		}
		
		private static function request():void {
			
			/*if (App.user && App.user.quests && App.user.quests.tutorial)
				App.user.quests.lockFuckAll();*/
			
			status = BUSY;
			
			var item:Object = queue[0];
			
			var result:String = '';

			for each(var action:* in item.action) {
				result += action + '';
			}
			
			var pid:Number = new Date().time;
			var crc:String = MD5.encrypt('ytf$%$yuGFis*&udh' + result + pid + '');
			var data:String = JSON.stringify(item.action);
			
			time1 = getTimer();
			trace("POST: " + data);
			addToArchive('\n'+data+'  '+time1);
			
			var requestVars:URLVariables = new URLVariables();
			requestVars.data = data;
			requestVars.crc = crc;
			requestVars.pid = pid;
			
			var req:URLRequest = new URLRequest(Config.getUrl());
			req.method = URLRequestMethod.POST;
			req.data = requestVars;
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
			loader.load(req);
			
		}
		
		private static function onComplete(e:Event):void {
			
			/*if (App.user && App.user.quests && App.user.quests.tutorial)
				App.user.quests.unlockFuckAll();
			*/	
			URLLoader(e.target).removeEventListener(Event.COMPLETE, onComplete);
			URLLoader(e.target).removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			URLLoader(e.target).removeEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
			
			var item:Object = queue.shift();
			
			time2 = getTimer();
			
			trace(e.currentTarget.data);
			addToArchive(e.currentTarget.data.replace(/\n/, '') + ' d:'+(time2 - time1)+'  '+time2);
			trace('resp -= ');
			try{
				var response:Object = JSON.parse(e.currentTarget.data);
			}catch (e:Error) {
				status = FREE;
				return;
			}
			
			//Обновляем серверное время и удаляем ненужную переменную
			var progress:*;
			if (response.data != null) {
				if(response.data.hasOwnProperty('__time')) {
					App.time = response.data['__time'];
					delete response.data['__time'];	
				}
				
				if(response.data.hasOwnProperty('__took')) {
					delete response.data['__took'];	
				}
				
				if (response.data.hasOwnProperty('__queststate')) {
					progress = new Object();
					//progress = response.data['__queststate'];
					for (var qID:* in response.data['__queststate']) {
						if (App.data.quests.hasOwnProperty(qID)) {
							progress[qID] = response.data['__queststate'][qID];
						}
					}
					delete response.data['__queststate'];	
				}
				
				//achivements
				if (response.data.hasOwnProperty('__achstate')) {
					//progress = new Object();
					
					for (var ach:* in response.data.__achstate) {
						if (!App.user.ach[ach]) {
							App.user.ach[ach] = response.data.__achstate[ach];
							continue;
						}
						for (var mis:* in response.data.__achstate[ach]) {
							App.user.ach[ach][mis] = response.data.__achstate[ach][mis];
						}
						
						AchivementsWindow.checkAchProgress(ach);
					}
					
					
					
					/*for (var qID:* in response.data['__achstate']) {
						if (App.data.quests.hasOwnProperty(qID)) {
							progress[qID] = response.data['__achstate'][qID];
						}
					}*/
					delete response.data['__achstate'];	
				}
				
				//Устанавливаем время полночи
				if(response.data.hasOwnProperty('midnight')) {
					if (response.data['midnight'] != undefined) {
						App.midnight = response.data.midnight;
						App.nextMidnight = App.midnight + 24*3600;
						delete response.data['midnight'];	
					}
				}
			}
			
			item.callback(response.error, response.data, item.params);
			
			if(App.ui && App.ui.bottomPanel)App.ui.bottomPanel.removePostPreloader();
			
			if (progress) {
				App.user.quests.progress(progress);
			}
			
			status = FREE;
			if (queue.length > 0) {
				request();
			}
		}
		
		public static function clear():void
		{
			queue = new Vector.<Object>;
		}
		
		private static function OnIOError(event:IOErrorEvent):void 
		{
			URLLoader(event.target).removeEventListener(Event.COMPLETE, onComplete);
			URLLoader(event.target).removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
			
			//Показываем ошибку, только если у нас уже не осталось flash:1382952379984пасных IP адресов
			if (Config._mainIP.length == 0) {
				new SimpleWindow( {
					title:Locale.__e('flash:1382952379725'),
					text:Locale.__e('flash:1382952379726'),
					label:SimpleWindow.ERROR
				});
			}
		}
		
		private static function OnHttpStatus(event:HTTPStatusEvent):void {
			
			
			
			switch(event.status) {
				case 301:
				case 302:
				case 303:
				case 304:
				case 305:
				case 307:
				case 200: break;
				default: 
				
				
					URLLoader(event.target).removeEventListener(Event.COMPLETE, onComplete);
					//loader.removeEventListener(IOErrorEvent.IO_ERROR, OnIOError);
					URLLoader(event.target).removeEventListener(HTTPStatusEvent.HTTP_STATUS, OnHttpStatus);
					
					//URLLoader(event.target).close();
					
					if (Config.changeIP()) {
						//trace('Change IP to ' + Config._curIP);
						status = FREE;
						if (queue.length > 0) {
							request();
						}
						return;
					}
					
					var item:Object = queue.shift();
					item.callback(1000, null, item.params);
				
					/*status = FREE;
					if (queue.length > 0) {
						request();
					}*/
					
					Errors.show(1000, {code:event.status } );
					break;
			}
		}
		
		public static const STATISTIC_INVITE:String = 'invite';
		public static const STATISTIC_WALLPOST:String = 'wallpost';
		public static function statisticPost(type:String):void 
		{
			Post.send({
				ctr:'User',
				act:'stat',
				uID:App.user.id,
				type:type
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}	
			});
		}
		
		
		public static function addToArchive(data:String, checkOnLength:Boolean = true):void
		{
			if (data.length > 230 && checkOnLength)
			{
				data = "\ntoo long\n";
			}
			
			if (archive.length > 80)
				archive.shift();
			
			var _data:String = '\n'+data
			archive.push(_data);
			
			if(App.console != null)
				App.console.log(_data);
		}
	}

}