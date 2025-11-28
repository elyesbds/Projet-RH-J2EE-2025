<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Ajouter Prime/Déduction - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
    <style>
        .fiche-info-box {
            background: radial-gradient(circle at 15% 20%, rgba(23, 162, 184, 0.1), transparent 45%), #151515;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            border-left: 4px solid #17a2b8;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
        }

        .fiche-info-box p {
            color: #e0e0e0;
            margin: 8px 0;
            line-height: 1.6;
        }

        .fiche-info-box strong {
            color: #17a2b8;
            font-weight: 600;
        }

        .warning-box {
            background: radial-gradient(circle at 15% 20%, rgba(255, 152, 0, 0.1), transparent 45%), #151515;
            padding: 20px;
            border-radius: 8px;
            margin: 25px 0;
            border-left: 4px solid #ff9800;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
        }

        .warning-box p {
            color: #e0e0e0;
            margin-bottom: 10px;
        }

        .warning-box strong {
            color: #ff9800;
            font-weight: 600;
        }

        .warning-box ul {
            margin: 10px 0;
            padding-left: 25px;
            color: #c9c9c9;
        }

        .warning-box li {
            margin: 6px 0;
            line-height: 1.5;
        }

        .warning-box li strong {
            color: #f0d479;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            margin-bottom: 10px;
            font-weight: bold;
            color: #d4af37;
            font-size: 15px;
        }

        .form-group input[type="number"] {
            width: 100%;
            padding: 14px;
            background-color: #121212;
            border: 1px solid #444;
            border-radius: 6px;
            font-size: 16px;
            color: #e0e0e0;
            transition: all 0.3s;
        }

        .form-group input[type="number"]:focus {
            outline: none;
            border-color: #d4af37;
            box-shadow: 0 0 8px rgba(212, 175, 55, 0.4);
            background-color: #1a1a1a;
        }

        .form-group small {
            display: block;
            margin-top: 8px;
            color: #b0b0b0;
            font-size: 13px;
            font-style: italic;
        }

        .form-actions {
            margin-top: 35px;
            display: flex;
            gap: 15px;
            justify-content: flex-start;
        }

        .form-actions .btn {
            padding: 12px 28px;
            font-size: 15px;
            font-weight: 600;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
        }

        .form-actions .btn-primary {
            background: linear-gradient(135deg, #e9c766, #c9921f);
            color: #0d0d0d;
            border: 1px solid rgba(212, 175, 55, 0.6);
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.35);
        }

        .form-actions .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 22px rgba(0, 0, 0, 0.4), 0 0 16px rgba(233, 199, 102, 0.35);
        }

        .form-actions .btn-secondary {
            background-color: #4a4a4a;
            color: white;
            border: 1px solid #555;
        }

        .form-actions .btn-secondary:hover {
            background-color: #5a5a5a;
            transform: translateY(-2px);
        }

        h1 {
            color: #d4af37;
            margin-bottom: 25px;
            border-bottom: 2px solid #d4af37;
            padding-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 28px;
        }
    </style>
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <h1>Ajouter Prime ou Déduction</h1>

    <!-- Message d'erreur simple -->
    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <!-- Messages d'erreurs multiples (validation) -->
    <c:if test="${not empty erreurs}">
        <div class="alert alert-error">
            <strong>Erreurs de validation :</strong>
            <ul style="margin: 10px 0 0 0;">
                <c:forEach var="erreur" items="${erreurs}">
                    <li>${erreur}</li>
                </c:forEach>
            </ul>
        </div>
    </c:if>

    <!-- Informations de la fiche -->
    <div class="fiche-info-box">
        <p><strong>Employé :</strong> ${employer.prenom} ${employer.nom} (${employer.matricule})</p>
        <p><strong>Période :</strong>
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
        <p><strong>Salaire de base :</strong>
            <fmt:formatNumber value="${fiche.salaireBase}" pattern="#,##0.00" /> €
        </p>
    </div>

    <!-- Formulaire -->
    <form action="${pageContext.request.contextPath}/fiches-paie/ajouter-prime" method="post"
          onsubmit="return confirmSave()">
        <input type="hidden" name="id" value="${fiche.id}">

        <div class="form-group">
            <label for="primes">Primes et Bonus (€)</label>
            <input type="number" id="primes" name="primes" step="0.01" min="0"
                   value="${param.primes != null ? param.primes : fiche.primes}" placeholder="0.00">
            <small>Heures supplémentaires, bonus de performance, primes exceptionnelles,
                etc.</small>
        </div>

        <div class="form-group">
            <label for="deductions">Déductions (€)</label>
            <input type="number" id="deductions" name="deductions" step="0.01" min="0"
                   value="${param.deductions != null ? param.deductions : fiche.deductions}"
                   placeholder="0.00">
            <small>Retards, absences non justifiées, retenues diverses, etc.</small>
        </div>

        <!-- Avertissement -->
        <div class="warning-box">
            <p><strong>Information importante :</strong></p>
            <ul>
                <li>Vous pouvez ajouter des <strong>primes</strong> (montant positif)</li>
                <li>Vous pouvez ajouter des <strong>déductions</strong> (montant positif)</li>
                <li>Le <strong>net à payer</strong> sera recalculé automatiquement</li>
                <li><strong>Vous ne pouvez pas modifier le salaire de base</strong></li>
            </ul>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">
                Enregistrer
            </button>
            <button type="button" class="btn btn-secondary" onclick="confirmCancel()">
                Annuler
            </button>
        </div>
    </form>
</div>

<script>
    function confirmSave() {
        return confirm('Confirmer l\'ajout de prime/déduction ?');
    }

    function confirmCancel() {
        if (confirm('Êtes-vous sûr d\'annuler ?\n\nLes modifications non enregistrées seront perdues.')) {
            window.location.href = '${pageContext.request.contextPath}/fiches-paie';
        }
    }
</script>
</body>

</html>