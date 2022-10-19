/* eslint-disable @typescript-eslint/no-var-requires */

/**
 * modified from https://github.com/vuejs/vue-next/blob/master/scripts/release.js
 */
const path = require('path')
const fs = require('fs')
const execa = require('execa')
const args = require('minimist')(process.argv.slice(2))
const semver = require('semver')
const chalk = require('chalk')
const { prompt } = require('enquirer')

const name = args._[0]?.trim()
let targetVersion = args._[1]
if (!name) {
  console.error(chalk.red(`Expected library name as an argument, received ${name}`))
  process.exit(1)
}

const isRubyLibrary = name !== 'vite-plugin-ruby' && name !== 'vite-plugin-rails'
const pkg = isRubyLibrary ? rubyPackage() : jsPackage()

/**
 * @type {boolean}
 */
const isDryRun = args.dry
/**
 * @type {boolean}
 */
const skipBuild = args.skipBuild || isRubyLibrary

/**
 * @type {import('semver').ReleaseType[]}
 */
const versionIncrements = [
  'patch',
  'minor',
  'major',
  'prepatch',
  'preminor',
  'premajor',
  'prerelease',
]

/**
 * @param {import('semver').ReleaseType} i
 */
function inc (i) {
  return semver.inc(pkg.version, i)
}

/**
 * @param {string} bin
 * @param {string[]} args
 * @param {object} opts
 */
function run (bin, args, opts = {}) {
  return execa(bin, args, { stdio: 'inherit', ...opts })
}

/**
 * @param {string} bin
 * @param {string[]} args
 * @param {object} opts
 */
function dryRun (bin, args, opts = {}) {
  console.log(chalk.blue(`[dryrun] ${bin} ${args.join(' ')}`), opts)
}

/**
 * @param {string} msg
 */
function step (msg) {
  console.log(chalk.cyan(msg))
}

/**
 * @param {string} paths
 */
function resolve (paths) {
  return path.resolve(__dirname, `../${name}/${paths}`)
}

function rubyPackage () {
  const versionRegex = /VERSION = '([\d.]+(?:[-.]\w+)?)'/
  const path = resolve(`lib/${name}/version.rb`)
  const content = fs.readFileSync(path, 'utf-8')
  const versionCaptures = content.match(versionRegex)
  const version = versionCaptures && versionCaptures[1]
  if (!version) {
    console.error(chalk.red(`Could not infer version for ${name}.`))
    process.exit(1)
  }
  return {
    type: 'gem',
    path,
    content,
    version,
    updateVersion (version) {
      const newContent = content.replace(versionRegex, `VERSION = '${version}'`)
      fs.writeFileSync(path, `${newContent}`)
    },
  }
}

function jsPackage () {
  const path = resolve('package.json')
  const content = fs.readFileSync(path, 'utf-8')
  return {
    type: 'package',
    path,
    content,
    ...require(path),
    updateVersion (version) {
      const newContent = { ...JSON.parse(content), version }
      fs.writeFileSync(path, `${JSON.stringify(newContent, null, 2)}\n`)
    },
  }
}

async function main () {
  const runIfNotDry = isDryRun ? dryRun : run

  if (!targetVersion) {
    // no explicit version, offer suggestions
    /**
     * @type {{ release: string }}
     */
    const { release } = await prompt({
      type: 'select',
      name: 'release',
      message: 'Select release type',
      choices: versionIncrements
        .map(i => `${i} (${inc(i)})`)
        .concat(['custom']),
    })

    if (release === 'custom') {
      /**
       * @type {{ version: string }}
       */
      const res = await prompt({
        type: 'input',
        name: 'version',
        message: 'Input custom version',
        initial: pkg.version,
      })
      targetVersion = res.version
    }
    else {
      targetVersion = release.match(/\((.*)\)/)[1]
    }
  }

  if (!semver.valid(targetVersion) && !isRubyLibrary)
    throw new Error(`invalid target version: ${targetVersion}`)

  const tag = `${name}@${targetVersion}`

  /**
   * @type {{ yes: boolean }}
   */
  const { yes } = await prompt({
    type: 'confirm',
    name: 'yes',
    message: `Releasing ${tag}. Confirm?`,
  })

  if (!yes)
    return

  step(`\nUpdating ${pkg.type} version...`)
  pkg.updateVersion(targetVersion)

  step(`\nBuilding ${pkg.type}...`)
  if (!skipBuild && !isDryRun)
    await run('pnpm', ['build'], { cwd: resolve('.') })
  else
    console.log('(skipped)')

  if (isRubyLibrary)
    await run('bundle install && bin/rubocop -A', { shell: true })

  step('\nGenerating changelog...')
  await run('pnpm', ['changelog', name])

  const { stdout } = await run('git', ['diff'], { stdio: 'pipe' })
  if (stdout) {
    step('\nCommitting changes...')
    await runIfNotDry('git', ['add', '-A'])
    await runIfNotDry('git', ['commit', '-m', `release: ${tag}`])
  }
  else {
    console.log('No changes to commit.')
  }

  step(`\nPublishing ${pkg.type}...`)
  if (isRubyLibrary)
    await publishGem(targetVersion)
  else
    await publishPackage(targetVersion, runIfNotDry)

  step('\nPushing to GitHub...')
  await runIfNotDry('git', ['push'])

  if (isDryRun)
    console.log(`\nDry run finished - run git diff to see ${pkg.type} changes.`)

  console.log()
}

/**
 * @param {string} version
 * @param {Function} runIfNotDry
 */
async function publishGem (version) {
  try {
    const runIfNotDry = isDryRun ? dryRun : execa.commandSync
    await runIfNotDry('bundle exec rake release', {
      stdio: 'inherit',
      cwd: resolve('.'),
    })
    console.log(chalk.green(`Successfully published ${name}@${version}`))
  }
  catch (e) {
    if (e.stderr.match(/previously/))
      console.log(chalk.red(`Skipping already published: ${name}`))
    else
      throw e
  }
}

/**
 * @param {string} version
 * @param {Function} runIfNotDry
 */
async function publishPackage (version, runIfNotDry) {
  try {
    await runIfNotDry('pnpm', ['publish'], {
      stdio: 'inherit',
      cwd: resolve('.'),
    })
    console.log(chalk.green(`Successfully published ${name}@${version}`))
  }
  catch (e) {
    if (e.stderr.match(/previously published/))
      console.log(chalk.red(`Skipping already published: ${name}`))
    else
      throw e
  }
}

main().catch((err) => {
  console.error(err)
})
