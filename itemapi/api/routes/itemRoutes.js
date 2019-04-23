'use strict';
module.exports = function(app) {
  var item = require('../controllers/itemController');

  app.route('/items')
    .get(item.listAllItems)
    .put(item.updateItem) 
    .delete(item.deleteItem);
  
  app.route('/addItem')
    .post(item.createItem)
};
