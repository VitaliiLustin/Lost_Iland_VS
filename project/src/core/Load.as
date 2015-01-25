package core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.UserInterface;
	
	import flash.events.IOErrorEvent;
	import flash.system.LoaderContext
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.LoaderInfo
	

	public class Load 
	{
		
		private static const QUEUESIZE:int = 5;
		private static const WAIT:int = 1;
		private static const LOADING:int = 2;
		private static const LOADED:int = 3;
		private static const ERROR:int = 4;
		
		private static var cache:Dictionary = new Dictionary();
		private static var waitingQueue:Array = new Array();
		private static var loadingQueue:Array = new Array();
		
		public function Load() 
		{
			
		}
		
		public static function loading(url:String, callback:Function, delay:uint = 0, showCursorLoader:Boolean = false, progress:Function = null):* {
			
			if (url.search(/\:\/\/vk\.com/) != -1) {
				callback(new Bitmap(UserInterface.textures.bearAvatar));
				return;
			}
			
			var hash:String = MD5.encrypt(url);
						
			if (cache[hash] != undefined && cache[hash].status == LOADED) {
				callback(cache[hash].data);
				return new Preloader(); //TODO может возвращать прелоадер
			}else if(cache[hash] != undefined && cache[hash].status == WAIT){
				cache[hash]['callbacks'].push(callback);
				return new Preloader(); //TODO может возвращать прелоадер
			}else if(cache[hash] != undefined && cache[hash].status == ERROR){
				return new Preloader(); //TODO может возвращать прелоадер
			}else{
				if(showCursorLoader){
					Cursor.loading = true;
				}
				cache[hash] = { data:null, status:WAIT, callbacks:[callback], loader:true, progress:progress};
			}
			
			waitingQueue.push( { url:url, status:WAIT } );
			
			loadNextInQueue();
		}
		
		public static function getCache(url:String):*{
			var hash:String = MD5.encrypt(url);
			if (cache[hash] != undefined && cache[hash].status == LOADED) {
				return cache[hash].data;
			}
			return null;
		}
		
		public static function addCache(url:String, data:*):void{
			var hash:String = MD5.encrypt(url);
			cache[hash] = {
				data:data,
				status:LOADED
			};
		}
		
		private static function loadNextInQueue():void {
			if (waitingQueue.length == 0) {
				return;
			}
			
			while(waitingQueue.length > 0 && loadingQueue.length < QUEUESIZE){
				var nextToLoad:Object = waitingQueue.shift();
				loadingQueue.push(nextToLoad);
			}
			process();
		}
		
		private static function process():void {
			
			if (loadingQueue.length == 0) {
				loadNextInQueue();
				return;
			}
			

			for each(var target:Object in loadingQueue){
				
				if (target.status == LOADING)
					continue;
				
				target.status = LOADING;
				trace("LOADING: " + target.url);
				
				var loader:Loader = new Loader();
				
				var hash:String = MD5.encrypt(target.url);
				var item:Object = cache[hash];
				
				
				function onComplete(e:Event):void {
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrors);
					loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
					
					item.data = { };
					
					try{
						if (e.target.content.hasOwnProperty('animation')) {
							item.data['animation'] = e.target.content.animation;
						}
						if (e.target.content.hasOwnProperty('smokePoints')) {
							item.data['smokePoints'] = e.target.content.smokePoints;
						}
						if (e.target.content.hasOwnProperty('additionals')) {
							item.data['additionals'] = e.target.content.additionals;
						}
						if (e.target.content.hasOwnProperty('sprites')) {
							item.data['sprites'] = e.target.content.sprites;
						}else{
							item.data = e.target.content;
						}
						
						//loader.unloadAndStop(true);
						//loader = null;
						
					}catch (err:SecurityError) {
						item.data = loader;
					}
					
					item.status = LOADED;
					if (item.hasOwnProperty('loader') && item.loader == true) {
						Cursor.loading = false;
					}
					if (item.callbacks.length > 0) {
						for each(var callback:Function in item.callbacks) {
							callback(item.data);
						}
						item.callbacks = [];
					}
					
					var index:int = loadingQueue.indexOf(target);
					if(index != -1){
						loadingQueue.splice(index, 1);
					}
					
					
					
					loadNextInQueue();	
				}
				
				function onProgress(e:ProgressEvent):void
				{
					var value:Number = e.bytesLoaded / e.bytesTotal;
					if (item.progress != null) item.progress(value);
				}
				
				function onErrors(e:IOErrorEvent):void {
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrors);
					trace("Error loading: " + target.url);
					
					target.status = ERROR;
					
					var index:int = loadingQueue.indexOf(target);
					if(index != -1){
						loadingQueue.splice(index, 1);
					}
					loadNextInQueue();
				}
				
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrors);

				loader.load(new URLRequest(target.url), new LoaderContext(true));
			}
		}
		
		private static function onSecurityError(e:SecurityErrorEvent):void {
			ExternalInterface.call('console.log("'+e.toString()+'")');
		}
		
		private static function onError(e:IOErrorEvent):void {
			trace('Error happend');
		}
		
		
		public static function loadText(url:String, callback:Function):void {
			var loader:URLLoader = new URLLoader();
			trace("LOADING: " + url);
			loader.addEventListener(Event.COMPLETE, function onTextComplete(e:Event):void {
				var data:* = e.target;
				callback(data);
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function onTextError(e:IOErrorEvent):void {
				trace("Error loading: " + url);
			});
			loader.load(new URLRequest(url));
		}
		
		
		public static function sendFile(url:String, bytes:ByteArray, filename:String, imagename:String, mimetype:String, callback:Function):void
		{
			var ldr:MultipartURLLoader = new MultipartURLLoader();
			ldr.addEventListener(Event.COMPLETE, callback);
			ldr.addEventListener(IOErrorEvent.IO_ERROR, onErrors);
			
			ldr.addFile(bytes, filename, imagename, mimetype);
			ldr.load(url);
			
			function onErrors(e:IOErrorEvent):void {
				Log.alert("Error loading: " + e.toString());
			}
		}
	}
}