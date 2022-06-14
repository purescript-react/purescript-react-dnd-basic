let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.0-20220527/packages.dhall
        sha256:15dd8041480502850e4043ea2977ed22d6ab3fc24d565211acde6f8c5152a799

in  upstream
  with react-basic-hooks =
      { dependencies =
        [ "aff"
        , "aff-promise"
        , "bifunctors"
        , "console"
        , "control"
        , "datetime"
        , "debug"
        , "effect"
        , "either"
        , "exceptions"
        , "foldable-traversable"
        , "functions"
        , "indexed-monad"
        , "integers"
        , "maybe"
        , "newtype"
        , "now"
        , "nullable"
        , "ordered-collections"
        , "prelude"
        , "react-basic"
        , "refs"
        , "tuples"
        , "type-equality"
        , "unsafe-coerce"
        , "unsafe-reference"
        , "web-html"
        ]
      , repo = "https://github.com/spicydonuts/purescript-react-basic-hooks.git"
      , version = "v8.0.0"
      }
