<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Projets de ${employee.prenom} ${employee.nom} - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>Projets de ${employee.prenom} ${employee.nom}</h1>
        
        <!-- Informations employé -->
        <div class="employee-info">
            <p><strong>Matricule:</strong> ${employee.matricule}</p>
            <p><strong>Poste:</strong> ${employee.poste}</p>
            <p><strong>Grade:</strong> ${employee.grade}</p>
        </div>
        
        <!-- Actions -->
        <div class="action-bar">
            <a href="${pageContext.request.contextPath}/employees" class="btn btn-secondary">
                Retour à la liste
            </a>
            <a href="${pageContext.request.contextPath}/employee-projets/ajouter?employeeId=${employee.id}" class="btn btn-primary">
                Ajouter à un projet
            </a>
        </div>
        
        <!-- Tableau des projets -->
        <h2>Projets en cours (${affectations != null ? affectations.size() : 0})</h2>
        
        <table class="employee-table">
            <thead>
                <tr>
                    <th>Nom du projet</th>
                    <th>État</th>
                    <th>Date d'affectation</th>
                    <th>Date début projet</th>
                    <th>Date fin prévue</th>
                    <th>Rôle</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty affectations}">
                        <tr>
                            <td colspan="7" class="no-data">Aucun projet affecté</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="aff" items="${affectations}">
                            <c:set var="projet" value="${projetsMap[aff.idProjet]}" />
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
                                <td><fmt:formatDate value="${aff.dateAffectation}" pattern="dd/MM/yyyy"/></td>
                                <td><fmt:formatDate value="${projet.dateDebut}" pattern="dd/MM/yyyy"/></td>
                                <td><fmt:formatDate value="${projet.dateFinPrevue}" pattern="dd/MM/yyyy"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${employee.id == projet.chefProjet}">
                                            <span class="badge badge-chef">CHEF DE PROJET</span>
                                        </c:when>
                                        <c:otherwise>
                                            Membre
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="actions">
                                    <a href="${pageContext.request.contextPath}/employee-projets/retirer?affectationId=${aff.id}&employeeId=${employee.id}" 
                                       class="btn-delete"
                                       onclick="return confirm('Retirer de ce projet ?')">
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