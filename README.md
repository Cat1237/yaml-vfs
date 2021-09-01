# yaml-vfs

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/wangson1237/SYCSSColor/master/LICENSE)&nbsp;

A gem which can gen VFS YAML file.

`vfs yamlwriter` lets you create clang opt "-ivfsoverlay" ymal file,  map virtual path to real path.

- ✅ It can gen VFS YAML.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yaml-vfs'
```

And then execute:

```shell
# bundle install
$ bundle install
```

Or install it yourself as:

```shell
# gem install
$ gem install yaml-vfs
```

## Usage

The command should be executed when your want VFS YAML file.

```shell
# write the VFS YAML file to --output-path=<path>
$ vfs yamlwriter --framework-path=<path> --real-headers-dir=<path> --real-modules-dir=<path> --output-path=<path>

# write the VFS YAML file to .
$ vfs yamlwriter --framework-path=<path> --real-headers-dir=<path> --real-modules-dir=<path>
```

### Option && Flags

`Usage:`

- `vfs yamlwriter --framework-path --real-headers-dir --real-modules-dir [--output-path]`

`Options:`

- `--framework-path=<path>`: framework path
- `--real-headers-dir=<path>`: real header path
- `--real-modules-dir=<path>`: real modules path
- `--output-path=<path>`: vfs yaml file output path

## Command Line Tool

Installing the 'yaml-vfs' gem will also install two command-line tool `vfs` which you can use to generate VFS YAML file.

For more information consult `vfs --help` or `vfs yamlwriter --help`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [yaml-vfs](https://github.com/Cat1237/yaml-vfs). This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the yaml-vfs project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cocoapods-hmap/blob/master/CODE_OF_CONDUCT.md).
