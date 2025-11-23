<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${absence != null ? 'Modifier' : 'Ajouter'} une Absence - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>📅 ${absence != null ? 'Modifier' : 'Ajouter'} une Absence</h1>
        
        <!-- Message d'erreur -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <!-- Formulaire -->
        <form method="post" 
              action="${absence != null ? pageContext.request.contextPath.concat('/absences/update') : pageContext.request.contextPath.concat('/absences')}" 
              class="employee-form">
            
            <!-- ID caché pour la modification -->
            <c:if test="${absence != null}">
                <input type="hidden" name="id" value="${absence.id}">
            </c:if>
            
            <!-- Employé -->
            <div class="form-row">
                <div class="form-group">
                    <label for="idEmployer">Employé *</label>
                    <select id="idEmployer" name="idEmployer" required>
                        <option value="">-- Sélectionner un employé --</option>
                        <c:forEach var="emp" items="${employees}">
                            <option value="${emp.id}" 
                                    ${absence != null && absence.idEmployer == emp.id ? 'selected' : ''}>
                                ${emp.prenom} ${emp.nom} - ${emp.matricule}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            
            <!-- Dates -->
            <div class="form-row">
                <div class="form-group">
                    <label for="dateDebut">Date de début *</label>
                    <input type="date" id="dateDebut" name="dateDebut" 
                           value="<fmt:formatDate value='${absence.dateDebut}' pattern='yyyy-MM-dd'/>" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="dateFin">Date de fin *</label>
                    <input type="date" id="dateFin" name="dateFin" 
                           value="<fmt:formatDate value='${absence.dateFin}' pattern='yyyy-MM-dd'/>" 
                           required>
                </div>
            </div>
            
            <!-- Type d'absence -->
            <div class="form-row">
                <div class="form-group">
                    <label for="typeAbsence">Type d'absence *</label>
                    <select id="typeAbsence" name="typeAbsence" required>
                        <option value="">-- Sélectionner un type --</option>
                        <option value="CONGE" ${absence != null && absence.typeAbsence == 'CONGE' ? 'selected' : ''}>
                            Congé
                        </option>
                        <option value="MALADIE" ${absence != null && absence.typeAbsence == 'MALADIE' ? 'selected' : ''}>
                            Maladie
                        </option>
                        <option value="ABSENCE_INJUSTIFIEE" ${absence != null && absence.typeAbsence == 'ABSENCE_INJUSTIFIEE' ? 'selected' : ''}>
                            Absence injustifiée
                        </option>
                    </select>
                </div>
            </div>
            
            <!-- Motif -->
            <div class="form-row">
                <div class="form-group">
                    <label for="motif">Motif</label>
                    <input type="text" id="motif" name="motif" 
                           value="${absence != null ? absence.motif : ''}"
                           placeholder="Motif de l'absence (optionnel)">
                </div>
            </div>
            
            <!-- Boutons -->
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    ${absence != null ? '✅ Mettre à jour' : '➕ Ajouter'}
                </button>
                <a href="${pageContext.request.contextPath}/absences" class="btn btn-secondary">
                    ❌ Annuler
                </a>
            </div>
        </form>
    </div>
    
</body>
</html>