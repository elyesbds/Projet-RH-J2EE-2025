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
    
    <div class="container">
        <h1>Gestion des Employés</h1>
        
        <!-- Formulaire de recherche -->
        <div class="search-section">
            <h2>Rechercher un employé</h2>
            <form action="${pageContext.request.contextPath}/employees/search" method="get">
                <select name="type" id="searchType">
                    <option value="name" ${searchType == 'name' ? 'selected' : ''}>Nom/Prénom</option>
                    <option value="matricule" ${searchType == 'matricule' ? 'selected' : ''}>Matricule</option>
                    <option value="grade" ${searchType == 'grade' ? 'selected' : ''}>Grade</option>
                    <option value="poste" ${searchType == 'poste' ? 'selected' : ''}>Poste</option>
                    <option value="departement" ${searchType == 'departement' ? 'selected' : ''}>Département</option>
                </select>
                <input type="text" name="value" placeholder="Rechercher..." value="${searchValue}">
                <button type="submit">Rechercher</button>
                <a href="${pageContext.request.contextPath}/employees" class="btn-link">Réinitialiser</a>
            </form>
        </div>
        
        <!-- Filtres rapides par Grade et Poste -->
        <div class="filters-section">
            <h2>Filtres rapides</h2>
            <div class="filter-buttons">
                <div class="filter-group">
                    <strong>Par Grade:</strong>
                    <a href="${pageContext.request.contextPath}/employees/search?type=grade&value=Junior" class="filter-btn">Junior</a>
                    <a href="${pageContext.request.contextPath}/employees/search?type=grade&value=Confirmé" class="filter-btn">Confirmé</a>
                    <a href="${pageContext.request.contextPath}/employees/search?type=grade&value=Senior" class="filter-btn">Senior</a>
                    <a href="${pageContext.request.contextPath}/employees/search?type=grade&value=Expert" class="filter-btn">Expert</a>
                </div>
            </div>
        </div>
        
        <!-- Bouton pour ajouter un employé -->
        <div class="action-bar">
            <a href="${pageContext.request.contextPath}/employees/new" class="btn btn-primary">
                Ajouter un employé
            </a>
        </div>
        
        <!-- Message d'erreur -->
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
                    <th>Salaire</th>
                    <th>Date d'embauche</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty employees}">
                        <tr>
                            <td colspan="9" class="no-data">Aucun employé trouvé</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="emp" items="${employees}">
                            <tr>
                                <td>${emp.matricule}</td>
                                <td>${emp.nom}</td>
                                <td>${emp.prenom}</td>
                                <td>${emp.email}</td>
                                <td>${emp.poste}</td>
                                <td>${emp.grade}</td>
                                <td><fmt:formatNumber value="${emp.salaireBase}" type="currency" currencySymbol="€"/></td>
                                <td><fmt:formatDate value="${emp.dateEmbauche}" pattern="dd/MM/yyyy"/></td>
                                <td class="actions">
                                    <a href="${pageContext.request.contextPath}/employee-projets?employeeId=${emp.id}" class="btn-projects" title="Gérer les projets">Projets</a>
                                    <a href="${pageContext.request.contextPath}/employees/edit?id=${emp.id}" class="btn-edit">Modifier</a>
                                    <a href="${pageContext.request.contextPath}/employees/delete?id=${emp.id}" 
                                       class="btn-delete" 
                                       onclick="return confirm('Êtes-vous sûr de vouloir supprimer cet employé ?')">
                                       Supprimer
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</body>
</html>