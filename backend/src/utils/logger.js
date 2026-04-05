const { createLogger, format, transports } = require('winston');
const { combine, timestamp, errors, json, colorize, printf } = format;

const isProduction = process.env.NODE_ENV === 'production';

/**
 * Development format — human-readable colored output in terminal
 */
const devFormat = combine(
  colorize(),
  timestamp({ format: 'HH:mm:ss' }),
  errors({ stack: true }),
  printf(({ level, message, timestamp, stack, ...meta }) => {
    const metaStr = Object.keys(meta).length ? `\n${JSON.stringify(meta, null, 2)}` : '';
    return `${timestamp} [${level}]: ${message}${stack ? `\n${stack}` : ''}${metaStr}`;
  })
);

/**
 * Production format — structured JSON, one line per log entry
 * Queryable by Datadog, CloudWatch, Grafana, etc.
 */
const prodFormat = combine(
  timestamp(),
  errors({ stack: true }),
  json()
);

const logger = createLogger({
  level: isProduction ? 'warn' : 'debug',
  format: isProduction ? prodFormat : devFormat,
  defaultMeta: { service: 'auth-service' },
  transports: [
    new transports.File({
      filename: 'logs/error.log',
      level: 'error',
      // Rotate logs — requires winston-daily-rotate-file in production
    }),
    new transports.File({ filename: 'logs/combined.log' }),
  ],
  exitOnError: false, // Don't crash on logger errors
});

// In development, also output to console
if (!isProduction) {
  logger.add(new transports.Console());
}

module.exports = logger;