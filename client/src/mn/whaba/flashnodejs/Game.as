package mn.whaba.flashnodejs 
{
	import com.adobe.serialization.json.JSON;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.Socket;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * Controller for the players in the game.
	 * 
	 * @author Tim Mann
	 */
	public class Game extends Sprite
	{
		private var socket:Socket;
		
		private var localPlayerId:int;
		private var localPlayer:Player;
		private var players:Object;
		
		private var chatBox:TextField;
		private const CHAT_BOX_BOUNDS:Rectangle = new Rectangle(350, 550, 100, 20);
		private const CHAT_BOX_MAX_CHARS:int = 15;
		
		/**
		 * Constructs a game.
		 */
		public function Game() 
		{
			players = new Object();
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		/**
		 * Event handler for when the game is added to the stage.
		 * Allows access to stage object so we can properly place
		 * the chat box.
		 * 
		 * @param	event
		 */
		public function addedToStage(event:Event):void {
			chatBox = new TextField();
			chatBox.border = true;
			chatBox.x = CHAT_BOX_BOUNDS.x;
			chatBox.y = CHAT_BOX_BOUNDS.y;
			chatBox.width = CHAT_BOX_BOUNDS.width;
			chatBox.height = CHAT_BOX_BOUNDS.height
			chatBox.type = "input";
			chatBox.maxChars = CHAT_BOX_MAX_CHARS;
	
			chatBox.addEventListener(KeyboardEvent.KEY_DOWN, chatBoxKeyDown);
			
			stage.addChild(chatBox);
		}
		
		/**
		 * Handles a stage mouse click event. Moves the main player to that location, and sends a message
		 * to the server about it.
		 * 
		 * @param	event
		 */
		public function mouseClick(event:MouseEvent):void {
			var newPosition:Point = globalToLocal(new Point(event.stageX, event.stageY));
			localPlayer.x = newPosition.x;
			localPlayer.y = newPosition.y;
			
			sendMessage( { message:"move", id:localPlayerId, position: { x:newPosition.x, y:newPosition.y }} );
			
			stage.focus = chatBox;
		} 
		
		/**
		 * Handles an enter keypress on the chatBox. Sends a chat message
		 * to server.
		 * 
		 * @param	event
		 */
		public function chatBoxKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ENTER) {
				sendMessage( { message:"say", id:localPlayerId, text:chatBox.text } );
				chatBox.text = "";
			}
		}
		
		/**
		 * Adds a player to the game.
		 * 
		 * @param	id The id of the player to add
		 */
		public function addPlayer(id:int, position:Object = null):Player {
			if (position == null) position = { x:0, y:0 };
			var newPlayer:Player = new Player(this, position);
			players[id] = newPlayer;
			addChild(newPlayer);
			return newPlayer;
		}
		
		/**
		 * Removes a player.
		 * 
		 * @param	id The id of the player to remove
		 */
		public function removePlayer(id:int):void {
			removeChild(players[id]);
			delete players[id];
		}
		
		/**
		 * Sends a JSON message on this game's associated socket if one is open.
		 * 
		 * @param	message The JSON message to send to the server.
		 */
		private function sendMessage(message:Object):void {
			if (this.socket) {
				socket.writeUTFBytes(JSON.encode(message));
				socket.flush();
			}
		}
		
		/**
		 * Properties
		 */
		public function get gameHandlers():Object {
			var game:Game = this; // handlers are called without a context, so we
								  // need to pass "this" through
			return {
				"open":function(request:Object, socket:Socket):void {
					game.socket = socket;
					sendMessage({ message:"hello" });
				},
				"new":function(request:Object, socket:Socket):void {
					addPlayer(request.id);
				},
				"join":function(request:Object, socket:Socket):void {
					localPlayer = addPlayer(request.id);
					localPlayerId = request.id;
					stage.addEventListener(MouseEvent.CLICK, mouseClick);
					for each(var player:Object in request.players) {
						players[player.id] = addPlayer(player.id, player.position);
					}
				},
				"say":function(request:Object, socket:Socket):void {
					players[request.id].say(request.text);
				},
				"move":function(request:Object, socket:Socket):void {
					var player:Player = players[request.id];
					var position:Object = request.position;
					player.x = position.x;
					player.y = position.y;
				},
				"leave":function(request:Object, socket:Socket):void {
					removePlayer(request.id);
				}
			}
		}
		
	}

}