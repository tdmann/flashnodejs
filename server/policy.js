/**
 * policy.js
 * A basic policy file server for flash socket connections, for development and non-production use.
 * 
 * @author	Tim Mann
 */

 var net = require('net');
 
/**
 * Starts the policy server on the specified listen port, allowing flash connections to the specified allow port.
 *
 * @param	listenPort The port for this server to listen on.
 * @param	allowPort The port to open for flash socket connections.
 */
var start = function(listenPort, allowPort) {
	var policy_server = net.createServer(function(socket) {
		policy = '<?xml version="1.0"?><!DOCTYPE cross-domain-policy SYSTEM "/xml/dtds/cross-domain-policy.dtd"><cross-domain-policy><allow-access-from domain="*" to-ports="'+ allowPort +'" /></cross-domain-policy>';
		
		// send policy immediately upon connection
		socket.write(policy + '\0');
	
		// on data events, pass messages through the delegate
		socket.on('data', function(data) {
			console.log('policy-server: ' + socket.remoteAddress + ' sent ' + data);
			
			// handle the policy file request to allow
			// Flash to connect
			if (data == '<policy-file-request/>\0') {
				socket.write(policy);
				console.log('policy-server: sent policy to ' + socket.remoteAddress);
			}
		});
	});
	
	policy_server.listen(listenPort, function() {
		console.log('policy server listening');
	});
};

/**
 * Exports
 */
exports.start = start;