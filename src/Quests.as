package
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.loading.data.VideoLoaderVars;
	import core.Debug;
	import core.Log;
	import core.Post;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.BottomPanel;
	import ui.QuestIcon;
	import ui.QuestPanel;
	import ui.SystemPanel;
	import ui.UserInterface;
	import units.Animal;
	import units.AnimationItem;
	import units.Bear;
	import units.Bridge;
	import units.Building;
	import units.Factory;
	import units.Field;
	import units.Floors;
	import units.Mining;
	import units.Missionhouse;
	import units.Moneyhouse;
	import units.Pigeon;
	import units.Plant;
	import units.Resource;
	import units.Storehouse;
	import units.Tribute;
	import units.Unit;
	import wins.BankWindow;
	import wins.ChapterWindow;
	import wins.CharactersWindow;
	import wins.CollectionWindow;
	import wins.DialogWindow;
	import wins.ErrorWindow;
	import wins.FreeGiftsWindow;
	import wins.GiftWindow;
	import wins.InviteSocialFriends;
	import wins.JamWindow;
	import wins.QuestMsgWindow;
	import wins.QuestRewardWindow;
	import wins.QuestWindow;
	import wins.ShopWindow;
	import wins.SimpleWindow;
	import wins.StockWindow;
	import wins.WindowEvent;
	
	public class Quests 
	{
		public var data:Object = { };
		
		public var opened:Array = []; 
		
		public var tutorial:Boolean = false;
		public var needIntro:Boolean = false;
		//private var startTutorial:Boolean = false;
		
		public static var targetSettings:Object;
		
		public static var initQuestRule:Boolean = false;
		public var chapters:Array = [];
		public var exclude:Object = { };
		
		public static var questMission:int = 0;
		
		public function Quests(quests:Object)
		{
			data = quests;
			
			for (var questID:* in App.data.quests) {
				if (!App.data.quests[questID].hasOwnProperty('ID'))
				delete App.data.quests[questID];
			}
			App.self.addEventListener(AppEvent.ON_UI_LOAD, init);
		}
		
		private var checked:Boolean = false;
		public function checkTutorialFinish():void 
		{
			if(!checked && data[96] && data[96].finished > 0){
				tutorial = false;
				checked = true;
				unlockFuckAll();
				stopTrack();
				Tutorial.watchOnTarget = null;
				Tutorial.focusOnTarget = null;
				setTimeout(function():void {
					App.self.dispatchEvent(new AppEvent(AppEvent.ON_FINISH_TUTORIAL));
					User.checkBoxState = CheckboxButton.CHECKED;
					App.ui.salesPanel.visible = true;
				},1000)
			}
		}
		
		public function init(e:AppEvent):void
		{
			if(App.user.id == '1')
				return;
			for each(var item:Object in App.data.updates) {
				if (item['quests'] != undefined) {					
					var qID:* = item['quests'];
					var has:Boolean = false
					
					
					if (item['social'].hasOwnProperty(App.social))
						has = true;
					
					/*for each(var social:* in item['social']) {
						if (social == App.social)	
							has = true;
					}*/
					if (!has)
						exclude[qID] = qID;
				}
			}
			
			// Записываем главы, которые нам встречались
			for (id in data) {
				if (App.data.quests[id] == null) {
					delete data[id];
					continue;
				}
				inNewChapter(App.data.quests[id].chapter)
			}
			
			for (var id:* in App.data.quests) {
				
				if (exclude[id] != undefined) {
					var parentID:int = App.data.quests[id].parent;
					var updateID:String = App.data.quests[id].update || null;
					//delete App.data.quests[id];
					deletedQuests.push(id);
					deleteAllChildrens(id, parentID, updateID);
					
				}	
					
				openChilds(id);
			}
			removeDeletedQuests();
			// Проверяем акции
			//checkPromo();
			getOpened();
			checkTutorialFinish();
		}
		
		private function removeDeletedQuests():void {
			for each(var id:* in deletedQuests) {
				if (App.data.quests[id] != null)
					delete App.data.quests[id];
			}
			deletedQuests = [];
		}
		
		private var deletedQuests:Array = [];
		private function deleteAllChildrens(qID:int, parentID:int, updateID:String):void
		{
			if (updateID == null) return;
			
			var quest:Object;
			// Выбираем квесты этого обновления
			for (var id:* in App.data.quests)
			{
				quest = App.data.quests[id];
				if (quest.hasOwnProperty('update') && quest.update == updateID)
				{
					deletedQuests.push(id);
					//delete App.data.quests[id];
				}
			}
			/*
			// Определяем наследников этих квестов
			var childrens:Array = [];
			for (var _id:* in App.data.quests)
			{
				if (data.hasOwnProperty(_id)) // если уже открыт
					continue;
					
				quest = App.data.quests[_id];
				if (deletedQuests.indexOf(quest.parent) != -1) {
					quest.parent = parentID;
					childrens.push(_id);

				}
			}
			
			if(childrens.length > 0)
				openQuest(childrens);*/
		}
		
		public function checkPromo(isLevelUp:Boolean = false):void
		{
			/*if (App.user.promo == null) return;
			
			for (var pID:* in App.data.promo)
			{
				if (App.user.promo.hasOwnProperty(pID)) 
					continue;
					
				var promo:Object = App.data.promo[pID];
				
				if (App.user.level >= promo.unlock.level) {
					if (promo.unlock.quest == 0 || (data[promo.unlock.quest] != null && data[promo.unlock.quest].finished > 0)) {
						
						if (promo.hasOwnProperty('type') && promo.type == 1)
						{	
							if (promo.time + promo.duration * 3600 < App.time)
								continue;
								
							App.user.promo[pID] = {
								started:promo.time,
								status:0
							};
							App.user.promo[pID]['new'] = App.time;
						}
						else
						{
							App.user.promo[pID] = {
								started:App.time,
								status:0
							};
							App.user.promo[pID]['new'] = App.time;
							openPromo(pID);
						}
					}
				}
			}*/
			
			App.user.updateActions();
			if (App.ui) {
				setTimeout(function():void{
					App.ui.salesPanel.createPromoPanel(isLevelUp);
					App.ui.salesPanel.resize();
				}, 10000);
			}
		}
		
		public function checkFreebie():void
		{
			//return;
			var many:Boolean = false;
			var fast:Boolean = false;
			
			if (App.user.freebie && App.user.freebie.status == 1) {
			
				if (InviteSocialFriends.canShow()) {
					App.ui.rightPanel.addFreebie(true);	
				}
				return;
			}
			
			if(App.user.freebie == null /*|| App.user.freebie.status == 1 */|| App.ui.rightPanel.freebieBttn != null){
				fast = false;
			}else{
				if(App.user.freebie.ID != 0){
					var neededQuest:int = App.data.freebie[App.user.freebie.ID].unlock.quest;
					if (App.user.quests.data.hasOwnProperty(neededQuest) && App.user.quests.data[neededQuest].finished > 0)
					{
						fast = true;
					}
				}
			}
			
			//if(fast)
				//App.ui.rightPanel.addFreebie();	
				
			//if (App.social == 'VK' && App.network.leads.length > 0 && App.network.leads[0] > 0) {
				//many = true;
			//}
			//if (App.social == 'FB'){// && ExternalApi.visibleTrialpay) {
				//many = true;
			//}
			
			//many = false
			if (App.ui && (fast || many)) {
				App.ui.rightPanel.addFreebie();	
			}
		}
		
		public function openPromo(pID:String):void {
			Post.send( {
				ctr:'promo',
				act:'open',
				uID:App.user.id,
				pID:pID
			}, function(error:int, data:Object, params:Object):void {
				
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		public function get isTutorial():Boolean
		{
			if (tutorial) {
				return true;
			}
			return false;
		}
		
		public function getOpened():void {
			opened = [];
			currentQID = 0;
			var messages:Array = [];
			
			for (var id:* in App.data.quests) {
				if (data[id] != undefined && data[id].finished == 0) {
					
					if(currentQID == 0){
						currentQID = id;
						for each(var miss:* in App.data.quests[id].missions) {
							if (!data[id][miss.ID]) {// == undefined
								currentMID = miss.ID;
								break;
							}
						}
					}
						
					if (App.data.quests[id].tutorial)
						tutorial = true;
					
					var questObject:Object = App.data.quests[id];
					
					if (questObject.hasOwnProperty('update')) {
						var updateID:String = questObject.update;
						if (App.data.updates.hasOwnProperty(updateID) && !App.data.updates[updateID].social.hasOwnProperty(App.social)) {
							continue;
						}
					}
			
					opened.push({
						id:id, 
						character:App.data.quests[id].character, 
						order:App.data.quests[id].order,
						fresh: data[id]['fresh'] || false,
						type: App.data.quests[id].type
					});
					if (data[id]['fresh'] != undefined) {
						delete data[id]['fresh'];
					}
				}
			}
			opened.sortOn('order', Array.NUMERIC);
			
			if (App.map == null) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
			}else{
				scoreOpened();
			}
		}
		
		private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);	
			scoreOpened();
		}
		
		public function countOfUnits(sid:*):int {
			var childs:int = App.map.mSort.numChildren;
			var unit:Unit;
			var count:uint = 0;
			while (childs--) {
				unit = App.map.mSort.getChildAt(childs) as Unit;
				if (unit.sid == sid) {
					count++;
				}
			}
			return count;
		}
		
		public function scoreOpened():void {
			if (App.user.mode == User.GUEST || App.user.quests.tutorial) {
				return;
			}
			var scored:Object = { };
			var send:Boolean = false;
			var exit:Boolean = false;
			
			for each(var quest:* in opened) {
				var missions:Object = App.data.quests[quest.id].missions;
				for (var mID:* in missions){
					if (missions[mID]['score'] != undefined && missions[mID].score) {
						
						if (missions[mID].event == 'zone') 
						{
							for each(var target_sID:* in missions[mID].target) {
								if (App.user.world.zones.indexOf(target_sID) != -1) {
									if(scored[quest.id] == undefined){
										scored[quest.id] = { };
									}
									scored[quest.id][mID] = { };
									scored[quest.id][mID][target_sID] = 1;
									
									exit = true;
									send = true;
								}
							}
						}
						
						if (exit) break;
						
						var childs:int; 
						var unit:Unit; 
						var _data:Array = [];
						
						
						childs = App.map.mSort.numChildren;
						while (childs--) {
							unit = App.map.mSort.getChildAt(childs) as Unit;
							if(unit != null)
								_data.push(unit)
						}
						
						childs = App.map.mLand.numChildren;
						while (childs--) {
							unit = App.map.mLand.getChildAt(childs) as Unit;
							if(unit != null)
								_data.push(unit)
						}
						
						childs = _data.length;
						exit = false;
						while (childs--) {
							
							//var unit:Unit = App.map.mSort.getChildAt(childs) as Unit;
							unit = _data[childs];
							
							//if (unit == null) continue;
							
							if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false) {
								continue;
							}
							
							for each(var sID:* in missions[mID].target){
						
								var need:int = missions[mID].need;
								var func:String = missions[mID].func;
								
								if (data[quest.id][mID] >= need) 
									continue;
								
								if (unit.sid == sID)
								{
									var obj:Object = App.data.storage[sID];
									switch(missions[mID].event) {
										case 'buy': 
											if (['Building', 'Field', 'Factory', 'Mining', 'Moneyhouse', 'Golden', 'Storehouse', 'Fplant', 'Tradeshop'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = unit.id;
												//exit = true;
												send = true;
											}
											break;
										case 'instance':
											if (['Building', 'Field', 'Factory', 'Mining', 'Moneyhouse', 'Golden', 'Storehouse'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												var count:int = countOfUnits(sID);
												
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = count
												//exit = true;
												send = true;
											}
											break;
										case 'finished':
											if (['Building', 'Field', 'Factory', 'Mining', 'Moneyhouse', 'Golden', 'Storehouse'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												
												if(unit.hasOwnProperty('level') && unit.hasOwnProperty('totalLevels') && unit['level'] == unit['totalLevels']){
													count = countOfUnits(sID);
												
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = count
													exit = true;
													send = true;
												}
											}
											break;
										case 'grow':
											if (['Floors'].indexOf(unit.type) != -1) {
												if (unit['floor'] >= missions[mID].need) {
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													exit = true;
													send = true;
												}
											}
											break;
										case 'upgrade':
										case 'reward':
											if (['Building', 'Field', 'Factory', 'Mining', 'Moneyhouse', 'Golden', 'Storehouse','Tradeshop'].indexOf(unit.type) != -1) {
												if (unit['level'] >= missions[mID].need) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = unit.id;
												//exit = true;
												send = true;
												}
											}
											break;
										case 'create':
											if (['Animal'].indexOf(unit.type) != -1) {
												if(scored[quest.id] == undefined){
													scored[quest.id] = { };
												}
												scored[quest.id][mID] = { };
												scored[quest.id][mID][sID] = unit.id;
												exit = true;
												send = true;
											}
											break;
										case 'stock':
											if (['Bridge'].indexOf(unit.type) != -1) {
												if(Bridge(unit).isPierComplete())
												{
													if(scored[quest.id] == undefined){
														scored[quest.id] = { };
													}
													scored[quest.id][mID] = { };
													scored[quest.id][mID][sID] = unit.id;
													
													exit = true;
													send = true;
												}
											}
											break;	
									}
								}
								if (exit) break;
							}
							if (exit) break;
						}		
					}
				}	
			}
			if (send) {
				Post.send( {
					ctr:'quest',
					act:'score',
					uID:App.user.id,
					wID:App.user.worldID,
					score:JSON.stringify(scored)
				},function(error:*, data:*, params:*):void {
					
					
				});
			}
		}
		
		public function finishQuests(qIDs:Array):void
		{
			Post.send({
				ctr:'quest',
				act:'finish',
				uID:App.user.id,
				finished:JSON.stringify(qIDs)
			},function(error:*, data:*, params:*):void {
				
			});
		}	
		
		public function finishQuest(qID:int, mID:int):void
		{
			var obj:Object = { };
			obj[qID] = [mID];
			Post.send({
				ctr:'quest',
				act:'finish',
				uID:App.user.id,
				finished:JSON.stringify(obj)
			},function(error:*, data:*, params:*):void {
				
			});
		}	
		
		public function openQuest(childrens:Array):void 
		{
			var qIDs:Array = [];
			for (var i:int = 0; i < childrens.length; i++)
			{
				var qID:int = childrens[i];
				if (data[qID] == undefined)
				{
					qIDs.push(qID);
					data[qID] = { };
					data[qID]['finished'] = 0;
					data[qID]['fresh'] = true;
				}
			}
			
			if(qIDs.length > 0){
				Post.send( {
					ctr:'quest',
					act:'open',
					uID:App.user.id,
					qIDs:JSON.stringify(qIDs)
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
				});
			}	
		}
		
		private var shoewdFr:Boolean = false;
		private var alreadyShowed:Object = { };
		public function openMessages():void{
			for (var id:* in opened) {
				var qID:int = opened[id].id;
				
				var stop:Boolean = false;
				
				switch(qID) {
					case 2:
						QuestsRules.pointingTraget(App.data.quests[qID].missions[1].map[0]);
						if (alreadyShowed[qID] != null) 
							break;
							
						setTimeout(function():void {
							new QuestWindow( { qID:qID} ).show();
							alreadyShowed[qID] = App.time;
						}, 500);
						return;
						break;
					case 4:
					case 31:
					case 14:
					//case 103:
					case 5:
					case 36:
						if (alreadyShowed[qID] != null) 
							break;
							
						setTimeout(function():void {
							new QuestWindow( { qID:qID} ).show();
							alreadyShowed[qID] = App.time;
						}, 500);
						return;
					break;
					case 103:
						stop = true;
						if (alreadyShowed[qID] != null) 
							break;
							
						setTimeout(function():void {
							new QuestWindow( { qID:qID } ).show();
							alreadyShowed[qID] = App.time;
						}, 500);
						return;
					break;
					
					case 15:
						Tutorial.showTip(qID);
					break;
				}
				
				if (!shoewdFr && !stop && App.user.quests.data[144]) {
					if (App.user.storageRead('tutViral', '') == '' && App.user.quests.data[144].finished == 0) {
						shoewdFr = true;
						new CharactersWindow( { qID:144, mID:1 } ).show();
					}
				}
				
				
				if(opened[id].type == 1){
					
					//Перед 35 квестом (Возвращение) делаем push в _6e
					//if (App.social == 'FB' && opened[id].id == 35) {
						//ExternalApi._6epush([ "_event", { "event": "tutorial", "status": "c" } ]);
					//}
					
					//new QuestMsgWindow( { qID:opened[id].id } ).show();
					switch(opened[id].id) {
						case 80:
								QuestsRules.getQuestRule(currentQID, currentMID);
							break;	
						case 92:
							//lock = false;
							//unlockFuckAll();	
							QuestsRules.focusedOnWorker();
							break;
						case 90:
							QuestsRules.initStart();
							break;
						case 91:
						case 93:
						case 94:
						case 95:
								new DialogWindow( { qID:opened[id].id, mID:1 } ).show();
							break;
						case 81:
						case 83:
						case 88:
						case 96:
							new CharactersWindow( { qID:opened[id].id, mID:1 } ).show();
							break;	
						case 86:
							lockFuckAll();
							setTimeout(function():void {
								unlockFuckAll();
								new CharactersWindow( { qID:opened[id].id, mID:1 } ).show(); 
							}, 2000);
							break;	
						case 99:
								App.tutorial.addFullScreenBttn();
							break;
						default:
							if(opened[id].id != 144)
								new CharactersWindow( { qID:opened[id].id, mID:1 } ).show();
							break;	
					}
					
					App.ui.refresh();
					return;
				}
			}
		}
		
		public function isNew(qID:int):Boolean {
			for each(var quest:Object in opened) {
				if (qID == quest.id && quest.fresh && App.data.quests[qID].type != 1) {
					return true;
				}
			}
			return false;
		}
		
		public function openChilds(parentID:int = 0):void
		{
			var parentQuest:Object = data[parentID] || { };
			for (var qID:* in App.data.quests) {
				var quest:Object = App.data.quests[qID];
				if(((parentQuest['finished'] != undefined && parentQuest['finished']>0) || parentID == 0) && quest.parent == parentID){
					if(data[qID] == undefined){
						data[qID] = { };
						data[qID]['finished'] = 0;
						data[qID]['fresh'] = true;
						//App.user.quests.glowQuestIcon(qID, Locale.__e('flash:1382952379743'), 6000);
						App.ui.leftPanel.questsPanel.refresh();
						checkPromo();
						checkFreebie();
						if (inNewChapter(quest.chapter)){
							if (exclude.hasOwnProperty(quest.ID)) continue;
							changeChapter(quest.chapter);
						}
						if (qID == '39')
							trace('39');
					}
				}
			}
		}
		
		private function inNewChapter(id:uint):Boolean
		{
			if (chapters.indexOf(id) == -1)
			{
				chapters.push(id);
				return true;
			}
			return false;
		}
		
		private function changeChapter(id:uint):void
		{
			new ChapterWindow( {
				chapter:id
			}).show();
			
			Pigeon.checkNews();
			
			setTimeout(function():void {
				App.self.dispatchEvent(new AppEvent(AppEvent.ON_FINISH_TUTORIAL));
			},1000)
		}
		
		public function openWindow(qID:int):void {
			getOpened();
			new QuestWindow( { qID:qID } ).show();
		}
		
		private var timeGlowID:uint = 0;
		private var timeID:uint = 0;
		public function progress(state:Object):void {
			for (var qID:* in state) {
				var missions:Object = state[qID];
				for (var mID:* in missions) {
					data[qID][mID] = missions[mID];
					
					if (data[qID][mID] >= App.data.quests[qID].missions[mID].need) {
						/*//TODO показываем прогресс напротив иконки квеста
						if (App.data.quests[qID].tutorial) {
							continueTutorial();
						}else {
							App.ui.leftPanel.questsPanel.focusedOnQuest(qID, QuestPanel.PROGRESS)
						}*/
					}else if(App.data.quests[qID].tutorial && App.data.quests[qID].track){
						helpEvent(qID, mID);
					}
				}
				var finished:Boolean = true;
				for (mID in App.data.quests[qID].missions) {
					if (data[qID][mID] == undefined || App.data.quests[qID].missions[mID].need > data[qID][mID]) {
						finished = false;
						break;
					}
				}
				
				if (finished == true) {
					data[qID].finished = App.time;
					checkTutorialFinish();
					
					//Делаем push в _6e
					//if (App.social == 'FB') {
						//ExternalApi._6epush([ "_event", { "event": "gain", "item": "quest_completed" } ]);
						//
						//if (App.data.quests[qID].tutorial == 1) {
							//ExternalApi._6push(['_trackevent',{event:"_level", status:qID}]);
						//}
					//}
					
					//App.user.stock.addAll(App.data.quests[qID].bonus.materials);
					
					if (!tutorial) {
						new QuestRewardWindow( {
							qID:qID,
							forcedClosing:true,
							strong:true,
							callback:onTakeEvent
						}).show();
					}
					
					App.user.stock.addAll(App.data.quests[qID].bonus.materials);
					
					openChilds(qID);
					getOpened();
					openMessages();
					
					clearTimeout(timeGlowID);
					clearTimeout(timeID);
					currentTarget = null;
					
					App.ui.leftPanel.questsPanel.refresh();

					continueTutorial();
				}
				
				for (var ind:* in missions) {
					questMission = ind;
					break;
				}
				
				//TODO показываем прогресс напротив иконки квеста
				if (App.data.quests[qID].tutorial) {
					continueTutorial();
				}else {
					App.ui.leftPanel.questsPanel.focusedOnQuest(qID, QuestPanel.PROGRESS)
				}
			}
		}
		
		public function onTakeEvent(bonus:Object):void {
			//App.user.stock.addAll(bonus);
		}
		
		public function readEvent(qID:int, callback:Function):void {
			Post.send( {
				ctr:'quest',
				act:'read',
				uID:App.user.id,
				qID:qID
			}, function(error:*, result:*, params:*):void {
				if (result) {
					callback();
					data[qID]['finished'] = App.time;
					openChilds(qID);
					getOpened();
					
					App.ui.leftPanel.questsPanel.refresh();
					//App.user.quests.glowQuestIcon(qID, Locale.__e('flash:1382952379743'), 6000);
					
					//App.ui.leftPanel.changeQuestPanel();
					//App.ui.leftPanel.createQuestPanel();
					currentTarget = null;
					continueTutorial();
					
					openMessages();
					checkTutorialFinish();
				}
			});
		}
		
		public function skipEvent(qID:int, mID:int, callback:Function):Boolean {
			
			if (data[qID] == undefined || data[qID].finished != 0) {
				//TODO может быть нужно показывать окно о несоответсвии, если квест не открыт
				return false;
			}
			
			var mission:Object = App.data.quests[qID].missions[mID];
			
			if (App.user.stock.take(Stock.FANT, mission.skip)) {
				
				Post.send( {
					ctr:'quest',
					act:'skip',
					uID:App.user.id,
					qID:qID,
					mID:mID
				}, function(error:*, result:*, params:*):void {
					
					if (error) {
						App.user.stock.add(Stock.FANT, mission.skip);
					}else if (result) {
						data[qID][mID] = mission.need;
						
						callback(mID);
					}
					
				});
				
				return true;
			}
			
			return false;
			
		}
		
		public var win:*;
		
		public static var help:Boolean = false;
		public function helpEvent(qID:int, mID:int):void {
			currentQID = qID;
			currentMID = mID;
			var event:* = App.data.quests[qID].missions[mID].find;
			
			var targets:Array = [];
			
			var mapTargets:Object;
			if (App.data.quests[qID].missions[mID]['map']) {
				mapTargets = App.data.quests[qID].missions[mID].map;
			}else{
				mapTargets = App.data.quests[qID].missions[mID].target;
			}
			
			for each(var target:* in mapTargets) {
				targets.push(target);
			}
			
			var searchByType:Boolean = Boolean(App.data.quests[qID].missions[mID].ontype) || false;
			
			var filter:Object = App.data.quests[qID].missions[mID].filter;
			var all:Boolean = Boolean(App.data.quests[qID].missions[mID].all || 0);
			
			help = true;
			
			switch(event) {
				case 0: break; //нигде
				case 1: 
					
					for each(var _find:* in App.data.quests[qID].missions[mID].target) {
						break;
					}
					
					if (!findTarget(targets, searchByType, filter, all, _find)) {
						
						new SimpleWindow( {
							title:Locale.__e("flash:1382952379744"),
							label:SimpleWindow.ERROR,
							text:Locale.__e("flash:1382952379745"),
							ok:function():void {
								
								if (App.user.level <= 2) {
									ExternalApi.sendmail( {
										title:'flash:1382952379745',
										text:App.self.flashVars['social'] + "  " + App.user.id
									});
								}
							}
						}).show();
					}
					
					break; //На карте
				case 2: 
					if (App.data.quests[qID].tutorial) {
						
						currentTarget = App.ui.bottomPanel.bttnMainShop;
						currentTarget.showGlowing();
						
						if(qID == 5)
							Tutorial.watchOn(currentTarget, 'top', false, { dy: -100 } );
						else
							currentTarget.showPointing("top", 0, 0, currentTarget.parent, '', null);
						
						targetSettings = { find:targets };
						currentTarget.addEventListener(MouseEvent.CLICK, onTargetClick, false, 3000);
					}else{
						win = new ShopWindow( { find:targets } );
						win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
						win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
						win.show();
					}
					break; //В магазине
				case 3: 
					win = new StockWindow( { find:targets } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break; //flash:1382952379772е
				case 4:
					win = new CollectionWindow( { find:targets } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break; //flash:1382952379772е
				case 5:
					if (App.ui.bottomPanel.friendsPanel.opened) {
						App.ui.bottomPanel.hideFriendsPanel();
						__dy = -65;
					}
					currentTarget = App.ui.bottomPanel.icons[0].bttn;
					currentTarget.showGlowing();
					Tutorial.watchOn(currentTarget, 'top', false, { dy: __dy } );
					currentTarget.addEventListener(MouseEvent.CLICK, onFriendsIconClick, false, 3000);
					//setTimeout(startTrack, 200);
					break; //flash:1382952379772е
				case 6:
					win = new FreeGiftsWindow( { find:targets } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break; //В бесплатных подарках
				case 7:
					win = new FreeGiftsWindow( { find:targets, mode:FreeGiftsWindow.TAKE } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break; //В принятых подарках
				case 8:
					win = new FreeGiftsWindow( { find:targets, icon:'wishlist' } );
					win.addEventListener(WindowEvent.ON_AFTER_OPEN, onAfterOpen);
					win.addEventListener(WindowEvent.ON_AFTER_CLOSE, onAfterClose);
					win.show();
					break; //В бесплатных подарках
				case 9:
					var __dy:int = 0;
					//if (qID == 81) {
					if (App.ui.bottomPanel.friendsPanel.opened) {
						App.ui.bottomPanel.hideFriendsPanel();
						__dy = -65;
					}
					currentTarget = App.ui.bottomPanel.icons[3].bttn;
					currentTarget.showGlowing();
					Tutorial.watchOn(currentTarget, 'top', false, { dy: __dy } );
					currentTarget.addEventListener(MouseEvent.CLICK, onOpenMaps, false, 3000);
					break;// В картах
			}
		}
		
		private function onTargetClick(e:MouseEvent):void {
			if (currentTarget == null) return;
			currentTarget.removeEventListener(MouseEvent.CLICK, onTargetClick);
			currentTarget.hidePointing();
			currentTarget.hideGlowing();
			App.tutorial.hide();
		}
		
		private function onFriendsIconClick(e:MouseEvent):void {
			onTargetClick(e);
			if (currentTarget == null) return;
			currentTarget = App.ui.bottomPanel.friendsPanel.friendsItems[0];
			currentTarget.showGlowing();
			Tutorial.watchOn(currentTarget, 'top', false, { dy: -65} );
		}
		
		
		private function onOpenMaps(e:MouseEvent):void {
			onTargetClick(e);
			
		/*	currentTarget = App.ui.bottomPanel.friendsPanel.friendsItems[0];
			currentTarget.showGlowing();
			Tutorial.watchOn(currentTarget, 'top', false, { dy: -65} );*/
		}
		
		
		private function filteredTarget(unit:Unit, filter:Object):Boolean {
			for (var field:String in filter) {
				var properties:Array = field.split(".");
				var value:* = filter[field];
				
				var target:* = unit;
				for each(var property:* in properties) {
					if (!target.hasOwnProperty(property)) 
						return false;
					
					target = target[property];
				}
				
				if (target != value)
					return false;	
			}
			
			return true;
		}
		
		public var targets:Array = [];
		public var currentTarget:*;
		/*public function set currentTarget(value:*):void {
			_currentTarget = value;
			if (_currentTarget == null) {
				lockFuckAll();
			}else{
				unlockFuckAll();
			}
		}
		public function get currentTarget():* {
			return _currentTarget;
		}*/
		public var lockWhileMove:Boolean = false;
		public function findTarget(sIDs:Array, searchByType:Boolean, filter:Object = null, all:Boolean = false, find:int = 0 ):Boolean {
			
			//var sPoint:Object = { x:App.user.hero.cell, z:App.user.hero.row };
			
			var sID:int;
			var childs:int;
			var unit:*;
			var depth:int;
			
			if (find != 0 && App.data.storage[find].type == 'Zones') {
				App.map.focusedOn( Zone.zonePoint[find] );
				return true;
			}else if (searchByType == true && sIDs.length > 0) {
				sID = sIDs.shift();
				var type:String = App.data.storage[sID].type;
				
				childs = App.map.mSort.numChildren;
				while (childs--) {
					unit = App.map.mSort.getChildAt(childs);
					
					if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false) {
						continue;
					}
					
					if(unit.type == type){
						if (unit is Plant) unit = unit.parent;
						
						if (filter != null) {
							if (!filteredTarget(unit, filter)) {
								continue;
							}
						}
				
						//depth = Math.abs(sPoint.x - unit.coords.x) + Math.abs(sPoint.z - unit.coords.z);
						targets.push( { unit:unit } );// , depth: depth } );
					}
				}
				
			}else{
				while(sIDs.length > 0){
					
					sID = sIDs.shift();
				
					childs = App.map.mSort.numChildren;
					while (childs--) {
						unit = App.map.mSort.getChildAt(childs);
						
						if (App.map._aStarNodes[unit.coords.x][unit.coords.z].open == false) {
							if (unit.sid == sID)
								trace();
							continue;
						}
						
						if(unit.sid == sID){
							if (unit is Plant) unit = unit.parent;
						
							if (filter != null) {
								if (!filteredTarget(unit, filter)) {
									continue;
								}
							}
							
							//depth = Math.abs(sPoint.x - unit.coords.x) + Math.abs(sPoint.z - unit.coords.z);
							targets.push( { unit:unit } );// , depth: depth } );
						}
					}
				}
			}
				
			if (targets.length > 0) {
				//targets.sortOn('depth', Array.NUMERIC);
				var target:Object = targets.shift();
				//var target:Object = targets.pop(); // выбираем первый таргет
				
				lock = true;
				lockWhileMove = true;
				trace('____lockWhileMove: ' + lockWhileMove);
				var tween:Boolean = true;
				/*if (currentQID == 270)
					tween = false;*/
				
				var focusTarget:* = target.unit;
				if (target.unit.sid == 250) {
					focusTarget = { x:target.unit.x - 150, y:target.unit.y + 150 };
				}
				/*if (target.unit.sid == 173) {
					focusTarget = { x:target.unit.x, y:target.unit.y + 50 };
				}*/
				
				
				
				if (all == true) {
					var need:int = App.data.quests[currentQID].missions[currentMID].need;
					var have:int = data[currentQID][currentMID];
					need = need - have;
					
					for each(var item:* in targets) {
						need--;
						if (need <= 0) break;
						
						item.unit.showPointing("top",item.unit.dx,item.unit.dy);//0 - dx
						item.unit.showGlowing();
						
						hideTargetGlowing(item);
						
						doFocus(item.unit);
					}
				}else {
					doFocus(focusTarget);
				}
				
				function doFocus(thisTarget:*):void
				{
					App.map.focusedOnCenter(thisTarget, false, function():void 
					{
						currentTarget = target.unit;
						
						var doClick:Boolean = false;
						if (thisTarget is Building &&  !(thisTarget is Moneyhouse) && !(thisTarget is Mining)  && !(thisTarget is Floors)   && !(thisTarget is Factory) && !(thisTarget is Storehouse && thisTarget != App.user.quests.isTutorial))
							doClick = true;
							
						if (thisTarget is Field && thisTarget.hasProduct)
							doClick = false;
							
						if(doClick){	
							thisTarget.helpTarget = find;
							thisTarget.click();
						}else{
							target.unit.showGlowing();
							
							if (!tutorial || !track) {
								if (target.unit is Animal)
									target.unit.showPointing("top", target.unit.dx - 40, target.unit.dy - 40);
								else
									target.unit.showPointing("top", target.unit.dx, target.unit.dy);
									setTimeout(function():void {
										target.unit.hidePointing();
										target.unit.hideGlowing();
									}, 3000);
							}else {
								Tutorial.watchOn(target.unit, 'top', true, Tutorial.getCorrections(target.unit.sid));
								App.user.quests.unlockFuckAll();
							}
						}
						
						lock = false;
						lockWhileMove = false;
						trace('__lockWhileMove: ' + lockWhileMove);
					}, tween);
				}
				
				//showFader();
				targets = [];	
				return true;
			}
			
			return false;
		}
		
		private function hideTargetGlowing(item:*):void {
			setTimeout(function():void {
				item.unit.hidePointing();
				item.unit.hideGlowing();
			}, 3000);
		}
		
		/*
		public var fader:Sprite = new Sprite();
		public function showFader():void {
			if (App.self.faderContainer.contains(fader)) {
				return;
			}
						
			fader.graphics.beginFill(0x000000,0);
			fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			fader.graphics.endFill();

			App.self.faderContainer.addChild(fader);
		}
		
		public function hideFader():void {
			if(App.self.faderContainer.contains(fader)){
				App.self.faderContainer.removeChild(fader);	
			}
		}
		*/
		
		public var track:Boolean = false;
		public var lock:Boolean = false;
		public function startTrack():void {	
			if (track == false) {
				trace('startTrack');
				track = true;
				App.self.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent, false, 1000);
				App.self.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent, false, 1000);
				App.self.addEventListener(MouseEvent.CLICK, onMouseEvent, false, 1000);
				App.self.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 1000);
				App.self.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDouble, false, 1000);
			}
		}
		
		public function stopTrack():void {		
			trace('stopTrack');
			track = false;
			App.self.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			App.self.removeEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			App.self.removeEventListener(MouseEvent.CLICK, onMouseEvent);
			App.self.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			App.self.removeEventListener(MouseEvent.DOUBLE_CLICK, onMouseDouble);
		}
		
		private function onMouseDouble(e:MouseEvent):void {
			e.stopImmediatePropagation();
		}
		
		private function onMouseMove(e:MouseEvent):void {
			//trace(e.target);
			//if (currentTarget && e.buttonDown) {
				//App.self.moveCounter = 0;
			//}
		}
		
		public static var lockButtons:Boolean = false;
		public var lastTarget:*;
		private function onMouseEvent(e:MouseEvent):void {
			
			if (_lockFuckAll || lockWhileMove) {
				e.stopImmediatePropagation();
				return;
			}
			
			/*if (lockWhileMove || (e.target is Button && e.target.parent is SystemPanel))	 {
				return;
			}*/

			if (!lock) {
				
				if (e.type == MouseEvent.MOUSE_UP && !(currentTarget is Unit)) {					
					
					if (lastTarget != e.target && lastTarget is Button && App.map.moved == null) {
						trace(lastTarget + " lastTarget");
						//lastTarget.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						lastTarget = null;
					}
				}
				
				if (!currentTarget) {
					return;
				}
			
				if (currentTarget is Unit) 
				{
					if (currentTarget is Missionhouse && e.target is ImageButton) {
						App.tutorial.hidePointing();
						App.tutorial.hide();
						currentTarget.hidePointing();
						currentTarget.hideGlowing();
						currentTarget = null;	
						return;
					}
					
					if((App.map.moved != null || App.map.touched.length > 0) && e.type == MouseEvent.MOUSE_UP && !(e.target is Button || e.target.parent is BottomPanel)){
						var unit:* = App.map.moved || App.map.touched[0];
						if (currentTarget == unit) {
							trace('!!!!!!! ' + currentTarget);
							currentTarget.hidePointing();
							currentTarget.hideGlowing();
							if (tutorial) {
								App.tutorial.hidePointing();
								//App.tutorial.nextStep(currentQID);
								if(!(currentTarget is Resource))
									App.tutorial.hide();
							}
							
							lastTarget = currentTarget;
							//hideFader();
							lock = true;
							QuestsRules.getQuestRule(currentQID, currentMID);
							App.self.moveCounter = 0;
							return;
						}
					}
				}else if(e.target == currentTarget || e.currentTarget == currentTarget){
					if(e.type == MouseEvent.MOUSE_DOWN && !App.user.quests.tutorial){
						App.self.moveCounter = 0;
						
						lastTarget = e.target;
						
						currentTarget.hidePointing();
						currentTarget.hideGlowing();
						
						if (initQuestRule) {
							QuestsRules.getQuestRule(currentQID, currentMID);
							initQuestRule = false;
						}else{
						
							//Злостный хак
							if (currentTarget.name == 'iconMenu') {	
								QuestsRules.getQuestRule(currentQID, currentMID);
							}else if (currentTarget != App.ui.bottomPanel.bttnMainShop) {
								currentTarget = null;
							}
						}
						
						if (tutorial) {
							App.tutorial.hidePointing();
							//App.tutorial.hide();
							//if(currentQID == 77) App.tutorial.nextStep(currentQID);
							/*if (currentQID == 11) {
								QuestsRules.finishTutorial();
							}*/
							//
						}
					}
					trace('return')	
					return;
				}else if (e.type == MouseEvent.MOUSE_DOWN) {
					lastTarget = e.target;
				}
			}
			
			trace('no return stopImmediatePropagation')	
			e.stopImmediatePropagation();
			
			if (e.type == MouseEvent.MOUSE_DOWN && (e.target is Button || e.target.parent is BottomPanel || e.target is units.AnimationItem)) {
				lockButtons = true;
			}
			if (e.type == MouseEvent.MOUSE_UP && e.target is Button) {
				
			}
		}
		
		public static var _lockFuckAll:Boolean = false;
		public function unlockFuckAll():void 
		{
			_lockFuckAll = false;
			lockButtons = false;
		}
		
		public function lockFuckAll():void 
		{
			_lockFuckAll = true;
			lockButtons = true;
		}
		
		public var currentQID:int = 0;
		public var currentMID:int = 0;
		public function continueTutorial():void
		{
			/*if (currentQID == 2 && !QuestsRules.fullscreen && App.social == 'PL') {
				if (!App.ui.systemPanel.bttnSystemFullscreen.__hasGlowing)
				{
					App.ui.systemPanel.bttnSystemFullscreen.showGlowing();
					App.ui.systemPanel.bttnSystemFullscreen.showPointing("right",0,60,App.ui.systemPanel, "", null, true);
					QuestsRules.getQuestRule(1, 1);
				}
				startTrack();
				currentTarget = App.ui.systemPanel.bttnSystemFullscreen;
				tutorial = true;
				return;
			}*/
			
			tutorial = false; 
			if (currentQID == 0 || !App.data.quests[currentQID].tutorial) {
				return;
			}else {
				tutorial = true;
				/*if (currentQID == 39 && currentMID == 1)
					return;*/
			}
			
			if(App.data.quests[currentQID].track){
				startTrack();
			}
			
			lock = false;
			getOpened();
			if(opened.length > 0 && App.ui.leftPanel.questsPanel){
				for each(var questIcon:QuestIcon in App.ui.leftPanel.questsPanel.icons) {
					var bttn:ImagesButton = questIcon.bttn;
					
					if (bttn.settings.qID == opened[0].id && data[opened[0].id].finished == 0) {
						
					/*	if (currentQID == 4 && currentMID == 2) {
							helpEvent(currentQID, currentMID);
							break;
						}
						if (currentQID == 6 && currentMID == 2) {
							helpEvent(currentQID, currentMID);
							break;
						}
						
						if (currentQID == 8 && currentMID == 1) {
							openWindow(currentQID);
							break;
						}
						*/
						App.ui.refresh();
						
						if (App.data.quests[currentQID].track) {
							switch(currentQID) {
								case 1:
										App.user.quests.helpEvent(currentQID, currentMID);
									break;	
								case 82:
								case 84:
								case 87:
								case 89:
								case 97:	
										App.user.quests.helpEvent(currentQID, currentMID);
									break;
								case 85:
										if(currentMID == 1){
											App.tutorial.hide();
											App.user.quests.lockFuckAll();
											App.user.quests.helpEvent(currentQID, currentMID);
										}else {
											QuestsRules.getQuestRule(currentQID, currentMID);
										}
									break;	
							
								/*case 85:	
									switch(currentMID) {
										case 1:	
										case 2:
												App.user.quests.helpEvent(currentQID, currentMID);
											break;
										case 3:
												QuestsRules.getQuestRule(currentQID, currentMID);
											break;
									}
								break;*/
									
								/*case 77:
										QuestsRules.getQuestRule(currentQID, currentMID);
									break;	
								case 79:
										QuestsRules.getQuestRule(currentQID, currentMID);
										//App.user.quests.helpEvent(currentQID, currentMID);//App.tutorial.nextStep(79, 1);
									break;
								case 75:	
								case 123:
								case 129:
								case 130:
								case 131:
								case 132:
								case 137:
								case 138:
										new DialogWindow( { qID:currentQID, mID:1 } ).show();
									break;
								case 5:
										//App.tutorial.showMarketPanel();
										App.user.quests.helpEvent(currentQID, currentMID);
									break;
								case 6:
										//App.tutorial.showMarketPanel();
										if(currentMID == 1)
											App.user.quests.helpEvent(currentQID, currentMID);
										else
											QuestsRules.getQuestRule(currentQID, currentMID);
									break;	
								case 14:
										//App.tutorial.showMarketPanel();
										if(currentMID == 1 || currentMID == 3)
											App.user.quests.helpEvent(currentQID, currentMID);
										else
											QuestsRules.getQuestRule(currentQID, currentMID);
									break;		
								case 7:
										//App.tutorial.showMarketPanel();
										App.user.quests.helpEvent(currentQID, currentMID);
									break;	
								case 8:	
										App.user.quests.helpEvent(currentQID, currentMID);
									break
								case 139:
										QuestsRules.getQuestRule(currentQID, currentMID);
									break;
								case 80:
										App.tutorial.showMarketPanel();
										App.user.quests.helpEvent(currentQID, currentMID);
									break;		
								case 10:
										QuestsRules.getQuestRule(currentQID, currentMID);
									break	
								case 11:
										App.data.quests[currentQID].track = false;
										if(currentMID == 1)
											QuestsRules.focusOnQuest(bttn);
									break	*/	
								default:
										bttn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
									break;	
							}
						}else{
							bttn.showGlowing();
							if (tutorial) {
								bttn.showPointing("left", 0, 0, questIcon, '', null, true);
							}else{
								bttn.showPointing("left", 0, 0, questIcon, Locale.__e("flash:1382952379743"), {
									color:0xf3c769,
									borderColor:0x322204,
									autoSize:"left",
									fontSize:24
								},true);
							}
							currentTarget = bttn;
						}
						break;
					}
				}
			}
		}
		
		public function glowHelp(window:QuestWindow):void {
			for each(var mission:* in window.missions) {
				if (mission.helpBttn != null) {
					currentQID = mission.qID;
					currentMID = mission.mID;
					
					mission.helpBttn.showGlowing();
					mission.helpBttn.showPointing("top", 0, 30, mission.helpBttn.parent);
					currentTarget = mission.helpBttn;
					
					break;
				}
			}
		}
		
		public function glowTutorialBttn(window:*, bttn:*):void{//, qID:int, mID:int):void {
		/*	currentQID = qID;
			currentMID = mID;*/
			bttn.showPointing("right", 0, 0, bttn.parent);
			bttn.showGlowing();
			currentTarget = bttn;
			lockButtons = false;
			
			//App.cursorShleif.start(currentTarget);
		}
		
		private function onAfterOpen(e:WindowEvent):void 
		{
			//if (currentTarget == null) {
				//QuestsRules.getQuestRule(currentQID, currentMID);
			//}
		}
		
		private function onAfterClose(e:WindowEvent):void {
			if (currentTarget == null) {
				QuestsRules.getQuestRule(currentQID, currentMID);
			}
		}
		
			
	}

}