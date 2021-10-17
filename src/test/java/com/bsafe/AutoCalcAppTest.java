package com.bsafe;

import org.openqa.selenium.By;		
import org.openqa.selenium.WebDriver;		
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.chrome.ChromeDriver;	
import org.openqa.selenium.WebElement;	
import org.testng.Assert;		
import org.testng.annotations.Test;	
import org.testng.annotations.BeforeTest;	
import org.testng.annotations.AfterTest;
	
public class AutoCalcAppTest {	
	
	    private WebDriver driver;
		private String testHost;

		@Test				
		public void testCalcMultiplication() {
			
			final int arg1 = 4, arg2 = 5;
			final int result = arg1*arg2;
			
			driver.get("http://"+testHost+"/bsafe");  
			String title = driver.getTitle();				 
			Assert.assertTrue(title.contains("B-Safe System")); 
			
			WebElement inArg1 = driver.findElement(By.id("arg1"));
			WebElement inArg2 = driver.findElement(By.id("arg2"));
			
			inArg1.sendKeys(""+arg1);
			inArg2.sendKeys(""+arg2);
			
			WebElement btnSubmit = driver.findElement(By.id("btnsubmit"));
			btnSubmit.submit();
			
			WebElement spnResult = driver.findElement(By.id("result"));
			
			Assert.assertTrue((""+result).equals(spnResult.getAttribute("innerHTML")));
		}	
		
		@BeforeTest
		public void beforeTest() {	
			System.out.println("Test Host: " + System.getProperty("testHost"));
			testHost = System.getProperty("testHost");
			
			String pathFirefox = System.getProperty("webdriver.firefox.driver");
			
		    driver = (pathFirefox != null && !"".equalsIgnoreCase(pathFirefox))? new FirefoxDriver(): new ChromeDriver();
		}		
		@AfterTest
		public void afterTest() {
			driver.quit();			
		}		
}