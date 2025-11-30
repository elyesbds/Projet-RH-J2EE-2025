<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="UTF-8">
            <title>Département - CY-RH</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        </head>

        <body>
            <%@ include file="../includes/header.jsp" %>

                <div class="container">
                    <h1>Mon Département</h1>

                    <!-- Message d'erreur -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-error">${error}</div>
                    </c:if>

                    <div class="info-section" style="text-align: center; padding: 50px;">
                        <p style="font-size: 18px; color: #666;">
                            Vous n'êtes actuellement rattaché à aucun département.
                        </p>
                        <p style="margin-top: 20px;">
                            Veuillez contacter votre responsable RH pour plus d'informations.
                        </p>

                        <div style="margin-top: 40px;">
                            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                                Retour à l'accueil
                            </a>
                        </div>
                    </div>
                </div>
        </body>

        </html>