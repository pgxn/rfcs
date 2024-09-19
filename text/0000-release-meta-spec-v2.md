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
v2][v2] `META.json` provided by authors in PGXN uploads PGXN with signed
metadata about the release on PGXN. This will allow clients to verify the
validity of PGXN release sources via public key verification.

## Introduction

### Background

When [PGXN Manager] was implemented in 2010, it published release zip files
that contain author-supplied [PGXN Meta Spec v1][v1] metadata, and also
published an augmented `META.json` file with three additional properties
representing the release:

*    `user`: The name of the user who made the release
*    `date`: A timestamp for the release
*    `sha1`: A [SHA-1] digest of the release zip file

Clients were advised to download both this release `META.json` along with the
source zip file, and to validate the zip file against the checksum. The `user`
and `date` information were provided mainly for informational purposes.

Compare, for example, the pair-0.1.7 [release META.json] to the
author-provided [distribution META.json]. The difference is these three
fields:

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
signing] to validate that distribution files come from trusted sources. [PGXN
Meta Spec v2][v2] provides an opportunity to update the release `META.json`
format with signed metadata to enable a much more secure method of validation.

This RFC therefore proposes to extend [v2] distribution metadata with a single
additional property, `release`, that contains a [JWS JSON Serialization]
object as defined by [RFC 7515][JWS]. This property will allow clients not
only to find the release file to download and verify against checksums, but
also validate it against a public key provided by PGXN.

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
this JSON object (with blank space formatting removed):

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

A client **SHOULD** verify that the payload was signed by PGXN, and then use
the URI to download the release file and verify it with the SHA-512 digest.
This pattern ensures that, when validation is properly implemented, it is
rooted by PGXN's private key, and therefore the distribution file can be fully
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

The act of a making a new Release of a Distribution. The included `META.json`
**MUST** have an updated, unique version.

#### Release ####

A single release of a Distribution on PGXN, uniquely identified by the
Distribution name and Release version, and signed and published by PGXN.

#### JWS ####

[JWS], JSON Web Signature, represents content secured with digital signatures
or Message Authentication Codes (MACs) using JSON-based data structures. This
RFC proposes to us this standard to sign PGXN Releases.

### Process ###

A PGXN user maintains a `META.json` file as defined by [PGXN Meta Spec v2][v2]
as part of the source code package they distribute. This example provides
metadata for a distribution named `pair`, which contains a Postgres extension
of the same name:

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
    signing, signs with its private key, then adds the `release` object to the
    copied `META.json` file.

5.   PGXN Manager publishes the distribution archive and the `META.json` file
     to the root registry, along with an additional file that lists all the
     releases of the distribution. These files would be:

     *    Release list: `dist/pair.json`
     *    0.1.7 release `META.json`: `dist/pair/0.1.7/META.json`
     *    0.1.7 release zip file: `dist/pair/0.1.7/pair-0.1.7.zip`

#### Installing a Release ####

The steps for a client to find, download, and verify a PGXN release would be:

1.  Using a valid PGXN mirror, assemble and fetch the release list for the
    the extension, `dist/pair.json`.
2.  Use the release list to determine the best version to install and assemble
    the URI for its release `META.json`. The format is
    `dist/{name}/{version}/META.json`; for the above example, that results in
    `dist/pair/0.1.7/META.json`.
3.  Fetch the release `META.json` file, read in the `releases/pgxn` object,
    and use PGXN's public key to verify that it was signed by PGXN. Abort with
    an error if validation fails.
4.  Decode the payload and use its `uri` field to download the release zip
    file.
5.  Compare one of the digests from the payload to a digest generated from the
    downloaded zip file.
6.  If they digests are the same, continue with building and installing.
    Otherwise abort with an error.

## Reference-level explanation

This design ensures proper validation of PGXN releases by the following chain
of trust:

1.  A root key pair is maintained by PGXN, with the private key kept offline.
2.  A release key pair is generated and signed by the private root key, with
    the private key kept in an online vault accessible only to PGXN Manager.
3.  The public keys for both keys are published by PGXN. Clients should embed
    the root public key in their sources.
4.  PGXN Manager uses the private release key to sign releases as described
    above. The most important property in the signed payload is the list of
    digests.
