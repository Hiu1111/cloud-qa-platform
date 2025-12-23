package com.example.ui.tests;

import com.example.config.Config;
import com.example.ui.driver.DriverFactory;
import com.example.ui.pages.LoginPage;
import org.junit.jupiter.api.*;
import org.openqa.selenium.WebDriver;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class UiSmokeTest {
  private WebDriver driver;

  @BeforeEach
  void setup() { driver = DriverFactory.create(); }

  @AfterEach
  void teardown() { if (driver != null) driver.quit(); }

  @Test
  void loginPageLoads() {
    String baseUrl = Config.get("baseUrl");
    int timeout = Config.getInt("timeoutSeconds", 10);

    LoginPage login = new LoginPage(driver, timeout);
    login.open(baseUrl);

    assertTrue(driver.getCurrentUrl().contains("/login"));
  }
}
