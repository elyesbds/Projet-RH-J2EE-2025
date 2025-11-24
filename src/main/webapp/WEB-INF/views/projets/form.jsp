<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${projet != null ? 'Modifier' : 'Créer'} un Projet - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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
        
        <!-- Message d'erreur -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <!-- Information pour les chefs de projet -->
        <c:if test="${isChefProjet && projet != null}">
            <div class="alert alert-info">
                En tant que Chef de Projet, vous pouvez modifier : l'état du projet, la date de fin prévue et la date de fin réelle.
            </div>
        </c:if>
        
        <!-- Formulaire -->
        <form action="${projet != null ? pageContext.request.contextPath.concat('/projets/update') : pageContext.request.contextPath.concat('/projets')}" 
              method="post" class="employee-form">
            
            <c:if test="${projet != null}">
                <input type="hidden" name="id" value="${projet.id}">
            </c:if>
            
            <!-- NOM DU PROJET : Admin peut modifier, Chef de Projet en lecture seule -->
            <div class="form-group">
                <label for="nomProjet">Nom du projet: *</label>
                <c:choose>
                    <c:when test="${isChefProjet && projet != null}">
                        <!-- Chef de projet : lecture seule -->
                        <input type="text" id="nomProjet" name="nomProjet" 
                               value="${projet.nomProjet}" 
                               readonly style="background-color: #f5f5f5; cursor: not-allowed;">
                        <small style="color: #666;">⚠️ Seul l'administrateur peut modifier le nom du projet</small>
                    </c:when>
                    <c:otherwise>
                        <!-- Admin : peut modifier -->
                        <input type="text" id="nomProjet" name="nomProjet" 
                               value="${projet != null ? projet.nomProjet : ''}" 
                               placeholder="Ex: Application RH, Site web..."
                               required>
                    </c:otherwise>
                </c:choose>
            </div>
            
 				<div class="form-row">
                <!-- ÉTAT DU PROJET : Tout le monde peut modifier -->
                <div class="form-group">
                    <label for="etatProjet">État du projet: *</label>
                    <select id="etatProjet" name="etatProjet" required>
                        <option value="EN_COURS" ${projet == null || projet.etatProjet == 'EN_COURS' ? 'selected' : ''}>En cours</option>
                        <!-- TERMINÉ : visible uniquement en MODIFICATION -->
                        <c:if test="${projet != null}">
                            <option value="TERMINE" ${projet.etatProjet == 'TERMINE' ? 'selected' : ''}>Terminé</option>
                        </c:if>
                        <option value="ANNULE" ${projet != null && projet.etatProjet == 'ANNULE' ? 'selected' : ''}>Annulé</option>
                    </select>
                </div>
                
                <!-- CHEF DE PROJET : Admin peut modifier, Chef de Projet en lecture seule -->
                <div class="form-group">
                    <label for="chefProjet">Chef de projet:</label>
                    <c:choose>
                        <c:when test="${isChefProjet && projet != null}">
                            <!-- Chef de projet : lecture seule -->
                            <select id="chefProjet" name="chefProjet" disabled style="background-color: #f5f5f5; cursor: not-allowed;">
                                <option value="">-- Aucun --</option>
                                <c:forEach var="emp" items="${employees}">
                                    <option value="${emp.id}" 
                                            ${projet != null && projet.chefProjet == emp.id ? 'selected' : ''}>
                                        ${emp.prenom} ${emp.nom} (${emp.poste})
                                    </option>
                                </c:forEach>
                            </select>
                            <small style="color: #666;">⚠️ Seul l'administrateur peut modifier le chef de projet</small>
                        </c:when>
                        <c:otherwise>
                            <!-- Admin : peut modifier -->
                            <select id="chefProjet" name="chefProjet">
                                <option value="">-- Aucun --</option>
                                <c:forEach var="emp" items="${employees}">
                                    <option value="${emp.id}" 
                                            ${projet != null && projet.chefProjet == emp.id ? 'selected' : ''}>
                                        ${emp.prenom} ${emp.nom} (${emp.poste})
                                    </option>
                                </c:forEach>
                            </select>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            
            <div class="form-row">
                <!-- DATE DE DÉBUT : Admin peut modifier, Chef de Projet en lecture seule -->
                <div class="form-group">
                    <label for="dateDebut">Date de début: *</label>
                    <c:choose>
                        <c:when test="${isChefProjet && projet != null}">
                            <!-- Chef de projet : lecture seule -->
                            <input type="date" id="dateDebut" name="dateDebut" 
                                   value="<fmt:formatDate value='${projet.dateDebut}' pattern='yyyy-MM-dd'/>" 
                                   readonly style="background-color: #f5f5f5; cursor: not-allowed;">
                            <small style="color: #666;">⚠️ Seul l'administrateur peut modifier la date de début</small>
                        </c:when>
                        <c:otherwise>
                            <!-- Admin : peut modifier -->
                            <input type="date" id="dateDebut" name="dateDebut" 
                                   value="<fmt:formatDate value='${projet.dateDebut}' pattern='yyyy-MM-dd'/>" 
                                   required>
                        </c:otherwise>
                    </c:choose>
                </div>
                
                <!-- DATE DE FIN PRÉVUE : Tout le monde peut modifier -->
                <div class="form-group">
                    <label for="dateFinPrevue">Date de fin prévue:</label>
                    <input type="date" id="dateFinPrevue" name="dateFinPrevue" 
                           value="<fmt:formatDate value='${projet.dateFinPrevue}' pattern='yyyy-MM-dd'/>">
                </div>
            </div>
            
            <c:if test="${projet != null}">
                <div class="form-row">
                    <!-- DATE DE FIN RÉELLE : Tout le monde peut modifier -->
                    <div class="form-group">
                        <label for="dateFinReelle">Date de fin réelle:</label>
                        <input type="date" id="dateFinReelle" name="dateFinReelle" 
                               value="<fmt:formatDate value='${projet.dateFinReelle}' pattern='yyyy-MM-dd'/>">
                        <small>À remplir uniquement si le projet est terminé</small>
                    </div>
                    
                    <!-- DÉPARTEMENT : Admin peut modifier, Chef de Projet en lecture seule -->
                    <div class="form-group">
                        <label for="idDepartement">Département:</label>
                        <c:choose>
                            <c:when test="${isChefProjet}">
                                <!-- Chef de projet : lecture seule -->
                                <select id="idDepartement" name="idDepartement" disabled style="background-color: #f5f5f5; cursor: not-allowed;">
                                    <option value="">-- Aucun --</option>
                                    <c:forEach var="dept" items="${departements}">
                                        <option value="${dept.id}" 
                                                ${projet != null && projet.idDepartement == dept.id ? 'selected' : ''}>
                                            ${dept.intitule}
                                        </option>
                                    </c:forEach>
                                </select>
                                <small style="color: #666;">⚠️ Seul l'administrateur peut modifier le département</small>
                            </c:when>
                            <c:otherwise>
                                <!-- Admin : peut modifier -->
                                <select id="idDepartement" name="idDepartement">
                                    <option value="">-- Aucun --</option>
                                    <c:forEach var="dept" items="${departements}">
                                        <option value="${dept.id}" 
                                                ${projet != null && projet.idDepartement == dept.id ? 'selected' : ''}>
                                            ${dept.intitule}
                                        </option>
                                    </c:forEach>
                                </select>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>
            
            <!-- DÉPARTEMENT pour la création (Admin uniquement) -->
            <c:if test="${projet == null}">
                <div class="form-group">
                    <label for="idDepartement">Département:</label>
                    <select id="idDepartement" name="idDepartement">
                        <option value="">-- Aucun --</option>
                        <c:forEach var="dept" items="${departements}">
                            <option value="${dept.id}">
                                ${dept.intitule}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </c:if>
            
            <!-- Boutons d'action -->
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    ✅ ${projet != null ? 'Enregistrer' : 'Créer'}
                </button>
                <a href="${pageContext.request.contextPath}/projets" class="btn btn-secondary">
                    ❌ Annuler
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
                    alert('❌ La date de fin prévue doit être postérieure ou égale à la date de début !');
                    dateFinPrevue.focus();
                    return false;
                }
            }
            
            // Vérifier date fin réelle (si elle existe)
            if (dateFinReelle && dateFinReelle.value && debut) {
                if (dateFinReelle.value < debut) {
                    e.preventDefault();
                    alert('❌ La date de fin réelle doit être postérieure ou égale à la date de début !');
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
            dateDebut.addEventListener('change', function() {
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
</body>
</html>