<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty fiche ? 'Créer' : 'Modifier'} une Fiche de Paie - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .form-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .form-card {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .form-header {
            border-bottom: 2px solid #007bff;
            padding-bottom: 15px;
            margin-bottom: 30px;
        }
        
        .form-header h1 {
            color: #333;
            margin: 0;
            font-size: 24px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #555;
        }
        
        .form-group label.required::after {
            content: " *";
            color: red;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 3px rgba(0,123,255,0.1);
        }
        
        .form-control:disabled {
            background-color: #f8f9fa;
            cursor: not-allowed;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .help-text {
            font-size: 12px;
            color: #6c757d;
            margin-top: 5px;
        }
        
        .calculation-box {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 4px;
            border-left: 4px solid #28a745;
            margin: 20px 0;
        }
        
        .calculation-box h3 {
            margin: 0 0 15px 0;
            color: #333;
            font-size: 18px;
        }
        
        .calculation-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #dee2e6;
        }
        
        .calculation-item:last-child {
            border-bottom: none;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 2px solid #28a745;
            font-weight: bold;
            font-size: 18px;
        }
        
        .calculation-label {
            color: #555;
        }
        
        .calculation-value {
            color: #333;
            font-weight: 600;
        }
        
        .net-value {
            color: #28a745;
            font-size: 20px;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
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
        
        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #dee2e6;
        }
        
        .alert {
            padding: 12px 20px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .employee-info {
            background: #e7f3ff;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .employee-info h3 {
            margin: 0 0 10px 0;
            color: #0056b3;
            font-size: 16px;
        }
        
        .employee-info p {
            margin: 5px 0;
            color: #333;
        }
    </style>
</head>
<body>
    <%@ include file="../includes/header.jsp" %>
    
    <div class="form-container">
        <div class="form-card">
            <div class="form-header">
                <h1>
                    <c:choose>
                        <c:when test="${empty fiche}">
                            ➕ Créer une Fiche de Paie
                        </c:when>
                        <c:otherwise>
                            ✏️ Modifier une Fiche de Paie
                        </c:otherwise>
                    </c:choose>
                </h1>
            </div>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    ⚠️ ${error}
                </div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/fiches-paie${empty fiche ? '' : '/update'}" 
                  method="post" 
                  id="ficheForm">
                
                <c:if test="${not empty fiche}">
                    <input type="hidden" name="id" value="${fiche.id}">
                </c:if>
                
                <c:choose>
                    <c:when test="${empty fiche}">
                        <div class="form-group">
                            <label for="idEmployer" class="required">Employé</label>
                            <select name="idEmployer" id="idEmployer" class="form-control" required onchange="updateSalaire()">
                                <option value="">-- Sélectionner un employé --</option>
                                <c:forEach items="${employers}" var="emp">
                                    <option value="${emp.id}" 
                                            data-salaire="${emp.salaireBase}"
                                            data-nom="${emp.prenom} ${emp.nom}"
                                            data-matricule="${emp.matricule}"
                                            data-poste="${emp.poste}">
                                        ${emp.prenom} ${emp.nom} - ${emp.matricule}
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="help-text">Sélectionnez l'employé pour qui vous créez la fiche de paie</div>
                        </div>
                        
                        <input type="hidden" name="salaireBase" id="salaireBaseHidden" value="0">
                    </c:when>
                    <c:otherwise>
                        <div class="employee-info">
                            <h3>👤 Informations de l'employé</h3>
                            <p><strong>Nom :</strong> ${employer.prenom} ${employer.nom}</p>
                            <p><strong>Matricule :</strong> ${employer.matricule}</p>
                            <p><strong>Poste :</strong> ${employer.poste}</p>
                        </div>
                    </c:otherwise>
                </c:choose>
                
                <div id="employeeInfo" class="employee-info" style="display: none;">
                    <h3>👤 Employé sélectionné</h3>
                    <p><strong>Nom :</strong> <span id="empNom"></span></p>
                    <p><strong>Matricule :</strong> <span id="empMatricule"></span></p>
                    <p><strong>Poste :</strong> <span id="empPoste"></span></p>
                    <p><strong>Salaire de base :</strong> <span id="empSalaire"></span> €</p>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="mois" class="required">Mois</label>
                        <select name="mois" id="mois" class="form-control" required>
                            <option value="">-- Sélectionner --</option>
                            <option value="1" ${fiche.mois == 1 ? 'selected' : ''}>Janvier</option>
                            <option value="2" ${fiche.mois == 2 ? 'selected' : ''}>Février</option>
                            <option value="3" ${fiche.mois == 3 ? 'selected' : ''}>Mars</option>
                            <option value="4" ${fiche.mois == 4 ? 'selected' : ''}>Avril</option>
                            <option value="5" ${fiche.mois == 5 ? 'selected' : ''}>Mai</option>
                            <option value="6" ${fiche.mois == 6 ? 'selected' : ''}>Juin</option>
                            <option value="7" ${fiche.mois == 7 ? 'selected' : ''}>Juillet</option>
                            <option value="8" ${fiche.mois == 8 ? 'selected' : ''}>Août</option>
                            <option value="9" ${fiche.mois == 9 ? 'selected' : ''}>Septembre</option>
                            <option value="10" ${fiche.mois == 10 ? 'selected' : ''}>Octobre</option>
                            <option value="11" ${fiche.mois == 11 ? 'selected' : ''}>Novembre</option>
                            <option value="12" ${fiche.mois == 12 ? 'selected' : ''}>Décembre</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="annee" class="required">Année</label>
                        <input type="number" 
                               name="annee" 
                               id="annee" 
                               class="form-control" 
                               min="2020" 
                               max="2030" 
                               value="${not empty fiche ? fiche.annee : 2025}" 
                               required>
                    </div>
                </div>
                
                <c:if test="${not empty fiche}">
                    <div class="form-group">
                        <label for="salaireBase" class="required">💵 Salaire de Base (€)</label>
                        <input type="number" 
                               name="salaireBase" 
                               id="salaireBase" 
                               class="form-control" 
                               step="0.01" 
                               min="0"
                               value="${fiche.salaireBase}"
                               required
                               oninput="updateSalaireBaseModif()">
                        <div class="help-text" style="color: #856404;">⚠️ Seul l'ADMIN peut modifier le salaire de base</div>
                    </div>
                </c:if>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="primes">Primes (€)</label>
                        <input type="number" 
                               name="primes" 
                               id="primes" 
                               class="form-control" 
                               step="0.01" 
                               min="0"
                               value="${not empty fiche ? fiche.primes : 0}"
                               oninput="calculateNet()">
                        <div class="help-text">Heures supplémentaires, bonus, etc.</div>
                    </div>
                    
                    <div class="form-group">
                        <label for="deductions">Déductions (€)</label>
                        <input type="number" 
                               name="deductions" 
                               id="deductions" 
                               class="form-control" 
                               step="0.01" 
                               min="0"
                               value="${not empty fiche ? fiche.deductions : 0}"
                               oninput="calculateNet()">
                        <div class="help-text">Retards, absences non justifiées, etc.</div>
                    </div>
                </div>
                
                <div class="calculation-box">
                    <h3>💰 Calcul du Salaire Net</h3>
                    
                    <div class="calculation-item">
                        <span class="calculation-label">Salaire de base</span>
                        <span class="calculation-value" id="displaySalaireBase">0.00 €</span>
                    </div>
                    
                    <div class="calculation-item">
                        <span class="calculation-label">+ Primes</span>
                        <span class="calculation-value" id="displayPrimes">0.00 €</span>
                    </div>
                    
                    <div class="calculation-item">
                        <span class="calculation-label">- Déductions</span>
                        <span class="calculation-value" id="displayDeductions">0.00 €</span>
                    </div>
                    
                    <div class="calculation-item">
                        <span class="calculation-label">NET À PAYER</span>
                        <span class="calculation-value net-value" id="displayNet">0.00 €</span>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary" onclick="return confirmSave()">
                        <c:choose>
                            <c:when test="${empty fiche}">
                                ✅ Créer la Fiche de Paie
                            </c:when>
                            <c:otherwise>
                                💾 Enregistrer les Modifications
                            </c:otherwise>
                        </c:choose>
                    </button>
                    <button type="button" class="btn btn-secondary" onclick="confirmCancel()">
                        ❌ Annuler
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        let salaireBase = ${not empty fiche ? fiche.salaireBase : 0};
        
        function updateSalaire() {
            const select = document.getElementById('idEmployer');
            const option = select.options[select.selectedIndex];
            
            if (option.value) {
                salaireBase = parseFloat(option.dataset.salaire);
                
                document.getElementById('salaireBaseHidden').value = salaireBase;
                
                document.getElementById('empNom').textContent = option.dataset.nom;
                document.getElementById('empMatricule').textContent = option.dataset.matricule;
                document.getElementById('empPoste').textContent = option.dataset.poste;
                document.getElementById('empSalaire').textContent = salaireBase.toFixed(2);
                document.getElementById('employeeInfo').style.display = 'block';
                
                calculateNet();
            } else {
                document.getElementById('employeeInfo').style.display = 'none';
                document.getElementById('salaireBaseHidden').value = 0;
                salaireBase = 0;
                calculateNet();
            }
        }
        
        function calculateNet() {
            const primes = parseFloat(document.getElementById('primes').value) || 0;
            const deductions = parseFloat(document.getElementById('deductions').value) || 0;
            
            const net = salaireBase + primes - deductions;
            
            document.getElementById('displaySalaireBase').textContent = salaireBase.toFixed(2) + ' €';
            document.getElementById('displayPrimes').textContent = primes.toFixed(2) + ' €';
            document.getElementById('displayDeductions').textContent = deductions.toFixed(2) + ' €';
            document.getElementById('displayNet').textContent = net.toFixed(2) + ' €';
        }
        
        function updateSalaireBaseModif() {
            salaireBase = parseFloat(document.getElementById('salaireBase').value) || 0;
            calculateNet();
        }
        
        function confirmSave() {
            return confirm('Confirmer l\'enregistrement de la fiche de paie ?');
        }
        
        function confirmCancel() {
            if (confirm('⚠️ Êtes-vous sûr d\'annuler ?\n\nLes modifications non enregistrées seront perdues.')) {
                window.location.href = '${pageContext.request.contextPath}/fiches-paie';
            }
        }
        
        window.onload = function() {
            calculateNet();
        };
    </script>
</body>
</html>
