package dao;

import models.FicheDePaie;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;
import utils.HibernateUtil;
import java.util.List;

/**
 * DAO pour gérer les opérations sur les fiches de paie
 */
public class FicheDePaieDAO {
    
    /**
     * Créer une nouvelle fiche de paie
     * Important : on vérifie qu'il n'existe pas déjà une fiche pour cet employé ce mois-ci
     */
    public boolean create(FicheDePaie ficheDePaie) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            
            // Vérifier qu'il n'existe pas déjà une fiche pour cet employé ce mois-ci
            if (ficheExistePourMois(ficheDePaie.getIdEmployer(), 
                                    ficheDePaie.getMois(), 
                                    ficheDePaie.getAnnee())) {
                System.out.println("Une fiche de paie existe déjà pour cet employé ce mois-ci !");
                return false;
            }
            
            session.persist(ficheDePaie);
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
     * Récupérer une fiche de paie par son ID
     */
    public FicheDePaie getById(Integer id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.get(FicheDePaie.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer toutes les fiches de paie
     * (Utilisé par l'admin)
     */
    public List<FicheDePaie> getAll() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM FicheDePaie ORDER BY annee DESC, mois DESC";
            return session.createQuery(hql, FicheDePaie.class).list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Mettre à jour une fiche de paie
     */
    public boolean update(FicheDePaie ficheDePaie) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.merge(ficheDePaie);
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
     * Supprimer une fiche de paie par son ID
     */
    public boolean delete(Integer id) {
        Transaction transaction = null;
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            FicheDePaie fiche = session.get(FicheDePaie.class, id);
            if (fiche != null) {
                session.remove(fiche);
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
     * Récupérer toutes les fiches de paie d'un employé
     * (Pour qu'un employé voie ses propres fiches dans "Mon Compte")
     */
    public List<FicheDePaie> getByEmployer(Integer idEmployer) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM FicheDePaie WHERE idEmployer = :idEmp ORDER BY annee DESC, mois DESC";
            Query<FicheDePaie> query = session.createQuery(hql, FicheDePaie.class);
            query.setParameter("idEmp", idEmployer);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les fiches de paie par période (année)
     * (Pour rechercher toutes les fiches d'une année)
     */
    public List<FicheDePaie> getByAnnee(Integer annee) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM FicheDePaie WHERE annee = :annee ORDER BY mois DESC";
            Query<FicheDePaie> query = session.createQuery(hql, FicheDePaie.class);
            query.setParameter("annee", annee);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les fiches de paie par période (mois + année)
     * (Pour rechercher toutes les fiches d'un mois précis)
     */
    public List<FicheDePaie> getByPeriode(Integer mois, Integer annee) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM FicheDePaie WHERE mois = :mois AND annee = :annee";
            Query<FicheDePaie> query = session.createQuery(hql, FicheDePaie.class);
            query.setParameter("mois", mois);
            query.setParameter("annee", annee);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer une fiche de paie spécifique d'un employé pour un mois donné
     * (Utile pour vérifier si une fiche existe déjà)
     */
    public FicheDePaie getByEmployerAndPeriode(Integer idEmployer, Integer mois, Integer annee) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "FROM FicheDePaie WHERE idEmployer = :idEmp AND mois = :mois AND annee = :annee";
            Query<FicheDePaie> query = session.createQuery(hql, FicheDePaie.class);
            query.setParameter("idEmp", idEmployer);
            query.setParameter("mois", mois);
            query.setParameter("annee", annee);
            return query.uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Vérifier si une fiche de paie existe déjà pour un employé pour un mois donné
     * (Pour éviter les doublons - une seule fiche par employé par mois)
     */
    public boolean ficheExistePourMois(Integer idEmployer, Integer mois, Integer annee) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT COUNT(*) FROM FicheDePaie WHERE idEmployer = :idEmp AND mois = :mois AND annee = :annee";
            Query<Long> query = session.createQuery(hql, Long.class);
            query.setParameter("idEmp", idEmployer);
            query.setParameter("mois", mois);
            query.setParameter("annee", annee);
            Long count = query.uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Récupérer les fiches de paie des employés d'un département
     * (Pour que le chef de département voie les fiches de ses employés)
     */
    public List<FicheDePaie> getByDepartement(Integer idDepartement) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // Requête SQL native pour joindre avec la table Employer
            String sql = "SELECT f.* FROM Fiche_de_paie f " +
                        "JOIN Employer e ON f.Id_employer = e.Id " +
                        "WHERE e.Id_departement = :idDept " +
                        "ORDER BY f.Annee DESC, f.Mois DESC";
            
            return session.createNativeQuery(sql, FicheDePaie.class)
                    .setParameter("idDept", idDepartement)
                    .list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les années distinctes des fiches de paie
     * (Pour créer des filtres dynamiques)
     */
    public List<Integer> getAllAnnees() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT DISTINCT f.annee FROM FicheDePaie f ORDER BY f.annee DESC";
            Query<Integer> query = session.createQuery(hql, Integer.class);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les années distinctes pour un employé spécifique
     * (Pour filtres dynamiques : afficher uniquement les années où l'employé a des fiches)
     */
    public List<Integer> getAnneesByEmployer(Integer idEmployer) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT DISTINCT f.annee FROM FicheDePaie f WHERE f.idEmployer = :idEmp ORDER BY f.annee DESC";
            Query<Integer> query = session.createQuery(hql, Integer.class);
            query.setParameter("idEmp", idEmployer);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les mois distincts pour une année donnée
     * (Pour filtres dynamiques : afficher uniquement les mois où il y a des fiches)
     */
    public List<Integer> getMoisByAnnee(Integer annee) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT DISTINCT f.mois FROM FicheDePaie f WHERE f.annee = :annee ORDER BY f.mois DESC";
            Query<Integer> query = session.createQuery(hql, Integer.class);
            query.setParameter("annee", annee);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les mois distincts pour un employé et une année
     * (Pour filtres dynamiques : afficher uniquement les mois où l'employé a des fiches)
     */
    public List<Integer> getMoisByEmployerAndAnnee(Integer idEmployer, Integer annee) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            String hql = "SELECT DISTINCT f.mois FROM FicheDePaie f WHERE f.idEmployer = :idEmp AND f.annee = :annee ORDER BY f.mois DESC";
            Query<Integer> query = session.createQuery(hql, Integer.class);
            query.setParameter("idEmp", idEmployer);
            query.setParameter("annee", annee);
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Recherche multicritères avec filtres optionnels
     * Permet de combiner : employé + année + mois (tous optionnels)
     */
    public List<FicheDePaie> searchFiches(Integer idEmployer, Integer annee, Integer mois) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            // Construire la requête dynamiquement selon les critères fournis
            StringBuilder hql = new StringBuilder("FROM FicheDePaie WHERE 1=1");
            
            if (idEmployer != null) {
                hql.append(" AND idEmployer = :idEmp");
            }
            if (annee != null) {
                hql.append(" AND annee = :annee");
            }
            if (mois != null) {
                hql.append(" AND mois = :mois");
            }
            
            hql.append(" ORDER BY annee DESC, mois DESC");
            
            Query<FicheDePaie> query = session.createQuery(hql.toString(), FicheDePaie.class);
            
            // Définir les paramètres si fournis
            if (idEmployer != null) {
                query.setParameter("idEmp", idEmployer);
            }
            if (annee != null) {
                query.setParameter("annee", annee);
            }
            if (mois != null) {
                query.setParameter("mois", mois);
            }
            
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Récupérer les fiches de paie des employés d'un département avec filtres
     * (Pour chef de département avec recherche par année/mois/employé)
     */
    public List<FicheDePaie> searchFichesByDepartement(Integer idDepartement, Integer idEmployer, Integer annee, Integer mois) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            StringBuilder sql = new StringBuilder(
                "SELECT f.* FROM Fiche_de_paie f " +
                "JOIN Employer e ON f.Id_employer = e.Id " +
                "WHERE e.Id_departement = :idDept"
            );
            
            if (idEmployer != null) {
                sql.append(" AND f.Id_employer = :idEmp");
            }
            if (annee != null) {
                sql.append(" AND f.Annee = :annee");
            }
            if (mois != null) {
                sql.append(" AND f.Mois = :mois");
            }
            
            sql.append(" ORDER BY f.Annee DESC, f.Mois DESC");
            
            var query = session.createNativeQuery(sql.toString(), FicheDePaie.class)
                    .setParameter("idDept", idDepartement);
            
            if (idEmployer != null) {
                query.setParameter("idEmp", idEmployer);
            }
            if (annee != null) {
                query.setParameter("annee", annee);
            }
            if (mois != null) {
                query.setParameter("mois", mois);
            }
            
            return query.list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}