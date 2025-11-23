package servlets;

import dao.ProjetDAO;
import dao.DepartementDAO;
import dao.EmployerDAO;
import dao.AffectationProjetDAO;
import models.Projet;
import models.Departement;
import models.Employer;
import models.AffectationProjet;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

/**
 * Servlet pour afficher les statistiques
 * Accessible uniquement par l'ADMIN
 */
@WebServlet("/statistiques")
public class StatistiquesServlet extends HttpServlet {
    
    private ProjetDAO projetDAO;
    private DepartementDAO departementDAO;
    private EmployerDAO employerDAO;
    private AffectationProjetDAO affectationDAO;
    
    @Override
    public void init() {
        projetDAO = new ProjetDAO();
        departementDAO = new DepartementDAO();
        employerDAO = new EmployerDAO();
        affectationDAO = new AffectationProjetDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Vérifier que l'utilisateur est admin
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
        
        // 1. Statistiques des projets par état
        Map<String, Integer> statsProjetsByEtat = getStatsProjetsByEtat();
        
        // 2. Nombre d'employés par département
        Map<String, Integer> statsEmployesByDept = getStatsEmployesByDepartement();
        
        // 3. Nombre d'employés par projet avec leurs grades
        List<Map<String, Object>> statsEmployesByProjet = getStatsEmployesByProjet();
        
        // Envoyer les données à la JSP
        request.setAttribute("statsProjetsByEtat", statsProjetsByEtat);
        request.setAttribute("statsEmployesByDept", statsEmployesByDept);
        request.setAttribute("statsEmployesByProjet", statsEmployesByProjet);
        
        request.getRequestDispatcher("/WEB-INF/views/statistiques/statistiques.jsp").forward(request, response);
    }
    
    /**
     * Calculer le nombre de projets par état (EN_COURS, TERMINE, ANNULE)
     */
    private Map<String, Integer> getStatsProjetsByEtat() {
        Map<String, Integer> stats = new HashMap<>();
        
        // Initialiser les compteurs
        stats.put("EN_COURS", 0);
        stats.put("TERMINE", 0);
        stats.put("ANNULE", 0);
        
        // Récupérer tous les projets
        List<Projet> projets = projetDAO.getAll();
        
        if (projets != null) {
            for (Projet p : projets) {
                String etat = p.getEtatProjet();
                stats.put(etat, stats.getOrDefault(etat, 0) + 1);
            }
        }
        
        return stats;
    }
    
    /**
     * Calculer le nombre d'employés par département
     */
    private Map<String, Integer> getStatsEmployesByDepartement() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        
        // Récupérer tous les départements
        List<Departement> departements = departementDAO.getAll();
        
        if (departements != null) {
            for (Departement dept : departements) {
                // Compter les employés de ce département
                int count = employerDAO.countByDepartement(dept.getId());
                stats.put(dept.getIntitule(), count);
            }
        }
        
        return stats;
    }
    
    /**
     * Calculer le nombre d'employés par projet avec répartition par grade
     */
    private List<Map<String, Object>> getStatsEmployesByProjet() {
        List<Map<String, Object>> statsList = new ArrayList<>();
        
        // Récupérer tous les projets
        List<Projet> projets = projetDAO.getAll();
        
        if (projets != null) {
            for (Projet projet : projets) {
                Map<String, Object> projetStats = new HashMap<>();
                projetStats.put("nomProjet", projet.getNomProjet());
                projetStats.put("etatProjet", projet.getEtatProjet());
                
                // Récupérer les affectations actives du projet
                List<AffectationProjet> affectations = affectationDAO.getEmployersByProjet(projet.getId());
                
                int totalEmployes = 0;
                Map<String, Integer> gradeCount = new HashMap<>();
                
                if (affectations != null) {
                    totalEmployes = affectations.size();
                    
                    // Compter par grade
                    for (AffectationProjet aff : affectations) {
                        Employer emp = employerDAO.getById(aff.getIdEmployer());
                        if (emp != null) {
                            String grade = emp.getGrade();
                            gradeCount.put(grade, gradeCount.getOrDefault(grade, 0) + 1);
                        }
                    }
                }
                
                projetStats.put("totalEmployes", totalEmployes);
                projetStats.put("gradeCount", gradeCount);
                
                statsList.add(projetStats);
            }
        }
        
        return statsList;
    }
}