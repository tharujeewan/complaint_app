// src/utils/logger.js
const { createLogger, transports, format } = require('winston');
const path = require('path');

const logger = createLogger({
  level: 'info', // Default log level
  format: format.combine(
    format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    format.errors({ stack: true }), // Include stack traces
    format.splat(),
    format.json() // Output as JSON for structured logs
  ),
  transports: [
    // Log errors to console (for dev)
    new transports.Console({ level: 'debug' }),
    // Log all info+ messages to a file
    new transports.File({ filename: path.join(__dirname, '../../logs/app.log') }),
  ],
  exitOnError: false, // Do not exit on handled exceptions
});

module.exports = logger;