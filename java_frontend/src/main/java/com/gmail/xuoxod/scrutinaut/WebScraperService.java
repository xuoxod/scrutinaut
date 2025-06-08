package com.gmail.xuoxod.scrutinaut;

import java.io.*;
import java.util.*;
import com.fasterxml.jackson.databind.*;

public class WebScraperService {

    private static final String[] COMMON_PATHS = {
            "./url_scraper_cli", // Same directory as the JAR
            "url_scraper_cli", // Fallback
            "../rust_backend/target/debug/url_scraper_cli",
            "../../rust_backend/target/debug/url_scraper_cli",
            "rust_backend/target/debug/url_scraper_cli"
    };

    public Map<String, Object> scrapeFromRustCli(List<String> urls) throws IOException, InterruptedException {
        String rustCliPath = System.getenv("SCRUTINAUT_RUST_CLI");
        if (rustCliPath == null || rustCliPath.isBlank()) {
            // Try common relative paths
            for (String path : COMMON_PATHS) {
                File f = new File(path);
                if (f.exists() && f.canExecute()) {
                    rustCliPath = f.getAbsolutePath();
                    break;
                }
            }
        }
        if (rustCliPath == null || rustCliPath.isBlank()) {
            throw new IllegalStateException("Could not find Rust CLI executable. Please build the Rust backend.");
        }

        List<String> command = new ArrayList<>();
        command.add(rustCliPath);
        command.addAll(urls);

        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);
        Process process = pb.start();

        StringBuilder output = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
        }
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("Rust CLI failed with exit code " + exitCode);
        }

        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.readValue(output.toString(),
                    new com.fasterxml.jackson.core.type.TypeReference<Map<String, Object>>() {
                    });
        } catch (com.fasterxml.jackson.core.JsonProcessingException e) {
            throw new RuntimeException("Rust CLI failed: " + output.toString().trim(), e);
        }
    }
}