<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- Vérification de la connexion : si pas connecté, rediriger vers login --%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/login"/>
</c:if>

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
        .welcome-message {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 40px;
        }
        .welcome-message h1 {
            color: white;
            margin-bottom: 10px;
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
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .menu-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.15);
        }
        .menu-card h2 {
            color: white;
            margin-bottom: 10px;
        }
        .menu-card p {
            color: rgba(255,255,255,0.9);
        }
    </style>
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container home-container">
        <div class="welcome-message">
            <h1>Bienvenue ${sessionScope.user.prenom} ${sessionScope.user.nom} !</h1>
            <p>Système de gestion des ressources humaines - CY-RH</p>
            <p>
                <strong>Rôle :</strong> ${sessionScope.userRole}
            </p>
        </div>
        
        <div class="menu-grid">
            <!-- Employés : Visible pour TOUS (consultation) -->
            <a href="${pageContext.request.contextPath}/employees" class="menu-card">
                <h2>👥 Employés</h2>
                <p>${sessionScope.userRole == 'ADMIN' ? 'Gérer les employés' : 'Consulter les employés'}</p>
            </a>
            
            <!-- Départements : Visible pour TOUS -->
                <a href="${pageContext.request.contextPath}/departements" class="menu-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                    <h2>🏢 Départements</h2>
                    <p>${sessionScope.userRole == 'EMPLOYE' ? 'Consulter mon département' : 'Gérer mon/les département'}</p>
                </a>

            
            <!-- Projets : Pour tous -->
            <a href="${pageContext.request.contextPath}/projets" class="menu-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                <h2>📊 Projets</h2>
                <p>${sessionScope.userRole == 'EMPLOYE' ? 'Voir mes projets' : 'Gérer les projets'}</p>
            </a>
            
            <!-- Fiches de paie : Pour tous (à venir) -->
            <a href="${pageContext.request.contextPath}/fiches-paie" class="menu-card" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
                <h2>💰 Fiches de paie</h2>
                <p>${sessionScope.userRole == 'ADMIN' ? 'Générer et consulter les fiches' : 'Consulter mes fiches'}</p>
            </a>
            
            <!-- Statistiques : Visible pour Admin UNIQUEMENT -->
            <c:if test="${sessionScope.userRole == 'ADMIN'}">
                <a href="#" class="menu-card" style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);">
                    <h2>📈 Statistiques</h2>
                    <p>Rapports et statistiques RH</p>
                </a>
            </c:if>
            
            <!-- Mon compte : Pour tous -->
            <a href="${pageContext.request.contextPath}/mon-compte" class="menu-card" style="background: linear-gradient(135deg, #30cfd0 0%, #330867 100%);">
                <h2>👤 Mon Compte</h2>
                <p>Mes informations personnelles</p>
            </a>
        </div>
    </div>
</body>
</html>
