// src/server.js

require('dotenv').config(); // Load environment variables from .env
const app = require('./app'); // Import Express app

// Use port from .env or default to 5000
const PORT = process.env.PORT || 5000;

// Start the server
const sequelize = require('./config/db');

// Sync database and start server
sequelize.sync()
  .then(() => {
    console.log('✅ Database connected & synced');
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('❌ Database connection failed:', err);
  });
