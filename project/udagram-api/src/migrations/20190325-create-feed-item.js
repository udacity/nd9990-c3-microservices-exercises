'use strict';
module.exports = {
  up: (queryInterface, Sequelize): queryInterface => {
    return queryInterface.createTable('FeedItem', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER,
      },
      caption: {
        type: Sequelize.STRING,
      },
      url: {
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
    return queryInterface.dropTable('FeedItem');
  },
};
