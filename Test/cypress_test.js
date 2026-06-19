/**
 * =============================================================================
 *  CYPRESS TEST SCRIPT — STQA (Software Testing & Quality Assurance)
 *  Quiz App — Online Quiz Application
 * =============================================================================
 *  APIs Under Test:
 *    1. POST   /api/quizzes            — Create a new quiz (Teacher only)
 *    2. GET    /api/quizzes            — Get all active quizzes
 *    3. GET    /api/quizzes/:id        — Get single quiz by ID
 *    4. PUT    /api/quizzes/:id        — Update a quiz (Teacher only)
 *    5. DELETE /api/quizzes/:id        — Delete a quiz (Teacher only)
 *    6. GET    /api/quizzes/teacher/mine — Get teacher's own quizzes
 * =============================================================================
 *  Prerequisites:
 *    - Node.js 16+
 *    - npm install cypress --save-dev   (inside Test/ folder)
 *    - Backend running on http://localhost:5001
 * =============================================================================
 *  How to Run:
 *    npx cypress run --spec "cypress_test.js"     (headless)
 *    npx cypress open                              (interactive)
 * =============================================================================
 */

const BASE_URL = "http://localhost:5001/api";

// Unique timestamp to avoid email conflicts
const TS = Date.now();
const TEACHER_USER = {
  name: `CypressTeacher_${TS}`,
  email: `cypress_teacher_${TS}@test.com`,
  password: "Teacher@123456",
  role: "teacher",
};
const STUDENT_USER = {
  name: `CypressStudent_${TS}`,
  email: `cypress_student_${TS}@test.com`,
  password: "Student@123456",
  role: "student",
};

let teacherToken = "";
let studentToken = "";
let createdQuizId = "";

