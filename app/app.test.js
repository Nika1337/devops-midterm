const request = require('supertest');
const { app, tasks } = require('./app');

beforeEach(() => {
  tasks.length = 0;
});

describe('DevOps task app', () => {
  test('GET / returns the task form', async () => {
    const response = await request(app).get('/');

    expect(response.status).toBe(200);
    expect(response.text).toContain('DevOps Tasks');
    expect(response.text).toContain('action="/tasks"');
  });

  test('GET / shows current tasks', async () => {
    await request(app).post('/tasks').send({ title: 'Check task list' });

    const response = await request(app).get('/');

    expect(response.status).toBe(200);
    expect(response.text).toContain('Current Tasks');
    expect(response.text).toContain('Check task list');
    expect(response.text).toContain('href="/tasks/1"');
  });

  test('POST /tasks creates a task and redirects home', async () => {
    const response = await request(app)
      .post('/tasks')
      .send({ title: 'Write deployment script' });

    expect(response.status).toBe(303);
    expect(response.headers.location).toBe('/');
    expect(tasks[0]).toMatchObject({
      id: '1',
      title: 'Write deployment script',
      completed: false
    });
  });

  test('GET /tasks/:id returns a task by id', async () => {
    await request(app).post('/tasks').send({ title: 'Add health check' });

    const response = await request(app).get('/tasks/1');

    expect(response.status).toBe(200);
    expect(response.text).toContain('Add health check');
    expect(response.text).toContain('Status: Not completed');
    expect(response.text).toContain('Back to tasks');
  });

  test('GET /health returns ok status', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
  });
});
