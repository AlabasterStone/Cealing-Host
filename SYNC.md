# Upstream Sync Documentation

## Overview

This repository is configured to automatically synchronize with the upstream repository [SpaceTimee/Cealing-Host](https://github.com/SpaceTimee/Cealing-Host) to ensure the host rules remain up-to-date.

## How It Works

### Automatic Sync

- **Schedule**: Runs daily at 02:00 UTC
- **Trigger**: Can also be manually triggered via GitHub Actions
- **Process**: 
  1. Fetches latest commits from upstream
  2. Checks for new commits using `git merge-base`
  3. Attempts automatic merge with conflict detection
  4. Pushes changes if successful, or creates an issue if conflicts arise

### Branch Management

The workflow automatically handles branch detection:
- Prefers `main` branch if available
- Falls back to `master` branch
- Creates `main` branch if neither exists

### Conflict Resolution

When merge conflicts occur, the workflow:
1. Aborts the automatic merge
2. Creates a GitHub issue with detailed instructions
3. Labels the issue for easy identification
4. Provides step-by-step resolution guide

## Manual Sync Process

If you need to manually sync or resolve conflicts:

1. **Clone and setup**:
   ```bash
   git clone https://github.com/AlabasterStone/Cealing-Host.git
   cd Cealing-Host
   git remote add upstream https://github.com/SpaceTimee/Cealing-Host.git
   git fetch upstream
   ```

2. **Create/switch to main branch**:
   ```bash
   git checkout -b main  # if main doesn't exist
   # or
   git checkout main     # if main exists
   ```

3. **Merge with upstream** (handling unrelated histories):
   ```bash
   git merge upstream/main --allow-unrelated-histories
   ```

4. **Resolve conflicts** (if any):
   - Edit conflicted files manually
   - Keep relevant changes from both sides
   - Focus on preserving local customizations while adopting upstream updates

5. **Complete the merge**:
   ```bash
   git add .
   git commit
   git push origin main
   ```

## Common Conflict Files

- `Cealing-Host.json` - Main host rules file
- `Cealing-Host-R.json` - Rutube video resource rules  
- `README.md` - Documentation differences
- Configuration files

## Troubleshooting

### "Unrelated Histories" Error

This occurs when repositories were created independently. Use:
```bash
git merge upstream/main --allow-unrelated-histories
```

### Workflow Not Running

- Check if the workflow file syntax is valid
- Ensure the repository has Actions enabled
- Verify the schedule cron expression is correct

### Manual Trigger

1. Go to the Actions tab in GitHub
2. Select "Sync with Upstream" workflow
3. Click "Run workflow"
4. Choose the branch and click "Run workflow"

## Workflow Configuration

The sync workflow is defined in `.github/workflows/sync-upstream.yaml` and includes:

- Scheduled execution (daily)
- Manual trigger capability
- Smart branch detection
- Conflict detection and handling
- Automatic issue creation for manual intervention
- Issue cleanup on successful sync

## Benefits

- **Always up-to-date**: Automatically receives upstream improvements
- **Conflict-aware**: Handles merge conflicts gracefully
- **Transparent**: Creates issues for manual intervention when needed
- **Flexible**: Supports both automatic and manual triggering
- **Safe**: Tests merges before applying changes