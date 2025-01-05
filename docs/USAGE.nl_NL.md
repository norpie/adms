# Gebruik

**Om op elk moment hulp te krijgen, gebruik de parameter -Help of het alias -H.**

## Niveaus van Verbositeit

- **1** - INF - Informatieve berichten. Dit is de standaardwaarde.
- **2** - WAR - Waarschuwingsberichten.
- **3** - ERR - Foutberichten.

## Foutafhandelingsmodi

- **1** - Negeer - Negeert fouten en gaat door met het volgende item.
- **2** - Overslaan - Geeft een waarschuwing en gaat door met het volgende item.
- **3** - Stop - Stopt de uitvoering en toont de fout.

## Entiteiten

- **-OU** - Organisatorische Eenheid
- **-User** - Gebruiker
- **-Group** - Groep
- **-GroupUser** - Verwijst naar groepslidmaatschap van een gebruiker

## Parameters

- **-LogDir** - **DIR** De map waarin de logbestanden worden geschreven.
- **-ActionLogDir** - **DIR** De map waarin de actie-logbestanden worden geschreven.
- **-LogFile** - **String** De naam van het logbestand waarin wordt geschreven.
- **-ActionLogFileName** - **String** De bestandsnaam van de actielog.
- **-LogVerbosity** - **Int** De verbositeit van het logbestand. 1-3 (Standaard: 1)
- **-ConsoleVerbosity** - **Int** De verbositeit van de console-output.
- **-Help** - **Switch** Toont het helpbericht.
- **-ErrorHandling** - **Int** Stel de foutafhandelingsmodus in. 1-3 (Standaard: 3)
- **-Reset** - **Switch** Verwijder alle door gebruikers gemaakte OUs uit AD. Dit wordt onmiddellijk uitgevoerd en vernietigt uw omgeving. GEBRUIK MET VOORZICHTIGHEID.
- **-OverwriteExisting** - **Switch** Overschrijft bestaande entiteiten bij 'Add'-acties.
- **-FillDefaults** - **Switch** Vul standaardwaarden in voor de entiteiten wanneer deze ontbreken in de CSV, indien mogelijk.
- **-RecursiveDelete** - **Switch** Bij het verwijderen van een OU worden ook alle onderliggende entiteiten verwijderd.
- **-Entity** - **Enum** De entiteit waarop moet worden gehandeld. [OU, User, Group, GroupUser]
- **-File** - **FILE** Het CSV-bestand waarop moet worden gehandeld.
- **-Export** - **Switch** Geeft aan dat dit een exportbewerking is. Maakt een CSV-bestand met 'Add'-acties op de locatie opgegeven bij het argument `-File`, zodat u ze opnieuw kunt importeren met dit script.
- **-MakeReport** - **Switch** Print een samenvatting van alle uitgevoerde acties aan het einde.
- **-ApiReport** - **String** Stuur de samenvatting van alle uitgevoerde acties naar een opgegeven endpoint via een POST.

## Aliassen

- **-H** - **Switch** Alias voor de `-Help`-parameter

## Voorbeelden

### Voorbeeld 1

> Importeer alle OUs uit het bestand OUs.csv.

```powershell
.\src\main.ps1 -Entity OU -File .\OUs.csv
```

### Voorbeeld 2

> Importeer alle OUs uit het bestand OUs.csv en print een samenvatting van alle uitgevoerde acties aan het einde.

```powershell
.\src\main.ps1 -Entity OU -File .\OUs.csv -MakeReport
```

### Voorbeeld 3

> Importeer alle OUs uit het bestand OUs.csv en print alleen fouten naar de console.

```powershell
.\src\main.ps1 -Entity OU -File .\OUs.csv -ConsoleVerbosity 3
```

### Voorbeeld 4

> Exporteer alle OUs naar het bestand OUs.csv.

```powershell
.\src\main.ps1 -Entity OU -File .\OUs.csv -Export
```
