/**
 * game.js
 * Exposes a Game class to track the game state.
 *
 * @author Tim Mann
 */
 
var player = require('./player');

/**
 * Tracks game state and connected players.
 */
var Game = function() {
	var players = {};
	var id = 0;

	/**
	 * Privileged Methods
	 */
	
	/**
	 * Creates a new player - used when a player connects. 
	 * Informs the connecting player of his new id, and the ids and
	 * positions of other players, and informs the other players of
	 * the new player and his id.
	 *
	 * @param	socket The socket which this player connected on.
	 */
	this.addPlayer = function(socket) {
		
		// build a list of data for the current players
		var otherPlayers = {};
		for (var k in this.players) {
			otherPlayers[k] = { "position":{x: this.players[k].position.x, y: this.players[k].position.y} };
		}
		
		// tell all the current players about the arriving player
		this.broadcast({ message:"new", id:id });
		
		// build the arriving player
		var newPlayer = player.createPlayer(this, socket, id);
		
		// tell him about everyone else
		newPlayer.sendMessage({ message:"join", id:id, players:otherPlayers });
		
		players[id] = newPlayer;
		id++;
	}

	/**
	 * Sends a JSON message to all players on the server.
	 *
	 * @param	message The JSON message to send to all players. 
	 */
	this.broadcast = function(message) {
		for (var p in players) {
			players[p].sendMessage(message);
		}
	}

	/**
	 * Removes a player from the game - used when a player disconnects.
	 * 
	 * @param	id The id of the player who has disconnected.
	 */
	this.removePlayer = function(id) {
		delete players[id];
		this.broadcast({ message: "leave", id: id });
	}

	/**
	 * Finds the player which is connected on the provided socket.
	 *
	 * @param	socket The socket to find the player for
	 * @return	The player connected to the provided socket
	 */
	this.findPlayerBySocket = function(socket) {
		for(p in players) {
			if (players[p].socket == socket) {
				return players[p];
			}
		}
		return null;
	}
	
	/**
	 * Properties
	 */
	this.__defineGetter__('players', function() {
		return players; 
	});
	
	this.__defineGetter__('gameHandlers', function() {
		var game = this; // handlers are called without context, so we need
					 // to manually pass "this" through
		return {
			hello: function(request, socket) {
				game.addPlayer(socket);
			},
			move: function(request, socket) {
				game.players[request.id].position = { x: request.position.x, y: request.position.y };
			},
			say: function(request, socket) {
				game.players[request.id].say(request.text);
			},
			close: function(request, socket) {
				var player = game.findPlayerBySocket(socket);
				if (player) {
					game.removePlayer(player.id);
				}
			}
		};
	});
}

/**
 * Exports
 */
exports.Game = Game;

/**
 * A wrapper for new Game.
 */
exports.createGame = function() {
	return new Game();
}