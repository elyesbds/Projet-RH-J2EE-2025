<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestion des Projets - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>Gestion des Projets</h1>
        
        <!-- Bouton pour ajouter un projet -->
        <div class="action-bar">
            <a href="${pageContext.request.contextPath}/projets/new" class="btn btn-primary">
                Créer un projet
            </a>
        </div>
        
        <!-- Tableau des projets -->
        <table class="employee-table">
            <thead>
                <tr>
                    <th>Nom du projet</th>
                    <th>État</th>
                    <th>Date début</th>
                    <th>Date fin prévue</th>
                    <th>Date fin réelle</th>
                    <th>Chef de projet</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty projets}">
                        <tr>
                            <td colspan="7" class="no-data">Aucun projet trouvé</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="projet" items="${projets}">
                            <tr>
                                <td><strong>${projet.nomProjet}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${projet.etatProjet == 'EN_COURS'}">
                                            <span class="badge badge-success">EN COURS</span>
                                        </c:when>
                                        <c:when test="${projet.etatProjet == 'TERMINE'}">
                                            <span class="badge badge-secondary">TERMINÉ</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-danger">ANNULÉ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatDate value="${projet.dateDebut}" pattern="dd/MM/yyyy"/></td>
                                <td><fmt:formatDate value="${projet.dateFinPrevue}" pattern="dd/MM/yyyy"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${projet.dateFinReelle != null}">
                                            <fmt:formatDate value="${projet.dateFinReelle}" pattern="dd/MM/yyyy"/>
                                        </c:when>
                                        <c:otherwise>
                                            <em>Non terminé</em>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${projet.chefProjet != null}">
                                            ID: ${projet.chefProjet}
                                        </c:when>
                                        <c:otherwise>
                                            <em>Non défini</em>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="actions">
                                    <a href="${pageContext.request.contextPath}/projets/equipe?id=${projet.id}" class="btn-projects" title="Gérer l'équipe">Équipe</a>
                                    <a href="${pageContext.request.contextPath}/projets/edit?id=${projet.id}" class="btn-edit">Modifier</a>
                                    <a href="${pageContext.request.contextPath}/projets/delete?id=${projet.id}" 
                                       class="btn-delete" 
                                       onclick="return confirm('Êtes-vous sûr de vouloir supprimer ce projet ?')">
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