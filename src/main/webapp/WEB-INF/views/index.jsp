<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- Vérification de la connexion : si pas connecté, rediriger vers login --%>
<c:if test="${empty sessionScope.user}">
    <c:redirect url="/login" />
</c:if>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>CY-RH - Accueil</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
    <style>
        .home-container {
            text-align: center;
            padding: 50px 20px;
            background-color: #1e1e1e;
            /* Force le fond sombre */
            border-radius: 8px;
            margin-top: 30px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
            border: 1px solid #333;
        }

        .welcome-message {
            background: #1e1e1e;
            color: #e0e0e0;
            padding: 40px;
            border-radius: 10px;
            margin-bottom: 50px;
            border: 1px solid #d4af37;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
            position: relative;
            overflow: hidden;
        }

        /* Petit effet de brillance sur le message de bienvenue */
        .welcome-message::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(212, 175, 55, 0.05), transparent);
            animation: shine 3s infinite;
        }

        @keyframes shine {
            0% {
                left: -100%;
            }

            50% {
                left: 100%;
            }

            100% {
                left: 100%;
            }
        }

        .welcome-message h1 {
            color: #d4af37;
            margin-bottom: 15px;
            text-transform: uppercase;
            letter-spacing: 2px;
            font-size: 2.2em;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
            border-bottom: 2px solid #d4af37;
            /* Force la bordure dorée */
            display: inline-block;
            padding-bottom: 10px;
        }

        .welcome-message p {
            font-size: 1.1em;
            color: #b0b0b0;
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 30px;
            margin-top: 40px;
        }

        .menu-card {
            background: #252525;
            color: #e0e0e0;
            padding: 40px 25px;
            border-radius: 12px;
            text-decoration: none;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            /* Effet rebond */
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
            border: 1px solid #333;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
            z-index: 1;
        }

        .menu-card:hover {
            transform: translateY(-10px) scale(1.03);
            box-shadow: 0 15px 30px rgba(212, 175, 55, 0.15);
            border-color: #d4af37;
            background: #2a2a2a;
        }

        .menu-card h2 {
            color: #d4af37;
            margin-bottom: 15px;
            font-size: 1.6em;
            transition: color 0.3s;
        }

        .menu-card:hover h2 {
            color: #f0c14b;
            text-shadow: 0 0 10px rgba(212, 175, 55, 0.3);
        }

        .menu-card p {
            color: #999;
            font-size: 0.95em;
            transition: color 0.3s;
        }

        .menu-card:hover p {
            color: #ccc;
        }
    </style>
</head>

<body>
<%@ include file="includes/header.jsp" %>

<div class="container home-container">
    <div class="welcome-message">
        <h1>Bienvenue ${sessionScope.user.prenom} ${sessionScope.user.nom} !</h1>
        <p>Système de gestion des ressources humaines - CY-RH</p>
        <p style="margin-top: 10px;">
            <strong style="color: #d4af37;">Rôle :</strong> <span
                style="color: #fff;">${sessionScope.userRole}</span>
        </p>
    </div>

    <div class="menu-grid">
        <!-- Employés : visible pour tous (consultation) -->
        <a href="${pageContext.request.contextPath}/employees" class="menu-card">
            <h2>Employés</h2>
            <p>${sessionScope.userRole == 'ADMIN' ? 'Gérer les employés' :
                    'Consulter les employés'}
            </p>
        </a>

        <!-- Départements : visible pour tous -->
        <a href="${pageContext.request.contextPath}/departements" class="menu-card">
            <h2>Départements</h2>
            <p>${sessionScope.userRole == 'EMPLOYE' ? 'Consulter mon département' :
                    'Gérer mon/les département'}</p>
        </a>


        <!-- Projets : pour tous -->
        <a href="${pageContext.request.contextPath}/projets" class="menu-card">
            <h2>Projets</h2>
            <p>${sessionScope.userRole == 'EMPLOYE' ? 'Voir mes projets' : 'Gérer les projets'}</p>
        </a>

        <!-- Fiches de paie : pour tous -->
        <a href="${pageContext.request.contextPath}/fiches-paie" class="menu-card">
            <h2>Fiches de paie</h2>
            <p>${sessionScope.userRole == 'ADMIN' ? 'Générer et consulter les fiches' : 'Consulter mes fiches'}</p>
        </a>

        <!-- Section Absences -->
        <a href="${pageContext.request.contextPath}/absences" class="menu-card">
            <h2>Absences</h2>
            <p>${sessionScope.userRole == 'ADMIN' ? 'Gérer les absences des employés (congés,maladies, etc.)' : 'Voir mes absences'}</p>
        </a>

        <!-- Statistiques : visible pour Admin uniquement -->
        <c:if test="${sessionScope.userRole == 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/statistiques" class="menu-card">
                <h2>Statistiques</h2>
                <p>Rapports et statistiques RH</p>
            </a>
        </c:if>

        <!-- Mon compte : pour tous -->
        <a href="${pageContext.request.contextPath}/mon-compte" class="menu-card">
            <h2>Mon Compte</h2>
            <p>Mes informations personnelles</p>
        </a>
    </div>
</div>
</body>

</html>