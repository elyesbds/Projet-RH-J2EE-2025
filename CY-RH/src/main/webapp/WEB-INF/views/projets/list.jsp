<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Liste des Projets - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <h1>Liste des Projets</h1>

    <!-- Message de succès -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <!-- Barre d'actions : Admin et Chef de département peuvent créer -->
    <div class="action-bar">
        <c:if test="${canCreateProjet}">
            <a href="${pageContext.request.contextPath}/projets/new" class="btn btn-primary">
                Créer un projet
            </a>
        </c:if>
    </div>

    <!-- Tableau des projets -->
    <table class="employee-table">
        <thead>
        <tr>
            <th>
                <a href="${pageContext.request.contextPath}/projets?sortBy=nomProjet&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                   style="color: inherit; text-decoration: none;">
                    Nom du projet ${sortBy == 'nomProjet' ? (order == 'ASC' ? '▲' : '▼') : ''}
                </a>
            </th>

            <th>
                <a href="${pageContext.request.contextPath}/projets?sortBy=chefProjet&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                   style="color: inherit; text-decoration: none;">
                    Chef de Projet ${sortBy == 'chefProjet' ? (order == 'ASC' ? '▲' : '▼') : ''}
                </a>
            </th>

            <th>
                <a href="${pageContext.request.contextPath}/projets?sortBy=idDepartement&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                   style="color: inherit; text-decoration: none;">
                    Département ${sortBy == 'idDepartement' ? (order == 'ASC' ? '▲' : '▼') : ''}
                </a>
            </th>

            <th>
                <a href="${pageContext.request.contextPath}/projets?sortBy=etatProjet&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                   style="color: inherit; text-decoration: none;">
                    État ${sortBy == 'etatProjet' ? (order == 'ASC' ? '▲' : '▼') : ''}
                </a>
            </th>
            <th>
                <a href="${pageContext.request.contextPath}/projets?sortBy=dateDebut&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                   style="color: inherit; text-decoration: none;">
                    Date de début ${sortBy == 'dateDebut' ? (order == 'ASC' ? '▲' : '▼') : ''}
                </a>
            </th>

            <th>
                <a href="${pageContext.request.contextPath}/projets?sortBy=dateFinPrevue&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                   style="color: inherit; text-decoration: none;">
                    Date fin prévue ${sortBy == 'dateFinPrevue' ? (order == 'ASC' ? '▲' : '▼') : ''}
                </a>
            </th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty projets}">
                <tr>
                    <td colspan="7" class="no-data">
                        <c:choose>
                            <c:when test="${sessionScope.userRole == 'EMPLOYE'}">
                                Vous n'êtes affecté à aucun projet actuellement.
                            </c:when>
                            <c:when test="${sessionScope.userRole == 'CHEF_PROJET'}">
                                Vous n'êtes chef d'aucun projet.
                            </c:when>
                            <c:otherwise>
                                Aucun projet enregistré.
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="projet" items="${projets}">
                    <tr>
                        <td><strong>${projet.nomProjet}</strong></td>

                        <!-- Chef de projet -->
                        <td>
                            <c:choose>
                                <c:when test="${chefsProjetMap[projet.id] != null}">
                                    ${chefsProjetMap[projet.id]}
                                </c:when>
                                <c:otherwise>
                                    <em>Non défini</em>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Département -->
                        <td>
                            <c:choose>
                                <c:when test="${departementsMap[projet.id] != null}">
                                    ${departementsMap[projet.id]}
                                </c:when>
                                <c:otherwise>
                                    <em>Non défini</em>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- État -->
                        <td>
                            <c:choose>
                                <c:when test="${projet.etatProjet == 'PAS_COMMENCE'}">
                                    <span class="badge badge-info">PAS COMMENCÉ</span>
                                </c:when>
                                <c:when test="${projet.etatProjet == 'EN_COURS'}">
                                    <span class="badge badge-success">EN COURS</span>
                                </c:when>
                                <c:when test="${projet.etatProjet == 'TERMINE'}">
                                    <span class="badge badge-secondary">TERMINÉ</span>
                                </c:when>
                                <c:when test="${projet.etatProjet == 'ANNULE'}">
                                    <span class="badge badge-danger">ANNULÉ</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-warning">INCONNU</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Date début -->
                        <td>
                            <fmt:formatDate value="${projet.dateDebut}" pattern="dd/MM/yyyy"/>
                        </td>

                        <!-- Date fin prévue -->
                        <td>
                            <c:choose>
                                <c:when test="${projet.dateFinPrevue != null}">
                                    <fmt:formatDate value="${projet.dateFinPrevue}" pattern="dd/MM/yyyy"/>
                                </c:when>
                                <c:otherwise>
                                    <em>Non définie</em>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <!-- Actions -->
                        <td class="actions">
                            <!-- Voir l'équipe : visible pour tous -->
                            <a href="${pageContext.request.contextPath}/projets/equipe?id=${projet.id}&from=projets"
                               class="btn-projects">
                                Voir l'équipe
                            </a>

                            <!-- Modifier : Admin, Chef de ce projet ou Chef du département du projet -->
                            <c:if test="${sessionScope.userRole == 'ADMIN' ||
                                                 (sessionScope.user.id == projet.chefProjet) ||
                                                 (sessionScope.userRole == 'CHEF_DEPT' && sessionScope.user.idDepartement == projet.idDepartement)}">
                                <a href="${pageContext.request.contextPath}/projets/edit?id=${projet.id}"
                                   class="btn-edit">
                                    Modifier
                                </a>
                            </c:if>

                            <!-- Supprimer : Admin uniquement -->
                            <c:if test="${sessionScope.userRole == 'ADMIN'}">
                                <a href="${pageContext.request.contextPath}/projets/delete?id=${projet.id}"
                                   class="btn-delete"
                                   onclick="return confirm('Êtes-vous sûr de vouloir supprimer ce projet ?')">
                                    Supprimer
                                </a>
                            </c:if>
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