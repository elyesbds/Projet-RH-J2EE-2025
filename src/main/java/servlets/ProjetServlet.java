package servlets;

import dao.ProjetDAO;
import dao.EmployerDAO;
import dao.DepartementDAO;
import dao.AffectationProjetDAO;
import models.Projet;
import models.Employer;
import models.Departement;
import models.AffectationProjet;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Servlet pour gérer les projets
 */
@WebServlet("/projets/*")
public class ProjetServlet extends HttpServlet {
    
    private ProjetDAO projetDAO;
    private EmployerDAO employerDAO;
    private DepartementDAO departementDAO;
    private AffectationProjetDAO affectationDAO;
    
    @Override
    public void init() {
        projetDAO = new ProjetDAO();
        employerDAO = new EmployerDAO();
        departementDAO = new DepartementDAO();
        affectationDAO = new AffectationProjetDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action == null || action.equals("/")) {
            // Liste tous les projets
            listProjets(request, response);
        } else if (action.equals("/new")) {
            // Afficher le formulaire de création
            showNewForm(request, response);
        } else if (action.equals("/edit")) {
            // Afficher le formulaire de modification
            showEditForm(request, response);
        } else if (action.equals("/delete")) {
            // Supprimer un projet
            deleteProjet(request, response);
        } else if (action.equals("/equipe")) {
            // Afficher l'équipe du projet
            showEquipe(request, response);
        } else if (action.equals("/affecterEmploye")) {
            // Afficher le formulaire pour affecter un employé
            showAffectationForm(request, response);
        } else if (action.equals("/retirerEmploye")) {
            // Retirer un employé du projet
            retirerEmploye(request, response);
        } else if (action.equals("/affectation-rapide")) {
            // Affectation rapide depuis la liste des employés
            showAffectationRapide(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action != null && action.equals("/update")) {
            // Mettre à jour un projet
            updateProjet(request, response);
        } else if (action != null && action.equals("/affecter")) {
            // Affecter un employé au projet
            affecterEmploye(request, response);
        } else {
            // Créer un nouveau projet
            createProjet(request, response);
        }
    }
    
