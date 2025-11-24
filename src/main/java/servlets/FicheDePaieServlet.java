package servlets;

import dao.FicheDePaieDAO;
import dao.EmployerDAO;
import dao.DepartementDAO;
import dao.ProjetDAO;
import dao.AffectationProjetDAO;
import models.FicheDePaie;
import models.Employer;
import models.Departement;
import models.Projet;
import models.AffectationProjet;
import utils.PermissionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.Date;
import java.util.ArrayList;
import dao.AbsenceDAO;
import models.Absence;
import java.util.Calendar;
/**
 * Servlet pour gérer toutes les opérations sur les fiches de paie
 */
@WebServlet("/fiches-paie/*")
public class FicheDePaieServlet extends HttpServlet {
    
    private FicheDePaieDAO ficheDAO;
    private EmployerDAO employerDAO;
    private DepartementDAO departementDAO;
    private ProjetDAO projetDAO;
    private AffectationProjetDAO affectationDAO;
    private AbsenceDAO absenceDAO;
    
    @Override
    public void init() {
        ficheDAO = new FicheDePaieDAO();
        employerDAO = new EmployerDAO();
        departementDAO = new DepartementDAO();
        projetDAO = new ProjetDAO();
        affectationDAO = new AffectationProjetDAO();
        absenceDAO = new AbsenceDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action == null || action.equals("/")) {
            // Lister toutes les fiches (avec recherche possible)
            listFiches(request, response);
        } else if (action.equals("/new")) {
            // Afficher le formulaire de création
            showNewForm(request, response);
        } else if (action.equals("/edit")) {
            // Afficher le formulaire de modification
            showEditForm(request, response);
        } else if (action.equals("/delete")) {
            // Supprimer une fiche
            deleteFiche(request, response);
        } else if (action.equals("/voir")) {
            // Voir les détails d'une fiche
            showViewForm(request, response);
        } else if (action.equals("/ajouter-prime")) {
            // Afficher le formulaire pour ajouter une prime
            showAjouterPrimeForm(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getPathInfo();
        
        if (action != null && action.equals("/update")) {
            // Mettre à jour une fiche
            updateFiche(request, response);
        } else if (action != null && action.equals("/ajouter-prime")) {
            // Ajouter une prime/déduction
            ajouterPrime(request, response);
        } else {
            // Créer une nouvelle fiche
            createFiche(request, response);
        }
    }
    
    /**
     * Lister les fiches de paie avec recherche multicritères
     * - EMPLOYE : voit seulement SES fiches
     * - CHEF_PROJET : voit les fiches de SES membres
     * - CHEF_DEPT : voit les fiches de SON département
     * - ADMIN : voit TOUTES les fiches
     */
    private void listFiches(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Employer user = PermissionUtil.getLoggedUser(request);
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Récupérer les paramètres de recherche
        String employeIdStr = request.getParameter("employeId");
        String anneeStr = request.getParameter("annee");
        String moisStr = request.getParameter("mois");
        
        Integer employeId = null;
        Integer annee = null;
        Integer mois = null;
        
        // Parser les paramètres (ignorer "all")
        if (employeIdStr != null && !employeIdStr.trim().isEmpty() && !employeIdStr.equals("all")) {
            try {
                employeId = Integer.parseInt(employeIdStr);
            } catch (NumberFormatException e) {
                // Ignorer
            }
        }
        
        if (anneeStr != null && !anneeStr.trim().isEmpty() && !anneeStr.equals("all")) {
            try {
                annee = Integer.parseInt(anneeStr);
            } catch (NumberFormatException e) {
                // Ignorer
            }
        }
        
        if (moisStr != null && !moisStr.trim().isEmpty() && !moisStr.equals("all")) {
            try {
                mois = Integer.parseInt(moisStr);
            } catch (NumberFormatException e) {
                // Ignorer
            }
        }
        
        List<FicheDePaie> fiches = null;
        List<Employer> employesDisponibles = new ArrayList<>();
        
        // ADMIN : peut rechercher sur tous les employés
        if (PermissionUtil.isAdmin(request)) {
            fiches = ficheDAO.searchFiches(employeId, annee, mois);
            employesDisponibles = employerDAO.getAll();
        } 
     // CHEF DEPT : peut rechercher dans son département
        else if (PermissionUtil.isChefDept(request)) {
            if (user.getIdDepartement() != null) {
                fiches = ficheDAO.searchFichesByDepartement(user.getIdDepartement(), employeId, annee, mois);
                // Récupérer les employés du département
                employesDisponibles = employerDAO.getByDepartement(user.getIdDepartement());
            }
        } 
     // CHEF PROJET : peut rechercher parmi ses membres + LUI-MÊME
        else if (PermissionUtil.isChefProjet(request)) {
            // Récupérer les employés affectés aux projets du chef
            Set<Integer> employeIds = getEmployeIdsForChefProjet(user.getId());
            
            // IMPORTANT : Ajouter le chef lui-même dans la liste
            employeIds.add(user.getId());
            
            // Si un employé est sélectionné, vérifier qu'il fait partie des membres (ou que c'est le chef lui-même)
            if (employeId != null && !employeIds.contains(employeId)) {
                employeId = null; // Ignorer la recherche si l'employé n'est pas autorisé
            }
            
            // Rechercher les fiches des membres du projet + chef
            fiches = new ArrayList<>();
            if (employeId != null) {
                // Recherche spécifique sur un employé
                List<FicheDePaie> fichesEmploye = ficheDAO.searchFiches(employeId, annee, mois);
                if (fichesEmploye != null) {
                    fiches.addAll(fichesEmploye);
                }
            } else {
                // Recherche sur tous les membres + chef
                for (Integer empId : employeIds) {
                    List<FicheDePaie> fichesEmploye = ficheDAO.searchFiches(empId, annee, mois);
                    if (fichesEmploye != null) {
                        fiches.addAll(fichesEmploye);
                    }
                }
            }
            
            // Récupérer la liste des employés pour le filtre
            for (Integer empId : employeIds) {
                Employer emp = employerDAO.getById(empId);
                if (emp != null) {
                    employesDisponibles.add(emp);
                }
            }
        }
        // EMPLOYE : voit uniquement SES fiches
        else {
            employeId = user.getId(); // Forcer la recherche sur lui-même
            fiches = ficheDAO.searchFiches(employeId, annee, mois);
        }
        
        // Créer le map des employés pour l'affichage
        Map<Integer, Employer> employersMap = new HashMap<>();
        List<Employer> allEmployers = employerDAO.getAll();
        if (allEmployers != null) {
            for (Employer emp : allEmployers) {
                employersMap.put(emp.getId(), emp);
            }
        }
        
        // Récupérer les filtres dynamiques INDÉPENDANTS (années et mois)
        List<Integer> annees = new ArrayList<>();
        List<Integer> moisDisponibles = new ArrayList<>();
        
        // Récupérer TOUTES les années disponibles (peu importe les autres filtres)
        if (PermissionUtil.isAdmin(request)) {
            annees = ficheDAO.getAllAnnees();
        } else if (PermissionUtil.isChefDept(request) && user.getIdDepartement() != null) {
            List<FicheDePaie> fichesDept = ficheDAO.getByDepartement(user.getIdDepartement());
            Set<Integer> anneesSet = new HashSet<>();
            if (fichesDept != null) {
                for (FicheDePaie f : fichesDept) {
                    anneesSet.add(f.getAnnee());
                }
            }
            annees = new ArrayList<>(anneesSet);
            annees.sort((a, b) -> b.compareTo(a));
        } else if (PermissionUtil.isChefProjet(request)) {
            List<FicheDePaie> fichesChef = getFichesForChefProjet(user.getId());
            Set<Integer> anneesSet = new HashSet<>();
            if (fichesChef != null) {
                for (FicheDePaie f : fichesChef) {
                    anneesSet.add(f.getAnnee());
                }
            }
            annees = new ArrayList<>(anneesSet);
            annees.sort((a, b) -> b.compareTo(a));
        } else {
            annees = ficheDAO.getAnneesByEmployer(user.getId());
        }
        
        // Récupérer TOUS les mois disponibles (INDÉPENDANT de l'année)
        Set<Integer> moisSet = new HashSet<>();
        if (fiches != null) {
            for (FicheDePaie f : fiches) {
                moisSet.add(f.getMois());
            }
        }
        moisDisponibles = new ArrayList<>(moisSet);
        moisDisponibles.sort(Integer::compareTo);
        
        // Permissions
        boolean canModify = PermissionUtil.isAdmin(request);
        boolean canAddPrime = PermissionUtil.isAdmin(request) || 
                              PermissionUtil.isChefDept(request) || 
                              PermissionUtil.isChefProjet(request);
        boolean canSearchEmploye = PermissionUtil.isAdmin(request) || 
                                    PermissionUtil.isChefDept(request) || 
                                    PermissionUtil.isChefProjet(request);
        
        // Attributs pour la JSP
        request.setAttribute("fiches", fiches);
        request.setAttribute("employersMap", employersMap);
        request.setAttribute("annees", annees);
        request.setAttribute("moisDisponibles", moisDisponibles);
        request.setAttribute("employesDisponibles", employesDisponibles);
        request.setAttribute("canModify", canModify);
        request.setAttribute("canAddPrime", canAddPrime);
        request.setAttribute("canSearchEmploye", canSearchEmploye);
        request.setAttribute("currentUserId", user.getId());
        
        // Conserver les valeurs de recherche
        request.setAttribute("selectedEmployeId", employeIdStr);
        request.setAttribute("selectedAnnee", anneeStr);
        request.setAttribute("selectedMois", moisStr);
        
        // Message de succès
        HttpSession session = request.getSession();
        String successMessage = (String) session.getAttribute("successMessage");
        if (successMessage != null) {
            request.setAttribute("successMessage", successMessage);
            session.removeAttribute("successMessage");
        }
        
        request.getRequestDispatcher("/WEB-INF/views/fiches-paie/list.jsp").forward(request, response);
    }
    
    /**
     * Récupérer les IDs des employés affectés aux projets d'un chef de projet
     */
    private Set<Integer> getEmployeIdsForChefProjet(Integer chefProjetId) {
        Set<Integer> employeIds = new HashSet<>();
        
        // Récupérer les projets où l'utilisateur est chef
        List<Projet> mesProjets = projetDAO.getByChefProjet(chefProjetId);
        
        if (mesProjets != null) {
            for (Projet projet : mesProjets) {
                // Récupérer les affectations pour chaque projet
                List<AffectationProjet> affectations = affectationDAO.getEmployersByProjet(projet.getId());
                if (affectations != null) {
                    for (AffectationProjet aff : affectations) {
                        employeIds.add(aff.getIdEmployer());
                    }
                }
            }
        }
        
        return employeIds;
    }
    
    /**
     * Récupérer les fiches de paie pour un chef de projet
     * (Toutes les fiches de ses membres de projets + SES PROPRES FICHES)
     */
    private List<FicheDePaie> getFichesForChefProjet(Integer chefProjetId) {
        List<FicheDePaie> fichesChefProjet = new ArrayList<>();
        
        Set<Integer> employeIds = getEmployeIdsForChefProjet(chefProjetId);
        
        // IMPORTANT : Ajouter le chef lui-même dans la liste
        employeIds.add(chefProjetId);
        
        // Récupérer les fiches de chaque employé (y compris le chef)
        for (Integer employeId : employeIds) {
            List<FicheDePaie> fichesEmploye = ficheDAO.getByEmployer(employeId);
            if (fichesEmploye != null) {
                fichesChefProjet.addAll(fichesEmploye);
            }
        }
        
        return fichesChefProjet;
    }
    
    /**
     * Vérifier si une fiche est dans la liste des fiches autorisées
     */
    private boolean isFicheInList(FicheDePaie fiche, List<FicheDePaie> fichesAutorisees) {
        if (fiche == null || fichesAutorisees == null) {
            return false;
        }
        
        for (FicheDePaie f : fichesAutorisees) {
            if (f.getId().equals(fiche.getId())) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Vérifier si un chef peut modifier une fiche
     */
    private boolean canChefModifyFiche(HttpServletRequest request, FicheDePaie fiche) {
        Employer user = PermissionUtil.getLoggedUser(request);
        
        if (user == null || fiche == null) {
            return false;
        }
        
        // Un chef ne peut pas modifier sa propre fiche
        if (fiche.getIdEmployer().equals(user.getId())) {
            return false;
        }
        
        // Chef de département : peut modifier les fiches de son département
        if (PermissionUtil.isChefDept(request)) {
            Employer employer = employerDAO.getById(fiche.getIdEmployer());
            return employer != null && employer.getIdDepartement() != null && 
                   employer.getIdDepartement().equals(user.getIdDepartement());
        }
        
        // Chef de projet : peut modifier les fiches de ses membres
        if (PermissionUtil.isChefProjet(request)) {
            List<FicheDePaie> fichesAutorisees = getFichesForChefProjet(user.getId());
            return isFicheInList(fiche, fichesAutorisees);
        }
        
        return false;
    }
    
    /**
     * Afficher le formulaire de création de fiche
     * (Admin uniquement)
     */
    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }
        
        List<Employer> employers = employerDAO.getAll();
        request.setAttribute("employers", employers);
        request.getRequestDispatcher("/WEB-INF/views/fiches-paie/form.jsp").forward(request, response);
    }
    
    /**
     * Afficher le formulaire de modification
     * (Admin uniquement)
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        FicheDePaie fiche = ficheDAO.getById(id);
        
        if (fiche == null) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }
        
        List<Employer> employers = employerDAO.getAll();
        Employer employer = employerDAO.getById(fiche.getIdEmployer());
        
        request.setAttribute("fiche", fiche);
        request.setAttribute("employers", employers);
        request.setAttribute("employer", employer);
        request.getRequestDispatcher("/WEB-INF/views/fiches-paie/form.jsp").forward(request, response);
    }
    
    /**
     * Afficher les détails d'une fiche
     */
    private void showViewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Employer user = PermissionUtil.getLoggedUser(request);
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        FicheDePaie fiche = ficheDAO.getById(id);
        
        if (fiche == null) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }
        
