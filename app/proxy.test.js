const { getTargetPort } = require('./proxy');

describe('blue-green proxy helpers', () => {
  test('returns blue port', () => {
    expect(getTargetPort('blue')).toBe(3001);
  });

  test('returns green port', () => {
    expect(getTargetPort('green')).toBe(3002);
  });

  test('returns null for invalid environment', () => {
    expect(getTargetPort('invalid')).toBeNull();
  });
});
