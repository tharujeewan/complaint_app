// src/config/createTables.js

// Load environment variables from .env file
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

// Import the database connection
const pool = require('./db');

// Function to create 'users' table
const createUsersTable = async () => {
  // SQL query to create table if it doesn't exist
  const query = `
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,                -- Auto-incrementing unique ID
      name VARCHAR(100) NOT NULL,          -- User's name
      email VARCHAR(150) UNIQUE NOT NULL,  -- User email must be unique
      password TEXT NOT NULL,              -- Hashed password
      role VARCHAR(20) DEFAULT 'user',     -- User role: user or admin
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp
    );
  `;
  // Execute the query
  await pool.query(query);
  console.log('✅ Users table created'); // Log success
};

// Function to create 'complaints' table
const createComplaintsTable = async () => {
  const query = `
    CREATE TABLE IF NOT EXISTS complaints (
      id SERIAL PRIMARY KEY,
      title VARCHAR(200) NOT NULL,
      description TEXT NOT NULL,
      status VARCHAR(30) DEFAULT 'pending',
      user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
      location VARCHAR(255),
      photo VARCHAR(255),  -- Store photo filename/path
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
  await pool.query(query);
  console.log('✅ Complaints table created with location & photo');
};


// Main function to create all tables
const createTables = async () => {
  try {
    await createUsersTable();       // Create users table
    await createComplaintsTable();  // Create complaints table
    console.log('🎉 All tables created successfully'); // Success message
    process.exit(0);                // Exit script
  } catch (error) {
    console.error('❌ Error creating tables:', error); // Error logging
    process.exit(1);               // Exit with failure
  }
};

// Run the function when the script is executed
createTables();
