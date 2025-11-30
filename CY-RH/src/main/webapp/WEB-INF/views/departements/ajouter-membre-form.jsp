<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Ajouter un membre à ${departement.intitule} - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <h1>Ajouter un membre au département: ${departement.intitule}</h1>

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

    <form action="${pageContext.request.contextPath}/departements/affecter" method="post"
          class="employee-form">
        <input type="hidden" name="deptId" value="${departement.id}">

        <div class="form-group">
            <label for="employeId">Sélectionner un employé: *</label>
            <select id="employeId" name="employeId" required>
                <option value="">-- Choisir un employé --</option>
                <c:choose>
                    <c:when test="${empty employes}">
                        <option value="" disabled>Tous les employés ont déjà un département</option>
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
            <small>Seuls les employés sans département sont affichés</small>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary" ${empty employes ? 'disabled' : '' }>
                Ajouter
            </button>
            <a href="${pageContext.request.contextPath}/departements/members?id=${departement.id}"
               class="btn btn-secondary">
                Annuler
            </a>
        </div>
    </form>
</div>
</body>

</html>