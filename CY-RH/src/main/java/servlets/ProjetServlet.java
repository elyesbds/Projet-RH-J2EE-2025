package servlets;

import dao.ProjetDAO;
import dao.EmployerDAO;
import dao.DepartementDAO;
import dao.AffectationProjetDAO;
import models.Projet;
import models.Employer;
import models.Departement;
import models.AffectationProjet;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;
import utils.ValidationUtil;
import java.text.ParseException;
import java.util.Set;
import java.util.HashSet;

/**
 * Servlet pour gérer les projets
 */
@WebServlet("/projets/*")
public class ProjetServlet extends HttpServlet {

    private ProjetDAO projetDAO;
    private EmployerDAO employerDAO;
    private DepartementDAO departementDAO;
    private AffectationProjetDAO affectationDAO;

    @Override
    public void init() {
        projetDAO = new ProjetDAO();
        employerDAO = new EmployerDAO();
        departementDAO = new DepartementDAO();
        affectationDAO = new AffectationProjetDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getPathInfo();

        if (action == null || action.equals("/")) {
            // Liste tous les projets
            listProjets(request, response);
        } else if (action.equals("/new")) {
            // Afficher le formulaire de création
            showNewForm(request, response);
        } else if (action.equals("/edit")) {
            // Afficher le formulaire de modification
            showEditForm(request, response);
        } else if (action.equals("/delete")) {
            // Supprimer un projet
            deleteProjet(request, response);
        } else if (action.equals("/equipe")) {
            // Afficher l'équipe du projet
            showEquipe(request, response);
        } else if (action.equals("/affecterEmploye")) {
            // Afficher le formulaire pour affecter un employé
            showAffectationForm(request, response);
        } else if (action.equals("/retirerEmploye")) {
            // Retirer un employé du projet
            retirerEmploye(request, response);
        } else if (action.equals("/affectation-rapide")) {
            // Affectation rapide depuis la liste des employés
            showAffectationRapide(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getPathInfo();

        if (action != null && action.equals("/update")) {
            // Mettre à jour un projet
            updateProjet(request, response);
        } else if (action != null && action.equals("/affecter")) {
            // Affecter un employé au projet
            affecterEmploye(request, response);
        } else {
            // Créer un nouveau projet
            createProjet(request, response);
        }
    }

    /**
     * Lister tous les projets
     * - EMPLOYE : voit seulement SES projets (où il est affecté)
     * - CHEF_PROJET : voit UNIQUEMENT SES projets (où il est chef)
     * - CHEF_DEPT et ADMIN : voient TOUS les projets
     */
    private void listProjets(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Projet> projets;
        Employer currentUser = PermissionUtil.getLoggedUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Employé simple : afficher seulement ses projets (où il est affecté)
        if ("EMPLOYE".equals(currentUser.getRole())) {
            Integer userId = currentUser.getId();
            List<AffectationProjet> affectations = affectationDAO.getProjetsByEmployer(userId);

            projets = new ArrayList<>();
            if (affectations != null) {
                for (AffectationProjet aff : affectations) {
                    Projet p = projetDAO.getById(aff.getIdProjet());
                    if (p != null) {
                        projets.add(p);
                    }
                }
            }
        }

     // Chef de projet : voit ses projets (chef) + projets où il est membre
        else if ("CHEF_PROJET".equals(currentUser.getRole())) {
            Integer userId = currentUser.getId();

            // Set pour stocker les IDs déjà ajoutés (évite les doublons)
            Set<Integer> projetsIds = new HashSet<>();
            projets = new ArrayList<>();

            // 1. Projets où il est chef
            List<Projet> projetsChef = projetDAO.getByChefProjet(userId);
            if (projetsChef != null) {
                for (Projet p : projetsChef) {
                    if (p != null && !projetsIds.contains(p.getId())) {
                        projets.add(p);
                        projetsIds.add(p.getId());
                    }
                }
            }

            // 2. Projets où il est membre (affecté)
            List<AffectationProjet> affectations = affectationDAO.getProjetsByEmployer(userId);
            if (affectations != null) {
                for (AffectationProjet aff : affectations) {
                    Projet p = projetDAO.getById(aff.getIdProjet());
                    // Ajouter seulement si l'ID n'est pas déjà dans le Set
                    if (p != null && !projetsIds.contains(p.getId())) {
                        projets.add(p);
                        projetsIds.add(p.getId());
                    }
                }
            }
        }
        
     // Chef de département : voit les projets de son département + projets où il est membre
        else if ("CHEF_DEPT".equals(currentUser.getRole())) {
            // Set pour stocker les IDs déjà ajoutés (évite les doublons)
            Set<Integer> projetsIds = new HashSet<>();
            projets = new ArrayList<>();

            // 1. Projets du département
            if (currentUser.getIdDepartement() != null) {
                List<Projet> projetsDept = projetDAO.getByDepartement(currentUser.getIdDepartement());
                if (projetsDept != null) {
                    for (Projet p : projetsDept) {
                        if (p != null && !projetsIds.contains(p.getId())) {
                            projets.add(p);
                            projetsIds.add(p.getId());
                        }
                    }
                }
            }

            // 2. Projets où il est membre
            List<AffectationProjet> affectations = affectationDAO.getProjetsByEmployer(currentUser.getId());
            if (affectations != null) {
                for (AffectationProjet aff : affectations) {
                    Projet p = projetDAO.getById(aff.getIdProjet());
                    if (p != null && !projetsIds.contains(p.getId())) {
                        projets.add(p);
                        projetsIds.add(p.getId());
                    }
                }
            }
        }
        
        // Admin : voit TOUS les projets
        else {
            projets = projetDAO.getAll();
        }

        // Récupérer les noms des chefs de projet
        Map<Integer, String> chefsProjetMap = new HashMap<>();

        // Récupérer les noms des départements
        Map<Integer, String> departementsMap = new HashMap<>();

        if (projets != null) {
            for (Projet projet : projets) {
                // Chef de projet
                if (projet.getChefProjet() != null) {
                    Employer chef = employerDAO.getById(projet.getChefProjet());
                    if (chef != null) {
                        chefsProjetMap.put(projet.getId(), chef.getPrenom() + " " + chef.getNom());
                    }
                }

                // Département
                if (projet.getIdDepartement() != null) {
                    Departement dept = departementDAO.getById(projet.getIdDepartement());
                    if (dept != null) {
                        departementsMap.put(projet.getId(), dept.getIntitule());
                    }
                }
            }
        }

        // TRI UNIVERSEL POUR TOUS LES RÔLES
        String sortBy = request.getParameter("sortBy");
        String order = request.getParameter("order");
        if (sortBy != null && !sortBy.trim().isEmpty() && projets != null && !projets.isEmpty()) {
            final String finalSortBy = sortBy.trim();
            final String finalOrder = (order != null && order.trim().equalsIgnoreCase("DESC")) ? "DESC" : "ASC";

            Collections.sort(projets, new Comparator<Projet>() {
                @Override
                public int compare(Projet p1, Projet p2) {
                    int result = 0;

                    switch (finalSortBy) {
                        case "nomProjet":
                            result = p1.getNomProjet().compareToIgnoreCase(p2.getNomProjet());
                            break;

                        case "chefProjet":
                            Integer chef1 = p1.getChefProjet();
                            Integer chef2 = p2.getChefProjet();
                            if (chef1 == null && chef2 == null)
                                result = 0;
                            else if (chef1 == null)
                                result = -1;
                            else if (chef2 == null)
                                result = 1;
                            else
                                result = chef1.compareTo(chef2);
                            break;

                        case "idDepartement":
                            Integer dept1 = p1.getIdDepartement();
                            Integer dept2 = p2.getIdDepartement();
                            if (dept1 == null && dept2 == null)
                                result = 0;
                            else if (dept1 == null)
                                result = -1;
                            else if (dept2 == null)
                                result = 1;
                            else
                                result = dept1.compareTo(dept2);
                            break;

                        case "dateDebut":
                            if (p1.getDateDebut() == null && p2.getDateDebut() == null)
                                result = 0;
                            else if (p1.getDateDebut() == null)
                                result = -1;
                            else if (p2.getDateDebut() == null)
                                result = 1;
                            else
                                result = p1.getDateDebut().compareTo(p2.getDateDebut());
                            break;

                        case "dateFinPrevue":
                            if (p1.getDateFinPrevue() == null && p2.getDateFinPrevue() == null)
                                result = 0;
                            else if (p1.getDateFinPrevue() == null)
                                result = -1;
                            else if (p2.getDateFinPrevue() == null)
                                result = 1;
                            else
                                result = p1.getDateFinPrevue().compareTo(p2.getDateFinPrevue());
                            break;

                        case "etatProjet":
                            result = p1.getEtatProjet().compareTo(p2.getEtatProjet());
                            break;

                        default:
                            result = 0;
                    }

                    return "DESC".equals(finalOrder) ? -result : result;
                }
            });
        }

        request.setAttribute("sortBy", sortBy);
        request.setAttribute("order", order);
        request.setAttribute("projets", projets);
        request.setAttribute("chefsProjetMap", chefsProjetMap);
        request.setAttribute("departementsMap", departementsMap);

        // Indiquer si l'utilisateur peut créer des projets (Admin OU Chef de département)
        boolean canCreateProjet = PermissionUtil.isAdmin(request) || PermissionUtil.isChefDept(request);
        request.setAttribute("canCreateProjet", canCreateProjet);

        request.getRequestDispatcher("/WEB-INF/views/projets/list.jsp").forward(request, response);
    }

    /**
     * Afficher le formulaire de création
     * Admin et Chef de département peuvent créer des projets
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Admin et Chef de département peuvent créer des projets
        if (!PermissionUtil.isAdmin(request) && !PermissionUtil.isChefDept(request)) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }

        Employer currentUser = PermissionUtil.getLoggedUser(request);

        // Récupérer la liste des employés pour choisir un chef de projet
        List<Employer> employees = employerDAO.getAll();
        request.setAttribute("employees", employees);

        // Récupérer la liste des départements
        List<Departement> departements = departementDAO.getAll();

        // Si c'est un chef de département, filtrer pour ne montrer QUE son département
        if (PermissionUtil.isChefDept(request) && currentUser != null) {
            Integer deptId = currentUser.getIdDepartement();
            if (deptId != null) {
                Departement userDept = departementDAO.getById(deptId);
                departements = new ArrayList<>();
                if (userDept != null) {
                    departements.add(userDept);
                }
                // Pré-sélectionner le département du chef
                request.setAttribute("preselectedDeptId", deptId);
            }
        }

        request.setAttribute("departements", departements);
        request.setAttribute("isChefDept", PermissionUtil.isChefDept(request));
        request.getRequestDispatcher("/WEB-INF/views/projets/form.jsp").forward(request, response);
    }

    /**
     * Afficher le formulaire de modification
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(id);
        Employer currentUser = PermissionUtil.getLoggedUser(request);

        if (projet == null) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }

        // Vérifier les permissions
        boolean canEdit = false;
        boolean isChefProjet = false;
        boolean isChefDept = false;

        // Admin : peut tout modifier
        if (PermissionUtil.isAdmin(request)) {
            canEdit = true;
        }
        // Chef de projet : peut modifier ses projets
        else if (currentUser != null && projet.getChefProjet() != null &&
                currentUser.getId().equals(projet.getChefProjet())) {
            canEdit = true;
            isChefProjet = true;
        }
        // Chef de département : peut modifier les projets de son département
        else if (PermissionUtil.isChefDept(request) && currentUser != null) {
            Integer userDeptId = currentUser.getIdDepartement();
            Integer projetDeptId = projet.getIdDepartement();

            if (userDeptId != null && userDeptId.equals(projetDeptId)) {
                canEdit = true;
                isChefDept = true;
            }
        }

        // Si pas de permission, rediriger
        if (!canEdit) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }

        // Récupérer les listes pour le formulaire
        List<Employer> employees = employerDAO.getAll();
        List<Departement> departements = departementDAO.getAll();

        request.setAttribute("projet", projet);
        request.setAttribute("employees", employees);
        request.setAttribute("departements", departements);
        request.setAttribute("isChefProjet", isChefProjet);
        request.setAttribute("isChefDept", isChefDept);
        request.getRequestDispatcher("/WEB-INF/views/projets/form.jsp").forward(request, response);
    }

    /**
     * Créer un nouveau projet
     * Seul l'admin peut créer
     * /**
     * Créer un nouveau projet
     */
    private void createProjet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Admin et Chef de département peuvent créer des projets
        if (!PermissionUtil.isAdmin(request) && !PermissionUtil.isChefDept(request)) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }

        Employer currentUser = PermissionUtil.getLoggedUser(request);

        String nomProjet = request.getParameter("nomProjet");
        String etat = request.getParameter("etatProjet");
        String dateDebutStr = request.getParameter("dateDebut");
        String dateFinPrevueStr = request.getParameter("dateFinPrevue");
        String chefStr = request.getParameter("chefProjet");
        String deptStr = request.getParameter("idDepartement");

        // Liste pour stocker les erreurs de validation
        List<String> erreurs = new ArrayList<>();

        // VALIDATION NOM PROJET
        if (ValidationUtil.estVide(nomProjet)) {
            erreurs.add("Le nom du projet est obligatoire");
        } else if (!ValidationUtil.estLongueurValide(nomProjet, 150)) {
            erreurs.add("Le nom du projet ne doit pas dépasser 150 caractères");
        }

        // VALIDATION ETAT PROJET
        if (!ValidationUtil.estVide(etat)) {
            if (!ValidationUtil.estEtatProjetValide(etat)) {
                erreurs.add("L'état du projet n'est pas valide");
            }
        }

        // VALIDATION DATE DEBUT
        if (ValidationUtil.estVide(dateDebutStr)) {
            erreurs.add("La date de début est obligatoire");
        } else if (!ValidationUtil.estDateValide(dateDebutStr)) {
            erreurs.add("La date de début n'est pas valide");
        }

        // VALIDATION : Cohérence date/état
        if (!ValidationUtil.estVide(dateDebutStr) && !ValidationUtil.estVide(etat)) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date dateDebut = sdf.parse(dateDebutStr);
                Date aujourdhui = new Date();

                // Normaliser les dates (ignorer l'heure)
                dateDebut = ValidationUtil.normaliserDate(dateDebut);
                aujourdhui = ValidationUtil.normaliserDate(aujourdhui);

                // RÈGLE 1 : Si la date de début est dans le FUTUR
                if (dateDebut.after(aujourdhui)) {
                    // Seul PAS_COMMENCE est autorisé
                    if ("EN_COURS".equals(etat)) {
                        erreurs.add("Un projet qui commence dans le futur doit être PAS COMMENCÉ, pas EN COURS.");
                    } else if ("TERMINE".equals(etat)) {
                        erreurs.add("Un projet TERMINÉ ne peut pas avoir une date de début dans le futur.");
                    }
                }
                // RÈGLE 2 : Si la date de début est AUJOURD'HUI ou dans le PASSÉ
                else {
                    // Seul EN_COURS est autorisé (sauf si date de fin dépassée)
                    if ("PAS_COMMENCE".equals(etat)) {
                        erreurs.add(
                                "Un projet qui commence aujourd'hui ou dans le passé doit être EN COURS, pas PAS COMMENCÉ.");
                    } else if ("TERMINE".equals(etat)) {
                        // Vérifier que la date de fin prévue est bien dans le passé
                        if (!ValidationUtil.estVide(dateFinPrevueStr)) {
                            Date dateFin = sdf.parse(dateFinPrevueStr);

                            dateFin = ValidationUtil.normaliserDate(dateFin);

                            if (!dateFin.before(aujourdhui)) {
                                erreurs.add("Un projet TERMINÉ doit avoir une date de fin prévue dans le passé.");
                            }
                        } else {
                            erreurs.add("Un projet TERMINÉ doit avoir une date de fin prévue.");
                        }
                    }
                }

            } catch (ParseException e) {
                // Erreur déjà gérée par la validation précédente
            }
        }

        // VALIDATION DATE FIN PREVUE (doit être après date début)
        if (!ValidationUtil.estVide(dateFinPrevueStr) && !ValidationUtil.estVide(dateDebutStr)) {
            if (!ValidationUtil.estDateFinApresDebut(dateDebutStr, dateFinPrevueStr)) {
                erreurs.add("La date de fin prévue doit être après ou égale à la date de début");
            }
        }

        // VALIDATION CHEF PROJET (optionnel)
        if (!ValidationUtil.estVide(chefStr) && !ValidationUtil.estNombrePositif(chefStr)) {
            erreurs.add("Le chef de projet sélectionné n'est pas valide");
        }

        // VALIDATION DEPARTEMENT (optionnel)
        if (!ValidationUtil.estVide(deptStr) && !ValidationUtil.estNombrePositif(deptStr)) {
            erreurs.add("Le département sélectionné n'est pas valide");
        }

        // Si des erreurs existent, retourner au formulaire
        if (!erreurs.isEmpty()) {
            request.setAttribute("erreurs", erreurs);
            showNewForm(request, response);
            return;
        }

        // VERIFICATION DES DOUBLONS AVANT CREATION
        Projet existingByNomProjet = projetDAO.getByNomProjet(nomProjet.trim());
        if (existingByNomProjet != null) {
            erreurs.add("Un projet avec ce nom existe déjà");
            request.setAttribute("erreurs", erreurs);
            showNewForm(request, response);
            return;
        }

        // VÉRIFICATION : Cohérence chef de projet / département
        if (chefStr != null && !chefStr.trim().isEmpty() && deptStr != null && !deptStr.trim().isEmpty()) {
            int chefId = Integer.parseInt(chefStr);
            int deptId = Integer.parseInt(deptStr);

            Employer chefCandidat = employerDAO.getById(chefId);
            if (chefCandidat != null) {
                // Vérifier que le chef a un département
                if (chefCandidat.getIdDepartement() == null) {
                    erreurs.add(
                            "Le chef de projet sélectionné n'appartient à aucun département. Veuillez d'abord l'affecter à un département.");
                    request.setAttribute("erreurs", erreurs);
                    showNewForm(request, response);
                    return;
                }

                // Vérifier que le chef appartient au même département que le projet
                if (!chefCandidat.getIdDepartement().equals(deptId)) {
                    Departement deptChef = departementDAO.getById(chefCandidat.getIdDepartement());
                    Departement deptProjet = departementDAO.getById(deptId);
                    erreurs.add("Le chef de projet sélectionné appartient au département \"" + deptChef.getIntitule()
                            + "\" mais le projet est rattaché au département \"" + deptProjet.getIntitule()
                            + "\". Ils doivent appartenir au même département.");
                    request.setAttribute("erreurs", erreurs);
                    showNewForm(request, response);
                    return;
                }
            }
        }

        try {
            Projet projet = new Projet();
            projet.setNomProjet(ValidationUtil.nettoyerTexte(nomProjet.trim()));

            // Par défaut : PAS_COMMENCE si aucun état fourni
            if (etat != null && !etat.trim().isEmpty()) {
                projet.setEtatProjet(etat);
            } else {
                projet.setEtatProjet("PAS_COMMENCE");
            }

            // Dates
            if (dateDebutStr != null && !dateDebutStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                projet.setDateDebut(sdf.parse(dateDebutStr));
            }

            if (dateFinPrevueStr != null && !dateFinPrevueStr.trim().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                projet.setDateFinPrevue(sdf.parse(dateFinPrevueStr));
            }

            // Chef de projet
            if (chefStr != null && !chefStr.trim().isEmpty()) {
                int chefId = Integer.parseInt(chefStr);
                projet.setChefProjet(chefId);

                // Synchroniser : Changer le role en CHEF_PROJET
                Employer chef = employerDAO.getById(chefId);
                if (chef != null && !"ADMIN".equals(chef.getRole()) && !"CHEF_DEPT".equals(chef.getRole())) {
                    chef.setRole("CHEF_PROJET");
                    employerDAO.update(chef);
                }
            }

            // Département
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                int selectedDeptId = Integer.parseInt(deptStr);

                // Si c'est un chef de département, vérifier qu'il crée bien pour SON
                // département
                if (PermissionUtil.isChefDept(request) && currentUser != null) {
                    Integer userDeptId = currentUser.getIdDepartement();
                    if (userDeptId == null || !userDeptId.equals(selectedDeptId)) {
                        erreurs.add("Vous ne pouvez créer des projets que pour votre propre département");
                        request.setAttribute("erreurs", erreurs);
                        showNewForm(request, response);
                        return;
                    }
                }

                projet.setIdDepartement(selectedDeptId);
            }

            boolean success = projetDAO.create(projet);

            if (success) {
                request.getSession().setAttribute("successMessage", "Projet créé avec succès");
                response.sendRedirect(request.getContextPath() + "/projets");
            } else {
                erreurs.add("Erreur lors de la création du projet (doublon possible)");
                request.setAttribute("erreurs", erreurs);
                showNewForm(request, response);
            }

        } catch (Exception e) {
            List<String> erreurs2 = new ArrayList<>();
            erreurs2.add("Erreur : " + e.getMessage());
            request.setAttribute("erreurs", erreurs2);
            showNewForm(request, response);
        }
    }

    /**
     * Mettre à jour un projet
     * Admin : peut tout modifier
     * Chef de projet : peut modifier SEULEMENT certains champs (état, date fin
     * prévue, date fin réelle)
     */
    /**
     * Mettre à jour un projet
     * Admin : peut tout modifier
     * Chef de projet : peut modifier SEULEMENT certains champs (état, date fin prévue, date fin réelle)
     */
    private void updateProjet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Projet projet = projetDAO.getById(id);

            if (projet == null) {
                response.sendRedirect(request.getContextPath() + "/projets");
                return;
            }

            Employer currentUser = PermissionUtil.getLoggedUser(request);

            // Vérifier les permissions
            boolean isAdmin = PermissionUtil.isAdmin(request);
            boolean isChefProjet = currentUser != null && projet.getChefProjet() != null &&
                    currentUser.getId().equals(projet.getChefProjet());
            boolean isChefDept = false;

            // Chef de département : peut modifier les projets de son département
            if (PermissionUtil.isChefDept(request) && currentUser != null) {
                Integer userDeptId = currentUser.getIdDepartement();
                Integer projetDeptId = projet.getIdDepartement();

                if (userDeptId != null && userDeptId.equals(projetDeptId)) {
                    isChefDept = true;
                }
            }

            // Si aucune permission, rediriger
            if (!isAdmin && !isChefProjet && !isChefDept) {
                response.sendRedirect(request.getContextPath() + "/projets");
                return;
            }

            // Récupération des paramètres
            String nomProjet = request.getParameter("nomProjet");
            String nouvelEtat = request.getParameter("etatProjet");
            String dateDebutStr = request.getParameter("dateDebut");
            String dateFinPrevueStr = request.getParameter("dateFinPrevue");
            String dateFinReelleStr = request.getParameter("dateFinReelle");
            String chefStr = request.getParameter("chefProjet");
            String deptStr = request.getParameter("idDepartement");

            List<String> erreurs = new ArrayList<>();

            // VALIDATION POUR ADMIN
            if (isAdmin) {
                if (ValidationUtil.estVide(nomProjet)) {
                    erreurs.add("Le nom du projet est obligatoire");
                } else if (!ValidationUtil.estLongueurValide(nomProjet, 150)) {
                    erreurs.add("Le nom du projet ne doit pas dépasser 150 caractères");
                }

                if (!ValidationUtil.estVide(nouvelEtat)) {
                    if (!ValidationUtil.estEtatProjetValide(nouvelEtat)) {
                        erreurs.add("L'état du projet n'est pas valide");
                    }
                }

                if (!ValidationUtil.estVide(dateDebutStr)) {
                    if (!ValidationUtil.estDateValide(dateDebutStr)) {
                        erreurs.add("La date de début n'est pas valide");
                    }
                }

                // Validation cohérence date/état
                if (!ValidationUtil.estVide(dateDebutStr) && !ValidationUtil.estVide(nouvelEtat)) {
                    try {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        Date dateDebut = sdf.parse(dateDebutStr);
                        Date aujourdhui = new Date();

                        // Normaliser les dates
                        dateDebut = ValidationUtil.normaliserDate(dateDebut);
                        aujourdhui = ValidationUtil.normaliserDate(aujourdhui);

                        // RÈGLE 1 : Date FUTURE
                        if (dateDebut.after(aujourdhui)) {
                            if ("EN_COURS".equals(nouvelEtat)) {
                                erreurs.add(
                                        "Un projet qui commence dans le futur doit être PAS COMMENCÉ, pas EN COURS.");
                            } else if ("TERMINE".equals(nouvelEtat)) {
                                erreurs.add("Un projet TERMINÉ ne peut pas avoir une date de début dans le futur.");
                            }
                        }
                        // RÈGLE 2 : Date AUJOURD'HUI ou PASSÉ
                        else {
                            if ("PAS_COMMENCE".equals(nouvelEtat)) {
                                erreurs.add(
                                        "Un projet qui commence aujourd'hui ou dans le passé doit être EN COURS, pas PAS COMMENCÉ.");
                            } else if ("TERMINE".equals(nouvelEtat)) {
                                if (!ValidationUtil.estVide(dateFinPrevueStr)) {
                                    Date dateFin = sdf.parse(dateFinPrevueStr);

                                    dateFin = ValidationUtil.normaliserDate(dateFin);

                                    if (!dateFin.before(aujourdhui)) {
                                        erreurs.add(
                                                "Un projet TERMINÉ doit avoir une date de fin prévue dans le passé.");
                                    }
                                } else {
                                    erreurs.add("Un projet TERMINÉ doit avoir une date de fin prévue.");
                                }
                            }
                        }
                    } catch (ParseException e) {
                        // Ignore
                    }
                }

                if (!ValidationUtil.estVide(dateFinPrevueStr) && !ValidationUtil.estVide(dateDebutStr)) {
                    if (!ValidationUtil.estDateFinApresDebut(dateDebutStr, dateFinPrevueStr)) {
                        erreurs.add("La date de fin prévue doit être après ou égale à la date de début");
                    }
                }

                if (!ValidationUtil.estVide(dateFinReelleStr) && !ValidationUtil.estVide(dateDebutStr)) {
                    if (!ValidationUtil.estDateFinApresDebut(dateDebutStr, dateFinReelleStr)) {
                        erreurs.add("La date de fin réelle doit être après ou égale à la date de début");
                    }
                }

                if (!ValidationUtil.estVide(chefStr) && !ValidationUtil.estNombrePositif(chefStr)) {
                    erreurs.add("Le chef de projet sélectionné n'est pas valide");
                }

                if (!ValidationUtil.estVide(deptStr) && !ValidationUtil.estNombrePositif(deptStr)) {
                    erreurs.add("Le département sélectionné n'est pas valide");
                }
            }

            // VALIDATION POUR CHEF DE PROJET
            else if (isChefProjet) {
                if (!ValidationUtil.estVide(nouvelEtat)) {
                    if (!ValidationUtil.estEtatProjetValide(nouvelEtat)) {
                        erreurs.add("L'état du projet n'est pas valide");
                    }
                }

                // Validation cohérence date/état (date existante)
                if (!ValidationUtil.estVide(nouvelEtat) && projet.getDateDebut() != null) {
                    Date dateDebut = projet.getDateDebut();
                    Date aujourdhui = new Date();

                    // Normaliser
                    dateDebut = ValidationUtil.normaliserDate(dateDebut);
                    aujourdhui = ValidationUtil.normaliserDate(aujourdhui);

                    if (dateDebut.after(aujourdhui)) {
                        if ("EN_COURS".equals(nouvelEtat)) {
                            erreurs.add("Un projet qui commence dans le futur doit être PAS COMMENCÉ, pas EN COURS.");
                        } else if ("TERMINE".equals(nouvelEtat)) {
                            erreurs.add("Un projet TERMINÉ ne peut pas avoir une date de début dans le futur.");
                        }
                    } else {
                        if ("PAS_COMMENCE".equals(nouvelEtat)) {
                            erreurs.add(
                                    "Un projet qui commence aujourd'hui ou dans le passé doit être EN COURS, pas PAS COMMENCÉ.");
                        }
                    }
                }

                if (!ValidationUtil.estVide(dateFinPrevueStr)) {
                    if (projet.getDateDebut() != null) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        String dateDebutActuelle = sdf.format(projet.getDateDebut());
                        if (!ValidationUtil.estDateFinApresDebut(dateDebutActuelle, dateFinPrevueStr)) {
                            erreurs.add("La date de fin prévue doit être après ou égale à la date de début");
                        }
                    }
                }

                if (!ValidationUtil.estVide(dateFinReelleStr)) {
                    if (projet.getDateDebut() != null) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        String dateDebutActuelle = sdf.format(projet.getDateDebut());
                        if (!ValidationUtil.estDateFinApresDebut(dateDebutActuelle, dateFinReelleStr)) {
                            erreurs.add("La date de fin réelle doit être après ou égale à la date de début");
                        }
                    }
                }
            }

            // VALIDATION POUR CHEF DE DÉPARTEMENT
            else if (isChefDept) {
                if (ValidationUtil.estVide(nomProjet)) {
                    erreurs.add("Le nom du projet est obligatoire");
                } else if (!ValidationUtil.estLongueurValide(nomProjet, 150)) {
                    erreurs.add("Le nom du projet ne doit pas dépasser 150 caractères");
                }

                if (!ValidationUtil.estVide(nouvelEtat)) {
                    if (!ValidationUtil.estEtatProjetValide(nouvelEtat)) {
                        erreurs.add("L'état du projet n'est pas valide");
                    }
                }

                // Validation cohérence date/état (date existante)
                if (!ValidationUtil.estVide(nouvelEtat) && projet.getDateDebut() != null) {
                    Date dateDebut = projet.getDateDebut();
                    Date aujourdhui = new Date();

                    // Normaliser
                    dateDebut = ValidationUtil.normaliserDate(dateDebut);
                    aujourdhui = ValidationUtil.normaliserDate(aujourdhui);

                    if (dateDebut.after(aujourdhui)) {
                        if ("EN_COURS".equals(nouvelEtat)) {
                            erreurs.add("Un projet qui commence dans le futur doit être PAS COMMENCÉ, pas EN COURS.");
                        } else if ("TERMINE".equals(nouvelEtat)) {
                            erreurs.add("Un projet TERMINÉ ne peut pas avoir une date de début dans le futur.");
                        }
                    } else {
                        if ("PAS_COMMENCE".equals(nouvelEtat)) {
                            erreurs.add(
                                    "Un projet qui commence aujourd'hui ou dans le passé doit être EN COURS, pas PAS COMMENCÉ.");
                        }
                    }
                }

                if (!ValidationUtil.estVide(chefStr) && !ValidationUtil.estNombrePositif(chefStr)) {
                    erreurs.add("Le chef de projet sélectionné n'est pas valide");
                }

                if (!ValidationUtil.estVide(dateFinPrevueStr)) {
                    if (projet.getDateDebut() != null) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        String dateDebutActuelle = sdf.format(projet.getDateDebut());
                        if (!ValidationUtil.estDateFinApresDebut(dateDebutActuelle, dateFinPrevueStr)) {
                            erreurs.add("La date de fin prévue doit être après ou égale à la date de début");
                        }
                    }
                }

                if (!ValidationUtil.estVide(dateFinReelleStr)) {
                    if (projet.getDateDebut() != null) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        String dateDebutActuelle = sdf.format(projet.getDateDebut());
                        if (!ValidationUtil.estDateFinApresDebut(dateDebutActuelle, dateFinReelleStr)) {
                            erreurs.add("La date de fin réelle doit être après ou égale à la date de début");
                        }
                    }
                }
            }

            // Si des erreurs existent, retourner au formulaire
            if (!erreurs.isEmpty()) {
                request.setAttribute("erreurs", erreurs);
                request.setAttribute("projet", projet);
                showEditForm(request, response);
                return;
            }

            // VÉRIFICATION DES DOUBLONS
            if ((isAdmin || isChefDept) && !ValidationUtil.estVide(nomProjet)) {
                Projet existingByNomProjet = projetDAO.getByNomProjet(nomProjet.trim());
                if (existingByNomProjet != null && !existingByNomProjet.getId().equals(id)) {
                    erreurs.add("Un projet avec ce nom existe déjà");
                    request.setAttribute("erreurs", erreurs);
                    request.setAttribute("projet", projet);
                    showEditForm(request, response);
                    return;
                }
            }

            // VALIDATION : Pas de chef si ANNULE
            if ((isAdmin || isChefDept) && "ANNULE".equals(nouvelEtat)) {
                if (chefStr != null && !chefStr.trim().isEmpty()) {
                    erreurs.add("Un projet ANNULÉ ne peut pas avoir de chef de projet.");
                    request.setAttribute("erreurs", erreurs);
                    request.setAttribute("projet", projet);
                    showEditForm(request, response);
                    return;
                }
            }

            // VÉRIFICATIONS DE COHÉRENCE DÉPARTEMENT/CHEF (ADMIN)
            if (isAdmin) {
            	
                // CAS 0 : Ajout simultané de département ET de chef (si le projet n'a ni l'un ni l'autre)
                if (deptStr != null && !deptStr.trim().isEmpty() && 
                    chefStr != null && !chefStr.trim().isEmpty() &&
                    projet.getIdDepartement() == null && projet.getChefProjet() == null) {
                    
                    int nouveauDeptId = Integer.parseInt(deptStr);
                    int nouveauChefId = Integer.parseInt(chefStr);
                    
                    Employer chefCandidat = employerDAO.getById(nouveauChefId);
                    
                    if (chefCandidat != null && chefCandidat.getIdDepartement() != null) {
                        if (!chefCandidat.getIdDepartement().equals(nouveauDeptId)) {
                            Departement deptChef = departementDAO.getById(chefCandidat.getIdDepartement());
                            Departement nouveauDept = departementDAO.getById(nouveauDeptId);
                            erreurs.add("Le chef de projet \"" + chefCandidat.getPrenom() + " " + chefCandidat.getNom() +
                                    "\" appartient au département \"" + deptChef.getIntitule() +
                                    "\" mais vous voulez rattacher le projet au département \"" + nouveauDept.getIntitule() + "\".");
                            request.setAttribute("erreurs", erreurs);
                            request.setAttribute("projet", projet);
                            showEditForm(request, response);
                            return;
                        }
                    }
                }
                
                // CAS 1 : Changement de département
                if (deptStr != null && !deptStr.trim().isEmpty() && projet.getChefProjet() != null) {
                    int nouveauDeptId = Integer.parseInt(deptStr);
                    Integer ancienDeptId = projet.getIdDepartement();

                    if (ancienDeptId == null || !ancienDeptId.equals(nouveauDeptId)) {
                        Employer chefActuel = employerDAO.getById(projet.getChefProjet());

                        if (chefActuel != null && chefActuel.getIdDepartement() != null) {
                            if (!chefActuel.getIdDepartement().equals(nouveauDeptId)) {
                                Departement deptChef = departementDAO.getById(chefActuel.getIdDepartement());
                                Departement nouveauDept = departementDAO.getById(nouveauDeptId);
                                erreurs.add("Impossible de changer le département : le chef de projet \"" +
                                        chefActuel.getPrenom() + " " + chefActuel.getNom() +
                                        "\" appartient au département \"" + deptChef.getIntitule() +
                                        "\" mais vous voulez rattacher le projet au département \"" +
                                        nouveauDept.getIntitule() + "\".");
                                request.setAttribute("erreurs", erreurs);
                                request.setAttribute("projet", projet);
                                showEditForm(request, response);
                                return;
                            }
                        }
                    }
                }

                // CAS 2 : Ajout de département
                if (deptStr != null && !deptStr.trim().isEmpty() && projet.getIdDepartement() == null &&
                        projet.getChefProjet() != null) {
                    int nouveauDeptId = Integer.parseInt(deptStr);
                    Employer chefActuel = employerDAO.getById(projet.getChefProjet());

                    if (chefActuel != null && chefActuel.getIdDepartement() != null) {
                        if (!chefActuel.getIdDepartement().equals(nouveauDeptId)) {
                            Departement deptChef = departementDAO.getById(chefActuel.getIdDepartement());
                            Departement nouveauDept = departementDAO.getById(nouveauDeptId);
                            erreurs.add("Impossible d'ajouter ce département : le chef appartient au département \"" +
                                    deptChef.getIntitule() + "\" mais vous voulez rattacher le projet au département \""
                                    +
                                    nouveauDept.getIntitule() + "\".");
                            request.setAttribute("erreurs", erreurs);
                            request.setAttribute("projet", projet);
                            showEditForm(request, response);
                            return;
                        }
                    }
                }

                // CAS 3 : Changement de chef
                if (chefStr != null && !chefStr.trim().isEmpty() && projet.getIdDepartement() != null) {
                    int nouveauChefId = Integer.parseInt(chefStr);
                    Integer ancienChefId = projet.getChefProjet();

                    if (ancienChefId == null || !ancienChefId.equals(nouveauChefId)) {
                        Employer nouveauChef = employerDAO.getById(nouveauChefId);

                        if (nouveauChef != null) {
                            if (nouveauChef.getIdDepartement() == null) {
                                erreurs.add("Le chef de projet sélectionné n'appartient à aucun département.");
                                request.setAttribute("erreurs", erreurs);
                                request.setAttribute("projet", projet);
                                showEditForm(request, response);
                                return;
                            }

                            if (!nouveauChef.getIdDepartement().equals(projet.getIdDepartement())) {
                                Departement deptChef = departementDAO.getById(nouveauChef.getIdDepartement());
                                Departement deptProjet = departementDAO.getById(projet.getIdDepartement());
                                erreurs.add("Le chef appartient au département \"" + deptChef.getIntitule() +
                                        "\" mais le projet est rattaché au département \"" + deptProjet.getIntitule()
                                        + "\".");
                                request.setAttribute("erreurs", erreurs);
                                request.setAttribute("projet", projet);
                                showEditForm(request, response);
                                return;
                            }
                        }
                    }
                }
            }

            // VÉRIFICATIONS CHEF DE DÉPARTEMENT
            if (isChefDept) {
                if (chefStr != null && !chefStr.trim().isEmpty()) {
                    int chefId = Integer.parseInt(chefStr);
                    Integer ancienChefId = projet.getChefProjet();

                    if (ancienChefId == null || !ancienChefId.equals(chefId)) {
                        Integer projetDeptId = projet.getIdDepartement();

                        if (projetDeptId != null) {
                            Employer chefCandidat = employerDAO.getById(chefId);
                            if (chefCandidat != null) {
                                if (chefCandidat.getIdDepartement() == null) {
                                    erreurs.add("Le chef de projet sélectionné n'appartient à aucun département.");
                                    request.setAttribute("erreurs", erreurs);
                                    request.setAttribute("projet", projet);
                                    showEditForm(request, response);
                                    return;
                                }

                                if (!chefCandidat.getIdDepartement().equals(projetDeptId)) {
                                    Departement deptChef = departementDAO.getById(chefCandidat.getIdDepartement());
                                    Departement deptProjet = departementDAO.getById(projetDeptId);
                                    erreurs.add("Le chef appartient au département \"" + deptChef.getIntitule() +
                                            "\" mais le projet est rattaché au département \""
                                            + deptProjet.getIntitule() + "\".");
                                    request.setAttribute("erreurs", erreurs);
                                    request.setAttribute("projet", projet);
                                    showEditForm(request, response);
                                    return;
                                }
                            }
                        }
                    }
                }
            }

            // MISE À JOUR
            if (isAdmin) {
                projet.setNomProjet(ValidationUtil.nettoyerTexte(nomProjet));
                projet.setEtatProjet(nouvelEtat);

                // Rétrogradation si TERMINE ou ANNULE
                if (("TERMINE".equals(nouvelEtat) || "ANNULE".equals(nouvelEtat)) && projet.getChefProjet() != null) {
                    Integer chefId = projet.getChefProjet();
                    Employer chef = employerDAO.getById(chefId);

                    if (chef != null && "CHEF_PROJET".equals(chef.getRole())) {
                        List<Projet> autresProjets = projetDAO.getByChefProjet(chefId);
                        boolean aAutreProjetActif = false;

                        if (autresProjets != null) {
                            for (Projet p : autresProjets) {
                                // Exclure le projet actuel ET vérifier qu'il est actif (EN_COURS ou PAS_COMMENCE)
                                if (!p.getId().equals(projet.getId()) &&
                                        ("EN_COURS".equals(p.getEtatProjet())
                                                || "PAS_COMMENCE".equals(p.getEtatProjet()))) {
                                    aAutreProjetActif = true;
                                    break;
                                }
                            }
                        }

                        if (!aAutreProjetActif) {
                            chef.setRole("EMPLOYE");
                            employerDAO.update(chef);
                        }
                    }

                    // Si ANNULE, retirer automatiquement le chef
                    if ("ANNULE".equals(nouvelEtat)) {
                        projet.setChefProjet(null);
                    }
                }

                if (dateDebutStr != null && !dateDebutStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateDebut(sdf.parse(dateDebutStr));
                }

                if (dateFinPrevueStr != null && !dateFinPrevueStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinPrevue(sdf.parse(dateFinPrevueStr));
                }

                if (dateFinReelleStr != null && !dateFinReelleStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinReelle(sdf.parse(dateFinReelleStr));
                } else {
                    projet.setDateFinReelle(null);
                }

                // Gestion du chef (sauf si ANNULE, déjà géré ci-dessus)
                if (!"ANNULE".equals(nouvelEtat)) {
                    if (chefStr != null && !chefStr.trim().isEmpty()) {
                        int nouveauChefId = Integer.parseInt(chefStr);
                        Integer ancienChefId = projet.getChefProjet();

                        if (ancienChefId == null || !ancienChefId.equals(nouveauChefId)) {
                            if (ancienChefId != null) {
                                Employer ancienChef = employerDAO.getById(ancienChefId);
                                if (ancienChef != null && "CHEF_PROJET".equals(ancienChef.getRole())) {
                                    List<Projet> autresProjets = projetDAO.getByChefProjet(ancienChefId);
                                    if (autresProjets == null || autresProjets.size() <= 1) {
                                        ancienChef.setRole("EMPLOYE");
                                        employerDAO.update(ancienChef);
                                    }
                                }
                            }

                            Employer nouveauChef = employerDAO.getById(nouveauChefId);
                            if (nouveauChef != null && !"ADMIN".equals(nouveauChef.getRole()) &&
                                    !"CHEF_DEPT".equals(nouveauChef.getRole())) {
                                nouveauChef.setRole("CHEF_PROJET");
                                employerDAO.update(nouveauChef);
                            }
                        }

                        projet.setChefProjet(nouveauChefId);
                    } else {
                        Integer ancienChefId = projet.getChefProjet();

                        if (ancienChefId != null) {
                            Employer ancienChef = employerDAO.getById(ancienChefId);
                            if (ancienChef != null && "CHEF_PROJET".equals(ancienChef.getRole())) {
                                List<Projet> autresProjets = projetDAO.getByChefProjet(ancienChefId);
                                if (autresProjets == null || autresProjets.size() <= 1) {
                                    ancienChef.setRole("EMPLOYE");
                                    employerDAO.update(ancienChef);
                                }
                            }
                        }

                        projet.setChefProjet(null);
                    }
                }

                // CORRECTION : Gestion du département (avec support pour "Aucun")
                if (deptStr != null && !deptStr.trim().isEmpty()) {
                    projet.setIdDepartement(Integer.parseInt(deptStr));
                } else {
                    // Si deptStr est vide, mettre le département à null
                    projet.setIdDepartement(null);
                }
            } else if (isChefProjet) {
                if (nouvelEtat != null && !nouvelEtat.trim().isEmpty()) {
                    projet.setEtatProjet(nouvelEtat);
                }

                if (dateFinPrevueStr != null && !dateFinPrevueStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinPrevue(sdf.parse(dateFinPrevueStr));
                }

                if (dateFinReelleStr != null && !dateFinReelleStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinReelle(sdf.parse(dateFinReelleStr));
                } else {
                    projet.setDateFinReelle(null);
                }
            } else if (isChefDept) {
                if (nomProjet != null && !nomProjet.trim().isEmpty()) {
                    projet.setNomProjet(ValidationUtil.nettoyerTexte(nomProjet.trim()));
                }

                if (nouvelEtat != null && !nouvelEtat.trim().isEmpty()) {
                    projet.setEtatProjet(nouvelEtat);

                    // Rétrogradation si TERMINE ou ANNULE
                    if (("TERMINE".equals(nouvelEtat) || "ANNULE".equals(nouvelEtat))
                            && projet.getChefProjet() != null) {
                        Integer chefId = projet.getChefProjet();
                        Employer chef = employerDAO.getById(chefId);

                        if (chef != null && "CHEF_PROJET".equals(chef.getRole())) {
                            List<Projet> autresProjets = projetDAO.getByChefProjet(chefId);
                            boolean aAutreProjetActif = false;

                            if (autresProjets != null) {
                                for (Projet p : autresProjets) {
                                    if (!p.getId().equals(projet.getId()) &&
                                            ("EN_COURS".equals(p.getEtatProjet())
                                                    || "PAS_COMMENCE".equals(p.getEtatProjet()))) {
                                        aAutreProjetActif = true;
                                        break;
                                    }
                                }
                            }

                            if (!aAutreProjetActif) {
                                chef.setRole("EMPLOYE");
                                employerDAO.update(chef);
                            }
                        }

                        // Si ANNULE, retirer automatiquement le chef
                        if ("ANNULE".equals(nouvelEtat)) {
                            projet.setChefProjet(null);
                        }
                    }
                }

                // Gestion du chef (sauf si ANNULE)
                if (!"ANNULE".equals(nouvelEtat)) {
                    if (chefStr != null && !chefStr.trim().isEmpty()) {
                        int nouveauChefId = Integer.parseInt(chefStr);
                        Integer ancienChefId = projet.getChefProjet();

                        if (ancienChefId == null || !ancienChefId.equals(nouveauChefId)) {
                            if (ancienChefId != null) {
                                Employer ancienChef = employerDAO.getById(ancienChefId);
                                if (ancienChef != null && "CHEF_PROJET".equals(ancienChef.getRole())) {
                                    List<Projet> autresProjets = projetDAO.getByChefProjet(ancienChefId);
                                    if (autresProjets == null || autresProjets.size() <= 1) {
                                        ancienChef.setRole("EMPLOYE");
                                        employerDAO.update(ancienChef);
                                    }
                                }
                            }

                            Employer nouveauChef = employerDAO.getById(nouveauChefId);
                            if (nouveauChef != null && !"ADMIN".equals(nouveauChef.getRole()) &&
                                    !"CHEF_DEPT".equals(nouveauChef.getRole())) {
                                nouveauChef.setRole("CHEF_PROJET");
                                employerDAO.update(nouveauChef);
                            }

                            projet.setChefProjet(nouveauChefId);
                        }
                    } else {
                        Integer ancienChefId = projet.getChefProjet();

                        if (ancienChefId != null) {
                            Employer ancienChef = employerDAO.getById(ancienChefId);
                            if (ancienChef != null && "CHEF_PROJET".equals(ancienChef.getRole())) {
                                List<Projet> autresProjets = projetDAO.getByChefProjet(ancienChefId);
                                if (autresProjets == null || autresProjets.size() <= 1) {
                                    ancienChef.setRole("EMPLOYE");
                                    employerDAO.update(ancienChef);
                                }
                            }
                        }

                        projet.setChefProjet(null);
                    }
                }

                if (dateFinPrevueStr != null && !dateFinPrevueStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinPrevue(sdf.parse(dateFinPrevueStr));
                }

                if (dateFinReelleStr != null && !dateFinReelleStr.trim().isEmpty()) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    projet.setDateFinReelle(sdf.parse(dateFinReelleStr));
                } else {
                    projet.setDateFinReelle(null);
                }
            }

            boolean success = projetDAO.update(projet);

            if (success) {
                request.getSession().setAttribute("successMessage", "Projet mis à jour avec succès");
                response.sendRedirect(request.getContextPath() + "/projets");
            } else {
                    erreurs.add("Erreur lors de la mise à jour (doublon possible)");
                    request.setAttribute("erreurs", erreurs);
                    showEditForm(request, response);
                }
    	} catch (Exception e) {
        List<String> erreurs = new ArrayList<>();
        erreurs.add("Erreur : " + e.getMessage());
        request.setAttribute("erreurs", erreurs);
        showEditForm(request, response);
    }
    }

    /**
     * Supprimer un projet
     * Seul l'admin peut supprimer
     */

    private void deleteProjet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(id);

        if (projet != null && projet.getChefProjet() != null) {
            Integer chefId = projet.getChefProjet();

            // Vérifier si le chef a d'autres projets
            List<Projet> autresProjets = projetDAO.getByChefProjet(chefId);

            // Si ce projet est le seul où il est chef, remettre en EMPLOYE
            if (autresProjets != null && autresProjets.size() == 1) {
                Employer chef = employerDAO.getById(chefId);
                if (chef != null && "CHEF_PROJET".equals(chef.getRole())) {
                    chef.setRole("EMPLOYE");
                    employerDAO.update(chef);
                }
            }
        }

        // Supprimer le projet
        projetDAO.delete(id);
        request.getSession().setAttribute("successMessage", "Projet supprimé avec succès !");
        response.sendRedirect(request.getContextPath() + "/projets");
    }

    /**
     * Afficher l'équipe du projet
     * Tout le monde peut voir, mais seuls Admin et Chef de ce projet peuvent
     * modifier
     */
    private void showEquipe(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int projetId = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(projetId);
        Employer currentUser = PermissionUtil.getLoggedUser(request);

        // Récupérer les affectations
        List<AffectationProjet> affectations = affectationDAO.getEmployersByProjet(projetId);

        // Récupérer les détails des employés
        Map<Integer, Employer> employesMap = new HashMap<>();
        if (affectations != null) {
            for (AffectationProjet aff : affectations) {
                Employer emp = employerDAO.getById(aff.getIdEmployer());
                if (emp != null) {
                    employesMap.put(emp.getId(), emp);
                }
            }
        }

        // Chef de projet
        Employer chef = null;
        if (projet.getChefProjet() != null) {
            chef = employerDAO.getById(projet.getChefProjet());
        }

        // RÉCUPÉRER LE DÉPARTEMENT
        Departement departement = null;
        if (projet.getIdDepartement() != null) {
            departement = departementDAO.getById(projet.getIdDepartement());
        }

        // Vérifier si l'utilisateur peut modifier (Admin OU chef de ce projet)
        boolean canModify = PermissionUtil.isAdmin(request) ||
                (currentUser != null && projet.getChefProjet() != null &&
                        projet.getChefProjet().equals(currentUser.getId()));

        request.setAttribute("projet", projet);
        request.setAttribute("departement", departement);
        request.setAttribute("affectations", affectations);
        request.setAttribute("employesMap", employesMap);
        request.setAttribute("chef", chef);
        request.setAttribute("canModify", canModify);
        request.getRequestDispatcher("/WEB-INF/views/projets/equipe.jsp").forward(request, response);
    }

    /**
     * Afficher le formulaire d'affectation
     * Admin OU chef de ce projet peuvent affecter
     */
    private void showAffectationForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int projetId = Integer.parseInt(request.getParameter("id"));
        Projet projet = projetDAO.getById(projetId);
        Employer currentUser = PermissionUtil.getLoggedUser(request);

        // Vérifier permission : Admin OU chef de ce projet
        boolean canAffect = PermissionUtil.isAdmin(request) ||
                (currentUser != null && projet.getChefProjet() != null &&
                        projet.getChefProjet().equals(currentUser.getId()));

        if (!canAffect) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }

        // Récupérer le département du projet pour l'affichage
        if (projet.getIdDepartement() != null) {
            Departement departementProjet = departementDAO.getById(projet.getIdDepartement());
            request.setAttribute("departementProjet", departementProjet);
        }

        // Vérifier que le projet est EN_COURS ou PAS COMMENCE
        if (!"EN_COURS".equals(projet.getEtatProjet()) && !"PAS_COMMENCE".equals(projet.getEtatProjet())) {
            request.getSession().setAttribute("errorMessage",
                    "Impossible d'affecter un employé à un projet terminé ou annulé.");
            response.sendRedirect(request.getContextPath() + "/projets/equipe?id=" + projetId);
            return;
        }

        List<Employer> tousEmployes = employerDAO.getAll();

        // Filtrer les employés disponibles selon les règles :
        // 1. Ne pas afficher le chef de projet
        // 2. Ne pas afficher les employés déjà affectés
        // 3. NOUVEAU : Filtrer selon le département du projet
        List<Employer> employesDisponibles = new ArrayList<>();
        if (tousEmployes != null) {
            for (Employer emp : tousEmployes) {
                // Ne pas afficher : employés déjà affectés OU le chef de projet
                boolean estChef = (projet.getChefProjet() != null && projet.getChefProjet().equals(emp.getId()));
                boolean dejaAffecte = affectationDAO.isEmployerAffected(emp.getId(), projetId);

                if (!estChef && !dejaAffecte) {
                    // NOUVELLE VÉRIFICATION : Cohérence département
                    if (projet.getIdDepartement() != null) {
                        // Le projet a un département : seuls les employés du même département
                        if (emp.getIdDepartement() != null &&
                                emp.getIdDepartement().equals(projet.getIdDepartement())) {
                            employesDisponibles.add(emp);
                        }
                        // Si l'employé n'a pas de département, il ne peut pas être affecté
                    } else {
                        // Le projet n'a pas de département : tous les employés peuvent être affectés
                        employesDisponibles.add(emp);
                    }
                }
            }
        }

        request.setAttribute("projet", projet);
        request.setAttribute("employes", employesDisponibles);
        request.getRequestDispatcher("/WEB-INF/views/projets/affectation-form.jsp").forward(request, response);
    }

    /**
     * Affecter un employé au projet
     * Admin OU chef de ce projet peuvent affecter
     * NOUVEAU : Gère aussi l'affectation rapide depuis la liste des employés
     */
    private void affecterEmploye(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            int projetId = Integer.parseInt(request.getParameter("projetId"));
            int employeId = Integer.parseInt(request.getParameter("employeId"));

            Projet projet = projetDAO.getById(projetId);
            Employer currentUser = PermissionUtil.getLoggedUser(request);

            // Vérifier permission : Admin OU chef de ce projet
            boolean canAffect = PermissionUtil.isAdmin(request) ||
                    (currentUser != null && projet.getChefProjet() != null &&
                            projet.getChefProjet().equals(currentUser.getId()));

            if (!canAffect) {
                response.sendRedirect(request.getContextPath() + "/projets");
                return;
            }

            // Créer l'affectation
            AffectationProjet affectation = new AffectationProjet();
            affectation.setIdProjet(projetId);
            affectation.setIdEmployer(employeId);
            affectation.setDateAffectation(new Date());

            affectationDAO.create(affectation);
            request.getSession().setAttribute("successMessage", "Employé affecté au projet avec succès !");

            // Redirection intelligente selon la provenance
            String fromRapide = request.getParameter("fromRapide");
            if ("true".equals(fromRapide)) {
                // Si affectation rapide : retour à la liste des employés
                response.sendRedirect(request.getContextPath() + "/employees");
            } else {
                // Sinon : retour à l'équipe du projet
                response.sendRedirect(request.getContextPath() + "/projets/equipe?id=" + projetId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/projets");
        }
    }

    /**
     * Retirer un employé du projet
     * Admin OU chef de ce projet peuvent retirer
     */
    private void retirerEmploye(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int affectationId = Integer.parseInt(request.getParameter("affectationId"));
        int projetId = Integer.parseInt(request.getParameter("projetId"));

        Projet projet = projetDAO.getById(projetId);
        Employer currentUser = PermissionUtil.getLoggedUser(request);

        // Vérifier permission : Admin OU chef de ce projet
        boolean canRemove = PermissionUtil.isAdmin(request) ||
                (currentUser != null && projet.getChefProjet() != null &&
                        projet.getChefProjet().equals(currentUser.getId()));

        if (!canRemove) {
            response.sendRedirect(request.getContextPath() + "/projets");
            return;
        }

        affectationDAO.delete(affectationId);
        request.getSession().setAttribute("successMessage", "Employé retiré du projet avec succès !");
        response.sendRedirect(request.getContextPath() + "/projets/equipe?id=" + projetId);
    }

    /**
     * Afficher le formulaire d'affectation rapide depuis la liste des employés
     * Admin : tous les projets disponibles
     * Chef de projet : LEURS projets uniquement
     */
    private void showAffectationRapide(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int employeId = Integer.parseInt(request.getParameter("employeId"));
        Employer employe = employerDAO.getById(employeId);
        Employer currentUser = PermissionUtil.getLoggedUser(request);

        boolean isAdmin = PermissionUtil.isAdmin(request);
        boolean isChefProjet = currentUser != null && "CHEF_PROJET".equals(currentUser.getRole());

        // Vérifier les permissions
        if (!isAdmin && !isChefProjet) {
            response.sendRedirect(request.getContextPath() + "/employees");
            return;
        }

        List<Projet> projetsDisponibles = new ArrayList<>();

        if (isAdmin) {
            // ADMIN : tous les projets disponibles
            List<Projet> tousProjets = projetDAO.getAll();
            
            if (tousProjets != null) {
                for (Projet projet : tousProjets) {
                    // Filtrer : (EN_COURS ou PAS_COMMENCE) + pas déjà affecté + cohérence département
                    if (("EN_COURS".equals(projet.getEtatProjet()) || "PAS_COMMENCE".equals(projet.getEtatProjet())) &&
                            !affectationDAO.isEmployerAffected(employeId, projet.getId())) {
                        
                        // Cohérence département
                        if (projet.getIdDepartement() == null) {
                            // Projet transversal : tout le monde peut être affecté
                            projetsDisponibles.add(projet);
                        } else if (employe.getIdDepartement() != null && 
                                   employe.getIdDepartement().equals(projet.getIdDepartement())) {
                            // Projet départemental : seulement si même département
                            projetsDisponibles.add(projet);
                        }
                    }
                }
            }
        } else {
            // CHEF DE PROJET : uniquement ses projets
            List<Projet> mesProjets = projetDAO.getByChefProjet(currentUser.getId());
            
            if (mesProjets != null) {
                for (Projet projet : mesProjets) {
                    // Filtrer : (EN_COURS ou PAS_COMMENCE) + pas déjà affecté + cohérence département
                    if (("EN_COURS".equals(projet.getEtatProjet()) || "PAS_COMMENCE".equals(projet.getEtatProjet())) &&
                            !affectationDAO.isEmployerAffected(employeId, projet.getId())) {
                        
                        // Cohérence département
                        if (projet.getIdDepartement() == null) {
                            // Projet transversal : tout le monde peut être affecté
                            projetsDisponibles.add(projet);
                        } else if (employe.getIdDepartement() != null && 
                                   employe.getIdDepartement().equals(projet.getIdDepartement())) {
                            // Projet départemental : seulement si même département
                            projetsDisponibles.add(projet);
                        }
                    }
                }
            }
        }

        request.setAttribute("employe", employe);
        request.setAttribute("projets", projetsDisponibles);
        request.getRequestDispatcher("/WEB-INF/views/projets/affectation-rapide.jsp").forward(request, response);
    }
}