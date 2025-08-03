{ pkgs, system, inputs, ... }:

let
  userName = "alice";
  repoPathA = "/home/${userName}/annex-a";
  repoPathB = "/home/${userName}/annex-b";
in
pkgs.nixosTest {
  name = "git-annex-fsck-multi-service";

  nodes = {
    server = { config, pkgs, ... }:
      {
        imports = [
          ({ config, pkgs, ... }: inputs.self.lib."${system}".mkFsckService {
            name = "git-annex-fsck-repo-a";
            inherit config pkgs;
          })

          ({ config, pkgs, ... }: inputs.self.lib."${system}".mkFsckService {
            name = "git-annex-fsck-repo-b";
            inherit config pkgs;
          })
        ];

        users.users."${userName}" = {
          name = userName;
          createHome = true;
          isNormalUser = true;
        };

        users.groups."${userName}" = {};

        services.git-annex-fsck-repo-a = {
          enable = true;
          path = repoPathA;
          user = userName;
          group = userName;

          startAt = "10s"; # very fast, for testing
          common-options.time-limit = "5s"; # don't take too long
        };

        services.git-annex-fsck-repo-b = {
          enable = true;
          path = repoPathB;
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

        systemd.services.repo-setup-a = {
          path = [ pkgs.git pkgs.git-annex ];
          script = ''
            mkdir "${repoPathA}"
            cd "${repoPathA}"
            git init
            git annex init
            touch file
            git annex add ./file
            git commit -am init
          '';
        };

        systemd.services.repo-setup-b = {
          path = [ pkgs.git pkgs.git-annex ];
          script = ''
            mkdir "${repoPathB}"
            cd "${repoPathB}"
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

    server.systemctl("start repo-setup-a.service");
    server.systemctl("start repo-setup-b.service");

    server.wait_for_unit("repo-setup-a.service");
    server.wait_for_unit("repo-setup-b.service");

    server.systemctl("start git-annex-fsck-a.service");
    server.systemctl("start git-annex-fsck-b.service");
  '';
}

