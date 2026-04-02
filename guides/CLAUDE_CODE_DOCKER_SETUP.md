# Running Claude Code in a Docker Container

This guide walks you through installing Claude Code on your host machine and configuring it to work inside a Docker container.

## Prerequisites

- Docker and Docker Compose installed on your host machine
- A valid Anthropic/Claude account

## Step 1: Install Claude Code on the Host Machine

Run the installer script:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Add the CLI to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

Run `claude` once on the host to complete the authentication flow. This creates the credentials file at `~/.claude/.credentials.json`.

## Step 2: Mount Claude Config into the Container

Add the following volume mapping to your `docker-compose.yml` service:

```yaml
volumes:
  - ~/.claude:/home/${USER}/.claude
```

This shares your host authentication and configuration with the container.

## Step 3: Set the Auth Token Inside the Container

Export the access token from the mounted credentials file:

```bash
export ANTHROPIC_AUTH_TOKEN=$(grep -o '"accessToken":"[^"]*"' ~/.claude/.credentials.json | cut -d'"' -f4)
```

> **Tip:** Add this export to your container's shell profile (e.g., `~/.bashrc`) so it persists across sessions.

## Troubleshooting

| Issue | Fix |
|---|---|
| `claude: command not found` | Verify `~/.local/bin` is in your `PATH` |
| Authentication errors in container | Re-run `claude` on the host to refresh credentials, then restart the container |
| Volume mount permission issues | Ensure the container user's home directory matches the mount target path |
