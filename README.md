# Quiz App — STQA Major Project

A full-stack Quiz application designed and configured to demonstrate comprehensive Software Testing and Quality Assurance (STQA) practices, including E2E UI testing, API testing, load testing, and continuous integration/continuous deployment (CI/CD) pipelines with Jenkins.

🚀 Key Features & Flow Coverage
The project implements and tests critical application flows across all testing frameworks (Cypress, Selenium, and JMeter):

### 1. Selenium + TestNG E2E & API Flows (Java / Maven)
- **POST /api/auth/register** — Registers new student and teacher accounts, validating field presence and duplicate email constraints.
- **POST /api/auth/login** — Validates login credentials (success, wrong password, nonexistent accounts).
- **GET /api/auth/me** — Verifies current session context extraction using JWT authentication headers.
- **PUT /api/auth/profile** — Edits user profile metadata and validates unique constraints.
- **GET /api/quizzes/categories** — Validates category catalog retrieval and content checks.
- **GET /api/results/quiz/:quizId** — Verifies role-based access control (teachers allowed, students forbidden).
- **E2E UI Verification** — Automates headless browser navigation, checks for the presence of the Flutter Canvas engine in the page DOM, and captures UI screenshots.

### 2. Cypress End-to-End API Flows (JavaScript)
- **POST /api/quizzes** — Teacher quiz creation and role-based student/unauthenticated denial.
- **GET /api/quizzes** — Retrieves the complete quiz list with category filtering checks.
- **GET /api/quizzes/:id** — Fetches specific quiz structures by ID and handles nonexistent parameters.
- **PUT /api/quizzes/:id** — Modifies quiz parameters and validates permission scopes.
- **DELETE /api/quizzes/:id** — Deletes quiz records permanently.
- **GET /api/quizzes/teacher/mine** — Fetches teacher-specific quiz catalogs.

### 3. JMeter Performance & Load Tests (API Threads)
1. **POST /api/results** — Submits finished quiz score configurations under load.
2. **GET /api/results/my** — High-concurrency retrieval of a student's scoring history.
3. **POST /api/auth/register** — Performs load testing of new user registration.
4. **POST /api/auth/login** — Performs load testing of user authentication.
5. **GET /api/auth/me** — Verifies current profile verification latency under concurrent load.
6. **PUT /api/auth/profile** — Verifies profile update latency under concurrent load.

---

## 🛠️ Technology Stack
- **Backend**: Node.js, Express.js, MongoDB (Mongoose ODM)
- **Frontend**: Flutter Web (CanvasKit/HTML5 Render Engine)
- **E2E UI & API Testing**: Cypress (JavaScript), Selenium WebDriver (Java + TestNG + Maven)
- **API Load Testing**: Apache JMeter
- **CI/CD Pipeline**: Jenkins (Declarative pipelines running on port 8082 with automated build triggers)

---

## 📁 Project Directory Structure
```
quizapp-stqa/
├── backendq/               # Node.js/Express Backend API Source Code
│   ├── models/             # Mongoose Models (User.js, Quiz.js, Result.js)
│   ├── routes/             # Express API Routes (auth.js, quiz.js, result.js)
│   ├── middleware/         # JWT Auth & Role Authorization
│   ├── config/             # DB Connection Config
│   ├── server.js           # Server Entry Point
│   └── package.json
├── frontendq/              # Flutter Web Frontend Application Source Code
│   ├── lib/                # Flutter Dart Components
│   └── web/                # Flutter Web Entry Assets (index.html)
├── selenium-java/          # Selenium + TestNG E2E UI & API Tests (Maven)
│   ├── pom.xml             # Maven Project Config & Dependencies
│   ├── Jenkinsfile         # Jenkins Declarative Pipeline for Selenium
│   └── src/
│       └── test/java/com/quizapp/
│           ├── BaseTest.java
│           ├── ApiTests.java
│           └── UiTests.java
├── Test/                   # Cypress & JMeter Test Suites
│   ├── Jenkinsfile         # Jenkins Declarative Pipeline for Cypress
│   ├── cypress.config.js   # Cypress Configurations
│   ├── cypress_test.cy.js  # Cypress Spec File (25 E2E cases)
│   ├── jmeter_test.jmx     # Apache JMeter Load Test Configuration (128 samples)
│   └── jmeter_results.jtl  # JMeter Test Run Logs
└── screenshots/            # Committed Test Dashboard Evidence & Runs
    ├── cypress/            # Cypress Spec Run Screenshots
    ├── jenkins/            # Jenkins Pipeline runs and TestNG Trend Dashboards
    └── jmeter/             # JMeter Load Test Reports
```

---

## 📋 Prerequisites
Ensure you have the following installed on your local machine:

