# Godot prototype
This is a prototype for a game in Godot.
It started as a sidescrolling platformer, but has transitioned into something like a cross between [Clank](https://www.direwolfdigital.com/clank/) and [Hades](https://www.supergiantgames.com/games/hades/).
I have been focusing on mechanics over visuals for now. The project is on hold while I focus on Junior Project.

There are playable builds for windows and linux in ./builds. The goal of the game is to follow the compass to the artifact and hold interact to collect it. Once you have the artifact you need to return to the entrance door.

## Menu system
In order to handle menus for the game I created a global menu manager at [menu_manager.gd](./scenes/UI/menu_manager.gd).
It uses a stack to keep track of the previous menus and allows for simple nested menus. Each menu can call one function to close itself and load the menu that called it.

## Finite state machine
[fsm.gd](./addons/gfsm/fsm.gd)
For the enemy AI, I primatily use finite state machines. I previously used an existing pugin that allowed for graphical editing, but due to some bugs and usability issues I decided to make my own.
My version addes state nodes to the tree under a parent FSM node. The FSM node will keep track of which child node is the current state and when it recivese a trigger it will check if the current state responds to the trigger, then emit an event for a transition if there is one.
The FSM can be configured to automatically update each physics frame, normal frame, or manually.

## Player controller
[player.gd](./scenes/player/player.gd)
The player controller is what I have spent the most time on. Making sure it feels good to play while still being maintainable. There are several nodes on the base player node that handle things like health, dealing damage, taking damage; enemies are similarly structured. With this approach I can easily configure new enemies or mechanics based on this, for example in the past enemies could be killed, now they cant I simply removed the node responsible for tracking health.
