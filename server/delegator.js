/**
 * delegator.js
 * Exposes a Delegator class which passes requests to the specified handlers.
 *
 * @author Tim Mann
 */

/**
 * Delegates messages to the provided functions.
 *
 * @param	[handlers] An associative array matching message names 
 * 		to a specific function to handle that message
 */
var Delegator = function(handlers) {
	
	if (!handlers)
		handlers = {};
	
	/**
	 * Calls the function mapped to the passed request's
	 * 'message' property.
	 *
	 * @param	request The request to handle
	 * @param	socket The socket which it lives on
	 */
	this.handle = function(request, socket) {
		if (typeof(handlers[request.message]) == 'function') {
			handlers[request.message].call(null, request, socket);
		}
	}
	
	/**
	 * Adds and overwrites handlers with the ones provided.
	 *
	 * @param	updateHandlers The handlers to merge with this delegator's
	 * 		current handlers.
	 */
	this.update = function(updateHandlers) {
		for (handler in updateHandlers) {
			handlers[handler] = updateHandlers[handler];
		}
	}
}

/**
 * Exports
 */
exports.Delegator = Delegator;

/**
 * A wrapper for new Delegator.
 *
 * @param	handlers The handlers to build the delegator with.
 */
exports.createDelegator = function(handlers) {
	return new Delegator(handlers);
}