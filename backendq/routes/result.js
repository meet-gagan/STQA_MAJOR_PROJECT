const express = require('express');
const router = express.Router();
const Result = require('../models/Result');
const Quiz = require('../models/Quiz');
const { protect, teacherOnly } = require('../middleware/auth');

// @route   POST /api/results
// @desc    Submit quiz result
// @access  Private (Student)
router.post('/', protect, async (req, res) => {
  try {
    const { quizId, answers } = req.body;

    const quiz = await Quiz.findById(quizId);
    if (!quiz) {
      return res.status(404).json({ success: false, message: 'Quiz not found' });
    }

    // Calculate score
    let correctAnswers = 0;
    let wrongAnswers = 0;
    let skippedAnswers = 0;
    const evaluatedAnswers = [];

    quiz.questions.forEach((question, index) => {
      const submitted = answers.find((a) => a.questionIndex === index);
      if (!submitted || submitted.selectedOption === -1) {
        skippedAnswers++;
        evaluatedAnswers.push({ questionIndex: index, selectedOption: -1, isCorrect: false });
      } else {
        const isCorrect = submitted.selectedOption === question.correctOption;
        if (isCorrect) correctAnswers++;
        else wrongAnswers++;
        evaluatedAnswers.push({
          questionIndex: index,
          selectedOption: submitted.selectedOption,
          isCorrect,
        });
      }
    });

    const totalQuestions = quiz.questions.length;
    const score = Math.round((correctAnswers / totalQuestions) * 100);

    const result = await Result.create({
      student: req.user._id,
      quiz: quizId,
      score,
      totalQuestions,
      correctAnswers,
      wrongAnswers,
      skippedAnswers,
      answers: evaluatedAnswers,
    });

    res.status(201).json({ success: true, result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/results/my
// @desc    Get current student's results
// @access  Private
router.get('/my', protect, async (req, res) => {
  try {
    const results = await Result.find({ student: req.user._id })
      .populate('quiz', 'title category')
      .sort({ completedAt: -1 });
    res.json({ success: true, count: results.length, results });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/results/quiz/:quizId
// @desc    Get all results for a specific quiz (Teacher view)
// @access  Private (Teacher)
router.get('/quiz/:quizId', protect, teacherOnly, async (req, res) => {
  try {
    const results = await Result.find({ quiz: req.params.quizId })
      .populate('student', 'name email')
      .sort({ completedAt: -1 });
    res.json({ success: true, count: results.length, results });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
