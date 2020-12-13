# Seedbox

A collection of Dockerfiles and a docker-compose configuration to set up a
seedbox and personal media server.
This seedbox setup is based on the excellent work from jfroment (https://github.com/jfroment/seedbox) which I customized to fit my usage, and hopefully yours :)

## Included Applications

| Application           | Web Interface             | Docker image                                                                      | Version tags  | Notes                  |
------------------------|---------------------------|-----------------------------------------------------------------------------------|---------------|-------------------------
| Traefik               | traefik.yourdomain.com    | [traefik](https://hub.docker.com/_/traefik)                                       | *latest*      | Routing                |
| Plex                  | plex.yourdomain.com       | [linuxserver/plex](https://hub.docker.com/r/linuxserver/plex)                     | *latest*      | Media Streaming        |
| Ubooquity             | reader.yourdomain.com     | [linuxserver/ubooquity](https://hub.docker.com/r/linuxserver/ubooquity)           | *latest*      | Books & Comics Reader  |
| Ombi                  | ombi.yourdomain.com       | [linuxserver/ombi](https://hub.docker.com/r/linuxserver/ombi)                     | *v4.0*        | Movies/Series requests |
| Rutorrent             | torrent.yourdomain.com    | [mondedie/rutorrent](https://hub.docker.com/r/mondedie/rutorrent)                 | *latest*      | Torrents downloader    |
| JDownloader           | ddl.yourdomain.com        | [jlesage/jdownloader-2](https://hub.docker.com/r/jlesage/jdownloader-2)           | *latest*      | Direct downloader      |
| Jackett               | jackett.yourdomain.com    | [sclemenceau/trakttoplex](https://hub.docker.com/r/sclemenceau/docker-jackett)    | *cloudproxy*  | Tracker indexer        |
| Medusa                | medusa.yourdomain.com     | [linuxserver/medusa](https://hub.docker.com/r/linuxserver/medusa)                 | *latest*      | TV Shows monitor       |
| Radarr                | movie.yourdomain.com      | [linuxserver/radarr](https://hub.docker.com/r/linuxserver/radarr)                 | *latest*      | Movies monitor         |
| Lidarr                | book.yourdomain.com       | [linuxserver/lidarr](https://hub.docker.com/r/linuxserver/lidarr)                 | *latest*      | Music monitor          |
| Mylar                 | comic.yourdomain.com      | [linuxserver/mylar3](https://hub.docker.com/r/linuxserver/mylar3)                 | *latest*      | Comics monitor         |
| NextCloud-db (MariaDB)| not reachable             | [linuxserver/mariadb](https://hub.docker.com/r/linuxserver/mariadb)               | *latest*      | DB for Nextcloud       |
| NextCloud             | cloud.yourdomain.com      | [linuxserver/nextcloud](https://hub.docker.com/r/linuxserver/nextcloud)           | *latest*      | private cloud          |
| Portainer             | docker.yourdomain.com     | [portainer/portainer-ce](https://hub.docker.com/r/portainer/portainer-ce)         | *latest*      | Container management   |
| Netdata               | netdata.yourdomain.com    | [netdata/netdata](https://hub.docker.com/r/netdata/netdata)                       | *latest*      | Server monitoring      |
| Duplicati             | backup.yourdomain.com     | [linuxserver/duplicati](https://hub.docker.com/r/linuxserver/duplicati)           | *latest*      | Backups                |
| Shel in a box         | shell.yourdomain.com      | [sspreitzer/shellinabox](https://hub.docker.com/r/sspreitzer/shellinabox)         | *latest*      | Web Console            |
| Organizr              | home.yourdomain.com       | [organizr/organizr](https://hub.docker.com/r/organizr/organizr)                   | *latest*      | Hub for your apps      |
| SFTP                  | not reachable             | [netresearch/sftp](https://hub.docker.com/r/netresearch/sftp)                     | *latest*      | SFTP                   |
| OpenPVN               | vpn.yourdomain.com        | [linuxserver/openvpn-as](https://hub.docker.com/r/linuxserver/openvpn-as)         | *latest*      | VPN                    |
| Tautulli              | tautulli.yourdomain.com   | [linuxserver/tautulli](https://hub.docker.com/r/linuxserver/tautulli)             | *latest*      | Plex stats and admin   |

## Dependencies

Linux OS using apt-get to get packages and bash as a shell.

- [Docker](https://github.com/docker/docker) >= 1.13.0
    + Install guidelines for Ubuntu 16.04: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
- [Docker Compose](https://github.com/docker/compose) >=v1.10.0
    + Install guidelines for Ubuntu 16.04: https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-16-04
- [local-persist Docker plugin](https://github.com/CWSpear/local-persist): installed directly on host (not in container). This is a volume plugin that extends the default local driver’s functionality by allowing you specify a mountpoint anywhere on the host, which enables the files to always persist, even if the volume is removed via `docker volume rm`. Use *systemd* install for Ubuntu 16.04.

## Fresh Server installation

If you want to install those containers on a brand new linux server with a running linux OS (see Dependencies), run those commands:
```sh
apt-get update
apt-get install git
git clone https://github.com/Shinsentoh/seedbox.git /opt/docker-seedbox/ && cd "$_"
chmod +x server-fresh-install.sh
./server-fresh-install.sh
```
That's it

## Seedbox docker stack installation on existing server

If git is not installed :
```sh
apt-get update
apt-get install git
```
then clone the repo:
```sh
git clone https://github.com/Shinsentoh/seedbox.git /opt/docker-seedbox/ && cd "$_"
chmod +x docker-fresh-install.sh
./docker-fresh-install.sh
```

## Running & updating docker containers

```sh
./update-all.sh
```

docker-compose should manage all the volumes and network setup for you. If it
does not, verify that your docker and docker-compose version is updated.

Make sure you install the dependencies and finish configuration before doing
this.

## PlexPass

Just set the `VERSION` environment variable to `latest` on the Plex service (enabled by default).
See https://hub.docker.com/r/linuxserver/plex.

## Where is my data?

All data is saved in the docker volumes `config` or `torrents` and `media`.
These volumes are mapped to the `config` and `torrents` folders located on the host in `$BASE_PATH` directory which is a variable you can change in the .env file and the docker-compose.yml file.
Thanks to the **local-persist** Docker plugin, the data located in these volumes is persistent, meaning that volumes are not deleted, even when using the ```docker-compose down``` command. It would be a shame to loose everything by running a simple docker command ;-)
