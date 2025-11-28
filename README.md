# CY-RH - Guide d'Installation Rapide

## Prérequis
- MySQL Workbench
- Eclipse IDE
- Apache Tomcat 10
- Maven

---

## Étape 1 : Base de Données

1. Ouvrir MySQL Workbench
2. Se connecter avec le mot de passe : `1234`
3. Exécuter le script `cy_rh_bdd.sql`
   - File → Open SQL Script → Sélectionner `cy_rh_bdd.sql`
   - Cliquer sur l'éclair pour exécuter
4. La base `CY_RH` est créée avec les données de test

---

## Étape 2 : Application

1. Télécharger le dossier `CY-RH`
2. Importer dans Eclipse
   - File → Open Projects from File System
   - Directory → Sélectionner le dossier `CY-RH`
   - Finish
3. Mettre à jour Maven
   - Clic droit sur le projet → Maven → Update Project → OK
4. Lancer l'application
   - Clic droit sur le projet → Run As → Run on Server
   - Sélectionner Tomcat 10 → Finish

---

## Étape 3 : Connexion

**Compte Administrateur :**
- Email : `admin@cy-rh.local`
- Mot de passe : `admin123`

**Comptes Employés :**
- Email : `[prenom].[nom]@cy-rh.local` (ex: `maria.lopez@cy-rh.local`)
- Mot de passe : `password`

---

## C'est prêt !

Bienvenue sur CY-RH, vous êtes connecté.

L'application de gestion des ressources humaines est maintenant opérationnelle.
