# Vault

## What is Vault

Vault comes with various pluggable components called **secrets engines** and **authentication methods** allowing you to integrate with external systems. The purpose of those components is to manage and protect your secrets in dynamic infrastructure (e.g. database credentials, passwords, API keys).

![[vault-intro.png]]

## Group, Policy, Entity

![[groups-entity.png]]

## Components

- **Policies** – Defines what an entity can do – create, read, modify, delete
- **Auth backend** – A service that can authenticate users
-  **Entities** – An entity ties different user accounts from different auth backends to a single entity. For example, my Auth0 username is “A” but my Github username is “B”. In either case, the account is still **ME,** just a different platform and/or username. Entities tie of all these different auth services and usernames together as a single object.
- **Groups** – A group makes all this magic come together. Not only is a group a collection of entities ( users and auth backends) but an assignment of policies that defines what each entity can perform.

