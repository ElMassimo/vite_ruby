/* eslint-disable @typescript-eslint/no-var-requires */
const path = require('path')
const fs = require('fs')
const args = require('minimist')(process.argv.slice(2))
const execa = require('execa')
const chalk = require('chalk')

const name = args._[0]?.trim()

if (!name) {
  console.error(chalk.red(`Expected library name as an argument, received ${name}`))
  process.exit(1)
}

const isRubyPackage = name !== 'vite-plugin-ruby'

/**
 * @param {string} bin
 * @param {string[]} args
 * @param {object} opts
 */
const run = (bin, args, opts = {}) =>
  execa(bin, args, { stdio: 'inherit', ...opts })

/**
 * @param {string} msg
 */
const step = msg => console.log(chalk.cyan(msg))

/**
 * @param {string} paths
 */
const resolve = paths => path.resolve(__dirname, `../${name}/${paths}`)

/**
 * @param {string} name
 */
function writePackageJson (name) {
  const versionRegex = /VERSION = '([\d.]+)'/
  const versionFile = fs.readFileSync(resolve(`lib/${name}/version.rb`), 'utf-8')
  const versionCaptures = versionFile.match(versionRegex)
  const version = versionCaptures && versionCaptures[1]
  if (!version) {
    console.error(chalk.red(`Could not infer version for ${name}.`))
    process.exit(1)
  }
  fs.writeFileSync(resolve('package.json'), `{ "version": "${version}" }`)
}

async function main () {
  if (isRubyPackage) {
    step('\nExtracting version number...')
    writePackageJson(name)
  }

  step('\nGenerating changelog...')
  await run('npx', ['conventional-changelog', `-p angular -i ${name}/CHANGELOG.md -s -t ${name}@ --pkg ./${name}/package.json --commit-path ./${name}`])

  if (isRubyPackage) {
    step('\nDeleting temporary package.json...')
    fs.rmSync(resolve('package.json'))
  }

  console.log(chalk.green(`\nCHANGELOG for ${name} was successfully updated!`))
  console.log()
}

main().catch((err) => {
  console.error(err)
})
