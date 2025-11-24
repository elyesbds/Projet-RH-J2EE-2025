package servlets;

import dao.EmployerDAO;
import dao.DepartementDAO;
import dao.FicheDePaieDAO; // AJOUT : DAO pour les fiches de paie
import models.Employer;
import models.Departement;
import models.FicheDePaie; // AJOUT : Modèle FicheDePaie
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List; // AJOUT : Pour la liste des fiches

/**
 * Servlet pour afficher la page "Mon Compte"
 * Affiche les informations personnelles de l'employé connecté
 * ET ses fiches de paie 
 */
@WebServlet("/mon-compte")
public class MonCompteServlet extends HttpServlet {
    
    private EmployerDAO employerDAO;
    private DepartementDAO departementDAO;
    private FicheDePaieDAO ficheDAO; 
    
    @Override
    public void init() {
        employerDAO = new EmployerDAO();
        departementDAO = new DepartementDAO();
        ficheDAO = new FicheDePaieDAO(); 
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Récupérer l'utilisateur connecté
        Employer user = PermissionUtil.getLoggedUser(request);
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Récupérer les infos à jour depuis la base
        user = employerDAO.getById(user.getId());
        
        // Récupérer le département si l'employé en a un
        Departement departement = null;
        if (user.getIdDepartement() != null) {
            departement = departementDAO.getById(user.getIdDepartement());
        }
        
        // Récupérer les fiches de paie de l'employé 
        List<FicheDePaie> fichesDePaie = ficheDAO.getByEmployer(user.getId());
      
        
        request.setAttribute("user", user);
        request.setAttribute("departement", departement);
        request.setAttribute("fichesDePaie", fichesDePaie); // AJOUT : Passer les fiches à la JSP
        request.getRequestDispatcher("/WEB-INF/views/mon-compte.jsp").forward(request, response);
    }
}