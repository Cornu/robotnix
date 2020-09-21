{ config, pkgs, apks, lib, robotnixlib, ... }:

with lib;
let
  cfg = config.apps.fdroid;
  services = pkgs.fetchFromGitLab {
    owner = "AuroraOSS";
    repo = "AuroraServices";
    rev = "1.0.6";
    sha256 = "163in1aas0cakpmsgw2kwifn7p0pmx99yxlfgfzrj7br2mvblff7";
  };
  androidmk = pkgs.writeText "Android.mk" (''
    LOCAL_PATH := $(call my-dir)

    include $(CLEAR_VARS)
    LOCAL_MODULE := permissions_com.aurora.services.xml
    LOCAL_MODULE_CLASS := ETC
    LOCAL_MODULE_TAGS := optional
    LOCAL_MODULE_PATH := $(TARGET_OUT_ETC)/permissions
    LOCAL_SRC_FILES := assets/$(LOCAL_MODULE)
    include $(BUILD_PREBUILT)

    include $(CLEAR_VARS)
    LOCAL_PACKAGE_NAME := AuroraServices
    LOCAL_MODULE_TAGS := optional
    LOCAL_PRIVILEGED_MODULE := true
    LOCAL_SDK_VERSION := current
    LOCAL_SRC_FILES := $(call all-java-files-under, java) \
                       $(call all-Iaidl-files-under, aidl)
    LOCAL_AIDL_INCLUDES := $(LOCAL_PATH)/aidl
    LOCAL_REQUIRED_MODULES := permissions_com.aurora.services.xml
    include $(BUILD_PACKAGE)
  '');
in
{
  options.apps.aurora-store = {
    enable = mkEnableOption "Aurora Store";
  };

  config = mkIf cfg.enable {
    apps.prebuilt."AuroraStore".apk = apks.aurora-store;

    # TODO: Put this under product/
    source.dirs."robotnix/apps/AuroraServices" = {
      src = services;
      patches = [
        (pkgs.substituteAll {
          src = ./aurora-services.patch;
          fingerprint = toLower (config.build.fingerprints "releasekey");
        })
      ];
      postPatch	= ''
        cp ${androidmk} $out/app/src/main/
      '';
    };

    system.additionalProductPackages = [ "AuroraServices" ];
  };
}
