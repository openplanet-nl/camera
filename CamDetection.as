/** Render function called every frame intended only for menu items in the main menu of the `UI`.
*/
void RenderMenuMain() {
	UI::BeginDisabled();
	UI::MenuItem("Current Cam: " + tostring(g_activeCam));
	UI::EndDisabled();
}

const string JsonStatusFile = IO::FromStorageFolder("status.json");

void SetStatusRunning() {
	auto j = Json::Object();
	j['running'] = true;
	j['timestamp'] = Time::Stamp;
	j['now'] = Time::Now;
	Json::ToFile(JsonStatusFile, j);
}

void SetStatusDone() {
	auto j = Json::Object();
	j['running'] = false;
	j['timestamp'] = Time::Stamp;
	j['now'] = Time::Now;
	Json::ToFile(JsonStatusFile, j);
}

ActiveCam g_activeCam = ActiveCam::Loading;

void UpdateActiveGameCam()
{
	g_activeCam = ActiveCam::None;

	const Reflection::MwClassInfo@ tmTy = Reflection::GetType("CTrackMania");
	const Reflection::MwMemberInfo@ gameSceneMember = tmTy.GetMember("GameScene");
	uint GameCameraNodOffset = gameSceneMember.Offset + 0x10;

	auto gameCameraNod = Dev::GetOffsetNod(GetApp(), GameCameraNodOffset);

	// This is null in the menu and when cameras aren't being used.
	if (gameCameraNod is null) {
		return;
	}

	auto camModelNod = Dev::GetOffsetNod(gameCameraNod, 0x58);
	auto camControlNod = Dev::GetOffsetNod(gameCameraNod, 0x68);

	// 0x2AC has a flag related to using internal cam (which is what the backwards cam is)
	bool isBackwards = Dev::GetOffsetUint32(gameCameraNod, 0xB0) == 0x4;

	if (isBackwards) {
		g_activeCam = ActiveCam::Backwards;
	} else if (camModelNod !is null) {
		auto ty = Reflection::TypeOf(camModelNod);
		switch (ty.ID) {
			// CPlugVehicleCameraRace2Model
			case 0x90f6000: {
				g_activeCam = TestCam1Alt(camModelNod) ? ActiveCam::Cam1Alt : ActiveCam::Cam1;
				break;
			}
			// CPlugVehicleCameraRace3Model
			case 0x90ef000: {
				g_activeCam = TestCam2Alt(camModelNod) ? ActiveCam::Cam2Alt : ActiveCam::Cam2;
				break;
			}
			// CPlugVehicleCameraInternalModel
			case 0x90f7000: {
				g_activeCam = TestCam3Alt(camModelNod) ? ActiveCam::Cam3Alt : ActiveCam::Cam3;
				break;
			}
			default: {
				trace('1 Got cam of unknown type: ' + ty.ID + ', ' + ty.Name);
				UI::ShowNotification('1 Got cam of unknown type: ' + ty.ID + ', ' + ty.Name);
				g_activeCam = ActiveCam::Other;
			};
		}
	} else if (camControlNod !is null) {
		auto ty = Reflection::TypeOf(camControlNod);
		switch (ty.ID) {
			// CGameControlCameraFree
			case 0x306d000: {
				g_activeCam = ActiveCam::FreeCam;
				break;
			}
			// CGameControlCameraEditorOrbital
			case 0x3125000: {
				g_activeCam = ActiveCam::EditorOrbital;
				break;
			}
			// CGameControlCameraOrbital3d
			case 0x306e000: {
				g_activeCam = ActiveCam::Orbital3d;
				break;
			}
			// CGameControlCameraHelico
			case 0x32f0000: {
				g_activeCam = ActiveCam::Helico;
				break;
			}
			// CGameControlCameraHmdExternal
			case 0x3277000: {
				g_activeCam = ActiveCam::HmdExternal;
				break;
			}
			// CGameControlCameraThirdPerson
			case 0x3042000: {
				g_activeCam = ActiveCam::ThirdPerson;
				break;
			}
			// CGameControlCameraFirstPerson
			case 0x3041000: {
				g_activeCam = ActiveCam::FirstPerson;
				break;
			}
			// CGameControlCameraTarget
			case 0x3072000: {
				g_activeCam = ActiveCam::Target;
				break;
			}
			// CGameControlCameraTrackManiaRace
			case 0x313d000: {
				g_activeCam = ActiveCam::Cam0;
				break;
			}
			// CGameControlCamera
			case 0x306b000: {
				// We probably won't ever end up here, but just in case.
				g_activeCam = ActiveCam::Other;
				break;
			}
			// CGameControlCameraTrackManiaRace2
			// 0x31cf000
			// CGameControlCameraTrackManiaRace3
			// 0x31ce000
			// CGameControlCameraVehicleInternal
			// 0x3189000
			default: {
				trace('2 Got cam of unknown type: ' + ty.ID + ', ' + ty.Name);
				UI::ShowNotification('2 Got cam of unknown type: ' + ty.ID + ', ' + ty.Name);
				g_activeCam = ActiveCam::Other;
			};
		}
	} else {
		// initalizing editor, when in mediatracker
		g_activeCam = ActiveCam::Loading;
	}
}

bool TestCam1Alt(CMwNod@ camNod)
{
	// alt 00 00 40 40, main: 00 00 a0 40 -- constant after restart
	return Dev::GetOffsetUint32(camNod, 0x38) == 0x40400000;
}

bool TestCam2Alt(CMwNod@ camNod)
{
	// alt: 00 00 8C 42, main: 00 00 96 42 -- constant after game restart
	return Dev::GetOffsetUint32(camNod, 0x38) == 0x428c0000;
}

bool TestCam3Alt(CMwNod@ camNod)
{
	// std: 0, alt: 1
	return Dev::GetOffsetUint32(camNod, 0x34) == 1;
}
