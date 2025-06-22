# Contributing to Gaming Laptop Pop!_OS Migration Guide

First off, thank you for considering contributing to this project! 🎉

This migration guide exists because of community efforts, and we welcome contributions that help more people successfully migrate their gaming laptops to Linux.

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

When reporting bugs, include:
- Your hardware specifications (CPU, GPU, laptop model)
- Pop!_OS version and kernel version
- Clear steps to reproduce the issue
- Expected behavior vs actual behavior
- Any error messages or logs
- Screenshots if applicable

### 💡 Suggesting Enhancements

Enhancement suggestions are welcome! Please:
- Use a clear and descriptive title
- Provide a detailed description of the proposed enhancement
- Explain why this enhancement would be useful
- Include examples or mockups if applicable

### 🔧 Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear messages (`git commit -m 'Add support for XYZ laptop'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

#### Pull Request Guidelines

- **Scripts**: Must pass shellcheck validation
- **Documentation**: Clear, concise, and properly formatted
- **Testing**: Confirm changes work on actual hardware when possible
- **Compatibility**: Ensure changes don't break existing functionality

### 📝 Documentation

Documentation improvements are highly valued! This includes:
- Fixing typos or grammatical errors
- Clarifying existing instructions
- Adding missing information
- Improving examples
- Adding support for new hardware

## Code Style Guidelines

### Bash Scripts
```bash
#!/bin/bash
# Use meaningful variable names
DISPLAY_CONFIG="/home/user/.config/displays"

# Add error handling
set -euo pipefail

# Comment complex operations
# This configures the external monitor for 144Hz gaming
xrandr --output DP-1 --mode 1920x1080 --rate 144

# Use functions for repeated code
check_nvidia_driver() {
    if ! command -v nvidia-smi &> /dev/null; then
        return 1
    fi
    return 0
}
```

### Markdown
- Use clear headings with proper hierarchy
- Include code blocks with language specification
- Add tables for structured data
- Use badges where appropriate
- Keep line length reasonable (80-100 chars)

## Testing

Before submitting:
1. Test scripts on fresh Pop!_OS installation if possible
2. Verify all commands work as expected
3. Check for typos and formatting issues
4. Ensure documentation matches code behavior

## Community Guidelines

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Celebrate successes and learn from failures
- Remember: we're all here to help people use Linux!

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Special mentions in release notes
- Credits section in documentation

## Questions?

Feel free to:
- Open a discussion in the [Discussions](https://github.com/omar-el-mountassir/gaming-laptop-popos-migration/discussions) tab
- Reach out via issues for clarification
- Join the Pop!_OS community forums

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make Linux gaming better for everyone! 🐧🎮