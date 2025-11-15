package dao;

import models.Employer;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateUtil;
import java.util.List;

/**
 * DAO simplifié pour gérer les employés
 */
public class EmployerDAO {
    
    /**
     * Créer un nouvel employé
     */
    public boolean create(Employer employer) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.persist(employer);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Récupérer un employé par son ID
     */
    public Employer getById(Integer id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Employer.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer tous les employés
     */
    public List<Employer> getAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Employer", Employer.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Mettre à jour un employé
     */
    public boolean update(Employer employer) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.merge(employer);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Supprimer un employé par son ID
     */
    public boolean delete(Integer id) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            Employer employer = session.get(Employer.class, id);
            if (employer != null) {
                session.remove(employer);
                transaction.commit();
                return true;
            }
            return false;
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Recherche universelle d'employés
     * Type peut être : "nom", "matricule", "email", "grade", "poste", "departement"
     */
    public List<Employer> search(String type, String value) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "";
            boolean needsLike = false;
            
            // Construire la requête selon le type de recherche
            switch (type.toLowerCase()) {
                case "nom":
                    // Chercher dans nom OU prénom avec CONCAT pour chercher "prenom nom" aussi
                    hql = "FROM Employer WHERE " +
                          "LOWER(nom) LIKE :value OR " +
                          "LOWER(prenom) LIKE :value OR " +
                          "LOWER(CONCAT(prenom, ' ', nom)) LIKE :value OR " +
                          "LOWER(CONCAT(nom, ' ', prenom)) LIKE :value";
                    needsLike = true;
                    break;
                case "matricule":
                    hql = "FROM Employer WHERE matricule = :value";
                    break;
                case "email":
                    hql = "FROM Employer WHERE email = :value";
                    break;
                case "grade":
                    hql = "FROM Employer WHERE grade = :value";
                    break;
                case "poste":
                    hql = "FROM Employer WHERE poste = :value";
                    break;
                case "departement":
                    // Si c'est un nombre, recherche par ID, sinon par nom
                    try {
                        Integer.parseInt(value);
                        hql = "FROM Employer WHERE idDepartement = :value";
                    } catch (NumberFormatException e) {
                        // Recherche par nom de département (requête SQL native)
                        String sql = "SELECT e.* FROM Employer e " +
                                    "JOIN Departement d ON e.Id_departement = d.Id " +
                                    "WHERE LOWER(d.Intitule) LIKE :value";
                        return session.createNativeQuery(sql, Employer.class)
                                .setParameter("value", "%" + value.toLowerCase() + "%")
                                .list();
                    }
                    break;
                default:
                    return null;
            }
            
            // Exécuter la requête
            Query<Employer> query = session.createQuery(hql, Employer.class);
            
            // Pour les recherches avec LIKE, ajouter les %
            if (needsLike) {
                query.setParameter("value", "%" + value.toLowerCase() + "%");
            } else if (type.equalsIgnoreCase("departement")) {
                // Pour département par ID
                query.setParameter("value", Integer.parseInt(value));
            } else {
                query.setParameter("value", value);
            }
            
            return query.list();
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer un employé par email (pour le login)
     */
    public Employer getByEmail(String email) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Employer WHERE email = :email";
            Query<Employer> query = session.createQuery(hql, Employer.class);
            query.setParameter("email", email);
            return query.uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les employés par département
     */
    public List<Employer> getByDepartement(Integer idDepartement) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Employer WHERE idDepartement = :idDept";
            Query<Employer> query = session.createQuery(hql, Employer.class);
            query.setParameter("idDept", idDepartement);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer tous les grades distincts (pour les filtres)
     */
    public List<String> getAllGrades() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT DISTINCT e.grade FROM Employer e ORDER BY e.grade";
            Query<String> query = session.createQuery(hql, String.class);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer tous les postes distincts (pour les filtres)
     */
    public List<String> getAllPostes() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT DISTINCT e.poste FROM Employer e ORDER BY e.poste";
            Query<String> query = session.createQuery(hql, String.class);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}