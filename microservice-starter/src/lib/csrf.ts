import { Elysia } from 'elysia';

export const csrf = new Elysia().onBeforeHandle(({ request, set }) => {
  // Example: Check for a custom CSRF token header
  const csrfToken = request.headers.get('x-csrf-token');

  // Replace 'expected-secret-token' with your real logic
  if (!csrfToken || csrfToken !== 'expected-secret-token') {
    set.status = 403;
    return 'Invalid CSRF token';
  }

  // If valid, just let it continue
});
