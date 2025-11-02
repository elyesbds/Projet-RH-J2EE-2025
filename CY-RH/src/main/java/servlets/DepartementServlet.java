package servlets;

import dao.DepartementDAO;
import dao.EmployerDAO;
import models.Departement;
import models.Employer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet pour gérer les opérations sur les départements
 */
@WebServlet("/departements/*")
public class DepartementServlet extends HttpServlet {
    
    private DepartementDAO departementDAO;
    private EmployerDAO employerDAO;
    
    @Override
    public void init() {
        departementDAO = new DepartementDAO();
        employerDAO = new EmployerDAO();
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
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action != null && action.equals("/update")) {
            // Mettre à jour un département existant
            updateDepartement(request, response);
        } else {
            // Créer un nouveau département
            createDepartement(request, response);
        }
    }
    
    /**
     * Lister tous les départements
     */
    private void listDepartements(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Departement> departements = departementDAO.getAll();
        request.setAttribute("departements", departements);
        request.getRequestDispatcher("/WEB-INF/views/departements/list.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de création
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
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
        List<Employer> employees = employerDAO.getAll();
        
        request.setAttribute("departement", departement);
        request.setAttribute("employees", employees);
        request.getRequestDispatcher("/WEB-INF/views/departements/form.jsp").forward(request, response);
    }
    
    /**
     * Créer un nouveau département
     */
    private void createDepartement(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String intitule = request.getParameter("intitule");
        
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
                departement.setChefDepartement(Integer.parseInt(chefStr));
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
            
            if (departement == null) {
                request.setAttribute("error", "Département non trouvé");
                response.sendRedirect(request.getContextPath() + "/departements");
                return;
            }
            
            // Mise à jour des champs
            String intitule = request.getParameter("intitule");
            if (intitule != null && !intitule.trim().isEmpty()) {
                departement.setIntitule(intitule.trim());
            }
            
            String chefStr = request.getParameter("chefDepartement");
            if (chefStr != null && !chefStr.trim().isEmpty()) {
                departement.setChefDepartement(Integer.parseInt(chefStr));
            } else {
                departement.setChefDepartement(null);
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
        
        int id = Integer.parseInt(request.getParameter("id"));
        departementDAO.delete(id);
        response.sendRedirect(request.getContextPath() + "/departements");
    }
    
    /**
     * Afficher les membres d'un département
     */
    private void showMembers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Departement departement = departementDAO.getById(id);
        List<Employer> membres = employerDAO.getByDepartement(id);
        
        // Récupérer le chef si défini
        Employer chef = null;
        if (departement.getChefDepartement() != null) {
            chef = employerDAO.getById(departement.getChefDepartement());
        }
        
        request.setAttribute("departement", departement);
        request.setAttribute("membres", membres);
        request.setAttribute("chef", chef);
        request.getRequestDispatcher("/WEB-INF/views/departements/members.jsp").forward(request, response);
    }
}