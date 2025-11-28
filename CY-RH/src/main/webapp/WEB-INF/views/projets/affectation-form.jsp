<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="UTF-8">
            <title>Affecter un employé au projet - CY-RH</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        </head>

        <body>
            <%@ include file="../includes/header.jsp" %>

                <div class="container">
                    <h1>Affecter un employé au projet: ${projet.nomProjet}</h1>

                    <!-- Message d'information sur le filtrage par département -->
                    <c:if test="${projet.idDepartement != null}">
                        <div class="alert alert-info"
                            style="background-color: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; padding: 12px; border-radius: 4px; margin-bottom: 20px;">
                            Seuls les employés du département "<strong>${departementProjet.intitule}</strong>" peuvent
                            être affectés à ce projet.
                        </div>
                    </c:if>

                    <c:if test="${projet.idDepartement == null}">
                        <div class="alert alert-success"
                            style="background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 12px; border-radius: 4px; margin-bottom: 20px;">
                            Ce projet n'a pas de département : tous les employés peuvent être affectés.
                        </div>
                    </c:if>

                    <!-- Affichage des messages d'erreur ou de succès -->
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger"
                            style="background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 20px;">
                            ${errorMessage}
                        </div>
                    </c:if>

                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success"
                            style="background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 12px; border-radius: 4px; margin-bottom: 20px;">
                            ${successMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/projets/affecter" method="post"
                        class="employee-form">
                        <input type="hidden" name="projetId" value="${projet.id}">

                        <div class="form-group">
                            <label for="employeId">Sélectionner un employé: *</label>
                            <select id="employeId" name="employeId" required>
                                <option value="">-- Choisir un employé --</option>
                                <c:choose>
                                    <c:when test="${empty employes}">
                                        <option value="" disabled>Aucun employé disponible</option>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="emp" items="${employes}">
                                            <option value="${emp.id}">
                                                ${emp.prenom} ${emp.nom} - ${emp.poste} (${emp.grade})
                                            </option>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </select>
                            <c:if test="${empty employes && projet.idDepartement != null}">
                                <small style="color: #666;">
                                    Tous les employés du département "${departementProjet.intitule}" sont déjà affectés
                                    ou il n'y a aucun employé dans ce département.
                                </small>
                            </c:if>
                            <c:if test="${empty employes && projet.idDepartement == null}">
                                <small style="color: #666;">
                                    Tous les employés sont déjà affectés à ce projet.
                                </small>
                            </c:if>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary" ${empty employes ? 'disabled' : '' }>
                                Affecter
                            </button>
                            <a href="${pageContext.request.contextPath}/projets/equipe?id=${projet.id}"
                                class="btn btn-secondary">
                                Annuler
                            </a>
                        </div>
                    </form>
                </div>
        </body>

        </html>