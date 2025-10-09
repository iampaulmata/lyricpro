import { createClient } from '@supabase/supabase-js'
import type { SupabaseClient } from '@supabase/supabase-js'

import { env } from '../config/env'

let client: SupabaseClient | null = null

if (env.supabaseUrl && env.supabaseServiceRoleKey) {
  client = createClient(env.supabaseUrl, env.supabaseServiceRoleKey, {
    auth: {
      persistSession: false
    }
  })
}

export const supabaseClient = client
