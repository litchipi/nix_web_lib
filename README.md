# Nix Web library

Build Web frameworks using Nix

Presentation post [on my blog](https://litchipi.github.io/nix/2023/01/14/nixifying-build-web-app.html)

## Backends

- Actix-web: `weblib.backend.rust.build`

## Frontends

- React: `weblib.frontend.react.build`
- VueJS: `weblib.frontend.vue.build`

## Databases

- Postgresql: `weblib.database.postgresql`
  - `pg_ctl`: Wrapper around `pg_ctl` to add arguments from the config
  - `init_db`: Initialize the database (if doesn't exist)
  - `stop_db`: Stop the database
  - `db_check_connected`: Check that the database is started and connection is OK
  - `ensure_user_exists`: Create the user if doesn't exist yet
  - `ensure_db_exists`: Create the database if doesn't exist yet
  - `stop_on_interrupt`: Trap the KeyboardInterrupt signal, and stop the database if caught

## Contributing

You can **create an example** by simply creating a PR adding an example of your
favourite framework in the `example/{type}/{langage}/{framework}` directory
with a `README.md` file describing how to build this example using the native
tools.

Once this is done, the nixification process can begin, and can be done by anyone
knowing a bit of nix. When the CI is green (if it builds), we merge everything.
