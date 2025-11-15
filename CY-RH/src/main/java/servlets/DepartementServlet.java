package servlets;

import dao.DepartementDAO;
import dao.EmployerDAO;
import dao.ProjetDAO;
import dao.AffectationProjetDAO;
import models.Departement;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * Servlet pour gérer les opérations sur les départements
 */
@WebServlet("/departements/*")
public class DepartementServlet extends HttpServlet {
    
    private DepartementDAO departementDAO;
    private EmployerDAO employerDAO;
    private ProjetDAO projetDAO;
    private AffectationProjetDAO affectationDAO;
    
    @Override
    public void init() {
        departementDAO = new DepartementDAO();
        employerDAO = new EmployerDAO();
        projetDAO = new ProjetDAO();
        affectationDAO = new AffectationProjetDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action == null || action.equals("/")) {
            // Liste tous les départements
            listDepartements(request, response);
        } else if (action.equals("/new")) {
            // Afficher le formulaire de création
            showNewForm(request, response);
        } else if (action.equals("/edit")) {
            // Afficher le formulaire de modification
            showEditForm(request, response);
        } else if (action.equals("/delete")) {
            // Supprimer un département
            deleteDepartement(request, response);
        } else if (action.equals("/members")) {
            // Afficher les membres d'un département
            showMembers(request, response);
        } else if (action.equals("/ajouterMembre")) {
            // Afficher le formulaire pour ajouter un membre
            showAjouterMembreForm(request, response);
        } else if (action.equals("/retirerMembre")) {
            // Retirer un employé du département
            retirerMembre(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action != null && action.equals("/update")) {
            // Mettre à jour un département existant
            updateDepartement(request, response);
        } else if (action != null && action.equals("/affecter")) {
            // Affecter un employé au département
            affecterMembre(request, response);
        } else {
            // Créer un nouveau département
            createDepartement(request, response);
        }
    }
    
