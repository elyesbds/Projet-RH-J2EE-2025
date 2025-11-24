<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Fiche de Paie - ${employer.prenom} ${employer.nom}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
        }
        
        .fiche-container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 3px solid #007bff;
            padding-bottom: 20px;
        }
        
        .header h1 {
            color: #333;
            font-size: 18px;
            margin-bottom: 5px;
        }
        
        .header h2 {
            color: #007bff;
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .periode {
            color: #666;
            font-size: 14px;
        }
        
        .info-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }
        
        .info-box {
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 5px;
        }
        
        .info-box h3 {
            color: #007bff;
            font-size: 16px;
            margin-bottom: 15px;
            border-bottom: 2px solid #007bff;
            padding-bottom: 8px;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            color: #666;
            font-weight: 500;
        }
        
        .info-value {
            color: #333;
            font-weight: bold;
        }
        
        .salaire-table {
            width: 100%;
            border-collapse: collapse;
            margin: 30px 0;
        }
        
        .salaire-table th {
            background-color: #007bff;
            color: white;
            padding: 15px;
            text-align: left;
            font-size: 16px;
        }
        
        .salaire-table th:last-child {
            text-align: right;
        }
        
        .salaire-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        
        .salaire-table td:last-child {
            text-align: right;
            font-weight: bold;
        }
        
        .salaire-table tr:hover {
            background-color: #f8f9fa;
        }
        
        .montant-positif {
            color: #28a745;
        }
        
        .montant-negatif {
            color: #dc3545;
        }
        
        .net-payer {
            background-color: #28a745 !important;
            color: white !important;
            font-size: 18px;
        }
        
        .net-payer td {
            font-size: 18px;
            font-weight: bold;
            padding: 20px 15px;
        }
        
        .info-complementaires {
            background-color: #e8f4fd;
            padding: 20px;
            border-radius: 5px;
            margin: 30px 0;
            border-left: 4px solid #007bff;
        }
        
        .info-complementaires h3 {
            color: #007bff;
            margin-bottom: 10px;
            font-size: 16px;
        }
        
        .info-complementaires p {
            color: #555;
            line-height: 1.6;
            margin: 5px 0;
        }
        
        .info-complementaires strong {
            color: #333;
        }
        
        /* Section Absences */
        .absences-section {
            margin: 30px 0;
            padding: 20px;
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            border-radius: 5px;
        }
        
        .absences-section h3 {
            color: #856404;
            margin-bottom: 15px;
            font-size: 16px;
        }
        
        .absences-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        
        .absences-table th {
            background-color: #ffc107;
            color: #333;
            padding: 10px;
            text-align: left;
            border: 1px solid #ddd;
        }
        
        .absences-table td {
            padding: 8px 10px;
            border: 1px solid #ddd;
            background-color: white;
        }
        
        .absences-table tr:hover td {
            background-color: #fff9e6;
        }
        
        .badge-conge {
            color: #28a745;
            font-weight: bold;
        }
        
        .badge-maladie {
            color: #6c757d;
            font-weight: bold;
        }
        
        .badge-injustifiee {
            color: #dc3545;
            font-weight: bold;
        }
        
        .absences-note {
            margin-top: 10px;
            font-size: 12px;
            color: #856404;
        }
        
        .signature-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 50px;
            margin-top: 50px;
        }
        
        .signature-box {
            text-align: center;
        }
        
        .signature-box h4 {
            color: #333;
            margin-bottom: 40px;
            font-size: 14px;
        }
        
        .signature-line {
            border-top: 2px solid #333;
            padding-top: 10px;
            color: #666;
            font-size: 12px;
        }
        
        .footer {
            text-align: center;
            margin-top: 50px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #999;
            font-size: 12px;
        }
        
        .action-buttons {
            text-align: center;
            margin-bottom: 20px;
        }
        
        .btn {
            padding: 10px 20px;
            margin: 0 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background-color: #007bff;
            color: white;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-success {
            background-color: #28a745;
            color: white;
        }
        
        @media print {
            .action-buttons {
                display: none;
            }
            body {
                background: white;
                padding: 0;
            }
            .fiche-container {
                box-shadow: none;
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="fiche-container">
        <!-- Boutons d'action -->
        <div class="action-buttons">
            <button onclick="window.print()" class="btn btn-primary">🖨️ Imprimer la Fiche</button>
            <a href="${pageContext.request.contextPath}/fiches-paie" class="btn btn-secondary">⬅️ Retour à la Liste</a>
            <a href="${pageContext.request.contextPath}/mon-compte" class="btn btn-success">👤 Mon Compte</a>
        </div>
        
        <!-- En-tête -->
        <div class="header">
            <h1>ENTREPRISE CY-RH</h1>
            <h2>FICHE DE PAIE</h2>
            <p class="periode">
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
            </p>
            <p class="periode">Date de génération : <fmt:formatDate value="${fiche.dateGeneration}" pattern="dd/MM/yyyy"/></p>
        </div>
        
        <!-- Informations Employeur et Employé -->
        <div class="info-section">
            <!-- Employeur -->
            <div class="info-box">
                <h3>👔 EMPLOYEUR</h3>
                <div class="info-row">
                    <span class="info-label">Entreprise :</span>
                    <span class="info-value">CY-RH</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Département :</span>
                    <span class="info-value">${departement != null ? departement.intitule : 'N/A'}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Fiche N° :</span>
                    <span class="info-value">${fiche.id}</span>
                </div>
            </div>
            
            <!-- Employé -->
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
        
        <!-- Tableau des salaires -->
        <table class="salaire-table">
            <thead>
                <tr>
                    <th>Libellé</th>
                    <th>Montant (€)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Salaire de base</td>
                    <td><fmt:formatNumber value="${fiche.salaireBase}" minFractionDigits="2" maxFractionDigits="2"/></td>
                </tr>
                <tr>
                    <td>+ Primes et bonus</td>
                    <td class="montant-positif">+ <fmt:formatNumber value="${fiche.primes}" minFractionDigits="2" maxFractionDigits="2"/></td>
                </tr>
                <tr>
                    <td>- Déductions</td>
                    <td class="montant-negatif">- <fmt:formatNumber value="${fiche.deductions}" minFractionDigits="2" maxFractionDigits="2"/></td>
                </tr>
                <tr class="net-payer">
                    <td>NET À PAYER</td>
                    <td><fmt:formatNumber value="${fiche.netAPayer}" minFractionDigits="2" maxFractionDigits="2"/> €</td>
                </tr>
            </tbody>
        </table>
        
        <!-- Informations complémentaires -->
        <div class="info-complementaires">
            <h3>ℹ️ Informations complémentaires</h3>
            <p><strong>Primes :</strong> Les primes incluent les heures supplémentaires, bonus de performance, primes exceptionnelles, etc.</p>
            <p><strong>Déductions :</strong> Les déductions peuvent inclure les retards, absences non justifiées, ou autres retenues sur salaire.</p>
        </div>
        <!-- DEBUG : Nombre d'absences 
<p style="color: red; font-weight: bold;">
    🔍 DEBUG : ${not empty absencesMois ? absencesMois.size() : 0} absence(s) trouvée(s)
</p>-->
        <!-- Section Absences du mois - CORRECTION ICI : changer absencesMois en absences -->
        <c:if test="${absencesMois != null && absencesMois.size() > 0}">
    <div class="absences-section">
        <h3>📅 Absences du mois</h3>
        <table class="absences-table">
            <thead>
                <tr>
                    <th>Date début</th>
                    <th>Date fin</th>
                    <th>Type</th>
                    <th>Jours</th>
                    <th>Motif</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="abs" items="${absencesMois}">
                    <tr>
                        <td><fmt:formatDate value="${abs.dateDebut}" pattern="dd/MM/yyyy"/></td>
                        <td><fmt:formatDate value="${abs.dateFin}" pattern="dd/MM/yyyy"/></td>
                        <td>
                            <c:choose>
                                <c:when test="${abs.typeAbsence == 'CONGE'}">
                                    <span class="badge-conge">✅ Congé</span>
                                </c:when>
                                <c:when test="${abs.typeAbsence == 'MALADIE'}">
                                    <span class="badge-maladie">🏥 Maladie</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-injustifiee">❌ Absence injustifiée</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            ${(abs.dateFin.time - abs.dateDebut.time) / (1000 * 60 * 60 * 24) + 1} jour(s)
                        </td>
                        <td>${abs.motif != null ? abs.motif : '-'}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        <p class="absences-note">
            ⚠️ <strong>Important :</strong> Seules les absences injustifiées sont déduites du salaire (200€ par jour d'absence).
        </p>
    </div>
</c:if>
        
        <!-- Signatures -->
        <div class="signature-section">
            <div class="signature-box">
                <h4>L'Employeur</h4>
                <div class="signature-line">Date et Signature</div>
            </div>
            <div class="signature-box">
                <h4>L'Employé</h4>
                <div class="signature-line">Date et Signature</div>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="footer">
            Ce document est confidentiel et destiné uniquement à son bénéficiaire.<br>
            CY-RH - Système de Gestion des Ressources Humaines<br>
            Fiche générée le <fmt:formatDate value="${fiche.dateGeneration}" pattern="dd/MM/yyyy 'à' HH:mm"/>
        </div>
    </div>
</body>
</html>