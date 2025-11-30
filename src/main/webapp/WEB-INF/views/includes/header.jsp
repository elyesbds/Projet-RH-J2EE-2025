<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
    /* Force Navbar Dark & Gold - Généralisation */
    .navbar {
        background-color: #1e1e1e;
        color: #d4af37;
        border-bottom: 1px solid #d4af37;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.5);
    }

    .navbar-brand a {
        color: #d4af37;
        font-size: 24px;
        font-weight: bold;
        text-decoration: none;
        text-transform: uppercase;
        letter-spacing: 1px;
    }

    .navbar-menu a {
        color: #e0e0e0;
        text-decoration: none;
        padding: 8px 15px;
        border-radius: 4px;
        transition: all 0.3s ease;
    }

    .navbar-menu a:hover {
        color: #d4af37;
        background-color: rgba(212, 175, 55, 0.1);
    }

    .user-name {
        color: #d4af37;
        font-weight: bold;
    }

    .logout-btn {
        background-color: transparent;
        color: #cf6679 ;
        padding: 6px 12px;
        border: 1px solid #cf6679 ;
        border-radius: 4px;
        text-decoration: none;
        font-size: 14px;
        transition: all 0.3s;
    }

    .logout-btn:hover {
        background-color: #cf6679 ;
        color: #121212 ;
    }
</style>

<!-- Barre de navigation -->
<div class="navbar">
    <div class="navbar-brand">
        <a href="${pageContext.request.contextPath}/">CY-RH</a>
    </div>
    <div class="navbar-menu">
        <a href="${pageContext.request.contextPath}/">Accueil</a>

        <!-- Employés : visible pour tous -->
        <a href="${pageContext.request.contextPath}/employees">Employés</a>

        <!-- Départements : visible pour tous -->
        <a href="${pageContext.request.contextPath}/departements">Départements</a>

        <!-- Projets : visible pour tous -->
        <a href="${pageContext.request.contextPath}/projets">Projets</a>

        <!-- Fiches de paie : visible pour tous -->
        <a href="${pageContext.request.contextPath}/fiches-paie">Fiches de paie</a>

        <!-- Statistiques : visible pour Admin uniquement -->
        <c:if test="${sessionScope.userRole == 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/statistiques">Statistiques</a>
        </c:if>

        <!-- Absences : visible pour tous -->
        <a href="${pageContext.request.contextPath}/absences">Absences</a>
    </div>
    <div class="navbar-user">
        <a href="${pageContext.request.contextPath}/mon-compte" class="user-profile-link">
            <span class="user-name">${sessionScope.user.prenom} ${sessionScope.user.nom}</span>
            <span class="user-role">(${sessionScope.userRole})</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Déconnexion</a>
    </div>
</div>