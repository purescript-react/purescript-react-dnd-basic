let config = ./../../spago.dhall

in      config
    //  { sources = config.sources # [ "examples/basic/**/*.purs" ]
        , dependencies =
              config.dependencies
            # [ "arrays"
              , "exceptions"
              , "foldable-traversable"
              , "integers"
              , "react-basic"
              , "react-basic-dom"
              , "web-html"
              ]
        }