    /**
     * Lister tous les projets
     * - EMPLOYE : voit seulement SES projets (où il est affecté)
     * - CHEF_PROJET : voit UNIQUEMENT SES projets (où il est chef)
     * - CHEF_DEPT et ADMIN : voient TOUS les projets
     */
    private void listProjets(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Projet> projets;
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // EMPLOYÉ SIMPLE : afficher seulement SES projets (où il est affecté)
        if ("EMPLOYE".equals(currentUser.getRole())) {
            Integer userId = currentUser.getId();
            List<AffectationProjet> affectations = affectationDAO.getProjetsByEmployer(userId);
            
            projets = new ArrayList<>();
            if (affectations != null) {
                for (AffectationProjet aff : affectations) {
                    Projet p = projetDAO.getById(aff.getIdProjet());
                    if (p != null) {
                        projets.add(p);
                    }
                }
            }
        } 
     // CHEF DE PROJET : voit SES projets (chef) + projets où il est MEMBRE
        else if ("CHEF_PROJET".equals(currentUser.getRole())) {
            Integer userId = currentUser.getId();
            
            // 1. Projets où il est CHEF
            List<Projet> projetsChef = projetDAO.getByChefProjet(userId);
            projets = new ArrayList<>(projetsChef != null ? projetsChef : new ArrayList<>());
            
            // 2. Projets où il est MEMBRE (affecté)
            List<AffectationProjet> affectations = affectationDAO.getProjetsByEmployer(userId);
            if (affectations != null) {
                for (AffectationProjet aff : affectations) {
                    Projet p = projetDAO.getById(aff.getIdProjet());
                    // Ajouter seulement si pas déjà dans la liste
                    if (p != null && !projets.contains(p)) {
                        projets.add(p);
                    }
                }
            }
        }
     // CHEF DEPT : voit les projets de son département + projets où il est membre
        else if ("CHEF_DEPT".equals(currentUser.getRole())) {
            projets = new ArrayList<>();
            
            // 1. Projets du département
            if (currentUser.getIdDepartement() != null) {
                List<Projet> projetsDept = projetDAO.getByDepartement(currentUser.getIdDepartement());
                if (projetsDept != null) {
                    projets.addAll(projetsDept);
                }
            }
            
            // 2. Projets où il est membre
            List<AffectationProjet> affectations = affectationDAO.getProjetsByEmployer(currentUser.getId());
            if (affectations != null) {
                for (AffectationProjet aff : affectations) {
                    Projet p = projetDAO.getById(aff.getIdProjet());
                    if (p != null && !projets.contains(p)) {
                        projets.add(p);
                    }
                }
            }
        }
        // ADMIN : TOUS les projets
        else {
            projets = projetDAO.getAll();
        }
        
        // Récupérer les noms des chefs de projet
        Map<Integer, String> chefsProjetMap = new HashMap<>();
        if (projets != null) {
            for (Projet projet : projets) {
                if (projet.getChefProjet() != null) {
                    Employer chef = employerDAO.getById(projet.getChefProjet());
                    if (chef != null) {
                        chefsProjetMap.put(projet.getId(), chef.getPrenom() + " " + chef.getNom());
                    }
                }
            }
        }
        
        request.setAttribute("projets", projets);
        request.setAttribute("chefsProjetMap", chefsProjetMap);
        request.getRequestDispatcher("/WEB-INF/views/projets/list.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de création
     * Seul l'admin peut créer des projets
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }
        
        List<Employer> employees = employerDAO.getAll();
        List<Departement> departements = departementDAO.getAll();
        
        request.setAttribute("employees", employees);
        request.setAttribute("departements", departements);
        request.getRequestDispatcher("/WEB-INF/views/projets/form.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de modification
     * Admin OU chef de ce projet peuvent modifier
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(id);
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        // Vérifier permission : Admin OU chef de ce projet
        boolean canModify = PermissionUtil.isAdmin(request) || 
                           (currentUser != null && projet.getChefProjet() != null && 
                            projet.getChefProjet().equals(currentUser.getId()));
        
        if (!canModify) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }
        
        List<Employer> employees = employerDAO.getAll();
        List<Departement> departements = departementDAO.getAll();
        
        // Indiquer si c'est un chef de projet (pour limiter les champs modifiables)
        boolean isChefProjet = currentUser != null && "CHEF_PROJET".equals(currentUser.getRole());
        
        request.setAttribute("projet", projet);
        request.setAttribute("employees", employees);
        request.setAttribute("departements", departements);
        request.setAttribute("isChefProjet", isChefProjet);
        request.getRequestDispatcher("/WEB-INF/views/projets/form.jsp").forward(request, response);
    }
    
