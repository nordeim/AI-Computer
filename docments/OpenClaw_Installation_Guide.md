**OpenClaw**

Complete Installation & Getting Started Guide

A Foolproof Guide for Novice Users

✓ Complete Beginners • ✓ Intermediate Users • ✓ Advanced Users

Version 2026.3 | Based on Official OpenClaw Documentation

github.com/openclaw/openclaw | openclaw.ai

**Table of Contents**

(Right-click and select "Update Field" to refresh page numbers)

What is OpenClaw? 3

System Requirements 4

Getting API Keys 5

Section A: Complete Beginners (Easiest Path) 6

macOS Installation (One-Click) 6

Windows Installation (WSL2) 7

First Conversation with Your Assistant 9

Section B: Intermediate Users (More Control) 10

Manual NPM Installation 10

Linux Server Setup 11

Connecting Messaging Channels 12

Section C: Advanced Users (Full Control) 14

Docker Installation 14

Local LLM with Ollama (No API Costs) 15

Advanced Configuration 16

Training & Personalizing Your OpenClaw 17

Troubleshooting Common Issues 19

Safety & Security Best Practices 21

Next Steps & Resources 22

# What is OpenClaw?

OpenClaw is an open-source, self-hosted personal AI assistant that runs on your own devices and connects to the messaging apps you already use. Unlike cloud-based AI services, OpenClaw keeps your data local while giving you an autonomous agent that can actually perform tasks.

## Key Features

• Runs 24/7 on your own hardware (Mac Mini, PC, Linux server, or VPS)

• Connects to WhatsApp, Telegram, Slack, Discord, iMessage, and 20+ other channels

• Can execute real tasks: send emails, manage calendars, browse the web, run code

• Works with Claude, GPT, Gemini, or local models (completely private)

• Open source with 300,000+ GitHub stars and a thriving community

## How It Works

Think of OpenClaw as having a digital employee with their own computer. You message it like a coworker, and it performs tasks autonomously. The Gateway runs on your machine, connects to AI models for intelligence, and communicates through your preferred messaging apps.

**Why the name?**

OpenClaw was originally called "Clawdbot" and then "Moltbot" before settling on OpenClaw. The lobster emoji (🦞) is the unofficial mascot!

# System Requirements

## Minimum Requirements

For basic usage with cloud AI models (Claude, GPT):

• 4 CPU cores

• 8 GB RAM

• 100 GB storage

• Stable internet connection

## Recommended for Local Models

If you want to run AI models locally (no API costs):

• Mac Mini M4 with 16-64GB RAM (ideal setup)

• Or PC with dedicated GPU

• 32GB+ RAM for larger models

## Operating Systems Supported

• macOS 13+ (Ventura or later, Sequoia recommended)

• Ubuntu Linux 22.04 LTS or 24.04 LTS

• Windows 11 via WSL2 (Windows Subsystem for Linux)

• Any Linux distribution with Node.js 22+ support

**⚠ Important Security Note**

OpenClaw can execute real commands on your system. For safety, consider running it on a dedicated machine or VM, not your primary work computer with sensitive data.

# Getting API Keys (Before You Start)

OpenClaw needs an AI "brain" to function. You have several options:

## Option 1: Anthropic Claude (Recommended)

**1.** Go to console.anthropic.com

**2.** Create an account and add a payment method

**3.** Navigate to API Keys section

**4.** Click "Create Key" and name it "openclaw"

**5.** Copy the key immediately (starts with sk-ant-)

New accounts receive $5 in free credits. Claude Sonnet 4.6 offers the best balance of capability and cost.

## Option 2: OpenAI (ChatGPT)

**1.** Go to platform.openai.com/api-keys

**2.** Create a new secret key

**3.** Copy the key (starts with sk-)

GPT-4o and GPT-4o-mini are commonly used models.

## Option 3: Google Gemini (Free Tier Available)

