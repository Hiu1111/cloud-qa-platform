package com.example.ui.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

public class LoginPage {
  private final WebDriver driver;
  private final WebDriverWait wait;

  private final By username = By.id("username");
  private final By password = By.id("password");
  private final By submit   = By.cssSelector("button[type='submit']");

  public LoginPage(WebDriver driver, int timeoutSeconds) {
    this.driver = driver;
    this.wait = new WebDriverWait(driver, Duration.ofSeconds(timeoutSeconds));
  }

  public void open(String baseUrl) {
    driver.get(baseUrl + "/login");
    wait.until(ExpectedConditions.presenceOfElementLocated(username));
  }

  public void login(String user, String pass) {
    driver.findElement(username).sendKeys(user);
    driver.findElement(password).sendKeys(pass);
    driver.findElement(submit).click();
  }
}
