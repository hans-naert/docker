# Docker-oefeningen

Deze map bevat voorbeelden om Docker-images te bouwen en een Apache-webserver
met PHP te starten. De commando's hieronder zijn bedoeld voor PowerShell op
Windows.

## Benodigdheden

- Docker Desktop met Linux-containers, gestart en bereikbaar vanuit PowerShell.
- Toegang voor Docker tot `C:\Apache\htdocs`.
- Voer de commando's uit vanuit deze map.

## Images bouwen

Het script [build-docker.ps1](./build-docker.ps1) bouwt een image op basis van
een bestand met de naam `<naam>.Dockerfile`. De bestandsnaam zonder
`.Dockerfile` wordt de imagenaam. Zonder expliciete versie gebruikt Docker
de tag `latest`.

```powershell
.\build-docker.ps1 ubuntu-apt-update.Dockerfile
```

Dit komt overeen met:

```powershell
docker build --file ubuntu-apt-update.Dockerfile --tag ubuntu-apt-update .
```

Het script gebruikt altijd deze map als buildcontext, ook als je het vanuit
een andere map aanroept. [ubuntu-apt-update.Dockerfile](./ubuntu-apt-update.Dockerfile)
vertrekt van Ubuntu en voert `apt-get update` uit.

Er is ook [ubuntu-add.Dockerfile](./ubuntu-add.Dockerfile): dit installeert
`bc`, kopieert [script.sh](./script.sh) naar de image en schrijft het
resultaat van de berekening naar `output.txt` tijdens de build.

```powershell
.\build-docker.ps1 ubuntu-add.Dockerfile
docker run --rm ubuntu-add
```

## Apache en PHP interactief installeren en de container committen

Een **image** is de basis voor een container. Een **container** is een
uitgevoerde instantie van een image, met een eigen beschrijfbare laag.
Een tag verwijst naar een image; `docker commit` maakt van de wijzigingen
in een container een nieuwe image en kan die meteen een naam en tag geven.

In deze oefening beantwoorden we de configuratievragen tijdens de installatie
en bewaren we het resultaat met `docker commit`. Zo zie je hoe je vanuit een
gewijzigde container een nieuwe image maakt.

### 1. Start de installatie

Bouw eerst de basisimage en installeer daarna Apache en PHP in een nieuwe
container:

```powershell
.\build-docker.ps1 ubuntu-apt-update.Dockerfile
docker run -it --name php-install ubuntu-apt-update apt-get -y install apache2 php
```

`-it` koppelt de invoer en een terminal aan de container, zodat je
eventuele configuratievragen tijdens de installatie kunt beantwoorden,
bijvoorbeeld over de tijdzone. `-y` beantwoordt de
pakketinstallatiebevestiging automatisch, maar niet noodzakelijk alle
configuratievragen. Het opgegeven commando start geen interactieve shell.
Na de installatie stopt de container, maar hij blijft bestaan omdat `--rm`
niet is opgegeven. Met `--name php-install` krijgt de container een naam
die je later kunt gebruiken in plaats van het container-ID.

### 2. Zoek de container

Wacht tot de installatie is voltooid. Toon ook de gestopte containers en
zoek de container met de naam `php-install`:

```powershell
docker ps -a
```

Controleer dat de container succesvol is gestopt (`Exited (0)`). De lijst
toont ook het container-ID, maar dat heb je hier niet nodig.

### 3. Maak een image van de container

Maak vervolgens een image van die container met zijn naam:

```powershell
docker commit php-install ubuntu-apache2-php
```

`ubuntu-apache2-php` is de imagenaam en krijgt standaard de tag `latest`.
Hiermee worden de installatie en configuratie in de container vastgelegd
in een nieuwe image; het geeft niet simpelweg een tag aan de container.
Die image is nodig als basis voor de bestaande webserver-Dockerfile.
Controleer de image met:

```powershell
docker image ls
```

### 4. Bouw de webserverimage

De bestaande [ubuntu-webserver.Dockerfile](./ubuntu-webserver.Dockerfile)
gebruikt `ubuntu-apache2-php` als basis en start Apache op de voorgrond.
Bouw de uiteindelijke webserverimage met:

```powershell
.\build-docker.ps1 ubuntu-webserver.Dockerfile
```

Een alternatief is om de installatie en configuratie rechtstreeks in een
Dockerfile vast te leggen en daarmee een image te bouwen. Dat is beter
herhaalbaar, maar in deze oefening gebruiken we bewust `docker commit`.

## De webserver starten

Maak de map `C:\Apache\htdocs` aan en kopieer
[phpinfo.php](./phpinfo.php) ernaartoe:

```powershell
.\setup-apache-htdocs.ps1
```

Het script [setup-apache-htdocs.ps1](./setup-apache-htdocs.ps1) overschrijft
een bestaand `phpinfo.php` in die map.

Start daarna de webserver met [compose.yaml](./compose.yaml):

```powershell
docker compose up -d
```

Dit gebruikt de lokaal gebouwde image `ubuntu-webserver`, koppelt poort
`4000` op de host aan poort `80` in de container en koppelt de map
`C:\Apache\htdocs` aan `/var/www/html`. Open
[http://localhost:4000/phpinfo.php](http://localhost:4000/phpinfo.php).
Wijzigingen in de gekoppelde hostmap zijn zichtbaar in de container.

Het overeenkomstige Docker-commando is:

```powershell
docker run -d -p 4000:80 -v 'C:\Apache\htdocs:/var/www/html' ubuntu-webserver
```

Bekijk de status en logs, of stop de Compose-container:

```powershell
docker compose ps
docker compose logs
docker compose down
```

`phpinfo.php` toont uitgebreide informatie over de PHP-configuratie. Gebruik
dit voorbeeld alleen in een veilige testomgeving, niet op een publiek
toegankelijke productieserver.
