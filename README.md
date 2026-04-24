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
Pour utiliser le bloc Enigma, en entrée, il faut envoyer une donée sur 8 bits sur stream_in avec un flag lorsque l'nvoi de cette donée est fini ur enable. En sortie, on utilise le même fonctionnement, une donnée sur 9 bits sur stream_out et un flag lorsque cette donnée est valide sur data_valid. La sortie est sur 9 bits pour se connecter au bloc Encodeur RS mais le bit de poids fort est set à 0, il est donc très facilement possible de réduire la sortie à 8 bits si nécéssaire.
```
