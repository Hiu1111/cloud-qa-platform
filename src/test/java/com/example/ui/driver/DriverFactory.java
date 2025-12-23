package com.example.ui.driver;

import com.example.config.Config;
import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;

public class DriverFactory {
  public static WebDriver create() {
    boolean headless = Config.getBool("headless", true);

    WebDriverManager.chromedriver().setup();
    ChromeOptions options = new ChromeOptions();
    if (headless) options.addArguments("--headless=new");
    options.addArguments("--no-sandbox");
    options.addArguments("--disable-dev-shm-usage");
    options.addArguments("--window-size=1400,900");
    return new ChromeDriver(options);
  }
}