    /**
     * Créer un nouveau projet
     * Seul l'admin peut créer
     */
    private void createProjet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }
        
        String nomProjet = request.getParameter("nomProjet");
        
        // Validation
        if (nomProjet == null || nomProjet.trim().isEmpty()) {
            request.setAttribute("error", "Le nom du projet est obligatoire");
            showNewForm(request, response);
            return;
        }
        
        try {
            Projet projet = new Projet();
            projet.setNomProjet(nomProjet.trim());
            
            String etat = request.getParameter("etatProjet");
            if (etat != null && !etat.trim().isEmpty()) {
                projet.setEtatProjet(etat);
            } else {
                projet.setEtatProjet("EN_COURS");
            }
            
            // Dates
            String dateDebutStr = request.getParameter("dateDebut");
            if (dateDebutStr != null && !dateDebutStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                projet.setDateDebut(sdf.parse(dateDebutStr));
            }
            
            String dateFinPrevueStr = request.getParameter("dateFinPrevue");
            if (dateFinPrevueStr != null && !dateFinPrevueStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                projet.setDateFinPrevue(sdf.parse(dateFinPrevueStr));
            }
            
         // Chef de projet
            String chefStr = request.getParameter("chefProjet");
            if (chefStr != null && !chefStr.trim().isEmpty()) {
                int chefId = Integer.parseInt(chefStr);
                projet.setChefProjet(chefId);
                
                // Synchroniser : Changer le role en CHEF_PROJET
                Employer chef = employerDAO.getById(chefId);
                if (chef != null && !"ADMIN".equals(chef.getRole()) && !"CHEF_DEPT".equals(chef.getRole())) {
                    chef.setRole("CHEF_PROJET");
                    employerDAO.update(chef);
                }
            }
            
            // Département
            String deptStr = request.getParameter("idDepartement");
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                projet.setIdDepartement(Integer.parseInt(deptStr));
            }
            
            boolean success = projetDAO.create(projet);
            
            if (success) {
                request.getSession().setAttribute("successMessage", "✅ Projet créé avec succès !");
                response.sendRedirect(request.getContextPath() + "/projets");
            } else {
                request.setAttribute("error", "Erreur lors de la création du projet");
                showNewForm(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Erreur : " + e.getMessage());
            showNewForm(request, response);
        }
    }
    
    /**
     * Mettre à jour un projet
     * Admin : peut tout modifier
     * Chef de projet : peut modifier SEULEMENT certains champs (état, date fin prévue, date fin réelle)
     */
    private void updateProjet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Projet projet = projetDAO.getById(id);
            
            if (projet == null) {
                response.sendRedirect(request.getContextPath() + "/projets");
                return;
            }
            
            Employer currentUser = PermissionUtil.getLoggedUser(request);
            
            // Vérifier permission : Admin OU chef de ce projet
            boolean isAdmin = PermissionUtil.isAdmin(request);
            boolean isChefOfThisProjet = (currentUser != null && projet.getChefProjet() != null && 
                                         projet.getChefProjet().equals(currentUser.getId()));
            
            if (!isAdmin && !isChefOfThisProjet) {
                response.sendRedirect(request.getContextPath() + "/projets");
                return;
            }
            
            // ADMIN : peut tout modifier
            if (isAdmin) {
            	projet.setNomProjet(request.getParameter("nomProjet"));
            	String nouvelEtat = request.getParameter("etatProjet");
            	projet.setEtatProjet(nouvelEtat);

            	// Si le projet est TERMINE ou ANNULE, vérifier le chef
            	if (("TERMINE".equals(nouvelEtat) || "ANNULE".equals(nouvelEtat)) && projet.getChefProjet() != null) {
            	    Integer chefId = projet.getChefProjet();
            	    Employer chef = employerDAO.getById(chefId);
            	    
            	    if (chef != null && "CHEF_PROJET".equals(chef.getRole())) {
            	        // Vérifier s'il a d'autres projets EN_COURS
            	        List<Projet> autresProjets = projetDAO.getByChefProjet(chefId);
            	        boolean aAutreProjetActif = false;
            	        
            	        if (autresProjets != null) {
            	            for (Projet p : autresProjets) {
            	                if (!p.getId().equals(projet.getId()) && "EN_COURS".equals(p.getEtatProjet())) {
            	                    aAutreProjetActif = true;
            	                    break;
            	                }
            	            }
            	        }
            	        
            	        // Si aucun autre projet actif, remettre en EMPLOYE
            	        if (!aAutreProjetActif) {
            	            chef.setRole("EMPLOYE");
            	            employerDAO.update(chef);
            	        }
            	    }
            	}             
                                
                String dateDebutStr = request.getParameter("dateDebut");
                if (dateDebutStr != null && !dateDebutStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateDebut(sdf.parse(dateDebutStr));
                }
                
                String dateFinPrevueStr = request.getParameter("dateFinPrevue");
                if (dateFinPrevueStr != null && !dateFinPrevueStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinPrevue(sdf.parse(dateFinPrevueStr));
                }
                
                String dateFinReelleStr = request.getParameter("dateFinReelle");
                if (dateFinReelleStr != null && !dateFinReelleStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinReelle(sdf.parse(dateFinReelleStr));
                } else {
                    projet.setDateFinReelle(null);
                }
                
                String chefStr = request.getParameter("chefProjet");
                if (chefStr != null && !chefStr.trim().isEmpty()) {
                    int nouveauChefId = Integer.parseInt(chefStr);
                    Integer ancienChefId = projet.getChefProjet();
                    
                    // Si changement de chef
                    if (ancienChefId == null || !ancienChefId.equals(nouveauChefId)) {
                        
                        // Remettre l'ancien chef en EMPLOYE (sauf si ADMIN ou CHEF_DEPT)
                        if (ancienChefId != null) {
                            Employer ancienChef = employerDAO.getById(ancienChefId);
                            if (ancienChef != null && "CHEF_PROJET".equals(ancienChef.getRole())) {
                                // Vérifier s'il est chef d'autres projets
                                List<Projet> autresProjets = projetDAO.getByChefProjet(ancienChefId);
                                if (autresProjets == null || autresProjets.size() <= 1) {
                                    ancienChef.setRole("EMPLOYE");
                                    employerDAO.update(ancienChef);
                                }
                            }
                        }
                        
                        // Promouvoir le nouveau chef
                        Employer nouveauChef = employerDAO.getById(nouveauChefId);
                        if (nouveauChef != null && !"ADMIN".equals(nouveauChef.getRole()) && !"CHEF_DEPT".equals(nouveauChef.getRole())) {
                            nouveauChef.setRole("CHEF_PROJET");
                            employerDAO.update(nouveauChef);
                        }
                    }
                    
                    projet.setChefProjet(nouveauChefId);
                }
                
                String deptStr = request.getParameter("idDepartement");
                if (deptStr != null && !deptStr.trim().isEmpty()) {
                    projet.setIdDepartement(Integer.parseInt(deptStr));
                }
            } 
            // CHEF DE PROJET : peut modifier SEULEMENT état, date fin prévue, date fin réelle
            else if (isChefOfThisProjet) {
                // Modifier l'état du projet
                String etat = request.getParameter("etatProjet");
                if (etat != null && !etat.trim().isEmpty()) {
                    projet.setEtatProjet(etat);
                }
                
                // Modifier la date de fin prévue
                String dateFinPrevueStr = request.getParameter("dateFinPrevue");
                if (dateFinPrevueStr != null && !dateFinPrevueStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinPrevue(sdf.parse(dateFinPrevueStr));
                }
                
                // Modifier la date de fin réelle
                String dateFinReelleStr = request.getParameter("dateFinReelle");
                if (dateFinReelleStr != null && !dateFinReelleStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinReelle(sdf.parse(dateFinReelleStr));
                } else {
                    projet.setDateFinReelle(null);
                }
                
                // NE PAS modifier : nom, date début, chef, département
            }
            
            boolean success = projetDAO.update(projet);
            
            if (success) {
                request.getSession().setAttribute("successMessage", "✅ Projet mis à jour avec succès !");
                response.sendRedirect(request.getContextPath() + "/projets");
            } else {
                request.setAttribute("error", "Erreur lors de la mise à jour");
                showEditForm(request, response);
            }
            
        } catch (Exception e) {
            request.setAttribute("error", "Erreur : " + e.getMessage());
            showEditForm(request, response);
        }
    }
    
    /**
     * Supprimer un projet
     * Seul l'admin peut supprimer
     */
    private void deleteProjet(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(id);
        
        if (projet != null && projet.getChefProjet() != null) {
            Integer chefId = projet.getChefProjet();
            
            // Vérifier si le chef a d'autres projets
            List<Projet> autresProjets = projetDAO.getByChefProjet(chefId);
            
            // Si ce projet est le seul où il est chef, remettre en EMPLOYE
            if (autresProjets != null && autresProjets.size() == 1) {
                Employer chef = employerDAO.getById(chefId);
                if (chef != null && "CHEF_PROJET".equals(chef.getRole())) {
                    chef.setRole("EMPLOYE");
                    employerDAO.update(chef);
                }
            }
        }
        
        // Supprimer le projet
        projetDAO.delete(id);
        request.getSession().setAttribute("successMessage", "Projet supprimé avec succès !");
        response.sendRedirect(request.getContextPath() + "/projets");
    }
    
    /**
     * Afficher l'équipe du projet
     * Tout le monde peut voir, mais seuls Admin et Chef de ce projet peuvent modifier
     */
    private void showEquipe(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int projetId = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(projetId);
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        // Récupérer les affectations
        List<AffectationProjet> affectations = affectationDAO.getEmployersByProjet(projetId);
        
        // Récupérer les détails des employés
        Map<Integer, Employer> employesMap = new HashMap<>();
        if (affectations != null) {
            for (AffectationProjet aff : affectations) {
                Employer emp = employerDAO.getById(aff.getIdEmployer());
                if (emp != null) {
                    employesMap.put(emp.getId(), emp);
                }
            }
        }
        
        // Chef de projet
        Employer chef = null;
        if (projet.getChefProjet() != null) {
            chef = employerDAO.getById(projet.getChefProjet());
        }
        
        // Vérifier si l'utilisateur peut modifier (Admin OU chef de ce projet)
        boolean canModify = PermissionUtil.isAdmin(request) || 
                           (currentUser != null && projet.getChefProjet() != null && 
                            projet.getChefProjet().equals(currentUser.getId()));
        
        request.setAttribute("projet", projet);
        request.setAttribute("affectations", affectations);
        request.setAttribute("employesMap", employesMap);
        request.setAttribute("chef", chef);
        request.setAttribute("canModify", canModify);
        request.getRequestDispatcher("/WEB-INF/views/projets/equipe.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire d'affectation
     * Admin OU chef de ce projet peuvent affecter
     */
    private void showAffectationForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int projetId = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(projetId);
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        // Vérifier permission : Admin OU chef de ce projet
        boolean canAffect = PermissionUtil.isAdmin(request) || 
                           (currentUser != null && projet.getChefProjet() != null && 
                            projet.getChefProjet().equals(currentUser.getId()));
        
        if (!canAffect) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }
        

        
        // Vérifier que le projet est EN_COURS
        if (!"EN_COURS".equals(projet.getEtatProjet())) {
            request.getSession().setAttribute("errorMessage", "❌ Impossible d'affecter un employé à un projet terminé ou annulé.");
            response.sendRedirect(request.getContextPath() + "/projets/equipe?id=" + projetId);
            return;
        }
        
        List<Employer> tousEmployes = employerDAO.getAll();
        
        // Filtrer les employés déjà affectés + le chef de projet (qui ne doit pas être dans affectations)
        List<Employer> employesDisponibles = new ArrayList<>();
        if (tousEmployes != null) {
            for (Employer emp : tousEmployes) {
                // Ne pas afficher : employés déjà affectés OU le chef de projet
                boolean estChef = (projet.getChefProjet() != null && projet.getChefProjet().equals(emp.getId()));
                boolean dejaAffecte = affectationDAO.isEmployerAffected(emp.getId(), projetId);
                
                if (!estChef && !dejaAffecte) {
                    employesDisponibles.add(emp);
                }
            }
        }
        
        request.setAttribute("projet", projet);
        request.setAttribute("employes", employesDisponibles);
        request.getRequestDispatcher("/WEB-INF/views/projets/affectation-form.jsp").forward(request, response);
    }
    
    /**
     * Affecter un employé au projet
     * Admin OU chef de ce projet peuvent affecter
     * NOUVEAU : Gère aussi l'affectation rapide depuis la liste des employés
     */
    private void affecterEmploye(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        try {
            int projetId = Integer.parseInt(request.getParameter("projetId"));
            int employeId = Integer.parseInt(request.getParameter("employeId"));
            
            Projet projet = projetDAO.getById(projetId);
            Employer currentUser = PermissionUtil.getLoggedUser(request);
            
            // Vérifier permission : Admin OU chef de ce projet
            boolean canAffect = PermissionUtil.isAdmin(request) || 
                               (currentUser != null && projet.getChefProjet() != null && 
                                projet.getChefProjet().equals(currentUser.getId()));
            
            if (!canAffect) {
                response.sendRedirect(request.getContextPath() + "/projets");
                return;
            }
            
            // Créer l'affectation
            AffectationProjet affectation = new AffectationProjet();
            affectation.setIdProjet(projetId);
            affectation.setIdEmployer(employeId);
            affectation.setDateAffectation(new Date());
            
            affectationDAO.create(affectation);
            request.getSession().setAttribute("successMessage", "✅ Employé affecté au projet avec succès !");
            
            // Redirection intelligente selon la provenance
            String fromRapide = request.getParameter("fromRapide");
            if ("true".equals(fromRapide)) {
                // Si affectation rapide : retour à la liste des employés
                response.sendRedirect(request.getContextPath() + "/employees");
            } else {
                // Sinon : retour à l'équipe du projet
                response.sendRedirect(request.getContextPath() + "/projets/equipe?id=" + projetId);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/projets");
        }
    }
    
    /**
     * Retirer un employé du projet
     * Admin OU chef de ce projet peuvent retirer
     */
    private void retirerEmploye(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        int affectationId = Integer.parseInt(request.getParameter("affectationId"));
        int projetId = Integer.parseInt(request.getParameter("projetId"));
        
        Projet projet = projetDAO.getById(projetId);
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        // Vérifier permission : Admin OU chef de ce projet
        boolean canRemove = PermissionUtil.isAdmin(request) || 
                           (currentUser != null && projet.getChefProjet() != null && 
                            projet.getChefProjet().equals(currentUser.getId()));
        
        if (!canRemove) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }
        
        affectationDAO.delete(affectationId);
        request.getSession().setAttribute("successMessage", "✅ Employé retiré du projet avec succès !");
        response.sendRedirect(request.getContextPath() + "/projets/equipe?id=" + projetId);
    }
    
    /**
     * Afficher le formulaire d'affectation rapide depuis la liste des employés
     * Pour les chefs de projet : afficher LEURS projets uniquement
     */
    private void showAffectationRapide(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int employeId = Integer.parseInt(request.getParameter("employeId"));
        Employer employe = employerDAO.getById(employeId);
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        // Vérifier que l'utilisateur est chef de projet
        if (currentUser == null || !"CHEF_PROJET".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }
        
        // Récupérer UNIQUEMENT les projets où l'utilisateur est chef
        List<Projet> mesProjets = projetDAO.getByChefProjet(currentUser.getId());
        
        // Filtrer : UNIQUEMENT projets EN_COURS + employé non affecté
        List<Projet> projetsDisponibles = new ArrayList<>();
        if (mesProjets != null) {
            for (Projet projet : mesProjets) {
                // Vérifier : EN_COURS + pas déjà affecté
                if ("EN_COURS".equals(projet.getEtatProjet()) && 
                    !affectationDAO.isEmployerAffected(employeId, projet.getId())) {
                    projetsDisponibles.add(projet);
                }
            }
        }
        
        request.setAttribute("employe", employe);
        request.setAttribute("projets", projetsDisponibles);
        request.getRequestDispatcher("/WEB-INF/views/projets/affectation-rapide.jsp").forward(request, response);
    }
}