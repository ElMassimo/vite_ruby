# Contributing

First, thanks for wanting to contribute. You’re awesome! :heart:

## Help

We’re not able to provide support through GitHub Issues. If you’re looking for
help with your code, try posting on [Stack Overflow](https://stackoverflow.com/).

All features should be documented. If you don’t see a feature in the docs,
assume it doesn’t exist.

## Bugs

Think you’ve discovered a bug?

1. Search existing issues to see if it’s been reported.
2. Try the `main` branch to make sure it hasn’t been fixed.

```rb
gem "vite_ruby", github: "ElMassimo/vite_ruby"
gem "vite_rails", github: "ElMassimo/vite_rails"
```

If the above steps don’t help, create an issue. Include:

- Detailed steps to reproduce
- Complete backtraces for exceptions

## New Features

If you’d like to discuss a new feature, [create a new Discussion](https://github.com/ElMassimo/vite_ruby/discussions/new?category=ideas).

## Pull Requests

Fork the project and create a pull request. A few tips:

- Keep changes to a minimum. If you have multiple features or fixes, submit multiple pull requests.
- Follow the existing style. The code should read like it’s written by a single person.

Please open a discussion to get feedback on your idea before spending too much time on it.


### Setting Up a Development Environment

1. Install [pnpm](https://pnpm.js.org/)

2. Run the following commands to set up the development environment.

```
bundle install
```

```
pnpm install
```

#### Making sure your changes pass all tests

There are a number of automated checks which run on GitHub Actions when a pull request is created.
You can run those checks on your own locally to make sure that your changes would not break the CI build.

##### 1. Check the code for JavaScript style violations

```
pnpm lint --fix
```

##### 2. Check the code for Ruby style violations
```
bin/rubocop -A
```

##### 3. Run the test suite
```
bin/m
```

---

This contributing guide is released under [CCO](https://creativecommons.org/publicdomain/zero/1.0/) (public domain). Use it for your own project without attribution.
