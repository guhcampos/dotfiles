# guhcampos dotfiles

This repository bootstraps a new workstation, configuring it to my taste. Currently it supports mostly MacOS workstations, since I haven't worked on a Linux machine for a while, but the idea is to support any UNIX operating system.

## Installation

### Requirements

Bootstrapping a new machine has a couple requirements:

- [`brew`](https://brew.sh)
- [`make`](https://www.gnu.org/software/make)

So if this is a brand new machine, you probably want to install them:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install make
```

Then deploy a new workstation from scratch:

```bash
make dotfiles
```

## Sandboxes

The workstation setup supports multiple `sandboxes` : dedicated user accounts for each workspace environment I work on: each `sandbox`  generally should not get mixed with the others, even if they are installed on the same machine.

 Each `sandbox`  gets a codename, so I can keep this repository public without giving away any projects or employers I might be working on at the moment.

>[!Note]
> Codenames use the [NATO Phonetic Alphabet](https://en.wikipedia.org/wiki/NATO_phonetic_alphabet) - I know I'm **Brazilian**, but these are the most generic names I could think of, and calling them anything else would potentially give hints about the project nature, which we want to avoid.

### Example

Say I've got a new Mac and I'm going to be working on projects `alpha`, `charlie` and `zulo` on that machine, I can just do:

```bash
make sandboxes alpha charlie zulo
```

and three users will be created on this machine, each with their own `$HOME` directories, dotfiles, keychains and completely isolated from each other by filesystem permissions and ACLS. I get write access to all their `$HOME` directories, so I can jump into each and work on them with complete isolation.

### Agents

Each `sandbox` also gets its own AI Agent: an instance of `opencode` that can be served using their credentials and to which I can connect to from my own shell or from the web, making it very easy to also do agentic coding with the proper isolation.

On a mac, the `opencode serve` instance for each `sandbox` is automatically triggered by `launchd` when a connection is first attempted. Connections can be initiated with:

for HTTP clients:

```bash
${HOME}/.local/bin/opencode-client <sandbox>
```

for ACP clients:

```bash
${HOME}/.local/bin/opencode-acp-client <sandbox>
```
