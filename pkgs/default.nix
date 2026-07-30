final: prev: {
  seeed-voicecard = kernel: final.callPackage ./seeed-voicecard.nix { inherit kernel; };
}
