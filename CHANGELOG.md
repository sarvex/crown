Changelog
=========

0.37.0
------
*DD MMM YYYY*

* lua: added RenderWorld.mesh_set_material()
* tools: fixed a crash when entering empty commands in the console
* tools: fixed an issue that prevented some operations in the Level Editor from being (un/re)done
* tools: fixed an issue that prevented the data compiler from restoring and saving its state when launched by the Level Editor
* tools: the game will now be started or stopped accordingly to its running state when launched from the Level Editor
* tools: the Properties Panel now accepts more sensible numeric ranges
* world: sprite's frame number now wraps if it is greater than the total number of frames in the sprite