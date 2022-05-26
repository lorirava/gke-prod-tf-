# Production Setup for Cuba Brand

Il seguente progetto Terraform fa il provisioning di un cluster Kubernetes Regional su infrastruttura Google Cloud. 
Oltre al cluster kubernetes sono comprese:
- due istante di database (staging e live) destinate a database di tipo db2
- un'istanza dedicata ad una installazione di Jenkins e varie utilità

## Dettaglio
- predisposti due progetti separati, prod e utils.
-- prod: contiene oltre ad una networking dedicata, due istanze per i database, il servizio managed FileStore (NFS as a Service di Google), il cluster GKE composto da control plane regional (managed da google) e un node pool di 4 nodi sempre suddivisi nelle zone disponibili della region. Inoltre contiene il setup di una VPN in HA che collega le network di prod e utils, aprendo anche le rotte ferso il FileStore
-- utils: contiene oltre ad una networking dedicata, una istanza dedicata all'installazione di Jenkins

## Networking and Security
Tutta l'infrastruttura è privata. Solo il control plane di Kubernetes ha un accesso tramite internet (autenticato tramite gcloud).
I node pool e le VM non hanno indirizzi IP pubblici. Si interfacciano verso l'esterno:
- in uscita tramite il servizio google Cloud Nat (singolo IP e punto di uscita per tutti)
- in entrata tramite global load balancer/ingress per il cluster kubernetes. 
Oppure per accessi di sistema si accede tramite IAP (Identity Aware Proxy, servizio di google che permette l'accesso alle risorse private dell'infrastruttura tramite autenticazione con gcloud), previa autorizzazione concessa all'utente lato IAM. 

Le network di prod e utils sono in peering. 

Vista la necessità di condividere un volume tra Prod e Utils si è scelto per il servizio di google FileStore, che è un NFS as a service. Il servizio risiede in Prod, ma avendo una rete dedicata anche se in peering con Utils, non si raggiungerebbe. Per cui è stata stabilita una VPN in HA tra le due network con apertura delle rotte anche verso la network di FileStore. 

## Resilience
Il cluster kubernetes ha sia il control plane che i nodi ridondati sulle zone della region. La VPN è in HA e il servizio FileStore di tipo Premium è anch'esso in HA.

I database hanno un piano di backup giornaliero e spostamento dei backup su infrastruttura separata. 

Il cluster è configurato in modalità "autoscalig" automatico dei node. 

## Next Step
Abilitazione di Cloud Armor come protezione contro attacchi DDoS, XXS, SQL Injection e molto altro, sebbene già il Global Load Balancer aiuta a prevenire alcune di queste vulnerabilità. 
Setup di un CDC (Change Data Capture) per mettere i database in HA. 


## Disegno architetturale
in allegato: Cuba-architecture.jpg



