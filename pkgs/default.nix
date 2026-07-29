final: prev: {
  seeed-voicecard = kernel: final.callPackage ./seeed-voicecard.nix { inherit kernel; };
  linux-voice-assistant = final.callPackage ./linux-voice-assistant.nix { };
  speech-to-phrase = final.callPackage ./speech-to-phrase.nix { };
}
