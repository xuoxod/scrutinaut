package com.gmail.xuoxod.scrutinaut.utils;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class NetworkUtils {
    public static boolean canAccessUrl(String urlString, int timeoutMillis) {
        try {
            URL url = java.net.URI.create(urlString).toURL();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(timeoutMillis);
            conn.setReadTimeout(timeoutMillis);
            conn.setRequestMethod("HEAD");
            int responseCode = conn.getResponseCode();
            return (200 <= responseCode && responseCode < 400);
        } catch (IOException | IllegalArgumentException e) {
            // Log the exception if needed
            System.err.printf("\n\n\t\tError accessing URL: {%s}\n\n\n", e.getMessage());
            return false;
        }
    }
}