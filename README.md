[![.github/workflows/cd.yaml](https://github.com/blackboard-innersource/gh-action-setup-artifactory/actions/workflows/cd.yaml/badge.svg)](https://github.com/blackboard-innersource/gh-action-setup-artifactory/actions/workflows/cd.yaml)

# GitHub Action: Setup Artifactory

Configures package managers to authenticate to Artifactory.

## Usage: GitHub Action

Every configuration option gets set via environment variables to help improve security and
to allow usage in other CI/CD systems.

Example for configuring all - `pip`, `npm/yarn1`, `mvn` and `yarn2+`:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v2
        env:
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
          ARTIFACTORY_PYPI_INDEX: ${{ secrets.ARTIFACTORY_PYPI_INDEX }}
          ARTIFACTORY_NPM_REGISTRY: ${{ secrets.ARTIFACTORY_NPM_REGISTRY }}
```

Example for configuring only `pip`:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v2
        env:
          ARTIFACTORY_SETUP_NPM: false
          ARTIFACTORY_YARN_SETUP: false
          ARTIFACTORY_SETUP_MVN: false
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
          ARTIFACTORY_PYPI_INDEX: ${{ secrets.ARTIFACTORY_PYPI_INDEX }}
```

Example for configuring only `npm/yarn1`:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v2
        env:
          ARTIFACTORY_SETUP_PIP: false
          ARTIFACTORY_YARN_SETUP: false
          ARTIFACTORY_SETUP_MVN: false
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
          ARTIFACTORY_NPM_REGISTRY: ${{ secrets.ARTIFACTORY_NPM_REGISTRY }}
```

Example for configuring only `yarn2+`:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v2
        env:
          ARTIFACTORY_SETUP_PIP: false
          ARTIFACTORY_SETUP_NPM: false
          ARTIFACTORY_SETUP_MVN: false
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
```

Example for configuring only `yarn2+`:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v2
        env:
          ARTIFACTORY_SETUP_PIP: false
          ARTIFACTORY_SETUP_NPM: false
          ARTIFACTORY_SETUP_MVN: false
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
```

If you want to change the settings for `mvn`, you need to set environment variable `ARTIFACTORY_MVN_DEFAULT=false` and create variables containing prefix `ARTIFACTORY_MVN_REPOS_` with 4 values separated by a comma.

Default repository and plugin settings for `mvn`:
* id: central, snapshots (first position in environment variable)
* name: fnds-maven (second position in environment variable)
* url: https://blackboard.jfrog.io/artifactory/fnds-maven (third position in environment variable)
* snapshots enabled: false (fourth position in environment variable)

For URL the default prefix is https://blackboard.jfrog.io/artifactory/. If you want to use other URL, you need to set environment variable `ARTIFACTORY_MVN_URL` with different prefix.

The default environment variables are `fnds-maven,central,fnds-maven,false` and `fnds-maven,snapshots,fnds-maven,false`.

Example for configuring only `mvn`:
```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v2
        env:
          ARTIFACTORY_SETUP_PIP: false
          ARTIFACTORY_SETUP_NPM: false
          ARTIFACTORY_YARN_SETUP: false
          ARTIFACTORY_MVN_DEFAULT: false
          ARTIFACTORY_MVN_URL: https://test.io/artifactory/
          ARTIFACTORY_MVN_REPOS_CENTRAL: fnds-maven-local,central,fnds-maven-local,false
          ARTIFACTORY_MVN_REPOS_SNAPSHOTS: fnds-maven-local,snapshots,fnds-maven-local,false
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
```

Example for configuring only JFrog CLI (`jf`). Just add `ARTIFACTORY_URL` to trigger setup
for JFrog CLI:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v2
        env:
          ARTIFACTORY_SETUP_PIP: false
          ARTIFACTORY_SETUP_NPM: false
          ARTIFACTORY_YARN_SETUP: false
          ARTIFACTORY_SETUP_MVN: false
          ARTIFACTORY_URL: ${{ secrets.ARTIFACTORY_URL }}
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
```

Additional environment variables:

`ARTIFACTORY_NPM_SCOPES` adds a scope to the NPM/yarn@v1 credential setup. Set multiple
scopes with: `"@scope1,@scope2"` This option is ignored everywhere except for in GitHub
actions. **Generally, never use this variable!**

## Usage: Other

You can invoke the shell scripts directly in non-GitHub workflows.

```shell
# Ensure environment variables are setup (see GitHub usage above)
export ARTIFACTORY_TOKEN="token"
# ...etc

# Download this project
git clone --quiet --depth 1 https://github.com/blackboard-innersource/gh-action-setup-artifactory.git

# Or using a tag
git clone --quiet --depth 1 --branch v2 https://github.com/blackboard-innersource/gh-action-setup-artifactory.git

# Same entry point as the GitHub action 
./gh-action-setup-artifactory/entry.sh

# Or you can call specific setup scripts 
./gh-action-setup-artifactory/setup_pip.sh
./gh-action-setup-artifactory/setup_npm.sh
./gh-action-setup-artifactory/setup_yarn.sh
./gh-action-setup-artifactory/setup_mvn.sh
```

## Developing

To run tests locally:

```shell script
make
```

## License

Please see the [LICENSE](LICENSE) file.
