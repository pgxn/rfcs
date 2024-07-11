# PGXN RFCs --- [PGXN Book](https://rfcs.pgxn.org/)

[PGXN RFCs]: #pgxn-rfcs

The "RFC" (request for comments) process is intended to provide a consistent
and controlled path for changes to PGXN and the PostgreSQL extension
ecosystem, so that all stakeholders can be confident about the direction of
the project.

All changes, including bug fixes, documentation improvements, and the
introduction of new RFCs, can be implemented and reviewed via the normal
GitHub pull request workflow.

## Table of Contents
[Table of Contents]: #toc

*   [Opening](#rust-rfcs)
*   [Table of Contents]
*   [When you need to follow this process]
*   [Before creating an RFC]
*   [What the process is]
*   [The RFC life-cycle]
*   [Reviewing RFCs]
*   [Implementing an RFC]
*   [License]
*   [Contributions]


## When you need to follow this process
[When you need to follow this process]: #when-you-need-to-follow-this-process

You need to follow the PGXN RFC process to propose "substantial" changes to
[PGXN], its governance, packaging, and services, or the RFC process itself.
What constitutes a "substantial" change evolves based on community norms and
varies depending on what part of the ecosystem you are proposing to change,
but may include the following.

*   Any change to the metadata or distribution formats that is not a bugfix.
*   Creating new services or features expected to be provided as part of PGXN.
*   Removing features or decommissioning services

Some changes do not require an RFC:

*   Rephrasing, reorganizing, refactoring, or otherwise "changing shape does
    not change meaning".
*   Additions that strictly improve objective, numerical quality criteria
    (performance improvements, better platform coverage, etc.)

## Before creating an RFC
[Before creating an RFC]: #before-creating-an-rfc

A hastily-proposed RFC can hurt its chances of acceptance. Low quality
proposals, proposals for previously-rejected features, or those that don't fit
into the near-term roadmap may be quickly rejected --- which can be
demotivating for the unprepared contributor. Laying some groundwork ahead of
the RFC can make the process smoother.

Although there is no single way to prepare for submitting an RFC, it is
generally a good idea to pursue feedback from other project developers
beforehand, to ascertain that the RFC may be desirable; having a consistent
impact on the project requires concerted effort toward consensus-building.

The most common preparation for writing and submitting an RFC is talking the
idea over on the [PostgreSQL Slack].

## What the process is
[What the process is]: #what-the-process-is

In short, to get a major feature added to PGXN, one must first get the RFC
merged into the [RFC repository] as a markdown file. At that point the RFC is
"active" and may be implemented with the goal of eventual inclusion in PGXN.

*   Fork the RFC repo [RFC repository]
*   Copy `0000-template.md` to `text/0000-my-feature.md` (where "my-feature" is
    descriptive). Don't assign an RFC number yet; This is going to be the PR
    number and we'll rename the file accordingly if the RFC is accepted.
*   Fill in the RFC. Put care into the details: RFCs that do not present
    convincing motivation, demonstrate lack of understanding of the design's
    impact, or are disingenuous about the drawbacks or alternatives tend to
    be poorly-received.
*   Submit a pull request. As a pull request the RFC will receive design
    feedback from the broader community, and the author should be prepared to
    revise it in response.
*   Now that your RFC has an open pull request, use the issue number of the PR
    to rename the file: update your `0000-` prefix to that number. Also
    update the "RFC PR" link at the top of the file.
*   Build consensus and integrate feedback. RFCs that have broad support are
    much more likely to make progress than those that don't receive any
    comments.
*   The community will discuss the RFC pull request, as much as possible in
    the comment thread of the pull request itself. Offline discussion will be
    summarized on the pull request comment thread.
*   RFCs rarely go through this process unchanged, especially as alternatives
    and drawbacks are shown. You can make edits, big and small, to the RFC to
    clarify or change the design, but make changes as new commits to the pull
    request, and leave a comment on the pull request explaining your changes.
    Specifically, do not squash or rebase commits after they are visible on the
    pull request.
*   At some point, a PGXN maintainer will propose a "motion for final comment
    period" (FCP), along with a *disposition* for the RFC (merge, close, or
    postpone).
*   The FCP lasts ten calendar days, so that it is open for at least 5
    business days. It is also advertised widely, e.g., on [Planet PostgreSQL].
    This way all stakeholders have a chance to lodge any final objections
    before a decision is reached.
*   In most cases, the FCP period is quiet, and the RFC is either merged or
    closed. However, sometimes substantial new arguments or ideas are raised,
    the FCP is canceled, and the RFC goes back into development mode.

## The RFC life-cycle
[The RFC life-cycle]: #the-rfc-life-cycle

Once an RFC becomes "active", where authors may implement it and submit the
feature as a pull request to the appropriate PGXN repo. Being "active" is not
a rubber stamp, and in particular still does not mean the feature will
ultimately be merged; it does mean that in principle all the major
stakeholders have agreed to the feature and are amenable to merging it.

Furthermore, the fact that a given RFC has been accepted and is "active"
implies nothing about what priority is assigned to its implementation, nor
does it imply anything about whether a PGXN developer has been assigned the
task of implementing the feature. While it is not *necessary* that the author
of the RFC also write the implementation, it is by far the most effective way
to see an RFC through to completion: authors should not expect that other
project developers will take on responsibility for implementing their accepted
feature.

Modifications to "active" RFCs can be made in follow-up pull requests. We
strive to write each RFC in a manner that it will reflect the final design of
the feature; but the nature of the process means that we cannot expect every
merged RFC to actually reflect what the end result will be at the time of the
next major release.

In general, once accepted, RFCs should not be substantially changed. Only very
minor changes should be submitted as amendments. More substantial changes
should be submitted as new RFCs, with a note and link and added to the
original RFC.

## Reviewing RFCs
[Reviewing RFCs]: #reviewing-rfcs

The PGXN maintainers make final decisions about RFCs after the benefits and
drawbacks are well understood. When a decision is made, the RFC pull request
will either be merged or closed. In either case, if the reasoning is not clear
from the discussion in the pull request discussion, the maintainers will add a
comment describing the rationale for the decision.

## Implementing an RFC
[Implementing an RFC]: #implementing-an-rfc

Some accepted RFCs represent vital features that need to be implemented right
away. Other accepted RFCs can represent features that can wait until some
arbitrary developer feels like doing the work. Every accepted RFC has an
associated issue tracking its implementation in the relevant PGXN repository;
thus that associated issue can be assigned a priority via the triage process
used for all PGXN issues.

The author of an RFC is not obligated to implement it. Of course, the RFC
author (like any other developer) is welcome to post an implementation for
review after the RFC has been accepted.

If you are interested in working on the implementation for an "active" RFC,
but cannot determine if someone else is already working on it, feel free to
ask (e.g. by leaving a comment on the associated issue).

## License
[License]: #license

This Book is distributed under the [CC BY-SA 4.0] license.

Code Components extracted from this book document are licensed under the
[PostgreSQL License].

### Contributions
[Contributions]: #contributions

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the PostgreSQL
license, shall be dual licensed as above, without any additional terms or
conditions.

  [PGXN]: https://pgxn.org "PostgreSQL Extension Network"
  [PostgreSQL Slack]: https://pgtreats.info/slack-invite
  [RFC repository]: https://github.com/pgxn/rfcs
  [Planet PostgreSQL]: https://planet.postgresql.org
  [CC BY-SA 4.0]: https://creativecommons.org/licenses/by-sa/4.0/
    "Attribution-Sharealike 4.0 International"
  [PostgreSQL License]: https://www.postgresql.org/about/licence/
