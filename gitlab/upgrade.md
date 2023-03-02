# Upgrade

---

**Reference: [gitlab upgrade guide](https://docs.gitlab.com/ee/update/package/#upgrade-using-the-official-repositories)**

## **Pre-upgrade and post-upgrade checks**

Immediately before and after the upgrade, perform the pre-upgrade and post-upgrade checks to ensure the major components of GitLab are working:

1.  [Check the general configuration](https://docs.gitlab.com/ee/administration/raketasks/maintenance.html#check-gitlab-configuration):

```bash
sudo gitlab-rake gitlab:check
```

1.  Confirm that encrypted database values [can be decrypted](https://docs.gitlab.com/ee/administration/raketasks/doctor.html#verify-database-values-can-be-decrypted-using-the-current-secrets):

```bash
sudo gitlab-rake gitlab:doctor:secrets
```

1.  In GitLab UI, check that:
    -   Users can log in.
    -   The project list is visible.
    -   Project issues and merge requests are accessible.
    -   Users can clone repositories from GitLab.
    -   Users can push commits to GitLab.
2.  For GitLab CI/CD, check that:
    -   Runners pick up jobs.
    -   Docker images can be pushed and pulled from the registry.
3.  If using Geo, run the relevant checks on the primary and each secondary:

```bash
sudo gitlab-rake gitlab:geo:check
```

1.  If using Elasticsearch, verify that searches are successful.

If in any case something goes wrong, see [how to troubleshoot](https://docs.gitlab.com/ee/update/plan_your_upgrade.html#troubleshooting).

## Upgrade path

Find where your version sits in the upgrade path below, and upgrade GitLab accordingly, while also consulting the [version-specific upgrade instructions](https://docs.gitlab.com/ee/update/index.html#version-specific-upgrading-instructions):

`8.11.Z` -> `8.12.0` -> `8.17.7` -> `9.5.10` -> `10.8.7` -> `[11.11.8](<https://docs.gitlab.com/ee/update/index.html#1200>)` -> `12.0.12` -> `[12.1.17](<https://docs.gitlab.com/ee/update/index.html#1210>)` -> `12.10.14` -> `13.0.14` -> `[13.1.11](<https://docs.gitlab.com/ee/update/index.html#1310>)` -> `[13.8.8](<https://docs.gitlab.com/ee/update/index.html#1388>)` -> [latest `13.12.Z`](https://about.gitlab.com/releases/categories/releases/) -> [latest `14.0.Z`](https://docs.gitlab.com/ee/update/index.html#1400) -> [latest `14.Y.Z`](https://about.gitlab.com/releases/categories/releases/)

### Check available version in official repo

```bash
sudo apt-cache policy gitlab-ce

```

### Upgrade version

> Must follow upgrade path

1.  upgrade to version 13.8.8:
    
    ```bash
    sudo apt install gitlab-ce=<version>-ce.0
    	
    ```
    
2.  Perform [post-upgrade checks](https://www.notion.so/Upgrade-82701892ba8a47538cfcfd45d9da15a9).