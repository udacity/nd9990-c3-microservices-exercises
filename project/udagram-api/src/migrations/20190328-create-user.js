'use strict';
module.exports = {
  up: (queryInterface, Sequelize): queryInterface => {
    return queryInterface.createTable('User', {
      id: {
        allowNull: false,
        autoIncrement: true,
        type: Sequelize.INTEGER,
      },
      email: {
        type: Sequelize.STRING,
        primaryKey: true,
      },
      passwordHash: {
        type: Sequelize.STRING,
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE,
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE,
      },
    });
  },
  down: (queryInterface): queryInterface => {
    return queryInterface.dropTable('User');
  },
};
