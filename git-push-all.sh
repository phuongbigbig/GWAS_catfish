#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if current directory is already a git repo
if [ -d ".git" ]; then
    echo "➜ Git repository already initialized."
else
    echo "➜ Initializing Git repository..."
    git init
fi

# Stage and commit files
echo "➜ Staging all files..."
git add .

# Prompt for a commit message, default to 'Automated push'
read -p "Enter commit message [Automated push]: " msg
msg="${msg:-Automated push}"

echo "➜ Committing files..."
git commit -m "$msg"

# Ensure default branch is main
git branch -M main

# Check if remote origin already exists
if git remote | grep -q "origin"; then
    echo "➜ Remote 'origin' already exists."
else
    echo "How would you like to link GitHub?"
    echo "1) Create a brand NEW repository using GitHub CLI (gh)"
    echo "2) Paste an EXISTING GitHub repository URL"
    read -p "Choose an option (1 or 2): " repo_choice

    if [ "$repo_choice" = "1" ]; then
        # Check if GitHub CLI is installed
        if ! command -v gh &> /dev/null; then
            echo "❌ Error: GitHub CLI (gh) is not installed. Run 'brew install gh' first."
            exit 1
        fi
        
        # Get current folder name for the repo name
        FOLDER_NAME=$(basename "$PWD")
        read -p "Enter repo name [$FOLDER_NAME]: " REPO_NAME
        REPO_NAME="${REPO_NAME:-$FOLDER_NAME}"
        
        echo "➜ Creating new GitHub repository..."
        gh repo create "$REPO_NAME" --private --source=. --remote=origin
    else
        read -p "Paste your GitHub repository URL: " REPO_URL
        git remote add origin "$REPO_URL"
    fi
fi

# Push to GitHub
echo "➜ Pushing to GitHub main branch..."
git push -u origin main

echo "✅ Successfully pushed to GitHub!"

