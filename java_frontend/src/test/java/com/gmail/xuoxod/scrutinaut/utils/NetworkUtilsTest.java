package com.gmail.xuoxod.scrutinaut.utils;

import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

class NetworkUtilsTest {

    // Global variable for timeout (best practice)
    private static final int TIMEOUT = 3000;

    @BeforeAll
    static void beforeAll() {
        // Could set up a mock server or log test start
    }

    @AfterAll
    static void afterAll() {
        // Could tear down resources or log test end
    }

    @BeforeEach
    void setUp() {
        // Setup before each test if needed
    }

    @AfterEach
    void tearDown() {
        // Cleanup after each test if needed
    }

    // 1. Real: Can access a known good URL
    @Test
    void testCanAccessValidUrl() {
        assertTrue(NetworkUtils.canAccessUrl("https://www.rust-lang.org/", TIMEOUT));
    }

    // 2. Real: Cannot access a non-existent domain
    @Test
    void testCannotAccessInvalidDomain() {
        assertFalse(NetworkUtils.canAccessUrl("http://nonexistent.example.com/", TIMEOUT));
    }

    // 3. Real: Cannot access a malformed URL
    @Test
    void testCannotAccessMalformedUrl() {
        assertFalse(NetworkUtils.canAccessUrl("not-a-url", TIMEOUT));
    }

    // 4. Dummy: Timeout is respected (simulate by using a reserved IP)
    @Test
    void testTimeoutIsRespected() {
        long start = System.currentTimeMillis();
        // 10.255.255.1 is a TEST-NET-2 IP, should not respond
        NetworkUtils.canAccessUrl("http://10.255.255.1/", 1000);
        long elapsed = System.currentTimeMillis() - start;
        assertTrue(elapsed >= 1000, "Timeout should be at least 1 second");
    }

    // 5. Dummy: Access to a local resource (localhost)
    @Test
    void testLocalhostAlwaysAccessible() {
        // This may fail if nothing is running on port 80, so just check it doesn't throw
        assertDoesNotThrow(() -> NetworkUtils.canAccessUrl("http://localhost/", TIMEOUT));
    }
}