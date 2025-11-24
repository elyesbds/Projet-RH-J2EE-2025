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
        
        try {
            Absence absence = new Absence();
            
            // ID Employé
            String idEmpStr = request.getParameter("idEmployer");
            if (idEmpStr != null && !idEmpStr.trim().isEmpty()) {
                absence.setIdEmployer(Integer.parseInt(idEmpStr));
            }
            
            // Dates
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            
            String dateDebutStr = request.getParameter("dateDebut");
            if (dateDebutStr != null && !dateDebutStr.trim().isEmpty()) {
                absence.setDateDebut(sdf.parse(dateDebutStr));
            }
            
            String dateFinStr = request.getParameter("dateFin");
            if (dateFinStr != null && !dateFinStr.trim().isEmpty()) {
                absence.setDateFin(sdf.parse(dateFinStr));
            }
            
            // Type d'absence
            absence.setTypeAbsence(request.getParameter("typeAbsence"));
            
            // Motif
            absence.setMotif(request.getParameter("motif"));
            
            // Validation basique
            if (absence.getIdEmployer() == null || absence.getDateDebut() == null || 
                absence.getDateFin() == null || absence.getTypeAbsence() == null) {
                request.setAttribute("error", "Tous les champs obligatoires doivent être remplis");
                showNewForm(request, response);
                return;
            }
            
            // Vérifier que la date de fin >= date de début
            if (absence.getDateFin().before(absence.getDateDebut())) {
                request.setAttribute("error", "La date de fin doit être après la date de début");
                showNewForm(request, response);
                return;
            }
            
            // Sauvegarder
            boolean success = absenceDAO.create(absence);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/absences");
            } else {
                request.setAttribute("error", "Erreur lors de la création de l'absence");
                showNewForm(request, response);
            }
            
        } catch (ParseException | NumberFormatException e) {
            request.setAttribute("error", "Erreur de format dans les données : " + e.getMessage());
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
            
            // Mise à jour des champs
            String idEmpStr = request.getParameter("idEmployer");
            if (idEmpStr != null && !idEmpStr.trim().isEmpty()) {
                absence.setIdEmployer(Integer.parseInt(idEmpStr));
            }
            
            // Dates
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            
            String dateDebutStr = request.getParameter("dateDebut");
            if (dateDebutStr != null && !dateDebutStr.trim().isEmpty()) {
                absence.setDateDebut(sdf.parse(dateDebutStr));
            }
            
            String dateFinStr = request.getParameter("dateFin");
            if (dateFinStr != null && !dateFinStr.trim().isEmpty()) {
                absence.setDateFin(sdf.parse(dateFinStr));
            }
            
            // Type et motif
            absence.setTypeAbsence(request.getParameter("typeAbsence"));
            absence.setMotif(request.getParameter("motif"));
            
            // Vérifier que la date de fin >= date de début
            if (absence.getDateFin().before(absence.getDateDebut())) {
                request.setAttribute("error", "La date de fin doit être après la date de début");
                showEditForm(request, response);
                return;
            }
            
            // Sauvegarder
            boolean success = absenceDAO.update(absence);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/absences");
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