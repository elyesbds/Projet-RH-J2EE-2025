<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fiche de Paie - ${employer.prenom} ${employer.nom}</title>
    <style>
        /* Style pour l'affichage écran */
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        
        .print-container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .no-print {
            text-align: center;
            margin-bottom: 20px;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            margin: 0 5px;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background-color: #007bff;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #0056b3;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #545b62;
        }
        
        /* En-tête de la fiche */
        .fiche-header {
            text-align: center;
            border-bottom: 3px solid #007bff;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        
        .fiche-header h1 {
            color: #007bff;
            margin: 0 0 10px 0;
            font-size: 28px;
        }
        
        .fiche-header .company-name {
            font-size: 20px;
            font-weight: bold;
            color: #333;
        }
        
        .fiche-header .subtitle {
            color: #6c757d;
            font-size: 14px;
        }
        
        /* Informations générales */
        .info-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }
        
        .info-box {
            border: 1px solid #dee2e6;
            padding: 15px;
            border-radius: 5px;
        }
        
        .info-box h3 {
            margin: 0 0 15px 0;
            color: #007bff;
            font-size: 16px;
            border-bottom: 2px solid #007bff;
            padding-bottom: 5px;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
        }
        
        .info-label {
            color: #6c757d;
            font-weight: bold;
        }
        
        .info-value {
            color: #333;
        }
        
        /* Tableau des montants */
        .amounts-table {
            width: 100%;
            border-collapse: collapse;
            margin: 30px 0;
        }
        
        .amounts-table th,
        .amounts-table td {
            padding: 12px;
            text-align: left;
            border: 1px solid #dee2e6;
        }
        
        .amounts-table thead {
            background-color: #007bff;
            color: white;
        }
        
        .amounts-table tbody tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        .amounts-table .text-right {
            text-align: right;
        }
        
        .amounts-table .total-row {
            background-color: #28a745 !important;
            color: white;
            font-weight: bold;
            font-size: 18px;
        }
        
        /* Pied de page */
        .fiche-footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #dee2e6;
            text-align: center;
            color: #6c757d;
            font-size: 12px;
        }
        
        .signature-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-top: 50px;
        }
        
        .signature-box {
            text-align: center;
        }
        
        .signature-box p {
            margin: 5px 0;
            color: #333;
        }
        
        .signature-line {
            border-top: 1px solid #333;
            width: 200px;
            margin: 60px auto 10px;
        }
        
        /* Style pour l'impression */
        @media print {
            body {
                background: white;
                padding: 0;
            }
            
            .print-container {
                box-shadow: none;
                padding: 20px;
            }
            
            .no-print {
                display: none !important;
            }
            
            /* Éviter les sauts de page au milieu des éléments */
            .info-section,
            .amounts-table,
            .signature-section {
                page-break-inside: avoid;
            }
        }
    </style>
