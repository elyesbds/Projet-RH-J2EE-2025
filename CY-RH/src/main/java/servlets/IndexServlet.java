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

/**
 * Servlet pour la page d'accueil
 * Récupère les infos du département de l'utilisateur
 */
@WebServlet({"/", "/index.jsp"})
public class IndexServlet extends HttpServlet {

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

        request.setAttribute("departement", departement);
        request.getRequestDispatcher("/WEB-INF/views/index.jsp").forward(request, response);
    }
}