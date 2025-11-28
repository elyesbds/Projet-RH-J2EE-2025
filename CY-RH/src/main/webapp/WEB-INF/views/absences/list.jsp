<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <title>Gestion des Absences - CY-RH</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
            </head>

            <body>
                <%@ include file="../includes/header.jsp" %>

                    <div class="container">
                        <h1>Gestion des Absences</h1>
                        <!-- Message de succès -->
                        <c:if test="${not empty sessionScope.successMessage}">
                            <div class="alert alert-success">${sessionScope.successMessage}</div>
                            <c:remove var="successMessage" scope="session" />
                        </c:if>

                        <!-- Section de filtres -->
                        <div class="search-section">
                            <h2>Filtrer les absences</h2>
                            <form method="get" action="${pageContext.request.contextPath}/absences/search">
                                <select name="idEmployer">
                                    <option value="">-- Tous les employés --</option>
                                    <c:forEach var="entry" items="${employersMap}">
                                        <option value="${entry.key}" ${param.idEmployer==entry.key ? 'selected' : '' }>
                                            ${entry.value}
                                        </option>
                                    </c:forEach>
                                </select>

                                <select name="typeAbsence">
                                    <option value="">-- Tous les types --</option>
                                    <option value="CONGE" ${param.typeAbsence=='CONGE' ? 'selected' : '' }>Congé
                                    </option>
                                    <option value="MALADIE" ${param.typeAbsence=='MALADIE' ? 'selected' : '' }>Maladie
                                    </option>
                                    <option value="ABSENCE_INJUSTIFIEE" ${param.typeAbsence=='ABSENCE_INJUSTIFIEE'
                                        ? 'selected' : '' }>Absence injustifiée</option>
                                </select>

                                <button type="submit" class="btn btn-primary">Filtrer</button>
                                <a href="${pageContext.request.contextPath}/absences"
                                    class="btn btn-secondary">Réinitialiser</a>
                            </form>
                        </div>

                        <!-- Bouton Ajouter (Admin uniquement) -->
                        <c:if test="${canModify}">
                            <div class="action-bar">
                                <a href="${pageContext.request.contextPath}/absences/new" class="btn btn-primary">
                                    Ajouter une absence
                                </a>
                            </div>
                        </c:if>


                        <!-- Message d'erreur -->
                        <c:if test="${not empty error}">
                            <div class="alert alert-error">${error}</div>
                        </c:if>

                        <!-- Tableau des absences -->
                        <table class="employee-table">
                            <thead>
                            <tr>
                                <th>
                                    <a href="${pageContext.request.contextPath}/absences?sortBy=employe&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                                       style="color: inherit; text-decoration: none;">
                                        Employé ${sortBy == 'employe' ? (order == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>

                                <th>
                                    <a href="${pageContext.request.contextPath}/absences?sortBy=dateDebut&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                                       style="color: inherit; text-decoration: none;">
                                        Date début ${sortBy == 'dateDebut' ? (order == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>

                                <th>
                                    <a href="${pageContext.request.contextPath}/absences?sortBy=dateFin&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                                       style="color: inherit; text-decoration: none;">
                                        Date fin ${sortBy == 'dateFin' ? (order == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>

                                <th>
                                    <a href="${pageContext.request.contextPath}/absences?sortBy=typeAbsence&order=${order == 'ASC' ? 'DESC' : 'ASC'}"
                                       style="color: inherit; text-decoration: none;">
                                        Type ${sortBy == 'typeAbsence' ? (order == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>

                                <th>Motif</th>

                                <c:if test="${canModify}">
                                    <th>Actions</th>
                                </c:if>
                            </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty absences}">
                                        <tr>
                                            <td colspan="${canModify ? '6' : '5'}" class="no-data">
                                                Aucune absence enregistrée
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="absence" items="${absences}">
                                            <tr>
                                                <td>${employersMap[absence.idEmployer]}</td>
                                                <td>
                                                    <fmt:formatDate value="${absence.dateDebut}" pattern="dd/MM/yyyy" />
                                                </td>
                                                <td>
                                                    <fmt:formatDate value="${absence.dateFin}" pattern="dd/MM/yyyy" />
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${absence.typeAbsence == 'CONGE'}">
                                                            <span class="badge badge-success">Congé</span>
                                                        </c:when>
                                                        <c:when test="${absence.typeAbsence == 'MALADIE'}">
                                                            <span class="badge badge-secondary">Maladie</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-danger">Absence injustifiée</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>${absence.motif != null ? absence.motif : '-'}</td>
                                                <c:if test="${canModify}">
                                                    <td class="actions">
                                                        <a href="${pageContext.request.contextPath}/absences/edit?id=${absence.id}"
                                                            class="btn-edit">Modifier</a>
                                                        <a href="${pageContext.request.contextPath}/absences/delete?id=${absence.id}"
                                                            class="btn-delete"
                                                            onclick="return confirm('Êtes-vous sûr de vouloir supprimer cette absence ?')">
                                                            Supprimer
                                                        </a>
                                                    </td>
                                                </c:if>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>

                        <br>
                        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary">Retour à l'accueil</a>
                    </div>

            </body>

            </html>