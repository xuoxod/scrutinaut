package com.gmail.xuoxod.scrutinaut;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ScrutinautAppTest {

    @Test
    void testMainHelpDoesNotCrash() {
        // Should print help and exit normally
        assertDoesNotThrow(() -> {
            ScrutinautApp.main(new String[] {"--help"});
        });
    }

    @Test
    void testMainVersionDoesNotCrash() {
        // Should print version and exit normally
        assertDoesNotThrow(() -> {
            ScrutinautApp.main(new String[] {"version"});
        });
    }
}