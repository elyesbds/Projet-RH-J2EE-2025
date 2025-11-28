<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Fiche de Paie - ${employer.prenom} ${employer.nom}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
    <style>
        body {
            background-color: #121212;
            font-family: 'Segoe UI', Arial, sans-serif;
            color: #e0e0e0;
            padding: 20px;
            
        }

        .fiche-container {
    max-width: 900px;
    margin: 30px auto 0 auto; /* Ajoute 30px en haut */
    background: linear-gradient(135deg, #1e1e1e, #1a1a1a);
    padding: 40px;
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(212, 175, 55, 0.2);
    border-radius: 8px;
}

        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 3px solid #d4af37;
            padding-bottom: 20px;
        }

        .header h1 {
            color: #b0b0b0;
            font-size: 18px;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .header h2 {
            color: #f0d479;
            font-size: 32px;
            margin-bottom: 10px;
            text-shadow: 0 0 10px rgba(212, 175, 55, 0.3);
        }

        .periode {
            color: #b0b0b0;
            font-size: 14px;
            margin: 5px 0;
        }

        .info-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }

        .info-box {
            background: radial-gradient(circle at 15% 20%, rgba(212, 175, 55, 0.08), transparent 45%), #151515;
            border: 1px solid rgba(212, 175, 55, 0.25);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
        }

        .info-box h3 {
            color: #f0d479;
            font-size: 16px;
            margin-bottom: 15px;
            border-bottom: 2px solid rgba(212, 175, 55, 0.4);
            padding-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .info-label {
            color: #b0b0b0;
            font-weight: 500;
        }

        .info-value {
            color: #e0e0e0;
            font-weight: bold;
        }

        .salaire-table {
            width: 100%;
            border-collapse: collapse;
            margin: 30px 0;
            background: #1a1a1a;
            border-radius: 8px;
            overflow: hidden;
        }

        .salaire-table th {
            background: linear-gradient(135deg, #d4af37, #c9921f);
            color: #0d0d0d;
            padding: 15px;
            text-align: left;
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
        }

        .salaire-table th:last-child {
            text-align: right;
        }

        .salaire-table td {
            padding: 15px;
            border-bottom: 1px solid #333;
            color: #e0e0e0;
        }

        .salaire-table td:last-child {
            text-align: right;
            font-weight: bold;
        }

        .salaire-table tr:hover {
            background-color: rgba(212, 175, 55, 0.05);
        }

        .montant-positif {
            color: #4bb543;
        }

        .montant-negatif {
            color: #cf6679;
        }

        .net-payer {
            background: linear-gradient(135deg, #4bb543, #3a9234) !important;
            color: white !important;
        }

        .net-payer td {
            font-size: 20px;
            font-weight: bold;
            padding: 20px 15px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        }

        .info-complementaires {
    background: radial-gradient(circle at 15% 20%, rgba(212, 175, 55, 0.08), transparent 45%), #151515;
    padding: 20px;
    border-radius: 8px;
    margin: 30px 0 20px 0; /* Réduit la marge */
    border-left: 4px solid #d4af37;
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
}

.absences-section {
    margin: 20px 0; /* Réduit la marge */
    padding: 20px;
    background: radial-gradient(circle at 15% 20%, rgba(255, 152, 0, 0.08), transparent 45%), #151515;
    border-left: 4px solid #ff9800;
    border-radius: 8px;
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
}

.signature-section {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 50px;
    margin-top: 30px; /* Réduit de 50px à 30px */
    page-break-inside: avoid; /* Évite la coupure en impression */
}

.footer {
    text-align: center;
    margin-top: 30px; /* Réduit de 50px à 30px */
    padding-top: 20px;
    border-top: 1px solid #333;
    color: #777;
    font-size: 12px;
    page-break-inside: avoid; /* Évite la coupure en impression */
}

/* Amélioration pour l'impression */
@media print {
    @page {
        margin: 1.5cm;
        size: A4;
    }

    /* Reset global pour forcer le fond blanc et texte noir */
    body, html {
        background-color: #ffffff !important;
        color: #000000 !important;
        font-family: 'Segoe UI', Arial, sans-serif;
        font-size: 11pt;
        margin: 0;
        padding: 0;
    }

    /* Masquer les éléments de navigation */
    .action-bar, nav, header, button, .btn, .navbar, a {
        display: none !important;
    }

    /* Conteneur principal sans ombres ni bordures superflues */
    .fiche-container {
        width: 100% !important;
        max-width: 100% !important;
        margin: 0 !important;
        padding: 0 !important;
        border: none !important;
        box-shadow: none !important;
        background: white !important;
    }

    /* En-tête épuré */
    .header {
        text-align: center;
        margin-bottom: 30px;
        border-bottom: 2px solid #d4af37; /* Trait doré conservé */
        padding-bottom: 15px;
    }
    .header h1 { 
        color: #333 !important; 
        font-size: 14pt; 
        margin: 0; 
        font-weight: normal; 
    }
    .header h2 { 
        color: #000 !important; 
        font-size: 26pt; 
        margin: 10px 0; 
        text-shadow: none !important; 
        text-transform: uppercase;
    }
    .periode { color: #555 !important; font-size: 12pt; }

    /* Blocs Employeur/Employé côte à côte (Bordures fines) */
    .info-section {
        display: flex !important;
        flex-direction: row;
        justify-content: space-between;
        gap: 20px;
        margin-bottom: 25px;
    }

    .info-box {
        flex: 1;
        background: transparent !important;
        border: 1px solid #000 !important; /* Cadre noir fin */
        border-radius: 4px;
        padding: 15px !important;
        box-shadow: none !important;
    }

    .info-box h3 {
        color: #000 !important;
        font-size: 12pt;
        background-color: #f0f0f0 !important; /* Gris très léger pour le titre */
        margin: -15px -15px 15px -15px;
        padding: 8px 15px;
        border-bottom: 1px solid #000;
        text-transform: uppercase;
    }

    .info-row {
        border-bottom: 1px dotted #ccc;
        padding: 6px 0;
    }
    .info-label { color: #444 !important; }
    .info-value { color: #000 !important; font-weight: bold; }

    /* Tableau des salaires clair */
    .salaire-table {
        width: 100%;
        border-collapse: collapse;
        margin: 20px 0;
        border: 1px solid #000;
    }

    .salaire-table th {
        background: #f8f8f8 !important; /* Fond gris clair */
        color: #000 !important;
        border-bottom: 2px solid #d4af37 !important; /* Touche dorée */
        padding: 10px;
        font-weight: bold;
        text-transform: uppercase;
        font-size: 10pt;
    }

    .salaire-table td {
        border-bottom: 1px solid #ddd;
        padding: 8px 10px;
        color: #000 !important;
    }

    /* Net à payer encadré proprement */
    .net-payer {
        background: transparent !important;
        color: #000 !important;
    }
    .net-payer td {
        border-top: 2px solid #000 !important;
        font-size: 16pt;
        font-weight: 900;
        padding: 15px 10px;
        background-color: #fff8e1 !important; /* Fond doré très pâle optionnel */
    }

    /* Section Infos complémentaires */
    .info-complementaires {
        border: 1px solid #ccc !important;
        background: none !important;
        box-shadow: none !important;
        margin-top: 20px;
        padding: 15px;
        page-break-inside: avoid;
    }
    .info-complementaires h3 { color: #000 !important; margin-top: 0; }

    /* Signatures */
    .signature-section {
        margin-top: 40px;
        display: flex;
        justify-content: space-between;
        page-break-inside: avoid;
    }
    .signature-box { width: 40%; }
    .signature-line {
        margin-top: 50px;
        border-top: 1px solid #000;
        padding-top: 5px;
        font-size: 10pt;
    }

    /* Footer bas de page */
    .footer {
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        text-align: center;
        font-size: 8pt;
        color: #666 !important;
        background: white;
        padding-top: 10px;
        border-top: 1px solid #eee;
    }
}
/* Masquer les boutons et header lors de l'impression */
@media print {
    button {
        display: none !important;
    }
    
    header, nav {
        display: none !important;
    }
    
    body {
        background: white !important;
    }
}
    </style>
</head>

<body>
<%@ include file="../includes/header.jsp" %>



<div class="fiche-container">
    <!-- En-tête -->
    <div class="header">
        <h1>CY-RH - Gestion des Ressources Humaines</h1>
        <h2>FICHE DE PAIE</h2>
        
        <!-- Boutons d'action -->
<div style="text-align: center; margin: 20px 0;">
    <button onclick="window.history.back()" style="background: #95a5a6; color: white; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; font-size: 1em; margin-right: 10px;">
        ← Retour à la liste
    </button>
    <button onclick="window.print()" style="background: #d4af37; color: #1a1a1a; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; font-size: 1em; font-weight: bold;">
        🖨 Imprimer
    </button>
</div>
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
        <p class="periode">Date de génération :
            <fmt:formatDate value="${fiche.dateGeneration}" pattern="dd/MM/yyyy" />
        </p>
    </div>

    <!-- Informations Employeur et Employé -->
    <div class="info-section">
        <!-- Employeur -->
        <div class="info-box">
            <h3>Employeur</h3>
            <div class="info-row">
                <span class="info-label">Entreprise :</span>
                <span class="info-value">CY-RH</span>
            </div>
            <div class="info-row">
                <span class="info-label">Département :</span>
                <span class="info-value">${departement != null ? departement.intitule :
                        'N/A'}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Fiche N° :</span>
                <span class="info-value">${fiche.id}</span>
            </div>
        </div>

        <!-- Employé -->
        <div class="info-box">
            <h3>Employé</h3>
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
            <td>
                <fmt:formatNumber value="${fiche.salaireBase}" minFractionDigits="2"
                                  maxFractionDigits="2" />
            </td>
        </tr>
        <tr>
            <td>+ Primes et bonus</td>
            <td class="montant-positif">+
                <fmt:formatNumber value="${fiche.primes}" minFractionDigits="2"
                                  maxFractionDigits="2" />
            </td>
        </tr>
        <tr>
            <td>- Déductions</td>
            <td class="montant-negatif">-
                <fmt:formatNumber value="${fiche.deductions}" minFractionDigits="2"
                                  maxFractionDigits="2" />
            </td>
        </tr>
        <tr class="net-payer">
            <td>NET À PAYER</td>
            <td>
                <fmt:formatNumber value="${fiche.netAPayer}" minFractionDigits="2"
                                  maxFractionDigits="2" /> €
            </td>
        </tr>
        </tbody>
    </table>

   <!-- Informations complémentaires -->
<div class="info-complementaires">
    <h3>INFORMATIONS COMPLÉMENTAIRES</h3>
    
    <p>
        <strong>Date d'embauche :</strong> 
        <fmt:formatDate value="${employer.dateEmbauche}" pattern="dd/MM/yyyy" />
    </p>
    
    <p>
        <strong>Ancienneté :</strong> 
        <%
            models.Employer employer = (models.Employer) request.getAttribute("employer");
            if (employer != null && employer.getDateEmbauche() != null) {
                java.util.Date dateEmbauche = employer.getDateEmbauche();
                java.util.Date today = new java.util.Date();
                
                long diffMillis = today.getTime() - dateEmbauche.getTime();
                long diffDays = diffMillis / (1000 * 60 * 60 * 24);
                
                int annees = (int) (diffDays / 365);
                int mois = (int) ((diffDays % 365) / 30);
                
                if (annees > 0) {
                    out.print(annees + " an" + (annees > 1 ? "s" : ""));
                    if (mois > 0) {
                        out.print(" et " + mois + " mois");
                    }
                } else if (mois > 0) {
                    out.print(mois + " mois");
                } else {
                    out.print("Moins d'un mois");
                }
            } else {
                out.print("Non disponible");
            }
        %>
    </p>
    
    <p>
        <strong>Salaire de base mensuel :</strong> 
        <fmt:formatNumber value="${employer.salaireBase}" type="number" minFractionDigits="2" maxFractionDigits="2" /> €
    </p>
</div>

    <!-- Section Absences -->
    <c:if test="${not empty absencesMois}">
        <div class="absences-section">
            <h3>Absences du mois</h3>
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
                        <td>
                            <fmt:formatDate value="${abs.dateDebut}" pattern="dd/MM/yyyy" />
                        </td>
                        <td>
                            <fmt:formatDate value="${abs.dateFin}" pattern="dd/MM/yyyy" />
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${abs.typeAbsence == 'CONGE'}">
                                    <span class="badge-conge">Congé</span>
                                </c:when>
                                <c:when test="${abs.typeAbsence == 'MALADIE'}">
                                    <span class="badge-maladie">Maladie</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-injustifiee">Absence injustifiée</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                                ${(abs.dateFin.time - abs.dateDebut.time) / (1000 * 60 * 60 * 24) +
                                        1}
                            jour(s)
                        </td>
                        <td>${abs.motif != null ? abs.motif : '-'}</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <p class="absences-note">
                <strong>Important :</strong> Seules les absences injustifiées sont déduites du
                salaire (200€
                par jour d'absence).
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
        Fiche générée le
        <fmt:formatDate value="${fiche.dateGeneration}" pattern="dd/MM/yyyy 'à' HH:mm" />
    </div>
</div>
</body>

</html>