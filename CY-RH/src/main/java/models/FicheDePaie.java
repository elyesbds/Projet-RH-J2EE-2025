package models;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.Date;

/**
 * Entité représentant une fiche de paie
 * Une fiche de paie est générée pour un employé pour un mois donné
 * Calcul : Net à payer = Salaire de base + Primes - Déductions
 */
@Entity
@Table(name = "Fiche_de_paie")
public class FicheDePaie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // L'employé concerné par cette fiche de paie
    @Column(name = "Id_employer", nullable = false)
    private Integer idEmployer;

    // Le mois de la fiche de paie (1-12)
    @Column(nullable = false)
    private Integer mois;

    // L'année de la fiche de paie (ex: 2025)
    @Column(nullable = false)
    private Integer annee;

    // Le salaire de base de l'employé
    @Column(name = "Salaire_base", nullable = false, precision = 10, scale = 2)
    private BigDecimal salaireBase;

    // Les primes (bonus, heures supplémentaires, etc.)
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal primes = BigDecimal.ZERO;

    // Les déductions (retards, absences, etc.)
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal deductions = BigDecimal.ZERO;

    // Le net à payer (calculé automatiquement)
    @Column(name = "Net_a_payer", nullable = false, precision = 10, scale = 2)
    private BigDecimal netAPayer;

    // Date de génération de la fiche de paie
    @Column(name = "Date_generation", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date dateGeneration;

    //  CONSTRUCTEURS


    public FicheDePaie() {
    }


    public FicheDePaie(Integer idEmployer, Integer mois, Integer annee,
                       BigDecimal salaireBase, BigDecimal primes, BigDecimal deductions) {
        this.idEmployer = idEmployer;
        this.mois = mois;
        this.annee = annee;
        this.salaireBase = salaireBase;
        this.primes = primes;
        this.deductions = deductions;
        this.dateGeneration = new Date();
        // Calcul automatique du net à payer
        this.calculerNetAPayer();
    }


    /**
     * Calculer automatiquement le net à payer
     * Formule : Net à payer = Salaire de base + Primes - Déductions
     */
    public void calculerNetAPayer() {
        if (this.salaireBase != null && this.primes != null && this.deductions != null) {
            this.netAPayer = this.salaireBase
                    .add(this.primes)
                    .subtract(this.deductions);
        }
    }

    // GETTERS ET SETTERS 

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getIdEmployer() {
        return idEmployer;
    }

    public void setIdEmployer(Integer idEmployer) {
        this.idEmployer = idEmployer;
    }

    public Integer getMois() {
        return mois;
    }

    public void setMois(Integer mois) {
        this.mois = mois;
    }

    public Integer getAnnee() {
        return annee;
    }

    public void setAnnee(Integer annee) {
        this.annee = annee;
    }

    public BigDecimal getSalaireBase() {
        return salaireBase;
    }

    public void setSalaireBase(BigDecimal salaireBase) {
        this.salaireBase = salaireBase;
        // Recalculer le net à payer quand on change le salaire
        calculerNetAPayer();
    }

    public BigDecimal getPrimes() {
        return primes;
    }

    public void setPrimes(BigDecimal primes) {
        this.primes = primes;
        // Recalculer le net à payer quand on change les primes
        calculerNetAPayer();
    }

    public BigDecimal getDeductions() {
        return deductions;
    }

    public void setDeductions(BigDecimal deductions) {
        this.deductions = deductions;
        // Recalculer le net à payer quand on change les déductions
        calculerNetAPayer();
    }

    public BigDecimal getNetAPayer() {
        return netAPayer;
    }

    public void setNetAPayer(BigDecimal netAPayer) {
        this.netAPayer = netAPayer;
    }

    public Date getDateGeneration() {
        return dateGeneration;
    }

    public void setDateGeneration(Date dateGeneration) {
        this.dateGeneration = dateGeneration;
    }
}