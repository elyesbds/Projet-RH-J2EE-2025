<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>${projet != null ? 'Modifier' : 'Créer'} un Projet - CY-RH</title>
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
    <h1>${projet != null ? 'Modifier' : 'Créer'} un Projet</h1>

    <!-- Message de succès -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

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


    <!-- Information pour les chefs de projet et chefs de département -->
    <c:if test="${isChefProjet && projet != null}">
        <div class="alert alert-info">
            En tant que Chef de Projet, vous pouvez modifier : l'état du projet, la date de fin
            prévue et la date de fin réelle.
        </div>
    </c:if>
    <c:if test="${isChefDept && projet != null}">
        <div class="alert alert-info">
            En tant que Chef de Département, vous pouvez modifier : le nom, l'état, les dates
            <c:if test="${projet.chefProjet == null}">
                , et attribuer un chef de projet
            </c:if>
            .
        </div>
    </c:if>

    <!-- Formulaire -->
    <form
            action="${projet != null ? pageContext.request.contextPath.concat('/projets/update') : pageContext.request.contextPath.concat('/projets')}"
            method="post" class="employee-form">

        <c:if test="${projet != null}">
            <input type="hidden" name="id" value="${projet.id}">
        </c:if>

        <!-- Nom du projet : Admin et Chef dept peuvent modifier, Chef de projet en lecture seule -->
        <div class="form-group">
            <label for="nomProjet">Nom du projet: *</label>
            <c:choose>
                <c:when test="${isChefProjet && projet != null}">
                    <!-- Chef de projet : lecture seule -->
                    <input type="text" id="nomProjet" name="nomProjet" value="${projet.nomProjet}"
                           readonly style="background-color: #f5f5f5; cursor: not-allowed; color: #333;">
                    <small style="color: #666;">Seul l'administrateur peut modifier le nom du
                        projet</small>
                </c:when>
                <c:otherwise>
                    <!-- Admin et Chef dept : peuvent modifier -->
                    <input type="text" id="nomProjet" name="nomProjet"
                           value="${projet != null ? projet.nomProjet : param.nomProjet}"
                           placeholder="Ex: Application RH, Site web..." required>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="form-row">
            <!-- État du projet : tout le monde peut modifier -->
            <div class="form-group">
                <label for="etatProjet">État du projet: *</label>
                <select id="etatProjet" name="etatProjet" required>
                    <c:choose>
                        <c:when test="${projet == null}">
                            <!-- MODE CRÉATION : Seulement PAS_COMMENCE et EN_COURS -->
                            <option value="PAS_COMMENCE" ${param.etatProjet=='PAS_COMMENCE'
                                    ? 'selected' : '' }>Pas commencé
                            </option>
                            <option value="EN_COURS" ${param.etatProjet=='EN_COURS' ? 'selected'
                                    : '' }>En cours
                            </option>
                        </c:when>
                        <c:otherwise>
                            <!-- MODE MODIFICATION : Tous les états -->
                            <option value="PAS_COMMENCE" ${projet.etatProjet=='PAS_COMMENCE'
                                    ? 'selected' : '' }>Pas commencé
                            </option>
                            <option value="EN_COURS" ${projet.etatProjet=='EN_COURS' ? 'selected'
                                    : '' }>En cours
                            </option>
                            <option value="TERMINE" ${projet.etatProjet=='TERMINE' ? 'selected' : ''
                                    }>Terminé
                            </option>
                            <option value="ANNULE" ${projet.etatProjet=='ANNULE' ? 'selected' : ''
                                    }>Annulé
                            </option>
                        </c:otherwise>
                    </c:choose>
                </select>
            </div>

            <!-- Chef de projet : Admin peut modifier, Chef dept peut attribuer si vide, Chef de projet en lecture seule -->
            <!-- Ne pas afficher si le projet est ANNULE -->
            <c:if test="${projet == null || projet.etatProjet != 'ANNULE'}">
                <div class="form-group">
                    <label for="chefProjet">Chef de projet:</label>
                    <c:choose>
                        <c:when test="${isChefProjet && projet != null}">
                            <!-- Chef de projet : lecture seule -->
                            <select id="chefProjet" name="chefProjet" disabled
                                    style="background-color: #f5f5f5; cursor: not-allowed; color: #333;">
                                <option value="">-- Aucun --</option>
                                <c:forEach var="emp" items="${employees}">
                                    <option value="${emp.id}" ${projet !=null &&
                                            projet.chefProjet==emp.id ? 'selected' : '' }>
                                            ${emp.prenom} ${emp.nom} (${emp.poste})
                                    </option>
                                </c:forEach>
                            </select>
                            <!-- Champ caché pour envoyer la valeur malgré le disabled -->
                            <input type="hidden" name="chefProjet" value="${projet.chefProjet}">
                            <small style="color: #666;">Seul l'administrateur peut modifier le chef
                                de projet</small>
                        </c:when>
                        <c:when test="${isChefDept && projet != null}">
                            <!-- Chef dept : peut modifier le chef -->
                            <select id="chefProjet" name="chefProjet">
                                <option value="">-- Aucun --</option>
                                <c:forEach var="emp" items="${employees}">
                                    <option value="${emp.id}" ${(projet.chefProjet==emp.id) ||
                                            (param.chefProjet==emp.id.toString()) ? 'selected' : '' }>
                                            ${emp.prenom} ${emp.nom} (${emp.poste})
                                    </option>
                                </c:forEach>
                            </select>
                            <small style="color: #28a745;">Vous pouvez attribuer ou changer le chef
                                de projet</small>
                        </c:when>
                        <c:otherwise>
                            <!-- Admin OU Chef dept (si pas de chef) : peut modifier -->
                            <select id="chefProjet" name="chefProjet">
                                <option value="">-- Aucun --</option>
                                <c:forEach var="emp" items="${employees}">
                                    <option value="${emp.id}" ${(projet !=null &&
                                            projet.chefProjet==emp.id) || (projet==null &&
                                            param.chefProjet==emp.id.toString()) ? 'selected' : '' }>
                                            ${emp.prenom} ${emp.nom} (${emp.poste})
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${isChefDept && projet != null}">
                                <small style="color: #28a745;">Vous pouvez attribuer un chef de
                                    projet à ce projet</small>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <!-- Message si ANNULE -->
            <c:if test="${projet != null && projet.etatProjet == 'ANNULE'}">
                <div class="form-group">
                    <label>Chef de projet:</label>
                    <p style="color: #dc3545; font-style: italic; margin-top: 8px;">
                        Un projet annulé ne peut pas avoir de chef de projet.
                    </p>
                </div>
            </c:if>
        </div>

        <div class="form-row">
            <!-- Date de début : Admin peut modifier, Chef de projet en lecture seule -->
            <div class="form-group">
                <label for="dateDebut">Date de début: *</label>
                <c:choose>
                    <c:when test="${(isChefProjet || isChefDept) && projet != null}">
                        <!-- Chef de projet : lecture seule -->
                        <input type="date" id="dateDebut" name="dateDebut"
                               value="<fmt:formatDate value='${projet.dateDebut}' pattern='yyyy-MM-dd'/>"
                               readonly style="background-color: #f5f5f5; cursor: not-allowed; color: #333;">
                        <small style="color: #666;">Seul l'administrateur peut modifier la date de
                            début</small>
                    </c:when>
                    <c:otherwise>
                        <!-- Admin : peut modifier -->
                        <input type="date" id="dateDebut" name="dateDebut"
                               value="${projet != null ? projet.dateDebut : param.dateDebut}" required>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Date de fin prévue : tout le monde peut modifier -->
            <div class="form-group">
                <label for="dateFinPrevue">Date de fin prévue:</label>
                <input type="date" id="dateFinPrevue" name="dateFinPrevue"
                       value="${projet != null ? projet.dateFinPrevue : param.dateFinPrevue}">
            </div>
        </div>

        <c:if test="${projet != null}">
            <div class="form-row">
                <!-- Date de fin réelle : tout le monde peut modifier -->
                <div class="form-group">
                    <label for="dateFinReelle">Date de fin réelle:</label>
                    <input type="date" id="dateFinReelle" name="dateFinReelle"
                           value="${projet != null ? projet.dateFinReelle : param.dateFinReelle}">
                    <small>À remplir uniquement si le projet est terminé</small>
                </div>

                <!-- Département : Admin peut modifier, Chef de département et Chef de projet en lecture seule -->
                <div class="form-group">
                    <label for="idDepartement">Département:</label>
                    <c:choose>
                        <c:when test="${isChefProjet || isChefDept}">
                            <!-- Chef de projet OU Chef de département : lecture seule -->
                            <select id="idDepartement" name="idDepartement" disabled
                                    style="background-color: #f5f5f5; cursor: not-allowed; color: #333;">
                                <option value="">-- Aucun --</option>
                                <c:forEach var="dept" items="${departements}">
                                    <option value="${dept.id}" ${projet !=null &&
                                            projet.idDepartement==dept.id ? 'selected' : '' }>
                                            ${dept.intitule}
                                    </option>
                                </c:forEach>
                            </select>
                            <small style="color: #666;">Seul l'administrateur peut modifier le
                                département</small>
                        </c:when>
                        <c:otherwise>
                            <!-- Admin : peut modifier -->
                            <select id="idDepartement" name="idDepartement">
                                <option value="">-- Aucun --</option>
                                <c:forEach var="dept" items="${departements}">
                                    <option value="${dept.id}" ${projet !=null &&
                                            projet.idDepartement==dept.id ? 'selected' : '' }>
                                            ${dept.intitule}
                                    </option>
                                </c:forEach>
                            </select>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>

        <!-- Département pour la création -->
        <c:if test="${projet == null}">
            <div class="form-group">
                <label for="idDepartement">Département:</label>
                <c:choose>
                    <c:when test="${isChefDept}">
                        <!-- Chef de département : département en lecture seule -->
                        <select id="idDepartement" name="idDepartement" required
                                style="background-color: #f5f5f5; pointer-events: none;">
                            <c:forEach var="dept" items="${departements}">
                                <option value="${dept.id}" selected>
                                        ${dept.intitule}
                                </option>
                            </c:forEach>
                        </select>
                        <small style="color: #666;">Vous ne pouvez créer des projets que pour votre
                            département</small>
                    </c:when>
                    <c:otherwise>
                        <!-- Admin : peut choisir -->
                        <select id="idDepartement" name="idDepartement">
                            <option value="">-- Aucun --</option>
                            <c:forEach var="dept" items="${departements}">
                                <option value="${dept.id}"
                                    ${(param.idDepartement==dept.id.toString()) ||
                                            (preselectedDeptId==dept.id) ? 'selected' : '' }>
                                        ${dept.intitule}
                                </option>
                            </c:forEach>
                        </select>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <!-- Boutons d'action -->
        <div class="form-actions">
            <button type="submit" class="btn btn-primary">
                ${projet != null ? 'Enregistrer' : 'Créer'}
            </button>
            <a href="${pageContext.request.contextPath}/projets" class="btn btn-secondary"
               onclick="return confirm('Êtes-vous sûr de vouloir annuler ? Les modifications seront perdues.')">
                Annuler
            </a>
        </div>
    </form>
