package utils;

import java.util.regex.Pattern;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Calendar;

/**
 * Classe utilitaire pour valider les données des formulaires
 * Contient des méthodes simples pour vérifier chaque type de champ
 */
public class ValidationUtil {

    // Pattern pour vérifier l'email
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    // Pattern pour vérifier le téléphone (10 chiffres commençant par 0)
    private static final Pattern TELEPHONE_PATTERN = Pattern.compile("^0[0-9]{9}$");

    // Pattern pour vérifier le matricule (EMPxxx)
    private static final Pattern MATRICULE_PATTERN = Pattern.compile("^EMP[0-9]{3,}$");

    // Pattern pour vérifier que c'est seulement des lettres,espaces, tirets
    private static final Pattern LETTRES_PATTERN = Pattern.compile("^[a-zA-ZÀ-ÿ\\s'-]+$");

    // Pattern pour vérifier que c'est seulement des chiffres
    private static final Pattern CHIFFRES_PATTERN = Pattern.compile("^[0-9]+$");

    /**
     * Vérifie si une chaîne est vide ou null
     */
    public static boolean estVide(String valeur) {
        return valeur == null || valeur.trim().isEmpty();
    }

    /**
     * Vérifie si un nom/prénom est valide (seulement des lettres)
     */
    public static boolean estNomValide(String nom) {
        if (estVide(nom)) {
            return false;
        }
        // Vérifie que c'est seulement des lettres, espaces et tirets
        return LETTRES_PATTERN.matcher(nom.trim()).matches();
    }

    /**
     * Vérifie si un email est valide
     */
    public static boolean estEmailValide(String email) {
        if (estVide(email)) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    /**
     * Vérifie si un téléphone est valide (10 chiffres commençant par 0)
     */
    public static boolean estTelephoneValide(String telephone) {
        if (estVide(telephone)) {
            return false;
        }
        return TELEPHONE_PATTERN.matcher(telephone.trim()).matches();
    }

    /**
     * Vérifie si un matricule est valide (format EMPxxx)
     */
    public static boolean estMatriculeValide(String matricule) {
        if (estVide(matricule)) {
            return false;
        }
        return MATRICULE_PATTERN.matcher(matricule.trim()).matches();
    }

    /**
     * Vérifie si un nombre est strictement positif (> 0)
     * Utilisé pour salaires et autres montants qui ne peuvent pas être zéro
     */
    public static boolean estNombrePositif(String valeur) {
        if (estVide(valeur)) {
            return false;
        }
        try {
            double nombre = Double.parseDouble(valeur);
            return nombre > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Vérifie si un nombre est positif ou zéro (>= 0)
     * Utilisé pour les primes et déductions qui peuvent être à 0
     */
    public static boolean estNombrePositifOuZero(String valeur) {
        if (estVide(valeur)) {
            return false;
        }
        try {
            double nombre = Double.parseDouble(valeur);
            return nombre >= 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Vérifie si une date est valide et n'est pas dans le futur
     */
    public static boolean estDateValide(String dateStr) {
        if (estVide(dateStr)) {
            return false;
        }

        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            sdf.setLenient(false); // Mode strict pour la validation
            Date date = sdf.parse(dateStr);

            // Accepter toutes les dates valides (passé ET futur)
            // La vérification de cohérence date/état est faite dans les servlets
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Vérifie si une date de fin est après une date de début
     */
    public static boolean estDateFinApresDebut(String dateDebutStr, String dateFinStr) {
        if (estVide(dateDebutStr) || estVide(dateFinStr)) {
            return true; // Si une des dates est vide, on ne valide pas ici
        }

        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date dateDebut = sdf.parse(dateDebutStr);
            Date dateFin = sdf.parse(dateFinStr);

            return dateFin.after(dateDebut) || dateFin.equals(dateDebut);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Nettoie une chaîne pour éviter les injections XSS
     */
    public static String nettoyerTexte(String texte) {
        if (texte == null) {
            return "";
        }
        // Remplace les caractères dangereux
        return texte.trim()
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;")
                .replace("/", "&#x2F;");
    }

    /**
     * Vérifie qu'un texte ne dépasse pas une longueur max
     */
    public static boolean estLongueurValide(String texte, int longueurMax) {
        if (texte == null) {
            return false;
        }
        return texte.trim().length() <= longueurMax;
    }

    /**
     * Vérifie qu'un champ contient seulement des chiffres
     */
    public static boolean estSeulementChiffres(String valeur) {
        if (estVide(valeur)) {
            return false;
        }
        return CHIFFRES_PATTERN.matcher(valeur.trim()).matches();
    }

    /**
     * Normalise une date en mettant l'heure à 00:00:00.000
     * Élimine la partie temps pour comparer uniquement les dates
     */
    public static Date normaliserDate(Date date) {
        if (date == null) {
            return null;
        }
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

    /**
     * Vérifie si l'état d'un projet est valide
     */
    public static boolean estEtatProjetValide(String etat) {
        if (estVide(etat)) {
            return false;
        }
        return etat.equals("PAS_COMMENCE") || etat.equals("EN_COURS") ||
                etat.equals("TERMINE") || etat.equals("ANNULE");
    }
}