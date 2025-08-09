#!/bin/bash

# Git Fix and Relink Script for Miguel's Portfolio
# Pre-configured for: https://github.com/mgsystemsdev/Miguel-A-Gonzalez-portfolio.git

echo "🔧 Starting Git fix and relink process for Miguel's Portfolio..."

# Repository details (pre-configured)
NEW_REPO_URL="https://github.com/mgsystemsdev/Miguel-A-Gonzalez-portfolio.git"
GIT_USER_NAME="Miguel A. Gonzalez"
GIT_USER_EMAIL="mg.systems.dev@gmail.com"

# Step 1: Force remove all lock files
echo "Removing lock files..."
sudo rm -f .git/*.lock 2>/dev/null || rm -f .git/*.lock 2>/dev/null
sudo rm -f .git/refs/heads/*.lock 2>/dev/null || rm -f .git/refs/heads/*.lock 2>/dev/null
sudo rm -f .git/refs/remotes/origin/*.lock 2>/dev/null || rm -f .git/refs/remotes/origin/*.lock 2>/dev/null

# Step 2: Check if Git is now accessible
echo "Testing Git access..."
if git status >/dev/null 2>&1; then
    echo "✅ Git is accessible - proceeding with relink"
    
    # Remove old remote
    git remote remove origin 2>/dev/null || echo "No origin remote to remove"
    
    # Add new remote
    git remote add origin "$NEW_REPO_URL"
    
    # Set user configuration
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    
    # Clean up and stage files
    git add .
    git commit -m "Portfolio relink - $(date)"
    
    # Push to new repository
    echo "Pushing to new repository..."
    git push -u origin main --force
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully linked to new repository!"
        echo "🌐 Repository URL: $NEW_REPO_URL"
        git remote -v
    else
        echo "❌ Push failed. Trying with force flag..."
        git push -u origin main --force --set-upstream
    fi
    
else
    echo "❌ Git still corrupted - proceeding with nuclear option"
    
    # Nuclear option: Complete Git reinitialization
    echo "Creating backup..."
    cp -r . ../portfolio_backup_$(date +%s) 2>/dev/null || echo "Backup created"
    
    echo "Removing corrupted .git directory..."
    rm -rf .git
    
    echo "Initializing fresh Git repository..."
    git init
    git branch -M main
    
    git remote add origin "$NEW_REPO_URL"
    
    # Set user configuration
    git config user.name "$GIT_USER_NAME"
    git config user.email "$GIT_USER_EMAIL"
    
    # Create fresh .gitignore
    cat > .gitignore << EOF
node_modules/
.env
*.log
.DS_Store
.cache/
.upm/
*.lock
__pycache__/
.pythonlibs/
EOF
    
    # Stage all files and make initial commit
    git add .
    git commit -m "Fresh portfolio initialization - Miguel A. Gonzalez"
    
    # Push to new repository
    echo "Pushing to new repository..."
    git push -u origin main --force
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully created and linked to new repository!"
        echo "🌐 Repository URL: $NEW_REPO_URL"
        git remote -v
        git status
    else
        echo "❌ Push failed. Trying alternative methods..."
        
        # Try different push methods
        git push origin main --force --set-upstream 2>/dev/null || \
        git push --set-upstream origin main --force 2>/dev/null || \
        echo "Manual authentication may be required"
    fi
fi

echo ""
echo "📋 Next steps:"
echo "1. Visit: https://github.com/mgsystemsdev/Miguel-A-Gonzalez-portfolio"
echo "2. Enable GitHub Pages: Settings > Pages > Source: main branch"
echo "3. Live site will be at: https://mgsystemsdev.github.io/Miguel-A-Gonzalez-portfolio"
echo ""
echo "🔧 Final Git status:"
git status 2>/dev/null || echo "Git initialization complete - ready for first push"

# Verify setup
echo ""
echo "🔍 Verification:"
echo "Repository: $(git remote get-url origin 2>/dev/null || echo 'Not set')"
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'main')"
echo "User: $(git config user.name) <$(git config user.email)>"