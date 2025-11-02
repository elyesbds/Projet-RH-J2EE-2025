<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestion des Départements - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>Gestion des Départements</h1>
        
        <!-- Bouton pour ajouter un département -->
        <div class="action-bar">
            <a href="${pageContext.request.contextPath}/departements/new" class="btn btn-primary">
                Ajouter un département
            </a>
        </div>
        
        <!-- Message d'erreur -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <!-- Tableau des départements -->
        <table class="employee-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Intitulé</th>
                    <th>Chef de département</th>
                    <th>Nombre d'employés</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty departements}">
                        <tr>
                            <td colspan="5" class="no-data">Aucun département trouvé</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="dept" items="${departements}">
                            <tr>
                                <td>${dept.id}</td>
                                <td><strong>${dept.intitule}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${dept.chefDepartement != null}">
                                            ID: ${dept.chefDepartement}
                                        </c:when>
                                        <c:otherwise>
                                            <em>Non défini</em>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/departements/members?id=${dept.id}" class="btn-link-small">
                                        Voir les membres
                                    </a>
                                </td>
                                <td class="actions">
                                    <a href="${pageContext.request.contextPath}/departements/edit?id=${dept.id}" class="btn-edit">Modifier</a>
                                    <a href="${pageContext.request.contextPath}/departements/delete?id=${dept.id}" 
                                       class="btn-delete" 
                                       onclick="return confirm('Êtes-vous sûr de vouloir supprimer ce département ?')">
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