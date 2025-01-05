# Design keuzes en assumpties

## Algemeen

Elke CSV vereist een header-rij en moet altijd een `Action`-kolom bevatten.

Het hele systeem is sterk afhankelijk van de paden van entiteiten; verplaatsbewerkingen worden daarom niet ondersteund.

## Pad

Er zijn twee varianten van paden die in verschillende scenario's worden verwacht.
- Variant 1: Een pad naar de container van de entiteit. Bijv. `ROOT/Path/To/OU`
- Variant 2: Een pad naar de entiteit zelf. Bijv. `ROOT/Path/To/OU/User`

## Acties

> [!NOTE]
> Niet alle acties zijn beschikbaar voor alle entiteiten. Bijv., de **Modify**-actie is niet beschikbaar voor de **-GroupUser**-entiteit, omdat lidmaatschappen niet echt bewerkbaar zijn.

- **Add** - Voegt de opgegeven entiteit toe.
- **Remove** - Verwijdert de opgegeven entiteit.
- **Modify** - Wijzigt de opgegeven entiteit.

## OU

De OU-CSV ondersteunt de volgende velden:
- Path
- Name
- Protect - Of de OU beschermd is tegen verwijdering: `true` of `false`
- Description

### Paden

- `Add`: Variant 1
- `Modify`: Variant 2
- `Remove`: Variant 2

## Gebruikers

De gebruikers-CSV ondersteunt de volgende velden:
- Path
- Name - De gebruikersnaam van de gebruiker
- DisplayName
- Password
- Email
- Department
- Status - `Active` of `Inactive`, geeft aan of het account is ingeschakeld.

### Paden

- `Add`: Variant 1
- `Modify`: Variant 2
- `Remove`: Variant 2

## Groepen

De groepen-CSV ondersteunt de volgende velden:
- Path
- Name
- Scope - `DomainLocal`, `Global` of `Universal`
- Type - `Security` of `Distribution`
- Description

### Paden

- `Add`: Variant 1
- `Modify`: Variant 2
- `Remove`: Variant 2

## Lidmaatschappen

De groepslidmaatschappen-CSV ondersteunt de volgende velden:
- UserPath
- GroupPath

### Paden

- `Add`: Variant 2
- `Remove`: Variant 2
