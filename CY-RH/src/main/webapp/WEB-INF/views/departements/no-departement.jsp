<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Aucun Département - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <h1>Département</h1>

    <!-- Message d'erreur -->
    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <div class="alert alert-info" style="text-align: center; padding: 40px; margin: 50px 0;">
        <h2 style="margin-bottom: 20px; color: #333;">Vous n'êtes rattaché à aucun département</h2>
        <p style="color: #666; font-size: 16px;">
            Veuillez contacter votre responsable RH ou l'administrateur pour être affecté à un département.
        </p>
        <a href="${pageContext.request.contextPath}/" class="btn btn-primary" style="margin-top: 30px;">
            Retour à l'accueil
        </a>
    </div>
</div>
</body>

</html>