</div>
<script>
    // Validation des dates
    const dateDebut = document.getElementById('dateDebut');
    const dateFinPrevue = document.getElementById('dateFinPrevue');
    const dateFinReelle = document.getElementById('dateFinReelle');
    const form = document.querySelector('form');

    // Fonction de validation
    function validateDates(e) {
        const debut = dateDebut.value;

        // Vérifier date fin prévue
        if (dateFinPrevue && dateFinPrevue.value && debut) {
            if (dateFinPrevue.value < debut) {
                e.preventDefault();
                alert('La date de fin prévue doit être postérieure ou égale à la date de début');
                dateFinPrevue.focus();
                return false;
            }
        }

        // Vérifier date fin réelle (si elle existe)
        if (dateFinReelle && dateFinReelle.value && debut) {
            if (dateFinReelle.value < debut) {
                e.preventDefault();
                alert('La date de fin réelle doit être postérieure ou égale à la date de début');
                dateFinReelle.focus();
                return false;
            }
        }

        return true;
    }

    // Ajouter l'événement de validation au formulaire
    if (form) {
        form.addEventListener('submit', validateDates);
    }

    // Mettre à jour l'attribut "min" dynamiquement
    if (dateDebut) {
        dateDebut.addEventListener('change', function () {
            if (dateFinPrevue) {
                dateFinPrevue.setAttribute('min', this.value);
            }
            if (dateFinReelle) {
                dateFinReelle.setAttribute('min', this.value);
            }
        });

        // Initialiser "min" au chargement de la page
        if (dateDebut.value) {
            if (dateFinPrevue) {
                dateFinPrevue.setAttribute('min', dateDebut.value);
            }
            if (dateFinReelle) {
                dateFinReelle.setAttribute('min', dateDebut.value);
            }
        }
    }
</script>
</body>

</html>