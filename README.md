# CodeContext Enhancer

## Purpose

CodeContext Enhancer is a bash script designed to optimize project file structures for advanced AI-powered development tools, particularly Claude.ai's project files feature and other Retrieval-Augmented Generation (RAG) applications. Its primary goal is to enhance AI comprehension of codebases, leading to more accurate and context-aware AI-generated responses in development workflows.

## Features

- Project structure flattening
- AI-powered file descriptions (optional)
- Flexible processing (merged or individual files)
- Multi-file type support
- Anthropic API integration for description generation
- Error handling and retry mechanisms
- User-friendly interface with customizable options

## Usage

1.  Clone the repository
2.  Make the script executable: `chmod +x code_context_enhancer.sh`
3.  Run the script: `./code_context_enhancer.sh`
4.  Follow the prompts to configure the script's behavior

Note: If using AI-powered descriptions, you'll need an Anthropic API key. Never commit or share your API key.

## ⚠️ Warning

This script modifies file structures and generates new files. Please be aware of the following risks:

- Existing file structures in the source directory may be altered.
- Files in the destination directory may be overwritten.
- New files will be generated, which could potentially clutter your workspace.

Always back up your data before running this script and carefully review the script's operations before execution.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.
