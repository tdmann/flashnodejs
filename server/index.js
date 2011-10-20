/**
 * index.js
 * A simple game server which will track player positions and allow them to chat.
 *
 * @author Tim Mann
 */
var net = require('net');
var server = require('./server');
var policy = require('./policy');
var delegator = require('./delegator');
var game = require('./game');

var currentGame = game.createGame();

// start the server
server.start(8111, delegator.createDelegator(currentGame.gameHandlers));

policy.start(8112, 8111);