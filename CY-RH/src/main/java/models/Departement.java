package models;

import jakarta.persistence.*;

/**
 * Entité représentant un département
 */
@Entity
@Table(name = "Departement")
public class Departement {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @Column(nullable = false, unique = true, length = 100)
    private String intitule;
    
    @Column(name = "Chef_departement")
    private Integer chefDepartement;
    
    // Constructeurs
    public Departement() {}
    
    public Departement(String intitule) {
        this.intitule = intitule;
    }
    
    // Getters et Setters
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public String getIntitule() {
        return intitule;
    }
    
    public void setIntitule(String intitule) {
        this.intitule = intitule;
    }
    
    public Integer getChefDepartement() {
        return chefDepartement;
    }
    
    public void setChefDepartement(Integer chefDepartement) {
        this.chefDepartement = chefDepartement;
    }
}