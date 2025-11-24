<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestion des Fiches de Paie - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .alert-success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
            padding: 12px 20px;
            border-radius: 4px;
            margin: 15px 0;
            font-weight: bold;
        }
        .search-section {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
        }
        .search-section h2 {
            margin-top: 0;
            color: #495057;
        }
        .search-section form {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            align-items: center;
        }
        .search-section select {
            padding: 8px 12px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>Gestion des Fiches de Paie</h1>
        
        <!-- Message de succès -->
        <c:if test="${not empty successMessage}">
            <div class="alert-success">${successMessage}</div>
        </c:if>
        
		<div class="action-bar">
            <c:if test="${canModify}">
                <a href="${pageContext.request.contextPath}/fiches-paie/new" class="btn btn-primary">
                    Créer une Fiche de Paie
                </a>
            </c:if>
            
            <!-- Bouton "Mes fiches" pour Admin, Chef Dept, Chef Projet -->
            <c:if test="${canSearchEmploye}">
                <a href="${pageContext.request.contextPath}/fiches-paie?employeId=${currentUserId}" 
                   class="btn btn-secondary"
                   style="background-color: #17a2b8;">
                    Mes Fiches
                </a>
            </c:if>
        </div>
        
        <!-- Section de recherche avec FILTRES DYNAMIQUES -->
        <div class="search-section">
            <h2>Rechercher des fiches</h2>
            <form action="${pageContext.request.contextPath}/fiches-paie" method="get" id="searchForm">
                
		<!-- Filtre par Employé (Admin, Chef Dept, Chef Projet) -->
                <c:if test="${canSearchEmploye}">
                    <select name="employeId" id="employeSelect">
                        <option value="all" ${empty selectedEmployeId || selectedEmployeId == 'all' ? 'selected' : ''}>-- Tous les employés --</option>
                        <c:forEach items="${employesDisponibles}" var="emp">
                            <option value="${emp.id}" ${selectedEmployeId == emp.id.toString() ? 'selected' : ''}>
                                ${emp.prenom} ${emp.nom} (${emp.matricule})
                            </option>
                        </c:forEach>
                    </select>
                </c:if>
                
                <!-- Filtre par Année (DYNAMIQUE) -->
                <select name="annee" id="anneeSelect">
                    <option value="all">-- Toutes les années --</option>
                    <c:forEach items="${annees}" var="annee">
                        <option value="${annee}" ${selectedAnnee == annee.toString() ? 'selected' : ''}>
                            ${annee}
                        </option>
                    </c:forEach>
                </select>
                
                <!-- Filtre par Mois (DYNAMIQUE) -->
                <select name="mois" id="moisSelect">
                    <option value="all">-- Tous les mois --</option>
                    <c:forEach items="${moisDisponibles}" var="mois">
                        <option value="${mois}" ${selectedMois == mois.toString() ? 'selected' : ''}>
                            <c:choose>
                                <c:when test="${mois == 1}">Janvier</c:when>
                                <c:when test="${mois == 2}">Février</c:when>
                                <c:when test="${mois == 3}">Mars</c:when>
                                <c:when test="${mois == 4}">Avril</c:when>
                                <c:when test="${mois == 5}">Mai</c:when>
                                <c:when test="${mois == 6}">Juin</c:when>
                                <c:when test="${mois == 7}">Juillet</c:when>
                                <c:when test="${mois == 8}">Août</c:when>
                                <c:when test="${mois == 9}">Septembre</c:when>
                                <c:when test="${mois == 10}">Octobre</c:when>
                                <c:when test="${mois == 11}">Novembre</c:when>
                                <c:when test="${mois == 12}">Décembre</c:when>
                            </c:choose>
                        </option>
                    </c:forEach>
                </select>
                
                <button type="submit" class="btn btn-primary">🔍 Rechercher</button>
                
                <!-- Bouton pour réinitialiser -->
                <c:if test="${not empty selectedEmployeId || not empty selectedAnnee || not empty selectedMois}">
                    <a href="${pageContext.request.contextPath}/fiches-paie" class="btn btn-secondary">❌ Réinitialiser</a>
                </c:if>
            </form>
        </div>
        
        <!-- Message de recherche active -->
        <c:if test="${not empty selectedEmployeId || not empty selectedAnnee || not empty selectedMois}">
            <div class="alert alert-info" style="background-color: #d1ecf1; color: #0c5460; padding: 12px; border-radius: 4px; margin: 15px 0;">
                Résultats filtrés :
                <c:if test="${not empty selectedEmployeId && selectedEmployeId != 'all'}">
                    <strong>Employé: ${employersMap[Integer.parseInt(selectedEmployeId)].prenom} ${employersMap[Integer.parseInt(selectedEmployeId)].nom}</strong>
                </c:if>
                <c:if test="${not empty selectedAnnee && selectedAnnee != 'all'}">
                    <strong>Année: ${selectedAnnee}</strong>
                </c:if>
                <c:if test="${not empty selectedMois && selectedMois != 'all'}">
                    <strong>
                        Mois:
                        <c:choose>
                            <c:when test="${selectedMois == '1'}">Janvier</c:when>
                            <c:when test="${selectedMois == '2'}">Février</c:when>
                            <c:when test="${selectedMois == '3'}">Mars</c:when>
                            <c:when test="${selectedMois == '4'}">Avril</c:when>
                            <c:when test="${selectedMois == '5'}">Mai</c:when>
                            <c:when test="${selectedMois == '6'}">Juin</c:when>
                            <c:when test="${selectedMois == '7'}">Juillet</c:when>
                            <c:when test="${selectedMois == '8'}">Août</c:when>
                            <c:when test="${selectedMois == '9'}">Septembre</c:when>
                            <c:when test="${selectedMois == '10'}">Octobre</c:when>
                            <c:when test="${selectedMois == '11'}">Novembre</c:when>
                            <c:when test="${selectedMois == '12'}">Décembre</c:when>
                        </c:choose>
                    </strong>
                </c:if>
            </div>
        </c:if>
        
        <!-- Tableau des fiches de paie -->
        <table class="employee-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Employé</th>
                    <th>Période</th>
                    <th style="text-align: right;">Salaire Base</th>
                    <th style="text-align: right;">Primes</th>
                    <th style="text-align: right;">Déductions</th>
                    <th style="text-align: right;">Net à Payer</th>
                    <th>Date Génération</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty fiches}">
                        <tr>
                            <td colspan="9" class="no-data">
                                Aucune fiche de paie ne correspond à votre recherche.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${fiches}" var="fiche">
                            <tr>
                                <!-- ID -->
                                <td>${fiche.id}</td>
                                
                                <!-- Employé -->
                                <td>
                                    <strong>${employersMap[fiche.idEmployer].prenom} ${employersMap[fiche.idEmployer].nom}</strong>
                                    <br>
                                    <small style="color: #6c757d;">${employersMap[fiche.idEmployer].matricule}</small>
                                </td>
                                
                                <!-- Période -->
                                <td>
                                    <strong>
                                        <c:choose>
                                            <c:when test="${fiche.mois == 1}">Janvier</c:when>
                                            <c:when test="${fiche.mois == 2}">Février</c:when>
                                            <c:when test="${fiche.mois == 3}">Mars</c:when>
                                            <c:when test="${fiche.mois == 4}">Avril</c:when>
                                            <c:when test="${fiche.mois == 5}">Mai</c:when>
                                            <c:when test="${fiche.mois == 6}">Juin</c:when>
                                            <c:when test="${fiche.mois == 7}">Juillet</c:when>
                                            <c:when test="${fiche.mois == 8}">Août</c:when>
                                            <c:when test="${fiche.mois == 9}">Septembre</c:when>
                                            <c:when test="${fiche.mois == 10}">Octobre</c:when>
                                            <c:when test="${fiche.mois == 11}">Novembre</c:when>
                                            <c:when test="${fiche.mois == 12}">Décembre</c:when>
                                        </c:choose>
                                        ${fiche.annee}
                                    </strong>
                                </td>
                                
                                <!-- Salaire Base -->
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${fiche.salaireBase}" pattern="#,##0.00"/> €
                                </td>
                                
                                <!-- Primes -->
                                <td style="text-align: right; color: #28a745;">
                                    +<fmt:formatNumber value="${fiche.primes}" pattern="#,##0.00"/> €
                                </td>
                                
                                <!-- Déductions -->
                                <td style="text-align: right; color: #dc3545;">
                                    -<fmt:formatNumber value="${fiche.deductions}" pattern="#,##0.00"/> €
                                </td>
                                
                                <!-- Net à Payer -->
                                <td style="text-align: right;">
                                    <strong style="color: #28a745; font-size: 16px;">
                                        <fmt:formatNumber value="${fiche.netAPayer}" pattern="#,##0.00"/> €
                                    </strong>
                                </td>
                                
                                <!-- Date Génération -->
                                <td>
                                    <fmt:formatDate value="${fiche.dateGeneration}" pattern="dd/MM/yyyy"/>
                                </td>
                                
                                <!-- Actions -->
                                <td class="actions">
                                    <!-- Bouton Voir (tout le monde) -->
                                    <a href="${pageContext.request.contextPath}/fiches-paie/voir?id=${fiche.id}" 
                                       class="btn-view"
                                       title="Voir">
                                        👁️
                                    </a>
                                    
                                                                    
                                    <!-- Bouton Ajouter Prime (CHEF_DEPT et CHEF_PROJET, sauf leurs propres fiches) -->
                                    <c:if test="${canAddPrime && fiche.idEmployer != currentUserId}">
                                        <a href="${pageContext.request.contextPath}/fiches-paie/ajouter-prime?id=${fiche.id}" 
                                           class="btn-edit"
                                           title="Ajouter Prime/Déduction"
                                           style="background-color: #ffc107;">
                                            💰
                                        </a>
                                    </c:if>
                                    
                                    <!-- Bouton Modifier (seulement ADMIN) -->
                                    <c:if test="${canModify}">
                                        <a href="${pageContext.request.contextPath}/fiches-paie/edit?id=${fiche.id}" 
                                           class="btn-edit"
                                           title="Modifier">
                                            ✏️
                                        </a>
                                    </c:if>
                                    
                                    <!-- Bouton Supprimer (seulement ADMIN) -->
                                    <c:if test="${canModify}">
                                        <a href="${pageContext.request.contextPath}/fiches-paie/delete?id=${fiche.id}" 
                                           class="btn-delete"
                                           title="Supprimer"
                                           onclick="return confirm('Êtes-vous sûr de vouloir supprimer cette fiche de paie ?')">
                                            🗑️
                                        </a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        
        <!-- Statistiques -->
        <c:if test="${not empty fiches}">
            <div style="margin-top: 20px; text-align: center; color: #6c757d;">
                <p>Total : <strong>${fiches.size()}</strong> fiche(s) de paie affichée(s)</p>
            </div>
        </c:if>
    </div>
    
</body>
</html>