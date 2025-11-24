package dao;

import models.AffectationProjet;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateUtil;
import java.util.List;

/**
 * DAO pour gérer les affectations employés-projets
 */
public class AffectationProjetDAO {
    
    /**
     * Créer une nouvelle affectation
     */
    public boolean create(AffectationProjet affectation) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.persist(affectation);
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
     * Récupérer les projets d'un employé
     */
    public List<AffectationProjet> getProjetsByEmployer(Integer idEmployer) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM AffectationProjet WHERE idEmployer = :idEmp AND dateFinAffectation IS NULL";
            Query<AffectationProjet> query = session.createQuery(hql, AffectationProjet.class);
            query.setParameter("idEmp", idEmployer);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les employés d'un projet
     */
    public List<AffectationProjet> getEmployersByProjet(Integer idProjet) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM AffectationProjet WHERE idProjet = :idProj AND dateFinAffectation IS NULL";
            Query<AffectationProjet> query = session.createQuery(hql, AffectationProjet.class);
            query.setParameter("idProj", idProjet);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Terminer une affectation (mettre une date de fin)
     */
    public boolean terminerAffectation(Integer id, java.util.Date dateFin) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            AffectationProjet affectation = session.get(AffectationProjet.class, id);
            if (affectation != null) {
                affectation.setDateFinAffectation(dateFin);
                session.merge(affectation);
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
     * Vérifier si un employé est déjà affecté à un projet
     */
    public boolean isEmployerAffected(Integer idEmployer, Integer idProjet) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM AffectationProjet WHERE idEmployer = :idEmp AND idProjet = :idProj AND dateFinAffectation IS NULL";
            Query<AffectationProjet> query = session.createQuery(hql, AffectationProjet.class);
            query.setParameter("idEmp", idEmployer);
            query.setParameter("idProj", idProjet);
            return !query.list().isEmpty();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Supprimer une affectation
     */
    public boolean delete(Integer id) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            AffectationProjet affectation = session.get(AffectationProjet.class, id);
            if (affectation != null) {
                session.remove(affectation);
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
}