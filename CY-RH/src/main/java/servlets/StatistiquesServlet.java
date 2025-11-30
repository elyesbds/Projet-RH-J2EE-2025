package servlets;

import dao.ProjetDAO;
import dao.DepartementDAO;
import dao.EmployerDAO;
import dao.AffectationProjetDAO;
import dao.AbsenceDAO;
import dao.FicheDePaieDAO;
import models.*;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.stream.Collectors;

import com.google.gson.Gson;

/**
 * Servlet pour afficher les statistiques avec graphiques
 * Accessible uniquement par l'ADMIN
 */
@WebServlet("/statistiques")
public class StatistiquesServlet extends HttpServlet {

    private ProjetDAO projetDAO;
    private DepartementDAO departementDAO;
    private EmployerDAO employerDAO;
    private AffectationProjetDAO affectationDAO;
    private AbsenceDAO absenceDAO;
    private FicheDePaieDAO ficheDAO;
    private Gson gson;

    @Override
    public void init() {
        projetDAO = new ProjetDAO();
        departementDAO = new DepartementDAO();
        employerDAO = new EmployerDAO();
        affectationDAO = new AffectationProjetDAO();
        absenceDAO = new AbsenceDAO();
        ficheDAO = new FicheDePaieDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Vérifier que l'utilisateur est admin
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Gérer les requêtes API pour les modales
        String action = request.getParameter("action");
        if (action != null) {
            handleApiRequest(request, response, action);
            return;
        }

        // STATS OBLIGATOIRES (cahier des charges)
        Map<String, Integer> statsEmployesByDept = getStatsEmployesByDepartement();
        List<Map<String, Object>> statsEmployesByProjet = getStatsEmployesByProjet();
        Map<String, Integer> statsGrades = getStatsGrades();

        // STATS BONUS
        Map<String, Integer> statsProjetsByEtat = getStatsProjetsByEtat();
        Map<String, Integer> statsRoles = getStatsRoles();
        Map<String, Integer> statsAbsences = getStatsAbsences();
        Map<String, Double> statsSalaires = getStatsSalairesByDept();
        List<Map<String, Object>> top5Projets = getTop5Projets();

        // Chiffres clés
        int totalEmployes = employerDAO.getAll().size();
        int totalProjets = projetDAO.getAll().size();
        int totalDepartements = departementDAO.getAll().size();
        int projetsEnCours = statsProjetsByEtat.getOrDefault("EN_COURS", 0);

        // Envoyer tout à la JSP
        request.setAttribute("statsEmployesByDept", statsEmployesByDept);
        request.setAttribute("statsEmployesByProjet", statsEmployesByProjet);
        request.setAttribute("statsGrades", statsGrades);
        request.setAttribute("statsProjetsByEtat", statsProjetsByEtat);
        request.setAttribute("statsRoles", statsRoles);
        request.setAttribute("statsAbsences", statsAbsences);
        request.setAttribute("statsSalaires", statsSalaires);
        request.setAttribute("top5Projets", top5Projets);
        request.setAttribute("totalEmployes", totalEmployes);
        request.setAttribute("totalProjets", totalProjets);
        request.setAttribute("totalDepartements", totalDepartements);
        request.setAttribute("projetsEnCours", projetsEnCours);

        request.getRequestDispatcher("/WEB-INF/views/statistiques/statistiques.jsp").forward(request, response);
    }

