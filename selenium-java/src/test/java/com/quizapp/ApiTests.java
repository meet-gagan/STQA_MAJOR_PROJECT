package com.quizapp;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ApiTests extends BaseTest {

    // ═══════════════════════════════════════════════════════════════════════════════
    //  API 1 — POST /api/auth/register
    // ═══════════════════════════════════════════════════════════════════════════════

    @Test(priority = 1)
    public void test01_registerStudentSuccess() {
        System.out.println("\n[TEST 1.1] Register New Student");
        Map<String, Object> payload = new HashMap<>();
        payload.put("name", STUDENT_NAME);
        payload.put("email", STUDENT_EMAIL);
        payload.put("password", STUDENT_PASSWORD);
        payload.put("role", "student");

        Response response = RestAssured.given()
                .contentType("application/json")
                .body(payload)
                .post(BASE_URL + "/auth/register");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 201, "Expected status code 201 for register success");
        Assert.assertTrue(response.jsonPath().getBoolean("success"), "Expected success to be true");
        Assert.assertNotNull(response.jsonPath().getString("token"), "Expected token to be present");
        Assert.assertEquals(response.jsonPath().getString("user.email"), STUDENT_EMAIL);
        
        studentToken = response.jsonPath().getString("token");
    }

    @Test(priority = 2)
    public void test02_registerDuplicateEmail() {
        System.out.println("\n[TEST 1.2] Register Duplicate Email");
        Map<String, Object> payload = new HashMap<>();
        payload.put("name", STUDENT_NAME);
        payload.put("email", STUDENT_EMAIL);
        payload.put("password", STUDENT_PASSWORD);
        payload.put("role", "student");

        Response response = RestAssured.given()
                .contentType("application/json")
                .body(payload)
                .post(BASE_URL + "/auth/register");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 400, "Expected status code 400 for duplicate email registration");
        Assert.assertFalse(response.jsonPath().getBoolean("success"), "Expected success to be false");
    }

    @Test(priority = 3)
    public void test03_registerMissingFields() {
        System.out.println("\n[TEST 1.3] Register Missing Fields");
        Response response = RestAssured.given()
                .contentType("application/json")
                .body("{}")
                .post(BASE_URL + "/auth/register");

        System.out.println("  Status: " + response.getStatusCode());
        int status = response.getStatusCode();
        Assert.assertTrue(status == 400 || status == 500, "Expected status code 400 or 500 for missing fields");
    }

    @Test(priority = 4)
    public void test04_registerTeacher() {
        System.out.println("\n[TEST 1.4] Register New Teacher");
        Map<String, Object> payload = new HashMap<>();
        payload.put("name", TEACHER_NAME);
        payload.put("email", TEACHER_EMAIL);
        payload.put("password", TEACHER_PASSWORD);
        payload.put("role", "teacher");

        Response response = RestAssured.given()
                .contentType("application/json")
                .body(payload)
                .post(BASE_URL + "/auth/register");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 201, "Expected status code 201 for teacher register");
        Assert.assertTrue(response.jsonPath().getBoolean("success"), "Expected success to be true");
        Assert.assertEquals(response.jsonPath().getString("user.role"), "teacher");
        
        teacherToken = response.jsonPath().getString("token");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    //  API 2 — POST /api/auth/login
    // ═══════════════════════════════════════════════════════════════════════════════

    @Test(priority = 5)
    public void test05_loginSuccess() {
        System.out.println("\n[TEST 2.1] Login Success");
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", STUDENT_EMAIL);
        payload.put("password", STUDENT_PASSWORD);

        Response response = RestAssured.given()
                .contentType("application/json")
                .body(payload)
                .post(BASE_URL + "/auth/login");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 200, "Expected status code 200 for login success");
        Assert.assertTrue(response.jsonPath().getBoolean("success"), "Expected success to be true");
        Assert.assertNotNull(response.jsonPath().getString("token"), "Expected token to be present");
        
        studentToken = response.jsonPath().getString("token");
    }

    @Test(priority = 6)
    public void test06_loginWrongPassword() {
        System.out.println("\n[TEST 2.2] Login Wrong Password");
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", STUDENT_EMAIL);
        payload.put("password", "WrongPassword123");

        Response response = RestAssured.given()
                .contentType("application/json")
                .body(payload)
                .post(BASE_URL + "/auth/login");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 401, "Expected status code 401 for invalid credentials");
        Assert.assertFalse(response.jsonPath().getBoolean("success"), "Expected success to be false");
    }

    @Test(priority = 7)
    public void test07_loginMissingFields() {
        System.out.println("\n[TEST 2.3] Login Missing Fields");
        Response response = RestAssured.given()
                .contentType("application/json")
                .body("{}")
                .post(BASE_URL + "/auth/login");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 400, "Expected status code 400 for missing login fields");
    }

    @Test(priority = 8)
    public void test08_loginNonexistentUser() {
        System.out.println("\n[TEST 2.4] Login Non-existent User");
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", "nonexistent_" + TIMESTAMP + "@nonexistent.com");
        payload.put("password", "SomePass123");

        Response response = RestAssured.given()
                .contentType("application/json")
                .body(payload)
                .post(BASE_URL + "/auth/login");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 401, "Expected status 401 for nonexistent user");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    //  API 3 — GET /api/auth/me
    // ═══════════════════════════════════════════════════════════════════════════════

    @Test(priority = 9)
    public void test09_getMeSuccess() {
        System.out.println("\n[TEST 3.1] Get Current User (Authenticated)");
        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + studentToken)
                .get(BASE_URL + "/auth/me");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 200, "Expected status 200 for authenticated profile query");
        Assert.assertTrue(response.jsonPath().getBoolean("success"), "Expected success to be true");
        Assert.assertEquals(response.jsonPath().getString("user.email"), STUDENT_EMAIL);
    }

    @Test(priority = 10)
    public void test10_getMeNoToken() {
        System.out.println("\n[TEST 3.2] Get Current User (No Token)");
        Response response = RestAssured.given()
                .get(BASE_URL + "/auth/me");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 401, "Expected status 401 for missing token");
    }

    @Test(priority = 11)
    public void test11_getMeInvalidToken() {
        System.out.println("\n[TEST 3.3] Get Current User (Invalid Token)");
        Response response = RestAssured.given()
                .header("Authorization", "Bearer invalid.token.here")
                .get(BASE_URL + "/auth/me");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 401, "Expected status 401 for invalid token");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    //  API 4 — PUT /api/auth/profile
    // ═══════════════════════════════════════════════════════════════════════════════

    @Test(priority = 12)
    public void test12_updateNameSuccess() {
        System.out.println("\n[TEST 4.1] Update Profile — Change Name");
        String newName = "Updated Java Tester " + TIMESTAMP;
        Map<String, Object> payload = new HashMap<>();
        payload.put("name", newName);

        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + studentToken)
                .contentType("application/json")
                .body(payload)
                .put(BASE_URL + "/auth/profile");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 200, "Expected status 200 for update success");
        Assert.assertTrue(response.jsonPath().getBoolean("success"), "Expected success to be true");
        Assert.assertEquals(response.jsonPath().getString("user.name"), newName);
    }

    @Test(priority = 13)
    public void test13_updateProfileNoToken() {
        System.out.println("\n[TEST 4.2] Update Profile (No Token)");
        Map<String, Object> payload = new HashMap<>();
        payload.put("name", "Hacker");

        Response response = RestAssured.given()
                .contentType("application/json")
                .body(payload)
                .put(BASE_URL + "/auth/profile");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 401, "Expected status 401 for unauthorized update");
    }

    @Test(priority = 14)
    public void test14_updateProfileDuplicateEmail() {
        System.out.println("\n[TEST 4.3] Update Profile — Duplicate Email");
        Map<String, Object> payload = new HashMap<>();
        payload.put("email", TEACHER_EMAIL);

        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + studentToken)
                .contentType("application/json")
                .body(payload)
                .put(BASE_URL + "/auth/profile");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 400, "Expected status 400 for duplicate email update");
        Assert.assertFalse(response.jsonPath().getBoolean("success"), "Expected success to be false");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    //  API 5 — GET /api/quizzes/categories
    // ═══════════════════════════════════════════════════════════════════════════════

    @Test(priority = 15)
    public void test15_createQuizSetup() {
        System.out.println("\n[SETUP] Create Quiz for Category & Results Tests");
        
        Map<String, Object> question1 = new HashMap<>();
        question1.put("questionText", "What is Java?");
        question1.put("options", List.of("Language", "Coffee", "Island", "All of the above"));
        question1.put("correctOption", 3);
        question1.put("explanation", "Java is a programming language, named after coffee, which comes from the island of Java.");

        Map<String, Object> quizPayload = new HashMap<>();
        quizPayload.put("title", "Java Maven Test Quiz " + TIMESTAMP);
        quizPayload.put("category", "Java_Maven_Cat");
        quizPayload.put("description", "A quiz created by automated Java tests");
        quizPayload.put("timePerQuestion", 30);
        quizPayload.put("questions", List.of(question1));

        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + teacherToken)
                .contentType("application/json")
                .body(quizPayload)
                .post(BASE_URL + "/quizzes");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 201, "Expected status 201 for quiz creation");
        
        quizId = response.jsonPath().getString("quiz._id");
        Assert.assertNotNull(quizId, "Expected created quiz ID to be non-null");
    }

    @Test(priority = 16)
    public void test16_getCategoriesSuccess() {
        System.out.println("\n[TEST 5.1] Get Quiz Categories (Authenticated)");
        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + studentToken)
                .get(BASE_URL + "/quizzes/categories");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 200, "Expected status 200");
        Assert.assertTrue(response.jsonPath().getBoolean("success"), "Expected success to be true");
        Assert.assertNotNull(response.jsonPath().getList("categories"), "Expected categories list");
    }

    @Test(priority = 17)
    public void test17_getCategoriesNoToken() {
        System.out.println("\n[TEST 5.2] Get Quiz Categories (No Token)");
        Response response = RestAssured.given()
                .get(BASE_URL + "/quizzes/categories");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 401, "Expected status 401");
    }

    @Test(priority = 18)
    public void test18_getCategoriesContainsExpected() {
        System.out.println("\n[TEST 5.3] Categories Contains Expected Value");
        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + studentToken)
                .get(BASE_URL + "/quizzes/categories");

        Assert.assertEquals(response.getStatusCode(), 200);
        List<String> categories = response.jsonPath().getList("categories");
        Assert.assertTrue(categories.contains("Java_Maven_Cat"), "Expected 'Java_Maven_Cat' to be in categories list");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    //  API 6 — GET /api/results/quiz/:quizId
    // ═══════════════════════════════════════════════════════════════════════════════

    @Test(priority = 19)
    public void test19_submitResultSetup() {
        System.out.println("\n[SETUP] Submit Quiz Result for query");
        
        Map<String, Object> answer1 = new HashMap<>();
        answer1.put("questionIndex", 0);
        answer1.put("selectedOption", 3);

        Map<String, Object> resultPayload = new HashMap<>();
        resultPayload.put("quizId", quizId);
        resultPayload.put("answers", List.of(answer1));

        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + studentToken)
                .contentType("application/json")
                .body(resultPayload)
                .post(BASE_URL + "/results");

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 201, "Expected status 201 for result submission");
    }

    @Test(priority = 20)
    public void test20_getQuizResultsTeacher() {
        System.out.println("\n[TEST 6.1] Get Quiz Results (Teacher)");
        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + teacherToken)
                .get(BASE_URL + "/results/quiz/" + quizId);

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 200, "Expected status 200 for teacher");
        Assert.assertTrue(response.jsonPath().getBoolean("success"), "Expected success to be true");
        Assert.assertNotNull(response.jsonPath().getList("results"), "Expected results list");
        Assert.assertTrue(response.jsonPath().getInt("count") >= 1, "Expected count to be at least 1");
    }

    @Test(priority = 21)
    public void test21_getQuizResultsStudentForbidden() {
        System.out.println("\n[TEST 6.2] Get Quiz Results (Student — Forbidden)");
        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + studentToken)
                .get(BASE_URL + "/results/quiz/" + quizId);

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 403, "Expected status 403 for student");
    }

    @Test(priority = 22)
    public void test22_getQuizResultsNoToken() {
        System.out.println("\n[TEST 6.3] Get Quiz Results (No Token)");
        Response response = RestAssured.given()
                .get(BASE_URL + "/results/quiz/" + quizId);

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 401, "Expected status 401 for no token");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    //  CLEANUP
    // ═══════════════════════════════════════════════════════════════════════════════

    @Test(priority = 23)
    public void test23_cleanupQuiz() {
        System.out.println("\n[CLEANUP] Delete Test Quiz");
        if (quizId == null || quizId.isEmpty()) {
            System.out.println("  No quiz to clean up");
            return;
        }
        Response response = RestAssured.given()
                .header("Authorization", "Bearer " + teacherToken)
                .delete(BASE_URL + "/quizzes/" + quizId);

        System.out.println("  Status: " + response.getStatusCode());
        Assert.assertEquals(response.getStatusCode(), 200, "Expected status 200 for successful deletion");
    }
}
