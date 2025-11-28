package models;

import jakarta.persistence.*;
import java.util.Date;

/**
 * Entité représentant l'affectation d'un employé à un projet
 */
@Entity
@Table(name = "Affectation_projet")
public class AffectationProjet {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Column(name = "Id_employer", nullable = false)
    private Integer idEmployer;
    
    @Column(name = "Id_projet", nullable = false)
    private Integer idProjet;
    
    @Column(name = "Date_affectation", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date dateAffectation;
    
    @Column(name = "Date_fin_affectation")
    @Temporal(TemporalType.DATE)
    private Date dateFinAffectation;
    
    // Constructeurs
    public AffectationProjet() {}
    
    // Getters et Setters
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
    
    public Integer getIdProjet() {
        return idProjet;
    }
    
    public void setIdProjet(Integer idProjet) {
        this.idProjet = idProjet;
    }
    
    public Date getDateAffectation() {
        return dateAffectation;
    }
    
    public void setDateAffectation(Date dateAffectation) {
        this.dateAffectation = dateAffectation;
    }
    
    public Date getDateFinAffectation() {
        return dateFinAffectation;
    }
    
    public void setDateFinAffectation(Date dateFinAffectation) {
        this.dateFinAffectation = dateFinAffectation;
    }
}