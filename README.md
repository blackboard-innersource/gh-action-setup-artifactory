[![.github/workflows/cd.yaml](https://github.com/blackboard-innersource/gh-action-setup-artifactory/actions/workflows/cd.yaml/badge.svg)](https://github.com/blackboard-innersource/gh-action-setup-artifactory/actions/workflows/cd.yaml)

# GitHub Action: Setup Artifactory

Configures package managers to authenticate to Artifactory.

## Usage: GitHub Action

Every configuration option gets set via environment variables to help improve security and
to allow usage in other CI/CD systems.

Example for configuring `pip`, `npm`, `yarn`, `sbt` and `mvn`:

```yaml
- name: Setup Artifactory
  uses: blackboard-innersource/gh-action-setup-artifactory@v2
  env:
    ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
    ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
```

General recommendation is to pull all artifacts from Artifactory because higher security
accreditations require that you pull packages from a repository that is under your
control.

Additional environment variables supported by this action:

| Name                       | How to use                                      |
| -------------------------- |-------------------------------------------------|
| `ARTIFACTORY_SETUP_PIP`    | Set to `false` to not setup `pip`               |
| `ARTIFACTORY_SETUP_NPM`    | Set to `false` to not setup `npm` and `yarn@v1` |
| `ARTIFACTORY_SETUP_YARN`   | Set to `false` to not setup `yarn@v2+`          |
| `ARTIFACTORY_SETUP_MVN`    | Set to `false` to not setup `nvm`               |
| `ARTIFACTORY_SETUP_SBT`    | Set to `false` to not setup `sbt`               |
| `SBT_CREDENTIALS`          | The value must be "$HOME/.sbt/.credentials"     |
| `ARTIFACTORY_SETUP_JFROG`  | Set to `true` to setup `jf` (JFrog CLI)\*       |
| `ARTIFACTORY_PYPI_INDEX`   | Set to override PyPi index URL                  |
| `ARTIFACTORY_NPM_REGISTRY` | Set to override NPM registry URL                |
| `ARTIFACTORY_NPM_SCOPES`   | CSV of NPM scopes\*\*                           |



\* The `ARTIFACTORY_SETUP_JFROG=true` only applies when using the `entry.sh` which is
called when using GitHub Actions. When calling `setup_jfrog.sh` directly, you do not need
to set this env var to `true`. You can also set `ARTIFACTORY_SETUP_JFROG=false` to always
prevent JFrog CLI from being installed. Default behavior for this is different because
most of the time it isn't needed, and it takes a while to download and configure.

\*\* `ARTIFACTORY_NPM_SCOPES` adds a scope to the `npm`/`yarn@v1` credential setup.
Set multiple scopes with: `"@scope1,@scope2"` This option **is ignored** everywhere except
for in GitHub actions. **Generally, never use this variable!**

## Usage: Other

You can invoke the shell scripts directly in non-GitHub workflows.

```shell
# Ensure environment variables are setup (see GitHub usage above)
export ARTIFACTORY_TOKEN="token"
# ...etc

# Download this project using a tag
git clone --quiet --depth 1 --branch v2 https://github.com/blackboard-innersource/gh-action-setup-artifactory.git

# Same entry point as the GitHub action
./gh-action-setup-artifactory/entry.sh

# Or you can call specific setup scripts
./gh-action-setup-artifactory/setup_pip.sh
./gh-action-setup-artifactory/setup_npm.sh
./gh-action-setup-artifactory/setup_yarn.sh
./gh-action-setup-artifactory/setup_mvn.sh
./gh-action-setup-artifactory/setup_sbt.sh
./gh-action-setup-artifactory/setup_jfrog.sh
```

## Developing

To run tests locally:

```shell script
make
```

## License

Please see the [LICENSE](LICENSE) file.
