#  Secrets

Absolutely, positively never-ever store secrets hard-coded in your source. And don't commit them to your repository, either.

## Setup

1. Close the project in Xcode (we're about to perform surgery on it -- better that it's not awake!)
2. In the Terminal, `cd` to the project directory
3. `bundle install` (installs the Ruby gems for `cocoapods-keys`, if not already installed -- likely need to take a look at [Troubleshooting](https://github.com/groton-school/swift-examples?tab=readme-ov-file#troubleshooting) when this almost definitely fails)
3. `pod install` (installs the pods for `cocoapods-keys` and enter secrets as asked)
3. `open Secrets.xcworkspace` (now that Cocoapods is installed, we _only_ want to open the workspace, **not** the project)

## References

- [Secret Management on iOS](https://nshipster.com/secrets), Matt
- [Cocoapods](https://cocoapods.org/)
- [`cocoapods-keys`](https://github.com/orta/cocoapods-keys?tab=readme-ov-file#readme)

