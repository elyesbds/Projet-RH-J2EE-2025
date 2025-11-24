<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Éditer mon compte - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <h1>Modifier mes informations personnelles</h1>
        
        <!-- Messages -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <c:if test="${not empty success}">
            <div class="alert alert-success">${success}</div>
        </c:if>
        
        <form method="post" action="${pageContext.request.contextPath}/editer-mon-compte" class="employee-form">
            
            <!-- Informations en lecture seule -->
            <div class="info-section">
                <h2>Informations non modifiables</h2>
                <div class="info-grid">
                    <div class="info-item">
                        <strong>Matricule :</strong>
                        <span>${user.matricule}</span>
                    </div>
                    <div class="info-item">
                        <strong>Nom complet :</strong>
                        <span>${user.nom} ${user.prenom}</span>
                    </div>
                    <div class="info-item">
                        <strong>Poste :</strong>
                        <span>${user.poste}</span>
                    </div>
                    <div class="info-item">
                        <strong>Grade :</strong>
                        <span>${user.grade}</span>
                    </div>
                    <div class="info-item">
                        <strong>Date d'embauche :</strong>
                        <span>${user.dateEmbauche}</span>
                    </div>
                </div>
            </div>
            
            <h2>Informations modifiables</h2>
            
            <!-- Email -->
            <div class="form-row">
                <div class="form-group">
                    <label for="email">Email * :</label>
                    <input type="email" id="email" name="email" value="${user.email}" required>
                </div>
            </div>
            
            <!-- Téléphone -->
            <div class="form-row">
                <div class="form-group">
                    <label for="telephone">Téléphone :</label>
                    <input type="text" id="telephone" name="telephone" value="${user.telephone}">
                </div>
            </div>
            
            <!-- Mot de passe -->
            <div class="form-row">
                <div class="form-group">
                    <label for="password">Nouveau mot de passe :</label>
                    <input type="password" id="password" name="password" placeholder="Laisser vide pour ne pas modifier">
                    <small>Laisser vide si vous ne souhaitez pas changer votre mot de passe</small>
                </div>
            </div>
            
            <!-- Boutons -->
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Enregistrer</button>
                <a href="${pageContext.request.contextPath}/mon-compte" 
                   class="btn btn-secondary"
                   onclick="return confirm('⚠️ Êtes-vous sûr de vouloir annuler ?\n\nLes modifications non enregistrées seront perdues.')">
                   Annuler
                </a>
            </div>
        </form>
    </div>
</body>
</html>
