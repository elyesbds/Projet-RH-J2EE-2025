package dao;

import models.Projet;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateUtil;
import java.util.List;

/**
 * DAO pour gérer les opérations sur les projets
 */
public class ProjetDAO {
    
    /**
     * Créer un nouveau projet
     */
    public boolean create(Projet projet) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.persist(projet);
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
     * Récupérer un projet par son ID
     */
    public Projet getById(Integer id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Projet.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer tous les projets
     */
    public List<Projet> getAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery("FROM Projet", Projet.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Mettre à jour un projet
     */
    public boolean update(Projet projet) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.merge(projet);
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
     * Supprimer un projet
     */
    public boolean delete(Integer id) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            Projet projet = session.get(Projet.class, id);
            if (projet != null) {
                session.remove(projet);
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
     * Récupérer les projets par état
     */
    public List<Projet> getByEtat(String etat) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Projet WHERE etatProjet = :etat";
            Query<Projet> query = session.createQuery(hql, Projet.class);
            query.setParameter("etat", etat);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les projets par département
     */
    public List<Projet> getByDepartement(Integer idDepartement) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Projet WHERE idDepartement = :idDept";
            Query<Projet> query = session.createQuery(hql, Projet.class);
            query.setParameter("idDept", idDepartement);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les projets où l'employé est chef de projet
     * NOUVELLE MÉTHODE pour les chefs de projet
     */
    public List<Projet> getByChefProjet(Integer chefProjetId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Projet WHERE chefProjet = :chefId";
            Query<Projet> query = session.createQuery(hql, Projet.class);
            query.setParameter("chefId", chefProjetId);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}