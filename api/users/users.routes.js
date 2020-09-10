var Users = require('./users.controller');

module.exports = function(router) {
  router.post('/users', Users.createUser);
  router.get('/users', Users.getUsers);
  router.get('/user/:name', Users.getUser);
  router.put('/user/:id', Users.updateUser);
  router.delete('/user/:id', Users.removeUser);
}
