{ name = "leap"
, dependencies = [ "console", "effect", "prelude", "psci-support", "test-unit" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
