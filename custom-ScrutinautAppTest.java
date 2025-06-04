package com.gmail.xuoxod.scrutinaut;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ScrutinautAppTest {
    @Test
    void mainRunsWithoutException() {
        assertDoesNotThrow(() -> ScrutinautApp.main(new String[]{}));
    }
}