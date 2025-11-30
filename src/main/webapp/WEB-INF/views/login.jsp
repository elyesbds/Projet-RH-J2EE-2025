<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Connexion - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .login-container {
            max-width: 400px;
            margin: 100px auto;
            background: #1e1e1e;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
            border: 1px solid #333;
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-header h1 {
            color: #d4af37;
            border: none;
            padding: 0;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .login-header p {
            color: #b0b0b0;
        }

        .login-form .form-group {
            margin-bottom: 20px;
        }

        .login-form label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #d4af37;
        }

        .login-form input {
            width: 100%;
            padding: 12px;
            background-color: #121212;
            border: 1px solid #444;
            border-radius: 4px;
            font-size: 14px;
            color: #e0e0e0;
            box-sizing: border-box;
        }

        .login-form input:focus {
            outline: none;
            border-color: #d4af37;
            box-shadow: 0 0 5px rgba(212, 175, 55, 0.3);
        }

        .login-form button[type="submit"] {
            width: 100%;
            padding: 12px;
            background-color: #d4af37;
            color: #121212;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
            font-weight: bold;
            transition: all 0.3s;
        }

        .login-form button[type="submit"]:hover {
            background-color: #f0c14b;
            transform: translateY(-1px);
        }

        /* Style pour le champ mot de passe avec bouton voir/cacher */
        .password-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .password-wrapper input {
            flex: 1;
            padding-right: 45px;
        }

        .toggle-password {
            position: absolute;
            right: 10px;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 14px;
            padding: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #b0b0b0;
            font-weight: normal;
        }

        .toggle-password:hover {
            color: #d4af37;
        }
    </style>
</head>

<body>
<div class="login-container">
    <div class="login-header">
        <h1>CY-RH</h1>
        <p>Connectez-vous à votre compte</p>
    </div>

    <!-- Message d'erreur -->
    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <!-- Formulaire de connexion -->
    <form action="${pageContext.request.contextPath}/login" method="post" class="login-form">
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" placeholder="votre.email@cy-rh.com" required>
        </div>

        <div class="form-group">
            <label for="password">Mot de passe:</label>
            <div class="password-wrapper">
                <input type="password" id="password" name="password" placeholder="••••••••" required>
                <button type="button" class="toggle-password"
                        onclick="togglePasswordVisibility('password', 'toggleIcon')"
                        title="Afficher/Masquer le mot de passe">
                    <span id="toggleIcon" style="font-size: 0.8em; cursor: pointer;">Voir</span>
                </button>
            </div>
        </div>

        <button type="submit">Se connecter</button>
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