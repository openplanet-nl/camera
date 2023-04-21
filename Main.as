CHmsCamera@ g_currentCamera = null;

mat4 g_projection = mat4::Identity();
mat4 g_rotation = mat4::Identity();
vec3 g_position = vec3();
vec3 g_direction = vec3();

vec2 g_displayPos;
vec2 g_displaySize;

void RenderEarly()
{
    // SetStatusRunning();
	UpdateActiveGameCam();
	// SetStatusDone();

	auto t = float(Time::Now % 1000) / 1000.0;
	// SetFreeCamPos(vec3(Math::Lerp(860.0, 880.0, t), Math::Lerp(16.0, 60.0, t), Math::Lerp(726.0, 780.0, t)));
	auto viewport = GetApp().Viewport;

	@g_currentCamera = null;
	for (int i = int(viewport.Cameras.Length) - 1; i >= 0; i--) {
		auto camera = viewport.Cameras[i];
#if TMNEXT
		if (camera.m_IsOverlay3d) {
			continue;
		}
#else
		if (camera.IsOverlay3d) {
			continue;
		}
#endif
		@g_currentCamera = camera;
		break;
	}

	if (g_currentCamera !is null) {
		iso4 camLoc = g_currentCamera.Location;
		mat4 camLocMat = mat4(camLoc);
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
		mat4 inverseTranslation = mat4::Inverse(translation);
		g_rotation = mat4::Inverse(inverseTranslation * camLocMat);

		g_projection = projection * mat4::Inverse(translation * g_rotation);
		g_position = vec3(camLoc.tx, camLoc.ty, camLoc.tz);

		vec2 topLeft = 1 - (g_currentCamera.DrawRectMax + 1) / 2;
		vec2 bottomRight = 1 - (g_currentCamera.DrawRectMin + 1) / 2;
		g_displaySize = vec2(Draw::GetWidth(), Draw::GetHeight());
		g_displayPos = topLeft * g_displaySize;
		g_displaySize *= bottomRight - topLeft;
		g_direction = vec3(camLoc.xz, camLoc.yz, camLoc.zz);
	}
}
