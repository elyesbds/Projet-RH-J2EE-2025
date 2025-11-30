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
        } catch (org.hibernate.exception.ConstraintViolationException e) {
            // Erreur de doublon (nom de projet déjà existant)
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
     * Récupérer tous les projets triés par un champ
     */
    public List<Projet> getAllSorted(String sortBy, String order) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // Validation des paramètres pour éviter les injections SQL
            String validSortBy = sortBy;
            if (!sortBy.matches("^[a-zA-Z]+$")) {
                validSortBy = "id";
            }
            String validOrder = order != null && order.equalsIgnoreCase("DESC") ? "DESC" : "ASC";
            String hql = "FROM Projet ORDER BY " + validSortBy + " " + validOrder;
            return session.createQuery(hql, Projet.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return getAll(); // Fallback sur la liste non triée
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
        } catch (org.hibernate.exception.ConstraintViolationException e) {
            // Erreur de doublon (nom de projet déjà existant)
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
     * Récupérer un projet par son nom
     */
    public Projet getByNomProjet(String nomProjet) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Projet WHERE LOWER(nomProjet) = LOWER(:nomProjet)";
            Query<Projet> query = session.createQuery(hql, Projet.class);
            query.setParameter("nomProjet", nomProjet);
            return query.uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
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