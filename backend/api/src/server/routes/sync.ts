import { Router } from 'express';

import { env } from '../config/env';
import { supabaseClient } from '../services/supabase_client';

const syncRouter = Router();

syncRouter.get('/status', async (_req, res, next) => {
  try {
    if (!supabaseClient) {
      res.status(503).json({ status: 'supabase_unconfigured' });
      return;
    }

    const { data, error } = await supabaseClient.from('songs').select('id').limit(1);

    if (error) {
      res.status(500).json({ status: 'error', message: error.message });
      return;
    }

    res.json({ status: 'ok', connected: Boolean(data) });
  } catch (error) {
    next(error);
  }
});

syncRouter.post('/queue', async (req, res, next) => {
  try {
    if (!supabaseClient) {
      res.status(503).json({ status: 'supabase_unconfigured' });
      return;
    }

    // Placeholder: accept queued mutations from clients.
    const { mutations } = req.body;
    if (!Array.isArray(mutations)) {
      res.status(400).json({ status: 'invalid_payload' });
      return;
    }

    res.status(202).json({ status: 'queued', count: mutations.length });
  } catch (error) {
    next(error);
  }
});

syncRouter.get('/config', (_req, res) => {
  res.json({
    supabaseUrl: env.supabaseUrl ?? null,
    hasServiceKey: Boolean(env.supabaseServiceRoleKey),
  });
});

export { syncRouter };
