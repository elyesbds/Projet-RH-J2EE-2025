<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Ajouter Prime/Déduction - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>💰 Ajouter Prime ou Déduction</h1>
        
        <div class="info-box" style="background-color: #d1ecf1; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
            <p><strong>📌 Employé :</strong> ${employer.prenom} ${employer.nom} (${employer.matricule})</p>
            <p><strong>📅 Période :</strong> 
                <c:choose>
                    <c:when test="${fiche.mois == 1}">Janvier</c:when>
                    <c:when test="${fiche.mois == 2}">Février</c:when>
                    <c:when test="${fiche.mois == 3}">Mars</c:when>
                    <c:when test="${fiche.mois == 4}">Avril</c:when>
                    <c:when test="${fiche.mois == 5}">Mai</c:when>
                    <c:when test="${fiche.mois == 6}">Juin</c:when>
                    <c:when test="${fiche.mois == 7}">Juillet</c:when>
                    <c:when test="${fiche.mois == 8}">Août</c:when>
                    <c:when test="${fiche.mois == 9}">Septembre</c:when>
                    <c:when test="${fiche.mois == 10}">Octobre</c:when>
                    <c:when test="${fiche.mois == 11}">Novembre</c:when>
                    <c:when test="${fiche.mois == 12}">Décembre</c:when>
                </c:choose>
                ${fiche.annee}
            </p>
            <p><strong>💵 Salaire de base :</strong> <fmt:formatNumber value="${fiche.salaireBase}" pattern="#,##0.00"/> €</p>
        </div>
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <form action="${pageContext.request.contextPath}/fiches-paie/ajouter-prime" 
              method="post"
              onsubmit="return confirmSave()">
            <input type="hidden" name="id" value="${fiche.id}">
            
            <div class="form-group">
                <label for="primes">💰 Primes et Bonus (€)</label>
                <input type="number" 
                       id="primes" 
                       name="primes" 
                       step="0.01" 
                       min="0"
                       value="${fiche.primes}"
                       placeholder="0.00">
                <small>Heures supplémentaires, bonus de performance, primes exceptionnelles, etc.</small>
            </div>
            
            <div class="form-group">
                <label for="deductions">💸 Déductions (€)</label>
                <input type="number" 
                       id="deductions" 
                       name="deductions" 
                       step="0.01" 
                       min="0"
                       value="${fiche.deductions}"
                       placeholder="0.00">
                <small>Retards, absences non justifiées, retenues diverses, etc.</small>
            </div>
            
            <div class="info-box" style="background-color: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0;">
                <p><strong>ℹ️ Information :</strong></p>
                <ul style="margin: 10px 0; padding-left: 20px;">
                    <li>Vous pouvez ajouter des primes (montant positif)</li>
                    <li>Vous pouvez ajouter des déductions (montant positif)</li>
                    <li>Le net à payer sera recalculé automatiquement</li>
                    <li><strong>Vous ne pouvez pas modifier le salaire de base</strong></li>
                </ul>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    💾 Enregistrer
                </button>
                <button type="button" class="btn btn-secondary" onclick="confirmCancel()">
                    ❌ Annuler
                </button>
            </div>
        </form>
    </div>
    
    <script>
        function confirmSave() {
            return confirm('Confirmer l\'ajout de prime/déduction ?');
        }
        
        function confirmCancel() {
            if (confirm('⚠️ Êtes-vous sûr d\'annuler ?\n\nLes modifications non enregistrées seront perdues.')) {
                window.location.href = '${pageContext.request.contextPath}/fiches-paie';
            }
        }
    </script>
</body>
</html>
