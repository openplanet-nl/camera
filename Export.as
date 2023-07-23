namespace Camera
{
	// Projects a 3D point to screen space in 2D from the current camera, including "z" which can be
	// used to check if the point is behind the camera or not. This saves the overhead of having to
	// calculate the projection twice. Consider the point behind the camera if z > 0.
	import vec3 ToScreen(const vec3 &in pos) from "Camera";

	// Projects a 3D point to screen space in 2D from the current camera.
	import vec2 ToScreenSpace(const vec3 &in pos) from "Camera";

	// Returns true if the 3D point is behind the camera.
	import bool IsBehind(const vec3 &in pos) from "Camera";

	// Gets the current camera used for rendering.
	import CHmsCamera@ GetCurrent() from "Camera";

	// Gets the projection matrix of the current camera, if there is one.
	import mat4 GetProjectionMatrix() from "Camera";

	// Gets the current camera position.
	import vec3 GetCurrentPosition() from "Camera";

	// Gets the current camera looking direction.
	import vec3 GetCurrentLookingDirection() from "Camera";

	// In the editor, sets the currently focused camera position of the orbital camera.
	import void SetEditorOrbitalTarget(const vec3 &in pos) from "Camera";

	// Gets the currently active game camera.
	import ActiveCam GetCurrentGameCamera() from "Camera";
}
