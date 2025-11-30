package servlets;

import dao.EmployerDAO;
import dao.ProjetDAO;
import dao.AffectationProjetDAO;
import models.Employer;
import models.Projet;
import models.AffectationProjet;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.*;

import org.hibernate.Session;
import utils.HibernateUtil;

/**
 * Servlet pour afficher les projets d'un employé
 */
@WebServlet("/employee-projets/*")
public class EmployeeProjetsServlet extends HttpServlet {

    private EmployerDAO employerDAO;
    private ProjetDAO projetDAO;
    private AffectationProjetDAO affectationDAO;

    @Override
    public void init() {
        employerDAO = new EmployerDAO();
        projetDAO = new ProjetDAO();
        affectationDAO = new AffectationProjetDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getPathInfo();

        if (action == null || action.equals("/")) {
            // Afficher les projets de l'employé
            showEmployeeProjets(request, response);
        } else if (action.equals("/ajouter")) {
            // Afficher le formulaire pour ajouter un projet
            showAjouterProjetForm(request, response);
        } else if (action.equals("/retirer")) {
            // Retirer l'employé d'un projet
            retirerProjet(request, response);
        } else if (action.equals("/retirerChef")) {
            retirerChef(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Ajouter l'employé à un projet
        ajouterProjet(request, response);
    }

    /**
     * Afficher les projets d'un employé (MEMBRE + CHEF)
     */
    private void showEmployeeProjets(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int employeeId = Integer.parseInt(request.getParameter("employeeId"));
        Employer employee = employerDAO.getById(employeeId);

        // RÉCUPÉRER LES PROJETS OÙ IL EST MEMBRE
        List<AffectationProjet> affectations = affectationDAO.getProjetsByEmployer(employeeId);

        // Récupérer les détails des projets (membre)
        Map<Integer, Projet> projetsMembreMap = new HashMap<>();
        if (affectations != null) {
            for (AffectationProjet aff : affectations) {
                Projet projet = projetDAO.getById(aff.getIdProjet());
                if (projet != null) {
                    projetsMembreMap.put(projet.getId(), projet);
                }
            }
        }

        // RÉCUPÉRER LES PROJETS OÙ IL EST CHEF
        List<Projet> projetsChef = projetDAO.getByChefProjet(employeeId);

        // FUSIONNER LES DEUX LISTES
        // Créer une map combinée pour éviter les doublons
        Map<Integer, Projet> tousProjetsCombines = new HashMap<>();

        // Ajouter les projets où il est membre
        tousProjetsCombines.putAll(projetsMembreMap);

        // Ajouter les projets où il est chef (sans doublons)
        if (projetsChef != null) {
            for (Projet projet : projetsChef) {
                if (!tousProjetsCombines.containsKey(projet.getId())) {
                    tousProjetsCombines.put(projet.getId(), projet);
                }
            }
        }

        request.setAttribute("employee", employee);
        request.setAttribute("affectations", affectations);
        request.setAttribute("projetsChef", projetsChef);
        request.setAttribute("projetsMap", tousProjetsCombines);
        request.getRequestDispatcher("/WEB-INF/views/employees/projets.jsp").forward(request, response);
    }

    /**
     * Afficher le formulaire pour ajouter un projet
     */
    private void showAjouterProjetForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Seul l'admin peut ajouter un employé à un projet via cette page
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        int employeeId = Integer.parseInt(request.getParameter("employeeId"));
        Employer employee = employerDAO.getById(employeeId);
        List<Projet> tousProjets = projetDAO.getAll();

        // Filtrer les projets disponibles
        List<Projet> projetsDisponibles = new ArrayList<>();
        if (tousProjets != null) {
            for (Projet projet : tousProjets) {
                // FILTRE 1 : Exclure les projets TERMINE et ANNULE
                if ("TERMINE".equals(projet.getEtatProjet()) || "ANNULE".equals(projet.getEtatProjet())) {
                    continue; // Passer au projet suivant
                }

                // FILTRE 2 : Vérifier que l'employé n'est pas déjà affecté
                boolean estChef = (projet.getChefProjet() != null && projet.getChefProjet().equals(employeeId));
                boolean estMembre = affectationDAO.isEmployerAffected(employeeId, projet.getId());

                if (!estChef && !estMembre) {
                    // FILTRE 3 : Cohérence département
                    if (projet.getIdDepartement() != null) {
                        if (employee.getIdDepartement() != null &&
                                employee.getIdDepartement().equals(projet.getIdDepartement())) {
                            projetsDisponibles.add(projet);
                        }
                    } else {
                        projetsDisponibles.add(projet);
                    }
                }
            }
        }

        request.setAttribute("employee", employee);
        request.setAttribute("projets", projetsDisponibles);
        request.getRequestDispatcher("/WEB-INF/views/employees/ajouter-projet-form.jsp").forward(request, response);
    }

    /**
     * Ajouter l'employé à un projet
     */
    private void ajouterProjet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Seul l'admin peut ajouter
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        try {
            int employeeId = Integer.parseInt(request.getParameter("employeeId"));
            int projetId = Integer.parseInt(request.getParameter("projetId"));

            // Vérification : Cohérence département
            Employer employee = employerDAO.getById(employeeId);
            Projet projet = projetDAO.getById(projetId);

            if (employee == null || projet == null) {
                request.getSession().setAttribute("errorMessage", "Employé ou projet introuvable");
                response.sendRedirect(request.getContextPath() + "/employee-projets/ajouter?employeeId=" + employeeId);
                return;
            }

            // Si le projet a un département, l'employé doit être du même département
            if (projet.getIdDepartement() != null) {
                if (employee.getIdDepartement() == null) {
                    request.getSession().setAttribute("errorMessage",
                            "Impossible d'affecter cet employé : il n'appartient à aucun département alors que le projet est rattaché à un département.");
                    response.sendRedirect(
                            request.getContextPath() + "/employee-projets/ajouter?employeeId=" + employeeId);
                    return;
                }

                if (!employee.getIdDepartement().equals(projet.getIdDepartement())) {
                    request.getSession().setAttribute("errorMessage",
                            "Impossible d'affecter cet employé : il appartient à un département différent de celui du projet.");
                    response.sendRedirect(
                            request.getContextPath() + "/employee-projets/ajouter?employeeId=" + employeeId);
                    return;
                }
            }

            // Si tout est OK, créer l'affectation
            AffectationProjet affectation = new AffectationProjet();
            affectation.setIdEmployer(employeeId);
            affectation.setIdProjet(projetId);
            affectation.setDateAffectation(new Date());

            boolean success = affectationDAO.create(affectation);

            if (success) {
                request.getSession().setAttribute("successMessage", "Employé affecté au projet avec succès");
            } else {
                request.getSession().setAttribute("errorMessage", "Erreur lors de l'affectation");
            }

            response.sendRedirect(request.getContextPath() + "/employee-projets?employeeId=" + employeeId);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Erreur : " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/employees");
        }
    }

    /**
     * Retirer l'employé d'un projet
     */
    private void retirerProjet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Seul l'admin peut retirer
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        try {
            int affectationId = Integer.parseInt(request.getParameter("affectationId"));
            int employeeId = Integer.parseInt(request.getParameter("employeeId"));

            // Récupérer l'affectation avant de la supprimer
            Session session = HibernateUtil.getSessionFactory().openSession();
            AffectationProjet affectation = session.get(AffectationProjet.class, affectationId);
            session.close();

            if (affectation != null) {
                int projetId = affectation.getIdProjet();
                Projet projet = projetDAO.getById(projetId);

                // Vérifier si l'employé est le chef de ce projet
                boolean estChefDeCeProjet = (projet != null && projet.getChefProjet() != null &&
                        projet.getChefProjet().equals(employeeId));

                // Supprimer l'affectation
                boolean deleted = affectationDAO.delete(affectationId);

                if (deleted && estChefDeCeProjet) {
                    // Gestion automatique des rôles

                    // 1. Retirer le chef du projet
                    projet.setChefProjet(null);
                    projetDAO.update(projet);

                    // 2. Vérifier si l'employé doit être rétrogradé
                    Employer employee = employerDAO.getById(employeeId);

                    if (employee != null && "CHEF_PROJET".equals(employee.getRole())) {
                        // Vérifier s'il est chef d'autres projets
                        List<Projet> autresProjets = projetDAO.getByChefProjet(employeeId);

                        boolean aAutreProjetActif = false;
                        if (autresProjets != null) {
                            for (Projet p : autresProjets) {
                                // Ne pas compter le projet actuel (déjà mis à jour)
                                if (!p.getId().equals(projetId)) {
                                    aAutreProjetActif = true;
                                    break;
                                }
                            }
                        }

                        // Si aucun autre projet actif, remettre en EMPLOYE
                        if (!aAutreProjetActif) {
                            employee.setRole("EMPLOYE");
                            employerDAO.update(employee);

                            request.getSession().setAttribute("successMessage",
                                    "Employé retiré du projet avec succès. Son rôle a été changé en EMPLOYE.");
                        } else {
                            request.getSession().setAttribute("successMessage",
                                    "Employé retiré du projet avec succès.");
                        }
                    } else {
                        request.getSession().setAttribute("successMessage",
                                "Employé retiré du projet avec succès.");
                    }
                } else if (deleted) {
                    request.getSession().setAttribute("successMessage",
                            "Employé retiré du projet avec succès.");
                } else {
                    request.getSession().setAttribute("errorMessage",
                            "Erreur lors du retrait de l'employé.");
                }
            } else {
                request.getSession().setAttribute("errorMessage",
                        "Affectation introuvable.");
            }

            response.sendRedirect(request.getContextPath() + "/employee-projets?employeeId=" + employeeId);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Erreur : " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/employees");
        }
    }

    /**
     * Retirer un employé de son poste de chef de projet (avec gestion automatique
     * des rôles)
     */
    private void retirerChef(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Seul l'admin peut retirer
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        try {
            int projetId = Integer.parseInt(request.getParameter("projetId"));
            int employeeId = Integer.parseInt(request.getParameter("employeeId"));

            Projet projet = projetDAO.getById(projetId);

            if (projet != null && projet.getChefProjet() != null && projet.getChefProjet().equals(employeeId)) {
                // 1. Retirer le chef du projet
                projet.setChefProjet(null);
                projetDAO.update(projet);

                // 2. Vérifier si l'employé doit être rétrogradé
                Employer employee = employerDAO.getById(employeeId);

                if (employee != null && "CHEF_PROJET".equals(employee.getRole())) {
                    // Vérifier s'il est chef d'autres projets
                    List<Projet> autresProjets = projetDAO.getByChefProjet(employeeId);

                    boolean aAutreProjetActif = false;
                    if (autresProjets != null) {
                        for (Projet p : autresProjets) {
                            if (!p.getId().equals(projetId)) {
                                aAutreProjetActif = true;
                                break;
                            }
                        }
                    }

                    // Si aucun autre projet actif, remettre en EMPLOYE
                    if (!aAutreProjetActif) {
                        employee.setRole("EMPLOYE");
                        employerDAO.update(employee);

                        request.getSession().setAttribute("successMessage",
                                "Employé retiré du poste de chef. Son rôle a été changé en EMPLOYE.");
                    } else {
                        request.getSession().setAttribute("successMessage",
                                "Employé retiré du poste de chef de ce projet.");
                    }
                } else {
                    request.getSession().setAttribute("successMessage",
                            "Employé retiré du poste de chef de ce projet.");
                }
            } else {
                request.getSession().setAttribute("errorMessage",
                        "Cet employé n'est pas le chef de ce projet.");
            }

            response.sendRedirect(request.getContextPath() + "/employee-projets?employeeId=" + employeeId);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Erreur : " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/employees");
        }
    }
}