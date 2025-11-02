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
        
        <!-- Message d'erreur -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <!-- Formulaire -->
        <form action="${projet != null ? pageContext.request.contextPath.concat('/projets/update') : pageContext.request.contextPath.concat('/projets')}" 
              method="post" class="employee-form">
            
            <c:if test="${projet != null}">
                <input type="hidden" name="id" value="${projet.id}">
            </c:if>
            
            <div class="form-group">
                <label for="nomProjet">Nom du projet: *</label>
                <input type="text" id="nomProjet" name="nomProjet" 
                       value="${projet != null ? projet.nomProjet : ''}" 
                       placeholder="Ex: Application RH, Site web..."
                       required>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="etatProjet">État du projet: *</label>
                    <select id="etatProjet" name="etatProjet" required>
                        <option value="EN_COURS" ${projet == null || projet.etatProjet == 'EN_COURS' ? 'selected' : ''}>En cours</option>
                        <option value="TERMINE" ${projet != null && projet.etatProjet == 'TERMINE' ? 'selected' : ''}>Terminé</option>
                        <option value="ANNULE" ${projet != null && projet.etatProjet == 'ANNULE' ? 'selected' : ''}>Annulé</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="chefProjet">Chef de projet:</label>
                    <select id="chefProjet" name="chefProjet">
                        <option value="">-- Aucun --</option>
                        <c:forEach var="emp" items="${employees}">
                            <option value="${emp.id}" 
                                    ${projet != null && projet.chefProjet == emp.id ? 'selected' : ''}>
                                ${emp.prenom} ${emp.nom} (${emp.poste})
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="dateDebut">Date de début: *</label>
                    <input type="date" id="dateDebut" name="dateDebut" 
                           value="<fmt:formatDate value='${projet.dateDebut}' pattern='yyyy-MM-dd'/>" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="dateFinPrevue">Date de fin prévue:</label>
                    <input type="date" id="dateFinPrevue" name="dateFinPrevue" 
                           value="<fmt:formatDate value='${projet.dateFinPrevue}' pattern='yyyy-MM-dd'/>">
                </div>
            </div>
            
            <c:if test="${projet != null}">
                <div class="form-row">
                    <div class="form-group">
                        <label for="dateFinReelle">Date de fin réelle:</label>
                        <input type="date" id="dateFinReelle" name="dateFinReelle" 
                               value="<fmt:formatDate value='${projet.dateFinReelle}' pattern='yyyy-MM-dd'/>">
                        <small>À remplir uniquement si le projet est terminé</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="idDepartement">Département:</label>
                        <select id="idDepartement" name="idDepartement">
                            <option value="">-- Aucun --</option>
                            <c:forEach var="dept" items="${departements}">
                                <option value="${dept.id}" 
                                        ${projet != null && projet.idDepartement == dept.id ? 'selected' : ''}>
                                    ${dept.intitule}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </c:if>
            
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
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    ${projet != null ? 'Mettre à jour' : 'Créer'}
                </button>
                <a href="${pageContext.request.contextPath}/projets" class="btn btn-secondary">
                    Annuler
                </a>
            </div>
        </form>
    </div>
</body>
</html>