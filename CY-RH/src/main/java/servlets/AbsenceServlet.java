package servlets;

import dao.AbsenceDAO;
import dao.EmployerDAO;
import dao.ProjetDAO;
import models.Absence;
import models.Employer;
import models.Projet;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Date;
import java.util.Comparator;
import java.util.Collections;

import utils.ValidationUtil;

/**
 * Servlet pour gérer les absences
 * Permissions:
 * - ADMIN: voit toutes les absences
 * - CHEF_DEPT: voit les absences de son département
 * - CHEF_PROJET: voit les absences de ses projets
 * - EMPLOYE: voit uniquement ses propres absences
 */
@WebServlet("/absences/*")
public class AbsenceServlet extends HttpServlet {

    private AbsenceDAO absenceDAO;
    private EmployerDAO employerDAO;
    private ProjetDAO projetDAO;

    @Override
    public void init() {
        absenceDAO = new AbsenceDAO();
        employerDAO = new EmployerDAO();
        projetDAO = new ProjetDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getPathInfo();

        if (action == null || action.equals("/")) {
            // Lister les absences selon le rôle
            listAbsences(request, response);
        } else if (action.equals("/new")) {
            // Afficher le formulaire de création
            showNewForm(request, response);
        } else if (action.equals("/edit")) {
            // Afficher le formulaire de modification
            showEditForm(request, response);
        } else if (action.equals("/delete")) {
            // Supprimer une absence
            deleteAbsence(request, response);
        } else if (action.equals("/search")) {
            // Rechercher avec filtres
            searchAbsences(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getPathInfo();

        if (action != null && action.equals("/update")) {
            // Mettre à jour une absence existante
            updateAbsence(request, response);
        } else {
            // Créer une nouvelle absence
            createAbsence(request, response);
        }
    }

    /**
     * Lister les absences selon le rôle de l'utilisateur
     */
    private void listAbsences(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        Employer currentUser = (Employer) session.getAttribute("user");

        List<Absence> absences = new ArrayList<>();

        // Récupérer les absences selon le rôle
        if ("ADMIN".equals(role)) {
            // Admin voit toutes les absences
            absences = absenceDAO.getAll();
        } else if ("CHEF_DEPT".equals(role)) {
            // Chef de département voit les absences de son département
            if (currentUser.getIdDepartement() != null) {
                absences = absenceDAO.getByDepartement(currentUser.getIdDepartement());
            }
        } else if ("CHEF_PROJET".equals(role)) {
            // Chef de projet voit les absences de ses projets
            List<Projet> projets = projetDAO.getByChefProjet(currentUser.getId());
            if (projets != null) {
                for (Projet projet : projets) {
                    List<Absence> absencesProjet = absenceDAO.getByProjet(projet.getId());
                    if (absencesProjet != null) {
                        absences.addAll(absencesProjet);
                    }
                }
            }
        } else {
            // Employé voit uniquement ses propres absences
            absences = absenceDAO.getByEmployer(currentUser.getId());
        }

        // Créer une map des employés pour l'affichage
        Map<Integer, String> employersMap = new HashMap<>();
        List<Employer> allEmployers = employerDAO.getAll();
        if (allEmployers != null) {
            for (Employer emp : allEmployers) {
                employersMap.put(emp.getId(), emp.getPrenom() + " " + emp.getNom());
            }
        }

        // Indiquer si l'utilisateur peut modifier
        boolean canModify = PermissionUtil.isAdmin(request);

        // TRI UNIVERSEL POUR TOUS LES RÔLES
        String sortBy = request.getParameter("sortBy");
        String order = request.getParameter("order");
        if (sortBy != null && !sortBy.trim().isEmpty() && absences != null && !absences.isEmpty()) {
            final String finalSortBy = sortBy.trim();
            final String finalOrder = (order != null && order.trim().equalsIgnoreCase("DESC")) ? "DESC" : "ASC";
            final Map<Integer, String> finalEmployersMap = employersMap; // Pour utilisation dans le Comparator

            Collections.sort(absences, new Comparator<Absence>() {
                @Override
                public int compare(Absence a1, Absence a2) {
                    int result = 0;

                    switch (finalSortBy) {
                        case "employe":
                            // Tri par nom de l'employé
                            String nom1 = finalEmployersMap.get(a1.getIdEmployer());
                            String nom2 = finalEmployersMap.get(a2.getIdEmployer());
                            if (nom1 == null && nom2 == null)
                                result = 0;
                            else if (nom1 == null)
                                result = -1;
                            else if (nom2 == null)
                                result = 1;
                            else
                                result = nom1.compareToIgnoreCase(nom2);
                            break;

                        case "dateDebut":
                            if (a1.getDateDebut() == null && a2.getDateDebut() == null)
                                result = 0;
                            else if (a1.getDateDebut() == null)
                                result = -1;
                            else if (a2.getDateDebut() == null)
                                result = 1;
                            else
                                result = a1.getDateDebut().compareTo(a2.getDateDebut());
                            break;

                        case "dateFin":
                            if (a1.getDateFin() == null && a2.getDateFin() == null)
                                result = 0;
                            else if (a1.getDateFin() == null)
                                result = -1;
                            else if (a2.getDateFin() == null)
                                result = 1;
                            else
                                result = a1.getDateFin().compareTo(a2.getDateFin());
                            break;

                        case "typeAbsence":
                            result = a1.getTypeAbsence().compareTo(a2.getTypeAbsence());
                            break;

                        default:
                            result = 0;
                    }

                    return "DESC".equals(finalOrder) ? -result : result;
                }
            });
        }
        // Passer les paramètres de tri à la JSP
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("order", order);
        request.setAttribute("absences", absences);
        request.setAttribute("employersMap", employersMap);
        request.setAttribute("canModify", canModify);
        request.getRequestDispatcher("/WEB-INF/views/absences/list.jsp").forward(request, response);
    }

    /**
     * Afficher le formulaire de création
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Seul l'admin peut créer des absences
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/absences");
            return;
        }

        // Charger la liste des employés
        List<Employer> employees = employerDAO.getAll();
        request.setAttribute("employees", employees);

        request.getRequestDispatcher("/WEB-INF/views/absences/form.jsp").forward(request, response);
    }

    /**
     * Afficher le formulaire de modification
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Seul l'admin peut modifier
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/absences");
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        Absence absence = absenceDAO.getById(id);

        // Charger la liste des employés
        List<Employer> employees = employerDAO.getAll();

        request.setAttribute("absence", absence);
        request.setAttribute("employees", employees);
        request.getRequestDispatcher("/WEB-INF/views/absences/form.jsp").forward(request, response);
    }

    /**
     * Créer une nouvelle absence
     */
    private void createAbsence(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Seul l'admin peut créer
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/absences");
            return;
        }

        // Récupération des paramètres
        String idEmpStr = request.getParameter("idEmployer");
        String dateDebutStr = request.getParameter("dateDebut");
        String dateFinStr = request.getParameter("dateFin");
        String typeAbsence = request.getParameter("typeAbsence");
        String motif = request.getParameter("motif");

        // Liste pour stocker les erreurs de validation
        List<String> erreurs = new ArrayList<>();

        // Validation de l'employé
        if (ValidationUtil.estVide(idEmpStr)) {
            erreurs.add("Veuillez sélectionner un employé");
        } else if (!ValidationUtil.estNombrePositif(idEmpStr)) {
            erreurs.add("L'employé sélectionné n'est pas valide");
        }

        // Validation de la date de début
        if (ValidationUtil.estVide(dateDebutStr)) {
            erreurs.add("La date de début est obligatoire");
        } else if (!ValidationUtil.estDateValide(dateDebutStr)) {
            erreurs.add("La date de début n'est pas valide ou est dans le futur");
        }

        // Validation de la date de fin
        if (ValidationUtil.estVide(dateFinStr)) {
            erreurs.add("La date de fin est obligatoire");
        } else if (!ValidationUtil.estDateValide(dateFinStr)) {
            erreurs.add("La date de fin n'est pas valide ou est dans le futur");
        }

        // Validation : Date fin >= Date début
        if (!ValidationUtil.estVide(dateDebutStr) && !ValidationUtil.estVide(dateFinStr)) {
            if (!ValidationUtil.estDateFinApresDebut(dateDebutStr, dateFinStr)) {
                erreurs.add("La date de fin doit être après ou égale à la date de début");
            }
        }

        // Validation du type d'absence
        if (ValidationUtil.estVide(typeAbsence)) {
            erreurs.add("Le type d'absence est obligatoire");
        } else if (!typeAbsence.equals("CONGE") && !typeAbsence.equals("MALADIE")
                && !typeAbsence.equals("ABSENCE_INJUSTIFIEE")) {
            erreurs.add("Le type d'absence n'est pas valide");
        }

        // Validation du motif (optionnel)
        if (!ValidationUtil.estVide(motif) && !ValidationUtil.estLongueurValide(motif, 500)) {
            erreurs.add("Le motif ne doit pas dépasser 500 caractères");
        }

        // Si des erreurs existent, retourner au formulaire
        if (!erreurs.isEmpty()) {
            request.setAttribute("erreurs", erreurs);
            showNewForm(request, response);
            return;
        }

        try {
            Absence absence = new Absence();

            // ID Employé
            int idEmployer = Integer.parseInt(idEmpStr);
            absence.setIdEmployer(idEmployer);

            // Dates
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date dateDebut = sdf.parse(dateDebutStr);
            Date dateFin = sdf.parse(dateFinStr);

            absence.setDateDebut(dateDebut);
            absence.setDateFin(dateFin);

            // Vérification des chevauchements avant création
            boolean chevauchement = absenceDAO.checkChevauchement(idEmployer, dateDebut, dateFin, null);
            if (chevauchement) {
                erreurs.add("Cette période chevauche une absence existante pour cet employé");
                request.setAttribute("erreurs", erreurs);
                showNewForm(request, response);
                return;
            }

            // Type d'absence
            absence.setTypeAbsence(typeAbsence);

            // Motif (nettoyé pour éviter XSS)
            if (motif != null && !motif.trim().isEmpty()) {
                absence.setMotif(ValidationUtil.nettoyerTexte(motif));
            } else {
                absence.setMotif(null);
            }

            // Sauvegarder
            boolean success = absenceDAO.create(absence);

            if (success) {
                request.getSession().setAttribute("successMessage", "Absence créée avec succès");
                response.sendRedirect(request.getContextPath() + "/absences");
            } else {
                erreurs.add("Erreur lors de la création de l'absence (chevauchement possible)");
                request.setAttribute("erreurs", erreurs);
                showNewForm(request, response);
            }

        } catch (ParseException | NumberFormatException e) {
            erreurs.add("Erreur de format dans les données");
            request.setAttribute("erreurs", erreurs);
            showNewForm(request, response);
        }
    }

    /**
     * Mettre à jour une absence
     */
    private void updateAbsence(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Seul l'admin peut modifier
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/absences");
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Absence absence = absenceDAO.getById(id);

            if (absence == null) {
                request.setAttribute("error", "Absence non trouvée");
                response.sendRedirect(request.getContextPath() + "/absences");
                return;
            }

            // Récupération des paramètres
            String idEmpStr = request.getParameter("idEmployer");
            String dateDebutStr = request.getParameter("dateDebut");
            String dateFinStr = request.getParameter("dateFin");
            String typeAbsence = request.getParameter("typeAbsence");
            String motif = request.getParameter("motif");

            // Liste pour stocker les erreurs de validation
            List<String> erreurs = new ArrayList<>();

            // Validation de l'employé
            if (ValidationUtil.estVide(idEmpStr)) {
                erreurs.add("Veuillez sélectionner un employé");
            } else if (!ValidationUtil.estNombrePositif(idEmpStr)) {
                erreurs.add("L'employé sélectionné n'est pas valide");
            }

            // Validation de la date de début
            if (ValidationUtil.estVide(dateDebutStr)) {
                erreurs.add("La date de début est obligatoire");
            } else if (!ValidationUtil.estDateValide(dateDebutStr)) {
                erreurs.add("La date de début n'est pas valide ou est dans le futur");
            }

            // Validation de la date de fin
            if (ValidationUtil.estVide(dateFinStr)) {
                erreurs.add("La date de fin est obligatoire");
            } else if (!ValidationUtil.estDateValide(dateFinStr)) {
                erreurs.add("La date de fin n'est pas valide ou est dans le futur");
            }

            // Validation : Date fin >= Date début
            if (!ValidationUtil.estVide(dateDebutStr) && !ValidationUtil.estVide(dateFinStr)) {
                if (!ValidationUtil.estDateFinApresDebut(dateDebutStr, dateFinStr)) {
                    erreurs.add("La date de fin doit être après ou égale à la date de début");
                }
            }

            // Validation du type d'absence
            if (ValidationUtil.estVide(typeAbsence)) {
                erreurs.add("Le type d'absence est obligatoire");
            } else if (!typeAbsence.equals("CONGE") && !typeAbsence.equals("MALADIE")
                    && !typeAbsence.equals("ABSENCE_INJUSTIFIEE")) {
                erreurs.add("Le type d'absence n'est pas valide");
            }

            // Validation du motif (optionnel)
            if (!ValidationUtil.estVide(motif) && !ValidationUtil.estLongueurValide(motif, 500)) {
                erreurs.add("Le motif ne doit pas dépasser 500 caractères");
            }

            // Si des erreurs existent, retourner au formulaire
            if (!erreurs.isEmpty()) {
                request.setAttribute("erreurs", erreurs);
                request.setAttribute("absence", absence);
                showEditForm(request, response);
                return;
            }

            // Mise à jour des champs
            int idEmployer = Integer.parseInt(idEmpStr);
            absence.setIdEmployer(idEmployer);

            // Dates
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date dateDebut = sdf.parse(dateDebutStr);
            Date dateFin = sdf.parse(dateFinStr);

            absence.setDateDebut(dateDebut);
            absence.setDateFin(dateFin);

            // Vérification des chevauchements avant modification
            boolean chevauchement = absenceDAO.checkChevauchement(idEmployer, dateDebut, dateFin, id);
            if (chevauchement) {
                erreurs.add("Cette période chevauche une autre absence pour cet employé");
                request.setAttribute("erreurs", erreurs);
                request.setAttribute("absence", absence);
                showEditForm(request, response);
                return;
            }

            // Type et motif
            absence.setTypeAbsence(typeAbsence);

            // Motif (nettoyé pour éviter XSS)
            if (motif != null && !motif.trim().isEmpty()) {
                absence.setMotif(ValidationUtil.nettoyerTexte(motif));
            } else {
                absence.setMotif(null);
            }

            // Sauvegarder
            boolean success = absenceDAO.update(absence);

            if (success) {
                request.getSession().setAttribute("successMessage", "Absence modifiée avec succès");
                response.sendRedirect(request.getContextPath() + "/absences");
            } else {
                erreurs.add("Erreur lors de la mise à jour (chevauchement possible)");
                request.setAttribute("erreurs", erreurs);
                showEditForm(request, response);
            }

        } catch (ParseException | NumberFormatException e) {
            List<String> erreurs = new ArrayList<>();
            erreurs.add("Erreur de format dans les données");
            request.setAttribute("erreurs", erreurs);
            showEditForm(request, response);
        }
    }

