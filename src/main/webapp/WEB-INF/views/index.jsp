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
            <a href="${pageContext.request.contextPath}/employees" class="menu-card" style="background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);>
                <h2>Employés</h2>
                <p>${sessionScope.userRole == 'ADMIN' ? 'Gérer les employés' : 'Consulter les employés'}</p>
            </a>
            
            <!-- Départements : Visible pour TOUS -->
                <a href="${pageContext.request.contextPath}/departements" class="menu-card" style="background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);">
                    <h2>Départements</h2>
                    <p>${sessionScope.userRole == 'EMPLOYE' ? 'Consulter mon département' : 'Gérer mon/les département'}</p>
                </a>

            
            <!-- Projets : Pour tous -->
            <a href="${pageContext.request.contextPath}/projets" class="menu-card" style="background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);">
                <h2>Projets</h2>
                <p>${sessionScope.userRole == 'EMPLOYE' ? 'Voir mes projets' : 'Gérer les projets'}</p>
            </a>
            
            <!-- Fiches de paie : Pour tous (à venir) -->
            <a href="${pageContext.request.contextPath}/fiches-paie" class="menu-card" style="background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);">
                <h2>Fiches de paie</h2>
                <p>${sessionScope.userRole == 'ADMIN' ? 'Générer et consulter les fiches' : 'Consulter mes fiches'}</p>
            </a>
            
            <!-- Section Absences -->
            <a href="${pageContext.request.contextPath}/absences" class="menu-card" style="background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);">
                <h2>Absences</h2>
                <p>${sessionScope.userRole == 'ADMIN' ? 'Gérer les absences des employés (congés, maladies, etc.)' : 'Voir mes absences'}</p>
            </a>

            <!-- Statistiques : Visible pour Admin UNIQUEMENT -->
            <c:if test="${sessionScope.userRole == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/statistiques" class="menu-card" style="background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);">
                    <h2>Statistiques</h2>
                    <p>Rapports et statistiques RH</p>
                </a>
            </c:if>
            
            <!-- Mon compte : Pour tous -->
            <a href="${pageContext.request.contextPath}/mon-compte" class="menu-card" style="background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);">
                <h2>Mon Compte</h2>
                <p>Mes informations personnelles</p>
            </a>
        </div>
    </div>
</body>
</html>
