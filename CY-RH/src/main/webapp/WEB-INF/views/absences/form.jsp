<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>${absence != null ? 'Modifier' : 'Ajouter'} une Absence - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
    <style>
        /* Icônes de calendrier en doré */
        input[type="date"]::-webkit-calendar-picker-indicator {
            filter: brightness(0) saturate(100%) invert(71%) sepia(45%) saturate(653%) hue-rotate(3deg) brightness(92%) contrast(87%);
            cursor: pointer;
        }
    </style>
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <h1>${absence != null ? 'Modifier' : 'Ajouter'} une Absence</h1>

    <!-- Message d'erreur -->
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

    <!-- Formulaire -->
    <form method="post"
          action="${absence != null ? pageContext.request.contextPath.concat('/absences/update') : pageContext.request.contextPath.concat('/absences')}"
          class="employee-form">

        <!-- ID caché pour la modification -->
        <c:if test="${absence != null}">
            <input type="hidden" name="id" value="${absence.id}">
        </c:if>

        <!-- Employé -->
        <div class="form-row">
            <div class="form-group">
                <label for="idEmployer">Employé *</label>
                <select id="idEmployer" name="idEmployer" required>
                    <option value="">-- Sélectionner un employé --</option>
                    <c:forEach var="emp" items="${employees}">
                        <option value="${emp.id}" ${(absence !=null && absence.idEmployer==emp.id)
                                || (absence==null && param.idEmployer==emp.id.toString()) ? 'selected'
                                : '' }>
                                ${emp.prenom} ${emp.nom} - ${emp.matricule}
                        </option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <!-- Dates -->
        <div class="form-row">
            <div class="form-group">
                <label for="dateDebut">Date de début *</label>
                <input type="date" id="dateDebut" name="dateDebut"
                       value="${absence != null ? absence.dateDebut : param.dateDebut}" required>
            </div>

            <div class="form-group">
                <label for="dateFin">Date de fin *</label>
                <input type="date" id="dateFin" name="dateFin"
                       value="${absence != null ? absence.dateFin : param.dateFin}" required>
            </div>
        </div>

        <!-- Type d'absence -->
        <div class="form-row">
            <div class="form-group">
                <label for="typeAbsence">Type d'absence *</label>
                <select id="typeAbsence" name="typeAbsence" required>
                    <option value="">-- Sélectionner un type --</option>
                    <option value="CONGE" ${(absence !=null && absence.typeAbsence=='CONGE' ) ||
                            (absence==null && param.typeAbsence=='CONGE' ) ? 'selected' : '' }>
                        Congé
                    </option>
                    <option value="MALADIE" ${(absence !=null && absence.typeAbsence=='MALADIE' ) ||
                            (absence==null && param.typeAbsence=='MALADIE' ) ? 'selected' : '' }>
                        Maladie
                    </option>
                    <option value="ABSENCE_INJUSTIFIEE" ${(absence !=null &&
                            absence.typeAbsence=='ABSENCE_INJUSTIFIEE' ) || (absence==null &&
                            param.typeAbsence=='ABSENCE_INJUSTIFIEE' ) ? 'selected' : '' }>
                        Absence injustifiée
                    </option>
                </select>
            </div>
        </div>

        <!-- Motif -->
        <div class="form-row">
            <div class="form-group">
                <label for="motif">Motif</label>
                <input type="text" id="motif" name="motif"
                       value="${absence != null ? absence.motif : param.motif}"
                       placeholder="Motif de l'absence (optionnel)">
            </div>
        </div>

        <!-- Boutons -->
        <div class="form-actions">
            <button type="submit" class="btn btn-primary">
                ${absence != null ? 'Mettre à jour' : 'Enregistrer'}
            </button>
            <a href="${pageContext.request.contextPath}/absences" class="btn btn-secondary"
               onclick="return confirm(' Êtes-vous sûr de vouloir annuler ?\n\nLes modifications non enregistrées seront perdues.')">
                Annuler
            </a>
        </div>
    </form>
</div>
</body>

</html>