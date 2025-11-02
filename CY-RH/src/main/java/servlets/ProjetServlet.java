package servlets;

import dao.ProjetDAO;
import dao.EmployerDAO;
import dao.DepartementDAO;
import dao.AffectationProjetDAO;
import models.Projet;
import models.Employer;
import models.Departement;
import models.AffectationProjet;
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
     */
    private void listProjets(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Projet> projets = projetDAO.getAll();
        request.setAttribute("projets", projets);
        request.getRequestDispatcher("/WEB-INF/views/projets/list.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de création
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Employer> employees = employerDAO.getAll();
        List<Departement> departements = departementDAO.getAll();
        
        request.setAttribute("employees", employees);
        request.setAttribute("departements", departements);
        request.getRequestDispatcher("/WEB-INF/views/projets/form.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de modification
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(id);
        List<Employer> employees = employerDAO.getAll();
        List<Departement> departements = departementDAO.getAll();
        
        request.setAttribute("projet", projet);
        request.setAttribute("employees", employees);
        request.setAttribute("departements", departements);
        request.getRequestDispatcher("/WEB-INF/views/projets/form.jsp").forward(request, response);
    }
    
    /**
     * Créer un nouveau projet
     */
    private void createProjet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String nomProjet = request.getParameter("nomProjet");
        
        if (nomProjet == null || nomProjet.trim().isEmpty()) {
            request.setAttribute("error", "Le nom du projet est obligatoire");
            showNewForm(request, response);
            return;
        }
        
        try {
            Projet projet = new Projet();
            projet.setNomProjet(nomProjet.trim());
            projet.setEtatProjet(request.getParameter("etatProjet"));
            
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
                projet.setChefProjet(Integer.parseInt(chefStr));
            }
            
            // Département
            String deptStr = request.getParameter("idDepartement");
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                projet.setIdDepartement(Integer.parseInt(deptStr));
            }
            
            boolean success = projetDAO.create(projet);
            
            if (success) {
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
            
            // Mise à jour
            projet.setNomProjet(request.getParameter("nomProjet"));
            projet.setEtatProjet(request.getParameter("etatProjet"));
            
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
                projet.setChefProjet(Integer.parseInt(chefStr));
            }
            
            String deptStr = request.getParameter("idDepartement");
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                projet.setIdDepartement(Integer.parseInt(deptStr));
            }
            
            boolean success = projetDAO.update(projet);
            
            if (success) {
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
     */
    private void deleteProjet(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        projetDAO.delete(id);
        response.sendRedirect(request.getContextPath() + "/projets");
    }
    
    /**
     * Afficher l'équipe du projet
     */
    private void showEquipe(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int projetId = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(projetId);
        
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
        
        request.setAttribute("projet", projet);
        request.setAttribute("affectations", affectations);
        request.setAttribute("employesMap", employesMap);
        request.setAttribute("chef", chef);
        request.getRequestDispatcher("/WEB-INF/views/projets/equipe.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire d'affectation
     */
    private void showAffectationForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int projetId = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(projetId);
        List<Employer> tousEmployes = employerDAO.getAll();
        
        // Filtrer les employés déjà affectés
        List<Employer> employesDisponibles = new ArrayList<>();
        if (tousEmployes != null) {
            for (Employer emp : tousEmployes) {
                if (!affectationDAO.isEmployerAffected(emp.getId(), projetId)) {
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
     */
    private void affecterEmploye(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        try {
            int projetId = Integer.parseInt(request.getParameter("projetId"));
            int employeId = Integer.parseInt(request.getParameter("employeId"));
            
            AffectationProjet affectation = new AffectationProjet();
            affectation.setIdProjet(projetId);
            affectation.setIdEmployer(employeId);
            affectation.setDateAffectation(new Date());
            
            affectationDAO.create(affectation);
            response.sendRedirect(request.getContextPath() + "/projets/equipe?id=" + projetId);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/projets");
        }
    }
    
    /**
     * Retirer un employé du projet
     */
    private void retirerEmploye(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        int affectationId = Integer.parseInt(request.getParameter("affectationId"));
        int projetId = Integer.parseInt(request.getParameter("projetId"));
        
        affectationDAO.delete(affectationId);
        response.sendRedirect(request.getContextPath() + "/projets/equipe?id=" + projetId);
    }
}