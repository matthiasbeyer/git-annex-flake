{ lib, ... }:

cfg: lib.optionalString (cfg.json) "--json"
