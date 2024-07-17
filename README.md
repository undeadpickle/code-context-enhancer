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

## Usage Instructions

1. Prerequisites:

   - Bash shell environment (Linux, macOS, or Windows with WSL)
   - curl installed for API calls
   - jq installed for JSON parsing
   - An Anthropic API key (if using AI-generated descriptions)

2. Setup:

   - Save the script as `code_context_enhancer.sh`
   - Make the script executable: `chmod +x code_context_enhancer.sh`

3. Running the script:

   - Open a terminal and navigate to the directory containing the script
   - Execute the script: `./code_context_enhancer.sh`

4. Script Options:

   - Source folder: The directory containing the files you want to process
   - Destination folder: Where the processed files will be saved
   - File types: Specify which file types to process (e.g., "lua,py,js" or "all")
   - Process type: Choose between merged (M) or individual (I) file processing
   - AI descriptions: Opt to generate AI-powered descriptions for each file
   - Output file type: For merged processing, specify the output file extension

5. Processing Modes:

   - Merged: Combines all processed files into a single output file
   - Individual: Processes each file separately, maintaining the original structure

6. AI Descriptions:

   - If enabled, the script will use the Anthropic API to generate brief descriptions for each file
   - Model: claude-3-haiku-20240307
   - You'll need to input your Anthropic API key when prompted

7. Output:

   - Merged mode: A single file containing all processed scripts
   - Individual mode: Multiple files in a new directory, each containing a processed script

8. Safety Features:
   - The script will warn you about potential data modifications
   - You'll be prompted for confirmation before overwriting existing files

## Basic Example Scenario

Let's say you're a game developer working on a Roblox project, and you want to prepare your codebase for AI-assisted development using Claude.ai.

1. Project Structure:

   ```
   my_roblox_game/
   ├── src/
   │   ├── PlayerScripts/
   │   │   ├── PlayerMovement.lua
   │   │   └── Inventory.lua
   │   ├── ServerScripts/
   │   │   ├── GameLogic.lua
   │   │   └── DataStore.lua
   │   └── Shared/
   │       └── Utilities.lua
   ```

2. Running the Script:

   - Open a terminal and navigate to the parent directory of `my_roblox_game`
   - Run the script: `./code_context_enhancer.sh`

3. Script Interaction:

   ```
   ⚠️  WARNING ⚠️
   This script will modify file structures and generate new files.
   It may overwrite existing files in the destination directory.
   Please ensure you have backed up your data before proceeding.

   Do you understand and wish to continue? (y/N): y

   Source folder [./src]: my_roblox_game/src
   Destination folder [.]: my_roblox_game_codebase
   File types to process (comma-separated, or 'all' for all types) [all]: lua
   Process files ([M]erged/[I]ndividual) [M]: M
   Generate AI descriptions? ([Y]es/[N]o) [Y]: Y
   Please enter Anthropic API Key: <enter your API key>
   Output file type (e.g., txt, lua) [txt]: lua

   Generating description for PlayerScripts/PlayerMovement.lua...
   Processed: PlayerScripts/PlayerMovement.lua
   Generating description for PlayerScripts/Inventory.lua...
   Processed: PlayerScripts/Inventory.lua
   Generating description for ServerScripts/GameLogic.lua...
   Processed: ServerScripts/GameLogic.lua
   Generating description for ServerScripts/DataStore.lua...
   Processed: ServerScripts/DataStore.lua
   Generating description for Shared/Utilities.lua...
   Processed: Shared/Utilities.lua

   Merge complete. Total scripts merged: 5
   Merged file: my_roblox_game_codebase/merged_scripts_20240415_123456.lua
   ```

4. Result:
   You now have a single Lua file (`merged_scripts_20240415_123456.lua`) in the `my_roblox_game_codebase` directory. This file contains all your Roblox scripts, along with their file paths and AI-generated descriptions.

5. Using the Result:
   - Upload the merged file to Claude.ai's project files feature
   - When asking Claude for assistance, it will have context about your entire codebase
   - Example query: "Can you suggest improvements for the player movement system?"

This example demonstrates how the CodeContext Enhancer can help game developers organize their Roblox project files for more effective AI-assisted development. The script preserves the original file structure information while consolidating the code, making it easier for AI tools to understand the project context.

## ⚠️ Warning

This script modifies file structures and generates new files. Please be aware of the following risks:

- Existing file structures in the source directory may be altered.
- Files in the destination directory may be overwritten.
- New files will be generated, which could potentially clutter your workspace.

Always back up your data before running this script and carefully review the script's operations before execution.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.
