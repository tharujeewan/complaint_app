const redis = require('./src/config/redis');
const { Queue } = require('bullmq');

console.log('Verifying Notification System Setup...');

async function verify() {
  try {
    // 1. Check Redis Connection
    console.log('Checking Redis connection...');
    await redis.ping();
    console.log('Redis connection successful.');

    // 2. Check Queue Initialization
    console.log('Initializing Queue...');
    const queue = new Queue('notifications', { connection: redis });
    console.log('Queue initialized successfully.');
    await queue.close();

    // 3. Check Modules Import
    console.log('Checking module imports...');
    console.log(' - importing notifications.model');
    require('./src/modules/notifications/notifications.model');
    console.log(' - importing notifications.service');
    require('./src/modules/notifications/notifications.service');
    console.log(' - importing notifications.controller');
    require('./src/modules/notifications/notifications.controller');
    console.log(' - importing notifications.route');
    require('./src/modules/notifications/notifications.route');
    console.log('All modules imported successfully.');

    console.log('VERIFICATION PASSED: System is ready.');
    process.exit(0);
  } catch (error) {
    console.error('VERIFICATION FAILED:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

verify();
