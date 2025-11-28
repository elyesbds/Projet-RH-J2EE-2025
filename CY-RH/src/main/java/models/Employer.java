package models;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.Date;

/**
 * Entité représentant un employé
 */
@Entity
@Table(name = "Employer")
public class Employer {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Column(length = 30, unique = true)
    private String matricule;
    
    @Column(nullable = false, length = 50)
    private String nom;
    
    @Column(nullable = false, length = 50)
    private String prenom;
    
    @Column(nullable = false, unique = true, length = 100)
    private String email;
    
    @Column(length = 20)
    private String telephone;
    
    @Column(nullable = false, length = 255)
    private String password;
    
    @Column(nullable = false, length = 100)
    private String poste;
    
    @Column(nullable = false, length = 50)
    private String grade;
    
    @Column(name = "Salaire_base", nullable = false, precision = 10, scale = 2)
    private BigDecimal salaireBase;
    
    @Column(name = "Date_embauche", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date dateEmbauche;
    
    @Column(name = "Id_departement")
    private Integer idDepartement;
    
    @Column(nullable = false, length = 30)
    private String role = "EMPLOYE";
    
    // Constructeurs
    public Employer() {}
    
    // Getters et Setters
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public String getMatricule() {
        return matricule;
    }
    
    public void setMatricule(String matricule) {
        this.matricule = matricule;
    }
    
    public String getNom() {
        return nom;
    }
    
    public void setNom(String nom) {
        this.nom = nom;
    }
    
    public String getPrenom() {
        return prenom;
    }
    
    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getTelephone() {
        return telephone;
    }
    
    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getPoste() {
        return poste;
    }
    
    public void setPoste(String poste) {
        this.poste = poste;
    }
    
    public String getGrade() {
        return grade;
    }
    
    public void setGrade(String grade) {
        this.grade = grade;
    }
    
    public BigDecimal getSalaireBase() {
        return salaireBase;
    }
    
    public void setSalaireBase(BigDecimal salaireBase) {
        this.salaireBase = salaireBase;
    }
    
    public Date getDateEmbauche() {
        return dateEmbauche;
    }
    
    public void setDateEmbauche(Date dateEmbauche) {
        this.dateEmbauche = dateEmbauche;
    }
    
    public Integer getIdDepartement() {
        return idDepartement;
    }
    
    public void setIdDepartement(Integer idDepartement) {
        this.idDepartement = idDepartement;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
}