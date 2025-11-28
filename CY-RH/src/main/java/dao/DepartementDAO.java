package dao;

import models.Departement;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateUtil;
import java.util.List;

/**
 * DAO pour gérer les opérations CRUD sur les départements
 */
public class DepartementDAO {
    
    /**
     * Créer un nouveau département
     */
    public boolean create(Departement departement) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.persist(departement);
            transaction.commit();
            return true;
        } catch (org.hibernate.exception.ConstraintViolationException e) {
            // Erreur de doublon (intitulé déjà existant)
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
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
     * Récupérer un département par son ID
     */
    public Departement getById(Integer id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Departement.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer tous les départements
     */
    public List<Departement> getAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Departement", Departement.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Mettre à jour un département
     */
    public boolean update(Departement departement) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.merge(departement);
            transaction.commit();
            return true;
        } catch (org.hibernate.exception.ConstraintViolationException e) {
            // Erreur de doublon (intitulé déjà existant)
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
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
     * Supprimer un département
     */
    public boolean delete(Integer id) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            Departement departement = session.get(Departement.class, id);
            if (departement != null) {
                session.remove(departement);
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
     * Récupérer un département par son intitulé
     */
    public Departement getByIntitule(String intitule) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Departement WHERE LOWER(intitule) = LOWER(:intitule)";
            Query<Departement> query = session.createQuery(hql, Departement.class);
            query.setParameter("intitule", intitule);
            return query.uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les employés sans département
     */
    public List<Integer> getEmployesSansDepartement() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT e.id FROM Employer e WHERE e.idDepartement IS NULL";
            return session.createQuery(hql, Integer.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Vérifier si un employé est déjà chef d'un autre département
     */
    public Departement getDepartementByChef(Integer idChef) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Departement WHERE chefDepartement.id = :idChef";
            Query<Departement> query = session.createQuery(hql, Departement.class);
            query.setParameter("idChef", idChef);
            return query.uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    
}