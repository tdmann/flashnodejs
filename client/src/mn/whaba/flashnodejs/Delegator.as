package mn.whaba.flashnodejs 
{
	import com.adobe.serialization.json.JSON;
	import flash.net.Socket;
	
	/**
	 * Delegates requests to the named handlers,
	 * 
	 * @author Tim Mann
	 */
	public class Delegator 
	{
		
		private var handlers:Object;
		
		/**
		 * Builds a delegator from the provided handlers.
		 * 
		 * @param	handlers An associative array mapping message names
		 *                   to the function to handle that message
		 */
		public function Delegator(handlers:Object) 
		{
			this.handlers = handlers;
		}
		
		/**
		 * Handles a request.
		 * 
		 * @param	request The request to be handled. 
		 * @param	socket The socket which the request came on.
		 */
		public function handle(request:Object, socket:Socket):void
		{
			if (typeof(handlers[request.message]) == 'function') {
				try {
					handlers[request.message](request, socket);
				}
				catch(err:ArgumentError) {
					trace("Argument error on " + request.message + ".");
					trace(request);
				}
			}
		}
		
	}

}