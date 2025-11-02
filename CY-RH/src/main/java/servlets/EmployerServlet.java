package servlets;

import dao.EmployerDAO;
import dao.DepartementDAO;
import models.Employer;
import models.Departement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Servlet pour gérer toutes les opérations sur les employés
 */
@WebServlet("/employees/*")
public class EmployerServlet extends HttpServlet {
    
    private EmployerDAO employerDAO;
    private DepartementDAO departementDAO;
    
    @Override
    public void init() {
        employerDAO = new EmployerDAO();
        departementDAO = new DepartementDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action == null || action.equals("/")) {
            // Liste tous les employés
            listEmployees(request, response);
        } else if (action.equals("/new")) {
            // Afficher le formulaire de création
            showNewForm(request, response);
        } else if (action.equals("/edit")) {
            // Afficher le formulaire de modification
            showEditForm(request, response);
        } else if (action.equals("/delete")) {
            // Supprimer un employé
            deleteEmployee(request, response);
        } else if (action.equals("/search")) {
            // Rechercher des employés
            searchEmployees(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action != null && action.equals("/update")) {
            // Mettre à jour un employé existant
            updateEmployee(request, response);
        } else {
            // Créer un nouvel employé
            createEmployee(request, response);
        }
    }
    
    /**
     * Lister tous les employés
     */
    private void listEmployees(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Employer> employees = employerDAO.getAll();
        request.setAttribute("employees", employees);
        request.getRequestDispatcher("/WEB-INF/views/employees/list.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de création
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Récupérer la liste des départements pour le formulaire
        List<Departement> departements = departementDAO.getAll();
        request.setAttribute("departements", departements);
        request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de modification
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Employer employee = employerDAO.getById(id);
        List<Departement> departements = departementDAO.getAll();
        
        request.setAttribute("employee", employee);
        request.setAttribute("departements", departements);
        request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
    }
    
    /**
     * Créer un nouvel employé
     */
    private void createEmployee(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Validation des données
        String nom = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String email = request.getParameter("email");
        
        if (nom == null || nom.trim().isEmpty() || 
            prenom == null || prenom.trim().isEmpty() || 
            email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Les champs nom, prénom et email sont obligatoires");
            showNewForm(request, response);
            return;
        }
        
        try {
            Employer employer = new Employer();
            employer.setMatricule(request.getParameter("matricule"));
            employer.setNom(nom.trim());
            employer.setPrenom(prenom.trim());
            employer.setEmail(email.trim());
            employer.setTelephone(request.getParameter("telephone"));
            employer.setPassword(request.getParameter("password"));
            employer.setPoste(request.getParameter("poste"));
            employer.setGrade(request.getParameter("grade"));
            
            // Conversion du salaire
            String salaireStr = request.getParameter("salaireBase");
            if (salaireStr != null && !salaireStr.trim().isEmpty()) {
                employer.setSalaireBase(new BigDecimal(salaireStr));
            }
            
            // Conversion de la date
            String dateStr = request.getParameter("dateEmbauche");
            if (dateStr != null && !dateStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                employer.setDateEmbauche(sdf.parse(dateStr));
            }
            
            // Département
            String deptStr = request.getParameter("idDepartement");
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                employer.setIdDepartement(Integer.parseInt(deptStr));
            }
            
            employer.setRole(request.getParameter("role"));
            
            // Sauvegarder en base
            boolean success = employerDAO.create(employer);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/employees");
            } else {
                request.setAttribute("error", "Erreur lors de la création de l'employé");
                showNewForm(request, response);
            }
            
        } catch (ParseException | NumberFormatException e) {
            request.setAttribute("error", "Erreur de format dans les données : " + e.getMessage());
            showNewForm(request, response);
        }
    }
    
    /**
     * Mettre à jour un employé
     */
    private void updateEmployee(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Employer employer = employerDAO.getById(id);
            
            if (employer == null) {
                request.setAttribute("error", "Employé non trouvé");
                response.sendRedirect(request.getContextPath() + "/employees");
                return;
            }
            
            // Mise à jour des champs
            employer.setMatricule(request.getParameter("matricule"));
            employer.setNom(request.getParameter("nom"));
            employer.setPrenom(request.getParameter("prenom"));
            employer.setEmail(request.getParameter("email"));
            employer.setTelephone(request.getParameter("telephone"));
            employer.setPoste(request.getParameter("poste"));
            employer.setGrade(request.getParameter("grade"));
            
            String salaireStr = request.getParameter("salaireBase");
            if (salaireStr != null && !salaireStr.trim().isEmpty()) {
                employer.setSalaireBase(new BigDecimal(salaireStr));
            }
            
            String dateStr = request.getParameter("dateEmbauche");
            if (dateStr != null && !dateStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                employer.setDateEmbauche(sdf.parse(dateStr));
            }
            
            String deptStr = request.getParameter("idDepartement");
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                employer.setIdDepartement(Integer.parseInt(deptStr));
            }
            
            employer.setRole(request.getParameter("role"));
            
            // Sauvegarder
            boolean success = employerDAO.update(employer);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/employees");
            } else {
                request.setAttribute("error", "Erreur lors de la mise à jour");
                showEditForm(request, response);
            }
            
        } catch (ParseException | NumberFormatException e) {
            request.setAttribute("error", "Erreur de format dans les données");
            showEditForm(request, response);
        }
    }
    
    /**
     * Supprimer un employé
     */
    private void deleteEmployee(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        employerDAO.delete(id);
        response.sendRedirect(request.getContextPath() + "/employees");
    }
    
    /**
     * Rechercher des employés
     */
    private void searchEmployees(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String searchType = request.getParameter("type");
        String searchValue = request.getParameter("value");
        List<Employer> employees = null;
        
        if (searchType != null && searchValue != null && !searchValue.trim().isEmpty()) {
            switch (searchType) {
                case "name":
                    employees = employerDAO.searchByName(searchValue);
                    break;
                case "matricule":
                    Employer emp = employerDAO.getByMatricule(searchValue);
                    if (emp != null) {
                        employees = List.of(emp);
                    }
                    break;
                case "grade":
                    employees = employerDAO.getByGrade(searchValue);
                    break;
                case "poste":
                    employees = employerDAO.getByPoste(searchValue);
                    break;
                case "departement":
                    try {
                        Integer deptId = Integer.parseInt(searchValue);
                        employees = employerDAO.getByDepartement(deptId);
                    } catch (NumberFormatException e) {
                        // Si ce n'est pas un ID, chercher par nom de département
                        employees = employerDAO.getByDepartementName(searchValue);
                    }
                    break;
            }
        }
        
        request.setAttribute("employees", employees);
        request.setAttribute("searchType", searchType);
        request.setAttribute("searchValue", searchValue);
        request.getRequestDispatcher("/WEB-INF/views/employees/list.jsp").forward(request, response);
    }
}