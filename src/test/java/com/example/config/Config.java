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
