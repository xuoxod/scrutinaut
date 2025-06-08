package com.gmail.xuoxod.scrutinaut;

import org.junit.jupiter.api.Test;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

class WebScraperServiceTest {

    @Test
    @SuppressWarnings("unchecked")
    void testScrapeSingleUrlReturnsData() throws Exception {
        WebScraperService service = new WebScraperService();
        Map<String, Object> result = service.scrapeFromRustCli(List.of("https://www.rust-lang.org/"));
        assertTrue(result.containsKey("https://www.rust-lang.org/"));
        Map<String, Object> siteData = (Map<String, Object>) result.get("https://www.rust-lang.org/");
        assertTrue(siteData.containsKey("title"));
        assertTrue(siteData.containsKey("headings"));
        assertTrue(siteData.containsKey("links"));
    }

    @Test
    void testScrapeMultipleUrls() throws Exception {
        WebScraperService service = new WebScraperService();
        List<String> urls = List.of("https://www.rust-lang.org/", "https://www.mozilla.org/");
        Map<String, Object> result = service.scrapeFromRustCli(urls);
        assertEquals(2, result.size());
    }

    @Test
    void testInvalidUrlIsHandled() {
        WebScraperService service = new WebScraperService();
        Exception exception = assertThrows(RuntimeException.class, () -> {
            service.scrapeFromRustCli(List.of("not-a-url"));
        });
        assertTrue(exception.getMessage().contains("Rust CLI failed"));
    }

    // Creative dummy test 1: Check that an empty list returns an error
    @Test
    void testEmptyUrlListThrows() {
        WebScraperService service = new WebScraperService();
        Exception exception = assertThrows(RuntimeException.class, () -> {
            service.scrapeFromRustCli(Collections.emptyList());
        });
        assertTrue(exception.getMessage().contains("Rust CLI failed"));
    }

    // Creative dummy test 2: Check that a URL with no headings still returns a
    // valid structure
    @Test
    @SuppressWarnings("unchecked")
    void testUrlWithNoHeadings() throws Exception {
        WebScraperService service = new WebScraperService();
        // Use a minimal HTML page you control or a known site with no <h1>-<h3>
        Map<String, Object> result = service.scrapeFromRustCli(List.of("https://example.com/"));
        Map<String, Object> siteData = (Map<String, Object>) result.get("https://example.com/");
        assertTrue(siteData.containsKey("title"));
        assertTrue(siteData.containsKey("headings"));
        assertTrue(siteData.containsKey("links"));
        List<?> headings = (List<?>) siteData.get("headings");
        assertNotNull(headings);
    }

    @Test
    @SuppressWarnings("unchecked")
    void testMetaDescriptionAndImagesExtraction() throws Exception {
        WebScraperService service = new WebScraperService();
        Map<String, Object> result = service.scrapeFromRustCli(List.of("https://www.rust-lang.org/"));
        Map<String, Object> siteData = (Map<String, Object>) result.get("https://www.rust-lang.org/");
        assertTrue(siteData.containsKey("meta_description"));
        assertTrue(siteData.containsKey("images"));
        assertNotNull(siteData.get("images"));
    }

    @Test
    @SuppressWarnings("unchecked")
    void testPageWithOnlyImages() throws Exception {
        WebScraperService service = new WebScraperService();
        // Use a known image-only page or a test fixture
        Map<String, Object> result = service
                .scrapeFromRustCli(List.of("https://www.w3schools.com/html/html_images.asp"));
        Map<String, Object> siteData = (Map<String, Object>) result
                .get("https://www.w3schools.com/html/html_images.asp");
        List<?> images = (List<?>) siteData.get("images");
        assertNotNull(images);
        assertTrue(images.size() > 0);
    }

    @Test
    @SuppressWarnings("unchecked")
    void testPageWithManyLinks() throws Exception {
        WebScraperService service = new WebScraperService();
        Map<String, Object> result = service
                .scrapeFromRustCli(List.of("https://en.wikipedia.org/wiki/List_of_HTTP_status_codes"));
        Map<String, Object> siteData = (Map<String, Object>) result
                .get("https://en.wikipedia.org/wiki/List_of_HTTP_status_codes");
        List<?> links = (List<?>) siteData.get("links");
        assertNotNull(links);
        assertTrue(links.size() > 50); // Wikipedia pages have many links
    }

}