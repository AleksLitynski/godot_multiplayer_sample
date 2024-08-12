
# Multiplayer Sample


Sample project showing how to create a multiplayer game in godot.

## Running the Sample

Run a headless server via:
	
```
cd multiplayer_demo/
Godot_v4.3-rc2_win64_console.exe main.tscn --headless ++ --server
```

In the editor, launch several clients via:
	
```
1. Debug -> Customize Run Instances... -> (set count to 2 or more)
2. Run main.tscn
```

When the clients start, press "Connect" in each to join your local server.

When a client connects, it will have no avatar, but can see the state of the game.

Any client can press "Request New Round" at any time to restart the round with a new avatar for each player.

The only actions players can take is moving via WASD.
