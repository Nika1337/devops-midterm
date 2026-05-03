const express = require('express');

const app = express();
const tasks = [];

app.use(express.urlencoded({ extended: false }));
app.use(express.json());

app.get('/', (req, res) => {
  const taskItems = tasks
    .map((task) => `<li><a href="/tasks/${task.id}">${task.title}</a></li>`)
    .join('');

  res.status(200).send(`
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>DevOps Tasks</title>
      </head>
      <body>
        <h1>DevOps Tasks</h1>
        <form action="/tasks" method="post">
          <label for="title">Task title</label>
          <input id="title" name="title" type="text" required>
          <button type="submit">Add task</button>
        </form>
        <h2>Current Tasks</h2>
        ${
          taskItems
            ? `<ul>${taskItems}</ul>`
            : '<p>No tasks added yet.</p>'
        }
      </body>
    </html>
  `);
});

app.post('/tasks', (req, res) => {
  const title = typeof req.body.title === 'string' ? req.body.title.trim() : '';

  if (!title) {
    return res.status(400).send(`
      <!doctype html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Task Error</title>
        </head>
        <body>
          <h1>Task title is required.</h1>
          <a href="/">Back to tasks</a>
        </body>
      </html>
    `);
  }

  const task = {
    id: String(tasks.length + 1),
    title,
    completed: false,
    createdAt: new Date().toISOString()
  };

  tasks.push(task);

  return res.redirect(303, '/');
});

app.get('/tasks/:id', (req, res) => {
  const task = tasks.find((item) => item.id === req.params.id);

  if (!task) {
    return res.status(404).send(`
      <!doctype html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Task Not Found</title>
        </head>
        <body>
          <h1>Task not found.</h1>
          <a href="/">Back to tasks</a>
        </body>
      </html>
    `);
  }

  return res.status(200).send(`
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>${task.title}</title>
      </head>
      <body>
        <h1>${task.title}</h1>
        <p>Status: ${task.completed ? 'Completed' : 'Not completed'}</p>
        <p>Created: ${task.createdAt}</p>
        <a href="/">Back to tasks</a>
      </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

module.exports = {
  app,
  tasks
};
