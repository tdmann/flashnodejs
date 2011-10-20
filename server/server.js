/**
 * server.js
 * Exposes a method to start two servers for Flash applications -
 * one, the game server proper, and two, a basic policy files
 * server for development.
 *
 * @author Tim Mann
 */

var net = require('net');
var delegator = require('./delegator');

/**
 * Starts a flash server listening on the provided port
 * which will handle messages using the provided delegator
 *
 * @param port - the port to set the server listening on
 * @param delegator - the delegator to pass events through
 */
var start = function(port, delegator) {

	var server = net.createServer(function(socket) {
		
		// on data events, pass messages through the delegate
		socket.on('data', function(data) {
			console.log('server: ' + socket.remoteAddress + ' sent ' + data);
			try {
				request = JSON.parse(data);
				delegator.handle(request, socket);
			}
			catch (e) {
				console.log("server: could not parse data - " + data);
			}
		});
		
		// allow the delegate to handle connection and disconnection events
		socket.on('connect', function() {
			console.log('server: connection received from ' + socket.remoteAddress);
			delegator.handle({ message:'open' }, socket);
		});
		socket.on('end', function() {
			console.log('server: connection from ' + socket.remoteAddress + ' closed');
			delegator.handle({ message:'close' }, socket);
		});
		
	});

	server.listen(port, function() {
		console.log('server listening');
	});
	
}

/**
 * Exports
 */
exports.start = start;