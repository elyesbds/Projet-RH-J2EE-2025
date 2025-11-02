<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CY-RH - Accueil</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .home-container {
            text-align: center;
            padding: 50px 20px;
        }
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 40px;
        }
        .menu-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 20px;
            border-radius: 10px;
            text-decoration: none;
            transition: transform 0.3s;
        }
        .menu-card:hover {
            transform: translateY(-5px);
        }
        .menu-card h2 {
            color: white;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container home-container">
        <h1>Bienvenue sur CY-RH</h1>
        <p>Système de gestion des ressources humaines</p>
        
        <div class="menu-grid">
            <a href="${pageContext.request.contextPath}/employees" class="menu-card">
                <h2>👥 Employés</h2>
                <p>Gérer les employés de l'entreprise</p>
            </a>
            
            <a href="${pageContext.request.contextPath}/departements" class="menu-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                <h2>🏢 Départements</h2>
                <p>Gérer les départements</p>
            </a>
            
            <a href="${pageContext.request.contextPath}/projets" class="menu-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                <h2>📊 Projets</h2>
                <p>Gérer les projets</p>
            </a>
            
            <a href="#" class="menu-card" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
                <h2>💰 Fiches de paie</h2>
                <p>Générer et consulter les fiches</p>
            </a>
        </div>
    </div>
</body>
</html>