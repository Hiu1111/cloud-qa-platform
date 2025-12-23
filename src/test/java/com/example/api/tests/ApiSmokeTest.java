package com.example.api.tests;

import com.example.api.ApiClient;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class ApiSmokeTest {
  @Test
  void healthEndpointOk() {
    ApiClient api = new ApiClient();
    assertEquals(200, api.health().statusCode());
  }
}
