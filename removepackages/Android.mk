LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := removepackages
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional

LOCAL_OVERRIDES_PACKAGES := \
    AdaptiveVPNPrebuilt \
    AiWallpapers \
    AmbientStreaming \
    arcore \
    BetterBugStub \
    CarrierLocation \
    CarrierMetrics \
    CarrierWifi \
    CbrsNetworkMonitor \
    ConfigUpdater \
    ConnMO \
    DCMO \
    DMService \
    GoogleFeedback \
    grilservice \
    HealthIntelligenceStubPrebuilt \
    KidsSupervisionStub \
    LocationHistoryPrebuilt \
    MaestroPrebuilt \
    MusicFX \
    MyVerizonServices \
    OemDmTrigger \
    Panic \
    PixelSupportPrebuilt \
    QuickAccessWallet \
    SafetyHubPrebuilt \
    SafetyRegulatoryInfo \
    ScribePrebuilt \
    Showcase \
    SoundAmplifierPrebuilt \
    Stk \
    SwitchAccessPrebuilt \
    TurboAdapter \
    TurboPrebuilt \
    Tycho \
    VZWAPNLib \
    WfcActivation \

LOCAL_UNINSTALLABLE_MODULE := true
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_SRC_FILES := /dev/null
include $(BUILD_PREBUILT)