**1.** Go to aistudio.google.com

**2.** Sign in with your Google account

**3.** Get an API key from the API Keys section

Gemini offers a generous free tier with excellent performance.

## Option 4: Local Models (No API Key Needed)

See the Advanced Users section for setting up Ollama to run models locally with zero API costs.

**Cost Estimate**

With moderate usage, expect $10-50/month in API costs. Using local models eliminates this entirely but requires more powerful hardware.

# Section A: Complete Beginners (Easiest Path)

This section is for users who want the simplest installation with minimal technical knowledge. Follow these steps exactly as written.

## macOS Installation (One-Click Method)

This is the easiest way to get started on a Mac:

**1.** Open Terminal (Press Command + Space, type "Terminal", press Enter)

**2.** Copy and paste this exact command:

curl -fsSL https://openclaw.ai/install.sh | bash

**3.** Wait 2-5 minutes for the installation to complete

**4.** Verify installation by typing:

openclaw --version

**5.** Start the onboarding wizard:

openclaw onboard --install-daemon

### What Happens During Onboarding

The wizard will ask you several questions:

• Accept the security warning (type 'yes')

• Choose Quick Start mode

• Select your AI provider (Anthropic, OpenAI, etc.)

• Paste your API key when prompted

• Choose a model (Claude Sonnet 4.6 recommended)

• Select a messaging channel (Telegram recommended for beginners)

• Name your assistant

**✓ Success!**

When you see "Wake up, my friend" - your OpenClaw is ready!

## Windows Installation (WSL2 Method)

Windows requires WSL2 (Windows Subsystem for Linux) for the best experience:

### Step 1: Install WSL2

**1.** Open PowerShell as Administrator (Right-click Start button, select "Windows PowerShell (Admin)")

**2.** Run this command:

wsl --install -d Ubuntu-24.04

**3.** Restart your computer when prompted

**4.** After restart, Ubuntu will open automatically

**5.** Create a username and password when asked

### Step 2: Enable Systemd (Required)

In your Ubuntu terminal, run:

sudo tee /etc/wsl.conf >/dev/null <<'EOF'

[boot]

systemd=true

EOF

Then in PowerShell (Admin), run:

wsl --shutdown

Re-open Ubuntu and verify systemd is running:

systemctl --version

### Step 3: Install OpenClaw

In your Ubuntu terminal, run:

curl -fsSL https://openclaw.ai/install.sh | bash

Then start onboarding:

openclaw onboard --install-daemon

## First Conversation with Your Assistant

Once installation is complete:

### If You Chose Telegram:

**1.** Open Telegram on your phone or computer

**2.** Search for your bot by the name you gave it

**3.** Send a message: "Hello! What can you do?"

**4.** Your assistant should respond within a few seconds

### Try These First Commands:

"What is my name?" (tests memory)

"What time is it in Tokyo?" (tests web access)

"Create a todo list for today" (tests task management)

# Section B: Intermediate Users (More Control)

This section is for users comfortable with the command line who want more control over their setup.

## Manual NPM Installation

If you prefer to manage Node.js yourself:

### Install Node.js 22+

macOS (with Homebrew):

brew install node

Ubuntu/Debian:

curl -fsSL https://deb.nodesource.com/setup\_22.x | sudo -E bash -

sudo apt-get install -y nodejs

Verify installation:

node --version # Should show v22.x.x or higher

npm --version

### Install OpenClaw via NPM

npm install -g openclaw@latest

If you get permission errors:

sudo npm install -g openclaw@latest

If the command isn't found after install, add to your PATH:

export PATH="$(npm config get prefix)/bin:$PATH"

Add that line to your ~/.bashrc or ~/.zshrc to make it permanent.

## Linux Server Setup (VPS)

For running OpenClaw 24/7 on a server:

### Recommended VPS Providers

• Hetzner: Excellent price/performance

• DigitalOcean: Simple and reliable

