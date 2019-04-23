'use strict';

var mongoose = require('mongoose'),
  Item = mongoose.model('Items');

exports.listAllItems = function(req, res) {
  Item.find({}, function(err, task) {
    if (err)
      res.send(err);
    res.json(task);
  });
};

exports.createItem = function(req, res) {
  var newItem = new Item(req.body);
  newItem.save(function(err, task) {
    if (err)
      res.send(err);
    res.json(task);
  });
};

exports.deleteItem = function(req, res) {
  Item.deleteOne({
    rfid: req.params.rfid
}, function(err, task) {
    if (err)
      res.send(err);
    res.json({ message: 'Item successfully deleted' });
  });
}

exports.updateItem = function(req, res) {
  Item.findOneAndUpdate({rfid: req.params.rfid}, req.body, {new: true}, function(err, task) {
    if (err)
      res.send(err);
    res.json(task);
  });
}