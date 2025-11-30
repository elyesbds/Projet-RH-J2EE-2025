package servlets;

import dao.EmployerDAO;
import models.Employer;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import utils.ValidationUtil;
import java.util.ArrayList;
import java.util.List;
import utils.PasswordUtil;

/**
 * Servlet pour permettre à un employé de modifier ses propres informations
 * Un employé peut modifier : email, téléphone, mot de passe
 * Un employé NE PEUT PAS modifier : salaire, grade, poste, département, rôle
 */
@WebServlet("/editer-mon-compte")
public class EditerMonCompteServlet extends HttpServlet {

    private EmployerDAO employerDAO;

    @Override
    public void init() {
        employerDAO = new EmployerDAO();
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

        // Récupérer les infos à jour
        user = employerDAO.getById(user.getId());

        request.setAttribute("user", user);
        request.getRequestDispatcher("/WEB-INF/views/editer-mon-compte.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Récupérer l'utilisateur connecté
        Employer currentUser = PermissionUtil.getLoggedUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Récupérer l'employé depuis la base
            Employer employer = employerDAO.getById(currentUser.getId());

            if (employer == null) {
                request.setAttribute("error", "Utilisateur non trouvé");
                response.sendRedirect(request.getContextPath() + "/mon-compte");
                return;
            }

            // L'employé peut modifier UNIQUEMENT ces champs :
            String email = request.getParameter("email");
            String telephone = request.getParameter("telephone");
            String password = request.getParameter("password");

            // Liste pour stocker les erreurs de validation
            List<String> erreurs = new ArrayList<>();

            // Validation de l'email
            if (ValidationUtil.estVide(email)) {
                erreurs.add("L'email est obligatoire");
            } else if (!ValidationUtil.estEmailValide(email)) {
                erreurs.add("L'email n'est pas valide");
            } else if (!ValidationUtil.estLongueurValide(email, 100)) {
                erreurs.add("L'email ne doit pas dépasser 100 caractères");
            }

            // Validation du téléphone
            if (!ValidationUtil.estVide(telephone)) {
                if (!ValidationUtil.estTelephoneValide(telephone)) {
                    erreurs.add("Le téléphone doit contenir 10 chiffres et commencer par 0");
                }
            }

            // Validation du mot de passe (optionnel)
            if (!ValidationUtil.estVide(password)) {
                if (password.length() < 4) {
                    erreurs.add("Le mot de passe doit contenir au moins 4 caractères");
                }
            }

            // Si des erreurs existent, retourner au formulaire
            if (!erreurs.isEmpty()) {
                request.setAttribute("erreurs", erreurs);
                request.setAttribute("user", employer);
                request.getRequestDispatcher("/WEB-INF/views/editer-mon-compte.jsp").forward(request, response);
                return;
            }

            // Validation simple (ton code original)
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "L'email est obligatoire");
                request.setAttribute("user", employer);
                request.getRequestDispatcher("/WEB-INF/views/editer-mon-compte.jsp").forward(request, response);
                return;
            }

            // Mise à jour UNIQUEMENT des champs autorisés
            employer.setEmail(ValidationUtil.nettoyerTexte(email.trim()));
            employer.setTelephone(telephone != null ? ValidationUtil.nettoyerTexte(telephone.trim()) : null);

            // Mot de passe : seulement si rempli
            if (password != null && !password.trim().isEmpty()) {
                employer.setPassword(PasswordUtil.hashPassword(password));
            }

            // Important : On ne touche pas à :
            // - salaire, grade, poste, département, rôle, matricule, date d'embauche

            boolean success = employerDAO.update(employer);

            if (success) {
                // Mettre à jour la session
                HttpSession session = request.getSession();
                session.setAttribute("user", employer);
                session.setAttribute("successMessage", "Vos informations ont été mises à jour avec succès !");

                // Rediriger vers mon compte
                response.sendRedirect(request.getContextPath() + "/mon-compte");
            } else {
                request.setAttribute("error", "Erreur lors de la mise à jour");
                request.setAttribute("user", employer);
                request.getRequestDispatcher("/WEB-INF/views/editer-mon-compte.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("error", "Erreur : " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/mon-compte");
        }
    }
}