• Oracle Cloud: Always Free tier available

• Fly.io: Easy deployment

### Server Installation Steps

**1.** SSH into your server

**2.** Update the system:

sudo apt update && sudo apt upgrade -y

**3.** Install Node.js:

curl -fsSL https://deb.nodesource.com/setup\_22.x | sudo -E bash -

sudo apt-get install -y nodejs

**4.** Install OpenClaw:

sudo npm install -g openclaw@latest

**5.** Run onboarding with daemon:

openclaw onboard --install-daemon

**6.** Enable persistent service:

sudo loginctl enable-linger $(whoami)

### Accessing the Control UI Remotely

Use SSH tunnel for secure access:

ssh -N -L 18789:127.0.0.1:18789 user@YOUR\_SERVER\_IP

Then open http://127.0.0.1:18789 in your browser.

## Connecting Messaging Channels

### Telegram Setup

**1.** Open Telegram and search for @BotFather

**2.** Send /newbot command

**3.** Choose a name and username for your bot

**4.** Copy the token BotFather gives you

**5.** During OpenClaw onboarding, select Telegram and paste the token

### Slack Setup

**1.** Go to api.slack.com/apps

**2.** Click "Create New App" -> "From scratch"

**3.** Name it (e.g., "OpenClaw") and select your workspace

**4.** Go to Socket Mode and enable it

**5.** Generate an App-Level Token (starts with xapp-)

**6.** Go to OAuth & Permissions, add these Bot Token Scopes:

• chat:write

• channels:history, channels:read

• groups:history, groups:read

• im:history, im:read

• users:read

**7.** Install to workspace and copy Bot User OAuth Token (starts with xoxb-)

**8.** During onboarding, paste both tokens when prompted

### Discord Setup

**1.** Go to discord.com/developers/applications

**2.** Click "New Application" and name it

**3.** Go to Bot section and click "Add Bot"

**4.** Copy the Bot Token

**5.** During onboarding, select Discord and paste the token

# Section C: Advanced Users (Full Control)

This section covers Docker deployment, local models, and advanced configuration.

## Docker Installation

Docker provides isolation and easier management:

### Prerequisites

# Install Docker and Docker Compose

curl -fsSL https://get.docker.com | sh

sudo apt install docker-compose-plugin

### Docker Setup

**1.** Clone the repository:

git clone https://github.com/openclaw/openclaw.git

cd openclaw

**2.** Copy environment file:

cp .env.example .env

**3.** Run the setup script:

./scripts/docker/setup.sh

**4.** Start the containers:

docker compose up -d

### Useful Docker Commands

# View logs

docker compose logs -f

# Restart services

docker compose restart

# Update to latest version

git pull

docker compose pull

docker compose up -d

## Local LLM with Ollama (No API Costs)

Run AI models locally for complete privacy and zero API costs:

### Install Ollama

curl -fsSL https://ollama.com/install.sh | sh

### Download a Model

# Recommended models for OpenClaw

ollama pull glm-4.7-flash

# or

ollama pull llama3.3

# or

ollama pull qwen2.5-coder:32b

### Configure OpenClaw for Ollama

**1.** Set the environment variable:

export OLLAMA\_API\_KEY="ollama-local"

**2.** Or configure via OpenClaw CLI:

openclaw config set models.providers.ollama.apiKey "ollama-local"

**3.** Set Ollama as your default model:

openclaw config set agents.defaults.model.primary "ollama/glm-4.7-flash"

**4.** Restart the gateway:

openclaw gateway restart

**Performance Note**

Local models require significant RAM. glm-4.7-flash works well with 8GB, but larger models need 16-32GB+ for good performance.

## Advanced Configuration

### Configuration File Location

~/.openclaw/openclaw.json

### Environment Variables

# Custom state directory

export OPENCLAW\_STATE\_DIR=/path/to/custom/location

# Custom config path

