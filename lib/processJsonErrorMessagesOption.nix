{ lib, ... }:

cfg: lib.optionalString (cfg.json-error-messages) "--json-error-messages"
