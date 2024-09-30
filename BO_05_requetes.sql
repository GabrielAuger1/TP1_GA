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