export OPENCLAW\_CONFIG\_PATH=/path/to/config.json

# API keys

export ANTHROPIC\_API\_KEY=sk-ant-...

export OPENAI\_API\_KEY=sk-...

export GOOGLE\_API\_KEY=...

### Multiple Model Providers

Configure multiple providers for fallback:

{

"agents": {

"defaults": {

"model": {

"primary": "anthropic/claude-sonnet-4-6",

"fallbacks": [

"openai/gpt-4o",

"ollama/glm-4.7-flash"

]

}

}

}

}

# Training & Personalizing Your OpenClaw

The major task is to 'train' your OpenClaw to understand you, your needs, your requirements, and your working style. This is done through configuration files and conversation.

## The Soul File (SOUL.md)

During onboarding, OpenClaw creates a soul.md file that defines your assistant's personality. You can edit this to customize:

# SOUL.md Example

## Identity

- Name: Jarvis

- Role: Personal AI Assistant

- Personality: Professional, helpful, slightly witty

- Communication style: Concise but thorough

## Behavior Rules

- Always confirm before executing destructive commands

- Proactively suggest optimizations

- Remember my preferences from our conversations

- Use emoji sparingly and professionally

## User Profile (USER.md)

Create a USER.md file so your assistant knows about you:

# USER.md

## About Me

- Name: [Your Name]

- Profession: Software Developer

- Timezone: America/New\_York

- Preferred communication: Direct and efficient

## Preferences

- Code style: Clean, well-commented

- Meeting times: Prefer mornings

- Notification frequency: Only urgent matters

## Goals

- Learning: Rust programming

- Projects: Building a personal website

- Productivity: Better time management

## Memory System

OpenClaw has a memory system that persists across conversations:

### Memory Files Location

~/.openclaw/workspace/memory/

### Types of Memory

• MEMORY.md - Long-term important information

• YYYY-MM-DD.md - Daily conversation summaries

• facts.md - Key facts about you

• preferences.md - Your preferences and settings

### Teaching Your Assistant

You can explicitly teach your assistant things:

"Remember that I prefer dark mode in all applications"

"Add to my preferences: I wake up at 7 AM"

"Note in my memory: My daughter's birthday is March 15th"

## Custom Skills

Skills are plugins that extend OpenClaw's capabilities:

### Finding Skills

Browse available skills at ClawHub or create your own:

# List installed skills

openclaw skills list

# Install a skill

openclaw skills install skill-name

# Search for skills

openclaw skills search keyword

### Creating a Simple Skill

Skills are stored in ~/.openclaw/skills/

# Example skill structure

my-skill/

skill.yaml # Skill metadata

main.ts # Main logic

README.md # Documentation

# Troubleshooting Common Issues

## Installation Problems

### "Command not found" after installation

# Add npm global bin to PATH

export PATH="$(npm config get prefix)/bin:$PATH"

# Or find where openclaw was installed

which openclaw

# If using nvm

nvm use 22

### Node.js version too old

# Check version

node --version

# Should be v22+

# Update via nvm

nvm install 22

nvm use 22

## Gateway Issues

### Gateway won't start

# Check status

openclaw gateway status

# View logs

openclaw logs --follow

# Restart gateway

openclaw gateway restart

# Run doctor for auto-fix

openclaw doctor --fix

### "Port 18789 already in use"

# Find what's using the port

lsof -i :18789

# Or change OpenClaw's port

openclaw config set gateway.port 18790

openclaw gateway restart

### "Gateway start blocked: set gateway.mode=local"

# Set the mode

openclaw config set gateway.mode local

openclaw gateway restart

## API Key Issues

### "No API key found for provider"

# Set API key via environment

export ANTHROPIC\_API\_KEY=sk-ant-...

# Or via config

openclaw config set models.providers.anthropic.apiKey "sk-ant-..."

# Restart gateway

openclaw gateway restart

### "401 Unauthorized" or "403 Forbidden"

