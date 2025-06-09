package com.gmail.xuoxod.scrutinaut;

import java.util.*;

public class ManualOpenGraphScrape {
    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.out.println("Usage: java ManualOpenGraphScrape <url>");
            return;
        }
        String url = args[0];
        WebScraperService service = new WebScraperService();
        Map<String, Object> result = service.scrapeFromRustCli(List.of(url));
        Map<String, Object> siteData = (Map<String, Object>) result.get(url);

        if (siteData == null) {
            System.out.println("No data returned for URL: " + url);
            return;
        }
        Map<String, Object> og = (Map<String, Object>) siteData.get("opengraph");
        System.out.println("OpenGraph data for " + url + ":");
        if (og == null || og.isEmpty()) {
            System.out.println("  (No OpenGraph tags found)");
        } else {
            og.forEach((k, v) -> System.out.println("  " + k + ": " + v));
        }
    }
}