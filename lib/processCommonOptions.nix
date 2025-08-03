{ lib, ... }:

let
  optionProcessors = [
    (cfg: lib.optionalString cfg.force "--force")
    (cfg: lib.optionalString cfg.fast "--fast")
    (cfg: lib.optionalString cfg.quiet "--quiet")
    (cfg: lib.optionalString cfg.verbose "--verbose")
    (cfg: lib.optionalString cfg.explain "--explain")
    (cfg: lib.optionalString cfg.debug "--debug")
    (cfg: lib.optionalString cfg.no-debug "--no-debug")

    (cfg: lib.optionalString (!isNull cfg.debugfilter) (lib.concatStringsSep "," cfg.debugfilter))

    (cfg: lib.optionalString (!isNull cfg.numcopies) "--numcopies=${cfg.numcopies}")

    (cfg: lib.optionalString (!isNull cfg.mincopies) "--mincopies=${cfg.mincopies}")

    (cfg: lib.optionalString cfg.rebalance "--rebalance")

    (cfg: lib.optionalString (!isNull cfg.time-limit) "--time-limit=${cfg.time-limit}")

    (cfg: lib.optionalString (!isNull cfg.size-limit) "--size-limit=${cfg.size-limit}")
    (cfg: lib.optionalString (!isNull cfg.semitrust) "--semitrust=${cfg.semitrust}")
    (cfg: lib.optionalString (!isNull cfg.untrust) "--untrust=${cfg.untrust}")
    (cfg: lib.optionalString (!isNull cfg.trust) "--trust=${cfg.trust}")
    (cfg: lib.optionalString cfg.trust-glacier "--trust-glacier")
    (cfg: lib.optionalString (!isNull cfg.user-agent) "--user-agent=${cfg.user-agent}")
    (cfg: lib.optionalString cfg.notify-start "--notify-start")
    (cfg: let
      cond = cfg ? config && (!isNull cfg.config) && (lib.lists.length cfg.config != 0);
    in lib.optionalString cond (lib.concatStringsSep " " cfg.config))
  ];

  applyProcessorTo = cfg: processor: (processor cfg);

  commonOptionsToListOfStrings = cfg: map (applyProcessorTo cfg.common-options) optionProcessors;

  commonOptionsToString = cfg: lib.concatStringsSep " " (commonOptionsToListOfStrings cfg);
in
{
  inherit
    commonOptionsToListOfStrings
    commonOptionsToString
    ;
}
