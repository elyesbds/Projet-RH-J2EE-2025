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
import utils.PasswordUtil;
import utils.ValidationUtil;
import java.util.ArrayList;
import dao.ProjetDAO;
import models.Projet;

/**
 * Servlet pour gérer toutes les opérations sur les employés
 */
@WebServlet("/employees/*")
public class EmployerServlet extends HttpServlet {

    private EmployerDAO employerDAO;
    private DepartementDAO departementDAO;
    private ProjetDAO projetDAO;

    @Override
    public void init() {
        employerDAO = new EmployerDAO();
        departementDAO = new DepartementDAO();
        projetDAO = new ProjetDAO();
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

        // Récupérer les paramètres de tri
        String sortBy = request.getParameter("sortBy");
        String order = request.getParameter("order");

        // Récupérer les employés (triés ou non)
        List<Employer> employees;
        if (sortBy != null && !sortBy.trim().isEmpty()) {
            employees = employerDAO.getAllSorted(sortBy, order);
        } else {
            employees = employerDAO.getAll();
        }

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
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("order", order);
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

        // Charger la liste des départements
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

        // Charger la liste des départements
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
        String matricule = request.getParameter("matricule");
        String nom = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String email = request.getParameter("email");
        String telephone = request.getParameter("telephone");
        String password = request.getParameter("password");
        String poste = request.getParameter("poste");
        String grade = request.getParameter("grade");
        String salaireStr = request.getParameter("salaireBase");
        String dateStr = request.getParameter("dateEmbauche");
        String deptStr = request.getParameter("idDepartement");
        String role = request.getParameter("role");

        // Liste pour stocker les erreurs de validation
        List<String> erreurs = new ArrayList<>();

        // Validation du matricule
        if (!ValidationUtil.estMatriculeValide(matricule)) {
            erreurs.add("Le matricule doit être au format EMPxxx (exemple: EMP001)");
        }

        // Validation du nom
        if (ValidationUtil.estVide(nom)) {
            erreurs.add("Le nom est obligatoire");
        } else if (!ValidationUtil.estNomValide(nom)) {
            erreurs.add("Le nom ne doit contenir que des lettres");
        } else if (!ValidationUtil.estLongueurValide(nom, 50)) {
            erreurs.add("Le nom ne doit pas dépasser 50 caractères");
        }

        // Validation du prénom
        if (ValidationUtil.estVide(prenom)) {
            erreurs.add("Le prénom est obligatoire");
        } else if (!ValidationUtil.estNomValide(prenom)) {
            erreurs.add("Le prénom ne doit contenir que des lettres");
        } else if (!ValidationUtil.estLongueurValide(prenom, 50)) {
            erreurs.add("Le prénom ne doit pas dépasser 50 caractères");
        }

        // Validation de l'email
        if (!ValidationUtil.estEmailValide(email)) {
            erreurs.add("L'email n'est pas valide");
        } else if (!ValidationUtil.estLongueurValide(email, 100)) {
            erreurs.add("L'email ne doit pas dépasser 100 caractères");
        }

        // Validation du téléphone
        if (!ValidationUtil.estTelephoneValide(telephone)) {
            erreurs.add("Le téléphone doit contenir 10 chiffres et commencer par 0");
        }

        // Validation du mot de passe
        if (ValidationUtil.estVide(password)) {
            erreurs.add("Le mot de passe est obligatoire");
        } else if (password.length() < 4) {
            erreurs.add("Le mot de passe doit contenir au moins 4 caractères");
        }

        // Validation du poste
        if (ValidationUtil.estVide(poste)) {
            erreurs.add("Le poste est obligatoire");
        } else if (!ValidationUtil.estLongueurValide(poste, 100)) {
            erreurs.add("Le poste ne doit pas dépasser 100 caractères");
        }

        // Validation du grade
        if (ValidationUtil.estVide(grade)) {
            erreurs.add("Le grade est obligatoire");
        }

        // Validation du salaire
        if (!ValidationUtil.estNombrePositif(salaireStr)) {
            erreurs.add("Le salaire doit être un nombre positif");
        }

        // Validation de la date d'embauche
        if (!ValidationUtil.estDateValide(dateStr)) {
            erreurs.add("La date d'embauche n'est pas valide ou est dans le futur");
        }

        // Validation du département (optionnel mais doit être un nombre si fourni)
        if (!ValidationUtil.estVide(deptStr) && !ValidationUtil.estNombrePositif(deptStr)) {
            erreurs.add("Le département sélectionné n'est pas valide");
        }

        // Validation du rôle
        if (ValidationUtil.estVide(role)) {
            role = "EMPLOYE"; // Valeur par défaut
        } else {
            // Vérifier que le rôle est parmi les valeurs autorisées
            if (!role.equals("ADMIN") && !role.equals("CHEF_DEPT") &&
                    !role.equals("CHEF_PROJET") && !role.equals("EMPLOYE")) {
                erreurs.add("Le rôle sélectionné n'est pas valide");
            }
        }

        // Si des erreurs existent, retourner au formulaire
        if (!erreurs.isEmpty()) {
            request.setAttribute("erreurs", erreurs);
            showNewForm(request, response);
            return;
        }

        // Vérification des doublons avant création

        // Vérifier si le matricule existe déjà
        Employer existingByMatricule = employerDAO.getByMatricule(matricule);
        if (existingByMatricule != null) {
            erreurs.add("Ce matricule existe déjà dans la base de données");
        }

        // Vérifier si l'email existe déjà
        Employer existingByEmail = employerDAO.getByEmail(email);
        if (existingByEmail != null) {
            erreurs.add("Cet email est déjà utilisé par un autre employé");
        }

        // Vérifier si le téléphone existe déjà
        if (!ValidationUtil.estVide(telephone)) {
            Employer existingByTelephone = employerDAO.getByTelephone(telephone);
            if (existingByTelephone != null) {
                erreurs.add("Ce numéro de téléphone est déjà utilisé par un autre employé");
            }
        }

        // Vérifier si nom + prénom existe déjà
        Employer existingByNomPrenom = employerDAO.getByNomPrenom(nom, prenom);
        if (existingByNomPrenom != null) {
            erreurs.add("Un employé avec ce nom et ce prénom existe déjà");
        }

        // Si des doublons sont détectés, retourner au formulaire
        if (!erreurs.isEmpty()) {
            request.setAttribute("erreurs", erreurs);
            showNewForm(request, response);
            return;
        }

        // Si tout est valide, créer l'employé
        try {
            Employer employer = new Employer();
            employer.setMatricule(ValidationUtil.nettoyerTexte(matricule));
            employer.setNom(ValidationUtil.nettoyerTexte(nom));
            employer.setPrenom(ValidationUtil.nettoyerTexte(prenom));
            employer.setEmail(ValidationUtil.nettoyerTexte(email));
            employer.setTelephone(ValidationUtil.nettoyerTexte(telephone));
            employer.setPassword(PasswordUtil.hashPassword(password));
            employer.setPoste(ValidationUtil.nettoyerTexte(poste));
            employer.setGrade(ValidationUtil.nettoyerTexte(grade));

            // Conversion du salaire
            if (salaireStr != null && !salaireStr.trim().isEmpty()) {
                employer.setSalaireBase(new BigDecimal(salaireStr));
            }

            // Conversion de la date
            if (dateStr != null && !dateStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                employer.setDateEmbauche(sdf.parse(dateStr));
            }

            // Département
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                employer.setIdDepartement(Integer.parseInt(deptStr));
            }

            // Rôle
            if (role != null && !role.trim().isEmpty()) {
                employer.setRole(role);
            } else {
                employer.setRole("EMPLOYE");
            }

            // Sauvegarder en base
            boolean success = employerDAO.create(employer);

            if (success) {
                request.getSession().setAttribute("successMessage", "Employé créé avec succès !");
                response.sendRedirect(request.getContextPath() + "/employees");
            } else {
                erreurs.add("Erreur lors de la création de l'employé (doublon possible)");
                request.setAttribute("erreurs", erreurs);
                showNewForm(request, response);
            }

        } catch (ParseException | NumberFormatException e) {
            erreurs.add("Erreur de format dans les données : " + e.getMessage());
            request.setAttribute("erreurs", erreurs);
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
            Employer employee = employerDAO.getById(id);

            if (employee == null) {
                request.setAttribute("error", "Employé non trouvé");
                response.sendRedirect(request.getContextPath() + "/employees");
                return;
            }

            // Récupération des paramètres
            String matricule = request.getParameter("matricule");
            String nom = request.getParameter("nom");
            String prenom = request.getParameter("prenom");
            String email = request.getParameter("email");
            String telephone = request.getParameter("telephone");
            String password = request.getParameter("password");
            String poste = request.getParameter("poste");
            String grade = request.getParameter("grade");
            String salaireStr = request.getParameter("salaireBase");
            String dateStr = request.getParameter("dateEmbauche");
            String deptStr = request.getParameter("idDepartement");
            String role = request.getParameter("role");

            // Liste pour stocker les erreurs
            List<String> erreurs = new ArrayList<>();

            // Récupérer les départements pour le formulaire
            List<Departement> departements = departementDAO.getAll();

            // Validation (même logique que createEmployee)
            if (!ValidationUtil.estMatriculeValide(matricule)) {
                erreurs.add("Le matricule doit être au format EMPxxx");
            }

            if (ValidationUtil.estVide(nom) || !ValidationUtil.estNomValide(nom)) {
                erreurs.add("Le nom n'est pas valide (lettres uniquement)");
            } else if (!ValidationUtil.estLongueurValide(nom, 50)) {
                erreurs.add("Le nom ne doit pas dépasser 50 caractères");
            }

            if (ValidationUtil.estVide(prenom) || !ValidationUtil.estNomValide(prenom)) {
                erreurs.add("Le prénom n'est pas valide (lettres uniquement)");
            } else if (!ValidationUtil.estLongueurValide(prenom, 50)) {
                erreurs.add("Le prénom ne doit pas dépasser 50 caractères");
            }

            if (!ValidationUtil.estEmailValide(email)) {
                erreurs.add("L'email n'est pas valide");
            }

            if (!ValidationUtil.estTelephoneValide(telephone)) {
                erreurs.add("Le téléphone doit contenir 10 chiffres");
            }

            // Validation du mot de passe (optionnel en modification)
            if (password != null && !password.trim().isEmpty()) {
                if (password.length() < 4) {
                    erreurs.add("Le mot de passe doit contenir au moins 4 caractères");
                }
            }

            if (ValidationUtil.estVide(poste)) {
                erreurs.add("Le poste est obligatoire");
            }

            if (ValidationUtil.estVide(grade)) {
                erreurs.add("Le grade est obligatoire");
            }

            if (!ValidationUtil.estNombrePositif(salaireStr)) {
                erreurs.add("Le salaire doit être un nombre positif");
            }

            if (!ValidationUtil.estDateValide(dateStr)) {
                erreurs.add("La date d'embauche n'est pas valide");
            }

            // Si erreurs, retourner au formulaire
            if (!erreurs.isEmpty()) {
                request.setAttribute("erreurs", erreurs);
                request.setAttribute("employee", employee);
                request.setAttribute("departements", departements);
                request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
                return;
            }

            // Vérification des doublons avant modification

            // Vérifier si le matricule existe déjà (sauf pour l'employé actuel)
            Employer existingByMatricule = employerDAO.getByMatricule(matricule);
            if (existingByMatricule != null && !existingByMatricule.getId().equals(id)) {
                erreurs.add("Ce matricule est déjà utilisé par un autre employé");
            }

            // Vérifier si l'email existe déjà (sauf pour l'employé actuel)
            Employer existingByEmail = employerDAO.getByEmail(email);
            if (existingByEmail != null && !existingByEmail.getId().equals(id)) {
                erreurs.add("Cet email est déjà utilisé par un autre employé");
            }

            // Vérifier si le téléphone existe déjà (sauf pour l'employé actuel)
            if (!ValidationUtil.estVide(telephone)) {
                Employer existingByTelephone = employerDAO.getByTelephone(telephone);
                if (existingByTelephone != null && !existingByTelephone.getId().equals(id)) {
                    erreurs.add("Ce numéro de téléphone est déjà utilisé par un autre employé");
                }
            }

            // Vérifier si nom + prénom existe déjà (sauf pour l'employé actuel)
            Employer existingByNomPrenom = employerDAO.getByNomPrenom(nom, prenom);
            if (existingByNomPrenom != null && !existingByNomPrenom.getId().equals(id)) {
                erreurs.add("Un employé avec ce nom et ce prénom existe déjà");
            }

            // Si des doublons sont détectés, retourner au formulaire
            if (!erreurs.isEmpty()) {
                request.setAttribute("erreurs", erreurs);
                request.setAttribute("employee", employee);
                request.setAttribute("departements", departements);
                request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
                return;
            }

            // Vérifications de cohérence métier

            // Vérification 1 : Un chef de département ne peut pas changer de département
            if ("CHEF_DEPT".equals(employee.getRole())) {
                Departement departementDirige = departementDAO.getDepartementByChef(id);

                if (departementDirige != null) {
                    // Cas 1 : On essaie de RETIRER le département
                    if (ValidationUtil.estVide(deptStr)) {
                        erreurs.add("Impossible de retirer le département : cet employé est chef du département \""
                                + departementDirige.getIntitule()
                                + "\". Veuillez d'abord retirer son statut de chef de département.");
                        request.setAttribute("erreurs", erreurs);
                        request.setAttribute("employee", employee);
                        request.setAttribute("departements", departements);
                        request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
                        return;
                    }

                    // Cas 2 : On essaie de CHANGER le département
                    Integer nouveauDeptId = Integer.parseInt(deptStr);
                    if (!nouveauDeptId.equals(departementDirige.getId())) {
                        erreurs.add("Impossible de changer le département : cet employé est chef du département \""
                                + departementDirige.getIntitule()
                                + "\". Veuillez d'abord retirer son statut de chef de département.");
                        request.setAttribute("erreurs", erreurs);
                        request.setAttribute("employee", employee);
                        request.setAttribute("departements", departements);
                        request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
                        return;
                    }
                }
            }

            // Vérification 2 : Ne pas permettre de devenir CHEF_DEPT manuellement
            if (role != null && "CHEF_DEPT".equals(role) && !"CHEF_DEPT".equals(employee.getRole())) {
                Departement departementDirige = departementDAO.getDepartementByChef(id);

                if (departementDirige == null) {
                    erreurs.add(
                            "Impossible d'attribuer le rôle Chef de Département : cet employé n'est chef d'aucun département. Veuillez d'abord le nommer chef dans la section Départements.");
                    request.setAttribute("erreurs", erreurs);
                    request.setAttribute("employee", employee);
                    request.setAttribute("departements", departements);
                    request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
                    return;
                }
            }

            // Vérification 3 : Ne pas permettre de devenir CHEF_PROJET manuellement
            if (role != null && "CHEF_PROJET".equals(role) && !"CHEF_PROJET".equals(employee.getRole())) {
                List<Projet> projetsChef = projetDAO.getByChefProjet(id);

                if (projetsChef == null || projetsChef.isEmpty()) {
                    erreurs.add(
                            "Impossible d'attribuer le rôle Chef de Projet : cet employé n'est chef d'aucun projet. Veuillez d'abord le nommer chef dans la section Projets.");
                    request.setAttribute("erreurs", erreurs);
                    request.setAttribute("employee", employee);
                    request.setAttribute("departements", departements);
                    request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
                    return;
                }
            }

            // Vérification 4 : Si on rétrograde un CHEF_DEPT en EMPLOYE, retirer
            // automatiquement de département
            if ("CHEF_DEPT".equals(employee.getRole()) && "EMPLOYE".equals(role)) {
                Departement departementDirige = departementDAO.getDepartementByChef(id);

                if (departementDirige != null) {
                    // Retirer le chef du département
                    departementDirige.setChefDepartement(null);
                    departementDAO.update(departementDirige);
                }
            }

            // Vérification 5 : Si on rétrograde un CHEF_PROJET en EMPLOYE, retirer de tous
            // les projets
            if ("CHEF_PROJET".equals(employee.getRole()) && "EMPLOYE".equals(role)) {
                List<Projet> projetsChef = projetDAO.getByChefProjet(id);

                if (projetsChef != null && !projetsChef.isEmpty()) {
                    // Retirer le chef de tous ses projets
                    for (Projet projet : projetsChef) {
                        projet.setChefProjet(null);
                        projetDAO.update(projet);
                    }
                }
            }

            // Mise à jour des champs
            employee.setMatricule(ValidationUtil.nettoyerTexte(matricule));
            employee.setNom(ValidationUtil.nettoyerTexte(nom));
            employee.setPrenom(ValidationUtil.nettoyerTexte(prenom));
            employee.setEmail(ValidationUtil.nettoyerTexte(email));
            employee.setTelephone(ValidationUtil.nettoyerTexte(telephone));

            // Mise à jour du mot de passe (optionnel)
            if (password != null && !password.trim().isEmpty()) {
                employee.setPassword(PasswordUtil.hashPassword(password));
            }

            employee.setPoste(ValidationUtil.nettoyerTexte(poste));
            employee.setGrade(ValidationUtil.nettoyerTexte(grade));

            // Salaire
            if (salaireStr != null && !salaireStr.trim().isEmpty()) {
                employee.setSalaireBase(new BigDecimal(salaireStr));
            }

            // Date
            if (dateStr != null && !dateStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                employee.setDateEmbauche(sdf.parse(dateStr));
            }

            // Département
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                employee.setIdDepartement(Integer.parseInt(deptStr));
            } else {
                employee.setIdDepartement(null);
            }

            // Rôle
            if (role != null && !role.trim().isEmpty()) {
                employee.setRole(role);
            }

            // Sauvegarder
            boolean success = employerDAO.update(employee);

            if (success) {
                request.getSession().setAttribute("successMessage", "Employé modifié avec succès");
                response.sendRedirect(request.getContextPath() + "/employees");
            } else {
                erreurs.add("Erreur lors de la mise à jour (doublon possible)");
                request.setAttribute("erreurs", erreurs);
                request.setAttribute("employee", employee);
                request.setAttribute("departements", departements);
                request.getRequestDispatcher("/WEB-INF/views/employees/form.jsp").forward(request, response);
            }

        } catch (ParseException | NumberFormatException e) {
            List<String> erreurs = new ArrayList<>();
            erreurs.add("Erreur de format dans les données");
            request.setAttribute("erreurs", erreurs);
            response.sendRedirect(request.getContextPath() + "/employees");
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