    /**
     * Supprimer une absence
     */
    private void deleteAbsence(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Seul l'admin peut supprimer
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/absences");
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        absenceDAO.delete(id);
        response.sendRedirect(request.getContextPath() + "/absences");
    }

    /**
     * Rechercher les absences avec filtres
     */
    private void searchAbsences(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        Employer currentUser = (Employer) session.getAttribute("user");

        String idEmployerStr = request.getParameter("idEmployer");
        String typeAbsence = request.getParameter("typeAbsence");

        List<Absence> absences = new ArrayList<>();

        // Récupérer toutes les absences selon le rôle (comme dans listAbsences)
        List<Absence> allAbsences = new ArrayList<>();

        if ("ADMIN".equals(role)) {
            allAbsences = absenceDAO.getAll();
        } else if ("CHEF_DEPT".equals(role)) {
            if (currentUser.getIdDepartement() != null) {
                allAbsences = absenceDAO.getByDepartement(currentUser.getIdDepartement());
            }
        } else if ("CHEF_PROJET".equals(role)) {
            List<Projet> projets = projetDAO.getByChefProjet(currentUser.getId());
            if (projets != null) {
                for (Projet projet : projets) {
                    List<Absence> absencesProjet = absenceDAO.getByProjet(projet.getId());
                    if (absencesProjet != null) {
                        allAbsences.addAll(absencesProjet);
                    }
                }
            }
        } else {
            allAbsences = absenceDAO.getByEmployer(currentUser.getId());
        }

        // Appliquer les filtres
        if (allAbsences != null) {
            for (Absence abs : allAbsences) {
                boolean match = true;

                // Filtre par employé
                if (idEmployerStr != null && !idEmployerStr.trim().isEmpty()) {
                    Integer idEmployer = Integer.parseInt(idEmployerStr);
                    if (!abs.getIdEmployer().equals(idEmployer)) {
                        match = false;
                    }
                }

                // Filtre par type
                if (typeAbsence != null && !typeAbsence.trim().isEmpty()) {
                    if (!abs.getTypeAbsence().equals(typeAbsence)) {
                        match = false;
                    }
                }

                if (match) {
                    absences.add(abs);
                }
            }
        }

        // Créer une map des employés pour l'affichage
        Map<Integer, String> employersMap = new HashMap<>();
        List<Employer> allEmployers = employerDAO.getAll();
        if (allEmployers != null) {
            for (Employer emp : allEmployers) {
                employersMap.put(emp.getId(), emp.getPrenom() + " " + emp.getNom());
            }
        }

        // Indiquer si l'utilisateur peut modifier
        boolean canModify = PermissionUtil.isAdmin(request);

        request.setAttribute("absences", absences);
        request.setAttribute("employersMap", employersMap);
        request.setAttribute("canModify", canModify);
        request.getRequestDispatcher("/WEB-INF/views/absences/list.jsp").forward(request, response);
    }
}