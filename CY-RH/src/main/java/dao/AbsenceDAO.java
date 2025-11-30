package dao;

import models.Absence;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateUtil;

import java.util.List;
import java.util.Date;

/**
 * DAO pour gérer les absences des employés
 */
public class AbsenceDAO {

    /**
     * Créer une nouvelle absence
     */
    public boolean create(Absence absence) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.persist(absence);
            transaction.commit();
            return true;
        } catch (org.hibernate.exception.ConstraintViolationException e) {
            // Erreur de contrainte (chevauchement possible)
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
     * Récupérer une absence par son ID
     */
    public Absence getById(Integer id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(Absence.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Récupérer toutes les absences
     * (Pour l'admin)
     */
    public List<Absence> getAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Absence ORDER BY dateDebut DESC";
            return session.createQuery(hql, Absence.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Mettre à jour une absence
     */
    public boolean update(Absence absence) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.merge(absence);
            transaction.commit();
            return true;
        } catch (org.hibernate.exception.ConstraintViolationException e) {
            // Erreur de contrainte (chevauchement possible)
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
     * Supprimer une absence
     */
    public boolean delete(Integer id) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            Absence absence = session.get(Absence.class, id);
            if (absence != null) {
                session.remove(absence);
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
     * Récupérer les absences d'un employé
     * (Pour qu'un employé voie ses propres absences)
     */
    public List<Absence> getByEmployer(Integer idEmployer) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Absence WHERE idEmployer = :idEmp ORDER BY dateDebut DESC";
            Query<Absence> query = session.createQuery(hql, Absence.class);
            query.setParameter("idEmp", idEmployer);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Vérifier si une absence chevauche une autre pour le même employé
     * (Pour éviter les doublons de périodes)
     */
    public boolean checkChevauchement(Integer idEmployer, Date dateDebut, Date dateFin, Integer excludeId) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT COUNT(*) FROM Absence WHERE idEmployer = :idEmp " +
                    "AND id != :excludeId " +
                    "AND ((dateDebut BETWEEN :debut AND :fin) " +
                    "OR (dateFin BETWEEN :debut AND :fin) " +
                    "OR (dateDebut <= :debut AND dateFin >= :fin))";
            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("idEmp", idEmployer);
            query.setParameter("excludeId", excludeId != null ? excludeId : -1);
            query.setParameter("debut", dateDebut);
            query.setParameter("fin", dateFin);
            Long count = query.uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Récupérer les absences par type
     */
    public List<Absence> getByType(String typeAbsence) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Absence WHERE typeAbsence = :type ORDER BY dateDebut DESC";
            Query<Absence> query = session.createQuery(hql, Absence.class);
            query.setParameter("type", typeAbsence);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Récupérer les absences des employés d'un département
     * (Pour le chef de département)
     */
    public List<Absence> getByDepartement(Integer idDepartement) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String sql = "SELECT a.* FROM Absence a " +
                    "JOIN Employer e ON a.Id_employer = e.Id " +
                    "WHERE e.Id_departement = :idDept " +
                    "ORDER BY a.Date_debut DESC";

            return session.createNativeQuery(sql, Absence.class)
                    .setParameter("idDept", idDepartement)
                    .list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Récupérer les absences des employés d'un projet
     * (Pour le chef de projet)
     */
    public List<Absence> getByProjet(Integer idProjet) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String sql = "SELECT a.* FROM Absence a " +
                    "JOIN Affectation_projet ap ON a.Id_employer = ap.Id_employer " +
                    "WHERE ap.Id_projet = :idProj AND ap.Date_fin_affectation IS NULL " +
                    "ORDER BY a.Date_debut DESC";

            return session.createNativeQuery(sql, Absence.class)
                    .setParameter("idProj", idProjet)
                    .list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Récupérer les absences d'un employé pour une période donnée
     * (Utile pour le calcul des fiches de paie)
     */
    public List<Absence> getByEmployerAndPeriode(Integer idEmployer, Date dateDebut, Date dateFin) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM Absence WHERE idEmployer = :idEmp " +
                    "AND ((dateDebut BETWEEN :debut AND :fin) " +
                    "OR (dateFin BETWEEN :debut AND :fin) " +
                    "OR (dateDebut <= :debut AND dateFin >= :fin))";
            Query<Absence> query = session.createQuery(hql, Absence.class);
            query.setParameter("idEmp", idEmployer);
            query.setParameter("debut", dateDebut);
            query.setParameter("fin", dateFin);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Compter le nombre de jours d'absence pour un employé sur une période
     * (Pour calculer les déductions)
     */
    public int countJoursAbsence(Integer idEmployer, Date dateDebut, Date dateFin) {
        List<Absence> absences = getByEmployerAndPeriode(idEmployer, dateDebut, dateFin);
        int totalJours = 0;

        if (absences != null) {
            for (Absence abs : absences) {
                // Calculer le nombre de jours d'absence
                long diff = abs.getDateFin().getTime() - abs.getDateDebut().getTime();
                int jours = (int) (diff / (1000 * 60 * 60 * 24)) + 1; // +1 pour inclure le premier jour
                totalJours += jours;
            }
        }

        return totalJours;
    }
}