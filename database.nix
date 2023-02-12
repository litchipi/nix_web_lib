{ system, nixpkgs, ... }: let
  pkgs = import nixpkgs { inherit system; };
in {
  postgresql = rec {
    pg_ctl = {
      dir,
      logfile ? "${dir}/logs",
      port ? 5432,
    ... }: args: (builtins.concatStringsSep " " [
      "${pkgs.postgresql}/bin/pg_ctl"
      "-D $(realpath ${dir})"
      "-l ${logfile}"
      "-o \"-p ${builtins.toString port}\""
      "-o \"--unix_socket_directories='$(realpath ${dir})'\""

    ]) + " " + args;

    init_db = { dir, ... }: ''
      mkdir -p ${dir}
      if [ ! -f ${dir}/PG_VERSION ]; then
        ${pkgs.postgresql}/bin/initdb -D ${dir} --no-locale --encoding=UTF8
      fi

    '';

    db_check_connected = { host, port, user, dbname, ... }: ''
      ${pkgs.postgresql}/bin/pg_isready --quiet -h ${host} \
        -p ${builtins.toString port} \
        -U ${user} \
        -d ${dbname}

    '';

    ensure_user_exists = {
      dir,
      port,
      user,
      dbname,
      ... }@args: ''
      if ! ${pkgs.postgresql}/bin/psql -h $(realpath ${dir}) \
        -p ${builtins.toString port} -U ${user} \
        -c "SELECT * FROM pg_catalog.pg_user"|grep ${user} 1>/dev/null 2>/dev/null; then
        if ! ${pkgs.postgresql}/bin/createuser \
          -p ${builtins.toString port} \
          -h $(realpath ${dir}) \
          -d ${user}; then
            ${stopdb args}
            exit 1
        fi
      fi

    '';

    ensure_db_exists = {
      dir,
      port,
      user,
      dbname,
      ... }@args: ''
      if ! ${pkgs.postgresql}/bin/psql \
        -h $(realpath ${dir}) \
        -p ${builtins.toString port} -U ${user} -n "${dbname}" \
        -c "SELECT * FROM pg_catalog.pg_database" 1>/dev/null 2>/dev/null; then
        if ! ${pkgs.postgresql}/bin/createdb \
          -h $(realpath ${dir}) \
          -p ${builtins.toString port} \
          -U ${user} ${dbname}; then
            ${stopdb args}
            exit 1
        fi
      fi

    '';

    stopdb = { dir, ...}: ''
      if [ -f ${dir}/postmaster.pid ]; then
        ${pkgs.postgresql}/bin/pg_ctl -D ${dir} stop
      fi

    '';

    stop_on_interrupt = args: ''
      function interrupt() {
        echo -e -n "\033[1K\r"
        ${stopdb args}
      }
      trap interrupt SIGINT

    '';
  };
}
