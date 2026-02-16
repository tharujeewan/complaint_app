console.log('Starting minimal test...');
try {
  console.log('Requiring bullmq...');
  const { Queue, Worker } = require('bullmq');
  console.log('BullMQ required.', { Queue, Worker });

  console.log('Creating Queue...');
  const q = new Queue('test-queue', { connection: { host: 'localhost', port: 6379 } });
  console.log('Queue created.');
  
  // console.log('Creating Worker...');
  // const w = new Worker('test-queue', async ()=>{}, { connection: { host: 'localhost', port: 6379 } });
  // console.log('Worker created.');
} catch (e) {
  console.error('Error in minimal test:', e);
}
console.log('Finished minimal test.');
