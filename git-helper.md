You want to “uncommit” but keep all your changes so you can modify and recommit — perfect use case for:

✅ Recommended command
```
git reset --soft HEAD~1
```
🔍 What this does:
Removes the last commit
Keeps all changes in the staging area (ready to commit)
Lets you edit/add more changes before committing again