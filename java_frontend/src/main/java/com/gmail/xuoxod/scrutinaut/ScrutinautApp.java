package com.gmail.xuoxod.scrutinaut;

import picocli.CommandLine;
import picocli.CommandLine.*;
import java.util.*;
import java.util.concurrent.Callable;
import com.gmail.xuoxod.scrutinaut.utils.PrettyPrintUtils;
import com.gmail.xuoxod.scrutinaut.utils.PrettyPrintUtils.PrettyStyle;

@Command(name = "scrutinaut", mixinStandardHelpOptions = true, version = "Scrutinaut 1.0", description = {
        "@|bold,underline Scrutinaut: A Modern Web Scraper CLI|@",
        "",
        "Scrapes web pages for metadata, headings, links, images, and OpenGraph tags.",
        "Uses a Rust backend for fast, robust extraction.",
        "",
        "Examples:",
        "  scrutinaut scrape https://www.rust-lang.org/",
        "  scrutinaut scrape --file urls.txt",
        "  scrutinaut scrape --style=enhanced https://www.rust-lang.org/",
        "  scrutinaut scrape --style=regular --file urls.txt",
        "  scrutinaut scrape --style=raw https://www.rust-lang.org/",
        "",
        "For more info, see: https://github.com/yourproject/scrutinaut"
})
public class ScrutinautApp implements Runnable {

    public static void main(String[] args) {
        int exitCode = new CommandLine(new ScrutinautApp())
                .addSubcommand("scrape", new ScrapeCommand())
                .addSubcommand("version", new VersionCommand())
                .execute(args);
        // Only exit if not running under Maven Surefire (unit test)
        if (System.getProperty("surefire.test.class.path") == null) {
            System.exit(exitCode);
        }
    }

    @Override
    public void run() {
        CommandLine.usage(this, System.out);
    }

    @Command(name = "scrape", description = "Scrape one or more URLs for metadata and content.", usageHelpAutoWidth = true, showDefaultValues = true)
    static class ScrapeCommand implements Callable<Integer> {

        @Parameters(arity = "0..*", paramLabel = "URL", description = "One or more URLs to scrape")
        List<String> urls = new ArrayList<>();

        @Option(names = "--file", description = "File with URLs (one per line)")
        String urlFile;

        // Accept style as a string for case-insensitive handling
        @Option(names = "--style", description = {
                "Output style: RAW, JSON, REGULAR, ENHANCED (case-insensitive)",
                "Default: JSON (indented, no color)",
                "Options:",
                "  RAW      - Compact JSON (single line)",
                "  JSON     - Indented JSON (default)",
                "  REGULAR  - Regular pretty print (color, vertical)",
                "  ENHANCED - Enhanced pretty print (color, wide, horizontal)"
        })
        String style = "JSON";

        @Override
        public Integer call() throws Exception {
            if (urls.isEmpty() && urlFile == null) {
                System.err.println(
                        CommandLine.Help.Ansi.AUTO.string("@|red No URLs provided. Use arguments or --file FILE.|@"));
                return 1;
            }

            if (urlFile != null) {
                urls.addAll(java.nio.file.Files.readAllLines(java.nio.file.Paths.get(urlFile)));
            }

            // Convert style string to enum, case-insensitive
            PrettyPrintUtils.PrettyStyle styleEnum;
            try {
                styleEnum = PrettyPrintUtils.PrettyStyle.valueOf(style.trim().toUpperCase());
            } catch (Exception e) {
                System.err.println(
                        CommandLine.Help.Ansi.AUTO.string("@|red Invalid style: " + style + ". Using default: JSON|@"));
                styleEnum = PrettyPrintUtils.PrettyStyle.JSON;
            }

            WebScraperService service = new WebScraperService();
            Map<String, Object> results = service.scrapeFromRustCli(urls);

            for (String url : urls) {
                System.out.println(CommandLine.Help.Ansi.AUTO.string("@|cyan === Results for: " + url + " ===|@"));
                Object resultObj = results.get(url);
                Map<String, Object> data = null;

                if (resultObj instanceof Map<?, ?>) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> casted = (Map<String, Object>) resultObj;
                    data = casted;
                } else if (resultObj instanceof String) {
                    System.out.println(CommandLine.Help.Ansi.AUTO.string("@|red Error: " + resultObj + "|@"));
                    continue;
                } else {
                    System.out.println(
                            CommandLine.Help.Ansi.AUTO.string("@|red Unknown result type for URL: " + url + "|@"));
                    continue;
                }
                PrettyPrintUtils.prettyPrint(data, styleEnum);
            }
            return 0;
        }
    }

    @Command(name = "version", description = "Show version info")
    static class VersionCommand implements Runnable {
        public void run() {
            System.out.println("Scrutinaut version 1.0");
        }
    }
}