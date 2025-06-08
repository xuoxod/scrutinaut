use rust_backend::core::url_interrogator::interrogate_url;
use std::env;
use std::collections::HashMap;
use serde_json::Value;
use url::Url; // <-- Add this import

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.is_empty() {
        eprintln!("Usage: url_scraper_cli <URL1> [URL2 ...]");
        std::process::exit(1);
    }

    let mut session_data: HashMap<String, Value> = HashMap::new();

    for url in &args {
        // Validate URL
        if Url::parse(url).is_err() {
            eprintln!("Invalid URL: {}", url);
            continue;
        }
        match interrogate_url(url) {
            Ok(json) => {
                session_data.insert(url.clone(), json);
            }
            Err(e) => {
                eprintln!("Error scraping {}: {}", url, e);
            }
        }
    }

    println!("{}", serde_json::to_string(&session_data).unwrap());
}