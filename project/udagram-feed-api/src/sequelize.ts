import {Sequelize} from 'sequelize-typescript';
import { Dialect } from 'sequelize/types';
import {config} from './config/config';

export const sequelize = new Sequelize(
  config.database, config.username, config.password, {
    'host': config.host,
    'dialect': config.dialect as Dialect,
    'storage': ':memory:',
  }
);
