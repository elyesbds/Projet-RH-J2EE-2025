package servlets;

import dao.EmployerDAO;
import dao.DepartementDAO;
import models.Employer;
import models.Departement;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

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
     * Tout le monde peut voir la liste (mais seul l'admin peut modifier/supprimer)
     */
    private void listEmployees(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Employer> employees = employerDAO.getAll();
        List<String> grades = employerDAO.getAllGrades();
        List<String> postes = employerDAO.getAllPostes();
        
        // Récupérer les départements pour l'affichage
        Map<Integer, String> departementsMap = new HashMap<>();
        List<Departement> departements = departementDAO.getAll();
        if (departements != null) {
            for (Departement dept : departements) {
                departementsMap.put(dept.getId(), dept.getIntitule());
            }
        }
        
        // Indiquer si l'utilisateur peut modifier (pour la JSP)
        boolean canModify = PermissionUtil.isAdmin(request);
        
        request.setAttribute("employees", employees);
        request.setAttribute("grades", grades);
        request.setAttribute("postes", postes);
        request.setAttribute("departementsMap", departementsMap);
        request.setAttribute("departements", departements);
        request.setAttribute("canModify", canModify);
        request.getRequestDispatcher("/WEB-INF/views/employees/list.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de création
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Seul l'admin peut créer des employés
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }
        
        // CORRECTION: Charger la liste des départements
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
        
        // Seul l'admin peut modifier les employés
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }
        
        // CORRECTION: Charger la liste des départements
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
        
        // Seul l'admin peut créer
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }
        
        // Récupération des paramètres
        String nom = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String email = request.getParameter("email");
        
        // Validation basique
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
            
            // Rôle
            String role = request.getParameter("role");
            if (role != null && !role.trim().isEmpty()) {
                employer.setRole(role);
            } else {
                employer.setRole("EMPLOYE"); // Valeur par défaut
            }
            
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
        
        // Seul l'admin peut modifier
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }
        
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
            
            // Salaire
            String salaireStr = request.getParameter("salaireBase");
            if (salaireStr != null && !salaireStr.trim().isEmpty()) {
                employer.setSalaireBase(new BigDecimal(salaireStr));
            }
            
            // Date
            String dateStr = request.getParameter("dateEmbauche");
            if (dateStr != null && !dateStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                employer.setDateEmbauche(sdf.parse(dateStr));
            }
            
            // Département
            String deptStr = request.getParameter("idDepartement");
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                employer.setIdDepartement(Integer.parseInt(deptStr));
            } else {
                employer.setIdDepartement(null);
            }
            
            // Rôle
            String role = request.getParameter("role");
            if (role != null && !role.trim().isEmpty()) {
                employer.setRole(role);
            }
            
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
        
        // Seul l'admin peut supprimer
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        employerDAO.delete(id);
        response.sendRedirect(request.getContextPath() + "/employees");
    }
    
    /**
     * Rechercher des employés
     * Tout le monde peut rechercher
     */
    private void searchEmployees(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String searchType = request.getParameter("type");
        String searchValue = request.getParameter("value");
        List<Employer> employees = null;
        
        // Utilisation de la méthode search() simplifiée
        if (searchType != null && searchValue != null && !searchValue.trim().isEmpty()) {
            employees = employerDAO.search(searchType, searchValue);
        }
        
        // Récupérer les listes pour les filtres
        List<String> grades = employerDAO.getAllGrades();
        List<String> postes = employerDAO.getAllPostes();
        
        // Récupérer les départements pour l'affichage
        Map<Integer, String> departementsMap = new HashMap<>();
        List<Departement> departements = departementDAO.getAll();
        if (departements != null) {
            for (Departement dept : departements) {
                departementsMap.put(dept.getId(), dept.getIntitule());
            }
        }
        
        // Indiquer si l'utilisateur peut modifier
        boolean canModify = PermissionUtil.isAdmin(request);
        
        request.setAttribute("employees", employees);
        request.setAttribute("grades", grades);
        request.setAttribute("postes", postes);
        request.setAttribute("departementsMap", departementsMap);
        request.setAttribute("departements", departements);
        request.setAttribute("canModify", canModify);
        request.setAttribute("searchType", searchType);
        request.setAttribute("searchValue", searchValue);
        request.getRequestDispatcher("/WEB-INF/views/employees/list.jsp").forward(request, response);
    }
}