// src/middlewares/rateLimit.middleware.js
const rateLimit = require('express-rate-limit');
const { RedisStore } = require('rate-limit-redis');
const redisClient = require('../config/redis');
const AppError = require('../utils/AppError');

// Rate limiter for authentication routes (login/register)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 10, // Limit each IP to 10 auth requests per `window` (here, per 15 minutes)
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  store: new RedisStore({
    // @ts-expect-error - Known issue with the `rate-limit-redis` types
    sendCommand: (...args) => redisClient.call(...args),
  }),
  handler: (req, res, next) => {
    next(new AppError('Too many login attempts from this IP, please try again after 15 minutes', 429));
  },
});

module.exports = {
  authLimiter,
};
