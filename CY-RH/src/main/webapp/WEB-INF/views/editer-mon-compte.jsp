<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Éditer mon compte - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
</head>

<body>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <h1>Modifier mes informations personnelles</h1>

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

    <c:if test="${not empty success}">
        <div class="alert alert-success">${success}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/editer-mon-compte"
          class="employee-form">

        <!-- Informations en lecture seule -->
        <div class="info-section"
             style="background: radial-gradient(circle at 15% 20%, rgba(212, 175, 55, 0.1), transparent 45%), #151515; padding: 22px; border-radius: 12px; margin-bottom: 30px; border: 1px solid rgba(212, 175, 55, 0.18); box-shadow: 0 12px 28px rgba(0, 0, 0, 0.35);">
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
                <input type="email" id="email" name="email"
                       value="${param.email != null ? param.email : user.email}" required>
            </div>
        </div>

        <!-- Téléphone -->
        <div class="form-row">
            <div class="form-group">
                <label for="telephone">Téléphone :</label>
                <input type="text" id="telephone" name="telephone"
                       value="${param.telephone != null ? param.telephone : user.telephone}">
            </div>
        </div>

        <!-- Mot de passe avec bouton voir/cacher -->
        <div class="form-row">
            <div class="form-group">
                <label for="password">Nouveau mot de passe :</label>
                <div style="position: relative;">
                    <input type="password" id="password" name="password" value="${param.password}"
                           placeholder="Laisser vide pour ne pas modifier"
                           style="padding-right: 40px; background-color: #121212; border: 1px solid #444; color: #e0e0e0;">
                    <button type="button"
                            onclick="togglePasswordVisibility('password', 'togglePasswordIcon')"
                            style="position: absolute; right: 10px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; font-size: 18px; color: #d4af37;"
                            title="Afficher/Masquer le mot de passe">
                                        <span id="togglePasswordIcon"
                                              style="font-size: 0.8em; cursor: pointer; color: #d4af37;">Voir</span>
                    </button>
                </div>
                <small style="color: #b0b0b0; display: block; margin-top: 5px;">
                    Laisser vide si vous ne souhaitez pas changer votre mot de passe
                </small>
            </div>
        </div>

        <!-- Boutons -->
        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Enregistrer</button>
            <a href="${pageContext.request.contextPath}/mon-compte" class="btn btn-secondary"
               onclick="return confirm('Êtes-vous sûr de vouloir annuler ?\n\nLes modifications non enregistrées seront perdues.')">
                Annuler
            </a>
        </div>
    </form>
</div>

<script>
    function togglePasswordVisibility(inputId, iconId) {
        var passwordInput = document.getElementById(inputId);
        var icon = document.getElementById(iconId);

        if (passwordInput.type === "password") {
            passwordInput.type = "text";
            icon.textContent = "Cacher";
        } else {
            passwordInput.type = "password";
            icon.textContent = "Voir";
        }
    }
</script>
</body>

</html>