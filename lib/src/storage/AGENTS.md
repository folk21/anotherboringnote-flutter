# Storage adapter rules

Keep `AppStore` the platform seam. Use conditional platform files for dart:io. Native files must remain UTF-8, and writes should use temporary publication where possible; tests must cover interrupted/malformed state and future format protection. Browser storage is a separate adapter, not a claim of native file compatibility.
