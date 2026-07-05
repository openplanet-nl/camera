CHmsCamera@ g_currentCamera = null;
array<CHmsCamera@> g_currentCameras;

mat4 g_projection = mat4::Identity();
vec3 g_position = vec3();

vec2 g_displayPos;
vec2 g_displaySize;

array<CHmsCamera@> FindCameras()
{
	array<CHmsCamera@> cameras;
	auto viewport = GetApp().Viewport;
	for (int i = int(viewport.Cameras.Length) - 1; i >= 0; i--) {
		auto camera = viewport.Cameras[i];
#if TMNEXT
		if (camera.m_IsOverlay3d) {
			continue;
		}
#elif FOREVER
		if (camera.NearZ >= 100.0f /* Menu camera */ || !camera.UseViewDependantRendering) {
			continue;
		}
#else
		if (camera.IsOverlay3d) {
			continue;
		}
#endif
		cameras.InsertLast(camera);
	}
	
	return cameras;
}

void RenderEarly()
{
	g_currentCameras = FindCameras();
	if (g_currentCameras.Length == 0) {
		@g_currentCamera = null;
		return;
	}
	@g_currentCamera = g_currentCameras[0];

	iso4 camLoc = g_currentCamera.Location;
	float camFov = g_currentCamera.Fov;
	float camNearZ = g_currentCamera.NearZ;
	float camFarZ = g_currentCamera.FarZ;
#if TMNEXT
	float camAspect = g_currentCamera.Width_Height;
#else
	float camAspect = g_currentCamera.RatioXY;
#endif

	mat4 projection = mat4::Perspective(camFov, camAspect, camNearZ, camFarZ);
	mat4 translation = mat4::Translate(vec3(camLoc.tx, camLoc.ty, camLoc.tz));
	mat4 rotation = mat4::Inverse(mat4::Inverse(translation) * mat4(camLoc));

	g_projection = projection * mat4::Inverse(translation * rotation);
	g_position = vec3(camLoc.tx, camLoc.ty, camLoc.tz);

	vec2 topLeft = 1 - (g_currentCamera.DrawRectMax + 1) / 2;
	vec2 bottomRight = 1 - (g_currentCamera.DrawRectMin + 1) / 2;
	g_displaySize = Display::GetSize();
	g_displayPos = topLeft * g_displaySize;
	g_displaySize *= bottomRight - topLeft;
}
