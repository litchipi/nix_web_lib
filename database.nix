{ system, nixpkgs, ... }: let
  pkgs = import nixpkgs { inherit system; };
in {
  postgresql = {
    pg_ctl = {
      dir,
      logfile ? "${dir}/logs",
      port ? 5432,
    ... }: args: (builtins.concatStringsSep " " [
      "${pkgs.postgresql}/bin/pg_ctl"
      "-D ${dir}"
      "-l ${logfile}"
      "-o \"-p ${builtins.toString port}\""
      "-o \"--unix_socket_directories='${dir}'\""

    ]) + args;

    init_db = { dir, ... }: ''
      mkdir -p ${dir}
      if [ ! -f ${dir}/PG_VERSION ]; then
        initdb -D ${dir} --no-locale --encoding=UTF8
      fi

    '';

    stop_db = { dir, ... }: ''
      if [ -f ${dir}/postmaster.pid ]; then
        ${pkgs.postgresql}/bin/pg_ctl -D ${dir} stop
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
      ... }: ''
      if ! ${pkgs.postgresql}/bin/psql -h ${dir} \
        -p ${builtins.toString port} -U ${user} \
        -n "${dbname}" \
        -c "SELECT * FROM pg_catalog.pg_user"|grep ${user} 1>/dev/null; then
        ${pkgs.postgresql}/bin/createuser -p ${builtins.toString port} -h ${dir} -d ${user}
      fi

    '';

    ensure_db_exists = {
      dir,
      port,
      user,
      dbname,
      ... }: ''
      if ! ${pkgs.postgresql}/bin/psql -h ${dir} \
        -p ${builtins.toString port} -U ${user} -n "${dbname}" \
        -c "SELECT * FROM pg_catalog.pg_database" 1>/dev/null 2>/dev/null; then
        ${pkgs.postgresql}/bin/createdb -h ${dir} -p ${builtins.toString port} -U ${user} ${dbname}
      fi

    '';
  };
}
