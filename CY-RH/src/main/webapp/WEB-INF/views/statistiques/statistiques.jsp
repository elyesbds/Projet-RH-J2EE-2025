<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Statistiques - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: #1a1a1a;
            color: #ffffff;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .page-title {
            text-align: center;
            font-size: 2.5em;
            margin-bottom: 40px;
            color: #d4af37;
            text-transform: uppercase;
            letter-spacing: 3px;
            border-bottom: 3px solid #d4af37;
            padding-bottom: 20px;
        }

        .stats-cards {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: linear-gradient(135deg, #2d2d2d 0%, #1a1a1a 100%);
            border: 2px solid #d4af37;
            color: white;
            padding: 30px 20px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 8px 20px rgba(212, 175, 55, 0.3);
            transition: all 0.3s;
        }

        .stat-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 12px 30px rgba(212, 175, 55, 0.5);
            border-color: #f4d03f;
        }

        .stat-number {
            font-size: 3.5em;
            font-weight: bold;
            margin-bottom: 10px;
            color: #d4af37;
            text-shadow: 0 0 20px rgba(212, 175, 55, 0.5);
        }

        .stat-label {
            font-size: 1.1em;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: #cccccc;
        }

        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }

        .chart-container {
            background: linear-gradient(135deg, #2d2d2d 0%, #1a1a1a 100%);
            border: 2px solid #d4af37;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 8px 20px rgba(212, 175, 55, 0.2);
            height: 420px;
        }

        .chart-container h2 {
            color: #d4af37;
            margin-bottom: 20px;
            font-size: 1.3em;
            text-transform: uppercase;
            letter-spacing: 2px;
            border-bottom: 2px solid #d4af37;
            padding-bottom: 10px;
        }

        .chart-container canvas {
            max-height: 320px !important;
        }

        .chart-container-full {
            background: linear-gradient(135deg, #2d2d2d 0%, #1a1a1a 100%);
            border: 2px solid #d4af37;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 8px 20px rgba(212, 175, 55, 0.2);
            margin-bottom: 30px;
            height: 420px;
        }

        .chart-container-full h2 {
            color: #d4af37;
            margin-bottom: 20px;
            font-size: 1.3em;
            text-transform: uppercase;
            letter-spacing: 2px;
            border-bottom: 2px solid #d4af37;
            padding-bottom: 10px;
        }

        .chart-container-full canvas {
            max-height: 320px !important;
        }

        .table-section {
            background: linear-gradient(135deg, #2d2d2d 0%, #1a1a1a 100%);
            border: 2px solid #d4af37;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 8px 20px rgba(212, 175, 55, 0.2);
            margin-top: 30px;
        }

        .table-section h2 {
            color: #d4af37;
            margin-bottom: 25px;
            font-size: 1.5em;
            text-transform: uppercase;
            letter-spacing: 2px;
            border-bottom: 2px solid #d4af37;
            padding-bottom: 15px;
        }

        .stats-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .stats-table th {
            background: #d4af37;
            color: #1a1a1a;
            padding: 15px;
            text-align: left;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .stats-table td {
            padding: 15px;
            border-bottom: 1px solid #3d3d3d;
            color: #cccccc;
        }

        .stats-table tbody tr {
            background: #2d2d2d;
            transition: all 0.3s;
        }

        .stats-table tbody tr:hover {
            background: #3d3d3d;
            transform: scale(1.02);
        }

        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .badge-success {
            background: #27ae60;
            color: white;
        }

        .badge-secondary {
            background: #95a5a6;
            color: white;
        }

        .badge-danger {
            background: #e74c3c;
            color: white;
        }

        .grade-badge {
            display: inline-block;
            background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
            color: #1a1a1a;
            padding: 6px 12px;
            border-radius: 15px;
            margin-right: 8px;
            margin-bottom: 5px;
            font-size: 0.9em;
            font-weight: bold;
        }

        /* Modales */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.9);
            animation: fadeIn 0.3s;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        .modal-content {
            background: linear-gradient(135deg, #2d2d2d 0%, #1a1a1a 100%);
            border: 3px solid #d4af37;
            color: white;
            margin: 5% auto;
            padding: 40px;
            border-radius: 20px;
            width: 80%;
            max-width: 900px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(212, 175, 55, 0.5);
            animation: slideDown 0.4s;
        }

        @keyframes slideDown {
            from {
                transform: translateY(-100px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .close {
            color: #d4af37;
            float: right;
            font-size: 40px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            line-height: 1;
        }

        .close:hover {
            color: #f4d03f;
            transform: rotate(90deg) scale(1.2);
        }

        .modal-content h2 {
            margin-bottom: 25px;
            color: #d4af37;
            border-bottom: 3px solid #d4af37;
            padding-bottom: 15px;
            font-size: 1.8em;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .modal-list {
            background: rgba(212, 175, 55, 0.05);
            padding: 25px;
            border-radius: 15px;
            margin-top: 20px;
            border: 1px solid #d4af37;
        }

        .modal-list h3 {
            color: #d4af37;
            margin-bottom: 20px;
            font-size: 1.3em;
        }

        .modal-item {
            background: rgba(255, 255, 255, 0.05);
            padding: 20px;
            margin-bottom: 15px;
            border-radius: 10px;
            border-left: 5px solid #d4af37;
            transition: all 0.3s;
        }

        .modal-item:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateX(10px);
            border-left-color: #f4d03f;
        }

        .modal-item strong {
            color: #d4af37;
            font-size: 1.1em;
        }

        /* Scrollbar custom */
        ::-webkit-scrollbar {
            width: 10px;
        }

        ::-webkit-scrollbar-track {
            background: #1a1a1a;
        }

        ::-webkit-scrollbar-thumb {
            background: #d4af37;
            border-radius: 5px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #f4d03f;
        }

        .chart-container canvas {
            max-height: 320px !important;
            cursor: pointer !important;
        }

        .chart-container-full canvas {
            max-height: 320px !important;
            cursor: pointer !important;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body>
<jsp:include page="../includes/header.jsp"/>

<div class="container">
    <h1 class="page-title">TABLEAU DE BORD - STATISTIQUES</h1>

    <!-- Chiffres clés -->
    <div class="stats-cards">
        <div class="stat-card">
            <div class="stat-number">${totalEmployes}</div>
            <div class="stat-label">Employés</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">${totalDepartements}</div>
            <div class="stat-label">Départements</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">${totalProjets}</div>
            <div class="stat-label">Projets</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">${projetsEnCours}</div>
            <div class="stat-label">Projets en cours</div>
        </div>
    </div>

    <!-- Graphiques principaux -->
    <div class="charts-grid">
        <!-- Employés par département -->
        <div class="chart-container">
            <h2>Employés par département</h2>
            <canvas id="chartEmployesDept"></canvas>
        </div>

        <!-- Répartition par grades -->
        <div class="chart-container">
            <h2>Répartition par grades</h2>
            <canvas id="chartGrades"></canvas>
        </div>

        <!-- Projets par état -->
        <div class="chart-container">
            <h2>État des projets</h2>
            <canvas id="chartProjetsEtat"></canvas>
        </div>

        <!-- Répartition des rôles -->
        <div class="chart-container">
            <h2>Répartition des rôles</h2>
            <canvas id="chartRoles"></canvas>
        </div>

        <!-- Masse salariale -->
        <div class="chart-container">
            <h2>Masse salariale par département</h2>
            <canvas id="chartSalaires"></canvas>
        </div>

        <!-- Top 5 projets -->
        <div class="chart-container">
            <h2>Top 5 projets</h2>
            <canvas id="chartTop5"></canvas>
        </div>
    </div>

    <!-- Absences -->
    <c:if test="${not empty statsAbsences}">
        <div class="chart-container-full">
            <h2>Absences par type</h2>
            <canvas id="chartAbsences"></canvas>
        </div>
    </c:if>

    <!-- Tableau détaillé -->
    <div class="table-section">
        <h2>Détail des employés par projet</h2>
        <table class="stats-table">
            <thead>
            <tr>
                <th>Nom du projet</th>
                <th>État</th>
                <th>Total employés</th>
                <th>Détail grades</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="projet" items="${statsEmployesByProjet}">
                <tr>
                    <td><strong>${projet.nomProjet}</strong></td>
                    <td>
                        <c:choose>
                            <c:when test="${projet.etatProjet == 'EN_COURS'}">
                                <span class="badge badge-success">EN COURS</span>
                            </c:when>
                            <c:when test="${projet.etatProjet == 'TERMINE'}">
                                <span class="badge badge-secondary">TERMINÉ</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-danger">ANNULÉ</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td><strong>${projet.totalEmployes}</strong></td>
                    <td>
                        <c:forEach var="grade" items="${projet.gradeCount}">
                            <span class="grade-badge">${grade.key}: ${grade.value}</span>
                        </c:forEach>
                        <c:if test="${empty projet.gradeCount}">
                            <em style="color: #999;">Aucun employé</em>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<!-- Modales -->
<div id="modalDept" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('modalDept')">&times;</span>
        <h2 id="modalDeptTitle">Détails du département</h2>
        <div id="modalDeptContent"></div>
    </div>
</div>

<div id="modalProjet" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('modalProjet')">&times;</span>
        <h2 id="modalProjetTitle">Détails du projet</h2>
        <div id="modalProjetContent"></div>
    </div>
</div>

<div id="modalGrade" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('modalGrade')">&times;</span>
        <h2 id="modalGradeTitle">Employés de ce grade</h2>
        <div id="modalGradeContent"></div>
    </div>
</div>

<div id="modalEtatProjet" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('modalEtatProjet')">&times;</span>
        <h2 id="modalEtatProjetTitle">Projets par état</h2>
        <div id="modalEtatProjetContent"></div>
    </div>
</div>

<div id="modalRole" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('modalRole')">&times;</span>
        <h2 id="modalRoleTitle">Employés avec ce rôle</h2>
        <div id="modalRoleContent"></div>
    </div>
</div>

<div id="modalAbsence" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('modalAbsence')">&times;</span>
        <h2 id="modalAbsenceTitle">Absences par type</h2>
        <div id="modalAbsenceContent"></div>
    </div>
</div>

<script>
    // Configuration des couleurs doré
    const goldColors = ['#d4af37', '#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12', '#1abc9c', '#34495e'];

    // Données pour modales
    const projetsData = {
        <c:forEach var="projet" items="${statsEmployesByProjet}" varStatus="status">
        '${projet.nomProjet}': {
            etat: '${projet.etatProjet}',
            total: ${projet.totalEmployes},
            grades: {
                <c:forEach var="grade" items="${projet.gradeCount}" varStatus="gradeStatus">
                '${grade.key}': ${grade.value}<c:if test="${!gradeStatus.last}">, </c:if>
                </c:forEach>
            }
        }<c:if test="${!status.last}">, </c:if>
        </c:forEach>
    };

    // Fonctions modales
    function openModal(modalId) {
        document.getElementById(modalId).style.display = 'block';
    }

    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    window.onclick = function (event) {
        if (event.target.className === 'modal') {
            event.target.style.display = 'none';
        }
    }


    // Détails département
    function showDeptDetails(deptName) {
        document.getElementById('modalDeptTitle').textContent = deptName;

        fetch('${pageContext.request.contextPath}/statistiques?action=dept-details&nom=' + encodeURIComponent(deptName))
            .then(response => response.json())
            .then(data => {
                let html = '<div class="modal-list"><h3>Liste des employés :</h3>';

                if (data.employes && data.employes.length > 0) {
                    data.employes.forEach(emp => {
                        html += '<div class="modal-item"><strong>' + emp.nom + ' ' + emp.prenom + '</strong><br>Poste: ' + emp.poste + '<br>Grade: ' + emp.grade + '<br>Salaire: ' + emp.salaire + ' €</div>';
                    });
                } else {
                    html += '<p>Aucun employé dans ce département</p>';
                }

                html += '</div>';
                document.getElementById('modalDeptContent').innerHTML = html;
                openModal('modalDept');
            })
            .catch(() => {
                document.getElementById('modalDeptContent').innerHTML = '<p>Erreur lors du chargement</p>';
                openModal('modalDept');
            });
    }

    // Détails projet
    function showProjetDetails(projetName) {
        document.getElementById('modalProjetTitle').textContent = projetName;

        const projet = projetsData[projetName];
        let html = '<div class="modal-list">';
        html += '<h3>État : ' + projet.etat + '</h3>';
        html += '<h3>Total employés : ' + projet.total + '</h3>';
        html += '<h3>Répartition par grade :</h3>';

        for (let grade in projet.grades) {
            html += '<div class="modal-item"><strong>' + grade + '</strong> : ' + projet.grades[grade] + ' employé(s)</div>';
        }

        html += '</div>';
        document.getElementById('modalProjetContent').innerHTML = html;
        openModal('modalProjet');
    }

    // Détails grade
    function showGradeDetails(gradeName) {
        document.getElementById('modalGradeTitle').textContent = 'Grade : ' + gradeName;

        fetch('${pageContext.request.contextPath}/statistiques?action=grade-details&grade=' + encodeURIComponent(gradeName))
            .then(response => response.json())
            .then(data => {
                let html = '<div class="modal-list"><h3>Employés de ce grade :</h3>';

                if (data.employes && data.employes.length > 0) {
                    data.employes.forEach(emp => {
                        html += '<div class="modal-item"><strong>' + emp.nom + ' ' + emp.prenom + '</strong><br>Poste: ' + emp.poste + '<br>Département: ' + emp.departement + '<br>Salaire: ' + emp.salaire + ' €</div>';
                    });
                } else {
                    html += '<p>Aucun employé avec ce grade</p>';
                }

                html += '</div>';
                document.getElementById('modalGradeContent').innerHTML = html;
                openModal('modalGrade');
            })
            .catch(() => {
                document.getElementById('modalGradeContent').innerHTML = '<p>Erreur lors du chargement</p>';
                openModal('modalGrade');
            });
    }

    // Détails état projet
    function showEtatProjetDetails(etat) {
        document.getElementById('modalEtatProjetTitle').textContent = 'Projets : ' + etat;

        fetch('${pageContext.request.contextPath}/statistiques?action=etat-details&etat=' + encodeURIComponent(etat))
            .then(response => response.json())
            .then(data => {
                let html = '<div class="modal-list"><h3>Liste des projets :</h3>';

                if (data.projets && data.projets.length > 0) {
                    data.projets.forEach(proj => {
                        html += '<div class="modal-item"><strong>' + proj.nom + '</strong><br>Date début: ' + proj.dateDebut + '<br>Chef: ' + proj.chef + '<br>Employés: ' + proj.nbEmployes + '</div>';
                    });
                } else {
                    html += '<p>Aucun projet avec cet état</p>';
                }

                html += '</div>';
                document.getElementById('modalEtatProjetContent').innerHTML = html;
                openModal('modalEtatProjet');
            })
            .catch(() => {
                document.getElementById('modalEtatProjetContent').innerHTML = '<p>Erreur lors du chargement</p>';
                openModal('modalEtatProjet');
            });
    }

    // Détails rôle
    function showRoleDetails(role) {
        document.getElementById('modalRoleTitle').textContent = 'Rôle : ' + role;

        fetch('${pageContext.request.contextPath}/statistiques?action=role-details&role=' + encodeURIComponent(role))
            .then(response => response.json())
            .then(data => {
                let html = '<div class="modal-list"><h3>Employés avec ce rôle :</h3>';

                if (data.employes && data.employes.length > 0) {
                    data.employes.forEach(emp => {
                        html += '<div class="modal-item"><strong>' + emp.nom + ' ' + emp.prenom + '</strong><br>Poste: ' + emp.poste + '<br>Département: ' + emp.departement + '<br>Grade: ' + emp.grade + '</div>';
                    });
                } else {
                    html += '<p>Aucun employé avec ce rôle</p>';
                }

                html += '</div>';
                document.getElementById('modalRoleContent').innerHTML = html;
                openModal('modalRole');
            })
            .catch(() => {
                document.getElementById('modalRoleContent').innerHTML = '<p>Erreur lors du chargement</p>';
                openModal('modalRole');
            });
    }

    // Détails absences
    function showAbsenceDetails(type) {
        document.getElementById('modalAbsenceTitle').textContent = 'Absences : ' + type;

        fetch('${pageContext.request.contextPath}/statistiques?action=absence-details&type=' + encodeURIComponent(type))
            .then(response => response.json())
            .then(data => {
                let html = '<div class="modal-list"><h3>Liste des absences :</h3>';

                if (data.absences && data.absences.length > 0) {
                    data.absences.forEach(abs => {
                        html += '<div class="modal-item"><strong>' + abs.employe + '</strong><br>Du: ' + abs.dateDebut + ' au ' + abs.dateFin + '<br>Motif: ' + abs.motif + '</div>';
                    });
                } else {
                    html += '<p>Aucune absence de ce type</p>';
                }

                html += '</div>';
                document.getElementById('modalAbsenceContent').innerHTML = html;
                openModal('modalAbsence');
            })
            .catch(() => {
                document.getElementById('modalAbsenceContent').innerHTML = '<p>Erreur lors du chargement</p>';
                openModal('modalAbsence');
            });
    }

    // Configuration commune
    Chart.defaults.color = '#cccccc';
    Chart.defaults.borderColor = '#3d3d3d';

    // Graphique 1 : Employés par département
    new Chart(document.getElementById('chartEmployesDept'), {
        type: 'bar',
        data: {
            labels: [<c:forEach var="stat" items="${statsEmployesByDept}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>],
            datasets: [{
                label: 'Nombre d\'employés',
                data: [<c:forEach var="stat" items="${statsEmployesByDept}" varStatus="status">${stat.value}<c:if test="${!status.last}">, </c:if></c:forEach>],
                backgroundColor: '#d4af37',
                borderColor: '#f4d03f',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            onClick: (event, elements) => {
                if (elements.length > 0) {
                    const index = elements[0].index;
                    const labels = [<c:forEach var="stat" items="${statsEmployesByDept}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>];
                    showDeptDetails(labels[index]);
                }
            },
            plugins: {
                legend: {display: false},
                tooltip: {
                    backgroundColor: '#d4af37',
                    titleColor: '#1a1a1a',
                    bodyColor: '#1a1a1a'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {color: '#3d3d3d'},
                    ticks: {color: '#cccccc'}
                },
                x: {
                    grid: {color: '#3d3d3d'},
                    ticks: {color: '#cccccc'}
                }
            }
        }
    });

    // Graphique 2 : Grades
    new Chart(document.getElementById('chartGrades'), {
        type: 'doughnut',
        data: {
            labels: [<c:forEach var="stat" items="${statsGrades}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>],
            datasets: [{
                data: [<c:forEach var="stat" items="${statsGrades}" varStatus="status">${stat.value}<c:if test="${!status.last}">, </c:if></c:forEach>],
                backgroundColor: goldColors,
                borderColor: '#1a1a1a',
                borderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            onClick: (event, elements) => {
                if (elements.length > 0) {
                    const index = elements[0].index;
                    const labels = [<c:forEach var="stat" items="${statsGrades}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>];
                    showGradeDetails(labels[index]);
                }
            },
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {color: '#cccccc'}
                },
                tooltip: {
                    backgroundColor: '#d4af37',
                    titleColor: '#1a1a1a',
                    bodyColor: '#1a1a1a'
                }
            }
        }
    });

    // Graphique 3 : Projets par état
    <c:if test="${not empty statsProjetsByEtat}">
    new Chart(document.getElementById('chartProjetsEtat'), {
        type: 'pie',
        data: {
            labels: [<c:forEach var="stat" items="${statsProjetsByEtat}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>],
            datasets: [{
                data: [<c:forEach var="stat" items="${statsProjetsByEtat}" varStatus="status">${stat.value}<c:if test="${!status.last}">, </c:if></c:forEach>],
                backgroundColor: ['#2ecc71', '#3498db', '#e74c3c', '#95a5a6'],
                borderColor: '#1a1a1a',
                borderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            onClick: (event, elements) => {
                if (elements.length > 0) {
                    const index = elements[0].index;
                    const labels = [<c:forEach var="stat" items="${statsProjetsByEtat}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>];
                    showEtatProjetDetails(labels[index]);
                }
            },
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        color: '#cccccc',
                        font: {size: 12}
                    }
                },
                tooltip: {
                    backgroundColor: '#d4af37',
                    titleColor: '#1a1a1a',
                    bodyColor: '#1a1a1a',
                    callbacks: {
                        afterLabel: () => 'Cliquez pour détails'
                    }
                }
            }
        }
    });
    </c:if>

    // Graphique 4 : Rôles
    new Chart(document.getElementById('chartRoles'), {
        type: 'bar',
        data: {
            labels: [<c:forEach var="stat" items="${statsRoles}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>],
            datasets: [{
                label: 'Nombre',
                data: [<c:forEach var="stat" items="${statsRoles}" varStatus="status">${stat.value}<c:if test="${!status.last}">, </c:if></c:forEach>],
                backgroundColor: '#9b59b6',
                borderColor: '#8e44ad',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            onClick: (event, elements) => {
                if (elements.length > 0) {
                    const index = elements[0].index;
                    const labels = [<c:forEach var="stat" items="${statsRoles}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>];
                    showRoleDetails(labels[index]);
                }
            },
            plugins: {
                legend: {display: false},
                tooltip: {
                    backgroundColor: '#d4af37',
                    titleColor: '#1a1a1a',
                    bodyColor: '#1a1a1a'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {color: '#3d3d3d'},
                    ticks: {color: '#cccccc'}
                },
                x: {
                    grid: {color: '#3d3d3d'},
                    ticks: {color: '#cccccc'}
                }
            }
        }
    });

    // Graphique 5 : Masse salariale
    new Chart(document.getElementById('chartSalaires'), {
        type: 'bar',
        data: {
            labels: [<c:forEach var="stat" items="${statsSalaires}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>],
            datasets: [{
                label: 'Masse salariale (€)',
                data: [<c:forEach var="stat" items="${statsSalaires}" varStatus="status">${stat.value}<c:if test="${!status.last}">, </c:if></c:forEach>],
                backgroundColor: '#d4af37',
                borderColor: '#f4d03f',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            onClick: (event, elements) => {
                if (elements.length > 0) {
                    const index = elements[0].index;
                    const labels = [<c:forEach var="stat" items="${statsSalaires}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>];
                    showDeptDetails(labels[index]);
                }
            },
            plugins: {
                legend: {display: false},
                tooltip: {
                    backgroundColor: '#d4af37',
                    titleColor: '#1a1a1a',
                    bodyColor: '#1a1a1a'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {color: '#3d3d3d'},
                    ticks: {color: '#cccccc'}
                },
                x: {
                    grid: {color: '#3d3d3d'},
                    ticks: {color: '#cccccc'}
                }
            }
        }
    });

    // Graphique 6 : Top 5 projets
    new Chart(document.getElementById('chartTop5'), {
        type: 'bar',
        data: {
            labels: [<c:forEach var="projet" items="${top5Projets}" varStatus="status">'${projet.nom}'<c:if test="${!status.last}">, </c:if></c:forEach>],
            datasets: [{
                label: 'Employés',
                data: [<c:forEach var="projet" items="${top5Projets}" varStatus="status">${projet.nbEmployes}<c:if test="${!status.last}">, </c:if></c:forEach>],
                backgroundColor: '#f39c12',
                borderColor: '#e67e22',
                borderWidth: 2
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: false,
            onClick: (event, elements) => {
                if (elements.length > 0) {
                    const index = elements[0].index;
                    const labels = [<c:forEach var="projet" items="${top5Projets}" varStatus="status">'${projet.nom}'<c:if test="${!status.last}">, </c:if></c:forEach>];
                    showProjetDetails(labels[index]);
                }
            },
            plugins: {
                legend: {display: false},
                tooltip: {
                    backgroundColor: '#d4af37',
                    titleColor: '#1a1a1a',
                    bodyColor: '#1a1a1a'
                }
            },
            scales: {
                x: {
                    beginAtZero: true,
                    grid: {color: '#3d3d3d'},
                    ticks: {color: '#cccccc'}
                },
                y: {
                    grid: {color: '#3d3d3d'},
                    ticks: {color: '#cccccc'}
                }
            }
        }
    });

    // Graphique 7 : Absences
    <c:if test="${not empty statsAbsences}">
    new Chart(document.getElementById('chartAbsences'), {
        type: 'doughnut',
        data: {
            labels: [<c:forEach var="stat" items="${statsAbsences}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>],
            datasets: [{
                data: [<c:forEach var="stat" items="${statsAbsences}" varStatus="status">${stat.value}<c:if test="${!status.last}">, </c:if></c:forEach>],
                backgroundColor: ['#e67e22', '#e74c3c', '#95a5a6'],
                borderColor: '#1a1a1a',
                borderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            onClick: (event, elements) => {
                if (elements.length > 0) {
                    const index = elements[0].index;
                    const labels = [<c:forEach var="stat" items="${statsAbsences}" varStatus="status">'${stat.key}'<c:if test="${!status.last}">, </c:if></c:forEach>];
                    showAbsenceDetails(labels[index]);
                }
            },
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {color: '#cccccc'}
                },
                tooltip: {
                    backgroundColor: '#d4af37',
                    titleColor: '#1a1a1a',
                    bodyColor: '#1a1a1a'
                }
            }
        }
    });
    </c:if>
</script>
</body>
</html>