    /**
     * Gère les requêtes API pour les modales
     */
    private void handleApiRequest(HttpServletRequest request, HttpServletResponse response, String action)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            if ("dept-details".equals(action)) {
                String nomDept = request.getParameter("nom");
                out.print(getDepartementDetails(nomDept));
            } else if ("grade-details".equals(action)) {
                String grade = request.getParameter("grade");
                out.print(getGradeDetails(grade));
            } else if ("etat-details".equals(action)) {
                String etat = request.getParameter("etat");
                out.print(getEtatProjetDetails(etat));
            } else if ("role-details".equals(action)) {
                String role = request.getParameter("role");
                out.print(getRoleDetails(role));
            } else if ("absence-details".equals(action)) {
                String type = request.getParameter("type");
                out.print(getAbsenceDetails(type));
            } else {
                out.print("{\"error\": \"Action inconnue\"}");
            }
        } catch (Exception e) {
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }

        out.flush();
    }

    /**
     * Retourne les détails d'un département en JSON
     */
    private String getDepartementDetails(String nomDept) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> employesList = new ArrayList<>();

        Departement dept = departementDAO.getAll().stream()
                .filter(d -> d.getIntitule().equals(nomDept))
                .findFirst()
                .orElse(null);

        if (dept != null) {
            List<Employer> employes = employerDAO.getByDepartement(dept.getId());

            if (employes != null) {
                for (Employer emp : employes) {
                    Map<String, Object> empData = new HashMap<>();
                    empData.put("nom", emp.getNom());
                    empData.put("prenom", emp.getPrenom());
                    empData.put("poste", emp.getPoste());
                    empData.put("grade", emp.getGrade());
                    empData.put("salaire", emp.getSalaireBase());
                    employesList.add(empData);
                }
            }
        }

        result.put("employes", employesList);
        return gson.toJson(result);
    }

    /**
     * Retourne les détails d'un grade en JSON
     */
    private String getGradeDetails(String grade) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> employesList = new ArrayList<>();

        List<Employer> employes = employerDAO.getAll().stream()
                .filter(e -> e.getGrade().equals(grade))
                .collect(Collectors.toList());

        for (Employer emp : employes) {
            Map<String, Object> empData = new HashMap<>();
            empData.put("nom", emp.getNom());
            empData.put("prenom", emp.getPrenom());
            empData.put("poste", emp.getPoste());
            empData.put("salaire", emp.getSalaireBase());

            String deptNom = "Non défini";
            if (emp.getIdDepartement() != null) {
                Departement dept = departementDAO.getById(emp.getIdDepartement());
                if (dept != null) {
                    deptNom = dept.getIntitule();
                }
            }
            empData.put("departement", deptNom);

            employesList.add(empData);
        }

        result.put("employes", employesList);
        return gson.toJson(result);
    }

    /**
     * Retourne les détails des projets par état en JSON
     */
    private String getEtatProjetDetails(String etat) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> projetsList = new ArrayList<>();

        List<Projet> projets = projetDAO.getAll().stream()
                .filter(p -> p.getEtatProjet().equals(etat))
                .collect(Collectors.toList());

        for (Projet proj : projets) {
            Map<String, Object> projData = new HashMap<>();
            projData.put("nom", proj.getNomProjet());
            projData.put("dateDebut", proj.getDateDebut() != null ? proj.getDateDebut().toString() : "Non défini");

            String chefNom = "Non défini";
            if (proj.getChefProjet() != null) {
                Employer chef = employerDAO.getById(proj.getChefProjet());
                if (chef != null) {
                    chefNom = chef.getNom() + " " + chef.getPrenom();
                }
            }
            projData.put("chef", chefNom);

            List<AffectationProjet> affectations = affectationDAO.getEmployersByProjet(proj.getId());
            int nbEmployes = (affectations != null) ? affectations.size() : 0;
            projData.put("nbEmployes", nbEmployes);

            projetsList.add(projData);
        }

        result.put("projets", projetsList);
        return gson.toJson(result);
    }

    /**
     * Retourne les détails d'un rôle en JSON
     */
    private String getRoleDetails(String role) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> employesList = new ArrayList<>();

        List<Employer> employes = employerDAO.getAll().stream()
                .filter(e -> e.getRole().equals(role))
                .collect(Collectors.toList());

        for (Employer emp : employes) {
            Map<String, Object> empData = new HashMap<>();
            empData.put("nom", emp.getNom());
            empData.put("prenom", emp.getPrenom());
            empData.put("poste", emp.getPoste());
            empData.put("grade", emp.getGrade());

            String deptNom = "Non défini";
            if (emp.getIdDepartement() != null) {
                Departement dept = departementDAO.getById(emp.getIdDepartement());
                if (dept != null) {
                    deptNom = dept.getIntitule();
                }
            }
            empData.put("departement", deptNom);

            employesList.add(empData);
        }

        result.put("employes", employesList);
        return gson.toJson(result);
    }

    /**
     * Retourne les détails des absences par type en JSON
     */
    private String getAbsenceDetails(String type) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> absencesList = new ArrayList<>();

        List<Absence> absences = absenceDAO.getByType(type);

        if (absences != null) {
            for (Absence abs : absences) {
                Map<String, Object> absData = new HashMap<>();

                Employer emp = employerDAO.getById(abs.getIdEmployer());
                String employeNom = "Inconnu";
                if (emp != null) {
                    employeNom = emp.getNom() + " " + emp.getPrenom();
                }

                absData.put("employe", employeNom);
                absData.put("dateDebut", abs.getDateDebut() != null ? abs.getDateDebut().toString() : "N/A");
                absData.put("dateFin", abs.getDateFin() != null ? abs.getDateFin().toString() : "N/A");
                absData.put("motif", abs.getMotif() != null ? abs.getMotif() : "Non précisé");

                absencesList.add(absData);
            }
        }

        result.put("absences", absencesList);
        return gson.toJson(result);
    }

    /**
     * Nombre d'employés par département (obligatoire)
     */
    private Map<String, Integer> getStatsEmployesByDepartement() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        List<Departement> departements = departementDAO.getAll();

        if (departements != null) {
            for (Departement dept : departements) {
                int count = employerDAO.countByDepartement(dept.getId());
                stats.put(dept.getIntitule(), count);
            }
        }
        return stats;
    }

    /**
     * Nombre d'employés par projet avec grades (obligatoire)
     */
    private List<Map<String, Object>> getStatsEmployesByProjet() {
        List<Map<String, Object>> statsList = new ArrayList<>();
        List<Projet> projets = projetDAO.getAll();

        if (projets != null) {
            for (Projet projet : projets) {
                Map<String, Object> projetStats = new HashMap<>();
                projetStats.put("nomProjet", projet.getNomProjet());
                projetStats.put("etatProjet", projet.getEtatProjet());

                List<AffectationProjet> affectations = affectationDAO.getEmployersByProjet(projet.getId());

                int totalEmployes = 0;
                Map<String, Integer> gradeCount = new HashMap<>();

                if (affectations != null) {
                    totalEmployes = affectations.size();

                    for (AffectationProjet aff : affectations) {
                        Employer emp = employerDAO.getById(aff.getIdEmployer());
                        if (emp != null) {
                            String grade = emp.getGrade();
                            gradeCount.put(grade, gradeCount.getOrDefault(grade, 0) + 1);
                        }
                    }
                }

                projetStats.put("totalEmployes", totalEmployes);
                projetStats.put("gradeCount", gradeCount);
                statsList.add(projetStats);
            }
        }
        return statsList;
    }

    /**
     * Répartition globale par grades (obligatoire)
     */
    private Map<String, Integer> getStatsGrades() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        List<Employer> employes = employerDAO.getAll();

        if (employes != null) {
            for (Employer emp : employes) {
                String grade = emp.getGrade();
                stats.put(grade, stats.getOrDefault(grade, 0) + 1);
            }
        }
        return stats;
    }

    /**
     * Projets par état (bonus)
     */
    private Map<String, Integer> getStatsProjetsByEtat() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        stats.put("EN_COURS", 0);
        stats.put("TERMINE", 0);
        stats.put("ANNULE", 0);

        List<Projet> projets = projetDAO.getAll();
        if (projets != null) {
            for (Projet p : projets) {
                String etat = p.getEtatProjet();
                stats.put(etat, stats.getOrDefault(etat, 0) + 1);
            }
        }
        return stats;
    }

    /**
     * Répartition des rôles (bonus)
     */
    private Map<String, Integer> getStatsRoles() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        List<Employer> employes = employerDAO.getAll();

        if (employes != null) {
            for (Employer emp : employes) {
                String role = emp.getRole();
                stats.put(role, stats.getOrDefault(role, 0) + 1);
            }
        }
        return stats;
    }

    /**
     * Absences par type (bonus)
     */
    private Map<String, Integer> getStatsAbsences() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        List<Absence> absences = absenceDAO.getAll();

        if (absences != null) {
            for (Absence abs : absences) {
                String type = abs.getTypeAbsence();
                stats.put(type, stats.getOrDefault(type, 0) + 1);
            }
        }
        return stats;
    }

    /**
     * Masse salariale par département (bonus)
     */
    private Map<String, Double> getStatsSalairesByDept() {
        Map<String, Double> stats = new LinkedHashMap<>();
        List<Departement> departements = departementDAO.getAll();

        if (departements != null) {
            for (Departement dept : departements) {
                double total = 0.0;
                List<Employer> employes = employerDAO.getByDepartement(dept.getId());

                if (employes != null) {
                    for (Employer emp : employes) {
                        total = total + emp.getSalaireBase().doubleValue();
                    }
                }
                stats.put(dept.getIntitule(), total);
            }
        }
        return stats;
    }

    /**
     * Top 5 projets avec le plus d'employés (bonus)
     */
    private List<Map<String, Object>> getTop5Projets() {
        List<Map<String, Object>> top5 = new ArrayList<>();
        List<Projet> projets = projetDAO.getAll();

        if (projets != null) {
            List<Map<String, Object>> projetsList = new ArrayList<>();

            for (Projet projet : projets) {
                Map<String, Object> projetData = new HashMap<>();
                projetData.put("nom", projet.getNomProjet());

                List<AffectationProjet> affectations = affectationDAO.getEmployersByProjet(projet.getId());
                int nbEmployes = (affectations != null) ? affectations.size() : 0;

                projetData.put("nbEmployes", nbEmployes);
                projetsList.add(projetData);
            }

            projetsList.sort((p1, p2) ->
                    ((Integer) p2.get("nbEmployes")).compareTo((Integer) p1.get("nbEmployes"))
            );

            top5 = projetsList.stream().limit(5).collect(Collectors.toList());
        }

        return top5;
    }
}