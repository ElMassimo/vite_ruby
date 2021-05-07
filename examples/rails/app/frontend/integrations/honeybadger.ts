import Honeybadger from '@honeybadger-io/js'

if (process.env.HONEYBADGER_API_KEY) {
  Honeybadger.configure({
    apiKey: process.env.HONEYBADGER_API_KEY,
    environment: import.meta.env.MODE,
  })

  Honeybadger.notify('Vite Rails Demo')
}

export default Honeybadger