    /**
     * Lister tous les départements
     * Admin et Chef dept : voient la liste complète
     * Employé : redirigé automatiquement vers son département
     */
    private void listDepartements(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        // Si l'utilisateur est un employé simple
        if (currentUser != null && "EMPLOYE".equals(currentUser.getRole())) {
            // S'il a un département, le rediriger vers la page membres de son département
            if (currentUser.getIdDepartement() != null) {
                response.sendRedirect(request.getContextPath() + "/departements/members?id=" + currentUser.getIdDepartement());
            } else {
                // S'il n'a pas de département, afficher un message
                request.setAttribute("error", "Vous n'êtes rattaché à aucun département actuellement.");
                request.getRequestDispatcher("/WEB-INF/views/departements/no-department.jsp").forward(request, response);
            }
            return;
        }
        
        // Si l'utilisateur est chef de projet (pas chef dept ni admin)
        if (currentUser != null && "CHEF_PROJET".equals(currentUser.getRole())) {
            // Le rediriger aussi vers son département
            if (currentUser.getIdDepartement() != null) {
                response.sendRedirect(request.getContextPath() + "/departements/members?id=" + currentUser.getIdDepartement());
            } else {
                request.setAttribute("error", "Vous n'êtes rattaché à aucun département actuellement.");
                request.getRequestDispatcher("/WEB-INF/views/departements/no-department.jsp").forward(request, response);
            }
            return;
        }
        
        // Seul l'admin et les chefs de département peuvent voir la liste complète
        if (!PermissionUtil.isAdmin(request) && !PermissionUtil.isChefDept(request)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        
        List<Departement> departements = departementDAO.getAll();
        request.setAttribute("departements", departements);
        request.getRequestDispatcher("/WEB-INF/views/departements/list.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de création
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Seul l'admin peut créer des départements
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/departements");
            return;
        }
        
        // Récupérer la liste des employés pour choisir un chef
        List<Employer> employees = employerDAO.getAll();
        request.setAttribute("employees", employees);
        request.getRequestDispatcher("/WEB-INF/views/departements/form.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de modification
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Departement departement = departementDAO.getById(id);
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        // Vérifier les permissions : Admin OU Chef du département concerné
        boolean isChefOfThisDept = currentUser != null && 
                                   departement.getChefDepartement() != null &&
                                   currentUser.getId().equals(departement.getChefDepartement().getId());
        
        if (!PermissionUtil.isAdmin(request) && !isChefOfThisDept) {
            response.sendRedirect(request.getContextPath() + "/departements");
            return;
        }
        
        List<Employer> employees = employerDAO.getAll();
        
        request.setAttribute("departement", departement);
        request.setAttribute("employees", employees);
        request.setAttribute("isChefDept", isChefOfThisDept);
        request.getRequestDispatcher("/WEB-INF/views/departements/form.jsp").forward(request, response);
    }
    
    /**
     * Créer un nouveau département
     */
    private void createDepartement(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Seul l'admin peut créer
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/departements");
            return;
        }
        
        String intitule = request.getParameter("intitule");
        
        // Validation
        if (intitule == null || intitule.trim().isEmpty()) {
            request.setAttribute("error", "L'intitulé du département est obligatoire");
            showNewForm(request, response);
            return;
        }
        
        try {
            Departement departement = new Departement();
            departement.setIntitule(intitule.trim());
            
            // Chef de département (optionnel)
            String chefStr = request.getParameter("chefDepartement");
            if (chefStr != null && !chefStr.trim().isEmpty()) {
                // CORRECTION: Récupérer l'objet Employer complet
                Employer chef = employerDAO.getById(Integer.parseInt(chefStr));
                departement.setChefDepartement(chef);
                
                // Changer le rôle du chef si ce n'est pas un admin
                if (chef != null && !"ADMIN".equals(chef.getRole())) {
                    chef.setRole("CHEF_DEPT");
                    employerDAO.update(chef);
                }
            }
            
            boolean success = departementDAO.create(departement);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/departements");
            } else {
                request.setAttribute("error", "Erreur lors de la création du département");
                showNewForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Erreur de format dans les données");
            showNewForm(request, response);
        }
    }
    
    /**
     * Mettre à jour un département
     */
    private void updateDepartement(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Departement departement = departementDAO.getById(id);
            Employer currentUser = PermissionUtil.getLoggedUser(request);
            
            if (departement == null) {
                request.setAttribute("error", "Département non trouvé");
                response.sendRedirect(request.getContextPath() + "/departements");
                return;
            }
            
            // Vérifier les permissions : Admin OU Chef du département concerné
            boolean isChefOfThisDept = currentUser != null && 
                                       departement.getChefDepartement() != null &&
                                       currentUser.getId().equals(departement.getChefDepartement().getId());
            
            if (!PermissionUtil.isAdmin(request) && !isChefOfThisDept) {
                response.sendRedirect(request.getContextPath() + "/departements");
                return;
            }
            
            // Mise à jour des champs
            String intitule = request.getParameter("intitule");
            if (intitule != null && !intitule.trim().isEmpty()) {
                departement.setIntitule(intitule.trim());
            }
            
            // Seul l'admin peut changer le chef de département
            if (PermissionUtil.isAdmin(request)) {
                String chefStr = request.getParameter("chefDepartement");
                if (chefStr != null && !chefStr.trim().isEmpty()) {
                    Employer chef = employerDAO.getById(Integer.parseInt(chefStr));
                    departement.setChefDepartement(chef);
                } else {
                    departement.setChefDepartement(null);
                }
            }
            
            boolean success = departementDAO.update(departement);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/departements");
            } else {
                request.setAttribute("error", "Erreur lors de la mise à jour");
                showEditForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Erreur de format dans les données");
            showEditForm(request, response);
        }
    }
    
    /**
     * Supprimer un département
     */
    private void deleteDepartement(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // Seul l'admin peut supprimer
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/departements");
            return;
        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        departementDAO.delete(id);
        response.sendRedirect(request.getContextPath() + "/departements");
    }
    
    /**
     * Afficher les membres d'un département
     * Admin et Chef dept : peuvent voir tous les départements
     * Chef projet et Employé : peuvent voir uniquement LEUR département
     */
    private void showMembers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        
        // Vérifier les permissions
        boolean canView = PermissionUtil.isAdmin(request) || 
                         PermissionUtil.isChefDept(request) ||
                         (currentUser != null && currentUser.getIdDepartement() != null && 
                          currentUser.getIdDepartement().equals(id));
        
        if (!canView) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        
        Departement departement = departementDAO.getById(id);
        List<Employer> membres = employerDAO.getByDepartement(id);
        
        // Récupérer le chef du département (déjà chargé par Hibernate)
        Employer chef = departement.getChefDepartement();
        
        // Récupérer les projets du département
        List<Projet> projets = projetDAO.getByDepartement(id);
        
        // Pour chaque projet, récupérer le nombre de membres
        Map<Integer, Integer> projetsMembreCount = new HashMap<>();
        if (projets != null) {
            for (Projet projet : projets) {
                List<AffectationProjet> affectations = affectationDAO.getEmployersByProjet(projet.getId());
                projetsMembreCount.put(projet.getId(), affectations != null ? affectations.size() : 0);
            }
        }
        