        // Vérifier les permissions d'accès
        if (!PermissionUtil.isAdmin(request)) {
            
            if (PermissionUtil.isChefDept(request)) {
                Employer employer = employerDAO.getById(fiche.getIdEmployer());
                if (employer == null || !employer.getIdDepartement().equals(user.getIdDepartement())) {
                    response.sendRedirect(request.getContextPath() + "/fiches-paie");
                    return;
                }
                
            } else if (PermissionUtil.isChefProjet(request)) {
                List<FicheDePaie> fichesAutorisees = getFichesForChefProjet(user.getId());
                if (!isFicheInList(fiche, fichesAutorisees)) {
                    response.sendRedirect(request.getContextPath() + "/fiches-paie");
                    return;
                }
                
            } else {
                if (!fiche.getIdEmployer().equals(user.getId())) {
                    response.sendRedirect(request.getContextPath() + "/fiches-paie");
                    return;
                }
            }
        }
        
        Employer employer = employerDAO.getById(fiche.getIdEmployer());
        Departement departement = null;
        if (employer != null && employer.getIdDepartement() != null) {
            departement = departementDAO.getById(employer.getIdDepartement());
        }
        
        List<Absence> absencesMois = getAbsencesDuMois(fiche);
        
        request.setAttribute("fiche", fiche);
        request.setAttribute("employer", employer);
        request.setAttribute("departement", departement);
        request.setAttribute("absencesMois", absencesMois);
        request.getRequestDispatcher("/WEB-INF/views/fiches-paie/voir.jsp").forward(request, response);
    }
    
    /**
     * Créer une nouvelle fiche de paie
     * (Admin uniquement)
     */
    private void createFiche(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }

        try {
            int idEmployer = Integer.parseInt(request.getParameter("idEmployer"));
            int mois = Integer.parseInt(request.getParameter("mois"));
            int annee = Integer.parseInt(request.getParameter("annee"));
            BigDecimal salaireBase = new BigDecimal(request.getParameter("salaireBase"));

            // Récupérer les primes
            String primesStr = request.getParameter("primes");
            BigDecimal primes = (primesStr != null && !primesStr.trim().isEmpty())
                ? new BigDecimal(primesStr) : BigDecimal.ZERO;

            // Récupérer les déductions manuelles
            String deductionsStr = request.getParameter("deductions");
            BigDecimal deductionsManuelles = (deductionsStr != null && !deductionsStr.trim().isEmpty())
                ? new BigDecimal(deductionsStr) : BigDecimal.ZERO;

            // ✅ VALIDATION : Bloquer les valeurs négatives
            if (primes.compareTo(BigDecimal.ZERO) < 0) {
                request.setAttribute("error", "❌ Les primes ne peuvent pas être négatives !");
                showNewForm(request, response);
                return;
            }

            if (deductionsManuelles.compareTo(BigDecimal.ZERO) < 0) {
                request.setAttribute("error", "❌ Les déductions ne peuvent pas être négatives !");
                showNewForm(request, response);
                return;
            }

            // Calculer les déductions des absences injustifiées
            BigDecimal deductionsAbsences = calculerDeductionsAbsences(idEmployer, mois, annee, salaireBase);

            // Total des déductions
            BigDecimal deductionsTotal = deductionsAbsences.add(deductionsManuelles);

            // Créer la fiche
            FicheDePaie fiche = new FicheDePaie();
            fiche.setIdEmployer(idEmployer);
            fiche.setMois(mois);
            fiche.setAnnee(annee);
            fiche.setSalaireBase(salaireBase);
            fiche.setPrimes(primes);
            fiche.setDeductions(deductionsTotal);
            fiche.setDateGeneration(new Date());

            // Calculer le net à payer
            fiche.calculerNetAPayer();

            boolean success = ficheDAO.create(fiche);

            HttpSession session = request.getSession();
            if (success) {
                session.setAttribute("successMessage", "Fiche de paie créée avec succès !");
                response.sendRedirect(request.getContextPath() + "/fiches-paie");
            } else {
                request.setAttribute("error", "Erreur : Une fiche existe déjà pour ce mois");
                showNewForm(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Erreur de format dans les données");
            showNewForm(request, response);
        }
    }
    
    /**
     * Mettre à jour une fiche de paie
     * (Admin uniquement)
     */
    private void updateFiche(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            FicheDePaie fiche = ficheDAO.getById(id);
            
            if (fiche == null) {
                response.sendRedirect(request.getContextPath() + "/fiches-paie");
                return;
            }
            
            // Mettre à jour les données
            fiche.setSalaireBase(new BigDecimal(request.getParameter("salaireBase")));
            
            String primesStr = request.getParameter("primes");
            String deductionsStr = request.getParameter("deductions");
            
            BigDecimal primes = (primesStr != null && !primesStr.trim().isEmpty()) 
                ? new BigDecimal(primesStr) : BigDecimal.ZERO;
            BigDecimal deductions = (deductionsStr != null && !deductionsStr.trim().isEmpty()) 
                ? new BigDecimal(deductionsStr) : BigDecimal.ZERO;
            
            if (primes.compareTo(BigDecimal.ZERO) < 0) {
                request.setAttribute("error", "❌ Les primes ne peuvent pas être négatives !");
                showEditForm(request, response);
                return;
            }

            if (deductions.compareTo(BigDecimal.ZERO) < 0) {
                request.setAttribute("error", "❌ Les déductions ne peuvent pas être négatives !");
                showEditForm(request, response);
                return;
            }
            
            fiche.setPrimes(primes);
            fiche.setDeductions(deductions);
            
            // Recalculer le net à payer
            fiche.calculerNetAPayer();
            
            boolean success = ficheDAO.update(fiche);
            
            HttpSession session = request.getSession();
            if (success) {
                session.setAttribute("successMessage", "✅ Fiche de paie modifiée avec succès !");
                response.sendRedirect(request.getContextPath() + "/fiches-paie");
            } else {
                request.setAttribute("error", "❌ Erreur lors de la modification");
                showEditForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "❌ Erreur de format dans les données");
            showEditForm(request, response);
        }
    }
    
    /**
     * Afficher le formulaire pour ajouter une prime/déduction
     * (Admin, Chef dept, Chef projet)
     */
    private void showAjouterPrimeForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Employer user = PermissionUtil.getLoggedUser(request);
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        FicheDePaie fiche = ficheDAO.getById(id);
        
        if (fiche == null) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }
        
        // Vérifier les permissions
        boolean canModify = PermissionUtil.isAdmin(request) || canChefModifyFiche(request, fiche);
        
        if (!canModify) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }
        
        Employer employer = employerDAO.getById(fiche.getIdEmployer());
        
        request.setAttribute("fiche", fiche);
        request.setAttribute("employer", employer);
        request.getRequestDispatcher("/WEB-INF/views/fiches-paie/ajouter-prime.jsp").forward(request, response);
    }
    
    /**
     * Ajouter une prime ou déduction à une fiche
     * (Admin, Chef dept, Chef projet)
     */
    private void ajouterPrime(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Employer user = PermissionUtil.getLoggedUser(request);
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            FicheDePaie fiche = ficheDAO.getById(id);
            
            if (fiche == null) {
                response.sendRedirect(request.getContextPath() + "/fiches-paie");
                return;
            }
            
            // Vérifier les permissions
            boolean canModify = PermissionUtil.isAdmin(request) || canChefModifyFiche(request, fiche);
            
            if (!canModify) {
                response.sendRedirect(request.getContextPath() + "/fiches-paie");
                return;
            }
            
            String primesStr = request.getParameter("primes");
            String deductionsStr = request.getParameter("deductions");
            
            BigDecimal primes = (primesStr != null && !primesStr.trim().isEmpty()) 
                ? new BigDecimal(primesStr) : BigDecimal.ZERO;
            BigDecimal deductions = (deductionsStr != null && !deductionsStr.trim().isEmpty()) 
                ? new BigDecimal(deductionsStr) : BigDecimal.ZERO;
            
            if (primes.compareTo(BigDecimal.ZERO) < 0) {
                request.setAttribute("error", "Les primes ne peuvent pas être négatives !");
                showAjouterPrimeForm(request, response);
                return;
            }

            if (deductions.compareTo(BigDecimal.ZERO) < 0) {
                request.setAttribute("error", "Les déductions ne peuvent pas être négatives !");
                showAjouterPrimeForm(request, response);
                return;
            }
            
            fiche.setPrimes(primes);
            fiche.setDeductions(deductions);
            
            // Recalculer le net à payer
            fiche.calculerNetAPayer();
            
            boolean success = ficheDAO.update(fiche);
            
            if (success) {
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "✅ Prime/Déduction ajoutée avec succès !");
                response.sendRedirect(request.getContextPath() + "/fiches-paie");
            } else {
                request.setAttribute("error", "❌ Erreur lors de l'ajout de prime");
                showAjouterPrimeForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "❌ Erreur de format dans les données");
            showAjouterPrimeForm(request, response);
        }
    }
    
    /**
     * Supprimer une fiche de paie
     * (Admin uniquement)
     */
    private void deleteFiche(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        if (!PermissionUtil.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/fiches-paie");
            return;
        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = ficheDAO.delete(id);
        
        HttpSession session = request.getSession();
        if (success) {
            session.setAttribute("successMessage", "✅ Fiche de paie supprimée avec succès !");
        } else {
            session.setAttribute("successMessage", "❌ Erreur lors de la suppression");
        }
        
        response.sendRedirect(request.getContextPath() + "/fiches-paie");
    }
    
  
    /**
     * Calculer les déductions basées sur les absences injustifiées du mois
     */
    private BigDecimal calculerDeductionsAbsences(Integer idEmployer, Integer mois, Integer annee, BigDecimal salaireBase) {
        try {
            // Créer les dates de début et fin du mois
            Calendar cal = Calendar.getInstance();
            cal.set(annee, mois - 1, 1);
            Date dateDebut = cal.getTime();

            cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
            Date dateFin = cal.getTime();

            // Récupérer les absences du mois
            List<Absence> absences = absenceDAO.getByEmployerAndPeriode(idEmployer, dateDebut, dateFin);

            if (absences == null || absences.isEmpty()) {
                return BigDecimal.ZERO;
            }

            int joursAbsence = 0;

            // Compter uniquement les absences injustifiées
            for (Absence abs : absences) {
                if ("ABSENCE_INJUSTIFIEE".equals(abs.getTypeAbsence())) {
                    // Calculer le nombre de jours d'absence dans ce mois
                    Date debut = abs.getDateDebut().before(dateDebut) ? dateDebut : abs.getDateDebut();
                    Date fin = abs.getDateFin().after(dateFin) ? dateFin : abs.getDateFin();

                    long diff = fin.getTime() - debut.getTime();
                    int jours = (int) (diff / (1000 * 60 * 60 * 24)) + 1;
                    joursAbsence += jours;
                }
            }

            // Calculer la déduction : (salaire / 30) * jours d'absence
            if (joursAbsence > 0) {
                BigDecimal salaireParJour = new BigDecimal("200.00");
                return salaireParJour.multiply(new BigDecimal(joursAbsence));
            }

            return BigDecimal.ZERO;

        } catch (Exception e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }
  
    /**
     * Récupérer les absences du mois pour une fiche
     */
    private List<Absence> getAbsencesDuMois(FicheDePaie fiche) {
        try {
            // Créer les dates du mois
            Calendar cal = Calendar.getInstance();
            cal.set(fiche.getAnnee(), fiche.getMois() - 1, 1);
            Date dateDebut = cal.getTime();
            
            cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
            Date dateFin = cal.getTime();
            
            // Récupérer les absences du mois
            return absenceDAO.getByEmployerAndPeriode(fiche.getIdEmployer(), dateDebut, dateFin);
            
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}