<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Connexion - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">


    <style>

        .login-container {
            max-width: 500px;
            margin: 80px auto;
            background: #1A1A1A;
            padding: 70px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.25);
            color: white;
        }

        .login-header {
            text-align: center;
            margin-bottom: 25px;
        }

        .login-header h1 {
            color: #DAA520;
            font-weight: 600;
            margin: 0;
            font-size: 28px;
        }

        .login-header p {
            font-size: 14px;
            color: #CCCCCC;
        }

        .subtext {
            margin-top: 12px;
            font-size: 14px;
            color: #cccccc;
        }

        .login-form .form-group {
            margin-bottom: 20px;
        }

        .login-form label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: #E5E5E5;
        }

        .login-form input {
            width: 100%;
            padding: 12px;
            border: 1px solid #444;
            border-radius: 5px;
            background: #2B2B2B;
            color: #FFF;
            font-size: 15px;
        }

        .login-form input:focus {
            border-color: #DAA520;
            outline: none;
        }

        .login-form button {
            width: 100%;
            padding: 12px;
            background-color: #DAA520; /* Gold */
            color: black;
            font-weight: bold;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
            transition: 0.2s ease;
        }

        .login-form button:hover {
            background-color: #B8860B; /* Gold foncé */
        }

        .alert-error {
            background: rgba(255, 80, 80, 0.15);
            color: #FF5C5C;
            border: 1px solid #FF5C5C;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 20px;
            text-align: center;
        }
    </style>

</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>🏢 CY-RH</h1>
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
                <input type="password" id="password" name="password" placeholder="••••••••" required>
            </div>
            
            <button type="submit">Se connecter</button>
        </form>
    </div>
</body>
</html>