Your API key is invalid or lacks permissions:

• Verify the key is copied correctly

• Check that billing is set up on your provider account

• Ensure the model you selected is available to your account

## Model Issues

### "Model not allowed"

# Check allowed models

openclaw config get agents.defaults.models

# Add your model to allowed list

openclaw config set agents.defaults.models '{"anthropic/claude-sonnet-4-6": {}}'

### "All models failed"

Check your internet connection and API key validity. Run:

openclaw doctor

openclaw logs --follow

## Channel Connection Issues

### Telegram bot not responding

• Verify bot token is correct

• Check that you started a conversation with the bot

• Look for pairing requests in the Control UI

### Slack bot not working

• Verify both tokens (Bot and App-Level)

• Check Socket Mode is enabled

• Ensure bot is invited to the channel

• Reinstall to workspace after permission changes

## Performance Issues

### High memory usage

# Check what's consuming memory

openclaw status

# Reduce concurrent runs

openclaw config set cron.maxConcurrentRuns 2

# Disable unused channels

openclaw channels list

openclaw channels remove channel-name

### Slow responses

• Check your internet connection

• Try a faster model (Flash models vs Pro models)

• Reduce context window if using long conversations

## Emergency Recovery

### Reset to defaults

# Backup first

cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

# Reset config

rm ~/.openclaw/openclaw.json

openclaw onboard

### Complete reinstall

# Remove OpenClaw

npm uninstall -g openclaw

# Remove config (WARNING: loses all data)

rm -rf ~/.openclaw

# Reinstall

npm install -g openclaw@latest

openclaw onboard --install-daemon

# Safety & Security Best Practices

## General Security

• Run OpenClaw on a dedicated machine or VM, not your primary work computer

• Keep your API keys secret - never commit them to version control

• Set spending limits on your AI provider accounts

• Regularly update OpenClaw: npm install -g openclaw@latest

## Network Security

• Don't expose the Control UI (port 18789) to the public internet

• Use SSH tunnels or Tailscale for remote access

• If running on a VPS, configure firewall rules (UFW)

# Example UFW rules

sudo ufw default deny incoming

sudo ufw allow ssh

sudo ufw allow 18789/tcp # Only if necessary

sudo ufw enable

## Execution Safety

• Review and approve destructive commands

• Set up approval requirements for system.run

• Use sandboxing for untrusted skills

# Require approval for system commands

openclaw config set agents.defaults.tools.system.run.approval required

**⚠ Prompt Injection Risk**

Like all AI systems, OpenClaw can be vulnerable to prompt injection. Be cautious about what data you expose to untrusted inputs.

# Next Steps & Resources

## Useful Commands Reference

# Check status

openclaw status

openclaw gateway status

# View logs

openclaw logs --follow

# Run diagnostics

openclaw doctor

openclaw doctor --fix

# Open dashboard

openclaw dashboard

# Update OpenClaw

npm install -g openclaw@latest

# Restart gateway

openclaw gateway restart

## Learning Resources

• Official Documentation: docs.openclaw.ai

• GitHub Repository: github.com/openclaw/openclaw

• Community Discord: discord.gg/clawd

• Showcase & Examples: docs.openclaw.ai/start/showcase

## What to Do Next

**1.** Explore the Control UI at http://127.0.0.1:18789

**2.** Try asking your assistant to perform simple tasks

**3.** Set up daily check-ins or reminders

**4.** Browse and install useful skills

**5.** Customize your SOUL.md and USER.md files

**6.** Join the Discord community for tips and help

**✓ Congratulations!**

You now have a personal AI assistant running on your own hardware. Take time to train it, and it will become an invaluable part of your workflow. Welcome to the future!

**OpenClaw**

The AI that actually does things

Official Resources

github.com/openclaw/openclaw

docs.openclaw.ai

discord.gg/clawd

© 2026 OpenClaw Community | Document Version 2026.3