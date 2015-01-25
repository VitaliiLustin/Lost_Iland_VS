package wins.elements 
{
	import buttons.MenuButton;
	import flash.events.MouseEvent;
	import wins.ShopWindow;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class ShopMenu extends Sprite
	{
		/*
				'0'=>array('label'=>'Невидимый','rel'=>'0'),  
				'1'=>array('label'=>'Материалы','rel'=>'1'),
				'2'=>array('label'=>'Растения','rel'=>'2'),
				'3'=>array('label'=>'Декорации','rel'=>'3'),
				'4'=>array('label'=>'Здания','rel'=>'4'),
				'5'=>array('label'=>'Персонажи','rel'=>'5'),
				'6'=>array('label'=>'Инструменты','rel'=>'6'),
				'7'=>array('label'=>'Важное','rel'=>'7'),
				'8'=>array('label'=>'Одежда','rel'=>'8'),
				'9'=>array('label'=>'Фантазия','rel'=>'9'),
				'10'=>array('label'=>'Сны','rel'=>'10'),
				'11'=>array('label'=>'Зоны','rel'=>'11'),
				'12'=>array('label'=>'Прибыль','rel'=>'12'),
				'13'=>array('label'=>'Животные','rel'=>-1),
				'14'=>array('label'=>'Дикие','rel'=>'13'),
				'15'=>array('label'=>'Птицы','rel'=>'13'),
				'16'=>array('label'=>'Звери','rel'=>'13'),
			*/
		public var menuBttns:Array = [];
		public var subBttns:Array = [];
		public var window:ShopWindow;
		
		public static var _currBtn:int = 0;
		
		public var menuSettings:Object = {
				100:{ order:0, 	title:Locale.__e("flash:1382952379743") 	 },
				14: { order:3,	title:Locale.__e("flash:1396612468985") 	 },
				3: 	{ order:5,	title:Locale.__e("flash:1382952380294") },
				4: 	{ order:2,	title:Locale.__e("flash:1382952380292") },
				13: { order:6,	title:Locale.__e("flash:1396612503921") },
				7: 	{ order:7,	title:Locale.__e("flash:1382952380295") },
				5: 	{ order:8,	title:Locale.__e("flash:1402910864995") }
			};
			
		public var arrSquence:Array = [100, 4, 14, 5, 3, 7, 13];
			
		public function ShopMenu(window:ShopWindow)
		{
			this.window = window;
			drawSubmenuBg();
			App.data.storage
			for (var i:int = 0; i < arrSquence.length; i++ ) {
				for (var item:* in menuSettings) {
					if (item == arrSquence[i]) {
						var settings:Object = menuSettings[item];
						settings['type'] = item;
						//settings['onMouseDown'] = onMenuBttnSelect;
						settings['fontSize'] = 22;//24;
						
						settings['widthPlus'] = 35;//50
						
						if (settings.order == 0) {
							settings["bgColor"] = [0xade7f1, 0x91c8d5];
							settings["bevelColor"] = [0xdbf3f3, 0x739dac];
							settings["fontBorderColor"] = 0x53828f;
							settings['active'] = {
								bgColor:				[0x73a9b6,0x82cad6],
								bevelColor:				[0x739dac, 0xdbf3f3],	
								fontBorderColor:		0x53828f				//Цвет обводки шрифта		
							}
						}
						
						var bttn:MenuButton = new MenuButton(settings);
						menuBttns.push(bttn);
						bttn.addEventListener(MouseEvent.CLICK, onMenuBttnSelect);
					}
				}
			}
			
			/*for (var item:* in menuSettings) {
				var settings:Object = menuSettings[item];
					settings['type'] = item;
					settings['onMouseDown'] = onMenuBttnSelect;
					settings['fontSize'] = 24;
					
					settings['widthPlus'] = 60;
					
					if (settings.order == 0) {
						settings["bgColor"] = [0xfec37f, 0xfc8524];
						settings["bevelColor"] = [0xffe294, 0xbe5e24];
						settings["fontBorderColor"] = 0x914d24;
						settings['active'] = {
							bgColor:				[0xb25000,0xdb8627],
							borderColor:			[0x504529,0xe0ac0e],	//Цвета градиента
							bevelColor:				[0x863707,0xddab14],	
							//fontColor:				0xffffff,				//Цвет шрифта
							fontBorderColor:		0x914d24				//Цвет обводки шрифта		
						}
					}
					
				menuBttns.push(new MenuButton(settings));
			}
			menuBttns.sortOn('order');*/
			
			menuBttns[_currBtn].selected = true;
			
			var bttnsContainer:Sprite = new Sprite();
			
			var offset:int = 0;
			for (i = 0; i < menuBttns.length; i++)
			{
				menuBttns[i].x = offset;
				offset += menuBttns[i].settings.width + 4;
				bttnsContainer.addChild(menuBttns[i]);
			}
			
			bttnsContainer.x = ( submenuBg.width - bttnsContainer.width ) / 2;
			addChild(bttnsContainer);
			
			this.x = (window.settings.width - submenuBg.width) / 2;
			this.y = 5;
		}
		
		private function clearSubmenu():void {
			
			for each(var bttn:SubMenuBttn in subBttns) 
			{
				submenuContainer.removeChild(bttn);
			}
			if(submenuContainer) removeChild(submenuContainer);
			submenuContainer = null
			subBttns = [];
		}
		
		private var submenuContainer:Sprite
		private function drawSubmenu(section:int):void {
			
			var childs:Object = menuSettings[section]['childs'];
			childs['all'] = { order:0,	title:Locale.__e("flash:1382952380301"), childs:[]};
			
			for (var item:* in childs) {
				var settings:Object = childs[item];
					settings['type'] = item;
					settings['onMouseDown'] = onSubMenuBttnSelect;
					settings['height'] = 36;
					settings['parentSection'] = section;
					
					if (item != 'all')
						childs['all'].childs.push(item);
					
				subBttns.push(new SubMenuBttn(settings));
			}
			subBttns.sortOn('order');
			submenuContainer = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < subBttns.length; i++)
			{
				subBttns[i].x = offset;
				offset += subBttns[i].settings.width + 4;
				submenuContainer.addChild(subBttns[i]);
			}
			
			submenuContainer.x = 10;// (submenuBg.width - submenuContainer.width ) / 2;
			submenuContainer.y = submenuBg.y + 2;
			addChild(submenuContainer);
			
			//subBttns[0].selected = true;
			subBttns[0].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		private var submenuBg:Sprite;
		private function drawSubmenuBg():void 
		{
			submenuBg = new Sprite();
			submenuBg.graphics.lineStyle(0x000000, 0, 0, true);	
			submenuBg.graphics.beginFill(0xb8a574);
			submenuBg.graphics.drawRoundRect(0, 0, window.settings.width - 120, 40, 25, 25);
			submenuBg.graphics.endFill();
			//this.addChild(submenuBg);
			submenuBg.y = 45;
		}
		
		public function onMenuBttnSelect(e:MouseEvent):void
		{
			for each(var bttn:MenuButton in menuBttns) {
				bttn.selected = false;
			}
			e.currentTarget.selected = true;
			
			ShopWindow.history.section = arrSquence[menuBttns.indexOf(e.currentTarget)];
			
			_currBtn = menuBttns.indexOf(e.currentTarget);
			
			clearSubmenu();
			
			if (menuSettings[e.currentTarget.type].hasOwnProperty('childs'))
				drawSubmenu(e.currentTarget.type);
			else	
				window.setContentSection([e.currentTarget.type]);
		}		
		
		public function onSubMenuBttnSelect(e:MouseEvent):void
		{
			for each(var bttn:SubMenuBttn in subBttns) {
				bttn.selected = false;
			}
			e.currentTarget.selected = true;
			
			if (e.currentTarget.type == 'all')
				window.setContentSection(e.currentTarget.settings.childs);	
			else
				window.setContentSection([e.currentTarget.type]);	
			
		}	
	}
}

import buttons.MenuButton;
internal class SubMenuBttn extends MenuButton
{
	public function SubMenuBttn(settings:Object = null) {
		
		settings["bgColor"] = settings.bgColor || [0xcfbd8c, 0xb19d6f];	
		settings["bevelColor"] = settings.bevelColor || [0x7d6d44, 0x70603a];	
		settings["fontColor"] = settings.fontColor || 0xffffff;				
		settings["fontBorderColor"] = settings.fontBorderColor || 0x786840
		settings["shadow"] = false;
		
		settings["active"] = {
				bgColor:				[0xf7efd2,0xfffade],
				bevelColor:				[0x7f6e43,0x7f6e43],	
				fontColor:				0x705f36,	
				fontBorderColor:		0xffffff	
			}
		super(settings);
	}
}
