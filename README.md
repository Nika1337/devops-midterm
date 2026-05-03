# DevOps Midterm Express App

A small beginner-friendly Node.js and Express web application for a DevOps assignment. The app stores tasks in memory and does not use a database.

## Tech Stack

- Node.js
- Express
- CommonJS JavaScript
- Jest
- Supertest
- ESLint
- GitHub Actions

## Project Structure

```text
app/
  app.js
  app.test.js
  server.js
deployments/
logs/
screenshots/
scripts/
.github/workflows/
  ci.yml
```

## Setup

Prepare the local environment:

```bash
bash scripts/setup.sh
```

This creates the required local folders, sets the default active environment to `blue`, and installs app dependencies.

You can also install dependencies manually:

```bash
cd app
npm install
```

Start the application:

```bash
cd app
npm start
```

Open the app at:

```text
http://localhost:3000
```

## Available Routes

| Method | Route | Description |
| --- | --- | --- |
| GET | `/` | Shows a simple task form |
| POST | `/tasks` | Creates a task in memory |
| GET | `/tasks/:id` | Gets one task by id |
| GET | `/health` | Returns application health status |

Example JSON request:

```bash
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Prepare DevOps assignment"}'
```

## Tests

Run automated tests:

```bash
cd app
npm test
```

## Linting

Run ESLint:

```bash
cd app
npm run lint
```

## CI Workflow

GitHub Actions runs linting and tests on every push and pull request.

```text
Push or Pull Request
        |
        v
GitHub Actions CI
        |
        v
Install dependencies
        |
        v
Run ESLint
        |
        v
Run Jest tests
```

## Deployment

Local blue-green deployment scripts will be added in the next assignment step.

Expected folder:

```text
deployments/
```

## Rollback

Rollback automation will be added after the local blue-green deployment simulation is implemented.

Expected folder:

```text
scripts/
```

## Monitoring

A health check monitoring script will be added later. It will call `/health` and write results to the `logs/` folder.

Expected folder:

```text
logs/
```

## Screenshots

Setup script success:

![Setup script success](screenshots/setup-success.png)

GitHub Actions run:

![GitHub Actions run](screenshots/github_actions_run.png)

More screenshots can be added later for the home page, health check, deployment, rollback, and monitoring steps.
