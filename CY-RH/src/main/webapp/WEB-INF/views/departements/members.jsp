<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Membres de ${departement.intitule} - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>Département: ${departement.intitule}</h1>
        
        <!-- Informations du département -->
        <div class="department-info">
            <c:if test="${chef != null}">
                <p><strong>Chef de département:</strong> ${chef.prenom} ${chef.nom} (${chef.poste})</p>
            </c:if>
            <c:if test="${chef == null}">
                <p><strong>Chef de département:</strong> <em>Non défini</em></p>
            </c:if>
        </div>
        
        <!-- Actions -->
        <div class="action-bar">
            <a href="${pageContext.request.contextPath}/departements" class="btn btn-secondary">
                Retour à la liste
            </a>
            <a href="${pageContext.request.contextPath}/departements/edit?id=${departement.id}" class="btn btn-primary">
                Modifier le département
            </a>
        </div>
        
        <!-- Liste des membres -->
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
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty membres}">
                        <tr>
                            <td colspan="7" class="no-data">Aucun employé dans ce département</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="membre" items="${membres}">
                            <tr ${membre.id == departement.chefDepartement ? 'class="chef-row"' : ''}>
                                <td>${membre.matricule}</td>
                                <td>${membre.nom}</td>
                                <td>${membre.prenom}</td>
                                <td>${membre.poste}</td>
                                <td>
                                    <span class="badge badge-grade">${membre.grade}</span>
                                </td>
                                <td>${membre.email}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${membre.id == departement.chefDepartement}">
                                            <span class="badge badge-chef">CHEF</span>
                                        </c:when>
                                        <c:otherwise>
                                            ${membre.role}
                                        </c:otherwise>
                                    </c:choose>
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