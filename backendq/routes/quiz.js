const express = require('express');
const router = express.Router();
const Quiz = require('../models/Quiz');
const { protect, teacherOnly } = require('../middleware/auth');

// @route   GET /api/quizzes
// @desc    Get all active quizzes (with optional category filter)
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const filter = { isActive: true };
    if (req.query.category) filter.category = req.query.category;

    const quizzes = await Quiz.find(filter)
      .populate('createdBy', 'name email')
      .select('-questions')
      .sort({ createdAt: -1 });

    res.json({ success: true, count: quizzes.length, quizzes });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/quizzes/categories
// @desc    Get distinct categories
// @access  Private
router.get('/categories', protect, async (req, res) => {
  try {
    const categories = await Quiz.distinct('category', { isActive: true });
    res.json({ success: true, categories });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/quizzes/teacher/mine
// @desc    Get all quizzes created by logged-in teacher
// @access  Private (Teacher)
router.get('/teacher/mine', protect, teacherOnly, async (req, res) => {
  try {
    const quizzes = await Quiz.find({ createdBy: req.user._id })
      .sort({ createdAt: -1 });
    res.json({ success: true, count: quizzes.length, quizzes });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   GET /api/quizzes/:id
// @desc    Get single quiz with all questions
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const quiz = await Quiz.findById(req.params.id).populate('createdBy', 'name email');
    if (!quiz) {
      return res.status(404).json({ success: false, message: 'Quiz not found' });
    }
    res.json({ success: true, quiz });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   POST /api/quizzes
// @desc    Create a new quiz
// @access  Private (Teacher only)
router.post('/', protect, teacherOnly, async (req, res) => {
  try {
    const { title, category, description, questions, timePerQuestion } = req.body;

    const quiz = await Quiz.create({
      title,
      category,
      description,
      questions,
      timePerQuestion: timePerQuestion || 30,
      createdBy: req.user._id,
    });

    res.status(201).json({ success: true, quiz });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   PUT /api/quizzes/:id
// @desc    Update a quiz
// @access  Private (Teacher — own quizzes only)
router.put('/:id', protect, teacherOnly, async (req, res) => {
  try {
    let quiz = await Quiz.findById(req.params.id);
    if (!quiz) {
      return res.status(404).json({ success: false, message: 'Quiz not found' });
    }

    // Make sure teacher owns the quiz
    if (quiz.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized to edit this quiz' });
    }

    quiz = await Quiz.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    res.json({ success: true, quiz });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// @route   DELETE /api/quizzes/:id
// @desc    Delete a quiz
// @access  Private (Teacher — own quizzes only)
router.delete('/:id', protect, teacherOnly, async (req, res) => {
  try {
    const quiz = await Quiz.findById(req.params.id);
    if (!quiz) {
      return res.status(404).json({ success: false, message: 'Quiz not found' });
    }

    if (quiz.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized to delete this quiz' });
    }

    await quiz.deleteOne();
    res.json({ success: true, message: 'Quiz deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
