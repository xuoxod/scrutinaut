package com.gmail.xuoxod.scrutinaut.utils;

import java.util.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

public class PrettyPrintUtils {
    public enum PrettyStyle {
        RAW, // Compact JSON
        JSON, // Indented JSON
        REGULAR, // Original pretty print
        ENHANCED // Enhanced, colorful, wide
    }

    // Orchestrator
    public static void prettyPrint(Map<String, Object> map, PrettyStyle style) {
        switch (style) {
            case RAW:
                printCustomJson(map, true);
                break;
            case JSON:
                printCustomJson(map, false);
                break;
            case REGULAR:
                printMap(map, true);
                break;
            case ENHANCED:
                printMapEnhanced(map);
                break;
        }
    }

    // Compact JSON
    public static void printRawJson(Map<String, Object> map) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            System.out.println(mapper.writeValueAsString(map));
        } catch (Exception e) {
            System.out.println(map);
        }
    }

    // Indented JSON
    public static void printIndentedJson(Map<String, Object> map) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.enable(SerializationFeature.INDENT_OUTPUT);
            System.out.println(mapper.writeValueAsString(map));
        } catch (Exception e) {
            System.out.println(map);
        }
    }

    // Original pretty print
    public static void printMap(Map<String, Object> map, boolean pretty) {
        if (!pretty) {
            printRawJson(map);
            return;
        }
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();
            System.out.print("\u001B[32m" + key + ":\u001B[0m ");
            if (value instanceof List<?>) {
                System.out.println();
                for (Object item : (List<?>) value) {
                    System.out.println("  - " + item);
                }
            } else if (value instanceof Map<?, ?>) {
                System.out.println();
                for (Map.Entry<?, ?> sub : ((Map<?, ?>) value).entrySet()) {
                    System.out.println("    " + sub.getKey() + ": " + sub.getValue());
                }
            } else {
                System.out.println(value);
            }
        }
        System.out.println();
    }

    // Enhanced, colorful, horizontally-aligned pretty print
    public static void printMapEnhanced(Map<String, Object> map) {
        String[] colors = {
                "\u001B[36m", // Cyan
                "\u001B[35m", // Magenta
                "\u001B[34m", // Blue
                "\u001B[32m", // Green
                "\u001B[33m", // Yellow
                "\u001B[31m", // Red
        };
        final String RESET = "\u001B[0m";
        final String BOLD = "\u001B[1m";
        final String WHITE = "\u001B[37m";
        final String HEADER = "\u001B[1;44m"; // Bold blue background for section headers

        int maxKeyLen = map.keySet().stream().mapToInt(String::length).max().orElse(10);

        int colorIdx = 0;
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();
            String color = colors[colorIdx % colors.length];
            colorIdx++;

            // Section header
            System.out.println(HEADER + padRight(" " + key.toUpperCase() + " ", maxKeyLen + 4) + RESET);

            // Value
            if (value instanceof List<?>) {
                List<?> list = (List<?>) value;
                if (list.isEmpty()) {
                    System.out.println("  " + color + "[empty]" + RESET);
                } else {
                    for (Object item : list) {
                        System.out.println("  " + color + "• " + colorizeValue(item) + RESET);
                    }
                }
            } else if (value instanceof Map<?, ?>) {
                Map<?, ?> subMap = (Map<?, ?>) value;
                for (Map.Entry<?, ?> sub : subMap.entrySet()) {
                    System.out.println("  " + BOLD + color + padRight(sub.getKey().toString(), maxKeyLen) + RESET
                            + " : " + colorizeValue(sub.getValue()));
                }
            } else {
                System.out.println("  " + colorizeValue(value));
            }
            System.out.println();
        }
    }

    private static String colorizeValue(Object value) {
        final String RESET = "\u001B[0m";
        final String YELLOW = "\u001B[33m";
        final String GREEN = "\u001B[32m";
        final String MAGENTA = "\u001B[35m";
        final String WHITE_BOLD = "\u001B[1;37m";
        if (value == null)
            return MAGENTA + "null" + RESET;
        String str = value.toString().trim();
        if (str.isEmpty())
            return MAGENTA + "[empty]" + RESET;
        if (str.startsWith("http"))
            return YELLOW + str + RESET;
        if (str.length() > 60 && !str.contains(" "))
            return YELLOW + str + RESET;
        if (str.matches("^[0-9]+$"))
            return GREEN + str + RESET;
        return WHITE_BOLD + str + RESET;
    }

    private static String padRight(String s, int n) {
        return String.format("%-" + n + "s", s);
    }

    public static void printCustomJson(Map<String, Object> map, boolean compact) {
        printJsonValue(map, 0, compact);
        System.out.println();
    }

    private static void printJsonValue(Object value, int indent, boolean compact) {
        String indentStr = compact ? "" : "  ".repeat(indent);
        String newline = compact ? "" : "\n";
        String space = compact ? "" : " ";

        if (value instanceof Map<?, ?>) {
            Map<?, ?> map = (Map<?, ?>) value;
            System.out.print("{" + newline);
            int count = 0;
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (count++ > 0)
                    System.out.print("," + newline);
                System.out.print(indentStr + (compact ? "" : "  "));
                System.out.print("\"" + entry.getKey() + "\":" + space);
                printJsonValue(entry.getValue(), indent + 1, compact);
            }
            System.out.print(newline + indentStr + "}");
        } else if (value instanceof List<?>) {
            List<?> list = (List<?>) value;
            System.out.print("[" + newline);
            for (int i = 0; i < list.size(); i++) {
                if (i > 0)
                    System.out.print("," + newline);
                System.out.print(indentStr + (compact ? "" : "  "));
                printJsonValue(list.get(i), indent + 1, compact);
            }
            System.out.print(newline + indentStr + "]");
        } else if (value instanceof String) {
            System.out.print("\"" + escapeJson((String) value) + "\"");
        } else if (value == null) {
            System.out.print("null");
        } else {
            // Numbers, booleans
            System.out.print(value.toString());
        }
    }

    private static String escapeJson(String s) {
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}