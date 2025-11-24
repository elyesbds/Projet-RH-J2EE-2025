<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Liste des Employés - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>

    <div class="container container-employees">
    <h1>Liste des Employés</h1>
        
        <!-- Barre d'actions -->
        <div class="action-bar">
            <c:if test="${canModify}">
                <a href="${pageContext.request.contextPath}/employees/new" class="btn btn-primary">
                    Ajouter un employé
                </a>
            </c:if>
        </div>
        
        <!-- Section de recherche -->
        <div class="search-section">
            <h2>Rechercher un employé</h2>
            <form action="${pageContext.request.contextPath}/employees/search" method="get">
                <select name="type" required>
                    <option value="">-- Type de recherche --</option>
                    <option value="nom" ${searchType == 'nom' ? 'selected' : ''}>Nom/Prénom</option>
                    <option value="matricule" ${searchType == 'matricule' ? 'selected' : ''}>Matricule</option>
                    <option value="grade" ${searchType == 'grade' ? 'selected' : ''}>Grade</option>
                    <option value="poste" ${searchType == 'poste' ? 'selected' : ''}>Poste</option>
                    <option value="departement" ${searchType == 'departement' ? 'selected' : ''}>Département</option>
                </select>
                
                <input type="text" name="value" placeholder="Valeur à rechercher..." value="${searchValue}" required>
                
                <button type="submit" class="btn btn-primary">Rechercher</button>
                
                <c:if test="${not empty searchValue}">
                    <a href="${pageContext.request.contextPath}/employees" class="btn btn-secondary">Réinitialiser</a>
                </c:if>
            </form>
        </div>
        
        <!-- Filtres rapides -->
        <div class="filters-section">
            <h2>Filtres rapides</h2>
            
            <div class="filter-buttons">
                <!-- Filtres par grade -->
                <c:if test="${not empty grades}">
                    <div class="filter-group">
                        <strong>Par grade :</strong>
                        <c:forEach var="grade" items="${grades}">
                            <a href="${pageContext.request.contextPath}/employees/search?type=grade&value=${grade}" class="filter-btn">
                                ${grade}
                            </a>
                        </c:forEach>
                    </div>
                </c:if>
                
                <!-- Filtres par poste -->
                <c:if test="${not empty postes}">
                    <div class="filter-group">
                        <strong>Par poste :</strong>
                        <c:forEach var="poste" items="${postes}">
                            <a href="${pageContext.request.contextPath}/employees/search?type=poste&value=${poste}" class="filter-btn">
                                ${poste}
                            </a>
                        </c:forEach>
                    </div>
                </c:if>
                
                <!-- Filtres par département -->
                <c:if test="${not empty departements}">
                    <div class="filter-group">
                        <strong>Par département :</strong>
                        <c:forEach var="dept" items="${departements}">
                            <a href="${pageContext.request.contextPath}/employees/search?type=departement&value=${dept.intitule}" class="filter-btn">
                                ${dept.intitule}
                            </a>
                        </c:forEach>
                    </div>
                </c:if>
            </div>
        </div>
        
        <!-- Messages -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <!-- Tableau des employés -->
        <table class="employee-table">
            <thead>
                <tr>
                    <th>Matricule</th>
                    <th>Nom</th>
                    <th>Prénom</th>
                    <th>Email</th>
                    <th>Poste</th>
                    <th>Grade</th>
                    <th>Département</th>
                    <th>Date d'embauche</th>
                    <!-- Colonne Actions : pour Admin OU Chef de Projet -->
                    <c:if test="${canModify || sessionScope.userRole == 'CHEF_PROJET'}">
                        <th>Actions</th>
                    </c:if>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty employees}">
                        <tr>
                            <td colspan="${canModify || sessionScope.userRole == 'CHEF_PROJET' ? '9' : '8'}" class="no-data">
                                <c:choose>
                                    <c:when test="${not empty searchValue}">
                                        Aucun employé ne correspond à votre recherche.
                                    </c:when>
                                    <c:otherwise>
                                        Aucun employé enregistré.
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="employee" items="${employees}">
                            <tr>
                                <td>${employee.matricule}</td>
                                <td><strong>${employee.nom}</strong></td>
                                <td>${employee.prenom}</td>
                                <td>${employee.email}</td>
                                <td>${employee.poste}</td>
                                <td><span class="badge badge-grade">${employee.grade}</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${employee.idDepartement != null && departementsMap[employee.idDepartement] != null}">
                                            ${departementsMap[employee.idDepartement]}
                                        </c:when>
                                        <c:otherwise>
                                            <em>Aucun</em>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatDate value="${employee.dateEmbauche}" pattern="dd/MM/yyyy"/></td>
                                
                                <!-- Colonne Actions -->
                                <c:if test="${canModify || sessionScope.userRole == 'CHEF_PROJET'}">
                                    <td class="actions">
                                        <!-- Admin : peut tout faire -->
                                        <c:if test="${canModify}">
                                            <a href="${pageContext.request.contextPath}/employees/edit?id=${employee.id}" class="btn-edit">✏️</a>
                                            <a href="${pageContext.request.contextPath}/employee-projets?employeeId=${employee.id}" class="btn-projects">📊</a>
                                            <a href="${pageContext.request.contextPath}/employees/delete?id=${employee.id}" 
                                               class="btn-delete" 
                                               onclick="return confirm('Êtes-vous sûr de vouloir supprimer cet employé ?')">
                                               🗑️
                                            </a>
                                        </c:if>
                                        
                                        <!-- Chef de Projet : peut affecter à SES projets -->
                                        <c:if test="${sessionScope.userRole == 'CHEF_PROJET' && !canModify}">
                                            <a href="${pageContext.request.contextPath}/projets/affectation-rapide?employeId=${employee.id}" 
                                               class="btn btn-primary"
                                               style="font-size: 0.85rem; padding: 5px 10px;">
                                               ➕
                                            </a>
                                        </c:if>
                                    </td>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</body>
</html>