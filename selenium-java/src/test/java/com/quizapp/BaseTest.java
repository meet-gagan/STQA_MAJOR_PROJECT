package com.quizapp;

public class BaseTest {
    public static final String BASE_URL = "http://localhost:5001/api";
    public static final String FRONTEND_URL = "http://localhost:8080";
    
    public static String studentToken = "";
    public static String teacherToken = "";
    public static String quizId = "";
    
    public static final String TIMESTAMP = String.valueOf(System.currentTimeMillis());
    
    // User details with timestamp to avoid duplicates
    public static final String STUDENT_NAME = "Java Student " + TIMESTAMP;
    public static final String STUDENT_EMAIL = "java_student_" + TIMESTAMP + "@test.com";
    public static final String STUDENT_PASSWORD = "Student@123456";
    
    public static final String TEACHER_NAME = "Java Teacher " + TIMESTAMP;
    public static final String TEACHER_EMAIL = "java_teacher_" + TIMESTAMP + "@test.com";
    public static final String TEACHER_PASSWORD = "Teacher@123456";
}
