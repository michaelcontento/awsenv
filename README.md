# Simple AWS Environment Management 

[awsenv][] lets you easily switch between multiple [AWS][] environments. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose tool that
do one thing well. It also includes the latest versions of the [AWS][] CLI tools
, so that you're ready to go in few seconds.

[awsenv][] is heavily inspired by [rbenv][] from [sstephenson][].

## How it works

[awsenv][] operates on the per-user directory `~/.awsenv`. Environments in
[awsenv][] correspond to subdirectories of `~/.awsenv/envs`. For example, you
might have `~/.awsenv/envs/acme-corporation` and `~/.awsenv/envs/private`.

## Installation

### Basic checkout

1. Check out [awsenv][] into `~/.awsenv`.

        $ git clone git://github.com/michaelcontento/awsenv.git "$HOME/.awsenv"

2. Add `~/.awsenv/bin` to your `$PATH` for access to the [awsenv][] command-line
utility.

        $ echo 'export PATH="$HOME/.awsenv/bin:$PATH"' >> ~/.bash_profile

    **Zsh note:** Modify your `~/.zshenv` file instead of `~/.bash_profile`.

3. Add `awsenv init` to your shell to load the default environment.

        $ echo 'eval "$(awsenv init -)"' >> ~/.bash_profile

    **Zsh note:** Modify your `~/.zshenv` file instead of `~/.bash_profile`.

4. Restart your shell so the path changes take effect. You can now begin using
[awsenv][].

        $ exec $SHELL

### Upgrading

If you've installed [awsenv][] using the instructions above, you can upgrade 
your installation at any time using [git][].

To upgrade to the latest development version of [awsenv][], use `git pull`:

    $ cd ~/.awsenv
    $ git pull

Or use the builtin update command:

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

This is the only command that will modify your current shell. Here is what this
command does:

1. Executes `awsenv rehash`
2. Expose the usage of [awsenv][] to the world with the variables described
below
3. Prefix your current `PATH` with `~/.awsenv/amazon/bin` so that all [AWS][]
CLI tools are available
4. Configures various variables required by the [AWS][] tools:
    * `AWS_${TOOL}_HOME` for all tools
    * Credential variables (e.g. `AWS_CREDENTIAL_FILE`)
    * Variables regarding the used identity file (e.g. `AWS_IDENTITY_FILE`)
    * Try to define `JAVA_HOME`, if not already set
5. Add the used identity file to the `ssh-agent`

Run `awsenv init -` for yourself to see exactly what happens under the hood.

The special name `-` tells [awsenv][] to use the environment selected with
`awsenv use` previously.

[awsenv][] expose it's presence to the outside world with the following 
variables:

* `AWSENV_LOADED=1` indicates that [awsenv][] is loaded properly
* `AWSENV_NAME` contains the name of the currently used environment

### awsenv use

Set the global environment name to be used in all shells by writing the name to
the `~/.awsenv/default` file.

    $ awsenv use acme-corporation

All environments are stored as seperate directory in `~/.awsenv/env`.

### awsenv list

Display a list of all currently installed environments.

    $ awsenv list

### awsenv rehash

The [AWS][] CLI tools are located in `~/.awsenv/amazon` and *every* tool has his
own `/bin` directory for the executables. But if we would use these, your `PATH`
variable would be unreadable long. [awsenv][] avoids this by creating symlinks
for all executables in one directory called `~/.awsenv/amazon/bin`. And creating
these symlinks is the job of `awsenv rehash`.

    $ awsenv rehash

### awsenv import

This command helps you to import environments into [awsenv][]. Just read the 
help of this command, checkout the [awsenv-example-env][] repository and you 
should be able to setup all required files without any problems.

    $ awsenv import git git://github.com/michaelcontento/awsenv-example-env.git example

Currently only environments stored as [Git][] repository are supported. But you 
can help to expand this list by simply creating a new executable named 
`awsenv-import-<TYPE>`. Pull requests are welcome!

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
  [awsenv-example-env]: https://github.com/michaelcontento/awsenv-example-env
  [git]: http://git-scm.com
  [issue tracker]: https://github.com/michaelcontento/awsenv/issues
  [rbenv]: https://github.com/sstephenson/rbenv
  [sstephenson]: https://github.com/sstephenson
