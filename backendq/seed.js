const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');

dotenv.config();

const User = require('./models/User');
const Quiz = require('./models/Quiz');
const Result = require('./models/Result');

const connectDB = async () => {
  await mongoose.connect(process.env.MONGO_URI);
  console.log('✅ MongoDB connected for seeding');
};

const seedData = async () => {
  await connectDB();

  // Clear existing data
  await User.deleteMany();
  await Quiz.deleteMany();
  await Result.deleteMany();
  console.log('🗑️  Cleared existing data');

  // Create users
  const password = 'password123';

  const teacher = await User.create({
    name: 'Prof. Arjun Sharma',
    email: 'teacher@quiz.com',
    password,
    role: 'teacher',
  });

  const student1 = await User.create({
    name: 'Rahul Mehta',
    email: 'student1@quiz.com',
    password,
    role: 'student',
  });

  const student2 = await User.create({
    name: 'Priya Patel',
    email: 'student2@quiz.com',
    password,
    role: 'student',
  });

  console.log('👥 Created users: teacher + 2 students');

  // --- General Knowledge Quiz ---
  const gkQuiz = await Quiz.create({
    title: 'General Knowledge Basics',
    category: 'General Knowledge',
    description: 'Test your general knowledge with these fundamental questions.',
    createdBy: teacher._id,
    timePerQuestion: 30,
    questions: [
      {
        questionText: 'What is the capital of India?',
        options: ['Mumbai', 'New Delhi', 'Kolkata', 'Chennai'],
        correctOption: 1,
        explanation: 'New Delhi is the capital of India.',
      },
      {
        questionText: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Jupiter', 'Mars', 'Saturn'],
        correctOption: 2,
        explanation: 'Mars is called the Red Planet due to its reddish appearance.',
      },
      {
        questionText: 'Who wrote the national anthem of India?',
        options: ['Mahatma Gandhi', 'Rabindranath Tagore', 'Jawaharlal Nehru', 'Subhash Chandra Bose'],
        correctOption: 1,
        explanation: 'Rabindranath Tagore wrote Jana Gana Mana.',
      },
      {
        questionText: 'How many days are in a leap year?',
        options: ['365', '366', '367', '364'],
        correctOption: 1,
        explanation: 'A leap year has 366 days.',
      },
      {
        questionText: 'Which is the largest ocean on Earth?',
        options: ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean', 'Pacific Ocean'],
        correctOption: 3,
        explanation: 'The Pacific Ocean is the largest and deepest ocean.',
      },
    ],
  });

  // --- Science Quiz ---
  const scienceQuiz = await Quiz.create({
    title: 'Science Fundamentals',
    category: 'Science',
    description: 'Explore the basics of physics, chemistry, and biology.',
    createdBy: teacher._id,
    timePerQuestion: 30,
    questions: [
      {
        questionText: 'What is the chemical symbol for water?',
        options: ['O2', 'H2O', 'CO2', 'NaCl'],
        correctOption: 1,
        explanation: 'Water is composed of 2 hydrogen and 1 oxygen atom: H2O.',
      },
      {
        questionText: 'What is the speed of light in vacuum?',
        options: ['3×10⁸ m/s', '3×10⁶ m/s', '3×10⁴ m/s', '3×10¹⁰ m/s'],
        correctOption: 0,
        explanation: 'The speed of light is approximately 3×10⁸ metres per second.',
      },
      {
        questionText: 'Which gas do plants absorb during photosynthesis?',
        options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
        correctOption: 2,
        explanation: 'Plants absorb CO₂ and release O₂ during photosynthesis.',
      },
      {
        questionText: 'What is the powerhouse of the cell?',
        options: ['Nucleus', 'Ribosome', 'Golgi Body', 'Mitochondria'],
        correctOption: 3,
        explanation: 'Mitochondria produce ATP, the energy currency of the cell.',
      },
      {
        questionText: 'Newton\'s second law states that Force equals?',
        options: ['Mass × Acceleration', 'Mass × Velocity', 'Weight × Distance', 'Speed × Time'],
        correctOption: 0,
        explanation: 'F = ma is Newton\'s second law of motion.',
      },
    ],
  });

  // --- Mathematics Quiz ---
  const mathQuiz = await Quiz.create({
    title: 'Mathematics Challenge',
    category: 'Mathematics',
    description: 'Put your math skills to the test!',
    createdBy: teacher._id,
    timePerQuestion: 35,
    questions: [
      {
        questionText: 'What is √144?',
        options: ['10', '11', '12', '13'],
        correctOption: 2,
        explanation: '√144 = 12 because 12 × 12 = 144.',
      },
      {
        questionText: 'What is the value of π (pi) approximately?',
        options: ['2.14', '3.14', '4.14', '1.14'],
        correctOption: 1,
        explanation: 'Pi (π) is approximately 3.14159.',
      },
      {
        questionText: 'If 2x + 4 = 10, what is x?',
        options: ['2', '3', '4', '5'],
        correctOption: 1,
        explanation: '2x = 6, so x = 3.',
      },
      {
        questionText: 'What is the area of a circle with radius 7? (use π = 22/7)',
        options: ['154', '144', '164', '174'],
        correctOption: 0,
        explanation: 'Area = π × r² = (22/7) × 49 = 154 sq units.',
      },
      {
        questionText: 'How many sides does a hexagon have?',
        options: ['5', '6', '7', '8'],
        correctOption: 1,
        explanation: 'A hexagon has 6 sides.',
      },
    ],
  });

  // --- Computer Science Quiz ---
  const csQuiz = await Quiz.create({
    title: 'Computer Science Basics',
    category: 'Computer Science',
    description: 'Fundamentals of CS for engineering students.',
    createdBy: teacher._id,
    timePerQuestion: 30,
    questions: [
      {
        questionText: 'What does CPU stand for?',
        options: ['Central Process Unit', 'Central Processing Unit', 'Computer Processing Unit', 'Core Processing Unit'],
        correctOption: 1,
        explanation: 'CPU stands for Central Processing Unit.',
      },
      {
        questionText: 'Which data structure uses LIFO order?',
        options: ['Queue', 'Array', 'Stack', 'Linked List'],
        correctOption: 2,
        explanation: 'Stack uses Last In, First Out (LIFO) order.',
      },
      {
        questionText: 'What is 0 XOR 1?',
        options: ['0', '1', '2', 'undefined'],
        correctOption: 1,
        explanation: 'XOR returns 1 when bits are different.',
      },
      {
        questionText: 'Which language is used to style web pages?',
        options: ['HTML', 'JavaScript', 'Python', 'CSS'],
        correctOption: 3,
        explanation: 'CSS (Cascading Style Sheets) is used for styling.',
      },
      {
        questionText: 'What is the binary representation of decimal 10?',
        options: ['1010', '1001', '1100', '0110'],
        correctOption: 0,
        explanation: '10 in binary is 1010 (8+2).',
      },
    ],
  });

  console.log('📚 Created 4 quizzes: GK, Science, Mathematics, Computer Science');
  console.log('\n✅ Seeding complete! Login credentials:');
  console.log('   Teacher: teacher@quiz.com / password123');
  console.log('   Student: student1@quiz.com / password123');
  console.log('   Student: student2@quiz.com / password123');

  process.exit(0);
};

seedData().catch((err) => {
  console.error('❌ Seed error:', err);
  process.exit(1);
});
