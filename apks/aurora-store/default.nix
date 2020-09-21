{ callPackage, substituteAll, fetchFromGitLab, androidPkgs, jdk, gradle }:
let
  androidsdk = androidPkgs.sdk (p: with p.stable; [ tools platforms.android-29 build-tools-28-0-3 ]);
  build-tools = androidPkgs.sdk (p: with p.stable; [ tools build-tools-29-0-3 ]);
  buildGradle = callPackage ./gradle-env.nix {};
in
buildGradle rec {
  name = "AuroraStore-${version}.apk";
  version = "3.2.9";

  envSpec = ./gradle-env.json;

  src = fetchFromGitLab {
    owner = "AuroraOSS";
    repo = "AuroraStore";
    rev = version;
    sha256 = "1d5s7xd7mgrnnwgxmdx32jml0rwsxz6qgfbwnh9ppgdsjhg3f3ab";
  };

  gradleFlags = [ "assembleRelease" ];

  preBuild = ''
    printf "\nandroid.aapt2FromMavenOverride=${build-tools}/share/android-sdk/build-tools/29.0.3/aapt2" >> gradle.properties 
  '';

  ANDROID_HOME = "${androidsdk}/share/android-sdk";
  nativeBuildInputs = [ jdk ];

  installPhase = ''
    cp app/build/outputs/apk/release/app-release-unsigned.apk $out
  '';
}
