# Git Helper
A bash script that adds UI features and walkthrough steps for git

- Intialize git
- Set remote
- View/Choose Branch
- Auto stage all files
- Pull & Push to Sync

## Installation
Paste the one line command in terminal

### RECOMMENDED Create alias `sync` to run
```
echo 'alias sync="curl -sSf https://raw.githubusercontent.com/Boden-C/git-helper/main/git.sh > git.sh && chmod +x git.sh && ./git.sh"' >> ~/.bashrc && source ~/.bashrc
```
_Doing this adds an alias to your `~/.bashrc` file and creates a temporary `git.sh` file which might override your own files_
### Create Permanent File Called `git.sh`
```
curl https://raw.githubusercontent.com/Boden-C/git-helper/main/git.sh > git.sh && chmod +x git.sh
```
_If you use this, you must replace `sync` with `./git.sh`. The file will not automatically update_
## Uses
Run `sync help`

When running the script, it will automatically initialize git
If there is no remote origin, it will give a menu to set it

- `sync`
  - General case; the walkthrough option to sync or change branches, gives you
    - Branch selection
    - Commit message prompt
    - Pulls and Pushes
- `sync -m "commit message"`
  - Faster way; skips branch selection and commit message prompt
- `sync pull`
  - Pulls only
- `sync push`
  - Pushes only; use if there was an error with pushing but not pulling
- `sync remote`
  - View and change remote origin
