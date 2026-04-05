const { DataTypes } = require('sequelize');
const sequelize = require('../../config/db');

/**
 * User model
 *
 * defaultScope excludes password on every query automatically.
 * Use User.scope('withPassword') explicitly only where the hash
 * is needed (login, password change verification).
 *
 * status field enables admin ban/unban — banned users are rejected
 * in protect middleware even if they hold a valid JWT.
 */
const User = sequelize.define(
  'User',
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: { msg: 'Name cannot be empty' },
        len: { args: [3, 100], msg: 'Name must be between 3 and 100 characters' },
      },
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: { msg: 'Email already registered' },
      validate: {
        isEmail: { msg: 'Must be a valid email address' },
        notEmpty: { msg: 'Email cannot be empty' },
      },
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    role: {
      type: DataTypes.ENUM('user', 'admin'),
      defaultValue: 'user',
      allowNull: false,
    },
    // Enables admin ban/unban without deleting the account
    status: {
      type: DataTypes.ENUM('active', 'banned'),
      defaultValue: 'active',
      allowNull: false,
    },
  },
  {
    tableName: 'users',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    defaultScope: {
      attributes: { exclude: ['password'] },
    },
    scopes: {
      withPassword: {
        attributes: { include: ['password'] },
      },
    },
  }
);

module.exports = User;