5.  Clients can verify the signature with the public release and root keys.
6.  With the data validated, the client can download and verify the release
    file against a signed digest (preference order: `sha512`, `sha256`,
    `sha1`). In this manner, the authenticity of the release file can be
    verified all the way to the root key.

To support this infrastructure, PGXN Manager **MUST** be updated to properly
generate and sign the payload and include it in the release `META.json` files.
Clients **MUST** follow the [JWS validation steps].

### Release Object Properties

```json
#{
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
#}
```

The `release` property is a JSON object that supports a single key, `pgxn`. No
other keys are allowed except [v2] custom keys, which must start with `x_` or
`X_`.

The value for each property **MUST** be a [JWS JSON Serialization] JSON
object, defined as follows:

> *   **payload**: The "payload" member MUST be present and contain the value
>     `BASE64URL(JWS Payload)`.
>
> *   **signatures**: The "signatures" member value MUST be an array of JSON
>     objects. Each object represents a signature or MAC over the JWS Payload
>     and the JWS Protected Header. Its fields are:
>
> The following members are defined for use in the JSON objects that are
> elements of the "signatures" array:
>
> *   **protected**: The "protected" member **MUST** be present and contain
>     the value `BASE64URL(UTF8(JWS Protected Header))` when the JWS Protected
>     Header value is non-empty; otherwise, it MUST be absent.  These Header
>     Parameter values are integrity protected.
>
> *   **header**: The "header" member **MUST** be present and contain the
>     value JWS Unprotected Header when the JWS Unprotected Header value is
>     non- empty; otherwise, it MUST be absent.  This value is represented as
>     an unencoded JSON object, rather than as a string.  These Header
>     Parameter values are not integrity protected.
>
> *   **signature**: The "signature" member **MUST** be present and contain
>     the value `BASE64URL(JWS Signature)`.
>
> At least one of the "protected" and "header" members **MUST** be present for
> each signature/MAC computation so that an "alg" Header Parameter value is
> conveyed.
>
> Additional members can be present in both the JSON objects defined above; if
> not understood by implementations encountering them, they MUST be ignored.

#### PGXN Payload

For the `pgxn` JWS `payload` property, the value **MUST** be an object with
the following structure:

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

``` json
{
  "user": "the_grinch",
  "date": "2012-04-25T02:48:38Z",
  "uri": "dist/widget/0.0.1/widget-0.0.1.zip",
  "digests": {
    "sha1": "b7ecaa270e912a60e3dd919918004c6fcd4989c9"
  }
}
```

The format for the `payload` property in the `pgxn` JWS object is itself an
object. When formatting into the payload, its keys must appear in order (by
Unicode [code points] and) must contain no formatting-only blank space
("pretty printing"), but just a single line of JSON. In other words, before
Base64 URL-encoding the second example above, it must be formatted as:

```json
{"date":"2012-04-25T02:48:38Z","digests":{"sha1":"b7ecaa270e912a60e3dd919918004c6fcd4989c9"},"uri":"dist/widget/0.0.1/widget-0.0.1.zip","user":"the_grinch"}
```

The object **MUST** contain all of these properties:

*   **user**: The username of the PGXN user who uploaded the release.
*   **date**: The date of the release in [RFC 3339]/[ISO 8601] format in the
    UTC time zone (indicated by the `Z`).
*   **uri**: The URI for the release archive, relative to a PGXN mirror root,
    in the format `dist/{name}/{version}/{name}-{version}.zip`.
*   **digests**: An object containing hash digests for the file represented by
    the `uri` property. It **MUST** contain *at least* one of the following
    keys:
    *   **sha512**: A SHA-512 hash digest in hex format. Preferred.
    *   **sha256**: A SHA-256 hash digest in hex format.
    *   **sha1**: A SHA-1 hash digest in hex format. Deprecated; provided to
        support migration of release metadata from [v1 PGXN Metadata][v1].

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
    trustworthiness of releases published on PGXN. In the era of [supply chain
    attacks], it's essential for PGXN to enable compromise detection.

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

## Future possibilities

