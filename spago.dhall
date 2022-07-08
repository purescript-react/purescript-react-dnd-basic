{ name = "react-dnd-basic"
, dependencies =
  [ "console"
  , "effect"
  , "maybe"
  , "nullable"
  , "prelude"
  , "react-basic-hooks"
  , "web-dom"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
, license = "Apache-2.0"
, repository = "https://github.com/lumihq/purescript-react-dnd-basic"
}
