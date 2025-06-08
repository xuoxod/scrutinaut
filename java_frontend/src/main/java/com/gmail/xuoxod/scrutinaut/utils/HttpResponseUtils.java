package com.gmail.xuoxod.scrutinaut.utils;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class HttpResponseUtils {
    public static int getHttpStatusCode(String urlString, int timeoutMillis) throws IOException {
        URL url = java.net.URI.create(urlString).toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setConnectTimeout(timeoutMillis);
        conn.setReadTimeout(timeoutMillis);
        conn.setRequestMethod("HEAD");
        return conn.getResponseCode();
    }
}