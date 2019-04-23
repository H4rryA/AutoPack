var express = require('express'),
  app = express(),
  port = process.env.PORT || 3000,
  mongoose = require('mongoose'),
  Task = require('./api/models/itemModel'),
  bodyParser = require('body-parser');

mongoose.Promise = global.Promise
mongoose.connect('mongodb://localhost/itemsdb');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

var routes = require('./api/routes/itemRoutes');
routes(app);

app.listen(port);

console.log('item RESTful API server started on: ' + port);

app.use(function(req, res) {
  res.status(404).send({url: req.originalUrl + ' not found'})
});
