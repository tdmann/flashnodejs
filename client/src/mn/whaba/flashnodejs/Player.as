package mn.whaba.flashnodejs 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	 * Represents a player onscreen. Has attached textbox and methods for speech.
	 * 
	 * @author Tim Mann
	 */
	public class Player extends Sprite
	{
		
		[Embed(source = "../../../../res/player.png")]
		public var playerBitmap:Class;
		
		private var bitmap:Bitmap;
		private var game:Game;
		
		private var chatField:TextField;
		private var chatTimer:Timer;
		private const CHAT_MAX_TIME:int = 5000;
		private const CHAT_CHARACTER_TIME_CAP:int = 50;
		private const CHAT_FIELD_POSITION:Point = new Point(30, -50);
		
		/**
		 * Creates a player. Sets up bitmap and chat textfield.
		 * 
		 * @param	game The game which holds this player.
		 */
		public function Player(game:Game, position:Object=null) 
		{	
			if (position == null) position = { x:0, y:0 };
			else trace("Made with pos " + position.x + "," + position.y);
			this.game = game;
			this.x = position.x;
			this.y = position.y;
			
			bitmap = new playerBitmap();
			bitmap.x = -bitmap.width / 2;
			bitmap.y = -bitmap.height / 2;
			
			chatField = new TextField();
			chatField.visible = false;
			chatField.x = CHAT_FIELD_POSITION.x;
			chatField.y = CHAT_FIELD_POSITION.y;
			
			chatTimer = new Timer(1000);
			chatTimer.addEventListener(TimerEvent.TIMER, hideChat);
			
			addChild(bitmap);
			addChild(chatField);
		}
		
		/**
		 * Fills this player's chatField with the provided text and shows it for a
		 * period of time based upon the length of the text.
		 * 
		 * @param	text The text for this player to say.
		 */
		public function say(text:String):void {
			chatField.text = text;
			chatField.visible = true;
			
			chatTimer.delay = (Number(Math.min(text.length, CHAT_CHARACTER_TIME_CAP)) / CHAT_CHARACTER_TIME_CAP) * CHAT_MAX_TIME;
			chatTimer.start();
		}
		
		/**
		 * Hides the chat display - called a few seconds after this player has said something.
		 * 
		 * @param	event
		 */
		private function hideChat(event:Event):void {
			chatTimer.stop();
			chatField.visible = false;
		}
		 
	}

}