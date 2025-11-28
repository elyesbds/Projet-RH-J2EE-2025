package servlets;

import dao.EmployerDAO;
import models.Employer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import utils.PasswordUtil;

/**
 * Servlet pour gérer la connexion
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private EmployerDAO employerDAO;

    @Override
    public void init() {
        employerDAO = new EmployerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Si l'utilisateur est déjà connecté, rediriger vers l'accueil
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Afficher la page de login
        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Validation
        if (email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email et mot de passe obligatoires");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        // Vérifier l'utilisateur
        Employer user = employerDAO.getByEmail(email.trim());
        
     // DEBUG - Afficher les infos
        if (user != null) {
            System.out.println("=== DEBUG LOGIN ===");
            System.out.println("User trouvé: " + user.getEmail());
            System.out.println("Password en BDD (hash): " + user.getPassword());
            System.out.println("Password saisi: " + password);
            System.out.println("Hash du password saisi: " + PasswordUtil.hashPassword(password));
            System.out.println("Vérification: " + PasswordUtil.verifyPassword(password, user.getPassword()));
            System.out.println("==================");
        } else {
            System.out.println("=== DEBUG LOGIN ===");
            System.out.println("Aucun user trouvé pour email: " + email);
            System.out.println("==================");
        }

        if (user != null && PasswordUtil.verifyPassword(password, user.getPassword())) {
            // Connexion réussie
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userRole", user.getRole());

            // Redirection vers la page d'accueil
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        } else {
            // Échec de connexion
            request.setAttribute("error", "Email ou mot de passe incorrect");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }
}