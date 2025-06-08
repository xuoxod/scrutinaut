use reqwest::blocking::get;
use scraper::{Html, Selector};
use serde_json::{Value, json};
use std::collections::HashMap;

pub fn interrogate_url(url: &str) -> Result<Value, String> {
    let body = get(url)
        .map_err(|e| format!("Failed to fetch URL: {e}"))?
        .text()
        .map_err(|e| format!("Failed to read response: {e}"))?;

    let document = Html::parse_document(&body);

    // Title
    let title = document
        .select(&Selector::parse("title").unwrap())
        .next()
        .map(|el| el.text().collect::<String>())
        .unwrap_or_default();

    // Headings
    let mut headings = Vec::new();
    for tag in &["h1", "h2", "h3"] {
        let sel = Selector::parse(tag).unwrap();
        for el in document.select(&sel) {
            headings.push(el.text().collect::<String>());
        }
    }

    // Links
    let links: Vec<_> = document
        .select(&Selector::parse("a").unwrap())
        .filter_map(|el| el.value().attr("href").map(|href| href.to_string()))
        .collect();

    // Meta description
    let meta_desc = document
        .select(&Selector::parse("meta[name=description]").unwrap())
        .next()
        .and_then(|el| el.value().attr("content"))
        .unwrap_or("")
        .to_string();

    // Images
    let images: Vec<_> = document
        .select(&Selector::parse("img").unwrap())
        .filter_map(|el| el.value().attr("src").map(|src| src.to_string()))
        .collect();

    let mut result = HashMap::new();
    result.insert("title", json!(title));
    result.insert("headings", json!(headings));
    result.insert("links", json!(links));
    result.insert("meta_description", json!(meta_desc));
    result.insert("images", json!(images));

    // OpenGraph meta tags
    let mut opengraph: HashMap<String, String> = HashMap::new();
    let og_selector = Selector::parse("meta[property^=\"og:\"]").unwrap();
    for el in document.select(&og_selector) {
        if let Some(property) = el.value().attr("property") {
            if let Some(content) = el.value().attr("content") {
                opengraph.insert(property.to_string(), content.to_string());
            }
        }
    }

    result.insert("opengraph", json!(opengraph));

    Ok(json!(result))
}
