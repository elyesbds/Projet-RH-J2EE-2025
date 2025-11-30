package utils;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
 * Classe utilitaire pour gérer la SessionFactory Hibernate
 */
public class HibernateUtil {
    
    private static SessionFactory sessionFactory;
    
    // Bloc statique pour initialiser la SessionFactory au démarrage
    static {
        try {
            // Créer la SessionFactory à partir du fichier hibernate.cfg.xml
            sessionFactory = new Configuration().configure().buildSessionFactory();
        } catch (Exception e) {
            System.err.println("Erreur lors de la création de la SessionFactory : " + e);
            e.printStackTrace();
            throw new ExceptionInInitializerError(e);
        }
    }
    
    /**
     * Récupérer la SessionFactory
     */
    public static SessionFactory getSessionFactory() {
        return sessionFactory;
    }
    
    /**
     * Fermer la SessionFactory 
     */
    public static void shutdown() {
        if (sessionFactory != null) {
            sessionFactory.close();
        }
    }
}