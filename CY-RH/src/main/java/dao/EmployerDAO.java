package dao;

import models.Employer;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateUtil;
import java.util.List;

/**
 * DAO pour gérer les opérations CRUD sur les employés
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
     * Rechercher des employés par nom ou prénom
     */
    public List<Employer> searchByName(String searchTerm) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Employer WHERE LOWER(nom) LIKE :term OR LOWER(prenom) LIKE :term";
            Query<Employer> query = session.createQuery(hql, Employer.class);
            query.setParameter("term", "%" + searchTerm.toLowerCase() + "%");
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Rechercher un employé par matricule
     */
    public Employer getByMatricule(String matricule) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Employer WHERE matricule = :matricule";
            Query<Employer> query = session.createQuery(hql, Employer.class);
            query.setParameter("matricule", matricule);
            return query.uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les employés par grade
     */
    public List<Employer> getByGrade(String grade) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Employer WHERE grade = :grade";
            Query<Employer> query = session.createQuery(hql, Employer.class);
            query.setParameter("grade", grade);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les employés par poste
     */
    public List<Employer> getByPoste(String poste) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Employer WHERE poste = :poste";
            Query<Employer> query = session.createQuery(hql, Employer.class);
            query.setParameter("poste", poste);
            return query.list();
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
     * Récupérer les employés par nom de département
     */
    public List<Employer> getByDepartementName(String nomDepartement) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Employer e WHERE e.idDepartement IN " +
                        "(SELECT d.id FROM Departement d WHERE LOWER(d.intitule) LIKE :nom)";
            Query<Employer> query = session.createQuery(hql, Employer.class);
            query.setParameter("nom", "%" + nomDepartement.toLowerCase() + "%");
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}