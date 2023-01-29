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
		return vec3(
			(ret.x / ret.w + 1.0f) / 2.0f * g_width,
			(ret.y / ret.w + 1.0f) / 2.0f * g_height,
			ret.w
		);
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

		float h = (orbital.m_CurrentHAngle + Math::PI / 2) * -1;
		float v = orbital.m_CurrentVAngle;

		vec4 axis(1, 0, 0, 0);
		axis = axis * mat4::Rotate(v, vec3(0, 0, -1));
		axis = axis * mat4::Rotate(h, vec3(0, 1, 0));

		orbital.m_TargetedPosition = pos;
		orbital.Pos = pos + axis.xyz * orbital.m_CameraToTargetDistance;
	}
}
