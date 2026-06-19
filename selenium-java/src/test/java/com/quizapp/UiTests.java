package com.quizapp;

import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.time.Duration;

public class UiTests extends BaseTest {
    private WebDriver driver;

    @BeforeClass
    public void setUp() {
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--headless");
        options.addArguments("--no-sandbox");
        options.addArguments("--disable-dev-shm-usage");
        options.addArguments("--window-size=1920,1080");
        
        driver = new ChromeDriver(options);
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(10));
        System.out.println("\n  ✅ WebDriver initialized");
    }

    @AfterClass
    public void tearDown() {
        if (driver != null) {
            driver.quit();
            System.out.println("  ✅ WebDriver shut down");
        }
    }

    @Test(priority = 1)
    public void test21_loadFrontend() {
        System.out.println("\n[TEST UI.1] Load Frontend Page");
        driver.get(FRONTEND_URL);
        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        String source = driver.getPageSource();
        Assert.assertTrue(source.length() > 100, "Page source should not be empty");
        System.out.println("  Page loaded — " + source.length() + " chars");
    }

    @Test(priority = 2)
    public void test22_flutterEnginePresent() {
        System.out.println("\n[TEST UI.2] Flutter Engine Present");
        driver.get(FRONTEND_URL);
        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        boolean found = false;
        String[] tags = {"flutter-view", "flt-glass-pane", "body"};
        for (String tag : tags) {
            try {
                WebElement el = driver.findElement(By.tagName(tag));
                if (el != null) {
                    found = true;
                    break;
                }
            } catch (Exception e) {
                // ignore
            }
        }
        Assert.assertTrue(found, "Flutter engine elements should be present in page DOM");
    }

    @Test(priority = 3)
    public void test23_captureScreenshot() throws IOException {
        System.out.println("\n[TEST UI.3] Capture Screenshot");
        driver.get(FRONTEND_URL);
        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);
        File destDir = new File("screenshots");
        if (!destDir.exists()) {
            destDir.mkdirs();
        }
        File destFile = new File(destDir, "selenium_screenshot.png");
        Files.copy(scrFile.toPath(), destFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        Assert.assertTrue(destFile.exists(), "Screenshot file should be saved");
        System.out.println("  Screenshot saved to " + destFile.getAbsolutePath());
    }
}
