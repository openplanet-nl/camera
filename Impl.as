namespace Camera
{
	vec3 ToScreen(const vec3 &in pos)
	{
		if (g_currentCamera is null) {
			return vec3(0, 0, 1);
		}
		auto ret = g_projection * pos;
		if (ret.w == 0.0f) {
			return vec3(0, 0, ret.w);
		}
		vec2 screenPos = g_displayPos + (ret.xy / ret.w + 1) / 2 * g_displaySize;
		return vec3(screenPos, ret.w);
	}

	vec2 ToScreenSpace(const vec3 &in pos)
	{
		return ToScreen(pos).xy;
	}

	bool IsBehind(const vec3 &in pos)
	{
		if (g_currentCamera is null) {
			return true;
		}
		return (g_projection * pos).w > 0;
	}

	CHmsCamera@ GetCurrent()
	{
		return g_currentCamera;
	}

	CHmsCamera@ FindCurrent()
	{
		return FindCurrentCamera();
	}

	mat4 GetProjectionMatrix()
	{
		return g_projection;
	}

	vec3 GetCurrentPosition()
	{
		return g_position;
	}

	void SetEditorOrbitalTarget(const vec3 &in pos)
	{
#if FOREVER
		throw("SetEditorOrbitalTarget is currently not supported on TrackMania Forever");
#else
		auto editor = cast<CGameCtnEditorCommon>(GetApp().Editor);
		if (editor is null) {
			throw("Not in editor");
			return;
		}

		auto orbital = editor.OrbitalCameraControl;
		if (orbital is null) {
			throw("No orbital camera");
			return;
		}

#if TURBO
		float h = (orbital.CurrentHAngle + Math::PI / 2) * -1;
		float v = orbital.CurrentVAngle;

		vec4 axis(1, 0, 0, 0);
		axis = axis * mat4::Rotate(v, vec3(0, 0, -1));
		axis = axis * mat4::Rotate(h, vec3(0, 1, 0));

		orbital.TargetedPosition = pos;

		vec3 newCameraPos = pos + axis.xyz * orbital.CameraToTargetDistance;

#else
		float h = (orbital.m_CurrentHAngle + Math::PI / 2) * -1;
		float v = orbital.m_CurrentVAngle;

		vec4 axis(1, 0, 0, 0);
		axis = axis * mat4::Rotate(v, vec3(0, 0, -1));
		axis = axis * mat4::Rotate(h, vec3(0, 1, 0));

		orbital.m_TargetedPosition = pos;

		vec3 newCameraPos = pos + axis.xyz * orbital.m_CameraToTargetDistance;
#endif

#if TMNEXT
		orbital.Pos = newCameraPos;
#else
		//TODO: This is correct for Maniaplanet, but probably not for Turbo
		Dev::SetOffset(orbital, 0x44, newCameraPos);
#endif
#endif
	}
}
