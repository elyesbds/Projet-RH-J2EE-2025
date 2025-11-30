<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Projets de ${employee.prenom} ${employee.nom} - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
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
        
         <!-- Message de succès -->
                        <c:if test="${not empty sessionScope.successMessage}">
                            <div class="alert alert-success">${sessionScope.successMessage}</div>
                            <c:remove var="successMessage" scope="session" />
                        </c:if>
                        
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
        <c:set var="totalProjets" value="${projetsMap != null ? projetsMap.size() : 0}" />
        <h2>Projets en cours (${totalProjets})</h2>
        
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
                    <c:when test="${empty projetsMap}">
                        <tr>
                            <td colspan="7" class="no-data">Aucun projet affecté</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <!-- AFFICHER TOUS LES PROJETS (triés par rôle : chef d'abord, puis membres) -->
                        
                        <!-- 1. PROJETS OÙ IL EST CHEF -->
						<c:if test="${not empty projetsChef}">
						    <c:forEach var="projet" items="${projetsChef}">
						        <tr>
						            <td><strong>${projet.nomProjet}</strong></td>
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
						            <td>
						                <!-- Chercher la date d'affectation si elle existe -->
						                <c:set var="affectationTrouvee" value="false" />
						                <c:forEach var="aff" items="${affectations}">
						                    <c:if test="${aff.idProjet == projet.id}">
						                        <fmt:formatDate value="${aff.dateAffectation}" pattern="dd/MM/yyyy"/>
						                        <c:set var="affectationTrouvee" value="true" />
						                    </c:if>
						                </c:forEach>
						                <c:if test="${!affectationTrouvee}">
						                    -
						                </c:if>
						            </td>
						            <td><fmt:formatDate value="${projet.dateDebut}" pattern="dd/MM/yyyy"/></td>
						            <td><fmt:formatDate value="${projet.dateFinPrevue}" pattern="dd/MM/yyyy"/></td>
						            <td>
						                <span class="badge badge-chef">CHEF DE PROJET</span>
						            </td>
						            <td class="actions">
						                <!-- Retirer du poste de chef -->
						                <a href="${pageContext.request.contextPath}/employee-projets/retirerChef?projetId=${projet.id}&employeeId=${employee.id}" 
						                   class="btn-delete"
						                   onclick="return confirm('Retirer cet employé du poste de chef de projet ?')">
						                   Retirer
						                </a>
						            </td>
						        </tr>
						    </c:forEach>
						</c:if>
						<!-- 2. PROJETS OÙ IL EST MEMBRE (mais PAS chef) -->
						<c:forEach var="aff" items="${affectations}">
						    <c:set var="projet" value="${projetsMap[aff.idProjet]}" />
						    <!-- Vérifier qu'il n'est PAS chef de ce projet -->
						    <c:if test="${employee.id != projet.chefProjet}">
						        <tr>
						            <td><strong>${projet.nomProjet}</strong></td>
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
						            <td><fmt:formatDate value="${aff.dateAffectation}" pattern="dd/MM/yyyy"/></td>
						            <td><fmt:formatDate value="${projet.dateDebut}" pattern="dd/MM/yyyy"/></td>
						            <td><fmt:formatDate value="${projet.dateFinPrevue}" pattern="dd/MM/yyyy"/></td>
						            <td>
						                Membre
						            </td>
						            <td class="actions">
						                <a href="${pageContext.request.contextPath}/employee-projets/retirer?affectationId=${aff.id}&employeeId=${employee.id}" 
						                   class="btn-delete"
						                   onclick="return confirm('Retirer de ce projet ?')">
						                   Retirer
						                </a>
						            </td>
						        </tr>
						    </c:if>
						</c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</body>
</html>