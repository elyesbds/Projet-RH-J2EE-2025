<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Équipe du projet ${projet.nomProjet} - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>Projet: ${projet.nomProjet}</h1>
        
        <!-- Informations du projet -->
        <div class="department-info">
            <p><strong>État:</strong> 
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
            </p>
            <p><strong>Date de début:</strong> <fmt:formatDate value="${projet.dateDebut}" pattern="dd/MM/yyyy"/></p>
            <p><strong>Date de fin prévue:</strong> <fmt:formatDate value="${projet.dateFinPrevue}" pattern="dd/MM/yyyy"/></p>
            <c:if test="${chef != null}">
                <p><strong>Chef de projet:</strong> ${chef.prenom} ${chef.nom} (${chef.poste})</p>
            </c:if>
        </div>
        
        <!-- Actions -->
        <div class="action-bar">
            <a href="${pageContext.request.contextPath}/projets" class="btn btn-secondary">
                Retour à la liste
            </a>
            <a href="${pageContext.request.contextPath}/projets/affecterEmploye?id=${projet.id}" class="btn btn-primary">
                Affecter un employé
            </a>
        </div>
        
        <!-- Liste de l'équipe -->
        <h2>Équipe du projet (${affectations != null ? affectations.size() : 0} membres)</h2>
        
        <table class="employee-table">
            <thead>
                <tr>
                    <th>Matricule</th>
                    <th>Nom</th>
                    <th>Prénom</th>
                    <th>Poste</th>
                    <th>Grade</th>
                    <th>Date d'affectation</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty affectations}">
                        <tr>
                            <td colspan="7" class="no-data">Aucun employé affecté à ce projet</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="aff" items="${affectations}">
                            <c:set var="employe" value="${employesMap[aff.idEmployer]}" />
                            <tr ${employe.id == projet.chefProjet ? 'class="chef-row"' : ''}>
                                <td>${employe.matricule}</td>
                                <td>${employe.nom}</td>
                                <td>${employe.prenom}</td>
                                <td>${employe.poste}</td>
                                <td>
                                    <span class="badge badge-grade">${employe.grade}</span>
                                </td>
                                <td><fmt:formatDate value="${aff.dateAffectation}" pattern="dd/MM/yyyy"/></td>
                                <td class="actions">
                                    <c:if test="${employe.id == projet.chefProjet}">
                                        <span class="badge badge-chef">CHEF</span>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/projets/retirerEmploye?affectationId=${aff.id}&projetId=${projet.id}" 
                                       class="btn-delete"
                                       onclick="return confirm('Retirer cet employé du projet ?')">
                                       Retirer
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