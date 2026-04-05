const { DataTypes } = require('sequelize');
const sequelize = require('../../config/db');
const User = require('../auth/auth.model');

const Complaint = sequelize.define('Complaint', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  status: {
    type: DataTypes.STRING,
    defaultValue: 'pending'
  },
  location: {
    type: DataTypes.STRING
  },
  photo: {
    type: DataTypes.STRING
  },
  in_progress_at: {
    type: DataTypes.DATE,
    allowNull: true,
    defaultValue: null
  },
  resolved_at: {
    type: DataTypes.DATE,
    allowNull: true,
    defaultValue: null
  },
  user_id: {
    type: DataTypes.INTEGER,
    references: {
      model: User,
      key: 'id'
    }
  }
}, {
  tableName: 'complaints',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

// Associations
User.hasMany(Complaint, { foreignKey: 'user_id' });
Complaint.belongsTo(User, { foreignKey: 'user_id' });

module.exports = Complaint;
