# Contributor Guidelines

:honeybee: Please read this document before beginning any implementation, we use a set of guidelines that should be followed.:honeybee:

## DOs and DON'Ts

- **DO** follow our git branching styleguide
- **DO** give priority to the current style of the project or file you're changing even if it diverges from the general guidelines
- **DO** include tests when adding new features. When fixing bugs, start with adding a test that highlights how the current behavior is broken
- **DO** keep the discussions focused. When a new or related topic comes up it's often better to create a new issue than to side track the discussion
- **DO NOT** make PRs for style changes
- **DO NOT** surprise us with big pull requests. Instead, file an issue and start a discussion so we can agree on a direction before you invest a large amount of time working on it
- **DO NOT** add API additions without filing an issue and discussing with us first

## Testing

We're using [busted](http://olivinelabs.com/busted) to run our tests. Every test file should live in a `spec` folder and end with `_spec.lua`.

### Running the tests

`make test` or `busted spec/` in the plugin folder should do the job.

remember to run it as super user if your current environment needs it.

### Test Coverage

If you're using our Makefile, just run `make coverage`.

With Busted, a `-c` flag will do the job.
It will generate a `luacov.stats.out` that you can use to generate coverage reports.
You can run `luacov` and it will generate a `luacov.report.out` containing a comprehensive coverage report.

## Lint

`make lint` or `luacheck -q .` in the plugin folder should run the linter.

### Adding External Library Dependencies

- Add new dependencies to the project ONLY IF STRICTLY NECESSARY, we know that adding new dependencies is easier, but by doing so it increases the build time of the framework.

### Workflow

- We use GitFlow, you can find more about this workfow [here](http://nvie.com/posts/a-successful-git-branching-model/).

### Branching

- **New Features** `feature/<Name of feature>` from `develop`.
- **Bugfix** `bugfix/<Name of bugfix>` from `develop`.
- **Improvements** `improvement/<Name of improvement>` from `develop`.
- **Hotfix** `hotfix/<Name of hotfix>` from `master`.

### Tests and coverage

- Don't forget to write tests!!
- We'd like to keep our project with a minimum of 60%, but 90% is the desirable target.

### Commit messages

See [standard-version](https://github.com/conventional-changelog/standard-version#commit-message-convention-at-a-glance) for commit guidelines.

Commit examples:

```bash
git commit -m "feat: Portal-12345 Add healthcheck endpoint"
git commit -m "fix: CLB-12345 Field in healthcheck endpoint"
git commit -m "chore: Fix tests"
```

### Pull Requests

- **DO** give PRs short-but-descriptive names (e.g. "Improves code coverage for System.Console by 10%", not "Fix #1234").
- **DO NOT** submit "work in progress" PRs. A PR should only be submitted when it is considered ready for review and subsequent merging by the contributor.
- **DO** tag any users that should know about and/or review the change.
- **DO** submit all code changes via pull requests (PRs) rather than through a direct commit. PRs will be reviewed and potentially merged by the repo maintainers after a peer review that includes at least one maintainer.
- **DO** ensure each commit successfully builds. The entire PR must pass all tests in the Continuous Integration (CI) system before it'll be merged.
- **DO NOT** mix independent, unrelated changes in one PR. Separate real product/test code changes from larger code formatting/dead code removal changes. Separate unrelated fixes into separate PRs, especially if they are in different assemblies.
- **DO** address PR feedback in an additional commit(s) rather than amending the existing commits, and only rebase/squash them when necessary. This makes it easier for reviewers to track changes. If necessary, squashing should be handled by the merger using the "squash and merge" feature, and should only be done by the contributor upon request.
- **DO** all the PRs to `develop` branch unless it is a `hotfix`. For this one you should do for both `develop` and `master` branches.

### Guiding Principles

- We allow anyone to participate in our projects. Tasks can be carried out by anyone that demonstrates the capability to complete them.
- Always be respectful of one another. Assume the best in others and act with empathy at all times.
- Collaborate closely with individuals maintaining the project or experienced users. Getting ideas out in the open and seeing a proposal before it's a pull request helps reduce redundancy and ensures we're all connected to the decision making process.
- Don't be a jerk.

### Release steps

1. Open a release branch, following gitflow branching conventions (`release/vx.x.x`), from `develop` branch.
2. Fetch all tags by running: `git fetch --all --tags`.
3. Update the CHANGELOG by running: `standard-version`.
    - If you need to install it, run: `npm install -g standard-version`.
4. Push the release branch.
5. Open a pull-request to the `develop` branch and another one against the `master` branch.
