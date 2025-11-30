<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty fiche ? 'Créer' : 'Modifier'} une Fiche de Paie - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
    <style>
        .form-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .form-card {
            background: linear-gradient(135deg, #1e1e1e, #1a1a1a);
            padding: 35px;
            border-radius: 10px;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(212, 175, 55, 0.2);
        }

        .form-header {
            border-bottom: 2px solid #d4af37;
            padding-bottom: 15px;
            margin-bottom: 30px;
        }

        .form-header h1 {
            color: #f0d479;
            margin: 0;
            font-size: 28px;
            text-transform: uppercase;
            letter-spacing: 1px;
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

        .form-group label.required::after {
            content: " *";
            color: #cf6679;
        }

        .form-control {
            width: 100%;
            padding: 14px;
            border: 1px solid #444;
            border-radius: 6px;
            font-size: 15px;
            box-sizing: border-box;
            background-color: #121212;
            color: #e0e0e0;
            transition: all 0.3s;
        }

        .form-control:focus {
            outline: none;
            border-color: #d4af37;
            box-shadow: 0 0 8px rgba(212, 175, 55, 0.4);
            background-color: #1a1a1a;
        }

        .form-control:disabled {
            background-color: #0d0d0d;
            cursor: not-allowed;
            color: #777;
        }

        .form-control option {
            background-color: #1e1e1e;
            color: #e0e0e0;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .help-text {
            font-size: 13px;
            color: #b0b0b0;
            margin-top: 8px;
            font-style: italic;
        }

        .calculation-box {
            background: radial-gradient(circle at 15% 20%, rgba(75, 181, 67, 0.1), transparent 45%), #151515;
            padding: 25px;
            border-radius: 10px;
            border-left: 4px solid #4bb543;
            margin: 25px 0;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
        }

        .calculation-box h3 {
            margin: 0 0 20px 0;
            color: #4bb543;
            font-size: 20px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .calculation-item {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }

        .calculation-item:last-child {
            border-bottom: none;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 2px solid #4bb543;
            font-weight: bold;
            font-size: 20px;
        }

        .calculation-label {
            color: #c9c9c9;
            font-size: 15px;
        }

        .calculation-value {
            color: #e0e0e0;
            font-weight: 600;
            font-size: 16px;
        }

        .net-value {
            color: #4bb543;
            font-size: 24px;
            text-shadow: 0 0 10px rgba(75, 181, 67, 0.3);
        }

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 35px;
            padding-top: 25px;
            border-top: 1px solid #333;
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

        .employee-info {
            background: radial-gradient(circle at 15% 20%, rgba(23, 162, 184, 0.1), transparent 45%), #151515;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            border-left: 4px solid #17a2b8;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
        }

        .employee-info h3 {
            margin: 0 0 15px 0;
            color: #17a2b8;
            font-size: 18px;
            text-transform: uppercase;
        }

        .employee-info p {
            margin: 8px 0;
            color: #e0e0e0;
            line-height: 1.6;
        }

        .employee-info strong {
            color: #17a2b8;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
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
                        Créer une Fiche de Paie
                    </c:when>
                    <c:otherwise>
                        Modifier une Fiche de Paie
                    </c:otherwise>
                </c:choose>
            </h1>
        </div>

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

        <form action="${pageContext.request.contextPath}/fiches-paie${empty fiche ? '' : '/update'}"
              method="post" id="ficheForm">

            <c:if test="${not empty fiche}">
                <input type="hidden" name="id" value="${fiche.id}">
            </c:if>

            <c:choose>
                <c:when test="${empty fiche}">
                    <div class="form-group">
                        <label for="idEmployer" class="required">Employé</label>
                        <select name="idEmployer" id="idEmployer" class="form-control" required
                                onchange="updateSalaire()">
                            <option value="">-- Sélectionner un employé --</option>
                            <c:forEach items="${employers}" var="emp">
                                <option value="${emp.id}" ${param.idEmployer==emp.id.toString()
                                        ? 'selected' : '' } data-salaire="${emp.salaireBase}"
                                        data-nom="${emp.prenom} ${emp.nom}"
                                        data-matricule="${emp.matricule}" data-poste="${emp.poste}">
                                        ${emp.prenom} ${emp.nom} - ${emp.matricule}
                                </option>
                            </c:forEach>
                        </select>
                        <div class="help-text">Sélectionnez l'employé pour qui vous créez la fiche
                            de paie</div>
                    </div>

                    <input type="hidden" name="salaireBase" id="salaireBaseHidden"
                           value="${param.salaireBase != null ? param.salaireBase : 0}">
                </c:when>
                <c:otherwise>
                    <div class="employee-info">
                        <h3>Informations de l'employé</h3>
                        <p><strong>Nom :</strong> ${employer.prenom} ${employer.nom}</p>
                        <p><strong>Matricule :</strong> ${employer.matricule}</p>
                        <p><strong>Poste :</strong> ${employer.poste}</p>
                    </div>
                </c:otherwise>
            </c:choose>

            <div id="employeeInfo" class="employee-info"
                 style="display: ${param.idEmployer != null ? 'block' : 'none'};">
                <h3>Employé sélectionné</h3>
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
                        <option value="1" ${(fiche !=null && fiche.mois==1) || (fiche==null &&
                                param.mois=='1' ) ? 'selected' : '' }>Janvier</option>
                        <option value="2" ${(fiche !=null && fiche.mois==2) || (fiche==null &&
                                param.mois=='2' ) ? 'selected' : '' }>Février</option>
                        <option value="3" ${(fiche !=null && fiche.mois==3) || (fiche==null &&
                                param.mois=='3' ) ? 'selected' : '' }>Mars</option>
                        <option value="4" ${(fiche !=null && fiche.mois==4) || (fiche==null &&
                                param.mois=='4' ) ? 'selected' : '' }>Avril</option>
                        <option value="5" ${(fiche !=null && fiche.mois==5) || (fiche==null &&
                                param.mois=='5' ) ? 'selected' : '' }>Mai</option>
                        <option value="6" ${(fiche !=null && fiche.mois==6) || (fiche==null &&
                                param.mois=='6' ) ? 'selected' : '' }>Juin</option>
                        <option value="7" ${(fiche !=null && fiche.mois==7) || (fiche==null &&
                                param.mois=='7' ) ? 'selected' : '' }>Juillet</option>
                        <option value="8" ${(fiche !=null && fiche.mois==8) || (fiche==null &&
                                param.mois=='8' ) ? 'selected' : '' }>Août</option>
                        <option value="9" ${(fiche !=null && fiche.mois==9) || (fiche==null &&
                                param.mois=='9' ) ? 'selected' : '' }>Septembre</option>
                        <option value="10" ${(fiche !=null && fiche.mois==10) || (fiche==null &&
                                param.mois=='10' ) ? 'selected' : '' }>Octobre</option>
                        <option value="11" ${(fiche !=null && fiche.mois==11) || (fiche==null &&
                                param.mois=='11' ) ? 'selected' : '' }>Novembre</option>
                        <option value="12" ${(fiche !=null && fiche.mois==12) || (fiche==null &&
                                param.mois=='12' ) ? 'selected' : '' }>Décembre</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="annee" class="required">Année</label>
                    <input type="number" name="annee" id="annee" class="form-control" min="2020"
                           max="2030"
                           value="${fiche != null ? fiche.annee : (param.annee != null ? param.annee : 2025)}"
                           required>
                </div>
            </div>

            <c:if test="${not empty fiche}">
                <div class="form-group">
                    <label for="salaireBase" class="required">Salaire de Base (€)</label>
                    <input type="number" name="salaireBase" id="salaireBase" class="form-control"
                           step="0.01" min="0" value="${fiche.salaireBase}" required
                           oninput="updateSalaireBaseModif()">
                    <div class="help-text" style="color: #ff9800;">Seul l'ADMIN peut modifier le
                        salaire de base</div>
                </div>
            </c:if>

            <div class="form-row">
                <div class="form-group">
                    <label for="primes">Primes (€)</label>
                    <input type="number" name="primes" id="primes" class="form-control" step="0.01"
                           min="0"
                           value="${fiche != null ? fiche.primes : (param.primes != null ? param.primes : 0)}"
                           oninput="calculateNet()">
                    <div class="help-text">Heures supplémentaires, bonus, etc.</div>
                </div>

                <div class="form-group">
                    <label for="deductions">Déductions (€)</label>
                    <input type="number" name="deductions" id="deductions" class="form-control"
                           step="0.01" min="0"
                           value="${fiche != null ? fiche.deductions : (param.deductions != null ? param.deductions : 0)}"
                           oninput="calculateNet()">
                    <div class="help-text">Retards, absences non justifiées, etc.</div>
                </div>
            </div>

            <div class="calculation-box">
                <h3>Calcul du Salaire Net</h3>

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
                            Créer la Fiche de Paie
                        </c:when>
                        <c:otherwise>
                            Enregistrer les Modifications
                        </c:otherwise>
                    </c:choose>
                </button>
                <button type="button" class="btn btn-secondary" onclick="confirmCancel()">
                    Annuler
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    let salaireBase = ${ fiche != null ? fiche.salaireBase : (param.salaireBase != null ? param.salaireBase : 0)};

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
        if (confirm('Êtes-vous sûr d\'annuler ?\n\nLes modifications non enregistrées seront perdues.')) {
            window.location.href = '${pageContext.request.contextPath}/fiches-paie';
        }
    }

    window.onload = function () {
        // Restaurer l'employé sélectionné en cas d'erreur
        <c:if test="${param.idEmployer != null && empty fiche}">
        updateSalaire();
        </c:if>
        calculateNet();
    };
</script>
</body>

</html>