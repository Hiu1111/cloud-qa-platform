# Cloud QA Platform

A starter QA automation framework built with Java and Maven for validating both API and UI workflows. This project is designed to be a simple, extensible foundation for smoke tests, regression suites, and CI-based test execution.

## Tech Stack

- **Java 17**
- **Maven**
- **JUnit 5**
- **Selenium**
- **WebDriverManager**
- **RestAssured**
- **Jenkins**
- **AWS S3** for optional report upload

## Project Purpose

This repository provides a lightweight automation framework for:

- API smoke testing
- UI test automation
- configuration-driven test execution
- CI pipeline integration with Jenkins
- optional test report upload to Amazon S3

## Project Structure

```text
cloud-qa-platform/
├── scripts/                         # helper scripts such as S3 report upload
├── src/
│   └── test/
│       ├── java/com/example/
│       │   ├── api/                 # API client and API tests
│       │   ├── config/              # configuration loader
│       │   └── ui/                  # UI driver, pages, and UI tests
│       └── resources/               # test resources including config files
├── Jenkinsfile                      # CI pipeline definition
├── pom.xml                          # Maven dependencies and build config
└── README.md
