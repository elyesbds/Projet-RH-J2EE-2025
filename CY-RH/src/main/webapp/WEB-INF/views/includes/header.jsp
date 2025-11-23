<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!-- Barre de navigation -->
<div class="navbar">
    <div class="navbar-brand">
        <a href="${pageContext.request.contextPath}/">CY-RH</a>
    </div>
    <div class="navbar-menu">
        <a href="${pageContext.request.contextPath}/">🏠 Accueil</a>
        
        <!-- Employés : Visible pour TOUS -->
        <a href="${pageContext.request.contextPath}/employees">👥 Employés</a>
        
        <!-- Départements : Visible pour TOUS -->
            <a href="${pageContext.request.contextPath}/departements">🏢 Départements</a>
        
        <!-- Projets : Visible pour TOUS -->
        <a href="${pageContext.request.contextPath}/projets">📊 Projets</a>
        
        <!-- Fiches de paie : Visible pour TOUS (MODIFIÉ : maintenant actif) -->
        <a href="${pageContext.request.contextPath}/fiches-paie">💰 Fiches de paie</a>
        
<!-- Statistiques : Visible pour Admin UNIQUEMENT -->
		<c:if test="${sessionScope.userRole == 'ADMIN'}">
		    <a href="${pageContext.request.contextPath}/statistiques">📈 Statistiques</a>
		</c:if>
		
		<!-- Absences : Visible pour TOUS -->
		<a href="${pageContext.request.contextPath}/absences">📅 Absences</a>
    </div>
    <div class="navbar-user">
        <a href="${pageContext.request.contextPath}/mon-compte" class="user-profile-link">
            <span class="user-name">👤 ${sessionScope.user.prenom} ${sessionScope.user.nom}</span>
            <span class="user-role">(${sessionScope.userRole})</span>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">🚪 Déconnexion</a>
    </div>
</div>
