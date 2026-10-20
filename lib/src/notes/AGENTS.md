# Notes implementation rules

Keep note models and lifecycle independent from Flutter widgets, reader semantics, and platform APIs. Preserve version-1 KMP metadata names/meaning and plain-text recoverability. Reject incompatible future format versions without mutation; add tests for reconciliation and failed mutations.
