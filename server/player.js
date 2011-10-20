/**
 * player.js
 * Exposes a class to track players.
 *
 * @author Tim Mann
 */

/**
 * Tracks a player's state and exposes some methods for updating clients.
 *
 * @param	game The game which is tracking this player.
 * @param	socket The socket for the client which has connected.
 * @param	id The id to assign this player.
 */
var Player = function(game, socket, id) {
	var position = {x:0, y:0};
	
	/**
	 * Properties
	 */
	this.__defineGetter__('socket', function() {
		return socket;
	});

	this.__defineGetter__('position', function() {
		return position;
	});

	this.__defineSetter__('position', function(value) {
		position = value;
		this.sendPosition();
	});

	this.__defineGetter__('id', function() {
		return id;
	});
	
	/**
	 * Privileged Methods
	 */
	 
	/**
	 * Sends a speech message to all clients - this player has spoken!
	 *
	 * @param	text The text to say
	 */
	this.say = function(text) {
		game.broadcast({ message: "say", id: id, text: text })
	}

	/**
	 * Sends a position update for this player to all clients.
	 */
	this.sendPosition = function() {
		game.broadcast({ message: "move", id: id, position: position })
	}

	/**
	 * Informs all clients that another player has connected.
	 */
	this.connect = function() {
		game.broadcast({ message: "connect", id: id });
	}

	/**
	 * Sends a JSON message on this player's socket.
	 *
	 * @param	message The JSON message to send.
	 */
	this.sendMessage = function(message) {
		
		var jsoned = JSON.stringify(message);
		socket.write(jsoned + '\0');
	}
	
}

/**
 * Exports
 */
exports.Player = Player;

/**
 * A wrapper for new Player.
 *
 * @param game The game which this player should be created under.
 * @param socket The socket which tracks this player.
 * @param id The id given for this player.
 */
exports.createPlayer = function(game, socket, id) {
	return new Player(game, socket, id);
}