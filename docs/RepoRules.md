# Repository Rules

**Last Updated**: 2025-12-20

This file contains repository-specific rules and conventions that guide AI interactions and code transformations.

---

## Conventions

### Naming Conventions

"variable_name": "auto-detected"
"function_name": "auto-detected"
"class_name": "auto-detected"
"enum_name": "auto-detected"
"file_name": "auto-detected"

### Include Patterns

"include_allowed_in_all_headers": true
"use_primary_header": true
"include_primary_header_in_impl": true

---

## Architecture Rules

### General Principles

- Add architecture rules here
- Example: All domain logic must be in the core/ directory
- Example: UI components should not directly access database

---

## Security Rules

### Security Guidelines

- Add security rules here
- Example: Never log sensitive data
- Example: Always validate user input at API boundaries

---

## Performance Rules

### Performance Guidelines

- Add performance rules here
- Example: Avoid N+1 queries in ORM code
- Example: Use connection pooling for database access

---

## Style Rules

### Code Style

- Add style rules here
- Example: Maximum line length: 100 characters
- Example: Use spaces, not tabs (4 spaces per indent)

---

## Notes

These rules are injected into AI prompts based on context. Use natural language that AI can understand.

To update conventions automatically, run:
```bash
maestro repo conventions detect
```

To refresh all repository metadata:
```bash
maestro repo refresh all
```
