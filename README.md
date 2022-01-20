# KeepAChangeLog-Parser
A simple shell parser designed to check the format of changelogs against https://keepachangelog.com/en/1.0.0/


## Who would use this?
Anyone using bash scripts to check changelog formats. Developed specifically with Gitlab CI/CD in mind, this can be used with any CI pipeline that uses bash to run scripts.

## How to use this?
Set script as executable and run without any parameters. The script by default looks for a CHANGELOG.md in the directory it was run in.

## How it works
Reads a CHANGELOG.md file line by line and uses RegEx matching to look for versions and then ensures that each version has a changetype and a comment.
