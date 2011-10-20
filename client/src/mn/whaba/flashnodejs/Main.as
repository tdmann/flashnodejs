package mn.whaba.flashnodejs
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Main class.
	 * 
	 * @author Tim Mann
	 */
	public class Main extends Sprite 
	{
		
		private var client:Client;
		private var game:Game;
		
		private const GAME_POSITION:Point = new Point(0, 0);
		
		
		/**
		 * Entry point to the game.
		 */
		public function Main():void 
		{
			
			game = new Game();
			
			game.x = GAME_POSITION.x;
			game.y = GAME_POSITION.y;
			
			client = new Client(new Delegator(game.gameHandlers));
			client.connect();
			
			addChild(game);
		}
		
	}
	
}