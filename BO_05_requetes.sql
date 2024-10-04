ALTER SESSION SET CURRENT_SCHEMA = TP12062763;

-- 1. Combien y a-t-il eu d’emprunts par genre au cours des 3 derniers mois d’emprunts à partir de la plus récente date du jeu de données 
-- (vous ne pouvez pas « hard coder » la date)? Trier de la catégorie la moins populaire à la plus populaire, puis par nom de genre.
-- Vous devrez utiliser la fonction add_months. De plus, ajoutez un alias de colonne pour Nb. Emprunts.

SELECT LOWER(g.nom_genre) AS genre, COUNT(e.id) AS "Nb. Emprunts"
FROM BO.EMPRUNTS e
JOIN BO.LIVRES l ON e.livres_id = l.id
JOIN BO.GENRES g ON l.genres_id = g.id
WHERE e.date_emprunt >= ADD_MONTHS((SELECT MAX(date_emprunt) FROM BO.EMPRUNTS), -3)
GROUP BY LOWER(g.nom_genre)
ORDER BY COUNT(e.id) ASC, LOWER(g.nom_genre) ASC;

-- 2. Afficher la quantité de livres par genre (roman, science-fiction, etc.) ainsi que la part (%) de ce
-- genre sur la quantité totale de livres. Triez en ordre décroissant de part

SELECT LOWER(g.nom_genre) AS genre, COUNT(l.id) AS "Nb. Livres", ROUND(COUNT(l.id) * 100 / (SELECT COUNT(*) FROM BO.LIVRES), 2) AS "Part (%)"
FROM BO.LIVRES l
JOIN BO.GENRES g ON l.genres_id = g.id
GROUP BY LOWER(g.nom_genre)
ORDER BY "Part (%)" DESC;

-- 3. Quel est le genre de livre le plus populaire auprès de la clientèle masculine? Afficher le nombre
-- d’emprunts à ce jour ainsi que le genre de livre.

SELECT LOWER(g.nom_genre) AS genre, COUNT(e.id) AS "Nb. Emprunts"
FROM BO.EMPRUNTS e
JOIN BO.LIVRES l ON e.livres_id = l.id
JOIN BO.GENRES g ON l.genres_id = g.id
JOIN BO.CLIENTS c ON e.clients_id = c.id
WHERE c.sexe = 'M'
GROUP BY LOWER(g.nom_genre)
ORDER BY COUNT(e.id) DESC
FETCH FIRST ROW ONLY;

-- 4. Lister les membres (concaténation du prénom et du nom) qui ont fait plus de 3 emprunts au
-- cours des 6 derniers mois à partir de la plus récente date du jeu de données (il y a une date
-- d’emprunt, peu importe s’il a été retourné ou pas). Trier en ordre alphabétique de nom complet de membre.

SELECT LOWER(m.prenom || ' ' || m.nom) AS nom_complet, COUNT(e.id) AS nb_emprunts
FROM BO.MEMBRES m
JOIN BO.EMPRUNTS e ON m.id = e.membres_id
WHERE e.date_emprunt >= ADD_MONTHS((SELECT MAX(date_emprunt) FROM BO.EMPRUNTS), -6)
GROUP BY LOWER(m.prenom || ' ' || m.nom)
HAVING COUNT(e.id) > 3
ORDER BY nom_complet ASC;

-- 5. Afficher la liste des membres qui ont des livres en retard. On ne veut voir que ceux dont le retard est supérieur à la moyenne 
-- des retards de tous les membres. Dans le résultat, nous aimerions
-- avoir les colonnes Membre (concaténation de prénom et nom), Date_Emprunt, Titre et le nombre
-- de jours en ordre décroissant. (*voir note).
-- *Note : Nous n’avons pas à tenir compte des enregistrements dont la date de retour est nulle. On veut seulement vérifier les livres
-- qui ont été retournés en retard et non pas les livres toujours empruntés et jamais retournés.

