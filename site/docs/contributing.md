# Contributing

Help improve PawMate AI Challenge.

## Ways to Contribute

### 1. Submit Benchmark Results

The most valuable contribution: run benchmarks and submit results.

**Why it helps:**
- Builds public dataset
- Enables tool comparisons
- Identifies edge cases
- Validates specification

**How:**
1. [Install the CLI](/getting-started)
2. [Run benchmarks](/run-benchmark)
3. [Submit results](/submit-results)

### 2. Improve Documentation

Help make docs clearer and more complete.

**What to improve:**
- Fix typos and grammar
- Add examples
- Clarify confusing sections
- Update outdated information
- Add troubleshooting tips

**How:**
- Edit pages on GitHub
- Submit pull requests
- Open issues for suggestions

### 3. Enhance the CLI

Improve the PawMate command-line tool.

**Ideas:**
- Better error messages
- Additional validation
- New features
- Performance improvements
- Cross-platform compatibility

**How:**
- Fork the repository
- Make changes
- Submit pull request
- Include tests

### 4. Refine the Specification

Propose improvements to benchmark requirements.

**Types of changes:**
- Clarify ambiguous requirements
- Fix inconsistencies
- Add missing details
- Improve testability

**How:**
- Open GitHub issue
- Describe the problem
- Propose solution
- Discuss with maintainers

**Note:** Spec changes follow semantic versioning.

### 5. Report Bugs

Found a bug? Let us know.

**What to include:**
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment (OS, Node version, CLI version)
- Error messages

**Where:**
- CLI bugs: [pawmate-ai-challenge/issues](https://github.com/fastcraft-ai/pawmate-ai-challenge/issues)
- Results bugs: [pawmate-ai-results/issues](https://github.com/fastcraft-ai/pawmate-ai-results/issues)

### 6. Suggest Features

Have an idea? Share it!

**Good feature requests:**
- Solve a real problem
- Align with project goals
- Include use cases
- Consider implementation complexity

**How:**
- Open GitHub issue
- Use "enhancement" label
- Describe the feature
- Explain the benefit

## Getting Started

### Prerequisites

**For CLI development:**
- Node.js 18+
- npm or yarn
- Git
- Familiarity with Node.js and ES modules

**For documentation:**
- Markdown knowledge
- VitePress familiarity (helpful)
- Git basics

### Clone the Repository

```bash
git clone https://github.com/fastcraft-ai/pawmate-ai-challenge.git
cd pawmate-ai-challenge
```

### Development Setup

**CLI:**
```bash
cd pawmate-ai-challenge/cli
npm install
npm link  # Makes 'pawmate' command available locally
```

**Documentation:**
```bash
cd pawmate-site
npm install
npm run docs:dev  # Start dev server at http://localhost:5173
```

## Contribution Workflow

### 1. Fork and Branch

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR-USERNAME/pawmate-ai-challenge.git

# Create a feature branch
git checkout -b feature/your-feature-name
```

### 2. Make Changes

**Code style:**
- Follow existing conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused

**Documentation:**
- Use clear, concise language
- Include code examples
- Follow markdown formatting
- Test all links

### 3. Test Your Changes

**CLI changes:**
```bash
# Install locally
npm link

# Test the command
pawmate init --profile model-a-rest --tool "Test"

# Run tests (if available)
npm test
```

**Documentation changes:**
```bash
# Preview locally
npm run docs:dev

# Build to verify
npm run docs:build
```

### 4. Commit and Push

```bash
# Stage changes
git add .

# Commit with clear message
git commit -m "Add feature: description of what changed"

# Push to your fork
git push origin feature/your-feature-name
```

### 5. Submit Pull Request

1. Go to GitHub
2. Click "New Pull Request"
3. Select your fork and branch
4. Fill out PR template
5. Wait for review

## Pull Request Guidelines

**Good PRs:**
- Solve one problem
- Include clear description
- Add tests (if applicable)
- Update documentation
- Follow code style
- Reference related issues

**PR Template:**
```markdown
## Description
Brief description of changes

## Motivation
Why is this change needed?

## Changes
- List of specific changes
- Each on a new line

## Testing
How did you test this?

## Checklist
- [ ] Code follows project style
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] All tests passing
```

## Code Review Process

1. **Submission:** You submit PR
2. **Automated checks:** CI runs (if configured)
3. **Review:** Maintainer reviews code
4. **Feedback:** Requested changes (if any)
5. **Updates:** You address feedback
6. **Approval:** Maintainer approves
7. **Merge:** PR is merged

**Response time:** Usually within 7 days

## Specification Changes

Spec changes follow a stricter process:

### Minor Changes (v2.7 → v2.8)

**Additive changes only:**
- New optional requirements
- Additional guidance
- Clarifications
- Documentation improvements

**Process:**
1. Open GitHub issue
2. Discuss need and approach
3. Submit PR with changes
4. Maintainer approves
5. Version bumped (minor)

### Major Changes (v2.x → v3.0)

**Breaking changes:**
- Changed requirements
- Removed features
- Different data models
- Incompatible APIs

**Process:**
1. Open GitHub issue for discussion
2. Create RFC (Request for Comments)
3. Community review period (14+ days)
4. Incorporate feedback
5. Submit PR
6. Maintainer approval
7. Version bumped (major)

## Documentation Style Guide

### Voice and Tone

- **Clear:** Simple, direct language
- **Helpful:** Anticipate reader needs
- **Professional:** No slang or jargon
- **Encouraging:** Positive tone

### Formatting

**Headers:**
```markdown
# Page Title (H1) - One per page
## Major Section (H2)
### Subsection (H3)
#### Detail (H4) - Use sparingly
```

**Code blocks:**
```markdown
```bash
# Always specify language
command --option value
```
```

**Lists:**
```markdown
- Unordered lists for related items
- Each item starts with capital
- End with period if complete sentence

1. Ordered lists for sequential steps
2. Number automatically
3. Keep items parallel in structure
```

**Links:**
```markdown
[Descriptive text](/path/to/page)
[External link](https://example.com)
```

**Emphasis:**
```markdown
**Bold** for strong emphasis
*Italic* for mild emphasis
`code` for inline code
```

## Testing Contributions

**CLI changes should include:**
- Unit tests for new functions
- Integration tests for commands
- Manual testing on macOS, Windows, Linux

**Documentation changes should verify:**
- All links work
- Code examples are correct
- Builds without errors
- Renders correctly

## Recognition

Contributors are recognized:
- In CHANGELOG.md
- In release notes
- In repository README
- On the website (for significant contributions)

## Code of Conduct

**Be respectful:**
- Assume good intentions
- Give constructive feedback
- Accept criticism gracefully
- Help newcomers

**Be collaborative:**
- Share knowledge
- Review others' work
- Document decisions
- Communicate clearly

**Be professional:**
- Stay on topic
- Avoid personal attacks
- Resolve conflicts maturely
- Follow project guidelines

## Questions?

**Before contributing:**
- Check [existing issues](https://github.com/fastcraft-ai/pawmate-ai-challenge/issues)
- Read the [documentation](/getting-started)
- Review [past PRs](https://github.com/fastcraft-ai/pawmate-ai-challenge/pulls?q=is%3Apr+is%3Aclosed)

**Need help?**
- Open a GitHub issue
- Ask in existing discussions
- Email: pawmate.ai.challenge@gmail.com

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Thank You!

Every contribution helps make PawMate better. Whether you submit benchmarks, fix typos, or propose features, your help is appreciated.

[Start contributing →](https://github.com/fastcraft-ai/pawmate-ai-challenge)

