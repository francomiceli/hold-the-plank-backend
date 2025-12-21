import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

interface UserAttributes {
  id: number;
  email: string;
  username: string | null;
  wallet_address: string | null;
  guild_id: number | null;
  balance_plank: number;
  aura_points: number;
  minutes_of_life_gained: number;
  is_active: boolean;
  created_at: Date;
}

interface UserCreationAttributes extends Optional<UserAttributes, 'id' | 'username' | 'wallet_address' | 'guild_id' | 'balance_plank' | 'aura_points' | 'minutes_of_life_gained' | 'is_active' | 'created_at'> {}

class User extends Model<UserAttributes, UserCreationAttributes> implements UserAttributes {
  public id!: number;
  public email!: string;
  public username!: string | null;
  public wallet_address!: string | null;
  public guild_id!: number | null;
  public balance_plank!: number;
  public aura_points!: number;
  public minutes_of_life_gained!: number;
  public is_active!: boolean;
  public created_at!: Date;
}

User.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
    },
    username: {
      type: DataTypes.STRING(255),
      allowNull: true,
      unique: true,
    },
    wallet_address: {
      type: DataTypes.STRING(255),
      allowNull: true,
      unique: true,
    },
    guild_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    balance_plank: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0,
    },
    aura_points: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    minutes_of_life_gained: {
      type: DataTypes.FLOAT,
      defaultValue: 0,
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    tableName: 'users',
    timestamps: false,
  }
);

export default User;