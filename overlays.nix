[
  (final: prev: {
    mongodb-compass = prev.mongodb-compass.overrideAttrs (old: {
      buildCommand = builtins.replaceStrings
      [ "wrapGAppsHook $out/bin/mongodb-compass" ]
      [ "wrapGApp $out/bin/mongodb-compass" ]
      old.buildCommand;
    });
  })
]