WITH Delay_Data AS (
    SELECT 
        m.prenom || ' ' || m.nom AS Membre,
        e.date_emprunt AS Date_Emprunt,
        l.titre AS Titre,
        e.date_retour - e.date_retour_prevu AS nb_jours_retard
    FROM 
        BO.EMPRUNTS e
    JOIN 
        BO.MEMBRES m ON e.membres_id = m.id
    JOIN 
        BO.LIVRES l ON e.livres_id = l.id
    WHERE 
        e.date_retour IS NOT NULL
        AND (e.date_retour - e.date_retour_prevu) > 0
)
SELECT 
    Membre, 
    Date_Emprunt, 
    Titre, 
    nb_jours_retard
FROM 
    Delay_Data
WHERE 
    nb_jours_retard > (SELECT AVG(nb_jours_retard) FROM Delay_Data)
ORDER BY 
    nb_jours_retard DESC;

-- 6. Afficher la liste des membres n'ayant pas encore emprunté de livre. Vous devez afficher le
-- numéro de membre, puis son nom complet dans une seule colonne avec le format « Nom, P. ».
-- Cette liste doit s’afficher en ordre alphabétique.

SELECT 
    m.id AS Numero_Membre,
    m.nom || ', ' || SUBSTR(m.prenom, 1, 1) || '.' AS Nom_Complet
FROM 
    BO.MEMBRES m
LEFT JOIN 
    BO.EMPRUNTS e ON m.id = e.membres_id
WHERE 
    e.membres_id IS NULL
ORDER BY 
    m.nom ASC, m.prenom ASC;

-- 7. Quels sont les 3 livres qui ont été empruntés le plus souvent en 2022? On veut voir les colonnes
-- suivantes : « Nombre d’emprunts » (écrit de cette manière et en ordre décroissant) et Titre.

SELECT 
    COUNT(e.id) AS "Nombre d'emprunts",
    l.titre AS Titre
FROM 
    BO.EMPRUNTS e
JOIN 
    BO.LIVRES l ON e.livres_id = l.id
WHERE 
    EXTRACT(YEAR FROM e.date_emprunt) = 2022
GROUP BY 
    l.titre
ORDER BY 
    "Nombre d'emprunts" DESC
FETCH FIRST 3 ROWS ONLY;

-- 8. Quelle est la valeur totale des livres perdus (livres qui ont été empruntés, mais jamais retournés
-- et dont le membre a le statut Expiré)

SELECT 
    SUM(l.prix) AS "Valeur totale des livres perdus"
FROM 
    BO.EMPRUNTS e
JOIN 
    BO.LIVRES l ON e.livres_id = l.id
JOIN 
    BO.MEMBRES m ON e.membres_id = m.id
WHERE 
    e.date_retour IS NULL
    AND m.statut_membre = 'expiré';

-- 9. Pour chaque section, afficher le nombre de livres par genres. Trier en ordre de nom de section et
-- de nom de genre.

SELECT 
    s.nom AS Nom_Section,
    g.nom_genre AS Nom_Genre,
    COUNT(l.id) AS "Nombre de livres"
FROM 
    BO.LIVRES l
JOIN 
    BO.SECTIONS s ON l.sections_id = s.id
JOIN 
    BO.GENRES g ON l.genres_id = g.id
GROUP BY 
    s.nom, g.nom_genre
ORDER BY 
    s.nom ASC, g.nom_genre ASC;

-- 10. Créer une vue dans le schéma BO nommée RETARDS_ MEMBRES qui ferait afficher les membres
-- qui ont des frais de retard et afficher le total des frais par membre considérant qu’il en coûte
-- 0,25$ par jour et par livre (arrondir à 2 décimales). Triez en ordre décroissant de frais
-- (*voir note).

CREATE OR REPLACE VIEW BO.RETARDS_MEMBRES AS
SELECT 
    m.id AS Membre_ID,
    m.prenom || ' ' || m.nom AS Nom_Complet,
    ROUND(SUM((e.date_retour - e.date_retour_prevu) * 0.25), 2) AS Total_Frais
FROM 
    BO.MEMBRES m
JOIN 
    BO.EMPRUNTS e ON m.id = e.membres_id
WHERE 
    e.date_retour IS NOT NULL
    AND (e.date_retour - e.date_retour_prevu) > 0
GROUP BY 
    m.id, m.prenom, m.nom
ORDER BY 
    Total_Frais DESC;