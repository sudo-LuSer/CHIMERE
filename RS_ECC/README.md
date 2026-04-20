# CHIMERE – Chaîne Hybride d’Injection et de Mesure d’Erreurs pour Reed‑Solomon et Ethernet

## Partie ECC : Encodeur/Décodeur Reed‑Solomon RS(7,3) dans GF(2³)

Ce dépôt contient l’implémentation **matérielle (VHDL)** et **logicielle (C++)** du code correcteur d’erreurs Reed‑Solomon utilisé dans le démonstrateur **CHIMERE**.  
La partie matérielle est destinée à être synthétisée sur FPGA (ENIGMA ENC / DEC), tandis que la partie logicielle sert de référence de test et d’outil de simulation du canal bruité.

---

## 1. Encodeur VHDL – `rs_encoder`

### Fichiers
- `VHDL/rs_pkg.vhd` : package contenant les constantes du code, le type `gf_array_t` et la fonction de multiplication dans GF(2³).
- `VHDL/rs_encoder.vhd` : entité et architecture de l’encodeur Reed‑Solomon.

### Paramètres du code (définis dans `rs_pkg`)

| Paramètre | Valeur | Description |
|-----------|--------|-------------|
| `N`       | 7      | Longueur totale du mot de code (symboles de 3 bits) |
| `K`       | 3      | Longueur du message original |
| `N_RDNCY` | 4      | Nombre de symboles de redondance (N – K) |

> **Remarque :** Le code est défini sur le corps de Galois GF(2³) avec le polynôme primitif  
> **P(x) = x³ + x + 1** (binaire `1011`).  
> Le polynôme générateur utilisé est :  
> **g(x) = x⁴ + α³·x³ + α²·x² + α¹·x + α⁰** (avec des coefficients stockés dans `G_COEF`).

### Entrées / Sorties de l’entité `rs_encoder`

| Port        | Direction | Largeur | Description |
|-------------|-----------|---------|-------------|
| `clk`       | in        | 1 bit   | Horloge système (front montant actif) |
| `rst`       | in        | 1 bit   | Reset asynchrone actif haut – réinitialise la machine d’états et les registres |
| `enable`    | in        | 1 bit   | Signal de validation du transfert. Lorsque `enable = '1'`, un nouveau symbole est consommé ou produit. |
| `data_in`   | in        | 3 bits  | Symbole d’entrée (message original). Chaque symbole représente un élément de GF(2³) sous forme binaire naturelle. |
| `data_out`  | out       | 3 bits  | Symbole de sortie (mot de code complet : d’abord les K symboles du message, puis les N–K symboles de parité). |
| `valid_out` | out       | 1 bit   | Indique que `data_out` contient un symbole valide du mot de code. |

### Comportement détaillé

La machine d’états de l’encodeur passe par trois phases :

1. **`IDLE`** :  
   - Attend que `enable = '1'`.  
   - Dès le premier symbole présent sur `data_in`, la machine passe dans l’état `ENCODE_MSG`.  
   - Le symbole d’entrée est immédiatement recopié sur `data_out` avec `valid_out = '1'`.  
   - Le LFSR (Linear Feedback Shift Register) de l’encodeur est mis à jour selon l’équation de récurrence de Reed‑Solomon.

2. **`ENCODE_MSG`** :  
   - Les `K` symboles du message (y compris le premier) sont successivement lus sur `data_in` et recopiés sur `data_out` (`valid_out` maintenu à `'1'`).  
   - À chaque symbole, le LFSR est mis à jour avec la rétroaction `feedback_sym = data_in XOR lfsr(N_RDNCY-1)`.  
   - Après le `K`-ième symbole, la machine passe dans l’état `OUT_PARITY`.

3. **`OUT_PARITY`** :  
   - Les `N_RDNCY` symboles de parité contenus dans le LFSR sont extraits un par un et émis sur `data_out` (avec `valid_out = '1'`).  
   - Le registre LFSR est décalé à chaque coup d’horloge sans nouvelle rétroaction.  
   - Après `N_RDNCY` cycles, la machine retourne en `IDLE`.

**Remarque importante :**  
- Le signal `enable` doit être maintenu haut pendant toute la durée du traitement d’un bloc de K symboles de message **et** pendant l’émission des symboles de parité.  
- La latence totale est de **N cycles d’horloge** (K pour la copie du message + N_RDNCY pour la parité), avec le premier symbole de sortie disponible un cycle après l’assertion de `enable`.

### Multiplication dans GF(2³) – fonction `gf_mult_3`

La fonction implémente l’algorithme de multiplication sur le corps fini défini par le polynôme primitif **x³ + x + 1**.  
Elle est purement combinatoire et utilisée dans la mise à jour du LFSR.

---

## 2. Bibliothèque logicielle C++ (simulation et test)

### Organisation des fichiers

```
CHIMERE/RS_ECC/
├── CMakeLists.txt
├── .gitignore
├── include/
│ ├── rs_encoder.hpp
│ ├── rs_decoder.hpp
│ └── rs_tools.hpp
├── src/
│ ├── main.cpp
│ ├── rs_encoder.cpp
│ ├── rs_decoder.cpp
│ └── rs_tools.cpp
└── VHDL/
├── rs_pkg.vhd
└── rs_encoder.vhd
```


### Description des modules C++

| Fichier | Rôle |
|---------|------|
| `rs_tools.hpp/.cpp` | Définition des opérations arithmétiques dans GF(2³) : addition, multiplication, calcul de l’inverse, évaluation de polynômes, recherche de racines, etc. Utilisé à la fois par l’encodeur et le décodeur. |
| `rs_encoder.hpp/.cpp` | Implémentation logicielle de l’encodeur Reed‑Solomon (mêmes paramètres que le VHDL). Fournit une méthode `encode()` qui prend un vecteur de K symboles et retourne les N symboles du mot de code. |
| `rs_decoder.hpp/.cpp` | Décodeur Reed‑Solomon logiciel utilisant l’algorithme de Berlekamp‑Massey (ou équivalent). Permet de corriger jusqu’à `(N-K)/2` erreurs par bloc. |
| `main.cpp` | Programme principal de test : génère des messages aléatoires, les encode, injecte des erreurs contrôlées, les décode et compare avec le message original. Utilisé pour valider l’implémentation matérielle par comparaison. |

### Compilation (CMake)

```bash
cd CHIMERE/RS_ECC
mkdir build && cd build
cmake ..
make
```