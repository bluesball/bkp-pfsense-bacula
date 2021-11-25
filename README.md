# BKP do pfsense


Script para fazer bkp das configs do pfsense e armazenar com bacula

Kibado da documentacao oficial do pfsense e do site do bacula.lat: 

```sh
https://docs.netgate.com/pfsense/en/latest/backup/remote-backup.html
https://www.bacula.lat/pre-script-para-backup-de-firewalls-pfsense/
```

### Sugestão de Job para o Bacula

```sh
Job {
  Name = "bkp-pfsense"
  Description = "Bkp Pfsenses"
  Client = "bacula-server-fd"
  Enabled = yes
  Fileset = "FileSet-Pfsense"
  JobDefs = "JobDefs-DataCenter"
  Runscript {
   Command = "/etc/bacula/scripts/before-bacula-pfsense.sh"
   FailJobOnError = yes
   RunsWhen = Before
  }
}
```

### Sugestão de FileSet para o Bacula

```sh
FileSet {
  Name = "FileSet-Pfsense"
  Include { 
    Options {
      signature = MD5
    }
    File = /opt/bkp-pfsense
  }
}
```
