package models;

import jakarta.persistence.*;

import java.util.Date;

/**
 * Entité représentant un projet
 */
@Entity
@Table(name = "Projet")
public class Projet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "Nom_projet", nullable = false, length = 150)
    private String nomProjet;

    @Column(name = "Etat_projet", nullable = false, length = 30)
    private String etatProjet = "EN_COURS";

    @Column(name = "Date_debut", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date dateDebut;

    @Column(name = "Date_fin_prevue")
    @Temporal(TemporalType.DATE)
    private Date dateFinPrevue;

    @Column(name = "Date_fin_reelle")
    @Temporal(TemporalType.DATE)
    private Date dateFinReelle;

    @Column(name = "Chef_projet")
    private Integer chefProjet;

    @Column(name = "Id_departement")
    private Integer idDepartement;

    // Constructeurs
    public Projet() {
    }

    // Getters et Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNomProjet() {
        return nomProjet;
    }

    public void setNomProjet(String nomProjet) {
        this.nomProjet = nomProjet;
    }

    public String getEtatProjet() {
        return etatProjet;
    }

    public void setEtatProjet(String etatProjet) {
        this.etatProjet = etatProjet;
    }

    public Date getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(Date dateDebut) {
        this.dateDebut = dateDebut;
    }

    public Date getDateFinPrevue() {
        return dateFinPrevue;
    }

    public void setDateFinPrevue(Date dateFinPrevue) {
        this.dateFinPrevue = dateFinPrevue;
    }

    public Date getDateFinReelle() {
        return dateFinReelle;
    }

    public void setDateFinReelle(Date dateFinReelle) {
        this.dateFinReelle = dateFinReelle;
    }

    public Integer getChefProjet() {
        return chefProjet;
    }

    public void setChefProjet(Integer chefProjet) {
        this.chefProjet = chefProjet;
    }

    public Integer getIdDepartement() {
        return idDepartement;
    }

    public void setIdDepartement(Integer idDepartement) {
        this.idDepartement = idDepartement;
    }
}