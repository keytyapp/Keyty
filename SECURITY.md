# Security Policy

## Supported Versions

Only the latest publicly released version of Keyty receives security updates.

## Reporting a Vulnerability

Functional defects with no security impact are regular application bugs and
should be reported through GitHub Issues.

Use GitHub's private vulnerability reporting form only for vulnerabilities that
allow an attacker, through an untrusted process, a maliciously crafted update,
or a tampered release artifact, to bypass Keyty's expected trust boundaries.
This includes issues such as:

- Executing attacker-controlled code or commands
- Installing or accepting an untrusted update as trusted
- Bypassing expected signing, notarization, or update integrity checks
- Accessing permission-protected behavior in a way the user did not authorize
- Causing unexpected disclosure of local input or other sensitive local data

A report should include the affected Keyty version, macOS version, a
description of the vulnerability and expected impact, and the steps required to
reproduce it.

Reports will be reviewed as soon as possible, but no specific response or
resolution timeframe is guaranteed.
