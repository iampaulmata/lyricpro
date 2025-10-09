import path from 'node:path'

import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(4000),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('debug'),
  SUPABASE_URL: z.string().url().optional(),
  SUPABASE_SERVICE_ROLE_KEY: z.string().optional(),
  CORS_ORIGINS: z
    .string()
    .optional()
    .transform((value) => {
      const origins = value?.split(',').map((origin) => origin.trim()).filter(Boolean)
      return origins?.length ? origins : ['http://localhost:8080']
    }),
  ENV_FILE: z.string().optional()
})

const parsed = envSchema.safeParse(process.env)

if (!parsed.success) {
  console.error('Invalid environment configuration', parsed.error.format())
  process.exit(1)
}

const values = parsed.data

export const env = {
  nodeEnv: values.NODE_ENV,
  port: values.PORT,
  logLevel: values.LOG_LEVEL,
  supabaseUrl: values.SUPABASE_URL,
  supabaseServiceRoleKey: values.SUPABASE_SERVICE_ROLE_KEY,
  corsOrigins: values.CORS_ORIGINS,
  envFile: values.ENV_FILE ?? path.resolve(process.cwd(), '.env')
} as const
