#  URLScheme

This app demonstrates handling a custom URL scheme via SwiftUI. Given that Blackbaud will not let you register a non-https URL Scheme for an OAuth2 app _without_ a dot in the URL scheme, the custom URL scheme for this app is `url-scheme.dot`.

Try running the app, then opening Safari on the simulator and navigating to `url-scheme.dot://this.is/a/test?foo=bar&baz=123`

## References

- [Deep linking and URL scheme in iOS](https://benoitpasquier.com/deep-linking-url-scheme-ios/), Benoit Pasquier
- [Deeplink URL handling in SwiftUI: Configuring your app for deeplinks](https://www.avanderlee.com/swiftui/deeplink-url-handling#configuring-your-app-for-deeplinks), Avander Lee
