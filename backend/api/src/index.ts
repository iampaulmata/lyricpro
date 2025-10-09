import { config } from 'dotenv'

import { createApp } from './server/app'
import { env } from './server/config/env'

config({ path: env.envFile })

const app = createApp()

const port = env.port
app.listen(port, () => {
  console.log(`[lyricpro-backend] listening on http://localhost:${port}`)
})
