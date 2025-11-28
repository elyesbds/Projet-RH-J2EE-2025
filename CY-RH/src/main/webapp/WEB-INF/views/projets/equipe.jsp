<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <title>Équipe - ${projet.nomProjet} - CY-RH</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
            </head>

            <body>
                <%@ include file="../includes/header.jsp" %>

                    <div class="container">
                        <h1>Projet : ${projet.nomProjet}</h1>

                        <!-- Message de succès -->
                        <c:if test="${not empty sessionScope.successMessage}">
                            <div class="alert alert-success">${sessionScope.successMessage}</div>
                            <c:remove var="successMessage" scope="session" />
                        </c:if>

                        <!-- Message d'erreur -->
                        <c:if test="${not empty sessionScope.errorMessage}">
                            <div class="alert alert-error">${sessionScope.errorMessage}</div>
                            <c:remove var="errorMessage" scope="session" />
                        </c:if>

                        <!-- Informations du projet -->
                        <div class="department-info">
                            <p><strong>État :</strong>
                                <c:choose>
                                    <c:when test="${projet.etatProjet == 'PAS_COMMENCE'}">
                                        <span class="badge badge-warning">PAS COMMENCÉ</span>
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
                                        <span class="badge badge-info">${projet.etatProjet}</span>
                                    </c:otherwise>
                                </c:choose>
                            </p>
                            <p><strong>Date de début :</strong>
                                <fmt:formatDate value="${projet.dateDebut}" pattern="dd/MM/yyyy" />
                            </p>
                            <c:if test="${projet.dateFinPrevue != null}">
                                <p><strong>Date de fin prévue :</strong>
                                    <fmt:formatDate value="${projet.dateFinPrevue}" pattern="dd/MM/yyyy" />
                                </p>
                            </c:if>
                            <c:if test="${chef != null}">
                                <p><strong>Chef de projet :</strong> ${chef.prenom} ${chef.nom} (${chef.poste})</p>
                            </c:if>
                            
                            <c:if test="${departement != null}">
						    	<p><strong>Département :</strong> ${departement.intitule}</p>
						    </c:if>
                        </div>

                        <!-- Actions (conditionnelles selon canModify) -->
                        <div class="action-bar">
                            <!-- Bouton retour intelligent selon la provenance -->
                            <c:choose>
                                <c:when test="${param.from == 'departement' && param.deptId != null}">
                                    <!-- Retour vers le département -->
                                    <a href="${pageContext.request.contextPath}/departements/members?id=${param.deptId}"
                                        class="btn btn-secondary">
                                        &lt; Retour au département
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <!-- Retour vers la liste des projets (par défaut) -->
                                    <a href="${pageContext.request.contextPath}/projets" class="btn btn-secondary">
                                        &lt; Retour aux projets
                                    </a>
                                </c:otherwise>
                            </c:choose>

                            <!-- Affecter un employé : Admin ou Chef de ce projet + PROJET PAS_COMMENCE ou EN_COURS -->
                            <c:if
                                test="${canModify && (projet.etatProjet == 'PAS_COMMENCE' || projet.etatProjet == 'EN_COURS')}">
                                <a href="${pageContext.request.contextPath}/projets/affecterEmploye?id=${projet.id}"
                                    class="btn btn-primary">
                                    Affecter un employé
                                </a>
                            </c:if>

                            <!-- Modifier le projet : Admin ou Chef de ce projet uniquement -->
                            <c:if test="${canModify}">
                                <a href="${pageContext.request.contextPath}/projets/edit?id=${projet.id}"
                                    class="btn btn-primary">
                                    Modifier le projet
                                </a>
                            </c:if>
                        </div>

                        <!-- Liste de l'équipe -->
                        <div class="info-section">
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
                                        <th>Rôle</th>
                                        <c:if
                                            test="${canModify && (projet.etatProjet == 'PAS_COMMENCE' || projet.etatProjet == 'EN_COURS')}">
                                            <th>Actions</th>
                                        </c:if>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty affectations}">
                                            <tr>
                                                <td colspan="${canModify && (projet.etatProjet == 'PAS_COMMENCE' || projet.etatProjet == 'EN_COURS') ? '8' : '7'}"
                                                    class="no-data">Aucun employé affecté à ce projet</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="aff" items="${affectations}">
                                                <c:set var="employe" value="${employesMap[aff.idEmployer]}" />
                                                <tr ${employe.id==projet.chefProjet ? 'class="chef-row"' : '' }>
                                                    <td>${employe.matricule}</td>
                                                    <td><strong>${employe.nom}</strong></td>
                                                    <td>${employe.prenom}</td>
                                                    <td>${employe.poste}</td>
                                                    <td>
                                                        <span class="badge badge-grade">${employe.grade}</span>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${aff.dateAffectation}"
                                                            pattern="dd/MM/yyyy" />
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${employe.id == projet.chefProjet}">
                                                                <span class="badge badge-chef">CHEF PROJET</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                Membre
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>

                                                    <!-- Colonne Actions : visible uniquement si canModify + PROJET EN_COURS -->
                                                    <c:if
                                                        test="${canModify && (projet.etatProjet == 'PAS_COMMENCE' || projet.etatProjet == 'EN_COURS')}">
                                                        <td class="actions">
                                                            <a href="${pageContext.request.contextPath}/projets/retirerEmploye?affectationId=${aff.id}&projetId=${projet.id}"
                                                                class="btn-delete"
                                                                onclick="return confirm('Retirer cet employé du projet ?')">
                                                                Retirer
                                                            </a>
                                                        </td>
                                                    </c:if>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
            </body>

            </html>