// ═══════════════════════════════════════════════════════════════════════════════
//  SETUP — Register teacher and student accounts, obtain JWT tokens
// ═══════════════════════════════════════════════════════════════════════════════
describe("SETUP — Create Test Accounts", () => {
  it("Register a Teacher account", () => {
    cy.request("POST", `${BASE_URL}/auth/register`, TEACHER_USER).then((res) => {
      expect(res.status).to.eq(201);
      expect(res.body.success).to.be.true;
      expect(res.body.token).to.be.a("string");
      expect(res.body.user.role).to.eq("teacher");
      teacherToken = res.body.token;
      cy.log(`✅ Teacher registered — token: ${teacherToken.slice(0, 20)}...`);
    });
  });

  it("Register a Student account", () => {
    cy.request("POST", `${BASE_URL}/auth/register`, STUDENT_USER).then((res) => {
      expect(res.status).to.eq(201);
      expect(res.body.success).to.be.true;
      studentToken = res.body.token;
      cy.log(`✅ Student registered — token: ${studentToken.slice(0, 20)}...`);
    });
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  API 1 — POST /api/quizzes  (Create Quiz)
// ═══════════════════════════════════════════════════════════════════════════════
describe("API 1: POST /api/quizzes — Create Quiz", () => {
  const QUIZ_PAYLOAD = {
    title: `Cypress Test Quiz ${TS}`,
    category: "Science",
    description: "A quiz created by Cypress automated tests",
    timePerQuestion: 30,
    questions: [
      {
        questionText: "What is the chemical symbol for water?",
        options: ["H2O", "CO2", "NaCl", "O2"],
        correctOption: 0,
        explanation: "Water is H2O",
      },
      {
        questionText: "What planet is known as the Red Planet?",
        options: ["Venus", "Mars", "Jupiter", "Saturn"],
        correctOption: 1,
        explanation: "Mars is the Red Planet",
      },
    ],
  };

  it("TEST 1.1 — Teacher creates a quiz successfully (201)", () => {
    cy.request({
      method: "POST",
      url: `${BASE_URL}/quizzes`,
      headers: { Authorization: `Bearer ${teacherToken}` },
      body: QUIZ_PAYLOAD,
    }).then((res) => {
      expect(res.status).to.eq(201);
      expect(res.body.success).to.be.true;
      expect(res.body.quiz).to.have.property("_id");
      expect(res.body.quiz.title).to.eq(QUIZ_PAYLOAD.title);
      expect(res.body.quiz.category).to.eq("Science");
      expect(res.body.quiz.questions).to.have.length(2);
      createdQuizId = res.body.quiz._id;
      cy.log(`✅ Quiz created with ID: ${createdQuizId}`);
    });
  });

  it("TEST 1.2 — Student CANNOT create a quiz (403 Forbidden)", () => {
    cy.request({
      method: "POST",
      url: `${BASE_URL}/quizzes`,
      headers: { Authorization: `Bearer ${studentToken}` },
      body: QUIZ_PAYLOAD,
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(403);
      expect(res.body.success).to.be.false;
      cy.log("✅ Student correctly denied quiz creation");
    });
  });

  it("TEST 1.3 — Unauthenticated user CANNOT create a quiz (401)", () => {
    cy.request({
      method: "POST",
      url: `${BASE_URL}/quizzes`,
      body: QUIZ_PAYLOAD,
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(401);
      cy.log("✅ Unauthenticated request correctly rejected");
    });
  });

  it("TEST 1.4 — Create quiz with missing title (400/500 validation error)", () => {
    cy.request({
      method: "POST",
      url: `${BASE_URL}/quizzes`,
      headers: { Authorization: `Bearer ${teacherToken}` },
      body: { category: "Math" },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.be.oneOf([400, 500]);
      cy.log("✅ Missing title correctly caught");
    });
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  API 2 — GET /api/quizzes  (Get All Quizzes)
// ═══════════════════════════════════════════════════════════════════════════════
describe("API 2: GET /api/quizzes — Get All Quizzes", () => {
  it("TEST 2.1 — Authenticated user fetches all quizzes (200)", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes`,
      headers: { Authorization: `Bearer ${studentToken}` },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.be.true;
      expect(res.body.quizzes).to.be.an("array");
      expect(res.body.count).to.be.at.least(1);
      cy.log(`✅ Fetched ${res.body.count} quizzes`);
    });
  });

  it("TEST 2.2 — Filter quizzes by category 'Science' (200)", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes?category=Science`,
      headers: { Authorization: `Bearer ${studentToken}` },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.be.true;
      res.body.quizzes.forEach((q) => {
        expect(q.category).to.eq("Science");
      });
      cy.log(`✅ ${res.body.count} Science quizzes returned`);
    });
  });

  it("TEST 2.3 — Unauthenticated user CANNOT fetch quizzes (401)", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes`,
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(401);
      cy.log("✅ Unauthenticated request correctly rejected");
    });
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  API 3 — GET /api/quizzes/:id  (Get Single Quiz)
// ═══════════════════════════════════════════════════════════════════════════════
describe("API 3: GET /api/quizzes/:id — Get Single Quiz", () => {
  it("TEST 3.1 — Fetch single quiz by ID (200)", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes/${createdQuizId}`,
      headers: { Authorization: `Bearer ${studentToken}` },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.be.true;
      expect(res.body.quiz._id).to.eq(createdQuizId);
      expect(res.body.quiz.questions).to.have.length(2);
      expect(res.body.quiz.title).to.include("Cypress Test Quiz");
      cy.log(`✅ Quiz ${createdQuizId} fetched with full details`);
    });
  });

  it("TEST 3.2 — Fetch non-existent quiz returns 404/500", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes/000000000000000000000000`,
      headers: { Authorization: `Bearer ${studentToken}` },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.be.oneOf([404, 500]);
      cy.log("✅ Non-existent quiz correctly handled");
    });
  });

  it("TEST 3.3 — Fetch quiz without auth returns 401", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes/${createdQuizId}`,
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(401);
      cy.log("✅ Unauthenticated request correctly rejected");
    });
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  API 4 — PUT /api/quizzes/:id  (Update Quiz)
// ═══════════════════════════════════════════════════════════════════════════════
describe("API 4: PUT /api/quizzes/:id — Update Quiz", () => {
  it("TEST 4.1 — Teacher updates quiz title successfully (200)", () => {
    const updatedTitle = `Updated Cypress Quiz ${TS}`;
    cy.request({
      method: "PUT",
      url: `${BASE_URL}/quizzes/${createdQuizId}`,
      headers: { Authorization: `Bearer ${teacherToken}` },
      body: { title: updatedTitle },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.be.true;
      expect(res.body.quiz.title).to.eq(updatedTitle);
      cy.log(`✅ Quiz title updated to: ${updatedTitle}`);
    });
  });

  it("TEST 4.2 — Student CANNOT update a quiz (403)", () => {
    cy.request({
      method: "PUT",
      url: `${BASE_URL}/quizzes/${createdQuizId}`,
      headers: { Authorization: `Bearer ${studentToken}` },
      body: { title: "Hacked Quiz" },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(403);
      cy.log("✅ Student correctly denied quiz update");
    });
  });

  it("TEST 4.3 — Unauthenticated user CANNOT update a quiz (401)", () => {
    cy.request({
      method: "PUT",
      url: `${BASE_URL}/quizzes/${createdQuizId}`,
      body: { title: "Hacked Quiz" },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(401);
      cy.log("✅ Unauthenticated update correctly rejected");
    });
  });

  it("TEST 4.4 — Update non-existent quiz returns 404/500", () => {
    cy.request({
      method: "PUT",
      url: `${BASE_URL}/quizzes/000000000000000000000000`,
      headers: { Authorization: `Bearer ${teacherToken}` },
      body: { title: "Ghost Quiz" },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.be.oneOf([404, 500]);
      cy.log("✅ Non-existent quiz update correctly handled");
    });
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  API 5 — DELETE /api/quizzes/:id  (Delete Quiz)
// ═══════════════════════════════════════════════════════════════════════════════
describe("API 5: DELETE /api/quizzes/:id — Delete Quiz", () => {
  let quizToDeleteId = "";

  it("TEST 5.0 — Setup: Create a quiz to delete", () => {
    cy.request({
      method: "POST",
      url: `${BASE_URL}/quizzes`,
      headers: { Authorization: `Bearer ${teacherToken}` },
      body: {
        title: `Deletable Quiz ${TS}`,
        category: "Temp",
        description: "Quiz to be deleted",
        timePerQuestion: 15,
        questions: [
          {
            questionText: "Temp question?",
            options: ["A", "B", "C", "D"],
            correctOption: 0,
            explanation: "A is correct",
          },
        ],
      },
    }).then((res) => {
      expect(res.status).to.eq(201);
      quizToDeleteId = res.body.quiz._id;
      cy.log(`✅ Deletable quiz created: ${quizToDeleteId}`);
    });
  });

  it("TEST 5.1 — Student CANNOT delete a quiz (403)", () => {
    cy.request({
      method: "DELETE",
      url: `${BASE_URL}/quizzes/${quizToDeleteId}`,
      headers: { Authorization: `Bearer ${studentToken}` },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(403);
      cy.log("✅ Student correctly denied quiz deletion");
    });
  });

  it("TEST 5.2 — Unauthenticated user CANNOT delete a quiz (401)", () => {
    cy.request({
      method: "DELETE",
      url: `${BASE_URL}/quizzes/${quizToDeleteId}`,
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(401);
      cy.log("✅ Unauthenticated delete correctly rejected");
    });
  });

  it("TEST 5.3 — Teacher deletes own quiz successfully (200)", () => {
    cy.request({
      method: "DELETE",
      url: `${BASE_URL}/quizzes/${quizToDeleteId}`,
      headers: { Authorization: `Bearer ${teacherToken}` },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.be.true;
      cy.log("✅ Quiz deleted successfully");
    });
  });

  it("TEST 5.4 — Delete non-existent quiz returns 404/500", () => {
    cy.request({
      method: "DELETE",
      url: `${BASE_URL}/quizzes/000000000000000000000000`,
      headers: { Authorization: `Bearer ${teacherToken}` },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.be.oneOf([404, 500]);
      cy.log("✅ Non-existent quiz delete correctly handled");
    });
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  API 6 — GET /api/quizzes/teacher/mine  (Teacher's Own Quizzes)
// ═══════════════════════════════════════════════════════════════════════════════
describe("API 6: GET /api/quizzes/teacher/mine — Teacher's Quizzes", () => {
  it("TEST 6.1 — Teacher fetches own quizzes (200)", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes/teacher/mine`,
      headers: { Authorization: `Bearer ${teacherToken}` },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.be.true;
      expect(res.body.quizzes).to.be.an("array");
      expect(res.body.count).to.be.at.least(1);
      cy.log(`✅ Teacher has ${res.body.count} quizzes`);
    });
  });

  it("TEST 6.2 — Student CANNOT access teacher/mine (403)", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes/teacher/mine`,
      headers: { Authorization: `Bearer ${studentToken}` },
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(403);
      cy.log("✅ Student correctly denied teacher endpoint");
    });
  });

  it("TEST 6.3 — Unauthenticated user CANNOT access teacher/mine (401)", () => {
    cy.request({
      method: "GET",
      url: `${BASE_URL}/quizzes/teacher/mine`,
      failOnStatusCode: false,
    }).then((res) => {
      expect(res.status).to.eq(401);
      cy.log("✅ Unauthenticated request correctly rejected");
    });
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
//  CLEANUP — Delete the main test quiz
// ═══════════════════════════════════════════════════════════════════════════════
describe("CLEANUP — Delete Test Quiz", () => {
  it("Teacher deletes the created quiz", () => {
    cy.request({
      method: "DELETE",
      url: `${BASE_URL}/quizzes/${createdQuizId}`,
      headers: { Authorization: `Bearer ${teacherToken}` },
    }).then((res) => {
      expect(res.status).to.eq(200);
      expect(res.body.success).to.be.true;
      cy.log("✅ Test quiz cleaned up");
    });
  });
});
