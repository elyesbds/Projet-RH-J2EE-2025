<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${departement != null ? 'Modifier' : 'Ajouter'} un Département - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>${departement != null ? 'Modifier' : 'Ajouter'} un Département</h1>
        
        <!-- Message d'erreur -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <!-- Formulaire -->
        <form action="${departement != null ? pageContext.request.contextPath.concat('/departements/update') : pageContext.request.contextPath.concat('/departements')}" 
              method="post" class="employee-form">
            
            <!-- ID caché pour la modification -->
            <c:if test="${departement != null}">
                <input type="hidden" name="id" value="${departement.id}">
            </c:if>
            
            <div class="form-group">
                <label for="intitule">Intitulé du département: *</label>
                <input type="text" id="intitule" name="intitule" 
                       value="${departement != null ? departement.intitule : ''}" 
                       placeholder="Ex: Informatique, RH, Finance..."
                       required>
            </div>
            
            <div class="form-group">
                <label for="chefDepartement">Chef de département:</label>
                <select id="chefDepartement" name="chefDepartement">
                    <option value="">-- Aucun --</option>
                    <c:forEach var="emp" items="${employees}">
                        <option value="${emp.id}" 
                                ${departement != null && departement.chefDepartement == emp.id ? 'selected' : ''}>
                            ${emp.prenom} ${emp.nom} (${emp.poste})
                        </option>
                    </c:forEach>
                </select>
                <small>Sélectionnez un employé comme responsable du département</small>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    ${departement != null ? 'Mettre à jour' : 'Créer'}
                </button>
                <a href="${pageContext.request.contextPath}/departements" class="btn btn-secondary">
                    Annuler
                </a>
            </div>
        </form>
    </div>
</body>
</html>