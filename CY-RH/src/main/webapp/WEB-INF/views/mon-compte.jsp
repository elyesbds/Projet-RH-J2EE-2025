<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Mon Compte - CY-RH</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=1.0">
    <style>
        /* Styles Dark & Gold pour les fiches de paie */
        .fiches-section {
            background: radial-gradient(circle at 10% 15%, rgba(212, 175, 55, 0.12), transparent 40%), #121212;
            padding: 28px;
            border-radius: 12px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.35);
            margin-top: 24px;
            border: 1px solid rgba(212, 175, 55, 0.18);
        }

        .fiches-section h2 {
            color: #d4af37;
            font-size: 24px;
            margin: 0 0 20px 0;
            border-bottom: 2px solid rgba(212, 175, 55, 0.45);
            padding-bottom: 10px;
        }

        .fiches-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        .fiches-table thead {
            background: linear-gradient(180deg, rgba(212, 175, 55, 0.08), rgba(37, 37, 37, 0.9));
            border-bottom: 1px solid rgba(212, 175, 55, 0.25);
        }

        .fiches-table th,
        .fiches-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #333;
            color: #e0e0e0;
        }

        .fiches-table th {
            font-weight: 600;
            color: #f0d479;
            text-transform: uppercase;
            font-size: 0.9em;
        }

        .fiches-table tbody tr {
            transition: background 0.2s, transform 0.2s, border-color 0.2s;
            border-left: 1px solid transparent;
        }

        .fiches-table tbody tr:hover {
            background-color: rgba(212, 175, 55, 0.06);
            transform: translateY(-1px);
            border-left-color: rgba(212, 175, 55, 0.4);
        }

        .fiches-table .text-right {
            text-align: right;
        }

        .net-amount {
            color: #f0d479;
            font-weight: 700;
            font-size: 1.1em;
            text-shadow: 0 0 6px rgba(212, 175, 55, 0.3);
        }

        .prime-positive {
            color: #4bb543;
        }

        .deduction-negative {
            color: #cf6679;
        }

        .btn-print {
            background-color: rgba(212, 175, 55, 0.12);
            color: #f0d479;
            padding: 7px 14px;
            border: 1px solid rgba(212, 175, 55, 0.6);
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            font-size: 12px;
            display: inline-block;
            transition: all 0.3s;
            box-shadow: 0 6px 14px rgba(0, 0, 0, 0.35);
        }

        .btn-print:hover {
            background-color: #d4af37;
            color: #0d0d0d;
            box-shadow: 0 0 10px rgba(212, 175, 55, 0.3), 0 10px 20px rgba(0, 0, 0, 0.35);
        }

        .no-fiches {
            text-align: center;
            padding: 40px;
            color: #c9c9c9;
            font-style: italic;
            background: #1a1a1a;
            border-radius: 10px;
            border: 1px dashed rgba(212, 175, 55, 0.35);
        }

        .fiches-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 20px;
            margin-top: 30px;
            padding: 20px;
            background: linear-gradient(135deg, #1a1a1a, #121212);
            border-radius: 10px;
            border: 1px solid rgba(212, 175, 55, 0.18);
        }

        .stat-box {
            text-align: center;
            padding: 16px;
            background: linear-gradient(135deg, #181818, #111);
            border-radius: 10px;
            border: 1px solid rgba(212, 175, 55, 0.18);
            transition: transform 0.3s, border-color 0.3s, box-shadow 0.3s;
        }

        .stat-box:hover {
            transform: translateY(-3px);
            border-color: rgba(212, 175, 55, 0.45);
            box-shadow: 0 10px 22px rgba(0, 0, 0, 0.35), 0 0 12px rgba(212, 175, 55, 0.22);
        }

        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #d4af37;
        }

        .stat-label {
            font-size: 12px;
            color: #b0b0b0;
            margin-top: 5px;
            text-transform: uppercase;
        }
    </style>
</head>

