---
title: Setup multiple git accounts on same machines
date: 2025-03-23 18:35:00 +0200
categories: [Guides]
tags: [Git, Github, Customization]
---

## Introduction
Git is an open-source version control system used worldwide. It's really useful to coordinate with other developers over the same project or even for personal projects to track new features, code introducement and the history of a project.

Because of its extense use, the need to use multiple accounts on a same machine becomes natural.

This guide presents a short an easy way to configure a setup with two (...or more) different Git accounts.

## HTTPS vs SSH
Git authentication can be handled trough HTTPS or SSH protocols.

The key differences of these technologies are:


| Feature            | HTTPS                                             | SSH     |
| :--------------------------- | :--------------- | ------: |
| Authentication| Username + PAT (Personal Access Token)| Uses public and private key pairs. Public key is stored on GitHub, private key stays local. |
| Security| Secure, but relies on token storage. Vulnerable to brute force and data leaks. | More secure (private key stays on your machine). |
| Use| Easier for beginners (just copy-paste the URL). Requires authentication on each push/pull. | Requires SSH key setup but is seamless after that. Key-based authentication is automatic. |

SSH is preferred in most cases, so we will use SSH to configure our setup.

## Setup

### 1. Generate the SSH keys


The usual path to store keys is: `~/.ssh/`.

To generate the SSH keys execute the following command:
> Replace the email and file path with your preferred ones


```bash
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/github_personal
ssh-keygen -t ed25519 -C "your-work-email@example.com" -f ~/.ssh/github_work
ssh-keygen -t ed25519 -C "azure@example.com" -f ~/.ssh/azure_key
```
Each of these commands, creates:
- Private key: `~/.ssh/<fileName>`
- Public key: `~/.ssh/<fileName>.pub`

Then add each public key to its respective account (GitHub, Azure, etc.).

### 2. Update the SSH config file
Edit the file:
`~/.ssh/config`

Add the account host with a custom host name to reference this particular account, then link it to the SSH private key we have just genereated:

```
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_personal

Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_work

Host azure.com
    HostName ssh.dev.azure.com
    User git
    IdentityFile ~/.ssh/azure_key
```

### 3. Use the Host account referencing the host name you used
For example, for the GitHub personal account, these are the commands that you'll need to use:

- To create a new repo:
`git remote add origin git@github.com-personal:<repoPath>.git`
- To clone an existing repo:
`git clone git@github.com-personal:<repoPath>.git`

### 4. Configure git name and email
Each commit is associated to a name and email.
Because we are setting up multiple accounts, we have to be cautious with what name and email we want to associate a commit with.

My current setup involves having a global user name and email for my most used account:

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```
And local credentials to the repos that use other accounts.
For setting up the local credentials, go to the path of that repo and execute:
```bash
git config --local user.name "Your Name"
git config --local user.email "your-email@example.com"
```

#### 4.1 Extra - Configure "automatic" git config credentials
If you have to switch a lot between accounts, maybe the previous setup is a bit cumbersome.
The credetials can be "automated" by using the `.gitconfig` file

```bash
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

And have separate configs:
- `~/.gitconfig-work`

```bash
[user]
    email = your-work-email@example.com
    name = Your Work Name
```

- `~/.gitconfig-personal`

```bash
[user]
    email = your-personal-email@example.com
    name = Your Personal Name
```


> For more details about git configuration, check: [Getting Started - First Time Git Setup](<https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup>)
{: .prompt-info }