By embedding the PGXN [JWS] data under its own, key, `pgxn`, the design allows
for other parties to add their own release metadata and signatures. For
example, an organization that provides security scanning services may want to
add their own signature to validate that they have tested a specific release.

In the future we may also want to issue key pairs to registered developers and
require that they sign releases, as well. This would allow an extra level of
protection, plus allow key revocation in case an upload has been tampered
with.

For the PGXN signing itself the proposed use of a separate, offline "root" key
to sign an intermediate "release" key would allow for easier key rotation in
the event the "release" private key was compromised.

## Unresolved questions

*   Is `release` the best name for this new property? Yes the PGXN object
    represents signed release metadata, and eventually authors may also use
    the pattern to sign releases. But others may sign for different purposes,
    such as the security scanning example under [Future
    Possibilities](#future-possibilities). Should it perhaps be named
    `signatures` or similar, instead?

*   If we retain the format of keys in the `release` object pointing to
    signatures, should we relax the requirement that additional keys start
    with `x_` or `X_`? In the future if we allowed, say, author signatures,
    then we might add the key `author` or `release_user` or some such. Would
    we allow any other signatures to appear in the file on PGXN?

*   Should we eliminate the `digests` object in the `payload` and allow
    `SHA-512` only? I had made an object with `sha1` to simplify migration
    from the PGXN v1 spec, which includes only a `sha1` has, but maybe it'd be
    better to simplify the structure here and requires new SHA-512s from the
    migration.

    On the other hand, supporting only SHA-512 now means a bit less flexibility
    when it's time to add a new algorithm later. If we wanted to support, say,
    `SHA3-256` at a future date, would we add another field to the `payload`
    object and just let the client find the right one? Or is it better to keep
    a sub-object with multiples to simplify backward compatibility for clients
    that may not yet support a new algorithm?

*   For PGXN signing, how will the private and public keys be managed? Where
    will private keys be stored and secured, and where will public keys be
    published? Should they live in a separate domain, or some sort of key
    store, so clients can fetch them less fear of compromise? The fear is that
    someone may breach the root registry, modify extensions, and then sign
    them with their own keys, which replace our own keys.

    I *think* that, in general, if we can keep the root private key offline
    and use intermediate keys, we can recommend that clients include the root
    public key in their sources, so that any intermediate key breach can be
    detected.


  [PGXN]: https://pgxn.org "PostgreSQL Extension Network"
  [PGXN Manager]: https://manager.pgxn.org
  [v1]: 0001-meta-spec-v1.md "PGXN Meta Spec v1"
  [SHA-1]: https://en.wikipedia.org/wiki/SHA-1 "Wikipedia: SHA-1"
  [release META.json]: https://master.pgxn.org/dist/pair/0.1.7/META.json
  [distribution META.json]: https://api.pgxn.org/src/pair/pair-0.1.7/META.json
  [public key signing]: https://en.wikipedia.org/wiki/Digital_signature
    "Wikipedia: Digital signature"
  [v2]: 0003-meta-spec-v2.md "PGXN Meta Spec v2"
  [JWS]: https://www.rfc-editor.org/rfc/rfc7515.html "JSON Web Signature (JWS)"
  [JWS JSON Serialization]: https://www.rfc-editor.org/rfc/rfc7515.html#section-7.2
    "RFC 7515: JWS JSON Serialization"
  [IETF RFC 2119]: https://www.ietf.org/rfc/rfc2119.txt
  [JWS validation steps]: https://www.rfc-editor.org/rfc/rfc7515.html#section-5.2
    "RFC 7515: Message Signature or MAC Validation"
  [code points]: https://en.wikipedia.org/wiki/Code_point "Wikipedia: Code point"
  [RFC 3339]: https://www.rfc-editor.org/rfc/rfc3339.html
    "RFC 3339: Date and Time on the Internet: Timestamps"
  [ISO 8601]: https://en.wikipedia.org/wiki/ISO_8601 "Wikipedia: ISO 8601"
  [supply chain attacks]: https://en.wikipedia.org/wiki/Supply_chain_attack
    "Wikipedia: Supply chain attack"
  [Python wheel]: https://packaging.python.org/en/latest/specifications/binary-distribution-format/
