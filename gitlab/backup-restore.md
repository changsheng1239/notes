# Backup & Restore

---

_Following guide written for Gitlab omnibus package_

## Backup

**Reference: [gitlab backup and restore guide](https://docs.gitlab.com/ee/raketasks/backup_restore.html#back-up-gitlab)**

---

### **Storing configuration files**

> GitLab does not back up any configuration files (`/etc/gitlab`), SSL certificates, or system files. You are highly advised to read about [storing configuration files](https://docs.gitlab.com/ee/raketasks/backup_restore.html#storing-configuration-files).

The [backup Rake task](https://docs.gitlab.com/ee/raketasks/backup_restore.html#back-up-gitlab) GitLab provides does _not_ store your configuration files. The primary reason for this is that your database contains items including encrypted information for two-factor authentication and the CI/CD _secure variables_. Storing encrypted information in the same location as its key defeats the purpose of using encryption in the first place.

The secrets file is essential to preserve your database encryption key.

At the very **minimum**, you must back up:

For Omnibus:

-   `/etc/gitlab/gitlab-secrets.json`
-   `/etc/gitlab/gitlab.rb`

You may also want to back up any TLS keys and certificates (`/etc/gitlab/ssl`), and your [SSH host keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).

If you use Omnibus GitLab, review additional information to [backup your configuration](https://docs.gitlab.com/omnibus/settings/backups.html).

In the unlikely event that the secrets file is lost, see the [troubleshooting section](https://docs.gitlab.com/ee/raketasks/backup_restore.html#when-the-secrets-file-is-lost).

---

### Steps

1.  Edit `/etc/gitlab/gitlab.rb` and add
    
    ```ruby
    gitlab_rails['backup_path'] = path_with_sufficient_storage
    ```
    
2.  Run `sudo gitlab-ctl reconfigure` so the above changes take effect.
    
3.  Backup `/etc/gitlab/gitlab.rb` and `/etc/gitlab/gitlab-secrets.json`
    
4.  If gitlab version >= **12.2**
    
    ```bash
    sudo gitlab-backup create
    ```
    
    if gitlab version <= **12.1**
    
    ```bash
    sudo gitlab-rake gitlab:backup:create
    ```
    

The process will takes some times as it backup all repositories also. After the backup is done, there will be a `$TIMESTAMP_gitlab_backup.tar` in the `backup_path` specified in step 1.

---

## Restore

### Restore prerequisites

-   Need to have a working installation of Gitlab before you can perform a restore.
-   Need to have the **exact same version and type (CE/EE)** of GitLab Omnibus with which the backup was created
-   You have run `sudo gitlab-ctl reconfigure` at least once.
-   GitLab is running. If not, start it using `sudo gitlab-ctl start`.

### Steps

Notes: For omnibus installation: db, redis are all included in single host.

1.  First ensure your backup tar file is in the backup directory described in the `gitlab.rb` configuration `gitlab_rails['backup_path']`. The default is `/var/opt/gitlab/backups`. It needs to be owned by the `git` user.
    
    ```bash
    sudo cp 11493107454_2018_04_25_10.6.4-ce_gitlab_backup.tar /var/opt/gitlab/backups/
    sudo chown git.git /var/opt/gitlab/backups/11493107454_2018_04_25_10.6.4-ce_gitlab_backup.tar
    ```
    
2.  Stop the processes that are connected to the database. Leave the rest of GitLab running:
    
    ```bash
    sudo gitlab-ctl stop puma
    sudo gitlab-ctl stop sidekiq
    # Verify
    sudo gitlab-ctl status
    ```
    
3.  Next, restore the backup, specifying the timestamp of the backup you wish to restore:
    
    ```bash
    # This command will overwrite the contents of your GitLab database!
    sudo gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce
    
    ```
    
    if your gitlab version is <= **12.1**, use `gitlab-rake gitlab:backup:restore`.
    
4.  Next, restore `/etc/gitlab/gitlab-secrets.json`, `/etc/gitlab/ssl` , [SSH host keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).
    
5.  Reconfigure, restart and check GitLab: