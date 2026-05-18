# 🏏 Analyse SQL — Mega-Auction IPL 2025

> Cas pratique data analyst : exploration et segmentation des transferts IPL 2025 avec MySQL — budgets par franchise, benchmarks et analyses de répartition.

---

## 🎯 Objectif

Ce projet analyse les données de la mega-auction IPL 2025 à travers une série de requêtes SQL progressives, allant des statistiques générales jusqu'aux analyses avancées par franchise et par rôle.

Il couvre un large spectre de compétences SQL utilisées en contexte professionnel :

| Compétence SQL | Sections |
|---|---|
| Agrégations & GROUP BY | 1, 3, 5 |
| Fonctions fenêtres — `ROW_NUMBER`, `SUM OVER` | 2, 3 |
| Common Table Expressions (CTE) | 2, 3, 5 |
| Sous-requêtes corrélées | 4 |
| Expressions CASE & Pivoting | 2, 3 |
| UNION ALL | 4 |
| Jointures JOIN | 2 |

---

## 📁 Structure du projet

```
ipl-sql-analysis-2025/
│
├── data/
│   └── ipl_players_seed.sql   # Création de la table + données
│
├── ipl_analysis.sql           # Toutes les requêtes d'analyse
│
└── README.md
```

---

## 🗃️ Modèle de données

**Table : `IPLPlayers`**

| Colonne | Type | Description |
|---|---|---|
| `id` | INT | Clé primaire auto-incrémentée |
| `Player` | VARCHAR(120) | Nom du joueur |
| `Price_in_cr` | DECIMAL(10,2) | Prix en crores de roupies |
| `Type` | VARCHAR(50) | `Indian` ou `Overseas`, capped ou uncapped |
| `Acquisition` | VARCHAR(50) | `Retained`, `Auction` ou `RTM` |
| `Role` | VARCHAR(50) | `Batter`, `Bowler`, `All-rounder`, `Batter/Wicketkeeper` |
| `Team` | VARCHAR(100) | Franchise IPL |

**10 franchises · ~250 joueurs · données réelles de la mega-auction 2025**

---

## 📊 Analyses réalisées

### Section 1 — Statistiques générales
- Nombre total de joueurs dans la base
- Budget total, nombre de joueurs et prix moyen par franchise

### Section 2 — Prix individuels
- Top 3 des All-rounders les mieux rémunérés
- Joueur le plus cher par équipe (CTE + JOIN)
- Top 2 des joueurs par équipe (fonctions fenêtres)
- Vue pivot : Top 2 affiché sur une seule ligne par équipe

### Section 3 — Répartition budgétaire
- Part (%) de chaque joueur dans le budget de son équipe
- Segmentation High / Medium / Low avec comptage et budget par segment

### Section 4 — Benchmarks
- Salaire moyen : joueurs indiens vs joueurs étrangers
- Joueurs qui gagnent plus que la moyenne salariale de leur équipe
- Joueur le plus cher par rôle

### Section 5 — Analyses bonus
- Stratégie d'acquisition (Retained / Auction / RTM) par franchise
- Ratio dépense par joueur — classement des franchises
- Nombre de joueurs étrangers par équipe
- Joueur retenu à moindre coût par franchise

---

## ⚙️ Exécution

**Prérequis : MySQL 8.0+**

```sql
-- Charger les données
SOURCE data/ipl_players_seed.sql;

-- Lancer les analyses
SOURCE ipl_analysis.sql;
```

Compatible avec MySQL Workbench, DBeaver, TablePlus et le CLI `mysql`.

---

## 🛠️ Outils utilisés

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Avancé-orange)

---

## 👤 Auteur

**Frejus Ibatta** — Ingénieur géophysicien - Data scientist

[https://www.linkedin.com/in/frejus-ibatta/]
