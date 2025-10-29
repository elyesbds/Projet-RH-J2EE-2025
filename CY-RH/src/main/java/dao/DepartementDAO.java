package dao;

import models.Departement;
import org.hibernate.Session;
import org.hibernate.Transaction;
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
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
}