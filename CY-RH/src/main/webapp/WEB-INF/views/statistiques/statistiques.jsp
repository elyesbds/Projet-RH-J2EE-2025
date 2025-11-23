<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Statistiques - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="container">
        <h1>📊 Statistiques de l'entreprise</h1>
        
        <!-- 1. STATISTIQUES DES PROJETS PAR ÉTAT -->
        <div class="stats-section">
            <h2>📈 Projets par état</h2>
            <table class="stats-table">
                <thead>
                    <tr>
                        <th>État</th>
                        <th>Nombre</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>En cours</td>
                        <td><strong>${statsProjetsByEtat['EN_COURS']}</strong></td>
                    </tr>
                    <tr>
                        <td>Terminé</td>
                        <td><strong>${statsProjetsByEtat['TERMINE']}</strong></td>
                    </tr>
                    <tr>
                        <td>Annulé</td>
                        <td><strong>${statsProjetsByEtat['ANNULE']}</strong></td>
                    </tr>
                </tbody>
            </table>
        </div>
        
        <!-- 2. NOMBRE D'EMPLOYÉS PAR DÉPARTEMENT -->
        <div class="stats-section">
            <h2>👥 Employés par département</h2>
            <table class="stats-table">
                <thead>
                    <tr>
                        <th>Département</th>
                        <th>Nombre d'employés</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="entry" items="${statsEmployesByDept}">
                        <tr>
                            <td>${entry.key}</td>
                            <td><strong>${entry.value}</strong></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        
        <!-- 3. EMPLOYÉS PAR PROJET ET LEURS GRADES -->
        <div class="stats-section">
            <h2>🎯 Employés par projet et grades</h2>
            <c:forEach var="projet" items="${statsEmployesByProjet}">
                <div class="projet-stats">
                    <h3>
                        ${projet.nomProjet} 
                        <span class="badge badge-${projet.etatProjet}">${projet.etatProjet}</span>
                    </h3>
                    <p><strong>Total employés :</strong> ${projet.totalEmployes}</p>
                    
                    <c:if test="${not empty projet.gradeCount}">
                        <table class="grade-table">
                            <thead>
                                <tr>
                                    <th>Grade</th>
                                    <th>Nombre</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="grade" items="${projet.gradeCount}">
                                    <tr>
                                        <td>${grade.key}</td>
                                        <td>${grade.value}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:if>
                    
                    <c:if test="${empty projet.gradeCount}">
                        <p class="no-data">Aucun employé affecté</p>
                    </c:if>
                </div>
            </c:forEach>
        </div>
        
    </div>
</body>
</html>