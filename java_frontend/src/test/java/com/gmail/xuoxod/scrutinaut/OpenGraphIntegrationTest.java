package com.gmail.xuoxod.scrutinaut;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import java.util.*;

class OpenGraphIntegrationTest {

    @Test
    @SuppressWarnings("unchecked")
    void testOpenGraphExtraction() throws Exception {
        WebScraperService service = new WebScraperService();
        String testUrl = "http://localhost:8000/opengraph-test.html";
        Map<String, Object> result = service.scrapeFromRustCli(List.of(testUrl));
        Map<String, Object> siteData = (Map<String, Object>) result.get(testUrl);

        System.out.printf("\n\n\t\tOpenGraph Data: %s\n\n", siteData);

        assertNotNull(siteData, "No data returned for test URL");
        assertTrue(siteData.containsKey("opengraph"), "No 'opengraph' key in result");
        Map<String, Object> og = (Map<String, Object>) siteData.get("opengraph");
        assertNotNull(og, "OpenGraph map is null");
        assertEquals("Test OG Title", og.get("og:title"));
        assertEquals("This is a test OpenGraph description.", og.get("og:description"));
        assertEquals("https://example.com/test-image.png", og.get("og:image"));
        assertEquals("website", og.get("og:type"));
    }
}