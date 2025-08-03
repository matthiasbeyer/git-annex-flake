{ pkgs, lib, ... }:

annexCall: cfg: lib.optionalString cfg.inhibitsSleep ''
${pkgs.systemd}/bin/systemd-inhibit \
  --who="${annexCall}" \
  --what="sleep" \
  --why="${annexCall} run" \
''

