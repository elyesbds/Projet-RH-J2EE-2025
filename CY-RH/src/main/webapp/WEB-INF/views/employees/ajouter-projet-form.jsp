<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Ajouter ${employee.prenom} ${employee.nom} à un projet - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <h1>Ajouter ${employee.prenom} ${employee.nom} à un projet</h1>

    <!-- Message d'erreur simple -->
    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <!-- Messages d'erreurs multiples (validation) -->
    <c:if test="${not empty erreurs}">
        <div class="alert alert-error">
            <strong>Erreurs de validation :</strong>
            <ul style="margin: 10px 0 0 0;">
                <c:forEach var="erreur" items="${erreurs}">
                    <li>${erreur}</li>
                </c:forEach>
            </ul>
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/employee-projets" method="post"
          class="employee-form">
        <input type="hidden" name="employeeId" value="${employee.id}">

        <div class="form-group">
            <label for="projetId">Sélectionner un projet: *</label>
            <select id="projetId" name="projetId" required>
                <option value="">-- Choisir un projet --</option>
                <c:choose>
                    <c:when test="${empty projets}">
                        <option value="" disabled>Déjà affecté à tous les projets</option>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="projet" items="${projets}">
                            <option value="${projet.id}">
                                    ${projet.nomProjet} (${projet.etatProjet})
                            </option>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </select>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary" ${empty projets ? 'disabled' : '' }>
                Ajouter
            </button>
            <a href="${pageContext.request.contextPath}/employee-projets?employeeId=${employee.id}"
               class="btn btn-secondary">
                Annuler
            </a>
        </div>
    </form>
</div>
</body>

</html>