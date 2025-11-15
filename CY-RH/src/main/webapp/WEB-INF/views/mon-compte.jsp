<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Mon Compte - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* ========== STYLES AJOUTÉS POUR LES FICHES DE PAIE ========== */
        .fiches-section {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        
        .fiches-section h2 {
            color: #333;
            font-size: 24px;
            margin: 0 0 20px 0;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        
        .fiches-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .fiches-table thead {
            background-color: #f8f9fa;
        }
        
        .fiches-table th,
        .fiches-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        
        .fiches-table th {
            font-weight: 600;
            color: #495057;
        }
        
        .fiches-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .fiches-table .text-right {
            text-align: right;
        }
        
        .net-amount {
            color: #28a745;
            font-weight: bold;
            font-size: 16px;
        }
        
        .prime-positive {
            color: #28a745;
        }
        
        .deduction-negative {
            color: #dc3545;
        }
        
        .btn-print {
            background-color: #17a2b8;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 12px;
            display: inline-block;
        }
        
        .btn-print:hover {
            background-color: #138496;
        }
        
        .no-fiches {
            text-align: center;
            padding: 40px;
            color: #6c757d;
        }
        
        .fiches-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 20px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        
        .stat-box {
            text-align: center;
            padding: 15px;
            background: white;
            border-radius: 5px;
        }
        
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
        }
        
        .stat-label {
            font-size: 12px;
            color: #6c757d;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <%@ include file="includes/header.jsp" %>
    
    <div class="container">
        <h1>👤 Mon Compte</h1>
        
        <!-- Message de succès -->
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="alert alert-success" style="background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
                ${sessionScope.successMessage}
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        
        <!-- Bouton modifier -->
        <div class="action-bar">
            <a href="${pageContext.request.contextPath}/editer-mon-compte" class="btn btn-primary">
                ✏️ Modifier mes informations
            </a>
        </div>
        
        <!-- Informations personnelles -->
        <div class="info-section">
            <h2>📋 Informations personnelles</h2>
            <div class="info-grid">
                <div class="info-item">
                    <strong>Matricule :</strong>
                    <span>${user.matricule}</span>
                </div>
                <div class="info-item">
                    <strong>Nom complet :</strong>
                    <span>${user.prenom} ${user.nom}</span>
                </div>
                <div class="info-item">
                    <strong>Email :</strong>
                    <span>${user.email}</span>
                </div>
                <div class="info-item">
                    <strong>Téléphone :</strong>
                    <span>${user.telephone != null ? user.telephone : 'Non renseigné'}</span>
                </div>
                <div class="info-item">
                    <strong>Poste :</strong>
                    <span>${user.poste}</span>
                </div>
                <div class="info-item">
                    <strong>Grade :</strong>
                    <span class="badge badge-grade">${user.grade}</span>
                </div>
                <div class="info-item">
                    <strong>Salaire de base :</strong>
                    <span><fmt:formatNumber value="${user.salaireBase}" type="currency" currencySymbol="€"/></span>
                </div>
                <div class="info-item">
                    <strong>Date d'embauche :</strong>
                    <span><fmt:formatDate value="${user.dateEmbauche}" pattern="dd/MM/yyyy"/></span>
                </div>
                <div class="info-item">
                    <strong>Rôle :</strong>
                    <span class="badge badge-chef">${user.role}</span>
                </div>
            </div>
        </div>
        
        <!-- Informations complémentaires -->
        <div class="info-section">
            <h2>🏢 Département</h2>
            <p>
                <c:choose>
                    <c:when test="${departement != null}">
                        <strong>Vous êtes rattaché au département :</strong> ${departement.intitule}
                    </c:when>
                    <c:otherwise>
                        <em>Vous n'êtes rattaché à aucun département actuellement.</em>
                    </c:otherwise>
                </c:choose>
            </p>
        </div>
        
        <!-- Lien vers mes projets -->
        <div class="info-section">
            <h2>📊 Mes projets</h2>
            <p>
                Pour consulter vos projets, rendez-vous dans l'onglet 
                <a href="${pageContext.request.contextPath}/projets" class="btn-link-small">
                    📊 Projets
                </a>
            </p>
        </div>
        
        <!-- ========== SECTION FICHES DE PAIE  ========== -->
        <div class="fiches-section">
            <h2>💰 Mes Fiches de Paie</h2>
            
            <c:choose>
                <c:when test="${empty fichesDePaie}">
                    <div class="no-fiches">
                        <h3>😕 Aucune fiche de paie</h3>
                        <p>Vous n'avez pas encore de fiches de paie enregistrées dans le système.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table class="fiches-table">
                        <thead>
                            <tr>
                                <th>Période</th>
                                <th class="text-right">Salaire Base</th>
                                <th class="text-right">Primes</th>
                                <th class="text-right">Déductions</th>
                                <th class="text-right">Net à Payer</th>
                                <th>Date Génération</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${fichesDePaie}" var="fiche">
                                <tr>
                                    <!-- Période -->
                                    <td>
                                        <strong>
                                            <c:choose>
                                                <c:when test="${fiche.mois == 1}">Janvier</c:when>
                                                <c:when test="${fiche.mois == 2}">Février</c:when>
                                                <c:when test="${fiche.mois == 3}">Mars</c:when>
                                                <c:when test="${fiche.mois == 4}">Avril</c:when>
                                                <c:when test="${fiche.mois == 5}">Mai</c:when>
                                                <c:when test="${fiche.mois == 6}">Juin</c:when>
                                                <c:when test="${fiche.mois == 7}">Juillet</c:when>
                                                <c:when test="${fiche.mois == 8}">Août</c:when>
                                                <c:when test="${fiche.mois == 9}">Septembre</c:when>
                                                <c:when test="${fiche.mois == 10}">Octobre</c:when>
                                                <c:when test="${fiche.mois == 11}">Novembre</c:when>
                                                <c:when test="${fiche.mois == 12}">Décembre</c:when>
                                            </c:choose>
                                            ${fiche.annee}
                                        </strong>
                                    </td>
                                    
                                    <!-- Salaire Base -->
                                    <td class="text-right">
                                        <fmt:formatNumber value="${fiche.salaireBase}" pattern="#,##0.00"/> €
                                    </td>
                                    
                                    <!-- Primes -->
                                    <td class="text-right">
                                        <c:choose>
                                            <c:when test="${fiche.primes > 0}">
                                                <span class="prime-positive">
                                                    +<fmt:formatNumber value="${fiche.primes}" pattern="#,##0.00"/> €
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                0.00 €
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    
                                    <!-- Déductions -->
                                    <td class="text-right">
                                        <c:choose>
                                            <c:when test="${fiche.deductions > 0}">
                                                <span class="deduction-negative">
                                                    -<fmt:formatNumber value="${fiche.deductions}" pattern="#,##0.00"/> €
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                0.00 €
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    
                                    <!-- Net à Payer -->
                                    <td class="text-right">
                                        <span class="net-amount">
                                            <fmt:formatNumber value="${fiche.netAPayer}" pattern="#,##0.00"/> €
                                        </span>
                                    </td>
                                    
                                    <!-- Date Génération -->
                                    <td>
                                        <fmt:formatDate value="${fiche.dateGeneration}" pattern="dd/MM/yyyy"/>
                                    </td>
                                    
                                    <!-- Action : Bouton Imprimer -->
                                    <td>
                                        <a href="${pageContext.request.contextPath}/fiches-paie/imprimer?id=${fiche.id}" 
                                           class="btn-print"
                                           title="Imprimer cette fiche">
                                            🖨️ Imprimer
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    
                    <!-- Statistiques -->
                    <div class="fiches-stats">
                        <div class="stat-box">
                            <div class="stat-value">${fichesDePaie.size()}</div>
                            <div class="stat-label">Fiche(s) de paie</div>
                        </div>
                        
                        <c:if test="${not empty fichesDePaie}">
                            <div class="stat-box">
                                <div class="stat-value">
                                    <fmt:formatNumber value="${fichesDePaie[0].netAPayer}" pattern="#,##0"/> €
                                </div>
                                <div class="stat-label">Dernier salaire</div>
                            </div>
                            
                            <div class="stat-box">
                                <div class="stat-value">
                                    <c:choose>
                                        <c:when test="${fichesDePaie[0].mois == 1}">Jan</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 2}">Fév</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 3}">Mar</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 4}">Avr</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 5}">Mai</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 6}">Jun</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 7}">Jul</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 8}">Aoû</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 9}">Sep</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 10}">Oct</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 11}">Nov</c:when>
                                        <c:when test="${fichesDePaie[0].mois == 12}">Déc</c:when>
                                    </c:choose>
                                    ${fichesDePaie[0].annee}
                                </div>
                                <div class="stat-label">Dernière période</div>
                            </div>
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        <!-- ========== FIN SECTION FICHES DE PAIE ========== -->
        
    </div>
</body>
</html>
