{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name =
    "my-project"
, dependencies =
    [ "aff-promise"
    , "arrays"
    , "bouzuya-command-line-option-parser"
    , "console"
    , "effect"
    , "node-fs-aff"
    , "node-process"
    , "now"
    , "psci-support"
    , "simple-json"
    , "test-unit"
    ]
, packages =
    ./packages.dhall
}
