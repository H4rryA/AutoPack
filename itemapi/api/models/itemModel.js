'use strict';
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var ItemSchema = new Schema({
  name: {
    type: String,
    required: 'Name of the Item'
  },
  RFID: {
    type: String,
    required: 'RFID of Item'
  },
  status: {
    type: Number,
    default: 2
  }
});

module.exports = mongoose.model('Items', ItemSchema);
