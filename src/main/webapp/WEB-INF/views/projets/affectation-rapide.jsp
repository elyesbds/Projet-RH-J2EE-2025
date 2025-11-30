<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="UTF-8">
            <title>Affectation Rapide - CY-RH</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        </head>

        <body>
            <%@ include file="../includes/header.jsp" %>

                <div class="container">
                    <h1>Affecter un employé à un projet</h1>

                    <!-- Information sur l'employé -->
                    <div class="department-info">
                        <p><strong>Employé :</strong> ${employe.prenom} ${employe.nom}</p>
                        <p><strong>Email :</strong> ${employe.email}</p>
                        <p><strong>Poste :</strong> ${employe.poste}</p>
                    </div>

                    <!-- Formulaire d'affectation -->
                    <c:choose>
                        <c:when test="${empty projets}">
                            <div class="alert alert-info" style="text-align: center; padding: 30px;">
                                Aucun projet disponible pour affectation.<br>
                                Cet employé est déjà affecté à tous vos projets ou vous n'êtes chef d'aucun projet.
                            </div>
                            <div class="form-actions">
                                <a href="${pageContext.request.contextPath}/employees" class="btn btn-secondary">
                                    &lt; Retour à la liste des employés
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <form action="${pageContext.request.contextPath}/projets/affecter" method="post"
                                class="employee-form">
                                <input type="hidden" name="employeId" value="${employe.id}">
                                <input type="hidden" name="fromRapide" value="true">

                                <div class="form-group">
                                    <label for="projetId">Choisir un projet : *</label>
                                    <select id="projetId" name="projetId" required>
                                        <option value="">-- Sélectionner un projet --</option>
                                        <c:forEach var="projet" items="${projets}">
                                            <option value="${projet.id}">
                                                ${projet.nomProjet} (${projet.etatProjet})
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <small>Liste de vos projets où cet employé n'est pas encore affecté</small>
                                </div>

                                <div class="form-actions">
                                    <button type="submit" class="btn btn-primary">
                                        Affecter au projet
                                    </button>
                                    <a href="${pageContext.request.contextPath}/employees" class="btn btn-secondary">
                                        Annuler
                                    </a>
                                </div>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
        </body>

        </html>