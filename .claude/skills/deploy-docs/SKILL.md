# Deploy Reference Documentation

Deploy the docC reference documentation for a new release. Pass the version number as argument (e.g. `/deploy-docs 6.4.0`).

Version: $ARGUMENTS

## Steps

Follow these steps in order. Stop and ask for confirmation before proceeding if any step fails.

### 1. Determine version

If no version argument is provided, read the version from `Airwallex.podspec` (the `s.version` line). Confirm the version with the user before proceeding.

### 2. Ensure `main` branch is up to date

Run `git fetch origin` and check if local `main` is behind `origin/main`. If behind, pull the latest changes. Ensure `main` is clean and in sync with remote.

### 3. Validate documentation links

Check that the links in `Airwallex.docc/Airwallex.md` are valid by verifying each `#section-name` anchor actually exists as a heading in the target file.

Specifically:
- For links pointing to the README (e.g. `https://github.com/airwallex/airwallex-payment-ios?tab=readme-ov-file#installation`), extract the `#fragment` and verify a matching heading exists in `README.md`.
- Also check `README_zh_CN.md` for any doc links that may need updating.

Report any broken links and ask whether to fix them or continue.

### 4. Switch to `reference-doc` branch and merge latest `main`

```bash
git checkout reference-doc
git pull origin reference-doc
git merge main
```

If `reference-doc` branch doesn't exist, create it from `main`. Resolve any merge conflicts if they arise (ask the user for help if needed).

### 5. Run `pod install`

Run `pod install` to generate/update the Pods project.

### 6. Add `Airwallex.docc` to Pods project compile sources

Check if `Airwallex.docc` is already referenced in `Pods/Pods.xcodeproj/project.pbxproj` by searching for "Airwallex.docc". If found, skip this step.

If NOT found:
1. Tell the user to open `Airwallex.xcworkspace` in Xcode.
2. Ask them to navigate to Pods project > Airwallex target > Build Phases > Compile Sources.
3. Ask them to add `Airwallex.docc` to the compile sources.
4. Wait for user confirmation before continuing.

### 7. Generate documentation

Run the documentation generation script:

```bash
.github/scripts/generate-docs-pods.sh <version>
```

This will build docs, transform for static hosting, create the redirect page, and attempt to commit/push to `reference-doc`.

If the auto-commit/push in the script succeeds, proceed to step 8.

If it fails, help the user commit manually:
```bash
git add docs/
git commit -m "doc: <version> [skip ci]"
git push origin reference-doc
```

### 8. Monitor deploy-docs GitHub Action

The push to `reference-doc` in step 7 automatically triggers the `deploy-docs` workflow. Monitor its status:

```bash
gh run list --workflow=deploy-docs --limit=1
```

If the workflow hasn't started yet, wait a moment and check again. Report the result to the user.

### 9. Done

Report the documentation URL: `https://airwallex.github.io/airwallex-payment-ios/<version>/documentation/airwallex`
