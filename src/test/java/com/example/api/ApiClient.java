
package com.example.api;

import com.example.config.Config;
import io.restassured.RestAssured;
import io.restassured.response.Response;

import static io.restassured.RestAssured.given;

public class ApiClient {
  public ApiClient() { RestAssured.baseURI = Config.get("apiBaseUrl"); }

  public Response health() {
    return given().when().get("/status/200").then().extract().response();
  }
}

