package 
{
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import mx.controls.Alert;
	import flash.filesystem.*;
	import mx.events.CloseEvent;
	import mx.graphics.codec.JPEGEncoder;
	
	/**
	 * ...
	 * @author 
	 */
	public class Save 
	{
		public static var swfPath:String;
		public static var projectDirectory:File = File.applicationDirectory;
		public static var projectPath:String;
		public static var name:String;
		
		public static var gridDelta:int = 0;
		public static var mapID:uint = 0;
		
		public function Save()
		{
			
		}
		
		public static function loadSavedGrid(callback:Function):void
		{
			var file:File = File.applicationDirectory.resolvePath("markers.txt"); 
			file.addEventListener(Event.COMPLETE, onLoadMarkersData); 
			file.load(); 
			
			function onLoadMarkersData(event:Event):void 
			{ 
				var str:String; 
				var bytes:ByteArray = file.data; 
				str = bytes.readUTFBytes(bytes.length); 
				var data:Object = JSON.parse(str);
				callback(data as Array);
			}
		}
		
		public static function generateProject():void
		{
			if (Map.main.mapName.text != "")	name = Map.main.mapName.text
			else{
				Alert.show('Введите название карты!');
				return;
			}
			
			var directory:File = projectDirectory.resolvePath(name + "/");
			var targetParent:File = directory.parent;
			targetParent.createDirectory();
			
			//Создаем директории
			var target:File = directory.resolvePath("obj/temp.txt");
			targetParent = target.parent;
			targetParent.createDirectory();
			
			var src:File = directory.resolvePath("src/");
			targetParent = src.parent;
			targetParent.createDirectory();
			
			var sprites:File = src.resolvePath("sprites/");
			var replaces:Object = generateContent(sprites);
			
			//Генерируем файл проекта
			var as3proj:File = File.applicationDirectory.resolvePath('templates/project.as3proj');
			var stream:FileStream = new FileStream(); 
			stream.open(as3proj, FileMode.READ); 
			var as3projData:String =  stream.readMultiByte(stream.bytesAvailable, File.systemCharset);
			stream.close();  
			as3projData = as3projData.replace(/\{path\}/, swfPath);
			as3projData = as3projData.replace(/\{name\}/g, name);
			
			//Сохраняем файл проекта
			as3proj = directory.resolvePath(name + '.as3proj');
			stream.open(as3proj, FileMode.WRITE); 
			stream.writeMultiByte(as3projData, File.systemCharset);
			stream.close(); 
			
			
			//Генерируем основной AS3 файл
			var as3:File = File.applicationDirectory.resolvePath('templates/code.as');
			stream.open(as3, FileMode.READ); 
			var as3Data:String =  stream.readMultiByte(stream.bytesAvailable, File.systemCharset);
			stream.close();
			
			as3Data = as3Data.replace(/\{name\}/g, name);
			as3Data = as3Data.replace(/\{embed\}/, replaces.embed);
			as3Data = as3Data.replace(/\{grid\}/, replaces.grid);
			as3Data = as3Data.replace(/\{elements\}/, replaces.elements);
			as3Data = as3Data.replace(/\{vars\}/, replaces.vars);
			
			as3 = directory.resolvePath('src/'+name + '.as');
			stream.open(as3, FileMode.WRITE); 
			stream.writeMultiByte(as3Data, File.systemCharset);
			stream.close();
			
			var appPath:String = File.applicationDirectory.nativePath;
			
			var batDir:File = as3proj.parent.parent;
			var batValue:String = '"C:\\Program Files (x86)\\FlashDevelop\\Tools\\fdbuild\\fdbuild.exe" "' + batDir.nativePath + '\\' + name + '\\' + name + '.as3proj" -compiler "C:\\Program Files (x86)\\FlashDevelop\\Tools\\flexsdk" -notrace -library "C:\\Program Files (x86)\\FlashDevelop\\Library"' + ";\n"+'java -jar '+appPath+'\\reducer.jar -input '+swfPath+'\\'+name+'.swf -output '+swfPath+'\\'+name+'.swf -quality 0.6'+"\n\n";
			var batFile:File = batDir.resolvePath("as3projs.bat");
			stream.open(batFile, FileMode.APPEND); 
			stream.writeMultiByte(batValue, "utf-8");
			stream.close();
			
			
			Alert.show("Проект успешно сохранен. Запустить проект?", "Успех!", Alert.YES|Alert.NO, Map.main.holder, alertClickHandler);
			function alertClickHandler(e:CloseEvent):void {
				if (e.detail == Alert.YES) {
					as3proj.openWithDefaultApplication();
				}
			}
		}
		
		/**
		 * Генереруем наполнение острова
		 * @param	event
		 */
		public static function generateContent(sprites:File):Object
		{
			var targetParent:File = sprites.parent;
				targetParent.createDirectory();
				
			var bmp:Bitmap = Map.self._tile;
			var encoder:JPGEncoder = new JPGEncoder(80); 
			var pixels:ByteArray = encoder.encode(bmp.bitmapData);
			var image:File = sprites.resolvePath("tile.jpg");
			var stream:FileStream = new FileStream(); 
				stream.open(image, FileMode.WRITE); 
				stream.writeBytes(pixels);
				stream.close();
				
			var embed:String 		= "";
			var elements:String 	= "";
			var grid:String 		= "";
			var vars:String 		= "";
			
			embed += "\n\t\t[Embed(source=\"sprites/" + "tile.jpg" + "\", mimeType=\"image/jpeg\")]\n\t\tprivate var Tile:Class;\n";
			embed += "\t\t\public var tile:BitmapData = new Tile().bitmapData";
			
			elements = "\n\t\tpublic var elements:Array = [\n";
			
			for (var i:int = 0; i < Map.units.length; i++)
			{
				var unit:Unit = Map.units[i];
				elements += "\t\t\t\t\t{name:'" + unit.label + "', url:\"" + unit.url + "\", x:" + unit.x + ", y:" + unit.y + ", width:" + unit.width + ", height:" + unit.height + ", depth:" + Map.self.mUnits.getChildIndex(unit) + "}";
				if (i != Map.units.length - 1)
				{
					elements += ","
				}
				elements += "\n";
			}
			
			elements += "\t\t\t\t\t];";
			
			grid += "public var gridData:Object = JSON.parse('" + JSON.stringify(Map.loadedMarkersData) + "');";
			
			vars += "public var id:uint = "			+Map.main.mapID.text+";\n";
			vars += "\t\tpublic var gridDelta:int = "	+gridDelta+		";\n";
			vars += "\t\tpublic var isoCells:uint = "	+Map.X+			";\n";
			vars += "\t\tpublic var isoRows:uint = "	+Map.Z+			";\n";
			vars += "\t\tpublic var mapWidth:uint = "	+Map.mapWidth+	";\n";
			vars += "\t\tpublic var mapHeight:uint = " 	+Map.mapHeight+	";";
			
			return {
				embed:embed,
				grid:grid,
				elements:elements,
				vars:vars
			}
		}
		
		/**
		 * Выбираем директорию для проекта
		 */
		public static function projectHandler(event:Event):void {
			
			try
			{
				projectDirectory.browseForDirectory("Укажите директорию");
				projectDirectory.addEventListener(Event.SELECT, directorySelected);
			}
			catch (error:*)
			{
				trace("Failed:", error.message)
			}

			function directorySelected(event:Event):void
			{
				projectDirectory.removeEventListener(Event.SELECT, directorySelected);
				
				projectDirectory = event.target as File;
				projectPath = projectDirectory.nativePath;
				Map.main.pathProj.text = projectPath;
			}
		}
		
		/**
		 * Деректория для SWF
		 * @param	event
		 */
		public static function pathHandler(event:Event):void {
			
			var directory:File = File.applicationDirectory;
			
			try
			{
				directory.browseForDirectory("Укажите директорию");
				directory.addEventListener(Event.SELECT, directorySelected);
			}
			catch (error:*)
			{
				trace("Failed:", error.message)
			}
			
			function directorySelected(event:Event):void
			{
				directory = event.target as File;
				swfPath = directory.nativePath;
				Map.main.path.text = swfPath;
			}
		}
		
		public static function saveMarkersData():void
		{
			var data:Array = [];
			
			for (var i:int = 0; i < Map.X; i++)
			{
				var row:Array = [];
				for (var j:int = 0; j < Map.Z; j++ )
				{
					var obj:Object = {
						b:Map.markersData[i][j].b,
						p:Map.markersData[i][j].p,
						z:Map.markersData[i][j].z
					}
					row.push(obj);
				}
				data.push(row);
			}
			
			var result:String = JSON.stringify(data);
			
			var file:File = File.applicationStorageDirectory.resolvePath("markers.txt"); 
			file.addEventListener(Event.COMPLETE, onSaveMarkersData);
			file.save(result);
		}
		
		private static function onSaveMarkersData(event:Event):void 
		{
			Alert.show('Cетка карты сохранена');
		}
	}
}