</head>
<body>
    <div class="print-container">
        <!-- Boutons d'action (cachés à l'impression) -->
        <div class="no-print">
            <button onclick="window.print()" class="btn btn-primary">
                🖨️ Imprimer la Fiche
            </button>
            <a href="${pageContext.request.contextPath}/fiches-paie" class="btn btn-secondary">
                ⬅️ Retour à la Liste
            </a>
            <a href="${pageContext.request.contextPath}/mon-compte" class="btn btn-secondary">
                👤 Mon Compte
            </a>
        </div>
        
        <!-- En-tête de la fiche -->
        <div class="fiche-header">
            <div class="company-name">ENTREPRISE CY-RH</div>
            <h1>FICHE DE PAIE</h1>
            <div class="subtitle">
                Période : 
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
            </div>
            <div class="subtitle">
                Date de génération : <fmt:formatDate value="${fiche.dateGeneration}" pattern="dd/MM/yyyy"/>
            </div>
        </div>
        
        <!-- Informations générales -->
        <div class="info-section">
            <!-- Informations Employeur -->
            <div class="info-box">
                <h3>🏢 EMPLOYEUR</h3>
                <div class="info-row">
                    <span class="info-label">Entreprise :</span>
                    <span class="info-value">CY-RH</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Département :</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${not empty departement}">
                                ${departement.intitule}
                            </c:when>
                            <c:otherwise>
                                Non affecté
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="info-row">
                    <span class="info-label">Fiche N° :</span>
                    <span class="info-value">${fiche.id}</span>
                </div>
            </div>
            
            <!-- Informations Employé -->
            <div class="info-box">
                <h3>👤 EMPLOYÉ</h3>
                <div class="info-row">
                    <span class="info-label">Nom :</span>
                    <span class="info-value">${employer.nom}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Prénom :</span>
                    <span class="info-value">${employer.prenom}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Matricule :</span>
                    <span class="info-value">${employer.matricule}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Poste :</span>
                    <span class="info-value">${employer.poste}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Grade :</span>
                    <span class="info-value">${employer.grade}</span>
                </div>
            </div>
        </div>
        
        <!-- Tableau des montants -->
        <table class="amounts-table">
            <thead>
                <tr>
                    <th>Libellé</th>
                    <th class="text-right">Montant (€)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Salaire de base</strong></td>
                    <td class="text-right">
                        <fmt:formatNumber value="${fiche.salaireBase}" pattern="#,##0.00"/>
                    </td>
                </tr>
                
                <c:if test="${fiche.primes > 0}">
                    <tr>
                        <td>+ Primes et bonus</td>
                        <td class="text-right" style="color: #28a745;">
                            + <fmt:formatNumber value="${fiche.primes}" pattern="#,##0.00"/>
                        </td>
                    </tr>
                </c:if>
                
                <c:if test="${fiche.deductions > 0}">
                    <tr>
                        <td>- Déductions</td>
                        <td class="text-right" style="color: #dc3545;">
                            - <fmt:formatNumber value="${fiche.deductions}" pattern="#,##0.00"/>
                        </td>
                    </tr>
                </c:if>
                
                <tr class="total-row">
                    <td><strong>NET À PAYER</strong></td>
                    <td class="text-right">
                        <strong><fmt:formatNumber value="${fiche.netAPayer}" pattern="#,##0.00"/> €</strong>
                    </td>
                </tr>
            </tbody>
        </table>
        
        <!-- Détails des primes et déductions (si présents) -->
        <c:if test="${fiche.primes > 0 || fiche.deductions > 0}">
            <div style="margin: 30px 0; padding: 15px; background: #f8f9fa; border-radius: 5px;">
                <h3 style="margin: 0 0 10px 0; color: #333;">ℹ️ Informations complémentaires</h3>
                
                <c:if test="${fiche.primes > 0}">
                    <p style="margin: 5px 0;">
                        <strong>Primes :</strong> 
                        Les primes incluent les heures supplémentaires, bonus de performance, 
                        primes exceptionnelles, etc.
                    </p>
                </c:if>
                
                <c:if test="${fiche.deductions > 0}">
                    <p style="margin: 5px 0;">
                        <strong>Déductions :</strong> 
                        Les déductions peuvent inclure les retards, absences non justifiées, 
                        ou autres retenues sur salaire.
                    </p>
                </c:if>
            </div>
        </c:if>
        
        <!-- Section signatures -->
        <div class="signature-section">
            <div class="signature-box">
                <p><strong>L'Employeur</strong></p>
                <div class="signature-line"></div>
                <p>Date et Signature</p>
            </div>
            
            <div class="signature-box">
                <p><strong>L'Employé</strong></p>
                <div class="signature-line"></div>
                <p>Date et Signature</p>
            </div>
        </div>
        
        <!-- Pied de page -->
        <div class="fiche-footer">
            <p><strong>Ce document est confidentiel et destiné uniquement à son bénéficiaire.</strong></p>
            <p>CY-RH - Système de Gestion des Ressources Humaines</p>
            <p>Fiche générée le <fmt:formatDate value="${fiche.dateGeneration}" pattern="dd/MM/yyyy à HH:mm"/></p>
        </div>
    </div>
    
    <script>
        // Fonction pour imprimer automatiquement au chargement (optionnel)
        // window.onload = function() { window.print(); };
    </script>
</body>
</html>
