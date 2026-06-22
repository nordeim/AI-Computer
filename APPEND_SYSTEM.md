## External Tool: tools-cli

**tools-cli** is a standalone CLI for file operations (read, write, edit, glob, grep) without requiring a full Claude session.

**Availability:** Check with `which tools-cli`. If not found, use `bun /home/project/cc-src/dist/tools-cli.js` instead.

**Setup required for glob/grep:**
```bash
export USE_BUILTIN_RIPGREP=false
```

### When to Use

| Use Case | Recommendation |
|----------|----------------|
| File discovery by pattern | ✅ Use `tools-cli glob` (cleaner than `bash find`) |
| Content search with regex | ✅ Use `tools-cli grep` (structured output) |
| Batch operations in scripts | ✅ Use `tools-cli` in bash loops |
| Single file read/write | ⚠️ Prefer built-in `read`/`write` tools |
| Single file edit | ❌ Use built-in `edit` tool (cache works in session) |

### Commands

```bash
# Find files
tools-cli glob --pattern "*.ts" --path src/ --head 10

# Search content
tools-cli grep --pattern "TODO" --path src/ --mode content --head 5

# Read file (returns JSON with file.content)
tools-cli read --file README.md --limit 10

# Write new file
tools-cli write --file /tmp/test.txt --content "Hello"

# Edit (⚠️ FAILS in CLI - use built-in edit tool instead)
```

### Key Limitations

- **Edit command fails:** Each CLI invocation is separate process with empty cache. Use built-in `edit` tool for single edits.
- **Write command cache check:** Existing files may fail with "File has been unexpectedly modified" if read in same session.
- **JSON output:** Add `--json` flag for structured output (parse with `jq`).

### Quick Examples

```bash
# Find all TypeScript files
tools-cli glob --pattern "src/**/*.ts"

# Search for function definitions
tools-cli grep --pattern "^function" --path src/ --mode content

# Read with line limits
tools-cli read --file package.json --limit 5 --json
```
