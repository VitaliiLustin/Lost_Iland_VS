package 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	
	
	public class WindowsLib extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");

		[Embed(source="Graphics2/MoneymanBig.png")]
		private var MoneymanBig:Class;
		public var moneymanBig:BitmapData = new MoneymanBig().bitmapData;
		
		[Embed(source="Graphics2/SaleTextBacking.png")]
		private var SaleTextBacking:Class;
		public var saleTextBacking:BitmapData = new SaleTextBacking().bitmapData;
		
		[Embed(source="Graphics2/DoorMan1.png")]
		private var DoorMan1:Class;
		public var doorMan1:BitmapData = new DoorMan1().bitmapData;
		
		[Embed(source="Graphics2/DoorMan2.png")]
		private var DoorMan2:Class;
		public var doorMan2:BitmapData = new DoorMan2().bitmapData;
		
		[Embed(source="Graphics2/DoorMan3.png")]
		private var DoorMan3:Class;
		public var doorMan3:BitmapData = new DoorMan3().bitmapData;
		
		[Embed(source="Graphics2/HelpButton.png")]
		private var HelpButton:Class;
		public var helpButton:BitmapData = new HelpButton().bitmapData;
		
		
		[Embed(source="Graphics2/InviteFriend.png")]
		private var InviteFriend:Class;
		public var inviteFriend:BitmapData = new InviteFriend().bitmapData;
		
		[Embed(source="Graphics2/MagicFog.png")]
		private var MagicFog:Class;
		public var magicFog:BitmapData = new MagicFog().bitmapData;
		
		[Embed(source="Graphics2/BuildIco.png")]
		private var BuildIco:Class;
		public var buildIco:BitmapData = new BuildIco().bitmapData;
		
		[Embed(source="Graphics2/Points.png")]
		private var Points:Class;
		public var points:BitmapData = new Points().bitmapData;
		
		[Embed(source="Textures/Plus.png")]
		private var Plus:Class;
		public var plus:BitmapData = new Plus().bitmapData;
		
		[Embed(source="Graphics2/CookingBarL.png")]
		private var CookingBarL:Class;
		public var cookingBarL:BitmapData = new CookingBarL().bitmapData;
		
		[Embed(source="Graphics2/CookingBarM.png")]
		private var CookingBarM:Class;
		public var cookingBarM:BitmapData = new CookingBarM().bitmapData;
		
		[Embed(source="Graphics2/CookingBarR.png")]
		private var CookingBarR:Class;
		public var cookingBarR:BitmapData = new CookingBarR().bitmapData;
		
		[Embed(source="Graphics2/CookingPanelBarLeft.png")]
		private var CookingPanelBarLeft:Class;
		public var cookingPanelBarLeft:BitmapData = new CookingPanelBarLeft().bitmapData;
		
		[Embed(source="Graphics2/CookingPanelBarM.png")]
		private var CookingPanelBarM:Class;
		public var cookingPanelBarM:BitmapData = new CookingPanelBarM().bitmapData;
		
		[Embed(source="Graphics2/CookingPanelBarRight.png")]
		private var CookingPanelBarRight:Class;
		public var cookingPanelBarRight:BitmapData = new CookingPanelBarRight().bitmapData;
		
		[Embed(source="Graphics2/GotoDream.png")]
		private var GotoDream:Class;
		public var gotoDream:BitmapData = new GotoDream().bitmapData;
		
		[Embed(source="Graphics2/SmallBacking.png")]
		private var SmallBacking:Class;
		public var smallBacking:BitmapData = new SmallBacking().bitmapData;
		
		[Embed(source="Graphics2/TextBacking.png")]
		private var TextBacking:Class;
		public var textBacking:BitmapData = new TextBacking().bitmapData;
		
		[Embed(source="Graphics2/BonusBacking.png")]
		private var BonusBacking:Class;
		public var bonusBacking:BitmapData = new BonusBacking().bitmapData;
		
		[Embed(source="Graphics2/WindowBacking.png")]
		private var WindowBacking:Class;
		public var windowBacking:BitmapData = new WindowBacking().bitmapData;
		
		
		
		[Embed(source="Graphics2/FurOff.png")]
		private var FurOff:Class;
		public var furOff:BitmapData = new FurOff().bitmapData;
		
		[Embed(source="Graphics2/FurOn.png")]
		private var FurOn:Class;
		public var furOn:BitmapData = new FurOn().bitmapData;
		
		[Embed(source="Graphics2/TextBubble.png")]
		private var TextBubble:Class;
		public var textBubble:BitmapData = new TextBubble().bitmapData;
		
		
		//QUESTS
		
		[Embed(source="Graphics2/BlueItemBacking.png")]
		private var BlueItemBacking:Class;
		public var blueItemBacking:BitmapData = new BlueItemBacking().bitmapData;
		
		/*************************************************************************************************/
		/****************************** NEW TEXTURES FOR ALIENSE *****************************************/
		/*************************************************************************************************/
		
		/*[Embed(source = "Textures/Arrow.png")]
		private var Arrow:Class;
		public var arrow:BitmapData = new Arrow().bitmapData;*/
		
		[Embed(source="Graphics2/Arrow.png")]
		private var Arrow:Class;
		public var arrow:BitmapData = new Arrow().bitmapData;
		
		//[Embed(source = "Textures/CheckMark.png")]
		//private var CheckMark:Class;
		//public var checkMark:BitmapData = new CheckMark().bitmapData;
		
		[Embed(source="Graphics2/CheckMark.png")]
		private var CheckMark:Class;
		public var checkMark:BitmapData = new CheckMark().bitmapData;
		
		[Embed(source="Graphics2/CheckmarkSlim.png")]
		private var CheckmarkSlim:Class;
		public var checkmarkSlim:BitmapData = new CheckmarkSlim().bitmapData;
		
		/*[Embed(source = "Textures/CloseBttn.png")]
		private var CloseBttn:Class;
		public var closeBttn:BitmapData = new CloseBttn().bitmapData;*/
		
		[Embed(source="Graphics2/CloseBttn.png")]
		private var CloseBttn:Class;
		public var closeBttn:BitmapData = new CloseBttn().bitmapData;
		
		[Embed(source="Graphics2/BFFAv.png")]
		private var BFFAv:Class;
		public var bFFAv:BitmapData = new BFFAv().bitmapData;
		
		[Embed(source="Graphics2/storage/CloseBttnSmall.png")]
		private var CloseBttnSmall:Class;
		public var closeBttnSmall:BitmapData = new CloseBttnSmall().bitmapData;
		
		[Embed(source = "Textures/Coin.png")]
		private var Coin:Class;
		public var coin:BitmapData = new Coin().bitmapData;
		
		/*[Embed(source = "Textures/Diamonds.png")]
		private var Diamonds:Class;
		public var diamonds:BitmapData = new Diamonds().bitmapData;*/
		
		[Embed(source="Graphics2/Diamonds.png")]
		private var Diamonds:Class;
		public var diamonds:BitmapData = new Diamonds().bitmapData;
		
		[Embed(source="Graphics2/storage/StorageWoodenDec.png")]
		private var StorageWoodenDec:Class;
		public var storageWoodenDec:BitmapData = new StorageWoodenDec().bitmapData;
		
		/*[Embed(source = "Textures/DiamondsTop.png")]
		private var DiamondsTop:Class;
		public var diamondsTop:BitmapData = new DiamondsTop().bitmapData;*/
		
		[Embed(source="Graphics2/DiamondsTop.png")]
		private var DiamondsTop:Class;
		public var diamondsTop:BitmapData = new DiamondsTop().bitmapData;
		
		[Embed(source = "Textures/DotGreen.png")]
		private var DotGreen:Class;
		public var dotGreen:BitmapData = new DotGreen().bitmapData;
		
		[Embed(source = "Textures/DotYellow.png")]
		private var DotYellow:Class;
		public var dotYellow:BitmapData = new DotYellow().bitmapData;
		
		//[Embed(source = "Textures/Drapery1.png")]
		//private var Drapery1:Class;
		//public var drapery1:BitmapData = new Drapery1().bitmapData;
		
		[Embed(source="Graphics2/drapery1.png")]
		private var Drapery1:Class;
		public var drapery1:BitmapData = new Drapery1().bitmapData;
		
		[Embed(source = "Textures/Drapery2.png")]
		private var Drapery2:Class;
		public var drapery2:BitmapData = new Drapery2().bitmapData;
		
		/*[Embed(source = "Textures/ItemBacking.png")]
		private var ItemBacking:Class;
		public var itemBacking:BitmapData = new ItemBacking().bitmapData;*/
		
		[Embed(source="Graphics2/ItemBacking.png")]
		private var ItemBacking:Class;
		public var itemBacking:BitmapData = new ItemBacking().bitmapData;
		
		[Embed(source="Graphics2/ItemBacking1.png")]
		private var ItemBacking1:Class;
		public var itemBacking1:BitmapData = new ItemBacking1().bitmapData;
		
		/*[Embed(source = "Textures/PrograssBarBacking.png")]
		private var PrograssBarBacking:Class;
		public var prograssBarBacking:BitmapData = new PrograssBarBacking().bitmapData;*/
		
		[Embed(source="Graphics2/storage/prograssBarBacking.png")]
		private var PrograssBarBacking:Class;
		public var prograssBarBacking:BitmapData = new PrograssBarBacking().bitmapData;
		
		[Embed(source="Graphics2/storage/YellowProgBarPiece.png")]
		private var YellowProgBarPiece:Class;
		public var yellowProgBarPiece:BitmapData = new YellowProgBarPiece().bitmapData;
		
		[Embed(source="Graphics2/GameWallPost.png")]
		private var GameWallPost:Class;
		public var gameWallPost:BitmapData = new GameWallPost().bitmapData;
		
		//[Embed(source = "Textures/prograssBarBacking3.png")]
		//private var prograssBarBacking3:Class;
		//public var prograssBarBacking3:BitmapData = new prograssBarBacking3().bitmapData;
		
		[Embed(source="Graphics2/storage/PrograssBarBacking3.png")]
		private var PrograssBarBacking3:Class;
		public var prograssBarBacking3:BitmapData = new PrograssBarBacking3().bitmapData;
		
		[Embed(source = "Graphics2/lastUpdate/QuestTaskBackingTop.png")]
		private var QuestTaskBackingTop:Class;
		public var questTaskBackingTop:BitmapData = new QuestTaskBackingTop().bitmapData;
		
		//[Embed(source="Graphics2/lastUpdate/QuestTaskBackingBot.png")]
		//private var QuestTaskBackingBot:Class;
		//public var questTaskBackingBot:BitmapData = new QuestTaskBackingBot().bitmapData;
		
		
		/*[Embed(source = "Textures/ProgressBar.png")]
		private var ProgressBar:Class;
		public var progressBar:BitmapData = new ProgressBar().bitmapData;*/
		
		[Embed(source="Graphics2/storage/ProgressBar.png")]
		private var ProgressBar:Class;
		public var progressBar:BitmapData = new ProgressBar().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/BuildingsActiveBacking.png")]
		private var BuildingsActiveBacking:Class;
		public var buildingsActiveBacking:BitmapData = new BuildingsActiveBacking().bitmapData;
		
		[Embed(source = "Textures/ProgressBarPiece.png")]
		private var ProgressBarPiece:Class;
		public var progressBarPiece:BitmapData = new ProgressBarPiece().bitmapData;
		
		[Embed(source="Graphics2/ItemNumRoundBakingLight.png")]
		private var ItemNumRoundBakingLight:Class;
		public var itemNumRoundBakingLight:BitmapData = new ItemNumRoundBakingLight().bitmapData;
		
		[Embed(source = "Textures/Separator.png")]
		private var Separator:Class;
		public var separator:BitmapData = new Separator().bitmapData;
		
		[Embed(source = "Textures/SeparatorPiece.png")]
		private var SeparatorPiece:Class;
		public var separatorPiece:BitmapData = new SeparatorPiece().bitmapData;
		
		[Embed(source = "Textures/SeparatorPiece2.png")]
		private var SeparatorPiece2:Class;
		public var separatorPiece2:BitmapData = new SeparatorPiece2().bitmapData;
		
		[Embed(source="Graphics2/SearchPanelBackingPiece.png")]
		private var SearchPanelBackingPiece:Class;
		public var searchPanelBackingPiece:BitmapData = new SearchPanelBackingPiece().bitmapData;
		
		[Embed(source="Graphics2/YellowRibbon.png")]
		private var YellowRibbon:Class;
		public var yellowRibbon:BitmapData = new YellowRibbon().bitmapData;
		
		/*[Embed(source = "Textures/ShopBackingMain.png")]
		private var ShopBackingMain:Class;
		public var shopBackingMain:BitmapData = new ShopBackingMain().bitmapData;*/
		
		[Embed(source="Graphics2/ShopBackingMain.png")]
		private var ShopBackingMain:Class;
		public var shopBackingMain:BitmapData = new ShopBackingMain().bitmapData;
		
		[Embed(source="Graphics2/unique/ShopMackingMainSmall.png")]
		private var ShopMackingMainSmall:Class;
		public var shopMackingMainSmall:BitmapData = new ShopMackingMainSmall().bitmapData;
		
		[Embed(source="Graphics2/Sale01.png")]
		private var Sale01:Class;
		public var sale01:BitmapData = new Sale01().bitmapData;
		
		[Embed(source="Graphics2/ShopBackingMain1.png")]
		private var ShopBackingMain1:Class;
		public var shopBackingMain1:BitmapData = new ShopBackingMain1().bitmapData;
		
		/*[Embed(source = "Textures/ShopBackingSmall.png")]
		private var ShopBackingSmall:Class;
		public var shopBackingSmall:BitmapData = new ShopBackingSmall().bitmapData;*/
		
		[Embed(source="Graphics2/ShopBackingSmall.png")]
		private var ShopBackingSmall:Class;
		public var shopBackingSmall:BitmapData = new ShopBackingSmall().bitmapData;
		
		[Embed(source="Graphics2/ShopBackingSmall1.png")]
		private var ShopBackingSmall1:Class;
		public var shopBackingSmall1:BitmapData = new ShopBackingSmall1().bitmapData;
		
		[Embed(source="Graphics2/ShopBackingSmall2.png")]
		private var ShopBackingSmall2:Class;
		public var shopBackingSmall2:BitmapData = new ShopBackingSmall2().bitmapData;
		
		[Embed(source="Graphics2/ShopBackingSmall3.png")]
		private var ShopBackingSmall3:Class;
		public var shopBackingSmall3:BitmapData = new ShopBackingSmall3().bitmapData;
		
		[Embed(source = "Textures/Star.png")]
		private var Star:Class;
		public var star:BitmapData = new Star().bitmapData;
		
		[Embed(source="Graphics2/FlowersDecor.png")]
		private var FlowersDecor:Class;
		public var flowersDecor:BitmapData = new FlowersDecor().bitmapData;
		
		[Embed(source="Graphics2/Crown.png")]
		private var Crown:Class;
		public var crown:BitmapData = new Crown().bitmapData;
		
		/*[Embed(source = "Textures/StorageBackingMain.png")]
		private var StorageBackingMain:Class;
		public var storageBackingMain:BitmapData = new StorageBackingMain().bitmapData;*/
		
		[Embed(source="Graphics2/storage/StorageBackingMain.png")]
		private var StorageBackingMain:Class;
		public var storageBackingMain:BitmapData = new StorageBackingMain().bitmapData;
		
		
		//private var StorageBackingMain:Class;
		//public var storageBackingMain:BitmapData = new StorageBackingMain().bitmapData;
		
		/*[Embed(source = "Textures/StorageBackingSmall.png")]
		private var StorageBackingSmall:Class;
		public var storageBackingSmall:BitmapData = new StorageBackingSmall().bitmapData;*/
		
		[Embed(source="Graphics2/storage/StorageBackingSmall.png")]
		private var StorageBackingSmall:Class;
		public var storageBackingSmall:BitmapData = new StorageBackingSmall().bitmapData;
		
		[Embed(source="Graphics2/storage/StorageBackingSmall2.png")]
		private var StorageBackingSmall2:Class;
		public var storageBackingSmall2:BitmapData = new StorageBackingSmall2().bitmapData;
		
		[Embed(source="Graphics2/upgrade/Plate.png")]
		private var Plate:Class;
		public var plate:BitmapData = new Plate().bitmapData;
		
		[Embed(source="Graphics2/storage/StorageUpperBacking.png")]
		private var StorageUpperBacking:Class;
		public var storageUpperBacking:BitmapData = new StorageUpperBacking().bitmapData;
		
		[Embed(source = "Textures/TradePostBackingSmall.png")]
		private var TradePostBackingSmall:Class;
		public var tradePostBackingSmall:BitmapData = new TradePostBackingSmall().bitmapData;
		
		[Embed(source="Graphics2/TradePostBackingSmall2.png")]
		private var TradePostBackingSmall2:Class;
		public var tradePostBackingSmall2:BitmapData = new TradePostBackingSmall2().bitmapData;
		
		[Embed(source="Graphics2/TradepostBacking.png")]
		private var TradepostBacking:Class;
		public var tradepostBacking:BitmapData = new TradepostBacking().bitmapData;
		
		[Embed(source = "Textures/TradePostDarkBacking.png")]
		private var TradePostDarkBacking:Class;
		public var tradePostDarkBacking:BitmapData = new TradePostDarkBacking().bitmapData;
		
		//[Embed(source = "Textures/TradingPostBackingMain.png")]
		//private var TradingPostBackingMain:Class;
		//public var tradingPostBackingMain:BitmapData = new TradingPostBackingMain().bitmapData;
		
		[Embed(source="Graphics2/TradingPostBackingMain.png")]
		private var TradingPostBackingMain:Class;
		public var tradingPostBackingMain:BitmapData = new TradingPostBackingMain().bitmapData;
		
		[Embed(source = "Textures/TradingPostBackingMainHeader.png")]
		private var TradingPostBackingMainHeader:Class;
		public var tradingPostBackingMainHeader:BitmapData = new TradingPostBackingMainHeader().bitmapData;
		
		[Embed(source="Textures/GiftBttn.png")]
		private var GiftBttn:Class;
		public var giftBttn:BitmapData = new GiftBttn().bitmapData;
		
		[Embed(source="Graphics2/GiftEvent.png")]
		private var GiftEvent:Class;
		public var giftEvent:BitmapData = new GiftEvent().bitmapData;
		
		[Embed(source="Textures/CollectionBackingSmall.png")]
		private var CollectionBackingSmall:Class;
		public var collectionBackingSmall:BitmapData = new CollectionBackingSmall().bitmapData;
		
		[Embed(source="Graphics2/ReferalRoundBacking.png")]
		private var ReferalRoundBacking:Class;
		public var referalRoundBacking:BitmapData = new ReferalRoundBacking().bitmapData;
		
		[Embed(source="Graphics2/storage/WishlistBttn.png")]
		private var WishlistBttn:Class;
		public var wishlistBttn:BitmapData = new WishlistBttn().bitmapData;
		
		[Embed(source="Textures/WhiteDot.png")]
		private var WhiteDot:Class;
		public var whiteDot:BitmapData = new WhiteDot().bitmapData;
		
		[Embed(source="Textures/CursorsPanelBg.png")]
		private var CursorsPanelBg:Class;
		public var cursorsPanelBg:BitmapData = new CursorsPanelBg().bitmapData;
		
		[Embed(source="Textures/CursorsPanelBg2.png")]
		private var CursorsPanelBg2:Class;
		public var cursorsPanelBg2:BitmapData = new CursorsPanelBg2().bitmapData;
		
		[Embed(source="Textures/CursorsPanelBg3.png")]
		private var CursorsPanelBg3:Class;
		public var cursorsPanelBg3:BitmapData = new CursorsPanelBg3().bitmapData;
		
		[Embed(source="Textures/CursorsPanelItemBg.png")]
		private var CursorsPanelItemBg:Class;
		public var cursorsPanelItemBg:BitmapData = new CursorsPanelItemBg().bitmapData;
		
		[Embed(source="Graphics2/PortCoinsBack.png")]
		private var PortCoinsBack:Class;
		public var portCoinsBack:BitmapData = new PortCoinsBack().bitmapData;
		
		[Embed(source="Graphics2/SpeechBubbleMainBacking.png")]
		private var SpeechBubbleMainBacking:Class;
		public var speechBubbleMainBacking:BitmapData = new SpeechBubbleMainBacking().bitmapData;
		
		[Embed(source="Textures/SpeechBubbleMainBackingBottom.png")]
		private var SpeechBubbleMainBackingBottom:Class;
		public var speechBubbleMainBackingBottom:BitmapData = new SpeechBubbleMainBackingBottom().bitmapData;
		
		[Embed(source="Textures/SpeechBubbleMainBackingBottom2.png")]
		private var SpeechBubbleMainBackingBottom2:Class;
		public var speechBubbleMainBackingBottom2:BitmapData = new SpeechBubbleMainBackingBottom2().bitmapData;
		
		[Embed(source="Textures/SpeechBubbleMainBackingTop.png")]
		private var SpeechBubbleMainBackingTop:Class;
		public var speechBubbleMainBackingTop:BitmapData = new SpeechBubbleMainBackingTop().bitmapData;
		
		[Embed(source="Textures/SpeechBubbleMainBackingTop2.png")]
		private var SpeechBubbleMainBackingTop2:Class;
		public var speechBubbleMainBackingTop2:BitmapData = new SpeechBubbleMainBackingTop2().bitmapData;
		
		[Embed(source="Graphics2/PieceBC.png")]
		private var PieceBC:Class;
		public var pieceBC:BitmapData = new PieceBC().bitmapData;
		
		[Embed(source="Textures/QuestsMainBacking.png")]
		private var QuestsMainBacking:Class;
		public var questsMainBacking:BitmapData = new QuestsMainBacking().bitmapData;
		
		[Embed(source="Graphics2/TradeportSmallBacking.png")]
		private var TradeportSmallBacking:Class;
		public var tradeportSmallBacking:BitmapData = new TradeportSmallBacking().bitmapData;
		
		[Embed(source="Graphics2/QuestsSmallBackingTopPiece.png")]
		private var QuestsSmallBackingTopPiece:Class;
		public var questsSmallBackingTopPiece:BitmapData = new QuestsSmallBackingTopPiece().bitmapData;
		
		[Embed(source="Graphics2/TimerBacking.png")]
		private var TimerBacking:Class;
		public var timerBacking:BitmapData = new TimerBacking().bitmapData;
		
		[Embed(source="Graphics2/QuestsSmallBackingBottomPiece.png")]
		private var QuestsSmallBackingBottomPiece:Class;
		public var questsSmallBackingBottomPiece:BitmapData = new QuestsSmallBackingBottomPiece().bitmapData;
		
		[Embed(source="Textures/SpeechBubbleSmallBackingPiece.png")]
		private var SpeechBubbleSmallBackingPiece:Class;
		public var speechBubbleSmallBackingPiece:BitmapData = new SpeechBubbleSmallBackingPiece().bitmapData;
		
		[Embed(source="Graphics2/CheckMark.png")]
		private var CheckMarkBig:Class;
		public var checkMarkBig:BitmapData = new CheckMarkBig().bitmapData;
		
		[Embed(source="Textures/CheckboxRound.png")]
		private var CheckboxRound:Class;
		public var checkboxRound:BitmapData = new CheckboxRound().bitmapData;
		
		[Embed(source="Textures/ItemBackingOff.png")]
		private var ItemBackingOff:Class;
		public var itemBackingOff:BitmapData = new ItemBackingOff().bitmapData;
		
		
		
		[Embed(source="Textures/OrangeStripPiece.png")]
		private var OrangeStripPiece:Class;
		public var orangeStripPiece:BitmapData = new OrangeStripPiece().bitmapData;
		
		//[Embed(source="Textures/TimerBrown.png")]
		//private var TimerBrown:Class;
		//public var timerBrown:BitmapData = new TimerBrown().bitmapData;
		
		[Embed(source="Graphics2/TimerBrown.png")]
		private var TimerBrown:Class;
		public var timerBrown:BitmapData = new TimerBrown().bitmapData;
		
		[Embed(source="Textures/ButtonDiamands.png")]
		private var ButtonDiamands:Class;
		public var buttonDiamands:BitmapData = new ButtonDiamands().bitmapData;
		
		[Embed(source="Textures/Recipte_line.png")]
		private var Recipte_line:Class;
		public var recipte_line:BitmapData = new Recipte_line().bitmapData;
		
		[Embed(source="Textures/Equals.png")]
		private var Equals:Class;
		public var equals:BitmapData = new Equals().bitmapData;
		
		[Embed(source="Textures/Diamond.png")]
		private var Diamond:Class;
		public var diamond:BitmapData = new Diamond().bitmapData;
		
		[Embed(source="Textures/TimerYellow.png")]
		private var TimerYellow:Class;
		public var timerYellow:BitmapData = new TimerYellow().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductBacking.png")]
		private var ProductBacking:Class;
		public var productBacking:BitmapData = new ProductBacking().bitmapData;
		
		/*[Embed(source="Textures/QuestsMainBacking2.png")]
		private var QuestsMainBacking2:Class;
		public var questsMainBacking2:BitmapData = new QuestsMainBacking2().bitmapData;*/
		
		[Embed(source="Graphics2/ShopSpecialBacking.png")]
		private var QuestsMainBacking2:Class;
		public var questsMainBacking2:BitmapData = new QuestsMainBacking2().bitmapData;
		
		[Embed(source="Graphics2/ShopSpecialBacking1.png")]
		private var ShopSpecialBacking1:Class;
		public var shopSpecialBacking1:BitmapData = new ShopSpecialBacking1().bitmapData;
		
		[Embed(source="Graphics2/ShopSpecialBacking2.png")]
		private var ShopSpecialBacking2:Class;
		public var shopSpecialBacking2:BitmapData = new ShopSpecialBacking2().bitmapData;
		
		[Embed(source="Textures/Separator2.png")]
		private var Separator2:Class;
		public var separator2:BitmapData = new Separator2().bitmapData;
		
		
		[Embed(source="Textures/Beardie.png")]
		private var Beardie:Class;
		public var beardie:BitmapData = new Beardie().bitmapData;
		
		[Embed(source="Textures/Leader.png")]
		private var Leader:Class;
		public var leader:BitmapData = new Leader().bitmapData;
		
		[Embed(source="Textures/Rabbit.png")]
		private var Rabbit:Class;
		public var rabbit:BitmapData = new Rabbit().bitmapData;
		
		[Embed(source="Textures/Robot.png")]
		private var Robot:Class;
		public var robot:BitmapData = new Robot().bitmapData;
		
		[Embed(source="Graphics2/CharsStatusBacking.png")]
		private var CharsStatusBacking:Class;
		public var charsStatusBacking:BitmapData = new CharsStatusBacking().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/ArrowUp.png")]
		private var ArrowUp:Class;
		public var arrowUp:BitmapData = new ArrowUp().bitmapData;
		
		[Embed(source="Textures/BlueRibbon.png")]
		private var BlueRibbon:Class;
		public var blueRibbon:BitmapData = new BlueRibbon().bitmapData;
		
		[Embed(source="Graphics2/CheckBoxEmpty.png")]
		private var CheckBox:Class;
		public var checkBox:BitmapData = new CheckBox().bitmapData;
		
		[Embed(source="Graphics2/CheckBoxFull.png")]
		private var CheckBoxPress:Class;
		public var checkBoxPress:BitmapData = new CheckBoxPress().bitmapData;
		
		[Embed(source="Textures/Glow.png")]
		private var Glow:Class;
		public var glow:BitmapData = new Glow().bitmapData;
		
		[Embed(source="Graphics2/UpgradeArrow.png")]
		private var UpgradeArrow:Class;
		public var upgradeArrow:BitmapData = new UpgradeArrow().bitmapData;
		
		[Embed(source="Textures/UnderPiece.png")]
		private var UnderPiece:Class;
		public var underPiece:BitmapData = new UnderPiece().bitmapData;
		
		[Embed(source="Textures/Techno.png")]
		private var Techno:Class;
		public var techno:BitmapData = new Techno().bitmapData;
		
		//[Embed(source="Textures/BgItem.png")]
		//private var BgItem:Class;
		//public var bgItem:BitmapData = new BgItem().bitmapData;
		
		[Embed(source="Graphics2/Upgrade/BgItem.png")]
		private var BgItem:Class;
		public var bgItem:BitmapData = new BgItem().bitmapData;
		
		[Embed(source="Textures/ProgressBarPink.png")]
		private var ProgressBarPink:Class;
		public var progressBarPink:BitmapData = new ProgressBarPink().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductionProgressBar.png")]
		private var ProductionProgressBar:Class;
		public var productionProgressBar:BitmapData = new ProductionProgressBar().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductionProgressBarBacking.png")]
		private var ProductionProgressBarBacking:Class;
		public var productionProgressBarBacking:BitmapData = new ProductionProgressBarBacking().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductBacking2.png")]
		private var ProductBacking2:Class;
		public var productBacking2:BitmapData = new ProductBacking2().bitmapData;
		
		[Embed(source="Graphics2/mini/IconEff.png")]
		private var IconEff:Class;
		public var iconEff:BitmapData = new IconEff().bitmapData;
		
		[Embed(source="Textures/BankBackingTop.png")]
		private var BankBackingTop:Class;
		public var bankBackingTop:BitmapData = new BankBackingTop().bitmapData;
		
		[Embed(source="Textures/BankBackingBot.png")]
		private var BankBackingBot:Class;
		public var bankBackingBot:BitmapData = new BankBackingBot().bitmapData;
		
		[Embed(source="Textures/BankRoundBaking.png")]
		private var BankRoundBaking:Class;
		public var bankRoundBaking:BitmapData = new BankRoundBaking().bitmapData;
		
		[Embed(source="Textures/DotGray.png")]
		private var DotGray:Class;
		public var dotGray:BitmapData = new DotGray().bitmapData;
		
		[Embed(source="Textures/Boost.png")]
		private var Boost:Class;
		public var boost:BitmapData = new Boost().bitmapData;
		
		[Embed(source="Graphics2/LevelUpHeader.png")]
		private var LevelUpHeader:Class;
		public var levelUpHeader:BitmapData = new LevelUpHeader().bitmapData;
		
		[Embed(source="Textures/Glow2.png")]
		private var Glow2:Class;
		public var glow2:BitmapData = new Glow2().bitmapData;
		
		[Embed(source="Textures/ItemBacking2.png")]
		private var ItemBacking2:Class;
		public var itemBacking2:BitmapData = new ItemBacking2().bitmapData;
		
		[Embed(source="Graphics2/questWindow/LevelUpOpenBacking.png")]
		private var LevelUpOpenBacking:Class;
		public var levelUpOpenBacking:BitmapData = new LevelUpOpenBacking().bitmapData;
		
		[Embed(source="Graphics2/QuestsSmallRoundPiece.png")]
		private var QuestsSmallRoundPiece:Class;
		public var questsSmallRoundPiece:BitmapData = new QuestsSmallRoundPiece().bitmapData;
		
		[Embed(source="Graphics2/QuestsSmallRoundBottomPiece.png")]
		private var QuestsSmallRoundBottomPiece:Class;
		public var questsSmallRoundBottomPiece:BitmapData = new QuestsSmallRoundBottomPiece().bitmapData;
		
		[Embed(source="Textures/Separator3.png")]
		private var Separator3:Class;
		public var separator3:BitmapData = new Separator3().bitmapData;
		
		/*[Embed(source="Textures/StripNew.png")]
		private var StripNew:Class;
		public var stripNew:BitmapData = new StripNew().bitmapData;*/
		
		[Embed(source="Graphics2/StripNew.png")]
		private var StripNew:Class;
		public var stripNew:BitmapData = new StripNew().bitmapData;
		
		[Embed(source = "Graphics2/GoldRibbon.png")]
		private var GoldRibbon:Class;
		public var goldRibbon:BitmapData = new GoldRibbon().bitmapData;
		
		/*[Embed(source="Textures/ShopSpecialBacking.png")]
		private var ShopSpecialBacking:Class;
		public var shopSpecialBacking:BitmapData = new ShopSpecialBacking().bitmapData;*/
		
		[Embed(source="Graphics2/ShopSpecialBacking.png")]
		private var ShopSpecialBacking:Class;
		public var shopSpecialBacking:BitmapData = new ShopSpecialBacking().bitmapData;
		
		[Embed(source="Textures/ShopGlow.png")]
		private var ShopGlow:Class;
		public var shopGlow:BitmapData = new ShopGlow().bitmapData;
		
		[Embed(source="Textures/BgBrown.png")]
		private var BgBrown:Class;
		public var bgBrown:BitmapData = new BgBrown().bitmapData;
		
		[Embed(source="Textures/BuildingsDarckBacking.png")]
		private var BuildingsDarckBacking:Class;
		public var buildingsDarckBacking:BitmapData = new BuildingsDarckBacking().bitmapData;
		
		[Embed(source="Textures/AvatarBgBott.png")]
		private var AvatarBgBott:Class;
		public var avatarBgBott:BitmapData = new AvatarBgBott().bitmapData;
		
		[Embed(source="Textures/AvatarBgTop.png")]
		private var AvatarBgTop:Class;
		public var avatarBgTop:BitmapData = new AvatarBgTop().bitmapData;
		
		//[Embed(source="Textures/AvaBg.png")]
		//private var AvaBg:Class;
		//public var avaBg:BitmapData = new AvaBg().bitmapData;
		
		[Embed(source="Textures/AvaBg2.png")]
		private var AvaBg2:Class;
		public var avaBg2:BitmapData = new AvaBg2().bitmapData;
		
		[Embed(source="Textures/HomeBttnBg.png")]
		private var HomeBttnBg:Class;
		public var homeBttnBg:BitmapData = new HomeBttnBg().bitmapData;
		
		[Embed(source="Graphics2/Hunger.png")]
		private var Hunger:Class;
		public var animalBubble:BitmapData = new Hunger().bitmapData;
		
		[Embed(source="Textures/HandIco.png")]
		private var HandIco:Class;
		public var handIco:BitmapData = new HandIco().bitmapData;
		
		[Embed(source="Textures/HungryIco.png")]
		private var HungryIco:Class;
		public var hungryIco:BitmapData = new HungryIco().bitmapData;
		
		[Embed(source="Graphics2/mini/MaterialIconRed.png")]
		private var MaterialIconRed:Class;
		public var materialIconRed:BitmapData = new MaterialIconRed().bitmapData;
		
		[Embed(source="Textures/InstantsTimer.png")]
		private var InstantsTimer:Class;
		public var instantsTimer:BitmapData = new InstantsTimer().bitmapData;
		
		[Embed(source="Textures/SpecialMark.png")]
		private var SpecialMark:Class;
		public var specialMark:BitmapData = new SpecialMark().bitmapData;
		
		[Embed(source="Graphics2/ChestCheckMark.png")]
		private var ChestCheckMark:Class;
		public var chestCheckMark:BitmapData = new ChestCheckMark().bitmapData;
		
		
		[Embed(source="Textures/Dice.png")]
		private var Dice:Class;
		public var dice:BitmapData = new Dice().bitmapData;
		
		[Embed(source="Textures/MissionBacking.png")]
		private var MissionBacking:Class;
		public var missionBacking:BitmapData = new MissionBacking().bitmapData;
		
		
		
		[Embed(source="Textures/BankRoundBaking2.png")]
		private var BankRoundBaking2:Class;
		public var bankRoundBaking2:BitmapData = new BankRoundBaking2().bitmapData;
		
		[Embed(source="Textures/MapBacking.png")]
		private var MapBacking:Class;
		public var mapBacking:BitmapData = new MapBacking().bitmapData;
		
		[Embed(source="Textures/HomeBttnShort.png")]
		private var HomeBttnShort:Class;
		public var homeBttnShort:BitmapData = new HomeBttnShort().bitmapData;
		
		[Embed(source="Textures/EmptySlot.png")]
		private var EmptySlot:Class;
		public var emptySlot:BitmapData = new EmptySlot().bitmapData;
		
		
		[Embed(source="Textures/Antenna.png")]
		private var Antenna:Class;
		public var antenna:BitmapData = new Antenna().bitmapData;
		
		[Embed(source="Graphics2/ClosedSign.png")]
		private var ClosedSign:Class;
		public var closedSign:BitmapData = new ClosedSign().bitmapData;
		
		[Embed(source="Graphics2/Avatarmask.png")]
		private var AvatarMask:Class;
		public var avatarMask:BitmapData = new AvatarMask().bitmapData;
		
		[Embed(source="Graphics2/Door.png")]
		private var Door:Class;
		public var door:BitmapData = new Door().bitmapData;
		
		[Embed(source="Textures/HouseBacking.png")]
		private var HouseBacking:Class;
		public var houseBacking:BitmapData = new HouseBacking().bitmapData;
		
		[Embed(source="Graphics2/Wicket.png")]
		private var Wicket:Class;
		public var wicket:BitmapData = new Wicket().bitmapData;
		
		[Embed(source="Textures/HouseRoof.png")]
		private var HouseRoof:Class;
		public var houseRoof:BitmapData = new HouseRoof().bitmapData;
		
		[Embed(source="Textures/AlienFriendsAvatar.png")]
		private var AlienFriendsAvatar:Class;
		public var alienFriendsAvatar:BitmapData = new AlienFriendsAvatar().bitmapData;
		
		[Embed(source="Textures/AchievementBacking.png")]
		private var AchievementBacking:Class;
		public var achievementBacking:BitmapData = new AchievementBacking().bitmapData;
		
		[Embed(source="Graphics2/AchievementUnlockBacking.png")]
		private var AchievementUnlockBacking:Class;
		public var achievementUnlockBacking:BitmapData = new AchievementUnlockBacking().bitmapData;
		
		[Embed(source="Textures/EmptyStarSlot.png")]
		private var EmptyStarSlot:Class;
		public var emptyStarSlot:BitmapData = new EmptyStarSlot().bitmapData;
		
		[Embed(source="Textures/BlueRibbon2.png")]
		private var BlueRibbon2:Class;
		public var blueRibbon2:BitmapData = new BlueRibbon2().bitmapData;
		
		[Embed(source="Textures/RedBow.png")]
		private var RedBow:Class;
		public var redBow:BitmapData = new RedBow().bitmapData;
		
		[Embed(source="Graphics2/unique/TimeBg.png")]
		private var TimeBg:Class;
		public var timeBg:BitmapData = new TimeBg().bitmapData;
		
		[Embed(source="Graphics2/SalseTimeBg.png")]
		private var SalseTimeBg:Class;
		public var salseTimeBg:BitmapData = new SalseTimeBg().bitmapData;
		
		[Embed(source="Textures/DecorStars.png")]
		private var DecorStars:Class;
		public var decorStars:BitmapData = new DecorStars().bitmapData;
		
		[Embed(source="Textures/SaleGlowPiece.png")]
		private var SaleGlowPiece:Class;
		public var saleGlowPiece:BitmapData = new SaleGlowPiece().bitmapData;
		
		[Embed(source="Textures/ArrowInst.png")]
		private var ArrowInst:Class;
		public var arrowInst:BitmapData = new ArrowInst().bitmapData;
		
		[Embed(source="Textures/UpArrowSmall.png")]
		private var UpArrowSmall:Class;
		public var upArrowSmall:BitmapData = new UpArrowSmall().bitmapData;
		
		[Embed(source="Textures/GreenPlus.png")]
		private var GreenPlus:Class;
		public var greenPlus:BitmapData = new GreenPlus().bitmapData;
		
		[Embed(source="Graphics2/HutNektarBack.png")]
		private var HutNektarBack:Class;
		public var hutNektarBack:BitmapData = new HutNektarBack().bitmapData;
		
		[Embed(source="Graphics2/WinnerFury.png")]
		private var WinnerFury:Class;
		public var winnerFury:BitmapData = new WinnerFury().bitmapData;	
		
		
		[Embed(source="Graphics2/BoatIcon_1.png")]
		private var BoatIcon_1:Class;
		public var boatIcon_1:BitmapData = new BoatIcon_1().bitmapData;		
		
		[Embed(source="Graphics2/BoatIcon_2.png")]
		private var BoatIcon_2:Class;
		public var boatIcon_2:BitmapData = new BoatIcon_2().bitmapData;		
		
		[Embed(source="Graphics2/BoatIcon_3.png")]
		private var BoatIcon_3:Class;
		public var boatIcon_3:BitmapData = new BoatIcon_3().bitmapData;
		
		

		[Embed(source="Textures/ShadowBoy.png")]
		private var ShadowBoy:Class;
		public var shadowBoy:BitmapData = new ShadowBoy().bitmapData;
		
		[Embed(source="Graphics2/CowIco.png")]
		private var CowIco:Class;
		public var cowIco:BitmapData = new CowIco().bitmapData;
		
		[Embed(source="Graphics2/ChickenIco.png")]
		private var ChickenIco:Class;
		public var chickenIco:BitmapData = new ChickenIco().bitmapData;
		
		[Embed(source="Graphics2/SheepIco.png")]
		private var SheepIco:Class;
		public var sheepIco:BitmapData = new SheepIco().bitmapData;
		
		[Embed(source="Graphics2/PigIco.png")]
		private var PigIco:Class;
		public var pigIco:BitmapData = new PigIco().bitmapData;
		
		[Embed(source="Graphics2/RabbitIco.png")]
		private var RabbitIco:Class;
		public var rabbitIco:BitmapData = new RabbitIco().bitmapData;
		
		[Embed(source="Graphics2/SnakeIco.png")]
		private var SnakeIco:Class;
		public var snakeIco:BitmapData = new SnakeIco().bitmapData;
		
		[Embed(source="Graphics2/ShepherdIco.png")]
		private var ShepherdIco:Class;
		public var shepherdIco:BitmapData = new ShepherdIco().bitmapData;
		
		[Embed(source="Textures/ShadowFat.png")]
		private var ShadowFat:Class;
		public var shadowFat:BitmapData = new ShadowFat().bitmapData;
		
		[Embed(source="Textures/ShadowGirl.png")]
		private var ShadowGirl:Class;
		public var shadowGirl:BitmapData = new ShadowGirl().bitmapData;
		
		[Embed(source = "Graphics2/QuestIconBacking.png")]
		private var QuestIconBacking:Class;
		public var questIconBacking:BitmapData = new QuestIconBacking().bitmapData;
		
		[Embed(source="Textures/CharacterBacking.png")]
		private var CharacterBacking:Class;
		public var characterBacking:BitmapData = new CharacterBacking().bitmapData;
		
		[Embed(source="Textures/CharacterProgressBar.png")]
		private var CharacterProgressBar:Class;
		public var characterProgressBar:BitmapData = new CharacterProgressBar().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductionProgressBarGreen.png")]
		private var ProductionProgressBarGreen:Class;
		public var productionProgressBarGreen:BitmapData = new ProductionProgressBarGreen().bitmapData;
		
		[Embed(source="Textures/TextBubbleTail.png")]
		private var TextBubbleTail:Class;
		public var textBubbleTail:BitmapData = new TextBubbleTail().bitmapData;
		
		[Embed(source="Textures/TutorialRibbon.png")]
		private var TutorialRibbon:Class;
		public var tutorialRibbon:BitmapData = new TutorialRibbon().bitmapData;
		
		[Embed(source="Textures/LoadingBacking.png")]
		private var LoadingBacking:Class;
		public var loadingBacking:BitmapData = new LoadingBacking().bitmapData;
		
		[Embed(source="Textures/Logo.png")]
		private var Logo:Class;
		public var logo:BitmapData = new Logo().bitmapData;
		
		[Embed(source="Graphics2/lastUpdate/UpgradeSmallBacking.png")]
		private var UpgradeSmallBacking:Class;
		public var upgradeSmallBacking:BitmapData = new UpgradeSmallBacking().bitmapData;
		
		[Embed(source="Graphics2/lastUpdate/StorageDarkBackingSlim.png")]
		private var StorageDarkBackingSlim:Class;
		public var storageDarkBackingSlim:BitmapData = new StorageDarkBackingSlim().bitmapData;
		
		[Embed(source="Graphics2/upgrade/PersIcon.png")]
		private var PersIcon:Class;
		public var persIcon:BitmapData = new PersIcon().bitmapData;
		
		[Embed(source="Graphics2/CommunityEvent.png")]
		private var CommunityEvent:Class;
		public var communityEvent:BitmapData = new CommunityEvent().bitmapData;
		
		[Embed(source="Graphics2/TradePortPic.png")]
		private var TradePortPic:Class;
		public var tradePortPic:BitmapData = new TradePortPic().bitmapData;
		
		[Embed(source="Graphics2/Nectarsource.png")]
		private var Nectarsource:Class;
		public var nectarsource:BitmapData = new Nectarsource().bitmapData;
		
		[Embed(source="Graphics2/Warehouse.png")]
		private var Warehouse:Class;
		public var warehouse:BitmapData = new Warehouse().bitmapData;
		
		[Embed(source="Graphics2/FrSlotBig.png")]
		private var FriendsBacking:Class;
		public var friendsBacking:BitmapData = new FriendsBacking().bitmapData;
		
		/////////////////////////////////////////////////////////////////////////////////////////////ITEM WINDOW
		
		[Embed(source="Graphics2/productionWindow/BuildingsSlot.png")]
		private var BuildingsSlot:Class;
		public var buildingsSlot:BitmapData = new BuildingsSlot().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/BuildingsBttn.png")]
		private var BuildingsBttn:Class;
		public var buildingsBttn:BitmapData = new BuildingsBttn().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/MenuArrow.png")]
		private var MenuArrow:Class;
		public var menuArrow:BitmapData = new MenuArrow().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/MenuArrow2.png")]
		private var MenuArrow2:Class;
		public var menuArrow2:BitmapData = new MenuArrow2().bitmapData;
		
		[Embed(source="Graphics2/ProductionReadyBacking.png")]
		private var ProductionReadyBacking:Class;
		public var productionReadyBacking:BitmapData = new ProductionReadyBacking().bitmapData;
		
		[Embed(source="Graphics2/ProductionReadyBacking2.png")]
		private var ProductionReadyBacking2:Class;
		public var productionReadyBacking2:BitmapData = new ProductionReadyBacking2().bitmapData;
		
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////QUEST WINDOW
		[Embed(source="Graphics2/questWindow/DialogueBacking.png")]
		private var DialogueBacking:Class;
		public var dialogueBacking:BitmapData = new DialogueBacking().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestRibbon.png")]
		private var QuestRibbon:Class;
		public var questRibbon:BitmapData = new QuestRibbon().bitmapData;
		
		[Embed(source="Graphics2/AchievementCup.png")]
		private var AchievementCup:Class;
		public var achievementCup:BitmapData = new AchievementCup().bitmapData;
		
		[Embed(source="Graphics2/questWindow/Divider.png")]
		private var Divider:Class;
		public var divider:BitmapData = new Divider().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestBacking.png")]
		private var QuestBacking:Class;
		public var questBacking:BitmapData = new QuestBacking().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestCheckmarkSlot.png")]
		private var QuestCheckmarkSlot:Class;
		public var questCheckmarkSlot:BitmapData = new QuestCheckmarkSlot().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestRewardBacking.png")]
		private var QuestRewardBacking:Class;
		public var questRewardBacking:BitmapData = new QuestRewardBacking().bitmapData;
		
		[Embed(source="Graphics2/RoundCheck.png")]
		private var RoundCheck:Class;
		public var roundCheck:BitmapData = new RoundCheck().bitmapData;
		
		[Embed(source="Graphics2/lastUpdate/QuestRewardBackingMini.png")]
		private var QuestRewardBackingMini:Class;
		public var questRewardBackingMini:BitmapData = new QuestRewardBackingMini().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestRewardBacking1.png")]
		private var QuestRewardBacking1:Class;
		public var questRewardBacking1:BitmapData = new QuestRewardBacking1().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestTaskBackingBot.png")]
		private var QuestTaskBackingBot:Class;
		public var questTaskBackingBot:BitmapData = new QuestTaskBackingBot().bitmapData;
		
		[Embed(source="Graphics2/OrderBacking.png")]
		private var OrderBacking:Class;
		public var orderBacking:BitmapData = new OrderBacking().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/BuildingsLockedBacking.png")]
		private var BuildingsLockedBacking:Class;
		public var buildingsLockedBacking:BitmapData = new BuildingsLockedBacking().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/Lock.png")]
		private var Lock:Class;
		public var lock:BitmapData = new Lock().bitmapData;
		
		[Embed(source="Graphics2/BigLock.png")]
		private var BigLock:Class;
		public var bigLock:BitmapData = new BigLock().bitmapData;
		
		[Embed(source="Graphics2/Locked2.png")]
		private var Lock2:Class;
		public var lock2:BitmapData = new Lock2().bitmapData;
		
		
		[Embed(source="Graphics2/lastUpdate/UpgradeBttnBacking.png")]
		private var UpgradeBttnBacking:Class;
		public var upgradeBttnBacking:BitmapData = new UpgradeBttnBacking().bitmapData;
		
		[Embed(source="Graphics2/lastUpdate/UpgradeBttnDec.png")]
		private var UpgradeBttnDec:Class;
		public var upgradeBttnDec:BitmapData = new UpgradeBttnDec().bitmapData;
		
		[Embed(source="Graphics2/lastUpdate/UpgradeBttn.png")]
		private var UpgradeBttn:Class;
		public var upgradeBttn:BitmapData = new UpgradeBttn().bitmapData;
		
		[Embed(source="Graphics2/lastUpdate/UpgradeBttnGrey.png")]
		private var UpgradeBttnGrey:Class;
		public var upgradeBttnGrey:BitmapData = new UpgradeBttnGrey().bitmapData;
		
		//////////////////////////////////////////////////////////////////////////////////////////////QUEST_ICONS////////////////
		
		[Embed(source="Graphics2/questIcons/DragonIco.png")]
		private var DragonIco:Class;
		public var dragonIco:BitmapData = new DragonIco().bitmapData;
		
		[Embed(source="Graphics2/questIcons/DruidIco.png")]
		private var DruidIco:Class;
		public var druidIco:BitmapData = new DruidIco().bitmapData;
		
		[Embed(source="Graphics2/questIcons/EngineerIco.png")]
		private var EngineerIco:Class;
		public var engineerIco:BitmapData = new EngineerIco().bitmapData;
		
		[Embed(source="Graphics2/questIcons/EvilIco.png")]
		private var EvilIco:Class;
		public var evilIco:BitmapData = new EvilIco().bitmapData;
		
		[Embed(source="Graphics2/questIcons/MinionIco.png")]
		private var MinionIco:Class;
		public var minionIco:BitmapData = new MinionIco().bitmapData;
		
		[Embed(source="Graphics2/questIcons/QuestCompleteHeader.png")]
		private var QuestCompleteHeader:Class;
		public var questCompleteHeader:BitmapData = new QuestCompleteHeader().bitmapData;
		
		[Embed(source="Graphics2/questIcons/RangerIco.png")]
		private var RangerIco:Class;
		public var rangerIco:BitmapData = new RangerIco().bitmapData;
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////INSTANCE//////////////////////////
		
		[Embed(source="Graphics2/instance/BlueBannerBacking.png")]
		private var BlueBannerBacking:Class;
		public var blueBannerBacking:BitmapData = new BlueBannerBacking().bitmapData;
		
		[Embed(source="Graphics2/instance/PurpleBannerBacking.png")]
		private var PurpleBannerBacking:Class;
		public var purpleBannerBacking:BitmapData = new PurpleBannerBacking().bitmapData;
		
		[Embed(source="Graphics2/instance/PrinceInstanceIco.png")]
		private var PrinceInstanceIco:Class;
		public var princeInstanceIco:BitmapData = new PrinceInstanceIco().bitmapData;
		
		[Embed(source="Graphics2/instance/PrincessInstanceIco.png")]
		private var PrincessInstanceIco:Class;
		public var princessInstanceIco:BitmapData = new PrincessInstanceIco().bitmapData;

		[Embed(source="Graphics2/instance/Stand.png")]
		private var Stand:Class;
		public var stand:BitmapData = new Stand().bitmapData;
		
		[Embed(source="Graphics2/RoundProgressBar.png")]
		private var RoundProgressBar:Class;
		public var roundProgressBar:BitmapData = new RoundProgressBar().bitmapData;
		
		[Embed(source="Graphics2/RoundProgressBarGreen.png")]
		private var RoundProgressBarGreen:Class;
		public var roundProgressBarGreen:BitmapData = new RoundProgressBarGreen().bitmapData;
		
		[Embed(source="Graphics2/instance/BlueRay.png")]
		private var BlueRay:Class;
		public var blueRay:BitmapData = new BlueRay().bitmapData;
		
		[Embed(source="Graphics2/instance/TreasureBackground.png")]
		private var TreasureBackground:Class;
		public var treasureBackground:BitmapData = new TreasureBackground().bitmapData;
		
		
		
		[Embed(source="Graphics2/PurchItemBg1.png")]
		private var PurchItemBg1:Class;
		public var purchItemBg1:BitmapData = new PurchItemBg1().bitmapData;
		
		[Embed(source="Graphics2/PurchItemBg2.png")]
		private var PurchItemBg2:Class;
		public var purchItemBg2:BitmapData = new PurchItemBg2().bitmapData;
		
		[Embed(source="Graphics2/AvaBg.png")]
		private var AvaBg:Class;
		public var avaBg:BitmapData = new AvaBg().bitmapData;
		
		
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////TUTORIAL//////////////////////////
		
		[Embed(source="Graphics2/tutorial/TutorialPrince.png")]
		private var TutorialPrince:Class;
		public var tutorialPrince:BitmapData = new TutorialPrince().bitmapData;
		
		[Embed(source="Graphics2/tutorial/TutorialPrincess.png")]
		private var TutorialPrincess:Class;
		public var tutorialPrincess:BitmapData = new TutorialPrincess().bitmapData;
		
		[Embed(source="Graphics2/tutorial/TutorialDialogueBacking.png")]
		private var TutorialDialogueBacking:Class;
		public var tutorialDialogueBacking:BitmapData = new TutorialDialogueBacking().bitmapData;
		
		[Embed(source="Graphics2/tutorial/TutorialDialogueTail.png")]
		private var TutorialDialogueTail:Class;
		public var tutorialDialogueTail:BitmapData = new TutorialDialogueTail().bitmapData;
		
		[Embed(source="Graphics2/tutorial/TutorialCharsBacking.png")]
		private var TutorialCharsBacking:Class;
		public var tutorialCharsBacking:BitmapData = new TutorialCharsBacking().bitmapData;
		
		[Embed(source="Graphics2/tutorial/TutorialArrow.png")]
		private var TutorialArrow:Class;
		public var tutorialArrow:BitmapData = new TutorialArrow().bitmapData;
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////FURRY//////////////////////////
		
		[Embed(source="Graphics2/ErrorOops.png")]
		private var ErrorOops:Class;
		public var errorOops:BitmapData = new ErrorOops().bitmapData;
		
		[Embed(source="Graphics2/ErrorStorage.png")]
		private var ErrorStorage:Class;
		public var errorStorage:BitmapData = new ErrorStorage().bitmapData;
		
		[Embed(source="Graphics2/ErrorWork.png")]
		private var ErrorWork:Class;
		public var errorWork:BitmapData = new ErrorWork().bitmapData;
		
		[Embed(source="Graphics2/GreenBanner.png")]
		private var GreenBanner:Class;
		public var greenBanner:BitmapData = new GreenBanner().bitmapData;
		
		[Embed(source="Graphics2/VaultFury.png")]
		private var VaultFury:Class;
		public var vaultFury:BitmapData = new VaultFury().bitmapData;
		
		[Embed(source="Graphics2/InviteFuryBack.png")]
		private var InviteFuryBack:Class;
		public var inviteFuryBack:BitmapData = new InviteFuryBack().bitmapData;
		
		
		public function Windows():void
		{
			
		}
	}
}