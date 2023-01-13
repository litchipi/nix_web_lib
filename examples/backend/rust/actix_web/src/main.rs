use actix_web::{App, HttpServer};
use actix_web::middleware::Logger;
use actix_files::Files;
use std::path::PathBuf;
use std::str::FromStr;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let args: Vec<String> = std::env::args().collect();
    println!("{:?}", args);
    if args.len() < 2 {
        panic!("Pass the directory to serve as an argument");
    }

    let mut builder = pretty_env_logger::formatted_builder();
    builder.filter_level(log::LevelFilter::Debug);
    builder.init();

    let addr = String::from("127.0.0.1");
    let port = 8080;

    log::info!("Starting server on http://{}:{}", addr, port);
    HttpServer::new(move || {
        App::new()
            .wrap(Logger::new("%t | %a - [%s] %r (%D ms)"))
            .service(
                Files::new("/",
                    PathBuf::from_str(&args[1]).unwrap().canonicalize().unwrap()
                ).index_file("index.html")
            )
        })
        .bind((addr.as_str(), port))?
        .run()
        .await?;

    Ok(())
}
