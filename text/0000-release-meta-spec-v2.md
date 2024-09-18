{{#title PGXN RFC–0 — PGXN Release Meta Spec v2}}
*   **RFC:** 0 (fill in with pull request number)
*   **Title:** PGXN Release Meta Spec v2
*   **Slug:** `release-meta-spec-v2`
*   **Start Date:** 2024-09-18
*   **Status:** Proposed Standard
*   **Category:** Packaging
*   **Pull Request:** [pgxn/rfcs#4](https://github.com/pgxn/rfcs/pull/4)
*   **Implementation Issue:** TBD

# RFC--0 --- PGXN Release Meta Spec v2

## Abstract

This document describes version 2.0.0 of the *release* format for [PGXN]
source distribution metadata. It extends the *distribution* [PGXN Meta Spec
v2] `META.json` provided by authors in PGXN uploads PGXN with signed metadata
about the release on PGXN. This will allow clients to verify the validity of
PGXN release sources via public key verification.

## Introduction

### Background

When [PGXN Manager] was implemented in 2010, in addition to publishing release
zip files that contain author-supplied [PGXN Meta Spec v1] metadata, it also
published an augmented `META.json` file, appending three fields representing
the release:

*    `user`: The name of the user who made the release
*    `date`: A timestamp for the release
*    `sha1`: A [SHA-1] digest of the release zip file

This allowed clients to download a source zip file and validate it against the
checksum. The `user` and `date` information were provided mainly for
informational purposes.

Compare, for example, pair-0.1.7 [release META.json] to the author-provided
[distribution META.json]. The difference is these three fields:

``` json
{
  "user": "theory",
  "date": "2020-10-25T21:54:02Z",
  "sha1": "5b9e3ba948b18703227e4dea17696c0f1d971759"
}
```

Using the release metadata, a client can determine the URL to download the zip
file, then validate it against the SHA-1 digest.

### Signed Releases

A lot has changed since 2010, including an increasing need for [public key
signing] to validate that distribution files come from validated sources.
[PGXN Meta Spec v2] provides an opportunity to include signed metadata to
enable a much more secure method of validation.

This RFC therefore proposes to extend [PGXN Meta Spec v2] distribution
metadata with a single additional property, `release`, that contains an [JWS
JSON Serialization] object as defined by [RFC 7515][JWS]. This will allow
clients not only to find the release file to download and verify it against
checksums, but also validate it against a public key provided by PGXN.

The design allows multiple digital signatures, which in the future may allow
authors or other entities to sign releases with their own keys. The new format
would append a structure such as this to the distribution `META.json` file:

``` json
{
  "release": {
     "pgxn": {
       "payload": "eyJ1c2VyIjoidGhlb3J5IiwiZGF0ZSI6IjIwMjQtMDktMTNUMTc6MzI6NTVaIiwidXJpIjoiZGlzdC9wYWlyLzAuMS43L3BhaXItMC4xLjcuemlwIiwiZGlnZXN0cyI6eyJzaGE1MTIiOiJiMzUzYjVhODJiM2I1NGU5NWY0YTI4NTllN2EyYmQwNjQ4YWJjYjM1YTdjMzYxMmIxMjZjMmM3NTQzOGZjMmY4ZThlZTFmMTllNjFmMzBmYTU0ZDdiYjY0YmNmMjE3ZWQxMjY0NzIyYjQ5N2JjYjYxM2Y4MmQ3ODc1MTUxNWI2NyJ9fQ",
       "signatures": [
          {
            "protected":"eyJhbGciOiJSUzI1NiJ9",
            "header": {"kid": "2024-12-29" },
            "signature": "cC4hiUPoj9Eetdgtv3hF80EGrhuB__dzERat0XF9g2VtQgr9PJbu3XOiZj5RZmh7AAuHIm4Bh-rLIARNPvkSjtQBMHlb1L07Qe7K0GarZRmB_eSN9383LcOLn6_dO--xi12jzDwusC-eOkHWEsqtFZES c6BfI7noOPqvhJ1phCnvWh6IeYI2w9QOYEUipUTI8np6LbgGY9Fs98rqVt5AXLIhWkWywlVmtVrBp0igcN_IoypGlUPQGe77Rw"
          }
       ]
     }
  }
}
```

This example includes a PGXN release signature. The data signed is the contents
of the `payload` property, which is the Base64 URL-encoded representation of
this JSON object (without the blank space):

``` json
{
  "user": "theory",
  "date": "2024-09-13T17:32:55Z",
  "uri": "dist/pair/0.1.7/pair-0.1.7.zip",
  "digests": {
    "sha512": "b353b5a82b3b54e95f4a2859e7a2bd0648abcb35a7c3612b126c2c75438fc2f8e8ee1f19e61f30fa54d7bb64bcf217ed1264722b497bcb613f82d78751515b67"
  }
}
```

This would allow a client to verify that the payload was signed by PGXN, and
then use the URI to download the release file and verify it with the SHA-512
digest. This ensures that, when validation is properly followed, it is rooted
by PGXN's private key, and therefore the distribution file can be fully
trusted as unmodified since PGXN signed it.

## Guide-level explanation

### Terminology ###

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [IETF RFC 2119].

This RFC makes use of the following additional terms:

#### Distribution ####

A named source code package published by a PGXN user. Each time a user
publishes a new version, it's considered a *Release* of the *Distribution"*.

#### Distribution Metadata ####

The `META.json` file maintained by the distribution author and updated with a
new version and any other relevant changes on each release.

#### Upload ####

The act of a user wishing to make a new Release of a distribution. The
included `META.json` should have an updated, unique version.

#### Release ####

A single release of a Distribution on PGXN, uniquely identified by the
Distribution name and Release version, and signed and published by PGXN.

#### JWS ####

[JWS], JSON Web Signature, represents content secured with digital signatures
or Message Authentication Codes (MACs) using JSON-based data structures. This
data format and key-signing pattern to be used by PGXN.

### Process ###

A PGXN user maintains a `META.json` file as defined by [PGXN Meta Spec v2] as
part of the source code package they distribute. A minimal example for an
extension distribution named `pair`, which contains a Postgres extension of
the same name:

```json
{
  "name": "pair",
  "abstract": "A key/value pair data type",
  "version": "0.1.7",
  "maintainers": [
    {
      "name": "David E. Wheeler",
      "email": "david@justatheory.com"
    }
  ],
  "license": "PostgreSQL",
  "contents": {
    "extensions": {
      "pair": {
        "sql": "sql/pair.sql",
        "control": "pair.control"
      }
    }
  },
  "meta-spec": { "version": "2.0.0" }
}
```

#### Publishing a Release ####

The steps to publish a signed release on PGXN would be:

1.  User updates the version in the `META.json` as appropriate for the
    release, then bundles the `META.json` file and all required and
    recommended source code and documentation files into a zip file. From a
    Git repository, for example:

    ```sh
    	git archive --format zip --prefix=pair-0.1.7/ -o pair-0.1.7.zip HEAD
    ```

2.  User uploads the file to [PGXN Manager].

3.  PGXN Manager validates the `META.json` file and, in some cases, rewrites
    the uploaded file (if it doesn't have the directory prefix, for example, or
    is uploaded in some other archive format than zip).

4.  PGXN Manager copies the `META.json` file, constructs the payload for
    sighing, signs with its public key, then adds the `release` object to the
    copied `META.json` file.

5.   PGXN Manager publishes the distribution archive and the `META.json` file
     to the root repository, along with an additional file that lists all the
     releases of the distribution. These files would be:

     *    Release list: `dist/pair.json`
     *    0.1.7 release `META.json`: `dist/pair/0.1.7/META.json`
     *    0.1.7 release zip file: `dist/pair/0.1.7/pair-0.1.7.zip`

#### Installing a Release ####

The steps for a client to find, download, and verify a PGXN release would be:

1.  Using a valid PGXN mirror, assemble and fetch the release list for the
    the extension, `dist/pair.json`.
2.  Use the release list to determine the best version to install and
    assemble its release `META.json` URI. The format is
    `dist/{name}/{version}/META.json`; for the above example, that results
    in `dist/pair/0.1.7/META.json`.
3.  Fetch the release `META.json` file, read in the `releases/pgxn` object,
    and use PGXN's public key to verify that it was signed by PGXN.
4.  Decode the payload and use its `uri` field to download the release zip
    file.
5.  Compare the the `sha512` digest from the payload to a digest generated
    from the downloaded zip file.
6.  If they digests are the same, continue with building and installing.
    Otherwise abort with an error.

## Reference-level explanation

This design ensures proper validation of PGXN releases by the following chain
of trust:

1.  A root key pair is maintained by PGXN, with the private key kept offline.
2.  A release key pair is generated and signed by the private root key, with
    the private key kept in an online vault accessible only to PGXN Manager.
3.  The public keys for both keys are published by PGXN.
4.  PGXN Manager uses the private release key to sign releases as described
    above. The most important property in the signed payload is the list of
    digests.
5.  Clients can verify the signature with the public release and root keys.
6.  With the data validated, the client can download and verify the release
    file against a signed digest. In this manner, the authenticity of the
    release file can be verified all the way to the root key.

To support this infrastructure, PGXN Manager **MUST** be updated to properly
generate and sign the payload and include it in the release `META.json` files.
Clients **MUST** follow the [JWS validation steps].

## Drawbacks

*   This pattern could make it more difficult for clients to install code from
    PGXN, especially if they incorrectly validate the signature.
*   Some clients may choose not to implement the validation, potentially
    leaving users to think they have trusted, validated code when they may
    not.

## Rationale and alternatives

*   This design takes advantage of the [JWS] standard to naturally augment the
    PGXN `META.json` format to enable best-in-class digital signatures and
    validation.
*   Without key signing, questions will gradually mount as to the
    trustworthiness of releases published on PGXN. In the era of [what's teh
    word I want here?] compromises, it's essential for PGXN to enable
    compromise detection.

## Prior art

This design was inspired by the [Python wheel] format, particularly its
precedent of signing only the hash digests for a package rather than the
package itself. The use of [JWS JSON Serialization] varies from [Python
wheel], and is enabled by the separation of the release `META.json` file from
the release file it describes.

The use of [JWS] ensures a widely-vetted key signing and distribution
standard, and the likelihood that clients can take advantage of well-tested,
mature libraries to handle signing and validation. And finally, its design
allows for key rotation when necessary.

## Unresolved questions

None currently.

## Future possibilities

By embedding the PGXN [JWS] data under its own, key, `pgxn`, the design allows
for other parties to add their own release metadata and signatures. For
example, an organization that provides security scanning services may want to
add their own signature to validate that they have tested a specific release.

For the PGXN signing itself the proposed use of a separate, offline "root" key
to sign an intermediate "release" key would allow for easier key rotation in
the event the "release" private key was compromised.

  [PGXN]: https://pgxn.org "PostgreSQL Extension Network"
  [PGXN Manager]: https://manager.pgxn.org
  [PGXN Meta Spec v1]: 0001-meta-spec-v1.md
  [SHA-1]: https://en.wikipedia.org/wiki/SHA-1 "Wikipedia: SHA-1"
  [release META.json]: https://master.pgxn.org/dist/pair/0.1.7/META.json
  [distribution META.json]: https://api.pgxn.org/src/pair/pair-0.1.7/META.json
  [public key signing]: https://en.wikipedia.org/wiki/Digital_signature
    "Wikipedia: Digital signature"
  [PGXN Meta Spec v2]: 0003-meta-spec-v2.md
  [JWS]: https://www.rfc-editor.org/rfc/rfc7515.html "JSON Web Signature (JWS)"
  [JWS JSON Serialization]: https://www.rfc-editor.org/rfc/rfc7515.html#section-7.2
    "RFC 7515: JWS JSON Serialization"
  [IETF RFC 2119]: https://www.ietf.org/rfc/rfc2119.txt
  [JWS validation steps]: https://www.rfc-editor.org/rfc/rfc7515.html#section-5.2
    "RFC 7515: Message Signature or MAC Validation"
