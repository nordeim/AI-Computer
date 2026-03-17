mv /usr/lib/node_modules /usr/lib/node_modules.1
ln -sf /Home1/neon/node_modules /usr/lib/node_modules
ln -sf /Home1/neon/node_modules/pnpm/bin/pnpm.cjs /usr/bin/pnpm
ln -sf /Home1/neon/node_modules/pnpm/bin/pnpx.cjs /usr/bin/pnpx
ln -sf /Home1/neon/node_modules/@musistudio/claude-code-router/dist/cli.js /usr/bin/ccr
ln -sf /Home1/neon/node_modules/@google/gemini-cli/dist/index.js /usr/bin/gemini
ln -sf /Home1/neon/node_modules/@anthropic-ai/claude-code/cli.js /usr/bin/claude
ln -sf /Home1/neon/node_modules/@upstash/context7-mcp/dist/index.js /usr/bin/context7-mcp
#ln -sf /Home1/neon/node_modules/@qwen-code/qwen-code/bundle/gemini.js /usr/bin/qwen
ln -sf /Home1/neon/node_modules/@qwen-code/qwen-code/dist/index.js /usr/bin/qwen
ls -L /usr/bin/claude  || ln -sf /Home1/neon/node_modules/@anthropic-ai/claude-code/cli.js /usr/bin/claude
ls -L /usr/bin/gemini || ln -sf /Home1/neon/node_modules/@google/gemini-cli/dist/index.js /usr/bin/gemini
ls -L /usr/bin/ccr || ln -sf /Home1/neon/node_modules/@musistudio/claude-code-router/dist/cli.js /usr/bin/ccr
ls -L /usr/bin/pnpm || ln -sf /Home1/neon/node_modules/pnpm/bin/pnpm.cjs /usr/bin/pnpm
ls -L /usr/bin/pnpx || ln -sf /Home1/neon/node_modules/pnpm/bin/pnpx.cjs /usr/bin/pnpx
ln -sf /Home1/neon/node_modules/@openai/codex/bin/codex.js /usr/bin/codex
# ccr -> ../lib/node_modules/@musistudio/claude-code-router/dist/cli.js
# gemini -> ../lib/node_modules/@google/gemini-cli/dist/index.js
# claude -> ../lib/node_modules/@anthropic-ai/claude-code/cli.js
# pnpm -> ../lib/node_modules/pnpm/bin/pnpm.cjs
# pnpx -> ../lib/node_modules/pnpm/bin/pnpx.cjs
ln -sf /Home1/kiro /usr/share/kiro
ln -sf /Home1/kiro/bin/kiro /usr/bin/kiro
ls -L /usr/share/code || mv /usr/share/code /usr/share/code.1
ln -sf /Home1/code /usr/share/code

mv /usr/share/cursor /usr/share/cursor.1
ln -sf /Home1/cursor/usr/share/cursor /usr/share/cursor
ln -sf /Home1/cursor/usr/share/cursor/cursor /usr/bin/cursor
