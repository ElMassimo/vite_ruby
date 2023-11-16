/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable import/order */
const args = require('minimist')(process.argv.slice(2))
const msgPath = args._[0]
const msg = require('fs').readFileSync(msgPath, 'utf-8').trim()

const releaseRE = /^v\d/
const commitRE = /^(revert: )?(feat|fix|docs|dx|refactor|perf|test|workflow|build|ci|chore|types|wip|release|deps)(\(.+\))?: .{1,50}/

if (!releaseRE.test(msg) && !commitRE.test(msg)) {
  console.log()
  const chalk = require('chalk')
  console.error(
    `  ${chalk.bgRed.white(' ERROR ')} ${chalk.red(
      'invalid commit message format.',
    )}\n\n${
      chalk.red(
        '  Proper commit message format is required for automated changelog generation. Examples:\n\n',
      )
    }    ${chalk.green('feat: add \'comments\' option')}\n`
      + `    ${chalk.green('fix: handle events on blur (close #28)')}\n\n${
        chalk.red('  See .github/commit-convention.md for more details.\n')}`,
  )
  process.exit(1)
}
