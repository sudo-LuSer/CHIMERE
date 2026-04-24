# CHIMERE
Chaîne Hybride d’Injection et de Mesure d’Erreurs pour Reed‑Solomon et Ethernet

```mermaid
flowchart LR
    A["Message (PC)"] -->|Ethernet| B["ENIGMA ENC FPGA"]
    B --> C["Encodeur_RS FPGA"]
    C --> D["Injecteur d'erreurs FPGA"]
    D --> |Ethernet| E["Décodeur C++"]
    E --> |Ethernet| F["ENIGMA DEC FPGA"]
    F --> |Ethernet| G["Message d'origine PC"]
```


# TODO :
```
Enlever l'uart dans l'ENIGMA.
comprendre manipuler in/out de enigma et encoder_rs.
créer un injecteur d'erreur simple dont l'entrée est générique ` t : integer` qui égale à une valeur fixe et fliper t bits de l'entrées (0 devient 1 et vice versa). 
on reliée les 3 modules.
```
# Bloc Enigma
```
Pour utiliser le bloc Enigma, en entrée, il faut envoyer une donée sur 8 bits sur stream_in avec un flag
lorsque l'envoi de cette donée est fini ur enable. En sortie, on utilise le même fonctionnement, une
donnée sur 9 bits sur stream_out et un flag lorsque cette donnée est valide sur data_valid. La sortie est
sur 9 bits pour se connecter au bloc Encodeur RS mais le bit de poids fort est set à 0, il est donc très
facilement possible de réduire la sortie à 8 bits si nécéssaire.

Il faut configurer le bloc avant qu'il renvoie des lettres, pour cela, il faut indiquer pour chaque rotor son numéro et sa position iitiale, par exemple, si on veut regler le rotor numéro 2 en position 12 puis le rotor 1 en position 0 et enfin le rotor 3 en position 2, il faut rentrer la suite : "2 1 2 1 0 0 3 0 2". Ensuite, la machine  reverra les lettres codées selon la configuration rentrée plus tôt.
```
