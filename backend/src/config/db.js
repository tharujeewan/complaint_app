const { Sequelize } = require('sequelize');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

// Create a new Sequelize instance using environment variables
const sequelize = new Sequelize(
  process.env.DB_NAME,       // Database name
  process.env.DB_USER,       // DB username
  process.env.DB_PASSWORD,   // DB password
  {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',      // Using PostgreSQL
    logging: false,           // Disable SQL query logs in production
    pool: {
      max: 10,                // Maximum number of connections
      min: 0,                 // Minimum number of connections
      acquire: 30000,         // Max time (ms) to get connection
      idle: 10000             // Max idle time (ms)
    }
  }
);

module.exports = sequelize;
