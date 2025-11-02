<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        
        <form action="${pageContext.request.contextPath}/projets/affecter" method="post" class="employee-form">
            <input type="hidden" name="projetId" value="${projet.id}">
            
            <div class="form-group">
                <label for="employeId">Sélectionner un employé: *</label>
                <select id="employeId" name="employeId" required>
                    <option value="">-- Choisir un employé --</option>
                    <c:choose>
                        <c:when test="${empty employes}">
                            <option value="" disabled>Tous les employés sont déjà affectés</option>
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
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary" ${empty employes ? 'disabled' : ''}>
                    Affecter
                </button>
                <a href="${pageContext.request.contextPath}/projets/equipe?id=${projet.id}" class="btn btn-secondary">
                    Annuler
                </a>
            </div>
        </form>
    </div>
</body>
</html>