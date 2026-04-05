const { Queue, Worker } = require('bullmq');
const redis = require('../../config/redis');
const nodemailer = require('nodemailer');
const User = require('../auth/auth.model');
const Notification = require('./notification.model');

// Email transporter
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.mailtrap.io',
  port: process.env.SMTP_PORT || 2525,
  auth: {
    user: process.env.SMTP_USER || 'user',
    pass: process.env.SMTP_PASS || 'pass',
  },
});

// BullMQ queue
const notificationQueue = new Queue('notifications', { connection: redis });

// BullMQ worker
const worker = new Worker('notifications', async (job) => {
  console.log('Processing notification job:', job.id);
  const { title, description } = job.data;

  try {
    const admins = await User.findAll({ where: { role: 'admin' } });
    const users = await User.findAll({ where: { role: 'user' } });

    // Notify admins (email + DB)
    for (const admin of admins) {
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

      await Notification.create({
        userId: admin.id,
        message: `New Complaint Posted: ${title}`,
        type: 'info'
      });
    }

    // Notify users (DB only)
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
