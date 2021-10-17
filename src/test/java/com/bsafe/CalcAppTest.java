package com.bsafe;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import org.junit.Before;
import org.junit.Test;
import org.junit.After;
import static org.junit.Assert.*;

/**
 * Unit test for simple App.
 */
public class CalcAppTest
{

    private final ByteArrayOutputStream outContent = new ByteArrayOutputStream();

    @Before
    public void setUpStreams() {
        System.setOut(new PrintStream(outContent));
    }

    @Test
    public void testAppConstructor() {
        try {
            new CalcApp();
        } catch (Exception e) {
            fail("Construction failed.");
        }
    }

    @Test
    public void testAppMain()
    {
        CalcApp.main(null);
        try {
            assertEquals("Hello World!" + System.getProperty("line.separator"), outContent.toString());
        } catch (AssertionError e) {
            fail("\"message\" is not \"Hello World! \"");
        }
    }

    @Test
    public void testAppCalc()
    {
        try {
            int res=CalcApp.calc(5,10);
            int expected=5*10;
            assertEquals(expected, res);
        } catch (AssertionError e1) {
            fail("Not 50");
        }
    }
    
    @After
    public void cleanUpStreams() {
        System.setOut(null);
    }

}
