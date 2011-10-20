flashnodejs
===========
This is a simple demo of a Flash client connecting to a node.js server. Players automatically join the locally running server instance and can move and chat.

The project is separated into folders for the client and the server. The client folder contains a FlashDevelop project which can be used for building, or it can be built by hand. The server folder contains all files needed to run the server - just run 'node index.js'.

The client and server attempt to be symmetrical. A core network class (Client.as and server.js) receives and parses JSON messages into associative arrays. These are passed to a delegation class (Delegator.as and delegator.js) that has been provided with mappings between message names and functions. In this instance, these functions are found on the Game classes (Game.as and game.js), which tracks the current game state along with classes representing Players (Player.as and player.js).

This project depends upon as3corelib. The license can be found alongside the library in the lib folder.

Protocol
========

This demo of Flash and node.js socket communication requires several message types to be passed between the client and the server and vice-versa. All messages are encoded in json and include a "message" field. Other fields depend upon the message being sent, and are listed as arguments here.

Server Outgoing
---------------
Say
A chat message relayed to each player of the game.
message: 	say
arguments: 	id The id of the player who sent the chat message.
			text The text of the chat message

Move
A player position update relayed to each other player of the game.
message:	move
arguments:	id The id of the player who is moving.
			position An object of the form {x:, y:} describing the
				player's new position

Join
All information a player needs to join the game. Sent to 
a new player in response to a hello message.
message:	join
arguments:	id The id being assigned to the joining player.
			players A list of objects with the form {id:, position:{x:,y:}}
				for each player in the game.

New
A notification for all other players of a new player. Sent to
all other players in response to a hello message.
message:	new
arguments:	id The id of the new player.

Leave
A notification for all other players that another has left.
message:	leave
arguments:	id The id of the ditching player.

Client Outgoing
---------------
Hello
Upon joining, the client sends a hello message, and expects
a join message in return.
message:	hello
no arguments

Say
A chat message from the client player.
message:	say
arguments:	id The id of this player.
			text The text of the chat message.

Move
Informing the server of a client player's new location.
message:	move
arguments:	id The id of this player.
			position The new position of this player in the
				form {x:, y:}


