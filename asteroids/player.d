module asteroids.player;

import godot;
import godot.object;
import godot.area;
import godot.camera;
import godot.input;
import godot.inputevent.all;

class Player : GodotScript!Area
{
	alias owner this;
	
	enum float speed = 25; /// units per second
	
	bool fly = false; /// should fly forward in the next frame
	
	@Method _ready()
	{
		
	}
	
	void faceScreenPosition(Vector2 p)
	{
		Camera camera = getTree.root.getCamera;
		Vector3 rayOrigin = camera.projectRayOrigin(p);
		Vector3 rayNormal = camera.projectRayNormal(p);
		
		Plane plane = Plane(Vector3(0f, 1f, 0f), 0f);
		Vector3 intersect;
		if(plane.intersectsRay(rayOrigin, rayNormal, &intersect))
		{
			lookAt(intersect, Vector3(0f, 1f, 0f));
		}
	}
	
	@Method _unhandledInput(scope InputEvent e)
	{
		// handle facing from mouse movement or screen drag
		if(auto mm = e.as!InputEventMouseMotion)
		{
			faceScreenPosition(mm.position);
		}
		else if(auto sd = e.as!InputEventScreenDrag)
		{
			faceScreenPosition(sd.position);
		}
		
		// handle movement from mouse click or screen touch
		else if(auto mb = e.as!InputEventMouseButton)
		{
			fly = mb.pressed;
		}
		else if(auto st = e.as!InputEventScreenTouch)
		{
			fly = st.pressed;
		}
		
		// handle the rebindable fly mapping (keyboard, etc)
		else if(e.isActionPressed(gs!"fly")) fly = true;
		else if(e.isActionReleased(gs!"fly")) fly = false;
	}
	
	@Method _process(float delta)
	{
		if(fly)
		{
			translateObjectLocal(Vector3(0f, 0f, -delta * speed));
			if(translation.length > 50f) translation = 50f * translation.normalized;
		}
	}
	
	@Method hit(GodotObject o)
	{
		import godot.control;
		setProcess(false);
		hide();
		getNode("GameOver").as!Control.show();
	}
}

