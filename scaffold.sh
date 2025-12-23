#!/usr/bin/env bash
set -euo pipefail

mkdir -p \
  src/test/java/com/example/config \
  src/test/java/com/example/api/tests \
  src/test/java/com/example/api \
  src/test/java/com/example/ui/driver \
  src/test/java/com/example/ui/pages \
  src/test/java/com/example/ui/tests \
  src/test/java/com/example/e2e \
  src/test/resources \
  scripts

cat > pom.xml <<'POM'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>cloud-qa-platform</artifactId>
  <version>1.0.0</version>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

    <junit.version>5.10.2</junit.version>
    <selenium.version>4.23.0</selenium.version>
    <restassured.version>5.5.0</restassured.version>
    <slf4j.version>2.0.13</slf4j.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter</artifactId>
      <version>${junit.version}</version>
      <scope>test</scope>
    </dependency>

    <dependency>
      <groupId>org.seleniumhq.selenium</groupId>
      <artifactId>selenium-java</artifactId>
      <version>${selenium.version}</version>
    </dependency>

    <dependency>
      <groupId>io.github.bonigarcia</groupId>
      <artifactId>webdrivermanager</artifactId>
      <version>5.9.2</version>
    </dependency>

    <dependency>
      <groupId>io.rest-assured</groupId>
      <artifactId>rest-assured</artifactId>
      <version>${restassured.version}</version>
      <scope>test</scope>
    </dependency>

    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.17.2</version>
    </dependency>

    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-simple</artifactId>
      <version>${slf4j.version}</version>
      <scope>test</scope>
    </dependency>

    <dependency>
      <groupId>software.amazon.awssdk</groupId>
      <artifactId>s3</artifactId>
      <version>2.27.17</version>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.2.5</version>
        <configuration>
          <useModulePath>false</useModulePath>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
POM

cat > Jenkinsfile <<'JENKINS'
pipeline {
  agent any
  options { timestamps() }

  environment {
    MAVEN_OPTS = '-Dmaven.repo.local=.m2'
    headless = 'true'
    browser = 'chrome'
  }

  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Test') {
      steps {
        sh 'mvn -v'
        sh 'mvn -q test'
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          archiveArtifacts artifacts: 'target/surefire-reports/**', fingerprint: true, allowEmptyArchive: true
        }
      }
    }

    stage('Upload Reports to S3') {
      when { expression { return env.S3_BUCKET != null && env.S3_BUCKET.trim() != '' } }
      steps {
        sh 'chmod +x scripts/upload-reports-to-s3.sh'
        sh 'scripts/upload-reports-to-s3.sh'
      }
    }
  }
}
JENKINS

cat > README.md <<'README'
# cloud-qa-platform

Starter QA automation repo:
- UI: Selenium (Java)
- API: RestAssured
- CI: Jenkinsfile
- AWS: upload surefire reports to S3 (optional)

Run:
- mvn test
README

cat > src/test/resources/config.properties <<'CONF'
baseUrl=https://example.test
apiBaseUrl=https://api.example.test
username=testuser
password=testpass

browser=chrome
headless=true
timeoutSeconds=10
CONF

cat > src/test/java/com/example/config/Config.java <<'JAVA'
package com.example.config;

import java.io.InputStream;
import java.util.Properties;

public class Config {
  private static final Properties props = new Properties();

  static {
    try (InputStream is = Config.class.getClassLoader().getResourceAsStream("config.properties")) {
      if (is == null) throw new RuntimeException("config.properties not found");
      props.load(is);
    } catch (Exception e) {
      throw new RuntimeException("Failed to load config.properties", e);
    }
  }

  public static String get(String key) {
    String envOverride = System.getenv(key);
    if (envOverride != null && !envOverride.isBlank()) return envOverride;

    String sysOverride = System.getProperty(key);
    if (sysOverride != null && !sysOverride.isBlank()) return sysOverride;

    return props.getProperty(key);
  }

  public static boolean getBool(String key, boolean defaultVal) {
    String v = get(key);
    return v == null ? defaultVal : Boolean.parseBoolean(v);
  }

  public static int getInt(String key, int defaultVal) {
    String v = get(key);
    return v == null ? defaultVal : Integer.parseInt(v);
  }
}
JAVA

cat > src/test/java/com/example/ui/driver/DriverFactory.java <<'JAVA'
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
JAVA

cat > src/test/java/com/example/ui/pages/LoginPage.java <<'JAVA'
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
JAVA

cat > src/test/java/com/example/ui/tests/UiSmokeTest.java <<'JAVA'
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
JAVA

cat > src/test/java/com/example/api/ApiClient.java <<'JAVA'
package com.example.api;

import com.example.config.Config;
import io.restassured.RestAssured;
import io.restassured.response.Response;

import static io.restassured.RestAssured.given;

public class ApiClient {
  public ApiClient() { RestAssured.baseURI = Config.get("apiBaseUrl"); }

  public Response health() {
    return given().when().get("/health").then().extract().response();
  }
}
JAVA

cat > src/test/java/com/example/api/tests/ApiSmokeTest.java <<'JAVA'
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
JAVA

cat > scripts/upload-reports-to-s3.sh <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

: "${S3_BUCKET:?Set S3_BUCKET env var}"
: "${S3_PREFIX:=qa-reports}"
: "${BUILD_TAG:=local}"

REPORT_DIR="target/surefire-reports"

if [ ! -d "$REPORT_DIR" ]; then
  echo "No reports found at $REPORT_DIR"
  exit 0
fi

aws s3 cp "$REPORT_DIR" "s3://${S3_BUCKET}/${S3_PREFIX}/${BUILD_TAG}/" --recursive
echo "Uploaded reports to s3://${S3_BUCKET}/${S3_PREFIX}/${BUILD_TAG}/"
BASH

chmod +x scripts/upload-reports-to-s3.sh
echo "✅ Project scaffolded in: $(pwd)"
