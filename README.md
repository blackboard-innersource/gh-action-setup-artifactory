[![.github/workflows/cd.yaml](https://github.com/blackboard-innersource/gh-action-setup-artifactory/actions/workflows/cd.yaml/badge.svg)](https://github.com/blackboard-innersource/gh-action-setup-artifactory/actions/workflows/cd.yaml)

# GitHub Action: Setup Artifactory

Configures package managers to authenticate to Artifactory.

## Usage: GitHub Action

Every configuration option gets set via environment variables to help improve security and
to allow usage in other CI/CD systems.

Example for configuring both `pip` and `npm`:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v1
        env:
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
          ARTIFACTORY_PYPI_INDEX: ${{ secrets.ARTIFACTORY_PYPI_INDEX }}
          ARTIFACTORY_NPM_REGISTRY: ${{ secrets.ARTIFACTORY_NPM_REGISTRY }}
```

Example for configuring only `pip`:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v1
        env:
          ARTIFACTORY_SETUP_NPM: false
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
          ARTIFACTORY_PYPI_INDEX: ${{ secrets.ARTIFACTORY_PYPI_INDEX }}
```

Example for configuring only `npm`:

```yaml
      - name: Setup Artifactory
        uses: blackboard-innersource/gh-action-setup-artifactory@v1
        env:
          ARTIFACTORY_SETUP_PIP: false
          ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
          ARTIFACTORY_TOKEN: ${{ secrets.ARTIFACTORY_TOKEN }}
          ARTIFACTORY_NPM_REGISTRY: ${{ secrets.ARTIFACTORY_NPM_REGISTRY }}
```

Additional environment variables:

- `ARTIFACTORY_NPM_SCOPES` adds a scope to the NPM credential setup. Set multiple scopes with: `"@scope1,@scope2"`

## Usage: Other

You can invoke the shell scripts directly in non-GitHub workflows.

```shell
# Ensure environment variables are setup (see GitHub usage above)
export ARTIFACTORY_TOKEN="token"
# ...etc

# Download this project
git clone --quiet --depth 1 https://github.com/blackboard-innersource/gh-action-setup-artifactory.git

# Or using a tag
git clone --quiet --depth 1 --branch v1 https://github.com/blackboard-innersource/gh-action-setup-artifactory.git

# Same entry point as the GitHub action 
./gh-action-setup-artifactory/entry.sh

# Or you can call specific setup scripts 
./gh-action-setup-artifactory/setup_pip.sh
./gh-action-setup-artifactory/setup_npm.sh
```

## Developing

To run tests locally:

```shell script
make
```

## License

Please see the [LICENSE](LICENSE) file.
