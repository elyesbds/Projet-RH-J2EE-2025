package utils;

import models.Employer;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Classe utilitaire simplifiée pour gérer les permissions
 * Seulement 3 méthodes de base - tu vérifies le rôle directement dans les servlets
 */
public class PermissionUtil {
    
    /**
     * Récupérer l'utilisateur connecté
     */
    public static Employer getLoggedUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (Employer) session.getAttribute("user");
        }
        return null;
    }
    
    /**
     * Vérifier si l'utilisateur est un administrateur
     * L'admin peut TOUT faire
     */
    public static boolean isAdmin(HttpServletRequest request) {
        Employer user = getLoggedUser(request);
        return user != null && "ADMIN".equals(user.getRole());
    }
    
    /**
     * Vérifier si l'utilisateur est chef de département
     */
    public static boolean isChefDept(HttpServletRequest request) {
        Employer user = getLoggedUser(request);
        return user != null && "CHEF_DEPT".equals(user.getRole());
    }
    
    /**
     * Vérifier si l'utilisateur est chef de projet
     */
    public static boolean isChefProjet(HttpServletRequest request) {
        Employer user = getLoggedUser(request);
        return user != null && "CHEF_PROJET".equals(user.getRole());
    }
}