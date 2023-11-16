import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

// Note: Once TypeScript 4.5 is out of beta we can drop the whole script.
const __dirname = path.dirname(fileURLToPath(import.meta.url))

const file = path.join(__dirname, '..', 'dist', 'index.cjs')
const source = fs.readFileSync(file, 'utf-8')
const code = source.replaceAll(
  'isNodeMode || !mod || !mod.__esModule',
  '!mod.default',
)

if (code !== source) {
  console.info(`Writing ${file}`)
  fs.writeFileSync(file, code)
}
else {
  const message = 'Did not find CJS pattern to replace.'
  console.warn(message)
}
