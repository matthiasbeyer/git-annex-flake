{ lib, ... }:

cfg: lib.optionalString (!isNull cfg.jobs) "--jobs=${cfg.jobs}"
