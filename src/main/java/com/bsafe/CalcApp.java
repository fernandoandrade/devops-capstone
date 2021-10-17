package com.bsafe;

/**
 * Hello world!
 */
public class CalcApp
{

    private final String message = "Hello World!";

    public CalcApp() {}

    public static void main(String[] args) {
        System.out.println(new CalcApp().getMessage());
    }
    
    public static int calc(int a, int b) {
        int result1 = a * b;
        return  result1;
    }
    
    private final String getMessage() {
        return message;
    }

}
