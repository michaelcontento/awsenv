# [awsenv][]

## Simple AWS Environment Management: awsenv

[awsenv][] lets you easily switch between multiple [AWS][] environments. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose tool that
do one thing well. It also includes the latest versions of the [AWS][] CLI tools
, so that you're ready to go in few seconds.

[awsenv][] is heavily inspired by [rbenv][] from [sstephenson][]. Thanks for
this awesome tool!

## How It Works

[awsenv][] operates on the per-user directory `~/.awsenv`. Environments in
[awsenv][] correspond to subdirectories of `~/.awsenv/envs`. For example, you
might have `~/.awsenv/envs/acme-corporation` and `~/.awsenv/envs/private`.

## Installation

1. Check out [awsenv][] into `~/.awsenv`.

    $ git clone git://github.com/michaelcontento/awsenv.git "$HOME/.awsenv"

2. Add `~/.awsenv/bin` to your `$PATH` for access to the [awsenv][] command-line
utility.

    $ echo 'export PATH="$HOME/.awsenv/bin:$PATH"' >> ~/.bash_profile

    **Zsh note:** Modify your `~/.zshenv` file instead of `~/.bash_profile`.

3. Add `awsenv init` to your shell to load the default environment.

    $ echo 'eval "$(awsenv init -)" >> ~/.bash_profile'

    **Zsh note:** Modify your `~/.zshenv` file instead of `~/.bash_profile`.

4. Restart your shell so the path changes take effect. You can now begin using
[awsenv][].

    $ exec $SHELL

## Upgrading

If you've installed [awsenv][] using the instructions above, you can upgrade your
installation at any time using git.

To upgrade to the latest development version of [awsenv][], use `git pull`:

    $ cd ~/.awsenv
    $ git pull

Or use the builtin update method:

    $ awsenv update

To upgrade to a specific release of [awsenv][], check out the corresponding tag:

    $ cd ~/.awsenv
    $ git fetch
    $ git tag
    0.1.0
    0.2.0
    $ git checkout 0.2.0

## Usage

Like [git][], the [awsenv][] command delegates to subcommands based on its first
argument. The most common subcommands are:

### awsenv init

### awsenv use

### awsenv list

### awsenv rehash

## Development

The [awsenv][] source code is hosted on [GitHub][]. It's clean, modular, and 
easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue tracker][].

## License

    Copyright 2009-2012 Michael Contento <michaelcontento@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

  [AWS]: https://aws.amazon.com/
  [GitHub]: https://github.com
  [awsenv]: https://github.com/michaelcontento/awsenv
  [git]: http://git-scm.com
  [issue tracker]: https://github.com/michaelcontento/awsenv/issues
  [rbenv]: https://github.com/sstephenson/rbenv
  [sstephenson]: https://github.com/sstephenson
