import {Sequelize} from 'sequelize-typescript';
import {config} from './config/config';


export const sequelize = new Sequelize({
  'dialect': config.dialect,
  'username': config.username,
  'password': config.password,
  'database': config.database,
  'host': config.host,
  'storage': ':memory:',
});
