#if TMNEXT

void RenderMenuMain()
{
	if (!Setting_DebugShowActiveCamInMenu) {
		return;
	}
	UI::BeginDisabled();
	UI::MenuItem("Active Cam: " + tostring(g_activeCam));
	UI::EndDisabled();
}

const Reflection::MwClassInfo@ tmTy = Reflection::GetType("CTrackMania");
const Reflection::MwMemberInfo@ gameSceneMember = tmTy.GetMember("GameScene");
const uint GameCameraNodOffset = gameSceneMember.Offset + 0x10;

void UpdateActiveGameCam()
{
	g_activeCam = ActiveCam::None;

	auto gameCameraNod = Dev::GetOffsetNod(GetApp(), GameCameraNodOffset);

	// This is null in the menu and when cameras aren't being used.
	if (gameCameraNod is null) {
		return;
	}

	auto camModelNod = Dev::GetOffsetNod(gameCameraNod, 0x58);
	auto camControlNod = Dev::GetOffsetNod(gameCameraNod, 0x68);
	// 0x1 for std, 0x2 for alt.
	bool cam1Alt = Dev::GetOffsetUint8(gameCameraNod, 0x24) == 0x2;
	bool cam2Alt = Dev::GetOffsetUint8(gameCameraNod, 0x25) == 0x2;
	bool cam3Alt = Dev::GetOffsetUint8(gameCameraNod, 0x26) == 0x2;

	// Always 4 when backwards, and seemingly always 0 otherwise
	bool isBackwards = Dev::GetOffsetUint32(gameCameraNod, 0xB0) == 0x4;

	if (isBackwards) {
		g_activeCam = ActiveCam::Backwards;
	} else if (camModelNod !is null) {
		auto ty = Reflection::TypeOf(camModelNod);
		if (ty.ID == ClsId_CPlugVehicleCameraRace2Model) {
			g_activeCam = cam1Alt ? ActiveCam::Cam1Alt : ActiveCam::Cam1;
		} else if (ty.ID == ClsId_CPlugVehicleCameraRace3Model) {
			g_activeCam = cam2Alt ? ActiveCam::Cam2Alt : ActiveCam::Cam2;
		} else if (ty.ID == ClsId_CPlugVehicleCameraInternalModel) {
			g_activeCam = cam3Alt ? ActiveCam::Cam3Alt : ActiveCam::Cam3;
		} else if (ty.ID == ClsId_CPlugVehicleCameraHelicoModel) {
			// this happens with CharacterPilot maps
			g_activeCam = ActiveCam::Helico;
		} else {
			trace('1 Got cam of unknown type: ' + ty.ID + ', ' + ty.Name);
			UI::ShowNotification('1 Got cam of unknown type: ' + ty.ID + ', ' + ty.Name);
			g_activeCam = ActiveCam::Other;
		}
	} else if (camControlNod !is null) {
		auto ty = Reflection::TypeOf(camControlNod);
		if (ty.ID == ClsId_CGameControlCameraFree) {
			g_activeCam = ActiveCam::FreeCam;
		} else if (ty.ID == ClsId_CGameControlCameraEditorOrbital) {
			g_activeCam = ActiveCam::EditorOrbital;
		} else if (ty.ID == ClsId_CGameControlCameraOrbital3d) {
			g_activeCam = ActiveCam::Orbital3d;
		} else if (ty.ID == ClsId_CGameControlCameraHelico) {
			g_activeCam = ActiveCam::Helico;
		} else if (ty.ID == ClsId_CGameControlCameraHmdExternal) {
			g_activeCam = ActiveCam::HmdExternal;
		} else if (ty.ID == ClsId_CGameControlCameraThirdPerson) {
			g_activeCam = ActiveCam::ThirdPerson;
		} else if (ty.ID == ClsId_CGameControlCameraFirstPerson) {
			g_activeCam = ActiveCam::FirstPerson;
		} else if (ty.ID == ClsId_CGameControlCameraTarget) {
			g_activeCam = ActiveCam::Target;
		} else if (ty.ID == ClsId_CGameControlCameraTrackManiaRace) {
			g_activeCam = ActiveCam::Cam0;
		} else if (ty.ID == ClsId_CGameControlCameraTrackManiaRace2) {
			g_activeCam = ActiveCam::Cam1;
		} else if (ty.ID == ClsId_CGameControlCameraTrackManiaRace3) {
			g_activeCam = ActiveCam::Cam2;
		} else if (ty.ID == ClsId_CGameControlCameraVehicleInternal) {
			g_activeCam = ActiveCam::Cam3;
		} else if (ty.ID == ClsId_CGameControlCamera) {
			// We probably won't ever end up here, but just in case.
			g_activeCam = ActiveCam::Other;
		} else {
			trace('2 Got cam of unknown type: ' + ty.ID + ', ' + ty.Name);
			UI::ShowNotification('2 Got cam of unknown type: ' + ty.ID + ', ' + ty.Name);
			g_activeCam = ActiveCam::Other;
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

const uint ClsId_CPlugVehicleCameraRace2Model = Reflection::GetType("CPlugVehicleCameraRace2Model").ID;
const uint ClsId_CPlugVehicleCameraRace3Model = Reflection::GetType("CPlugVehicleCameraRace3Model").ID;
const uint ClsId_CPlugVehicleCameraInternalModel = Reflection::GetType("CPlugVehicleCameraInternalModel").ID;
const uint ClsId_CPlugVehicleCameraHelicoModel = Reflection::GetType("CPlugVehicleCameraHelicoModel").ID;

const uint ClsId_CGameControlCameraFree = Reflection::GetType("CGameControlCameraFree").ID;
const uint ClsId_CGameControlCameraEditorOrbital = Reflection::GetType("CGameControlCameraEditorOrbital").ID;
const uint ClsId_CGameControlCameraOrbital3d = Reflection::GetType("CGameControlCameraOrbital3d").ID;
const uint ClsId_CGameControlCameraHelico = Reflection::GetType("CGameControlCameraHelico").ID;
const uint ClsId_CGameControlCameraHmdExternal = Reflection::GetType("CGameControlCameraHmdExternal").ID;
const uint ClsId_CGameControlCameraThirdPerson = Reflection::GetType("CGameControlCameraThirdPerson").ID;
const uint ClsId_CGameControlCameraFirstPerson = Reflection::GetType("CGameControlCameraFirstPerson").ID;
const uint ClsId_CGameControlCameraTarget = Reflection::GetType("CGameControlCameraTarget").ID;
const uint ClsId_CGameControlCameraTrackManiaRace = Reflection::GetType("CGameControlCameraTrackManiaRace").ID;
const uint ClsId_CGameControlCamera = Reflection::GetType("CGameControlCamera").ID;
const uint ClsId_CGameControlCameraTrackManiaRace2 = Reflection::GetType("CGameControlCameraTrackManiaRace2").ID;
const uint ClsId_CGameControlCameraTrackManiaRace3 = Reflection::GetType("CGameControlCameraTrackManiaRace3").ID;
const uint ClsId_CGameControlCameraVehicleInternal = Reflection::GetType("CGameControlCameraVehicleInternal").ID;

#else

void UpdateActiveGameCam()
{
	// not supported in MP4 / Turbo
}

#endif
