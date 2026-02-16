const { Queue, Worker } = require('bullmq');
const redis = require('../../config/redis');
const nodemailer = require('nodemailer');
const User = require('../auth/auth.model');
const Notification = require('./notifications.model');

// Email Transporter
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.mailtrap.io',
  port: process.env.SMTP_PORT || 2525,
  auth: {
    user: process.env.SMTP_USER || 'user',
    pass: process.env.SMTP_PASS || 'pass',
  },
});

// Queue
const notificationQueue = new Queue('notifications', { connection: redis });

// Worker
const worker = new Worker('notifications', async (job) => {
  console.log('Processing notification job:', job.id);
  const { title, description } = job.data;

  try {
    // 1. Fetch Admins and All Users
    const admins = await User.findAll({ where: { role: 'admin' } });
    const users = await User.findAll({ where: { role: 'user' } });

    // 2. Notify Admins (Email + DB)
    for (const admin of admins) {
      // Send Email
      try {
          await transporter.sendMail({
            from: '"Complaint App" <no-reply@complaintapp.com>',
            to: admin.email,
            subject: `New Complaint: ${title}`,
            text: `A new complaint has been filed.\n\nTitle: ${title}\nDescription: ${description}`,
          });
          console.log(`Email sent to admin: ${admin.email}`);
      } catch (e) {
          console.error(`Failed to send email to ${admin.email}`, e);
      }

      // DB Notification
      await Notification.create({
        userId: admin.id,
        message: `New Complaint Posted: ${title}`,
        type: 'info'
      });
    }

    // 3. Notify All Users (DB Only)
    for (const user of users) {
       await Notification.create({
        userId: user.id,
        message: `New Complaint Posted: ${title}`,
        type: 'info'
      });
    }
  } catch (error) {
    console.error('Error processing notification job:', error);
    throw error;
  }

}, { connection: redis });

const addNotificationJob = async (data) => {
  await notificationQueue.add('new-complaint', data);
};

module.exports = { addNotificationJob };
