const { DataTypes } = require('sequelize');
const sequelize = require('../../config/db');

/**
 * RefreshToken model
 *
 * Why this exists:
 * Without persisting refresh tokens, they cannot be revoked.
 * A stolen token would give an attacker indefinite access until expiry.
 *
 * With this table:
 * - Logout revokes the token immediately (sets revoked = true)
 * - Logout-all revokes every token for a user in one query
 * - Token rotation: on each refresh, old token is revoked and a new pair is issued
 * - If a revoked token is reused → possible token theft → revoke all user tokens
 *
 * onDelete: CASCADE ensures tokens are cleaned up when a user is deleted.
 */
const RefreshToken = sequelize.define(
  'RefreshToken',
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    token: {
      type: DataTypes.TEXT,
      allowNull: false,
      unique: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'user_id',
      references: {
        model: 'users',
        key: 'id',
      },
      onDelete: 'CASCADE',
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false,
      field: 'expires_at',
    },
    revoked: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    },
  },
  {
    tableName: 'refresh_tokens',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  }
);

module.exports = RefreshToken;