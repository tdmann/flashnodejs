package mn.whaba.flashnodejs 
{
	
	import com.adobe.serialization.json.JSONParseError;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import com.adobe.serialization.json.JSON;
	import flash.system.Security;
	
	/**
	 * Connects to a running node.js server. Can send and receive messages.
	 * Delegates received messages to the current game object to handle.
	 * 
	 * @author Tim Mann
	 */
	public class Client 
	{
		
		private var socket:Socket;
		private var delegator:Delegator;
		private var lastData:String;
		
		/**
		 * Constructs a Client object which will delegate received messages 
		 * through the provided game.
		 * 
		 * @param	delegator A delegator which maps message names to functions.
		 */
		public function Client(delegator:Delegator) 
		{
			this.delegator = delegator;
			lastData = "";
			
			// open the connection
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, open);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, handleData);
			socket.addEventListener(Event.CLOSE, close);
			
		}
		
		/**
		 * Connects the socket.
		 */
		public function connect():void {
			// load the policy file so we can actually connect to our game
			Security.loadPolicyFile("xmlsocket://localhost:8112");
			
			socket.connect('localhost', 8111);
		}
		
		/**
		 * Executed upon receiving data.
		 * Reads the data which exists in the socket, and extracts any possible
		 * JSON objects from it.
		 * Any leftover data is stored until later.
		 * 
		 * @param	event
		 */
		private function handleData(event:ProgressEvent):void {
			
			// handle every JSON object we can pull out of the socket
			// we prepend any data that didn't get used last time we received
			// objects
			var read:String = lastData + socket.readUTFBytes(socket.bytesAvailable);
			
			var messages:Array = getJSONObjects(read);
			
			// store the remaining bytes to process later
			lastData = messages.pop();
			
			trace(lastData);
			
			for each (var message:Object in messages) {
				trace("handling a message");
				delegator.handle(message, socket);
			}
		}
		
		/**
		 * An event executed when the client has connected to the server.
		 * 
		 * @param	event
		 */
		private function open(event:Event):void {
			delegator.handle({ message:"open" }, socket);
		}
		
		/**
		 * Executed when the socket is closed by the server.
		 * @param	event
		 */
		private function close(event:Event):void {
			delegator.handle({ message:'close' }, socket);
		}
		
		/**
		 * Returns an array of JSON objects that exist in the passed string - if the
		 * string ends with an incomplete JSON object, the remaining data
		 * is returned as the last item on the array.
		 * 
		 * @param	data The string to parse for JSON objects
		 * @return	An array of the JSON objects contained in data.
		 */
		private function getJSONObjects(data:String):Array {
			var jsonObjects:Array = new Array();
			var tokenIndex:int, tokens:Array = new Array(), inString:Boolean;
			var currentJSONString:String = "";
			var matches:Object = { 
				'\{':'\}', 
				'\}':'\{',
				'\'':'\'',
				'"':'"'
			};
			var tokenExp:RegExp = /[\{\}\'"]/;
			
			// step through the string to select complete
			// json objects.
			do {
				
				// find the next important character
				tokenIndex = data.search(tokenExp);
				if (tokenIndex == -1) {
					
					// did not find one - push the current data onto
					// the return array
					currentJSONString = currentJSONString + data;
					jsonObjects.push(currentJSONString);
					break;
				}
				else {
					
					// found one
					var top:String = '';
					var token:String = data.charAt(tokenIndex);
					
					// get the last read token,
					// if it matches the current one,
					// pop it off
					if (tokens.length != 0) {
						top = tokens[tokens.length - 1];
					}
					if (top == matches[token]) {
						tokens.pop();
					}
					else if (top != matches[token] && top != '\'' && top != '"') {
						
						// otherwise,
						// add it to the token stack if the top isn't
						// currently a quotation
						tokens.push(token);
					}
					
					// add the read data to the current JSON string,
					// remove it from the remaining data
					currentJSONString = currentJSONString + data.substring(0, tokenIndex + 1);
					data = data.substring(tokenIndex + 1);
					
					// if we've completed an object, push it
					if (tokens.length == 0) {
						var object:Object;
						try {
							object = JSON.decode(currentJSONString)
							jsonObjects.push(object);
						}
						catch (error:JSONParseError) {
							trace("Could not parse JSON from: " + currentJSONString);
						}
						finally {
							currentJSONString = "";
						}
					}
				}
			} while (1);
			
			return jsonObjects;
		}
		
	}

}