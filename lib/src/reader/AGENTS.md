# Reader implementation rules

Reader state is presentation-only. Retain semantic four-mode typography, reflow zoom bounds, font/color fallback, and versioned reader.properties. The reader must never write note content. Mobile orientation is an integration effect and must be restored on reader exit.
