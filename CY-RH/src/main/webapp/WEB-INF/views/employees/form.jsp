<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${employee != null ? 'Modifier' : 'Ajouter'} un Employé - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="container">
        <h1>${employee != null ? 'Modifier' : 'Ajouter'} un Employé</h1>
        
        <!-- Message d'erreur -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <!-- Formulaire -->
        <form action="${employee != null ? pageContext.request.contextPath.concat('/employees/update') : pageContext.request.contextPath.concat('/employees')}" 
              method="post" class="employee-form">
            
            <!-- ID caché pour la modification -->
            <c:if test="${employee != null}">
                <input type="hidden" name="id" value="${employee.id}">
            </c:if>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="matricule">Matricule:</label>
                    <input type="text" id="matricule" name="matricule" 
                           value="${employee != null ? employee.matricule : ''}" 
                           placeholder="Ex: EMP001">
                </div>
                
                <div class="form-group">
                    <label for="nom">Nom: *</label>
                    <input type="text" id="nom" name="nom" 
                           value="${employee != null ? employee.nom : ''}" 
                           required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="prenom">Prénom: *</label>
                    <input type="text" id="prenom" name="prenom" 
                           value="${employee != null ? employee.prenom : ''}" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email: *</label>
                    <input type="email" id="email" name="email" 
                           value="${employee != null ? employee.email : ''}" 
                           required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="telephone">Téléphone:</label>
                    <input type="tel" id="telephone" name="telephone" 
                           value="${employee != null ? employee.telephone : ''}" 
                           placeholder="0612345678">
                </div>
                
                <div class="form-group">
                    <label for="password">Mot de passe: ${employee != null ? '(laisser vide pour ne pas changer)' : '*'}</label>
                    <input type="password" id="password" name="password" 
                           ${employee == null ? 'required' : ''}>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="poste">Poste: *</label>
                    <input type="text" id="poste" name="poste" 
                           value="${employee != null ? employee.poste : ''}" 
                           placeholder="Ex: Développeur" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="grade">Grade: *</label>
                    <select id="grade" name="grade" required>
                        <option value="">-- Sélectionner --</option>
                        <option value="Junior" ${employee != null && employee.grade == 'Junior' ? 'selected' : ''}>Junior</option>
                        <option value="Confirmé" ${employee != null && employee.grade == 'Confirmé' ? 'selected' : ''}>Confirmé</option>
                        <option value="Senior" ${employee != null && employee.grade == 'Senior' ? 'selected' : ''}>Senior</option>
                        <option value="Expert" ${employee != null && employee.grade == 'Expert' ? 'selected' : ''}>Expert</option>
                    </select>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="salaireBase">Salaire de base (€): *</label>
                    <input type="number" id="salaireBase" name="salaireBase" 
                           step="0.01" min="0"
                           value="${employee != null ? employee.salaireBase : ''}" 
                           required>
                </div>
                
                <div class="form-group">
                    <label for="dateEmbauche">Date d'embauche: *</label>
                    <input type="date" id="dateEmbauche" name="dateEmbauche" 
                           value="${employee != null ? employee.dateEmbauche : ''}" 
                           required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="idDepartement">Département:</label>
                    <select id="idDepartement" name="idDepartement">
                        <option value="">-- Aucun --</option>
                        <c:forEach var="dept" items="${departements}">
                            <option value="${dept.id}" 
                                    ${employee != null && employee.idDepartement == dept.id ? 'selected' : ''}>
                                ${dept.intitule}
                            </option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="role">Rôle: *</label>
                    <select id="role" name="role" required>
                        <option value="EMPLOYE" ${employee == null || employee.role == 'EMPLOYE' ? 'selected' : ''}>Employé</option>
                        <option value="CHEF_PROJET" ${employee != null && employee.role == 'CHEF_PROJET' ? 'selected' : ''}>Chef de Projet</option>
                        <option value="CHEF_DEPT" ${employee != null && employee.role == 'CHEF_DEPT' ? 'selected' : ''}>Chef de Département</option>
                        <option value="ADMIN" ${employee != null && employee.role == 'ADMIN' ? 'selected' : ''}>Administrateur</option>
                    </select>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    ${employee != null ? 'Mettre à jour' : 'Créer'}
                </button>
                <a href="${pageContext.request.contextPath}/employees" class="btn btn-secondary">
                    Annuler
                </a>
            </div>
        </form>
    </div>
</body>
</html>