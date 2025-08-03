{ pkgs, system, inputs, ... }:

let
  userName = "alice";
  repoPath = "/home/${userName}/annex";
in
pkgs.nixosTest {
  name = "git-annex-fsck-smoke-test";

  nodes = {
    server = { config, pkgs, ... }:
      {
        imports = [
          inputs.self.nixosModules."${system}".git-annex-fsck
        ];

        users.users."${userName}" = {
          name = userName;
          createHome = true;
          isNormalUser = true;
        };

        users.groups."${userName}" = {};

        services.git-annex-fsck = {
          enable = true;
          path = repoPath;
          user = userName;
          group = userName;

          startAt = "10s"; # very fast, for testing
          common-options.time-limit = "5s"; # don't take too long
        };


        systemd.services.git-annex-fsck = {
          # We start it by hand in this test
          wantedBy = pkgs.lib.mkForce [];
        };

        systemd.services.git-setup = {
          path = [ pkgs.git ];
          script = ''
            git config --global user.name "User Name"
            git config --global user.email user@example.com
            git config --global init.defaultBranch master
          '';
        };

        systemd.services.repo-setup = {
          path = [ pkgs.git pkgs.git-annex ];
          script = ''
            mkdir "${repoPath}"
            cd "${repoPath}"
            git init
            git annex init
            touch file
            git annex add ./file
            git commit -am init
          '';
        };
      };
  };

  testScript = ''
    start_all()
    server.systemctl("start git-setup.service");

    server.systemctl("start repo-setup.service");
    server.wait_for_unit("repo-setup.service");

    server.systemctl("start git-annex-fsck.service");
  '';
}

