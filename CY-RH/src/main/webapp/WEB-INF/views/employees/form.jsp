<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>${employee != null ? 'Modifier' : 'Ajouter'} un Employé - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
</head>

<body>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <h1>${employee != null ? 'Modifier' : 'Ajouter'} un Employé</h1>

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

    <!-- Formulaire -->
    <form
            action="${employee != null ? pageContext.request.contextPath.concat('/employees/update') : pageContext.request.contextPath.concat('/employees')}"
            method="post" class="employee-form">

        <!-- ID caché pour la modification -->
        <c:if test="${employee != null}">
            <input type="hidden" name="id" value="${employee.id}">
        </c:if>

        <div class="form-row">
            <div class="form-group">
                <label for="matricule">Matricule:</label>
                <input type="text" id="matricule" name="matricule"
                       value="${employee != null ? employee.matricule : param.matricule}"
                       placeholder="Ex: EMP001">
            </div>

            <div class="form-group">
                <label for="nom">Nom: *</label>
                <input type="text" id="nom" name="nom"
                       value="${employee != null ? employee.nom : param.nom}" required>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="prenom">Prénom: *</label>
                <input type="text" id="prenom" name="prenom"
                       value="${employee != null ? employee.prenom : param.prenom}" required>
            </div>

            <div class="form-group">
                <label for="email">Email: *</label>
                <input type="email" id="email" name="email"
                       value="${employee != null ? employee.email : param.email}" required>
            </div>
        </div>

        <!-- LIGNE TÉLÉPHONE + MOT DE PASSE -->
        <div class="form-row">
            <div class="form-group">
                <label for="telephone">Téléphone:</label>
                <input type="tel" id="telephone" name="telephone"
                       value="${employee != null ? employee.telephone : param.telephone}"
                       placeholder="0612345678">
            </div>

            <c:choose>
                <%-- MODE CRÉATION : Champ mot de passe obligatoire --%>
                <c:when test="${employee == null}">
                    <div class="form-group">
                        <label for="password">Mot de passe: *</label>
                        <div style="position: relative;">
                            <input type="password" id="password" name="password"
                                   placeholder="Mot de passe (min 4 caractères)"
                                   style="padding-right: 40px; background-color: #121212; border: 1px solid #444; color: #e0e0e0;"
                                   required>
                            <button type="button"
                                    onclick="togglePasswordVisibility('password', 'togglePasswordIcon')"
                                    style="position: absolute; right: 10px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; font-size: 18px; color: #d4af37;"
                                    title="Afficher/Masquer le mot de passe">
                                <span id="togglePasswordIcon"
                                      style="font-size: 0.8em; cursor: pointer; color: #d4af37;">Voir</span>
                            </button>
                        </div>
                    </div>
                </c:when>

                <%-- MODE MODIFICATION : Champ nouveau mot de passe (optionnel) --%>
                <c:otherwise>
                    <div class="form-group">
                        <label for="password">Nouveau mot de passe: <span
                                style="color: #b0b0b0; font-weight: normal;">(laisser vide pour ne pas changer)</span></label>
                        <div style="position: relative;">
                            <input type="password" id="password" name="password"
                                   placeholder="Nouveau mot de passe (min 4 caractères)"
                                   style="padding-right: 40px; background-color: #121212; border: 1px solid #444; color: #e0e0e0;">
                            <button type="button"
                                    onclick="togglePasswordVisibility('password', 'togglePasswordIcon')"
                                    style="position: absolute; right: 10px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; font-size: 18px; color: #d4af37;"
                                    title="Afficher/Masquer le mot de passe">
                                <span id="togglePasswordIcon"
                                      style="font-size: 0.8em; cursor: pointer; color: #d4af37;">Voir</span>
                            </button>
                        </div>
                        <small style="color: #b0b0b0; display: block; margin-top: 5px;">
                            Le mot de passe actuel ne sera modifié que si vous remplissez ce champ.
                        </small>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="poste">Poste: *</label>
                <input type="text" id="poste" name="poste"
                       value="${employee != null ? employee.poste : param.poste}"
                       placeholder="Ex: Développeur" required>
            </div>

            <div class="form-group">
                <label for="grade">Grade: *</label>
                <select id="grade" name="grade" required>
                    <option value="">-- Sélectionner --</option>
                    <option value="JUNIOR" ${(employee != null && employee.grade == 'JUNIOR') ||
                            (employee == null && param.grade == 'JUNIOR') ? 'selected' : ''}>Junior
                    </option>
                    <option value="CONFIRME" ${(employee != null && employee.grade == 'CONFIRME') ||
                            (employee == null && param.grade == 'CONFIRME') ? 'selected' : ''}>
                        Confirmé</option>
                    <option value="SENIOR" ${(employee != null && employee.grade == 'SENIOR') ||
                            (employee == null && param.grade == 'SENIOR') ? 'selected' : ''}>Senior
                    </option>
                    <option value="MANAGER" ${(employee != null && employee.grade == 'MANAGER') ||
                            (employee == null && param.grade == 'MANAGER') ? 'selected' : ''}>Manager
                    </option>
                    <option value="DIRECTEUR" ${(employee != null && employee.grade == 'DIRECTEUR') ||
                            (employee == null && param.grade == 'DIRECTEUR') ? 'selected' : ''}>
                        Directeur</option>
                </select>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="salaireBase">Salaire de base (€): *</label>
                <input type="number" id="salaireBase" name="salaireBase" step="0.01" min="0"
                       value="${employee != null ? employee.salaireBase : param.salaireBase}"
                       required>
            </div>

            <div class="form-group">
                <label for="dateEmbauche">Date d'embauche: *</label>
                <input type="date" id="dateEmbauche" name="dateEmbauche"
                       value="${employee != null ? employee.dateEmbauche : param.dateEmbauche}"
                       required>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="idDepartement">Département:</label>
                <select id="idDepartement" name="idDepartement">
                    <option value="">-- Aucun --</option>
                    <c:forEach var="dept" items="${departements}">
                        <option value="${dept.id}" ${(employee != null && employee.idDepartement != null &&
                                employee.idDepartement.toString() == dept.id.toString()) ||
                                (employee == null && param.idDepartement == dept.id.toString())
                                ? 'selected' : ''}>
                                ${dept.intitule}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label for="role">Rôle: *</label>
                <select id="role" name="role" required>
                    <option value="EMPLOYE" ${(employee == null && (param.role == 'EMPLOYE' || empty param.role)) ||
                            (employee != null && employee.role == 'EMPLOYE')
                            ? 'selected' : ''}>Employé</option>
                    <option value="CHEF_PROJET" ${(employee == null && param.role == 'CHEF_PROJET') ||
                            (employee != null && employee.role == 'CHEF_PROJET') ? 'selected' : ''}>
                        Chef de Projet</option>
                    <option value="CHEF_DEPT" ${(employee == null && param.role == 'CHEF_DEPT') ||
                            (employee != null && employee.role == 'CHEF_DEPT') ? 'selected' : ''}>
                        Chef de Département</option>
                    <option value="ADMIN" ${(employee == null && param.role == 'ADMIN') ||
                            (employee != null && employee.role == 'ADMIN') ? 'selected' : ''}>
                        Administrateur</option>
                </select>
            </div>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">
                ${employee != null ? 'Mettre à jour' : 'Créer'}
            </button>
            <a href="${pageContext.request.contextPath}/employees" class="btn btn-secondary"
               onclick="return confirm('Êtes-vous sûr de vouloir annuler ?\n\nLes modifications non enregistrées seront perdues.')">
                Annuler
            </a>
        </div>
    </form>
</div>

<script>
    function togglePasswordVisibility(inputId, iconId) {
        var passwordInput = document.getElementById(inputId);
        var icon = document.getElementById(iconId);

        if (passwordInput.type === "password") {
            passwordInput.type = "text";
            icon.textContent = "Cacher";
        } else {
            passwordInput.type = "password";
            icon.textContent = "Voir";
        }
    }
</script>
</body>

</html>