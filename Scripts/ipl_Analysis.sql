-- ============================================================
--  PROJET : Analyse des données des joueurs IPL 2025
--  Auteur  : [Votre Nom]
--  Outil   : MySQL 8.0+
--  Source  : Données de la mega-auction IPL 2025
--  Description : Exploration et analyse des transferts, budgets
--                et répartitions des effectifs par franchise.
-- ============================================================

USE sqlCasestudies;

-- (Les INSERT figurent dans le fichier data/IPL_InsertData.sql)

-- ============================================================
-- SECTION 1 — Statistiques générales
-- ============================================================

-- 1.1 Nombre total de joueurs enregistrés
SELECT COUNT(DISTINCT Player) AS total_joueurs
FROM IPLPlayers;

-- 1.2 Nombre de joueurs et dépenses totales par équipe
--     → Classement décroissant pour identifier les franchises
--       les plus dépensières
SELECT
    Team                      AS equipe,
    COUNT(*)                  AS nb_joueurs,
    SUM(Price_in_cr)          AS depenses_totales_cr,
    ROUND(AVG(Price_in_cr),2) AS prix_moyen_cr
FROM IPLPlayers
GROUP BY Team
ORDER BY depenses_totales_cr DESC;


-- ============================================================
-- SECTION 2 — Analyse des prix individuels
-- ============================================================

-- 2.1 Top 3 des All-rounders les mieux rémunérés (toutes équipes)

SELECT
    Player,
    Team,
    Price_in_cr
FROM IPLPlayers
WHERE Role = 'All-rounder'
ORDER BY Price_in_cr DESC
LIMIT 3;

-- 2.2 Joueur le plus cher par équipe (via CTE)
WITH cte_prix_max AS (
    SELECT
        Team,
        MAX(Price_in_cr) AS prix_max
    FROM IPLPlayers
    GROUP BY Team
)
SELECT
    ip.Team,
    ip.Player,
    cmp.prix_max AS prix_cr
FROM IPLPlayers  ip
JOIN cte_prix_max cmp
  ON ip.Team = cmp.Team
 AND ip.Price_in_cr = cmp.prix_max
ORDER BY cmp.prix_max DESC;

-- 2.3 Top 2 des joueurs les mieux payés par équipe
--     → ROW_NUMBER() garantit l'unicité du rang même en cas d'ex-æquo
WITH cte_rang AS (
    SELECT
        Team,
        Player,
        Price_in_cr,
        ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS rang
    FROM IPLPlayers
)
SELECT
    Team,
    Player,
    Price_in_cr
FROM cte_rang
WHERE rang <= 2
ORDER BY Team, rang;

-- 2.4 Vue pivot : joueur n°1 et joueur n°2 côte à côte par équipe
--     → Utile pour un reporting condensé ou un export Excel
WITH cte_rang AS (
    SELECT
        Team,
        Player,
        Price_in_cr,
        ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS rang
    FROM IPLPlayers
)
SELECT
    Team,
    MAX(CASE WHEN rang = 1 THEN Player      END) AS joueur_1,
    MAX(CASE WHEN rang = 1 THEN Price_in_cr END) AS prix_joueur_1_cr,
    MAX(CASE WHEN rang = 2 THEN Player      END) AS joueur_2,
    MAX(CASE WHEN rang = 2 THEN Price_in_cr END) AS prix_joueur_2_cr
FROM cte_rang
GROUP BY Team
ORDER BY prix_joueur_1_cr DESC;


-- ============================================================
-- SECTION 3 — Répartition budgétaire
-- ============================================================

-- 3.1 Part (%) de chaque joueur dans le budget de son équipe

SELECT
    Team,
    Player,
    Price_in_cr,
    ROUND(
        Price_in_cr / SUM(Price_in_cr) OVER (PARTITION BY Team) * 100,
    2) AS part_budget_pct
FROM IPLPlayers
ORDER BY Team, part_budget_pct DESC;

-- 3.2 Segmentation des joueurs par tranche de prix
--     High   : Price > 15 Cr
--     Medium : 5 Cr <= Price <= 15 Cr
--     Low    : Price < 5 Cr
WITH cte_segment AS (
    SELECT
        Team,
        Player,
        Price_in_cr,
        CASE
            WHEN Price_in_cr > 15             THEN 'High'
            WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
            ELSE                                   'Low'
        END AS segment
    FROM IPLPlayers
)
SELECT
    Team,
    segment,
    COUNT(*)                  AS nb_joueurs,
    SUM(Price_in_cr)          AS budget_segment_cr,
    ROUND(AVG(Price_in_cr),2) AS prix_moyen_segment_cr