### 1. Verification Commands
Check if you already have the prerequisites installed:
```bash
node -v          # Expected: v18+
npm -v           # Expected: v9+
java -version    # Expected: JDK 17+ (JDK 25 used in this setup)
mvn -v           # Expected: Maven 3.9+
jmeter -v        # Expected: JMeter 5.4+
```

### 2. macOS Installation Guide (using Homebrew)
If any dependency is missing, you can install it using Homebrew:

**Node.js & NPM**:
```bash
brew install node
```

**MongoDB Community Edition**:
```bash
brew tap mongodb/brew
brew install mongodb-community@8.0
brew services start mongodb-community
```

**Java Development Kit & Maven**:
```bash
brew install openjdk
# Follow brew instructions to symlink openjdk and export JAVA_HOME
brew install maven
```

**Apache JMeter**:
```bash
brew install jmeter
```

---

## ⚙️ Installation & Local Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/meet-gagan/STQA_MAJOR_PROJECT.git
   cd STQA_MAJOR_PROJECT
   ```

2. **Configure and Run Express Backend**:
   ```bash
   cd backendq
   npm install
   # Make sure MongoDB is running locally on port 27017
   npm start
   ```
   *The backend will run on `http://localhost:5001`.*

3. **Run Flutter Frontend**:
   ```bash
   cd ../frontendq
   flutter pub get
   flutter run -d chrome --web-port=8080
   ```
   *The frontend will run on `http://localhost:8080`.*

---

## 🧪 Running the Tests

### 1. Git Pre-Push Hook (Automated Verification)
A Git pre-push hook is installed at `.git/hooks/pre-push`. Every time you run `git push`, the hook will execute `mvn clean test` in the `selenium-java` directory. If any test fails, the push is aborted automatically.

To run Maven tests locally manually:
```bash
cd selenium-java
JAVA_HOME=/opt/homebrew/Cellar/openjdk/25.0.2/libexec/openjdk.jdk/Contents/Home mvn clean test
```

### 2. Cypress API Test Suite
Cypress tests execute full E2E API flows on the running backend server.
To execute Cypress tests headless:
```bash
cd Test
npx cypress run --spec cypress_test.cy.js
```

### 3. JMeter Load Testing
To run the load testing suite:
```bash
# Run headless and generate the report dashboard
jmeter -n -t Test/jmeter_test.jmx -l Test/jmeter_results.jtl -e -o Test/jmeter_report
```

---

## 🔗 Jenkins CI/CD Pipeline Setup

The project implements automated builds in **Jenkins** running on port **8082**:

- **Automated Webhook & Polling Triggers**:
  - `githubPush()`: Configured to automatically trigger pipeline execution when new commits are pushed to the GitHub repository.
  - `pollSCM('*/2 * * * *')`: Fallback polling checks the remote repository every 2 minutes. This enables automatic builds locally without requiring a public IP hook tunnel.
- **Post-Build Action**: Calls the `testNG()` publisher inside the pipeline to compile results and display execution trend graphs on the project dashboard.

---

## 📸 Test Results & Screenshots Location

Evidence of successful local and Jenkins test executions are tracked and committed under the [screenshots/](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots) directory:

### 🌲 Cypress E2E Spec Runs
- [Cypress Spec Run Screenshot](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/cypress/cypress_run.png) — Captures local headed spec runner results (25 passing E2E tests).
- [Cypress Job Build Triggers Config](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/jenkins/cypress_build_triggers.png) — Webhook and polling configuration for the Cypress pipeline.

### 📊 JMeter API Performance Logs
- [JMeter HTML Dashboard Screenshot](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/jmeter/jmeter_dashboard.png) — High-concurrency statistics summary report showing 100% PASS rate.

### ☸️ Jenkins Pipeline & TestNG Reports
- [Jenkins Server Dashboard Overview](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/jenkins/jenkins_dashboard.png) — Displays active pipeline job statuses.
- [Selenium Job Dashboard and Trend Graph](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/jenkins/selenium_job_dashboard.png) — Overview of builds showing the TestNG results chart widget.
- [TestNG Results Trend Graph](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/jenkins/testng_trend_graph.png) — Aggregated pass/fail statistics across successful pipeline runs.
- [TestNG Detailed Success Rates](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/jenkins/testng_detailed_results.png) — Execution list breakdown for individual test cases.
- [Selenium Build Triggers Config](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/jenkins/selenium_build_triggers.png) — Verified webhook and polling triggers settings page.
- [Cypress Build Triggers Config](file:///Users/gagannagu/Desktop/quizapp%206%20test/screenshots/jenkins/cypress_build_triggers.png) — Webhook and polling configuration for the Cypress pipeline.