<body>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <h1>Mon Compte</h1>

    <!-- Message de succès -->
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">
                ${sessionScope.successMessage}
        </div>
        <c:remove var="successMessage" scope="session" />
    </c:if>

    <!-- Bouton modifier -->
    <div class="action-bar">
        <a href="${pageContext.request.contextPath}/editer-mon-compte" class="btn btn-primary">
            Modifier mes informations
        </a>
    </div>

    <!-- Informations personnelles -->
    <div class="info-section">
        <h2>Informations personnelles</h2>
        <div class="info-grid">
            <div class="info-item">
                <strong>Matricule :</strong>
                <span>${user.matricule}</span>
            </div>
            <div class="info-item">
                <strong>Nom complet :</strong>
                <span>${user.prenom} ${user.nom}</span>
            </div>
            <div class="info-item">
                <strong>Email :</strong>
                <span>${user.email}</span>
            </div>
            <div class="info-item">
                <strong>Téléphone :</strong>
                <span>${user.telephone != null ? user.telephone : 'Non renseigné'}</span>
            </div>
            <div class="info-item">
                <strong>Poste :</strong>
                <span>${user.poste}</span>
            </div>
            <div class="info-item">
                <strong>Grade :</strong>
                <span class="badge badge-grade">${user.grade}</span>
            </div>
            <div class="info-item">
                <strong>Salaire de base :</strong>
                <span>
                                        <fmt:formatNumber value="${user.salaireBase}" type="currency"
                                                          currencySymbol="€" />
                                    </span>
            </div>
            <div class="info-item">
                <strong>Date d'embauche :</strong>
                <span>
                                        <fmt:formatDate value="${user.dateEmbauche}" pattern="dd/MM/yyyy" />
                                    </span>
            </div>
            <div class="info-item">
                <strong>Rôle :</strong>
                <span class="badge badge-chef">${user.role}</span>
            </div>
        </div>
    </div>

    <!-- Informations complémentaires -->
    <div class="info-section">
        <h2>Département</h2>
        <p>
            <c:choose>
                <c:when test="${departement != null}">
                    <strong>Vous êtes rattaché au département :</strong> ${departement.intitule}
                </c:when>
                <c:otherwise>
                    <em>Vous n'êtes rattaché à aucun département actuellement.</em>
                </c:otherwise>
            </c:choose>
        </p>
    </div>

    <!-- Lien vers mes projets -->
    <div class="info-section">
        <h2>Mes projets</h2>
        <p>
            Pour consulter vos projets, rendez-vous dans l'onglet :
            <a href="${pageContext.request.contextPath}/projets" class="btn-link-small">
                Projets
            </a>
        </p>
    </div>

    <!-- Section fiches de paie -->
    <div class="fiches-section">
        <h2>Mes Fiches de Paie</h2>

        <c:choose>
            <c:when test="${empty fichesDePaie}">
                <div class="no-fiches">
                    <h3>Aucune fiche de paie</h3>
                    <p>Vous n'avez pas encore de fiches de paie enregistrées dans le système.</p>
                </div>
            </c:when>
            <c:otherwise>
                <table class="fiches-table">
                    <thead>
                    <tr>
                        <th>Période</th>
                        <th class="text-right">Salaire Base</th>
                        <th class="text-right">Primes</th>
                        <th class="text-right">Déductions</th>
                        <th class="text-right">Net à Payer</th>
                        <th>Date Génération</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${fichesDePaie}" var="fiche">
                        <tr>
                            <!-- Période -->
                            <td>
                                <strong>
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
                                </strong>
                            </td>

                            <!-- Salaire Base -->
                            <td class="text-right">
                                <fmt:formatNumber value="${fiche.salaireBase}"
                                                  pattern="#,##0.00" /> €
                            </td>

                            <!-- Primes -->
                            <td class="text-right">
                                <c:choose>
                                    <c:when test="${fiche.primes > 0}">
                                                                <span class="prime-positive">
                                                                    +
                                                                    <fmt:formatNumber value="${fiche.primes}"
                                                                                      pattern="#,##0.00" /> €
                                                                </span>
                                    </c:when>
                                    <c:otherwise>
                                        0.00 €
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <!-- Déductions -->
                            <td class="text-right">
                                <c:choose>
                                    <c:when test="${fiche.deductions > 0}">
                                                                <span class="deduction-negative">
                                                                    -
                                                                    <fmt:formatNumber value="${fiche.deductions}"
                                                                                      pattern="#,##0.00" /> €
                                                                </span>
                                    </c:when>
                                    <c:otherwise>
                                        0.00 €
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <!-- Net à Payer -->
                            <td class="text-right">
                                                        <span class="net-amount">
                                                            <fmt:formatNumber value="${fiche.netAPayer}"
                                                                              pattern="#,##0.00" /> €
                                                        </span>
                            </td>

                            <!-- Date Génération -->
                            <td>
                                <fmt:formatDate value="${fiche.dateGeneration}"
                                                pattern="dd/MM/yyyy" />
                            </td>

						<!-- Action : Bouton Imprimer -->
						<td>
						    <a href="${pageContext.request.contextPath}/fiches-paie/voir?id=${fiche.id}&from=mon-compte"
						       class="btn-print" 
						       title="Voir et imprimer cette fiche">
						        Imprimer
						    </a>
						</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

                <!-- Statistiques -->
                <div class="fiches-stats">
                    <div class="stat-box">
                        <div class="stat-value">${fichesDePaie.size()}</div>
                        <div class="stat-label">Fiche(s) de paie</div>
                    </div>

                    <c:if test="${not empty fichesDePaie}">
                        <div class="stat-box">
                            <div class="stat-value">
                                <fmt:formatNumber value="${fichesDePaie[0].netAPayer}"
                                                  pattern="#,##0" /> €
                            </div>
                            <div class="stat-label">Dernier salaire</div>
                        </div>

                        <div class="stat-box">
                            <div class="stat-value">
                                <c:choose>
                                    <c:when test="${fichesDePaie[0].mois == 1}">Jan</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 2}">Fév</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 3}">Mar</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 4}">Avr</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 5}">Mai</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 6}">Jun</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 7}">Jul</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 8}">Aoû</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 9}">Sep</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 10}">Oct</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 11}">Nov</c:when>
                                    <c:when test="${fichesDePaie[0].mois == 12}">Déc</c:when>
                                </c:choose>
                                    ${fichesDePaie[0].annee}
                            </div>
                            <div class="stat-label">Dernière période</div>
                        </div>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <!-- Fin section fiches de paie -->

</div>
</body>

</html>