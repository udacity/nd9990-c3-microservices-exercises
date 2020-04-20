const { v4: uuidv4 } = require('uuid');
const express = require("express");
const app = express();

app.listen(8080, () => {
  console.log("Server running on port 8080");
});

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

app.get("/users/:username", (req, res, next) => {
  let username = req.params.username;
  let pid = uuidv4();

  console.log(new Date().toLocaleString() + `: ${pid} - User ${username} requested for resource`);
  sleep(Math.random() * 10000).then(() => {
    console.log(new Date().toLocaleString() + `: ${pid} - Finished processing request for ${username}`);
  })

  res.status(200).send;
});

