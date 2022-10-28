import Honeybadger from '@honeybadger-io/js'

if (import.meta.env.HONEYBADGER_API_KEY) {
  Honeybadger.configure({
    apiKey: import.meta.env.HONEYBADGER_API_KEY,
    environment: import.meta.env.MODE,
  })

  Honeybadger.notify('Vite Rails Demo')
}

export default Honeybadger
