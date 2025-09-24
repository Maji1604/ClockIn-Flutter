import { Elysia } from 'elysia';
import { checkinRoutes } from './routes/checkin';
import { breakRoutes } from './routes/break';
import { hrRequestRoutes } from './routes/hrRequest';
import { leaveRoutes } from './routes/leave';
import { holidaysRoutes } from './routes/holidays';
import { notificationRoutes } from './routes/notification';

const app = new Elysia()
  .use(checkinRoutes)
  .use(breakRoutes)
  .use(hrRequestRoutes)
  .use(leaveRoutes)
  .use(holidaysRoutes)
  .use(notificationRoutes);

export default app;
