# Datalayers Documentation


English | [简体中文](./README-CN.md)

---

Welcome to the repo for [Datalayers](https://github.com/datalayers-io/docs-datalayers) documentation. This is the source for [Datalayers Documentation](https://docs.datalayers.io/).

todo Datalayers introductions

For more information about Datalayers, please access [Datalayers website](https://www.datalayers.io/en).

## Contributing

If you find Datalayers documentation issues, please create an Issue to let us know or directly create a Pull request to help fix or update it. Our docs are completely open-source, and we sincerely appreciate contributions from our community!

See [Datalayers Documentation Contributing Guide](./CONTRIBUTING-EN.md) to become a contributor!


## Preview

```sh
./preview.sh 8080
```

Now, open <http://localhost:8080/docs/en/latest/>, if dir.yaml has been updated, you can re-run the above command to update the docs.

## Release a New Version

Both community and enterprise edition documents are managed in the same repo and same `release-Major.Minor` branch.

Opensource and Enterprise may have different content so they may release at different pace.

### Cut a new release for community edition

```sh
NEW_TAG="$(./cut-release.sh ce)"
git push origin "${NEW_TAG}"
```

### Cut a New Release for Enterprise Edition

```sh
NEW_TAG="$(./cut-release.sh ee)"
git push origin "${NEW_TAG}"
```

## Opensource

You can reach the Datalayers community and developers via the following channels.

- todo following
