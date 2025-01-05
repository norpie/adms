# Design Choices and Assumptions

## General

Every CSV requires a header row, and there must always be an `Action` column.

The whole system is very dependent on the paths of entities, move operations are entirely unsupported because of this.

## Path


There are 2 variations of path expected in different scenarios.
- Variation 1: A path to the container of the entity. E.g. `ROOT/Path/To/OU`
- Variation 2: A path to the entity itself. E.g. `ROOT/Path/To/OU/User`

## Actions

> [!NOTE]
> Not all actions are available for all entities. E.g., the **Modify** action is not available for the **-GroupUser** entity, as you can not really edit a membership.

- **Add** - Adds the specified entity.
- **Remove** - Removes the specified entity.
- **Modify** - Updates the specified entity.

## OU

The OU CSV supports the following fields:
- Path
- Name
- Protect - Whether the OU is protected from deletion: `true` or `false`
- Description

### Paths

- `Add`: Variation 1
- `Modify`: Variation 2
- `Remove`: Variation 2

## Users

The user CSV supports the following fields:
- Path
- Name - The username of the user
- DisplayName
- Password
- Email
- Department
- Status - `Active` or `Inactive`, whether the account is enabled.

### Paths

- `Add`: Variation 1
- `Modify`: Variation 2
- `Remove`: Variation 2

## Groups

The group CSV supports the following fields:
- Path
- Name
- Scope - `DomainLocal`, `Global`, or `Universal`
- Type - `Security` or `Distribution`
- Description

### Paths

- `Add`: Variation 1
- `Modify`: Variation 2
- `Remove`: Variation 2

## Memberships

The group membership CSV supports the following fields:
- UserPath
- GroupPath

### Paths

- `Add`: Variation 2
- `Remove`: Variation 2
