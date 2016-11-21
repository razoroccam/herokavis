# Herokavis

Some wierd mashup of heroku buildpacks and travis.yml, exists for $REASONS


## Usage

1. Download this repo somewhere (probably best to use github releases so you don't have to use a git client).
1. Install some buildpacks with `./install-buildpacks`
1. Then call `./build.sh BUILD_DIR CACHE_DIR ENV_DIR`
  - `BUILD_DIR` - the directory containing the source code
  - `CACHE_DIR` - a directory that can be used to store artifacts between builds
  - `ENV_DIR` - a directory containing env vars as files

This will cause every bundled pack to be tried against the source code and the first one that matches will be used to compile the the code. Once the code is compiled any `scripts` and `after_scripts` present in a `.travis.yml` in the projects root will be run


You could always fork this repo, install the buildpacks and then commit them if you want to bundle this all up in an
easy to re-use repo

## Todo

- support more travis.yml keys

## LICENSE

MIT License

Parts of this project are lincesed under the Apache 2.0 licensed
