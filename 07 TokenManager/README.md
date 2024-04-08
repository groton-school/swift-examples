# TokenManager

Example of creating an `@Observable` token manager in the environment to handle OAuth interactions for your app.

Note the change in `OAuth2.swift` from a `struct` to a class (and the consequent removal of the `modifying` descriptor on methods). This allows us to extend OAuth2 into the TokenManager (only classes can be extended, not structs).
