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


*** TODO : *** 
-Enlever l'uart dans l'ENIGMA
-comprendre manipuler in/out de enigma et encoder_rs 
-créer un injecteur d'erreur simple dont l'entrée est générique ``` t : integer``` qui égale à une valeur fixe et fliper t bits de l'entrées (0 devient 1 et vice versa). 
-on reliée les 3 modules. 
