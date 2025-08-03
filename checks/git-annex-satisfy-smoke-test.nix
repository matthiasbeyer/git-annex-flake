{ pkgs, system, inputs, ... }:

let
  userName = "alice";
  repoPathA = "/home/${userName}/annex-a";
  repoPathB = "/home/${userName}/annex-b";
in
pkgs.nixosTest {
  name = "git-annex-satisfy-smoke-test";

  nodes = {
    server = { config, pkgs, ... }:
      {
        imports = [
          inputs.self.nixosModules."${system}".git-annex-satisfy
        ];

        users.users."${userName}" = {
          name = userName;
          createHome = true;
          isNormalUser = true;
        };

        users.groups."${userName}" = {};

        services.git-annex-satisfy = {
          enable = true;
          path = repoPathA;
          remotes = [ "repo-b" ];
          user = userName;
          group = userName;

          common-options.time-limit = "10s"; # don't take too long
        };

        systemd.services.git-annex-satisfy = {
          # We start it by hand in this test
          wantedBy = pkgs.lib.mkForce [];
        };

        systemd.services.git-setup = {
          path = [ pkgs.git ];
          serviceConfig.Type = "oneshot";
          script = ''
            git config --global user.name "User Name"
            git config --global user.email user@example.com
            git config --global init.defaultBranch master
          '';
        };

        systemd.services.repo-setup = {
          path = [ pkgs.git pkgs.git-annex ];
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir "${repoPathA}"
            cd "${repoPathA}"
            git init
            git annex init
            touch file
            git annex add ./file
            git commit -am init

            cd "${repoPathB}"
            git init
            git annex init
            git remote add repo-a "${repoPathA}"
            git annex wanted here everything
            git annex sync repo-a

            cd "${repoPathA}"
            git remote add repo-b "${repoPathB}"
            git annex sync repo-b
          '';
        };
      };
  };

  testScript = ''
    start_all()
    server.systemctl("start git-setup.service")
    server.systemctl("start repo-setup.service")
    server.wait_for_unit("repo-setup.service")

    server.systemctl("start git-annex-satisfy.service")

    server.wait_for_unit("git-annex-satisfy.service")

    server.succeed("realpath ${repoPathB}/file")
  '';
}

