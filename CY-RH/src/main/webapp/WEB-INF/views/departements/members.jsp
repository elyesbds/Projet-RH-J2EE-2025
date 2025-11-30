<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Département ${departement.intitule} - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <h1>Département : ${departement.intitule}</h1>

    <!-- Informations du département -->
    <div class="department-info">
        <c:if test="${chef != null}">
            <p><strong>Chef de département :</strong> ${chef.prenom} ${chef.nom} (${chef.poste})</p>
        </c:if>
        <c:if test="${chef == null}">
            <p><strong>Chef de département :</strong> <em>Non défini</em></p>
        </c:if>
    </div>

    <!-- Actions (uniquement pour Admin et Chef de CE département) -->
    <div class="action-bar">
        <!-- Retour à la liste : seulement pour Admin et Chef dept -->
        <c:if test="${sessionScope.userRole == 'ADMIN' || sessionScope.userRole == 'CHEF_DEPT'}">
            <a href="${pageContext.request.contextPath}/departements" class="btn btn-secondary">
                &lt; Retour à la liste
            </a>
        </c:if>

        <!-- Retour à l'accueil : pour les autres utilisateurs -->
        <c:if test="${sessionScope.userRole != 'ADMIN' && sessionScope.userRole != 'CHEF_DEPT'}">
            <a href="${pageContext.request.contextPath}/" class="btn btn-secondary">
                Retour à l'accueil
            </a>
        </c:if>

        <!-- Ajouter membre et Modifier : Admin OU Chef de CE département uniquement -->
        <c:if
                test="${sessionScope.userRole == 'ADMIN' || (chef != null && sessionScope.userId == chef.id)}">
            <a href="${pageContext.request.contextPath}/departements/ajouterMembre?id=${departement.id}"
               class="btn btn-primary">
                Ajouter un membre
            </a>

            <a href="${pageContext.request.contextPath}/departements/edit?id=${departement.id}"
               class="btn btn-primary">
                Modifier le département
            </a>
        </c:if>
    </div>

    <!-- Liste des membres -->
    <div class="info-section">
        <h2>Membres du département (${membres != null ? membres.size() : 0})</h2>

        <table class="employee-table">
            <thead>
            <tr>
                <th>Matricule</th>
                <th>Nom</th>
                <th>Prénom</th>
                <th>Poste</th>
                <th>Grade</th>
                <th>Email</th>
                <th>Rôle</th>
                <c:if
                        test="${sessionScope.userRole == 'ADMIN' || (chef != null && sessionScope.userId == chef.id)}">
                    <th>Actions</th>
                </c:if>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty membres}">
                    <tr>
                        <td colspan="${sessionScope.userRole == 'ADMIN' || (chef != null && sessionScope.userId == chef.id) ? '8' : '7'}"
                            class="no-data">Aucun employé dans ce département
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="membre" items="${membres}">
                        <tr ${departement.chefDepartement !=null &&
                                membre.id==departement.chefDepartement.id ? 'class="chef-row"' : ''
                                }>
                            <td>${membre.matricule}</td>
                            <td><strong>${membre.nom}</strong></td>
                            <td>${membre.prenom}</td>
                            <td>${membre.poste}</td>
                            <td>
                                <span class="badge badge-grade">${membre.grade}</span>
                            </td>
                            <td>${membre.email}</td>
                            <td>
                                <c:choose>
                                    <c:when
                                            test="${departement.chefDepartement != null && membre.id == departement.chefDepartement.id}">
                                        <span class="badge badge-chef">CHEF DEPT</span>
                                    </c:when>
                                    <c:otherwise>
                                        ${membre.role}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <c:if
                                    test="${sessionScope.userRole == 'ADMIN' || (chef != null && sessionScope.userId == chef.id)}">
                                <td>
                                    <c:choose>
                                        <c:when
                                                test="${departement.chefDepartement != null && membre.id == departement.chefDepartement.id && sessionScope.userRole != 'ADMIN'}">
                                            <em style="color: #999;">Vous êtes le chef</em>
                                        </c:when>
                                        <c:when
                                                test="${departement.chefDepartement != null && membre.id == departement.chefDepartement.id && sessionScope.userRole == 'ADMIN'}">
                                            <a href="${pageContext.request.contextPath}/departements/retirerMembre?employeId=${membre.id}&deptId=${departement.id}"
                                               class="btn-delete"
                                               onclick="return confirm('ATTENTION : Vous allez retirer le chef de département !\n\n${membre.prenom} ${membre.nom} perdra son statut de chef et deviendra employé simple.\n\nConfirmer ?')">
                                                Retirer le chef
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/departements/retirerMembre?employeId=${membre.id}&deptId=${departement.id}"
                                               class="btn-delete"
                                               onclick="return confirm('Êtes-vous sûr de vouloir retirer ${membre.prenom} ${membre.nom} de ce département ?')">
                                                Retirer
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>

    <!-- Liste des projets du département -->
    <div class="info-section">
        <h2>Projets du département (${projets != null ? projets.size() : 0})</h2>

        <c:choose>
            <c:when test="${empty projets}">
                <p class="no-data" style="text-align: center; padding: 30px; color: #999;">
                    Aucun projet n'est actuellement rattaché à ce département.
                </p>
            </c:when>
            <c:otherwise>
                <table class="employee-table">
                    <thead>
                    <tr>
                        <th>Nom du projet</th>
                        <th>État</th>
                        <th>Date début</th>
                        <th>Date fin prévue</th>
                        <th>Nombre de membres</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
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
                            <td>
                                <fmt:formatDate value="${projet.dateDebut}"
                                                pattern="dd/MM/yyyy"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${projet.dateFinPrevue != null}">
                                        <fmt:formatDate value="${projet.dateFinPrevue}"
                                                        pattern="dd/MM/yyyy"/>
                                    </c:when>
                                    <c:otherwise>
                                        <em>Non définie</em>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: center;">
                                                        <span
                                                                class="badge badge-grade">${projetsMembreCount[projet.id]}</span>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/projets/equipe?id=${projet.id}&from=departement&deptId=${departement.id}"
                                   class="btn-link-small">
                                    Voir l'équipe
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>

</html>