FROM cte_segment
GROUP BY Team, segment
ORDER BY Team, FIELD(segment, 'High','Medium','Low');


-- ============================================================
-- SECTION 4 — Comparaisons & Benchmarks
-- ============================================================

-- 4.1 Salaire moyen : joueurs indiens vs joueurs étrangers
SELECT
    'Indien'                   AS categorie,
    ROUND(AVG(Price_in_cr), 2) AS prix_moyen_cr
FROM IPLPlayers
WHERE Type LIKE 'India%'

UNION ALL

SELECT
    'Etranger'                 AS categorie,
    ROUND(AVG(Price_in_cr), 2) AS prix_moyen_cr
FROM IPLPlayers
WHERE Type LIKE 'Oversea%';

-- 4.2 Joueurs qui gagnent plus que la moyenne de leur propre équipe
--     → Sous-requête corrélée : recalcul de l'AVG pour chaque équipe
SELECT
    ip.Team,
    ip.Player,
    ip.Price_in_cr,
    ROUND((
        SELECT AVG(Price_in_cr)
        FROM   IPLPlayers sub
        WHERE  sub.Team = ip.Team
    ), 2) AS moyenne_equipe_cr
FROM IPLPlayers ip
WHERE ip.Price_in_cr > (
    SELECT AVG(Price_in_cr)
    FROM   IPLPlayers sub
    WHERE  sub.Team = ip.Team
)
ORDER BY ip.Team, ip.Price_in_cr DESC;

-- 4.3 Joueur le plus cher par rôle
--     → Identifie le meilleur investissement dans chaque spécialité
SELECT
    ip.Role,
    ip.Player,
    ip.Team,
    ip.Price_in_cr
FROM IPLPlayers ip
WHERE ip.Price_in_cr = (
    SELECT MAX(Price_in_cr)
    FROM   IPLPlayers sub
    WHERE  sub.Role = ip.Role
)
ORDER BY ip.Price_in_cr DESC;


-- ============================================================
-- SECTION 5 — Analyses complémentaires (bonus)
-- ============================================================

-- 5.1 Répartition des modes d'acquisition par équipe
--     → Retained / Auction / RTM : quelle stratégie pour chaque franchise ?
SELECT
    Team,
    Acquisition,
    COUNT(*)         AS nb_joueurs,
    SUM(Price_in_cr) AS montant_total_cr
FROM IPLPlayers
GROUP BY Team, Acquisition
ORDER BY Team, montant_total_cr DESC;

-- 5.2 Classement des franchises par ratio dépense/joueur
SELECT
    Team,
    COUNT(*)                              AS nb_joueurs,
    SUM(Price_in_cr)                      AS budget_total_cr,
    ROUND(SUM(Price_in_cr) / COUNT(*), 2) AS ratio_depense_par_joueur_cr
FROM IPLPlayers
GROUP BY Team
ORDER BY ratio_depense_par_joueur_cr DESC;

-- 5.3 Nombre de joueurs étrangers par équipe
--     (les franchises IPL sont limitées à 4 étrangers sur le terrain)
SELECT
    Team,
    COUNT(*) AS nb_joueurs_etrangers
FROM IPLPlayers
WHERE Type LIKE 'Oversea%'
GROUP BY Team
ORDER BY nb_joueurs_etrangers DESC;

-- 5.4 Joueur retenu (Retained/RTM) le moins cher par équipe
--     → Repère les paris sur l'avenir réalisés à moindre coût
WITH cte_retention AS (
    SELECT
        Team,
        Player,
        Price_in_cr,
        Acquisition,
        ROW_NUMBER() OVER (
            PARTITION BY Team
            ORDER BY Price_in_cr ASC
        ) AS rang
    FROM IPLPlayers
    WHERE Acquisition IN ('Retained', 'RTM')
)
SELECT
    Team,
    Player,
    Price_in_cr,
    Acquisition
FROM cte_retention
WHERE rang = 1
ORDER BY Price_in_cr ASC;
