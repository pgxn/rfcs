{{#title PGXN RFC–2 — Binary Distribution Format}}
*   **RFC:** 2
*   **Title:** Binary Distribution Format
*   **Slug:** `binary-distribution-format`
*   **Start Date:** 2024-06-18
*   **Status:** Proposed Standard
*   **Category:** Packaging
*   **Pull Request:** [pgxn/rfcs#2](https://github.com/pgxn/rfcs/pull/2)
*   **Implementation Issue:** TBD

# RFC--2 --- Binary Distribution Format

## Abstract

This RFC specifies the binary distribution format for [PGXN] packages, also
called the trunk format.[^wheel] A trunk is a ZIP-format archive with a
specially formatted file name and the `.trunk` extension. It contains a single
distribution nearly as it would be installed by [PGXS]. Although a specialized
installer is recommended, a trunk file may be installed by simply copying
directories of files to destinations defined by [pg_config].

## Introduction

Currently [PGXN] distributes only source code packages. Users wishing to
install and use PGXN distributions must install build tools, including `make`,
a compiler, and PostgreSQL development packages; then download, compile, and
install the distribution. Many users do not have the expertise to follow these
steps. Those wishing to use extension in a production environment may not wish
to include a compiler and tooling, let alone perform compilation, on a
production host, and so must find an appropriate binary package or else create
their own.

The proposed binary distribution format, or "trunk", aims to provide
pre-compiled PGXN distributions in a format that's straightforward to download
and install in directories defined by [pg_config]. This format will serve as a
building block for building comprehensive extension packaging for multiple
versions of PostgreSQL, CPU architectures, and --- unlike other packaging
systems, --- a diversity of operating systems, including Linux, macOS, various
BSDs, and Windows.

## Guide-level explanation

TODO.

<!--
Explain the proposal as if it already existed and you were teaching it to
another extension developer. That generally means:

*   Introducing new named concepts.
*   Explaining the feature largely in terms of examples.
*   Explaining how extension programmers should *think* about the feature, and
    how it should impact the way they use PGXN. It should explain the impact
    as concretely as possible.
*   If applicable, provide sample error messages, deprecation warnings, or
    migration guidance.
*   If applicable, describe the differences between teaching this to existing
    extension programmers and new extension programmers.
*   Discuss how this impacts the ability to develop, build and distribute
    extension packages.
 -->

## File Format

### File name convention

The trunk filename is:

```
{package}-{version}+{pg}-{platform}.trunk
```

Definition of variables:

*   `package`: Package name, e.g. `pgmq`, `postgis`, `pgAdmin`, `pg_top`.
*   `version`: Distribution version in [SemVer] format without build metadata,
    e.g., `0.8.6` or `1.0.0-beta`.
*   `pg`: Major version of Postgres the binary was built against, e.g.,
    `pg15`, `pg16`.
*   `platform`: The platform the binary was built for. Will be made up of one
    to three hyphen-delimited[^hyphen] values for the OS, version
    information[^PEPs], and CPU architecture. Examples: `any`,
    `gnulinux-amd64`, `darwin-23.5.0.arm64`, `musllinux-1.2-amd64v3`. The
    allowed values will be defined one or more separate RFCs.

#### Examples:

*   `pgtap-1.0.1+pg15-any.trunk` packages `pgtap` version 1.9.1, compatible
    with Postgres 15 (any minor release) on any platform.
*   `pair-0.32.1+pg16-gnulinux-amd64.trunk` packages `pair` version 0.32.1,
    compatible with Postgres 16 (any minor release) on GNU libc-based Linux
    for amd64 CPUs.
*   `pair-0.32.1+pg16-darwin-23.5.0-arm64.trunk` packages `pair` version
    0.32.1, compatible with Postgres 16 (any minor release) on Darwin version
    23.5.0 (macOS) for arm64 CPUs.

#### Escaping and Unicode

The `+` in the file name indicates the division between the package name and
version and the package metadata. The package name and version must not
include a `+`. This allows the file name, without the `.trunk` extension, to
also function as a valid [SemVer].

Tools producing trunks should verify that the filename components do not
contain `+`, as the resulting file may not be processed correctly if it does.

The package name should be lowercase and the file name components should all
be UTF-8.

The filenames *inside* the archive are encoded as UTF-8. Although some ZIP
clients in common use do not properly display UTF-8 filenames, the encoding is
supported by the ZIP specification.

#### Parsing

Parsing of the file name takes place in four parts:

1.  For the file name, remove the `.trunk` extension. If working with the
    directory name (prefix) extracted from the archive, there will be no
    `.trunk` extension.

2.  Split the name into two parts at the `+` sign. The left part is the
    package name and [SemVer]. The right part is the platform specification.

3.  For the left part, read the package name, including dashes (`-`), until a
    digit follows a dash. This dash indicates the end of the package name and
    the start of the [SemVer].

4.  Split the right string on dashes. There will be between two and four
    values as follows:

    *   Two: the postgres version (`pg16`) and `any`.
    *   Three: the postgres version (`pg16`), the OS (`gnulinux`, `darwin`,
        etc.), and the architecture (`amd64`, `arm64`, etc.)
    *   Four: the postgres version (`pg16`), the OS (`gnulinux`, `darwin`,
        etc.), the OS version (`23.5.0`) and the architecture (`amd64`,
        `arm64`, etc.)

##### Examples:

*   `pgtap-1.0.1+pg15-any`
    *   Package: `pgtap`
    *   Version: `1.0.1`
    *   Postgres: `pg15`
    *   Platform: `any`
*   `pair-0.32.1-beta1+pg16-gnulinux-amd64`
    *   Package: `pair`
    *   Version: `0.32.1-beta1`
    *   Postgres: `pg16`
    *   OS: `gnulinux`
    *   Architecture: `amd64`
*   `pair-0.32.1+pg16-darwin-23.5.0-arm64`
    *   Package: `pair`
    *   Version: `0.32.1`
    *   Postgres: `pg16`
    *   OS: `darin`
    *   OS Version: `23.5.0`
    *   Architecture: `arm64`

### File contents

The contents of a trunk file should unpack into a directory with the same name
as the file, but without the `.trunk` extension. The contents of the directory
are:

*   `trunk.json` contains metadata necessary to install the extension. The
    format wil be subject to a future RFC, but at a minimum will include the
    trunk format version, package version, dependencies, license, language and
    runtime (e.g., libc implementation and version), platform metadata, and
    Postgres version and build configuration. Trunk installers should warn if
    the trunk version is greater than the version it supports, and must fail
    if the Trunk version has a greater major version than the version it
    supports.

*   `digests` contains a list of (almost) all the files in the trunk and their
    secure hashes. Each line lists a single file and its checksum in the [BSD
    digest format]: `{algorithm} ({filename}) = {checksum}`. Every file except
    `digests` --- which cannot contain a hash of itself --- must be listed in
    this file. The cryptographic hash algorithm must be [SHA-256] or better;
    specifically, MD5 and SHA-1 are not permitted, as signed trunk files rely
    on the strong hashes in `digests` to validate the integrity of the
    archive.

*   The `pgsql` directory contains one or more subdirectories named for
    `pg_config` directory configurations: `bin`, `doc`, `html`, `include`,
    `pkginclude`, `lib`, `pkglib`, `locale`, `man`, `share`, and `sysconf`.
    Each contains the files to be installed in the corresponding `pg_config`
    directory.

*   Dynamic language scripts must appear in `pgsql/bin` and begin with exactly
    `'#!{cmd}`, where `cmd` is the name of the interpreter, in order to enjoy
    script wrapper generation and shebang rewriting at install time. They must
    have no extension. The list of supported interpreters will depend on the
    features of the installer, but one can reasonably expect support for
    [Perl], [Python], and [Ruby]. If no appropriate instance of the given
    interpreter is present, the installer may abort the installation.

*   `README`, `LICENSE`, and `CHANGELOG` may optionally be in the directory.
    Each must be plain text or Markdown-formatted. In the latter case, they
    may use the extension `.md`.

*   Trunk, being an installation format intended to install pre-compiled
    binaries and supporting files, does not include a `Makefile`, `configure`
    file or any other tool for building the package contents.

During extraction, trunk installers verify all the hashes in `digests` against
the file contents. Apart from `digests` and its signatures, installation will
fail if any file in the archive is not both mentioned and correctly hashed in
`digests`.

## Details

### Installing a Trunk

The following descriptions will use a trunk file named
`pair-0.32.1+pg16-gnulinux-amd64.trunk`. Trunk installation notionally
consists of two phases:

1.  Unpack
    *   Validate digests. Ensure that every file, aside from `digests` itself,
        is listed in `digest` along with it valid hash digest. If any file is
        missing or has an invalid digest, installation should fail. If a file
        listed in `digests` is not present, installation should fail.
    *   Parse the `trunk.json` file. Check that the distribution is compatible
        with:
        *   The trunk format version
        *   The platform (OS, OS version, and architecture); `any` is allowed
            for any platform
        *   The PostgreSQL version
2.  Install
    *   If applicable, update scripts starting with `#!{cmd}` to point to the
        correct interpreter. Fail if no such interpreter is present.
    *   Iterate over each subdirectory of the `pgsql` directory.
    *   If the directory corresponds to a directory configuration from
        [pg_config], install its contents in that target directory.

## Drawbacks

Many PostgreSQL extensions and applications are already distributed via
well-tested and -maintained packaging systems, including the community [Yum]
and [Apt] repositories.

However, these systems serve a limited number of OSes; macOS and Windows,
while served by their own packaging systems ([Homebrew] and [Chocolatey],
among others), have access to fewer packages and are less integrated into
community package distribution.

[PGXN] aims to be the canonical repository for all publicly-available
extensions, and to provide as many of them as possible in the same binary
format to a variety of OSes. The trunk format is a key component for realizing
that vision.

## Rationale and alternatives

This design is ideally suited to PostgreSQL extensions because it's built
around the installation and configuration options provided by [pg_config].
This short list of directories into which to install appropriate distribution
files is universal across OSes, and therefore suitable for distributing
binaries for, ultimately, every OS supported by PostgreSQL itself.

The alternatives available today include:

*    The community [Yum] and [Apt] repositories, which serve only Linux
     systems and require separate packages tied to the file layouts of those
     systems. The trunk format is OS-agnostic and provides files for any Linux
     distribution, regardless of the location of the PostgreSQL
     installation(s) on the file system.
*    [PGXMan] supports only Debian and Ubuntu Linux systems, and being
     downstream of the community [Apt] packages, is also dependent on its file
     layouts. Plans for macOS support have been promised, but the project
     has seen [little activity] in 2024.
*    [Trunk] inspired the design documented here, and from which it takes its
     name. That format is limited to a few file types, and lacks support for
     multiple OSes and architectures. This RFC may be considered an evolution
     of that format.
*    [StackBuilder] has little visibility or penetration beyond [EDB] Windows
     customers. I am unable to find a public list of available extensions or a
     description of the packaging format or how to contribute to it.

Without the trunk binary distribution format, it will be difficult to build
and deliver cross-platform binary distribution of all the packages on PGXN.

## Prior art

The design of the trunk binary distribution format is inspired by the original
[Trunk] format, which demonstrated a pattern for distributing extensions
agnostic of file locations. This design may be considered an evolution of the
[Trunk] registry format.

The design was also heavily inspired by the [Python wheel] format. Although
locations for installable files in the trunk format relate directly to
[pg_config] directories, most of the other aspects of the design were borrowed
from wheel, including the `digests` file and the `trunk.json` metadata file.

## Unresolved questions

*    Should the archive format be Zip or tarball? PGXN had traditionally used
     Zip, since it's supported everywhere, including Windows. So does the
     [Python Wheel] format. But many other packaging systems use tarballs,
     including [Homebrew] and [OCI]. The emerging idea to [distribute trunks
     via OCI registries] may favor tarballs.
*    The list of platforms to support and the strings to indicate them,
     including CPU alternatives, will be defined in a forthcoming RFC.

## Future possibilities

Some other ideas for the format, in either the short or long term:

*   Adopt the [Python wheel signing pattern]
*   Include an [SPDX SBOM](https://spdx.dev)?
*   Allow non-postgres libraries to be included, such as OS dependencies,
    either in the appropriate `pgsql` subdirectory or perhaps in a separate
    `sys` directory

## References

*   [Python Binary distribution format][Python wheel]
*   [trunk POC]
*   [Previous discussion]

  [^wheel]: With much inspiration and from and gratitude to the [Python wheel]
    format.
  [^hyphen]: Why hyphens? They allow the entire file name, between the package
    name and the `.trunk` extension, to be a valid [SemVer].
  [^PEPs]: See for example [PEP 600] defining Python wheel tags for different
    versions of GNU libc and [PEP 656] defining tags for different versions of
    musl libc. See also how [Homebrew] uses [macOS version names] in file
    names for its packages.

  [PGXN]: https://pgxn.org "PostgreSQL Extension Network"
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Docs: Extension Building Infrastructure"
  [pg_config]: https://www.postgresql.org/docs/current/app-pgconfig.html
    "PostgreSQL Docs: pg_config"
  [Python wheel]: https://packaging.python.org/en/latest/specifications/binary-distribution-format/
  [SemVer]: https://semver.org "Semantic Versioning 2.0.0"
  [PEP 600]: https://peps.python.org/pep-0600/
    "PEP 600 – Future ‘manylinux’ Platform Tags for Portable Linux Built Distributions"
  [PEP 656]: https://peps.python.org/pep-0656/
    "PEP 656 – Platform Tag for Linux Distributions Using Musl"
  [Homebrew]: https://brew.sh "Homebrew: The Missing Package Manager for macOS (or Linux)"
  [macOS version names]: https://github.com/oras-project/oras/issues/237#issuecomment-815250008
    "oras-project/oras#237 Comment from sjackman"
  [BSD digest format]: https://stackoverflow.com/q/1299833/79202
  [SHA-256]: https://en.wikipedia.org/wiki/SHA-2 "Wikipedia: SHA-2"
  [Perl]: https://perl.org "The Perl Programming Language"
  [Python]: https://python.org "The Python Programming Language"
  [Ruby]: https://ruby-lang.org/en/ "The Ruby Programming Language"
  [Yum]: https://yum.postgresql.org "PostgreSQL Yum Repository"
  [Apt]: https://wiki.postgresql.org/wiki/Apt "PostgreSQL packages for Debian and Ubuntu"
  [Homebrew]: https://brew.sh "The Missing Package Manager for macOS (or Linux)"
  [Chocolatey]: https://chocolatey.org "The Package Manager for Windows"
  [PGXMan]: https://pgxman.com "npm for PostgreSQL"
  [little activity]: https://github.com/pgxman/buildkit/commits/main/?since=2024-01-01&until=2024-07-11
  [Trunk]: https://pgt.dev "Trunk is an open-source package installer and registry for PostgreSQL extensions"
  [StackBuilder]: https://www.enterprisedb.com/docs/supported-open-source/postgresql/installing/using_stackbuilder/
  [EDB]: https://www.enterprisedb.com "Enterprise DB"
  [OCI]: https://github.com/opencontainers/image-spec/blob/main/media-types.md
    "OCI Image Media Types"
  [distribute trunks via OCI registries]: https://justatheory.com/2024/06/trunk-oci-poc/
    "POC: Distributing Trunk Binaries via OCI"
  [Python wheel signing pattern]: https://packaging.python.org/en/latest/specifications/binary-distribution-format/#signed-wheel-files
    "Python Binary distribution format: Signed wheel files"
  [trunk POC]: https://gist.github.com/theory/7dc164e5772cae652d838a1c508972ae
    "trunk POC using PGXS, bash, tar, shasum, and jq"
  [Previous discussion]: https://github.com/orgs/pgxn/discussions/2
    "Proposal: Binary Distribution Format"