        // Indiquer si l'utilisateur peut modifier : Admin OU Chef de CE département spécifique
        boolean isChefOfThisDept = currentUser != null && 
                                   departement.getChefDepartement() != null &&
                                   currentUser.getId().equals(departement.getChefDepartement().getId());
        boolean canModify = PermissionUtil.isAdmin(request) || isChefOfThisDept;
        
        request.setAttribute("departement", departement);
        request.setAttribute("membres", membres);
        request.setAttribute("chef", chef);
        request.setAttribute("projets", projets);
        request.setAttribute("projetsMembreCount", projetsMembreCount);
        request.setAttribute("canModify", canModify);
        request.getRequestDispatcher("/WEB-INF/views/departements/members.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire pour ajouter un membre
     */
    private void showAjouterMembreForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int deptId = Integer.parseInt(request.getParameter("id"));
        Departement departement = departementDAO.getById(deptId);
        
        // Vérifier les permissions
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        boolean isChefOfThisDept = currentUser != null && 
                                   departement.getChefDepartement() != null &&
                                   currentUser.getId().equals(departement.getChefDepartement().getId());
        
        if (!PermissionUtil.isAdmin(request) && !isChefOfThisDept) {
            response.sendRedirect(request.getContextPath() + "/departements");
            return;
        }
        
        // Récupérer les employés sans département
        List<Employer> tousEmployes = employerDAO.getAll();
        List<Employer> employesDisponibles = new ArrayList<>();
        
        if (tousEmployes != null) {
            for (Employer emp : tousEmployes) {
                if (emp.getIdDepartement() == null) {
                    employesDisponibles.add(emp);
                }
            }
        }
        
        request.setAttribute("departement", departement);
        request.setAttribute("employes", employesDisponibles);
        request.getRequestDispatcher("/WEB-INF/views/departements/ajouter-membre-form.jsp").forward(request, response);
    }
    
    /**
     * Affecter un employé au département
     */
    private void affecterMembre(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        try {
            int deptId = Integer.parseInt(request.getParameter("deptId"));
            int employeId = Integer.parseInt(request.getParameter("employeId"));
            
            // Vérifier les permissions
            Employer currentUser = PermissionUtil.getLoggedUser(request);
            Departement departement = departementDAO.getById(deptId);
            
            boolean isChefOfThisDept = currentUser != null && 
                                       departement.getChefDepartement() != null &&
                                       currentUser.getId().equals(departement.getChefDepartement().getId());
            
            if (!PermissionUtil.isAdmin(request) && !isChefOfThisDept) {
                response.sendRedirect(request.getContextPath() + "/departements");
                return;
            }
            
            Employer employe = employerDAO.getById(employeId);
            employe.setIdDepartement(deptId);
            employerDAO.update(employe);
            
            response.sendRedirect(request.getContextPath() + "/departements/members?id=" + deptId);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/departements");
        }
    }
    
    /**
     * Retirer un employé du département
     */
    private void retirerMembre(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        int employeId = Integer.parseInt(request.getParameter("employeId"));
        int deptId = Integer.parseInt(request.getParameter("deptId"));
        
        // Vérifier les permissions
        Employer currentUser = PermissionUtil.getLoggedUser(request);
        Departement departement = departementDAO.getById(deptId);
        
        boolean isChefOfThisDept = currentUser != null && 
                                   departement.getChefDepartement() != null &&
                                   currentUser.getId().equals(departement.getChefDepartement().getId());
        
        if (!PermissionUtil.isAdmin(request) && !isChefOfThisDept) {
            response.sendRedirect(request.getContextPath() + "/departements");
            return;
        }
        
        Employer employe = employerDAO.getById(employeId);
        
        // Vérifier si cet employé est le chef du département
        boolean isChef = departement.getChefDepartement() != null && 
                         departement.getChefDepartement().getId().equals(employeId);
        
        if (isChef) {
            // Si c'est le chef, retirer le lien chef dans le département
            departement.setChefDepartement(null);
            departementDAO.update(departement);
            
            // Changer son rôle de CHEF_DEPT à EMPLOYE (seulement si son rôle était CHEF_DEPT)
            if ("CHEF_DEPT".equals(employe.getRole())) {
                employe.setRole("EMPLOYE");
            }
        }
        
        // Retirer l'employé du département
        employe.setIdDepartement(null);
        employerDAO.update(employe);
        
        response.sendRedirect(request.getContextPath() + "/departements/members?id=" + deptId);
    }
}