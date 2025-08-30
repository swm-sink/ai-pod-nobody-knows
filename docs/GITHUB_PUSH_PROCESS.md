# GitHub Push Process for swm-sink Repository

## Secure Push Configuration

### Method 1: Personal Access Token (Recommended)

1. **Create a GitHub Personal Access Token:**
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Select scopes: `repo` (full control of private repositories)
   - Copy the token immediately (you won't see it again)

2. **Store the token securely in .env:**
   ```bash
   echo 'export GITHUB_PAT="ghp_YOUR-TOKEN-HERE"' >> .env
   source .env
   ```

3. **Push using the token:**
   ```bash
   # One-time push with token
   git push https://$GITHUB_PAT@github.com/swm-sink/ai-pod-nobody-knows.git main

   # Or create an alias in your shell profile
   echo 'alias git-push-secure="git push https://$GITHUB_PAT@github.com/swm-sink/ai-pod-nobody-knows.git main"' >> ~/.bashrc
   source ~/.bashrc

   # Then use:
   git-push-secure
   ```

### Method 2: SSH Key (Alternative)

1. **Generate SSH key if you don't have one:**
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

2. **Add SSH key to GitHub:**
   - Copy your public key: `cat ~/.ssh/id_ed25519.pub`
   - Go to GitHub Settings → SSH and GPG keys → New SSH key
   - Paste the key and save

3. **Change remote to use SSH:**
   ```bash
   git remote set-url origin git@github.com:swm-sink/ai-pod-nobody-knows.git
   git push origin main
   ```

### Method 3: GitHub CLI (Most Convenient)

1. **Install GitHub CLI:**
   ```bash
   # macOS
   brew install gh

   # Linux
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update
   sudo apt install gh
   ```

2. **Authenticate:**
   ```bash
   gh auth login
   # Follow the interactive prompts
   ```

3. **Push normally:**
   ```bash
   git push origin main
   # gh handles authentication automatically
   ```

## Security Best Practices

1. **NEVER commit tokens to the repository**
   - Always use environment variables or external credential stores
   - Add `.env` to `.gitignore`

2. **Rotate tokens regularly**
   - Delete and regenerate PATs every 90 days
   - Use tokens with minimal required permissions

3. **Use separate tokens for different projects**
   - Don't reuse the same token across multiple repositories
   - Makes it easier to revoke access if compromised

4. **Monitor token usage**
   - Check GitHub Settings → Personal access tokens regularly
   - Review "Last used" timestamps
   - Revoke unused tokens

## Pre-Push Checklist

Before pushing to the public repository:

```bash
# 1. Check for exposed secrets
grep -r "ghp_\|sk-\|pplx-\|xi-" . --exclude-dir=.git --exclude="*.example"

# 2. Verify git remote URL has no embedded token
git remote -v
# Should show: https://github.com/swm-sink/ai-pod-nobody-knows.git
# NOT: https://ghp_TOKEN@github.com/...

# 3. Run security audit
git diff --staged | grep -E "(api[_-]?key|token|secret|password)" -i

# 4. Ensure .gitignore is working
git status --ignored

# 5. Final push
git push origin main
```

## Troubleshooting

### Authentication Failed
```bash
# Clear cached credentials
git config --global --unset credential.helper
git config --system --unset credential.helper

# Re-authenticate
git push origin main
# Enter username and PAT when prompted
```

### Wrong Remote URL
```bash
# Check current remote
git remote -v

# Fix if needed
git remote set-url origin https://github.com/swm-sink/ai-pod-nobody-knows.git
```

### Token Not Working
- Ensure token has `repo` scope
- Check token hasn't expired
- Verify you're using the token, not your GitHub password

## Repository Information
- **Repository:** swm-sink/ai-pod-nobody-knows
- **Visibility:** Public (ensure no secrets before pushing)
- **Default Branch:** main
