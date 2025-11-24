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
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Ajouter l'employé à un projet
        ajouterProjet(request, response);
    }
    
    /**
     * Afficher les projets d'un employé
     */
    private void showEmployeeProjets(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int employeeId = Integer.parseInt(request.getParameter("employeeId"));
        Employer employee = employerDAO.getById(employeeId);
        
        // Récupérer les affectations de l'employé
        List<AffectationProjet> affectations = affectationDAO.getProjetsByEmployer(employeeId);
        
        // Récupérer les détails des projets
        Map<Integer, Projet> projetsMap = new HashMap<>();
        if (affectations != null) {
            for (AffectationProjet aff : affectations) {
                Projet projet = projetDAO.getById(aff.getIdProjet());
                if (projet != null) {
                    projetsMap.put(projet.getId(), projet);
                }
            }
        }
        
        request.setAttribute("employee", employee);
        request.setAttribute("affectations", affectations);
        request.setAttribute("projetsMap", projetsMap);
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
        
        // Filtrer les projets où l'employé n'est pas encore affecté
        List<Projet> projetsDisponibles = new ArrayList<>();
        if (tousProjets != null) {
            for (Projet projet : tousProjets) {
                if (!affectationDAO.isEmployerAffected(employeeId, projet.getId())) {
                    projetsDisponibles.add(projet);
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
            
            AffectationProjet affectation = new AffectationProjet();
            affectation.setIdEmployer(employeeId);
            affectation.setIdProjet(projetId);
            affectation.setDateAffectation(new Date());
            
            affectationDAO.create(affectation);
            response.sendRedirect(request.getContextPath() + "/employee-projets?employeeId=" + employeeId);
            
        } catch (Exception e) {
            e.printStackTrace();
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
        
        int affectationId = Integer.parseInt(request.getParameter("affectationId"));
        int employeeId = Integer.parseInt(request.getParameter("employeeId"));
        
        affectationDAO.delete(affectationId);
        response.sendRedirect(request.getContextPath() + "/employee-projets?employeeId=" + employeeId);
    }
}