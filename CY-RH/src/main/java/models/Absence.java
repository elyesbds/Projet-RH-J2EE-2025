package models;

import jakarta.persistence.*;
import java.util.Date;

/**
 * Entité représentant une absence d'un employé
 * Types : CONGE, MALADIE, ABSENCE_INJUSTIFIEE
 */
@Entity
@Table(name = "Absence")
public class Absence {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    // L'employé concerné par cette absence
    @Column(name = "Id_employer", nullable = false)
    private Integer idEmployer;
    
    // Date de début de l'absence
    @Column(name = "Date_debut", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date dateDebut;
    
    // Date de fin de l'absence
    @Column(name = "Date_fin", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date dateFin;
    
    // Type d'absence : CONGE, MALADIE, ABSENCE_INJUSTIFIEE
    @Column(name = "Type_absence", nullable = false, length = 50)
    private String typeAbsence;
    
    // Motif optionnel de l'absence
    @Column(columnDefinition = "TEXT")
    private String motif;
    
    // Constructeurs
    public Absence() {}
    
    public Absence(Integer idEmployer, Date dateDebut, Date dateFin, String typeAbsence, String motif) {
        this.idEmployer = idEmployer;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.typeAbsence = typeAbsence;
        this.motif = motif;
    }
    
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
    
    public Date getDateDebut() {
        return dateDebut;
    }
    
    public void setDateDebut(Date dateDebut) {
        this.dateDebut = dateDebut;
    }
    
    public Date getDateFin() {
        return dateFin;
    }
    
    public void setDateFin(Date dateFin) {
        this.dateFin = dateFin;
    }
    
    public String getTypeAbsence() {
        return typeAbsence;
    }
    
    public void setTypeAbsence(String typeAbsence) {
        this.typeAbsence = typeAbsence;
    }
    
    public String getMotif() {
        return motif;
    }
    
    public void setMotif(String motif) {
        this.motif = motif;
    }
}